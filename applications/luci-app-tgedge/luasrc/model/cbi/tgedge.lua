--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local tgedge_model = require "luci.model.tgedge"
local m, s, o

m = taskd.docker_map("tgedge", "tgedge", "/usr/libexec/istorec/tgedge.sh",
	translate("TiGO Edge"),
	"「甜果容器云 TiGO Edge 」由甜果云推出的一款 docker 容器镜像软件，通过在简单安装后即可快速加入甜果云，用户可根据每日的贡献量获得相应的现金收益回报。了解更多，请登录「<a href=\"https://www.tigocloud.cn/\" target=\"_blank\" >甜果云官网</a>」并查看<a href=\"https://doc.linkease.com/zh/guide/istoreos/software/tgedge.html\" target=\"_blank\">「教程」</a>")

s = m:section(SimpleSection, translate("服务状态"), translate("甜果云 TiGO Edge 状态: "), "注意甜果云会以超级权限运行！")
s:append(Template("tgedge/status"))

s = m:section(TypedSection, "tgedge", translate("安装配置"), translate("以下参数只在安装或者升级时才会生效: "))
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
o = s:option(Value, "cache_path", translate("缓存路径 Cache path").."<b>*</b>", "请选择合适的存储位置进行安装，安装位置容量越大，收益越高。安装后请勿轻易改动")
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
