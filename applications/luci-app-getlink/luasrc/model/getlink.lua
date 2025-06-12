local util  = require "luci.util"
local jsonc = require "luci.jsonc"
local nixio = require "nixio"

local getlink = {}

getlink.blocks = function()
  local f = io.popen("lsblk -s -f -b -o NAME,FSSIZE,MOUNTPOINT --json", "r")
  local vals = {}
  if f then
    local ret = f:read("*all")
    f:close()
    local obj = jsonc.parse(ret)
    for _, val in pairs(obj["blockdevices"]) do
      local fsize = val["fssize"]
      if fsize ~= nil and string.len(fsize) > 10 and val["mountpoint"] then
        -- fsize > 1G
        vals[#vals+1] = val["mountpoint"]
      end
    end
  end
  return vals
end

getlink.default_image = function()
  if string.find(nixio.uname().machine, "aarch64") then
    return "registry.cn-hangzhou.aliyuncs.com/getlink/ipes:arm64"
  else
    return "registry.cn-hangzhou.aliyuncs.com/getlink/ipes:amd64"
  end
end

return getlink
