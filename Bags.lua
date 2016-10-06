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
--@debug@
LoadAddOn("Blizzard_DebugTools")
LoadAddOn("LibDebug")
if LibDebug then LibDebug() ns.print=print else ns.print=function() end end
--@end-debug@
--[===[@non-debug@
ns.print=function() end
--@end-non-debug@]===]
--local print=ns.print or print
print("Bags loaded from",me)
LoadAddOn("ItemLevelDisplay")
local addon=LibStub("AceAddon-3.0"):GetAddon("ItemLevelDisplay")
--local module=LibStub("LibInit"):NewAddon(ns,me,{noswitch=true,profile=false,enhancedProfile=false,nogui=true,nohelp=true},'AceHook-3.0','AceEvent-3.0','AceTimer-3.0') --#Module
local module=LibStub("AceAddon-3.0"):NewAddon(ns,me,'AceConsole-3.0','AceHook-3.0','AceEvent-3.0','AceTimer-3.0') --#Module
local I=LibStub("LibItemUpgradeInfo-1.0")
--local module=addon:NewSubModule(me,"AceHook-3.0","AceEvent-3.0") --#module
local toc=select(4,GetBuildInfo())
local C=addon:GetColorTable()
local L=addon:GetLocale()
local hookedFrames={}
local triggerFrames={}
function module:OnInitialize()
	self:Print(me,"loaded")
	self:OnInitialized()
end
function module:SetTriggerFrame(frame)
	if type(frame)=="string" then
		if not _G[frame] then
		--@debug@
			print("Waiting to set trigger for",frame)
		--@end-debug@
			self:ScheduleTimer("SetTriggerFrame",1,frame)
			return
		else
			frame=_G[frame]
		end
	end
--@debug@
	if not frame then
		print("Passed a nil frame")
		return
	end
	print("Trigger set for",frame:GetName())
--@end-debug@
	if not self:IsHooked(frame,"OnShow") then
		triggerFrames[frame]=true
		self:SecureHookScript(frame,"OnShow","FirstBagDisplay")
	end
end
local bagManagers={} --#_bags
function bagManagers:baggins()
	canDisplayLevel=function()
		return true
	end
	findItemButtons=function()
		self:scanForBagItemButtons('BagginsPooledItemButton')
		self:scanForBagItemButtons('ContainerFrame%dItem')
	end
	self:SetTriggerFrame("BagginsBag1")
end
function module:IsItemButton(name,frame)
	return name:find("ContainerFrame%dItem")
end
function module:IsOfflineBag()
	return false
end
-- Placeholder
function module:ReHook(this)
end
function module:FirstBagDisplay(this)
	for frame,_ in pairs(triggerFrames) do
		self:Unhook(frame,"OnShow")
	end
	self:ReHook(this)
--	print("BagOpen",this:GetName(),this.isOffLine)
	self:RegisterEvent("BAG_UPDATE_DELAYED")
	return self:ScanForBagItemButtons(this)
end
function module:FirstBankDisplay(this)
	self:UnregisterEvent("BANKFRAME_OPENED")
	return self:ScanForBagItemButtons(this)
end
function module:GetItemInfo(frame)
	local bag,slot=frame:GetParent():GetID(), frame:GetID()
	return GetContainerItemInfo(bag,slot)
end
function module:HookFrame(hookedFrames,frame)
	if not hookedFrames[frame] then
		local rc,message=pcall(self.SecureHookScript,self,frame,"OnShow","OnBagItemShow")
--@debug@
		if not rc then
			print(name.." : "..message)
		end
--@end-debug@
		hookedFrames[frame]=addon:addLayer(frame,frame:GetName(),true)
	end
end
function module:ScanForBagItemButtons(main)
	local frame = EnumerateFrames()
	local elapsed=GetTime()
	local batch,batchSize=0,500
	local s=0
	local first=true
	while frame do
		local name=frame:GetName()
		s=s+1
		batch=batch+1
		if frame:GetObjectType()=="Button" and name then
			if  -- Using this set of feature as a signature for itemcontainer derived frames
				self:IsItemButton(name) then
--@debug@
--				print("Verifying",name,frame)
--@end-debug@
				if  _G[name .."Cooldown"]
				and  _G[name .."IconQuestTexture"]
				and frame.newitemglowAnim
				and frame.flashAnim
				and frame.JunkIcon
				and frame.flash
				and frame.NewItemTexture
				and frame.BattlepayItemTexture
				then
					if self:HookFrame(hookedFrames,frame) then break end -- Allow an early exit
				end
			end
		end
		if coroutine.running() and batch > batchSize then batch=0 coroutine.yield(true) end
		frame = EnumerateFrames(frame)
	end
	self:ScheduleTimer("BagRefresh",0.2)
--@debug@
	local i=0
	for _,_ in pairs(hookedFrames) do i=i+1 end
	print(("BagScan End in %f %d/%d"):format(GetTime()-elapsed,i,s))
--@end-debug@

end
function module:BagRefresh()
	if self:IsOfflineBag() then
		for _,data in pairs(hookedFrames) do data.ilevel:Hide() end
	else
		for frame,_ in pairs(hookedFrames) do
			if frame:IsVisible() then
				if self:OnBagItemShow(frame) then
					if coroutine.running() then coroutine.yield() end
				end
			end
		end
	end
end
function module:BAG_UPDATE_DELAYED()
	self:BagRefresh()
end

function module:OnBagItemShow(this,...)
	--@debug@
	--print("OnSHow",this:GetName(),this:GetInfo())
	--@end-debug@
	if not this:IsVisible() then return end
	if not hookedFrames[this] then return end
	local t=hookedFrames[this].ilevel
	if self:IsOfflineBag() then t:Hide() end
	local quality,_,_,itemlink=select(4,self:GetItemInfo(this))
	if quality then
		if itemlink then
			if hookedFrames[this].itemlink==itemlink then return end
			hookedFrames[this].itemlink=itemlink
			--local font="NumberFont_OutlineThick_Mono_Small"
			--local font="NumberFontNormalYellow"
			--local font="NumberFont_Outline_Large"
			--local font="NumberFont_Outline_Huge"
			local ilevel=I:GetUpgradedItemLevel(itemlink)
			t:SetFormattedText("%3d",ilevel)
			t:SetTextColor(addon:getColors(quality,ilevel))
			t:Show()
			return true
		else
			if hookedFrames[this].itemlink=='empty' then return end
			hookedFrames[this].itemlink='empty'
			t:Hide()
			return true
		end
	end
	t:Hide()
end
ns.addon=addon
ns.module=module
