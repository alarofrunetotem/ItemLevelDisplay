local me,ns=...
local addon=ns.addon
local module=ns.module
local _G=_G
local ArkInventory
if LibDebug then LibDebug() end
function module:OnInitialized()
	ArkInventory=LibStub("AceAddon-3.0"):GetAddon("ArkInventory",true)
end
function module:OnEnable()
	self:SecureHook(ArkInventory,"SetItemButtonTexture","Display")
end
function module:Display(frame)
	local i=ArkInventory.Frame_Item_GetDB(frame)
	if i and i.h then
		local rc,message=pcall(self.DrawItem,self,frame,i.q,i.h,4)
		if not rc then
			print(message)
			DevTools_Dump(i)
		end
	else
		self:DrawItem(frame)
	end
end
