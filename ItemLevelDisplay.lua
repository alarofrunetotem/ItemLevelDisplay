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
--@debug@
local wininfo
--@end-debug@
local _G=_G
local type=type
local pairs=pairs
local GetItemStats=GetItemStats
local GetInventorySlotInfo=GetInventorySlotInfo
local addon=LibStub("AlarLoader-3.0"):CreateAddon(me,true)
_G.ILD=addon
local L=LibStub("AceLocale-3.0"):GetLocale(me,true)
local C=LibStub("AlarCrayon-3.0"):GetColorTable()
--------------------------------------
local addonName="ILD"
local range=8
local markdirty
local blue={0, 0.6, 1}
local red={1, 0.4, 0.4}
local yellow={1, 1, 0}
local prismatic={1, 1, 1}
local green={0,1,0}
local dirty=true
local eventframe=nil
local redGems, blueGems, yellowGems, prismaticGems = 0, 0, 0, 0
local gems={}
local textures={
 blue = "Interface\\Icons\\inv_misc_cutgemsuperior2",
 red =  "Interface\\Icons\\inv_misc_cutgemsuperior6",
 yellow =  "Interface\\Icons\\inv_misc_cutgemsuperior",
 prismatic = "Interface\\Icons\\INV_Jewelcrafting_DragonsEye02"
}
local gemcolors={
	blue=blue,
	red=red,
	yellow=yellow,
	prismatic=prismatic
}

