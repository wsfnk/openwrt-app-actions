
module("luci.controller.tgedge", package.seeall)

function index()
  entry({"admin", "services", "tgedge"}, alias("admin", "services", "tgedge", "config"), _("TiGO Edge"), 30).dependent = true
  entry({"admin", "services", "tgedge", "config"}, cbi("tgedge"))
end
