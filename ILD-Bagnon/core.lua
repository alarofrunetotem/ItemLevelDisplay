local me,ns=...
local addon=ns.addon
local module=ns.module
local pp=print
if LibDebug then LibDebug() end
function module:OnInitialized()
	self:SetTriggerFrame("BagnonFrameinventory")
	--self:SetTriggerFrame("BagnonFramebank")
	local Bagnon=LibStub("AceAddon-3.0"):GetAddon("Bagnon")
end
function module:IsItemButton(name)
	return name:find("ContainerFrame%dItem")
end

function module:ReHook(this)
	local rc,message=pcall(self.SecureHookScript,self,this,"OnShow","BagRefresh")
end
_G.bagrefresh=function() module:BagRefresh() end