local slotsList={
HeadSlot={E=false},
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
local gframe=false
local gred=false
local gblue=false
local gyellow=false
local prismatic=false
local tmp={}
local Red_localized = 52255
local Blue_localized = 52235
local Yellow_localized = 52267
local Green_localized = 52245
local Purple_localized = 52213
local Orange_localized = 52222
local Meta_localized = 52296
--http://www.wowinterface.com/forums/showthread.php?t=45388
  local levelAdjust={ -- 11th item:id field and level adjustment
  ["0"]=0,["1"]=8,["373"]=4,["374"]=8,["375"]=4,["376"]=4,
  ["377"]=4,["379"]=4,["380"]=4,["445"]=0,["446"]=4,["447"]=8,
  ["451"]=0,["452"]=8,["453"]=0,["454"]=4,["455"]=8,["456"]=0,
  ["457"]=8,["458"]=0,["459"]=4,["460"]=8,["461"]=12,["462"]=16}

function addon:getSockets(itemlink)
	if (not sockets[itemlink]) then
		local s=0
		local r=0
		local b=0
		local y=0
		local p=0
		--debug (itemlink)
		local tmp=GetItemStats(itemlink,tmp)
		if (type(tmp)=="table") then
			for k,v in pairs(tmp) do
				--debug(k,v)
				if (k=="EMPTY_SOCKET_RED") then
					r=r+v
				elseif (k=="EMPTY_SOCKET_BLUE") then
					b=b+v
				elseif (k=="EMPTY_SOCKET_YELLOW") then
					y=y+v
				elseif (k=="EMPTY_SOCKET_META") then
					p=p+v
				end
			end
			table.wipe(tmp)
		else
			tmp={}
		end
		s=r+b+y+p
		sockets[itemlink]={s=s,r=r,y=y,b=b,p=p}
		--debug(s,r,y,b,p)
	end
	return sockets[itemlink]
end		
function addon:getNumGems(...)
	local s=0
	--debug("GEMS",...)
	for v,i in pairs({...}) do
		if v then
		 	--debug("GEM",v,GetItemInfo(i))
			s=s+1 
		end
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
	local t=f:CreateFontString(me.."ilevel"..id, "OVERLAY", font)
	t:SetText()      
	font="NumberFont_OutlineThick_Mono_Small"
	local e=f:CreateFontString(me .."enc"..id,"OVERLAY",font)
	e:SetText("")
	local g=f:CreateFontString(me..'gem'..id,"OVERLAY",font)
	g:SetText("")
	self:placeLayer(t,e,g)
	return {ilevel=t,gem=g,enc=e}
end	

local function corner2points(corner)
	local positions={
		b="BOTTOM",
		t="TOP",
		r="RIGHT",
		l="LEFT"
	}
	--debug(corner,corner:sub(1,1),corner:sub(2,2))
	return positions[corner:sub(1,1)],positions[corner:sub(2,2)]
end

function addon:placeLayer(t,e,g)
	t:ClearAllPoints()
	e:ClearAllPoints()
	g:ClearAllPoints()
	t:SetHeight(15)
	t:SetWidth(45)
	local v,h=corner2points(self:GetVar("CORNER"))
	local additional="BOTTOM"
	if (v=="BOTTOM") then
	  additional="TOP"
	end
	t:SetPoint(v..h)
	t:SetJustifyH(h)
	e:SetHeight(15)
	e:SetWidth(30)
	e:SetPoint(additional .."LEFT")
	e:SetJustifyH("LEFT")
	e:SetTextColor(1,0,0)

	g:SetHeight(15)
	g:SetWidth(30)
	g:SetPoint(additional .. "RIGHT")
	g:SetTextColor(1,0,0)
	g:SetJustifyH("RIGHT")
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
    local upgrade=select(12,strsplit(':',data)) or 0
    return tonumber(enchant) or 0,upgrade or "0"
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
function addon:ApplySHOWGEMS(value)
if (not gframe) then return end
	if (value) then
		gframe:Show()
	else
		gframe:Hide()
	end
end
function addon:ApplyCORNER(value)
	if (not slots) then return end 
	for  slotId,data in pairs(slots) do
		self:placeLayer(data.frame.ilevel,data.frame.enc,data.frame.gem)
	end
end
function addon:ApplyGEMCORNER(value)
	self:placeGemLayer()
end
function addon:getGemColors(gem)
local empty={r=0,p=0,b=0,y=0}
	if (not gem) then return empty end
	if (false or not gems[gem]) then
		local r,b,y,p=0,0,0,0
	    local testGem = (select(7, GetItemInfo(gem)))
	    if testGem == Red_localized then
	    	r=1
	    elseif testGem == Blue_localized then
	    	b=1
	    elseif testGem == Yellow_localized then
	    	y=1
	    elseif testGem == Green_localized then
	    	b=1
	    	y=1
	    elseif testGem == Purple_localized then
	    	r=1
	    	b=1
	    elseif testGem == Orange_localized then
	    	r=1
	    	y=1
	    elseif testGem == Meta_localized then
	    	p=0
	    else
	    	p=1
	    end
	    gems[gem]={r=r,b=b,y=y,p=p}
	    debug(testGem,r,b,y,p)
    end
    return gems[gem]
end
function addon:slotsCheck (...)
	if (not dirty) then return end
	if (not CharacterFrame:IsShown()) then return end
	if (not slots) then self:loadSlots(PaperDollItemsFrame:GetChildren()) end
	local avgmin=GetAverageItemLevel()-range -- 1 tier up are full green
	local trueAvg=0
	local equippedCount=0
	local r,y,b,p=0,0,0,0
	local tr,ty,tb,tp=0,0,0,0
	for  slotId,data in pairs(slots) do
		local t=data.frame
		local enchantable=data.enchantable
		local itemid=GetInventoryItemID("player",slotId)
		if (itemid) then
			local  name,itemlink,itemrarity,ilevel=GetItemInfo(itemid)
			local itemlink=GetInventoryItemLink("player",slotId)
			local enchval,upval=self:checkLink(itemlink)
			
			if enchantable and data.special then
				enchantable=self:checkSpecial(slotId,itemlink)
			end
			ilevel=ilevel or 1
			local upvalue=levelAdjust[upval] or 0
			t.ilevel:SetFormattedText("%3d",ilevel+upvalue)
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
			if (enchantable and self:GetToggle("SHOWENCHANT") and  enchval<1) then
				t.enc:SetText("E") 
			else 
				t.enc:SetText("") 
			end
			local sockets=self:getSockets(itemlink)
			local gem1,gem2,gem3,gem4=GetInventoryItemGems(slotId)
			local gems=self:getNumGems(gem1,gem2,gem3,gem4)
			if (self:GetToggle("SHOWGEMS")) then
				local gg=self:getGemColors(gem1)
				r=r+gg.r
				b=b+gg.b
				y=y+gg.y
				p=p+gg.p
				gg=self:getGemColors(gem2)
				r=r+gg.r
				b=b+gg.b
				y=y+gg.y
				p=p+gg.p
				gg=self:getGemColors(gem3)
				r=r+gg.r
				b=b+gg.b
				y=y+gg.y
				p=p+gg.p
				gg=self:getGemColors(gem4)
				r=r+gg.r
				b=b+gg.b
				y=y+gg.y
				p=p+gg.p
			end
			if (sockets.s > gems and self:GetToggle("SHOWSOCKETS")) then
				t.gem:SetFormattedText("%d",(sockets.s)-gems)
			else
				t.gem:SetText("")
			end
			tr=tr+sockets.r
			tb=tb+sockets.b
			ty=ty+sockets.y
			tp=tp+sockets.p
		else
			t.gem:SetText("") 
			t.enc:SetText("") 
			t.ilevel:SetText('')
		end

	end
	if (self:GetToggle("SHOWGEMS")) then
		self["buttonprismatic"].text:SetFormattedText("%d/%d",p,tp)
		self["buttonred"].text:SetFormattedText("%d/%d",r,tr)
		self["buttonblue"].text:SetFormattedText("%d/%d",b,tb)
		self["buttonyellow"].text:SetFormattedText("%d/%d",y,ty)
		gframe:Show()
	else
		gframe:Hide()
	end
end
function addon:markDirty()
	dirty=true
	self:slotsCheck()
end
function addon:loadGemLocalizedStrings()
	Red_localized = select(7, GetItemInfo(Red_localized))
	Blue_localized = select(7, GetItemInfo(Blue_localized))
	Yellow_localized = select(7, GetItemInfo(Yellow_localized))
	Green_localized = select(7, GetItemInfo(Green_localized))
	Purple_localized = select(7, GetItemInfo(Purple_localized))
	Orange_localized = select(7, GetItemInfo(Orange_localized))
	Meta_localized = select(7,GetItemInfo(Meta_localized))
	self:addGemLayer()
end

function addon:OnInitialized()
	self:RegisterEvent("UNIT_INVENTORY_CHANGED","markDirty")
	self:RegisterEvent("PLAYER_LOGIN","loadGemLocalizedStrings")
	CharacterFrame:HookScript("OnShow",function(...) self.slotsCheck(self,...) end)
	self:AddToggle('SHOWENCHANT',true,L['Shows missing enchants'])    
	self:AddToggle('SHOWSOCKETS',true,L['Shows number of empty socket'])    
	self:AddToggle('SHOWGEMS',true,L['Shows total number of gems'])    
	self:AddToggle('COLORIZE',true,L['Colors item level relative to average itemlevel'])    
	self:AddToggle('REVERSE',false,L['Invert color scale (best items are red)'])
	self:AddSelect('CORNER',"br",
		{br=L['Bottom Right'],
		tr=L['Top Right'],
		tl=L['Top Left'],
		bl=L['Bottom Left']
		},L['Position'],L['Level text aligned to'])
	self:AddSelect('GEMCORNER',"br",
		{br=L['Bottom Right'],
		tr=L['Top Right'],
		tl=L['Top Left'],
		bl=L['Bottom Left']
		},L['Position'],L['Gem frame position'])
    self:AddOpenCmd('showinfo',"cmdInfo",L["Debug info"],L["Show raw item info.Please post the screenshot to Curse Forum"])
	self:loadHelp()
end
function addon:addGemLayer()
	gframe=CreateFrame("frame",addonName .. "main",CharacterFrame)
	gframe:SetHeight(75)
	gframe:SetWidth(100)
	local x=0
	for i,k in pairs(textures) do
		self["button"..i] = PaperDollItemsFrame:CreateTexture(addonName.."button"..i, "OVERLAY")
		local frame = self["button"..i]
		frame:SetHeight(15)
		frame:SetWidth(15)
		frame.text = PaperDollItemsFrame:CreateFontString(addonName.."text"..i, "OVERLAY", "NumberFontNormal")
		frame.text:SetParent(gframe)
		frame.text:SetPoint("LEFT", frame, "RIGHT", 5, 0)
		frame.text:SetText("0")
		frame:SetTexture(k)
		frame.text:SetTextColor(unpack(gemcolors[i]))
		frame:SetParent(gframe)
		frame:SetPoint("TOPLEFT",0,-20*x)
		x=x+1
	end
	self:placeGemLayer()
end
function addon:placeGemLayer()
	if (not gframe) then return end 
	local first=true
	local previous
	local v,h=corner2points(self:GetVar("GEMCORNER"))
	local x,y=0,0
	local notv
	if (v=="TOP") then
		y=-55
		notv="BOTTOM"
	else
	    y=40
	    notv="TOP"
	end
	if (h=="LEFT") then
		x=55
	else
		h="LEFT"
		x=240
	end
	gframe:ClearAllPoints()
	gframe:SetPoint(v..h,CharacterFrame,v..h,x,y)
	if (true) then return end
	for i,k in pairs(textures) do
		local frame = self["button"..i]
		if (not frame) then return end
		if first then
			first=false
			frame:ClearAllPoints();
			frame:SetPoint(v..h, CharacterFrame, v..h, x, y)
		else
			frame:ClearAllPoints()
			frame:SetPoint(v, self["button"..previous],notv)
		end
		previous=i
	end
end

local wininfo
function addon:cmdInfo()
	local gui=LibStub("AceGUI-3.0")
	wininfo=gui:Create("Frame")
	wininfo:SetTitle("Please post this screenshot to curse, thanks")
	wininfo:SetStatusText("Add the expected ilevel for upgraded items")
	if (not CharacterFrame:IsShown()) then
		ToggleCharacter("PaperDollFrame")
	else
		debug("Already show")
	end
	ToggleCharacter("PaperDollFrame")
	for  slotId,data in pairs(slots) do
		local gui=LibStub("AceGUI-3.0")				
		local l=gui:Create("Label")
		local itemid=GetInventoryItemID("player",slotId)
		if (itemid) then
			local  name,itemlink,itemrarity,ilevel=GetItemInfo(itemid)
			local itemlink=GetInventoryItemLink("player",slotId)
			local data=select(3,strsplit("|",itemlink or "|||||"))
			local e,u=self:checkLink(itemlink)
			l:SetFullWidth(true)
			l:SetText(format("%s:  %s %s %s %s",
				name,
				C(ilevel,"green"),
				C(u,"yellow"),
				C(levelAdjust[u],"orange"),
				data or "<empty>"
				)
				)
				wininfo:AddChild(l)
		end
	end	
end

