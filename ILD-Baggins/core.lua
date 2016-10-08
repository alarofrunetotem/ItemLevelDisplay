local me,ns=...
local addon=ns.addon
local module=ns.module
local bagManagers={} --#_bags
if LibDebug then LibDebug() end
function module:OnInitialized()
	self:UnregisterAllEvents()
	self:SecureHook(Baggins,"UpdateItemButton","Display")
end
function module:GetItemInfo(frame,bag,slot)
	if type(bag)=="number" and type(slot)=="number" then
		return GetContainerItemInfo(bag,slot)
	end
end
function module:Display(baggins,bagframe,button,bag,slot)
	self:HookFrame(button,true)
	self:ItemUpdate(button,bag,slot)
end
