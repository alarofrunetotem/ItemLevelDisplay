local me,ns=...
local addon=ns.addon
local module=ns.module
function module:OnEnabled()
	self:SecureHook("LiteBagItemButton_Update", "Display")
end
function module:Display(button)
	self:DrawItem(button,self:GetInfo(button))
end
