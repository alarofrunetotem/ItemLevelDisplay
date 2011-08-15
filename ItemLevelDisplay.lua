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
print("ItemLevelDisplay Version 0.9")
local range=8
local markdirty
local blue={0, 0.6, 1}
local red={1, 0.4, 0.4}
local yellow={1, 1, 0}
local prismatic={1, 1, 1}
local green={0,1,0}
local dirty=true
local slotsList={
HeadSlot={E=true,F=nil},
NeckSlot={E=false,F=nil},
ShoulderSlot={E=true,F=nil},
BackSlot={E=true,F=nil},
ChestSlot={E=true,F=nil},
ShirtSlot=false,
TabardSlot=false,
WristSlot={E=true,F=nil},
HandsSlot={E=true,F=nil},
WaistSlot=false,
LegsSlot={E=true,F=nil},
FeetSlot={E=true,F=nil},
Finger0Slot={E=false,F=nil},
Finger1Slot={E=false,F=nil},
Trinket0Slot={E=false,F=nil},
Trinket1Slot={E=false,F=nil},
MainHandSlot={E=false,F=nil},
SecondaryHandSlot={E=true,F=nil},
RangedSlot={E=true,F=nil}
}
local stats={}
local sockets={}
local slots=false
local tmp={}
local function getNumSocket(itemlink)
	if (not sockets[itemlink]) then
		local s=0
		table.wipe(tmp)
		tmp=GetItemStats(itemlink,tmp)
		for k,v in pairs(tmp) do
			if (k:find("EMPTY_SOCKET_",1,true)) then
				s=s+v
			end
		end
		sockets[itemlink]=s
	end
	return sockets[itemlink]
end		
local function getNumGems(...)
	local s=0
	for v in pairs({...}) do
		if v then s=s+1 end
	end
	return s
end

local function ColorGradient(perc, ...)
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
local function addLayer(f,id)
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
local function loadSlots(...)
	slots={}
   	for i=1,select('#',...) do
   		local frame=select(i,...) -- Got SlotFrame 
   		local slotname=frame:GetName():gsub('Character','')
   		if (slotsList[slotname]) then
			local slotId=GetInventorySlotInfo(slotname)
			if (slotId) then
				slots[slotId]={frame=addLayer(frame,slotId),enchantable=slotsList[slotname]['E']}
			end
		end
   end
end
local function checkLink(link)
	local data=select(3,strsplit("|",link))
	print("cl1",data)
    local enchant=select(3,strsplit(':',data)) or 0
	print("cl2",enchant)
    return tonumber(enchant) or 0
end
local function slotsCheck (...)
	if (not dirty) then return end
	if (not slots) then loadSlots(PaperDollItemsFrame:GetChildren()) end
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
			ilevel=ilevel or 1
			t.ilevel:SetFormattedText("%3d",ilevel)
			local g	=(ilevel-avgmin)/(range*2)
			if (slotId==1) then
				print("avgmin="..avgmin,ilevel-avgmin,range,g)
				end
			equippedCount=equippedCount+1
			trueAvg=trueAvg+ilevel
			t.ilevel:SetTextColor(ColorGradient(g,1,0,0,1,1,0,0,1,0))
			if (enchantable and checkLink(itemlink) <1) then 
				t.enc:SetText("E") 
			else 
				t.enc:SetText("") 
			end
			local sockets=getNumSocket(itemlink)
			local gems=getNumGems(GetInventoryItemGems(slotId))
			debug(name,slotId,"S",sockets,"G",gems)
			if (sockets ~= gems ) then
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
local function markdirty()
	dirty=true
	slotsCheck()
end

local XX1 -- Event Dispatcher
XX1=CreateFrame("Frame","XX1",CharacterFrame)
XX1:RegisterEvent("UNIT_INVENTORY_CHANGED")
XX1:RegisterEvent("PLAYER_LOGIN")
XX1:SetScript("OnEvent",markdirty)
CharacterFrame:HookScript("OnShow",slotsCheck)
