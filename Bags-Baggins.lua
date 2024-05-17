local me,ns=...
local addon=ns.addon
local module=ns.module
local bagManagers={} --#_bags
if LibDebug then LibDebug() end
function module:OnEnabled()
	self:SecureHook(Baggins,"UpdateItemButton","Display")
end
function module:Display(baggins,bagframe,button,bag,slot)
	local quality,itemlink,class=self:GetInfo(nil,bag,slot)
	self:DrawItem(button,quality,itemlink,class)
end
