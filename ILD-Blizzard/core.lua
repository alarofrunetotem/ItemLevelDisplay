local me,ns=...
local addon=ns.addon
local module=ns.module
function module:OnEnabled()
	self:SecureHook("BankFrameItemButton_Update","Display")
	self:SecureHook("ContainerFrameItemButton_UpdateItemUpgradeIcon","Display")

end
function module:Display(button,...)
	local quality,itemlink,class=self:GetInfo(nil,button:GetParent():GetID(),button:GetID())
	return self:DrawItem(button,quality,itemlink,class)
end
