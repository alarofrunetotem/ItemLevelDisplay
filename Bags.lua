local me,ns=...
local _G=_G
local setmetatable=setmetatable
local next=next
local pairs=pairs
local wipe=wipe
local GetChatFrame=GetChatFrame
local format=format
local GetTime=GetTime
local strjoin=strjoin
local strspilit=strsplit
local tostringall=tostringall
local tostring=tostring
local tonumber=tonumber
local type=type
local LoadAddOn=LoadAddOn
local pp=print
--@debug@
LoadAddOn("Blizzard_DebugTools")
LoadAddOn("LibDebug")
if LibDebug then LibDebug() ns.print=print else ns.print=function() end end
--@end-debug@
--[===[@non-debug@
ns.print=function() end
--@end-non-debug@]===]
--local print=ns.print or print
LoadAddOn("ItemLevelDisplay")
local addon=LibStub("LibInit"):GetAddon("ItemLevelDisplay")
local module=LibStub("AceAddon-3.0"):NewAddon(ns,me,'AceConsole-3.0','AceHook-3.0','AceEvent-3.0','AceTimer-3.0') --#Module
local I=LibStub("LibItemUpgradeInfo-1.0")
local GetItemInfo=I:GetCachingGetItemInfo()
--local module=addon:NewSubModule(me,"AceHook-3.0","AceEvent-3.0") --#module
local toc=select(4,GetBuildInfo())
local C=addon:GetColorTable()
local L=addon:GetLocale()
local hookedFrames={}
local priorityFrames={}
local triggerFrames={}
local frameLayers=setmetatable({},
{
	__index=function(t,frame)
		local f=addon:addLayer(frame,frame:GetName(),true)
		t[frame]=f
		return f
	end
})
function module:OnInitialize()
	self:Print("Loaded",me)
	self:SetEnabledState(addon:GetBoolean('BAGS'))
	return self:OnInitialized()
end
function module:OnInitialized()
end
function module:GetInfo(frame,bag,slot)
	if frame then
		bag,slot=frame:GetParent():GetID(), frame:GetID()
	end
	local q,_,_,h=select(4,GetContainerItemInfo(bag,slot))
	local c=h and GetItemInfo(h,12) or nil
	return q,h,c

end
function module:GetItemInfo(itemlink,index)
	return GetItemInfo(itemlink,index)
end
function module:OnEnable()
	if not addon:GetBoolean("BAGS") then return end
	if (not addon.db.global.silent) then self:Print(VIDEO_OPTIONS_ENABLED) end
	self:OnEnabled()
end
function module:OnDisable()
	if (not addon.db.global.silent) then self:Print(VIDEO_OPTIONS_DISABLED) end
	self:BagHide()
	self:UnhookAll()
	self:UnregisterAllEvents()
end
function module:OnEnabled()
	self:Print("Placeholder")
end
function module:BagShow()
	for frame,data in pairs(frameLayers) do
		self:DrawItem(frame,data.quality,data.itemlink,data.class,true)
	end
end
function module:BagHide()
	for _,data in pairs(frameLayers) do
		data.ilevel:Hide()
		data.itemlink="new"
	end
end
function module:DrawItem(frame,quality,itemlink,class)
	--pp("DrawItem",quality,itemlink,class)
	if not frame:IsVisible() then return end
	local layer=frameLayers[frame]
	local t=layer.ilevel
	if not addon:IsClassEnabled(class) then t:Hide() return end -- Class check. Empty slots also have class invalid
	if layer.itemlink==itemlink then return end -- Already drawn
	layer.itemlink=itemlink -- cache update
	layer.quality=quality
	layer.class=class
	--local font="NumberFont_OutlineThick_Mono_Small"
	--local font="NumberFontNormalYellow"
	--local font="NumberFont_Outline_Large"
	--local font="NumberFont_Outline_Huge"
	local ilevel=I:GetUpgradedItemLevel(itemlink)
	t:SetFormattedText("%3d",ilevel)
	t:SetTextColor(addon:getColors(quality,ilevel))
	t:Show()
end
ns.addon=addon
ns.module=module
