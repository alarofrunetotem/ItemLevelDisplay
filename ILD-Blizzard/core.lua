local me,ns=...
local addon=ns.addon
local module=ns.module
local toc=select(4,GetBuildInfo())
function module:OnEnabled()
	self:SecureHook("BankFrameItemButton_Update","DisplayBank")
	if toc > 70000 then
		self:SecureHook("ContainerFrameItemButton_UpdateItemUpgradeIcon","Display")
	else
		self:SecureHook("ContainerFrame_Update","DisplayBag")
	end

end
function module:Display(...)
	print(...)

end
function module:DisplayBank(button,...)
	if( button.isBag ) then
		return
	end
	local quality,itemlink,class=self:GetInfo(nil,button:GetParent():GetID(),button:GetID())
	return self:DrawItem(button,quality,itemlink,class)

end
function module:DisplayBag(frame,...)
	local bagId = frame:GetID();
	local name = frame:GetName();
	for i=1,frame.size do
		local button=_G[name .. "Item" ..i]
		local quality,itemlink,class=self:GetInfo(nil,bagId,button:GetID())
		self:DrawItem(button,quality,itemlink,class)
	end
end
