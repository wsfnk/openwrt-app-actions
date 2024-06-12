local util  = require "luci.util"
local jsonc = require "luci.jsonc"
local nixio = require "nixio"

local tgedge = {}

tgedge.blocks = function()
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

tgedge.default_image = function()
  if string.find(nixio.uname().machine, "aarch64") then
    return "registry.cn-hangzhou.aliyuncs.com/babi-public/byy-agent-ipes:arm64"
  else
    return "onething1/tgedge:2.4.3"
  end
end

return tgedge

