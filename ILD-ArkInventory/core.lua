local me,ns=...
local addon=ns.addon
local module=ns.module
function module:OnInitialized()
	local frame=ArkInventory.Frame_Main_Get(ArkInventory.Const.Location.Bag)
	self:SetTriggerFrame(frame)
	frame=ArkInventory.Frame_Main_Get(ArkInventory.Const.Location.Bank)
	self:SetTriggerFrame(frame)
end
function module:IsItemButton(name)
	local bagFrame=("ARKINV_Frame%dScrollContainerBag"):format(ArkInventory.Const.Location.Bag)
	local bankFrame=("ARKINV_Frame%dScrollContainerBag"):format(ArkInventory.Const.Location.Bank)
	return name:find(bagFrame) or name:find(bankFrame)
end
function module:IsOfflineBag()
	return ArkInventory.Global.Location[ArkInventory.Const.Location.Bag].isOffline
end
