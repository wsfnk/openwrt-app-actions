#!/bin/sh

ACTION=${1}
shift 1

do_install() {
  local path=`uci get tgedge.@tgedge[0].cache_path 2>/dev/null`
  local image_name=`uci get tgedge.@tgedge[0].image_name 2>/dev/null`

  if [ -z "$path" ]; then
      echo "path is empty!"
      exit 1
  fi

  mkdir -p /opt/moecdn/ipes
  echo "" > /opt/moecdn/ipes/sn
echo "args:
        - /data/storage" > /opt/moecdn/ipes/custom.yml

  [ -z "$image_name" ] && image_name="registry.cn-hangzhou.aliyuncs.com/babi-public/byy-agent-ipes"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f tgedge

  #local cmd="docker run --restart=unless-stopped -d \
  #  --privileged \
  #  --network=host \
  #  --dns=127.0.0.1 \
  #  --tmpfs /run \
  #  --tmpfs /tmp \
  #  -v \"$path:/storage\" \
  #  -v \"$path/containerd:/var/lib/containerd\" \
  #  -e PLACE=CTKS"

  local cmd="docker run --restart=unless-stopped -d \
    --cap-add SYS_RAWIO \
    --ulimit core=0 \
    -v /opt/moecdn/ipes/custom.yml:/root/ipes/var/db/ipes/happ-conf/custom.yml \
    -v /opt/moecdn/ipes/sn:/root/ipes/bin/ipes_sn \
    --net=host \
    -v \"$path:/data1\""

    #-v /opt/moecdn/ipes/custom.yml:/tigocloud/ipes/var/db/ipes/happ-conf/custom.yml \
    #-v /opt/moecdn/ipes/sn:/tigocloud/ipes/bin/ipes_sn \
    #--restart=always \
  echo $path > /opt/moecdn/ipes/openwrt_cache_path
  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd --name tgedge \"$image_name\""

  echo "$cmd"
  eval "$cmd"

  if [ "$?" = "0" ]; then
    if [ "`uci -q get firewall.tgedge.enabled`" = 0 ]; then
      uci -q batch <<-EOF >/dev/null
        set firewall.tgedge.enabled="1"
        commit firewall
EOF
      /etc/init.d/firewall reload
    fi
  fi

}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the tgedge"
  echo "      upgrade                Upgrade the tgedge"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the tgedge"
  echo "      status                 Onething Edge status"
  echo "      port                   Onething Edge port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f tgedge
    [ "$(uname -m)" = "aarch64" ] && docker rmi registry.cn-hangzhou.aliyuncs.com/babi-public/byy-agent-ipes:arm64
    [ "$(uname -m)" = "x86_64" ] && docker rmi registry.cn-hangzhou.aliyuncs.com/babi-public/byy-agent-ipes:amd64
    docker rmi $(docker images -f "dangling=true" -q)
    rm -rf $(cat /opt/moecdn/ipes/openwrt_cache_path)
    #rm -rf "$path"
    rm /opt/moecdn/ipes -rf
    if [ "`uci -q get firewall.tgedge.enabled`" = 1 ]; then
      uci -q batch <<-EOF >/dev/null
        set firewall.tgedge.enabled="0"
        commit firewall
EOF
      /etc/init.d/firewall reload
    fi
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} tgedge
  ;;
  "status")
    docker ps --all -f 'name=tgedge' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=tgedge' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac
