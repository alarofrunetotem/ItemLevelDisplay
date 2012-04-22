local __FILE__=tostring(debugstack(1,2,0):match("(.*):1:")) -- MUST BE LINE 1
local _,_,_,toc=GetBuildInfo()
local pp=print
local me, ns = ...
--@debug@
print("Loading",__FILE__," inside ",me)
--@end-debug@
if (LibDebug) then LibDebug() end
local function debug(...) 
--@debug@
print(...)
--@end-debug@
end
local print=_G.print
local notify=_G.print
local error=_G.error
local function dump() end
local function debugEnable() end
if (LibStub("AlarLoader-3.0",true)) then
	local rc=LibStub("AlarLoader-3.0"):GetPrintFunctions(me)
	print=rc.print
	--@debug@
	debug=rc.debug
	dump=rc.dump
	--@end-debug@
	notify=rc.notify
	error=rc.error
	debugEnable=rc.debugEnable
else
	debug("Missing AlarLoader-3.0")
end
debugEnable(false)
local L=LibStub("AceLocale-3.0"):GetLocale(me,true)
--------------------------------------
local _G=_G
local GetItemStats=GetItemStats
local GetInventorySlotInfo=GetInventorySlotInfo
local addon=LibStub("AlarLoader-3.0"):CreateAddon(me,true)
_G.ILD=addon
local L=LibStub("AceLocale-3.0"):GetLocale(me,true)
local C=LibStub("AlarCrayon-3.0"):GetColorTable()
--------------------------------------
local range=8
local markdirty
local blue={0, 0.6, 1}
local red={1, 0.4, 0.4}
local yellow={1, 1, 0}
local prismatic={1, 1, 1}
local green={0,1,0}
local dirty=true
local eventframe=nil
local slotsList={
HeadSlot={E=true},
NeckSlot={E=false},
ShoulderSlot={E=true},
BackSlot={E=true},
ChestSlot={E=true},
ShirtSlot=false,
TabardSlot=false,
WristSlot={E=true},
HandsSlot={E=true},
WaistSlot={E=false,S=true},
LegsSlot={E=true},
FeetSlot={E=true},
Finger0Slot={E=false},
Finger1Slot={E=false},
Trinket0Slot={E=false},
Trinket1Slot={E=false},
MainHandSlot={E=false},
SecondaryHandSlot={E=true},
RangedSlot={E=true,S=true}
}
local stats={}
local sockets={}
local slots=false
local tmp={}
function addon:getNumSocket(itemlink)
	if (not sockets[itemlink]) then
		local s=0
		tmp=GetItemStats(itemlink,tmp)
		if (type(tmp)=="table") then
			for k,v in pairs(tmp) do
				if (k:find("EMPTY_SOCKET_",1,true)) then
					s=s+v
				end
			end
			table.wipe(tmp)
		else
			tmp={}
		end
		sockets[itemlink]=s
	end
	return sockets[itemlink]
end		
function addon:getNumGems(...)
	local s=0
	for v in pairs({...}) do
		if v then s=s+1 end
	end
	return s
end

function addon:colorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end
	local num = select('#', ...) / 3
	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)
	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end
function addon:addLayer(f,id)
	local font="NumberFont_Outline_Med"
	--local font="NumberFont_OutlineThick_Mono_Small"
	--local font="NumberFontNormalYellow"         
	--local font="NumberFont_Outline_Large"
	--local font="NumberFont_Outline_Huge"
	t=f:CreateFontString(me.."ilevel"..id, "OVERLAY", font)      
	t:SetHeight(15)
	t:SetWidth(45)
	t:SetPoint("BOTTOMRIGHT")
	t:SetJustifyH("RIGHT")
	font="NumberFont_OutlineThick_Mono_Small"
	local e=f:CreateFontString(me .."enc"..id,"OVERLAY",font)
	e:SetHeight(15)
	e:SetWidth(30)
	e:SetPoint("TOPLEFT")
	e:SetJustifyH("LEFT")
	e:SetText("")
	e:SetTextColor(1,0,0)
	local g=f:CreateFontString(me..'gem'..id,"OVERLAY",font)
	g:SetHeight(15)
	g:SetWidth(30)
	g:SetPoint("TOPRIGHT")
	g:SetTextColor(1,0,0)
	g:SetJustifyH("RIGHT")
	return {ilevel=t,gem=g,enc=e}
