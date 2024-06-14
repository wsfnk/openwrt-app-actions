--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local tgedge_model = require "luci.model.tgedge"
local m, s, o

m = taskd.docker_map("tgedge", "tgedge", "/usr/libexec/istorec/tgedge.sh",
	translate("TiGO Edge"),
	"甜果云-(TiGO Edge)：由 甜果云 推出的一款 基于OP路由器系统的 docker 容器镜像软件，通过在简单安装后即可快速加入甜果云，可根据用户每日的贡献量，按周结算收益回报。了解更多，请登录「<a href=\"https://www.tigocloud.cn/\" target=\"_blank\" >甜果云官网</a>」并查看<a href=\"https://tigocloud.feishu.cn/wiki/EqShweDN3iDA5IkJwkacJPwhnxe\" target=\"_blank\">「使用教程」</a>")

s = m:section(SimpleSection, translate("Service Status"), translate("TiGO Edge status:"), "注意甜果云会以超级权限运行！")
s:append(Template("tgedge/status"))

s = m:section(TypedSection, "tgedge", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

local default_image = tgedge_model.default_image()
o = s:option(Value, "image_name", translate("镜像 Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("registry.cn-hangzhou.aliyuncs.com/babi-public/byy-agent-ipes:amd64", "registry.cn-hangzhou.aliyuncs.com/babi-public/byy-agent-ipes:amd64")
o:value("registry.cn-hangzhou.aliyuncs.com/babi-public/byy-agent-ipes:arm64", "registry.cn-hangzhou.aliyuncs.com/babi-public/byy-agent-ipes:arm64")
o.default = default_image

local blks = tgedge_model.blocks()
local dir
o = s:option(Value, "cache_path", translate("Cache path").."<b>*</b>", "请选择合适的存储位置进行安装，安装位置容量越大，收益越高。安装后请勿轻易改动")
o.rmempty = false
o.datatype = "string"
for _, dir in pairs(blks) do
	dir = dir .. "/tgedge1"
	o:value(dir, dir)
end
if #blks > 0 then
    o.default = blks[1] .. "/tgedge1"
end

return m
