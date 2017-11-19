local me,ns=...
local addon=ns.addon
local module=ns.module
local _G=_G
local ArkInventory
--@debug@
if LibDebug then LibDebug() end
--@end-debug@
function module:OnInitialized()
	ArkInventory=LibStub("AceAddon-3.0"):GetAddon("ArkInventory",true)
end
function module:OnEnable()
	self:SecureHook(ArkInventory,"SetItemButtonTexture","Display")
	self:SecureHook(ArkInventory,"Frame_Item_Update_Fade","SearchShadow")
end
function module:CustomLayer(layer,parent)
    addon.HookScript(module,parent,"OnShow","RefreshItem")
end
function module:Display(frame)
	local i=ArkInventory.Frame_Item_GetDB(frame)
	if i and i.h then
		local rc,message=pcall(self.DrawItem,self,frame,i.q,i.h)
--@debug@
		if not rc then
			print(message,i)
		end
--@end-debug@
	else
		self:DrawItem(frame)
	end
end
function module:SearchShadow(frame)
  if frame.searchOverlay and frame.searchOverlay.IsVisible then
    self:ShadowItem(frame,frame.searchOverlay:IsVisible())
  end
end 
