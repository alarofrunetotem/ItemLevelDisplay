local me,ns=...
local addon=ns.addon
local module=ns.module
if LibDebug then LibDebug() end
function module:OnEnabled()
	self:SecureHook("BaudBagItemButton_UpdateRarity","Display")
end
function module:Display(frame)
	self:DrawItem(frame,self:GetInfo(frame))
end
