
module("luci.controller.getlink", package.seeall)

function index()
  entry({"admin", "services", "getlink"}, alias("admin", "services", "getlink", "config"), _("GETL Edge Node"), 30).dependent = true
  entry({"admin", "services", "getlink", "config"}, cbi("getlink"))
end
