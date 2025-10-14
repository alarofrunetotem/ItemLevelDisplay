local me,ns=...
local addon=ns.addon
local module=ns.module
function module:OnEnabled()
	if ns.CLASSIC then
		self:SecureHook("BankFrameItemButton_Update","Display")
		self:SecureHook("ContainerFrameItemButton_UpdateItemUpgradeIcon","Display")
	else
		self:SecureHook("SetItemButtonQuality","Display2")
	end

end
function module:Display(button,...)
	local quality,itemlink,class=self:GetInfo(nil,button:GetParent():GetID(),button:GetID())
	return self:DrawItem(button,quality,itemlink,class)
end
function module:Display2(button, quality, itemLink, doNotSuppressOverlays, isBound)
	--if not itemLink then return end
	if (button:GetName()) then return end
	return self:DrawItem(button,quality,itemLink)
end
