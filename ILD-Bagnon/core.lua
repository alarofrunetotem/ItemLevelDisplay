local me,ns=...
local addon=ns.addon
local module=ns.module
local pp=print
if LibDebug then LibDebug() end
local Bagnon
function module:OnInitialized()
	Bagnon=LibStub("AceAddon-3.0"):GetAddon("Bagnon",true)
end
function module:OnEnabled()
	self:SecureHook(Bagnon.ItemFrame.Button,"Update","Display")
end
function module:Display(frame,...)
	local _,_,_,quality,_,_,itemlink,class=frame:GetInfo()
	if itemlink then
		class =self:GetItemInfo(itemlink,12)
	end
	return self:DrawItem(frame,quality,itemlink,class)
end