end
function addon:loadSlots(...)
	slots={}
   	for i=1,select('#',...) do
   		local frame=select(i,...) -- Got SlotFrame 
   		local slotname=frame:GetName():gsub('Character','')
   		if (slotsList[slotname]) then
			local slotId=GetInventorySlotInfo(slotname)
			if (slotId) then
				slots[slotId]={
					frame=self:addLayer(frame,slotId),
					enchantable=slotsList[slotname]['E'],
					special=slotsList[slotname]['S']
				}
			end
		end
   end
end
function addon:checkLink(link)
	local data=select(3,strsplit("|",link))
    local enchant=select(3,strsplit(':',data)) or 0
    return tonumber(enchant) or 0
end
function addon:checkSpecial(ID,link)
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
	itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(link)  
	if (itemEquipLoc == "INVTYPE_RANGED") then
		return true
	else
		return false
	end
end
function addon:slotsCheck (...)
	if (not dirty) then return end
	if (not CharacterFrame:IsShown()) then return end
	if (not slots) then self:loadSlots(PaperDollItemsFrame:GetChildren()) end
	local avgmin=GetAverageItemLevel()-range -- 1 tier up are full green
	local trueAvg=0
	local equippedCount=0
	for  slotId,data in pairs(slots) do
		local t=data.frame
		local enchantable=data.enchantable
		local itemid=GetInventoryItemID("player",slotId)
		if (itemid) then
			local  name,itemlink,itemrarity,ilevel=GetItemInfo(itemid)
			local itemlink=GetInventoryItemLink("player",slotId)
			if enchantable and data.special then
				enchantable=self:checkSpecial(slotId,itemlink)
			end
			ilevel=ilevel or 1
			t.ilevel:SetFormattedText("%3d",ilevel)
			local g	=(ilevel-avgmin)/(range*2)
			equippedCount=equippedCount+1
			trueAvg=trueAvg+ilevel
			if (self:GetToggle("COLORIZE")) then
				if (self:GetToggle("REVERSE")) then
					t.ilevel:SetTextColor(self:colorGradient(g,0,1,0,1,1,0,1,0,0))
				else
					t.ilevel:SetTextColor(self:colorGradient(g,1,0,0,1,1,0,0,1,0))
				end
			end
			if (enchantable and self:GetToggle("SHOWENCHANT") and self:checkLink(itemlink) <1) then
				t.enc:SetText("E") 
			else 
				t.enc:SetText("") 
			end
			local sockets=self:getNumSocket(itemlink)
			local gems=self:getNumGems(GetInventoryItemGems(slotId))
			if (sockets > gems and self:GetToggle("SHOWSOCKETS")) then
				t.gem:SetFormattedText("%d",sockets-gems)
			else
				t.gem:SetText("")
			end
		else
			t.gem:SetText("") 
			t.enc:SetText("") 
			t.ilevel:SetText('')
		end
	end
end
function addon:markDirty()
	dirty=true
	self:slotsCheck()
end

function addon:OnInitialized()
	self:RegisterEvent("UNIT_INVENTORY_CHANGED","markDirty")
	self:RegisterEvent("PLAYER_LOGIN","markDirty")
	CharacterFrame:HookScript("OnShow",function(...) self.slotsCheck(self,...) end)
	self:AddToggle('SHOWENCHANT',true,L['Shows missing enchants'])    
	self:AddToggle('SHOWSOCKETS',true,L['Shows number of empty socket'])    
	self:AddToggle('COLORIZE',true,L['Colors item level relative to average itemlevel'])    
	self:AddToggle('REVERSE',false,L['Invert color scale (best items are red)'])    
	self:loadHelp()
end
function addon:loadHelp()
self:RelNotes(1,0,1,[[
Fixed: Waist slot was ignored
]])
self:RelNotes(1,0,0,[[
Initial release
]])
self:HF_Title("Quick Item Level Display","Description")
self:HF_Paragraph("Description")
self:HF_Pre([[
ItemLevelDisplay adds a tiny layer on each equipment slot in your paperdoll frame showing:

    ItemLevel
    Socket Status
    Enchant Status
    
(internal)
]])
end
