--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local getlink_model = require "luci.model.getlink"
local m, s, o

m = taskd.docker_map("getlink", "getlink", "/usr/libexec/istorec/getlink.sh",
	translate("GETL Edge Node"),
	"GETL边缘节点-(GETL Edge Node)：由 GETL共享计算平台 推出的一款 基于OP路由器系统的 docker 容器镜像软件，通过在简单安装后即可快速加入GETL共享计算平台，可根据用户每日的贡献量，按周结算收益回报。了解更多，请登录「<a href=\"https://www.tigocloud.cn/\" target=\"_blank\" >GETL共享计算平台官网</a>」并查看<a href=\"https://tigocloud.feishu.cn/wiki/EqShweDN3iDA5IkJwkacJPwhnxe\" target=\"_blank\">「使用教程」</a>")

s = m:section(SimpleSection, translate("Service Status"), translate("GETL Edge Node status:"), "注意 GETL边缘节点 会以超级权限运行！")
s:append(Template("getlink/status"))

s = m:section(TypedSection, "getlink", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

local default_image = getlink_model.default_image()
o = s:option(Value, "image_name", translate("镜像 Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("registry.cn-hangzhou.aliyuncs.com/babi-public/byy-agent-ipes:amd64", "registry.cn-hangzhou.aliyuncs.com/babi-public/byy-agent-ipes:amd64")
o:value("registry.cn-hangzhou.aliyuncs.com/babi-public/byy-agent-ipes:arm64", "registry.cn-hangzhou.aliyuncs.com/babi-public/byy-agent-ipes:arm64")
o.default = default_image

local blks = getlink_model.blocks()
local dir
o = s:option(Value, "cache_path", translate("Cache path").."<b>*</b>", "请选择合适的存储位置进行安装，安装位置容量越大，收益越高。安装后请勿轻易改动")
o.rmempty = false
o.datatype = "string"
for _, dir in pairs(blks) do
	dir = dir .. "/getlink1"
	o:value(dir, dir)
end
if #blks > 0 then
    o.default = blks[1] .. "/getlink1"
end

return m
