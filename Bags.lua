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
local select=select
local font
local corner
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
local LSM=LibStub("LibSharedMedia-3.0")
local GetItemInfo=I:GetCachingGetItemInfo()
--local module=addon:NewSubModule(me,"AceHook-3.0","AceEvent-3.0") --#module
local toc=select(4,GetBuildInfo())
local C=addon:GetColorTable()
local L=addon:GetLocale()
local fontObject={}
function fontObject:SetFont(a,b,c)
	self.a=a
	self.b=b
	self.c=c
end
function fontObject:GetFont(a,b,c)
	return self.a,self.b,self.c
end
fontObject:SetFont(Game11Font:GetFont())
local frameLayers=setmetatable({},
{
	__index=function(t,parent)
		local layer=addon:addLayer(parent,parent:GetName(),true,fontObject)
	  module:CustomLayer(layer,parent)
		t[parent]=layer
		return layer
	end,
	__mode="k"
})
function module:CustomLayer(layer,parent)
end
function module:OnInitialize()
	self:Print("Loaded",me)
	self:SetEnabledState(addon:GetBoolean('BAGS'))
	corner = addon:GetVar("BAGSCORNER")
	local a,b,c=fontObject:GetFont()
	a=LSM:Fetch("font",addon:GetVar("BAGSFONT"))
	b=addon:GetNumber("BAGSFONTSIZE")
	c=addon:GetString("BAGSFONTOUTLINE")
	fontObject:SetFont(a,b,c)
	self:RegisterMessage("ILD_APPLY")
	return self:OnInitialized()
end
function module:ILD_APPLY(event,key,value)
	if key=="CORNER" then
		corner=value
		self:RefreshCorners(value)
	elseif key=="FONT" or key=="FONTSIZE" or key=="FONTOUTLINE" then
		local a,b,c=fontObject:GetFont()
		if key=="FONT" then
			a=LSM:Fetch("font",value)
		elseif key=="FONTSIZE" then
			b=value
		else
			c=value
		end
		fontObject:SetFont(a,b,c)
		self:RefreshFonts()
	end
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
function module:RefreshFonts()
	for frame,data in pairs(frameLayers) do
		local t=data.ilevel
		t:SetFont(fontObject:GetFont())
	end
end
function module:RefreshCorners(value)
	for frame,data in pairs(frameLayers) do
		addon:placeLayer(frame,value)
	end
end
function module:BagHide()
	for _,data in pairs(frameLayers) do
		data.ilevel:Hide()
		data.itemlink="new"
	end
end
function module:ShadowItem(frame,grey)
  local layer=frameLayers[frame]
  if layer then layer:SetAlpha(grey and 0.4 or 1) end
end
function module:RefreshItem(layer)
  if not layer then return end
  local t=layer.ilevel
  local itemlink=layer.itemlink
  if not itemlink then layer:Hide() end
  local class=layer.class
  local quality=layer.quality
  if itemlink and not class then
    class=GetItemInfo(itemlink,12)
  end
  addon:Print("RefreshItem",layer:GetName(),layer.itemlink,class)
  if not addon:IsClassEnabled(class) then layer:Hide() return end -- Class check. Empty slots also have class invalid
  local ilevel=I:GetUpgradedItemLevel(itemlink)
  if ilevel < addon:GetNumber("BAGSLEVELS") then t:Hide() return end
  addon:placeLayer(layer,addon:GetVar("BAGSCORNER"))
  t:SetFormattedText("%3d",ilevel)
  t:SetTextColor(addon:getColors(quality,ilevel))
  t:SetFont(fontObject:GetFont())
  layer:Show()
end
function module:DrawItem(frame,quality,itemlink,class)
  local layer=frameLayers[frame]
  if frame.searchOverlay and frame.searchOverlay.IsVisible then
    self:ShadowItem(frame,frame.searchOverlay:IsVisible())
  end 
  layer.itemlink=itemlink -- cache update
  layer.quality=quality
  layer.class=class
  return layer
end
ns.addon=addon
ns.module=module
