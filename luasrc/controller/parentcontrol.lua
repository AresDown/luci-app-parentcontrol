module("luci.controller.parentcontrol", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/parentcontrol") then return end

    entry({"admin", "control"}, firstchild(), "Control", 44).dependent = false
    local e = entry({"admin","control","parentcontrol"}, firstchild(), _("Parent Control"), 2)
    e.dependent = false
    e.acl_depends = { "luci-app-parentcontrol" }

    entry({"admin","control","parentcontrol","time"}, cbi("parentcontrol/time"), _("Time Control"), 1).leaf = true
    entry({"admin","control","parentcontrol","status"}, call("status")).leaf = true
end

function status()
    local e = {}
    local lock_running = nixio.fs.access("/tmp/lock/parentcontrol.lock")

    local time_chain_running = (luci.sys.call("/usr/sbin/nft list chain inet fw4 parentcontrol_time >/dev/null 2>&1") == 0)
    local speed_chain_running = (luci.sys.call("/usr/sbin/nft list chain inet fw4 parentcontrol_speed >/dev/null 2>&1") == 0)

    local cron_running = (luci.sys.call("grep -q '# parentcontrol' /etc/crontabs/root >/dev/null 2>&1") == 0)

    if not lock_running then
        e.status = "inactive"
    elseif (time_chain_running or speed_chain_running) and cron_running then
        e.status = "running"
    else
        e.status = "started_no_rules"
    end

    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end
