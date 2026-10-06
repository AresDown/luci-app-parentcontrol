local o = require "luci.sys"
local fs = require "nixio.fs"
local ipc = require "luci.ip"
local net = require "luci.model.network".init()
local sys = require "luci.sys"
local a, t, e
a = Map("parentcontrol", translate("Parent Control"), translate("<b><font color=\"green\">利用 crontab 来管控以禁止符合设定条件的用户连接互联网的工具软件。</font> </b></br>\
时间限制:限制指定MAC地址机器是否联网.包括IPV4和IPV6</br>不指定MAC就是代表限制所有机器,星期用1-7表示，多个日期用自定义：1,5表示星期一和星期五" ))
a.template = "parentcontrol/index"

t = a:section(TypedSection, "basic", translate(""))
t.anonymous = true

e = t:option(DummyValue, "parentcontrol_status", translate("当前状态"))
e.template = "parentcontrol/parentcontrol"
e.value = translate("Collecting data...")

e = t:option(Flag, "enabled", translate("开启"))
e.rmempty = false

e = t:option(ListValue, "control_mode",translate("路由器访问控制"), translate("普通管控：限制客户端访问互联网，但允许访问路由器后台。强力管控：同时限制客户端访问路由器后台、DNS 等本机服务。注意：强力管控下，被管控的客户端可能无法访问软路由后台。"))
e.rmempty = false
e:value("0", "允许访问路由器后台")
e:value("1", "禁止访问路由器后台")
e.default = "0"

t = a:section(TypedSection, "time", translate("时间限制列表"))
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true

e = t:option(Value, 'remarks', translate('Remarks'))

e = t:option(Flag, "enable", translate("开启"))
e.rmempty = false
e.default = '1'

e = t:option(Value, "mac", translate("MAC地址<font color=\"green\">(留空为全部客户端)</font>"))

e.rmempty = true
o.net.mac_hints(function(t, a) e:value(t, "%s (%s)" % {t, a}) end)

    function validate_time(self, value, section)
        local hh, mm, ss
        hh, mm, ss = string.match (value, "^(%d?%d):(%d%d)$")
        hh = tonumber (hh)
        mm = tonumber (mm)
        if hh and mm and hh <= 23 and mm <= 59 then
            return value
        else
            return nil, "时间格式必须为 HH:MM 或者留空"
        end
    end
    
e = t:option(Value, "timestart", translate("起控时间"))
e.placeholder = '00:00'
e.default = '00:00'
e.validate = validate_time
e.rmempty = true

e = t:option(Value, "timeend", translate("停控时间"))
e.placeholder = '00:00'
e.default = '00:00'
e.validate = validate_time
e.rmempty = true

week=t:option(Value,"week",translate("Week Day"))
week.rmempty = true
week:value('*',translate("Everyday"))
week:value(7,translate("Sunday"))
week:value(1,translate("Monday"))
week:value(2,translate("Tuesday"))
week:value(3,translate("Wednesday"))
week:value(4,translate("Thursday"))
week:value(5,translate("Friday"))
week:value(6,translate("Saturday"))
week.default='*'

t = a:section(TypedSection, "speed", translate("速度限制列表"))
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true

e = t:option(Value, 'remarks', translate('Remarks'))

e = t:option(Flag, "enable", translate("开启"))
e.rmempty = false
e.default = '1'

e = t:option(Value, "mac", translate("MAC地址<font color=\"green\">(留空为全部客户端)</font>"))
e.rmempty = true
o.net.mac_hints(function(t, a) e:value(t, "%s (%s)" % {t, a}) end)

e = t:option(Value, "rate", translate("限速速率<font color=\"green\">(如 100kbit 1mbit 0.5mbit 1kb 1mb)</font>"))
e.placeholder = '1mbit'
e.default = '1mbit'
e.rmempty = true

function e.validate(self, value, section)
    if not value or value == "" then return value end
    local num, unit = value:lower():match("^([0-9]*%.?[0-9]+)(%a+)$")
    if not num then
        num = value:match("^([0-9]*%.?[0-9]+)$")
        if num then return value end
        return nil, "格式错误，示例: 100kbit, 1mbit, 0.5mbit, 1kb, 1mb"
    end
    local valid_units = { bit=1, bps=1, kbit=1, kbps=1, mbit=1, mbps=1, gbit=1, gbps=1, b=1, kb=1, mb=1, gb=1 }
    if not valid_units[unit] then
        return nil, "不支持的单位，可用: kbit mbit gbit kb mb gb"
    end
    return value
end

e = t:option(Value, "timestart", translate("起控时间"))
e.placeholder = '00:00'
e.default = '00:00'
e.validate = validate_time
e.rmempty = true

e = t:option(Value, "timeend", translate("停控时间"))
e.placeholder = '00:00'
e.default = '00:00'
e.validate = validate_time
e.rmempty = true

week=t:option(Value,"week",translate("Week Day"))
week.rmempty = true
week:value('*',translate("Everyday"))
week:value(7,translate("Sunday"))
week:value(1,translate("Monday"))
week:value(2,translate("Tuesday"))
week:value(3,translate("Wednesday"))
week:value(4,translate("Thursday"))
week:value(5,translate("Friday"))
week:value(6,translate("Saturday"))
week.default='*'

a.apply_on_parse = true

function a.on_after_commit(self)
    luci.sys.call("/etc/init.d/parentcontrol restart >/dev/null 2>&1")
end

return a
