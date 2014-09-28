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
local L=LibStub("AceLocale-3.0"):GetLocale(me,true)
--------------------------------------
--@debug@
print("ItemLevelDisplay ALPHA version")
--@end-debug@
local _G=_G
local type=type
local pairs=pairs
local GetItemStats=GetItemStats
local GetInventorySlotInfo=GetInventorySlotInfo
local addon=LibStub("AlarLoader-3.0"):CreateAddon(me,true) --#ItemLevelDisplay
--@debug@
_G.ILD=addon
--@end-debug@
local C=LibStub("AlarCrayon-3.0"):GetColorTable()
local I=LibStub("LibItemUpgradeInfo-1.0")
--------------------------------------
local addonName="ILD"
local range=8
local markdirty
local blue={0, 0.6, 1}
local red={1, 0.4, 0.4}
local yellow={1, 1, 0}
local meta={1, 1, 1}
local green={0,1,0}
local dirty=true
local eventframe=nil
local redGems, blueGems, yellowGems, metaGems = 0, 0, 0, 0
local gems={}
local profilelabel={name=''}
local textures={
	blue = "Interface\\Icons\\inv_misc_cutgemsuperior2",
	red =  "Interface\\Icons\\inv_misc_cutgemsuperior6",
	yellow =  "Interface\\Icons\\inv_misc_cutgemsuperior",
	meta = "Interface\\Icons\\INV_Jewelcrafting_DragonsEye02"
}
local gemcolors={
	blue=blue,
	red=red,
	yellow=yellow,
	meta=meta
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
	WaistSlot={E=false},
	LegsSlot={E=true},
	FeetSlot={E=true},
	Finger0Slot={E=false},
	Finger1Slot={E=false},
	Trinket0Slot={E=false},
	Trinket1Slot={E=false},
	MainHandSlot={E=true},
	SecondaryHandSlot={E=true},
}

local stats={}
local sockets={}
local slots=false
local gframe=false
local gred=false
local gblue=false
local gyellow=false
local meta=false
local tmp={}
local Red_localized = 52255
local Blue_localized = 52235
local Yellow_localized = 52267
local Green_localized = 52245
local Purple_localized = 52213
local Orange_localized = 52222
local Meta_localized = 52296

function addon:getSockets(itemlink)
	--if (not sockets[itemlink]) then
		local s=0
		local r=0
		local b=0
		local y=0
		local p=0
		--@debug@
		debug ("ItemLink for gem",itemlink)
		--@end-debug@
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
		--@debug@
		debug("Gem List","T:",s,"R:",r,"Y:",y,"B:",b,"M:",p)
		--@end-debug@
	--end
	return sockets[itemlink]
end

function addon:getNumGems(...)
	local s=0
	--@debug@
	debug("GEMS",...)
	--@end-debug@
	for v,i in pairs({...}) do
		if v then
			--@debug@
			debug("GEM",v,GetItemInfo(i))
			--@end-debug@
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
	return tonumber(enchant) or 0,tonumber(upgrade) or 0
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
function addon:Apply()
	print("apply")
	self:markDirty()
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
			p=1
		else
			p=0
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
	if (not gframe) then self:addGemLayer() end
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
			local  name,itemlink,itemrarity,ilevel,itemMinLevel,itemType,itemSubType,itemStackCount,ItemEquipLoc=GetItemInfo(itemid)
			local itemlink=GetInventoryItemLink("player",slotId)
			local enchval,upval=self:checkLink(itemlink)

			ilevel=ilevel or 1
			local upvalue=I:GetItemLevelUpgrade(upval)
			t.ilevel:SetFormattedText("%3d",ilevel+upvalue)
			-- Apply actual color scheme
			if (self:GetVar('COLORSCHEME')=='qual') then
				for token in string.gmatch((itemrarity), "[^%s]+") do
					if tonumber(token) == 3 then
						t.ilevel:SetTextColor(0.39,0.73,1.0,1.0)
					elseif tonumber(token) == 4 then
						t.ilevel:SetTextColor(0.8,0.6,1.0,1.0)
					else
						local r, g, b, hex = GetItemQualityColor(itemrarity)
						t.ilevel:SetTextColor(r,g,b,1.0)
					end
				end
			elseif (self:GetVar("COLORSCHEME")=='plain') then
				t.ilevel:SetTextColor(1.0,1.0,1.0,1.0)
			else
				-- Only the two level based schemes are left
				local g	=(ilevel-avgmin)/(range*2)
				trueAvg=trueAvg+ilevel
				if (self:GetVar("COLORSCHEME")=='lvup') then
					t.ilevel:SetTextColor(self:colorGradient(g,0,1,0,1,1,0,1,0,0))
				else
					t.ilevel:SetTextColor(self:colorGradient(g,1,0,0,1,1,0,0,1,0))
				end
			end
			if (enchantable and self:GetToggle("SHOWENCHANT") and  enchval<1) then
				t.enc:SetText(L["E"])
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
			elseif (sockets.s==0 and ItemEquipLoc == "INVTYPE_WAIST" and self:GetToggle("SHOWBUCKLE")) then
			t.gem:SetText("B")
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
		self["buttonmeta"].text:SetFormattedText("%d/%d",p,tp)
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
	debug(Meta_localized,GetItemInfo(Meta_localized))
	Meta_localized = select(7,GetItemInfo(Meta_localized))
	debug(Meta_localized)
end
function addon:OnInitialized()
	self:RegisterEvent("PLAYER_LOGIN","loadGemLocalizedStrings")
	if (not self.db.global.hascommon) then
		local myprofile=self.db:GetCurrentProfile()
		if (myprofile~='Default') then
			self.db:SetProfile('Default')
			self.db:CopyProfile(myprofile)
			self.db:SetProfile(myprofile)
		end
		self.db.global.hascommon=true
	end
	CharacterFrame:HookScript("OnShow",function(...) self.slotsCheck(self,...) end)
	profilelabel=self:AddText(L['Current profile is: '] .. C(self.db:GetCurrentProfile(),'green'))
	profilelabel.fontSize="large"
	self:AddAction('switchProfile',L['Choose profile'],L['Switch between global and per character profile'])
	self:AddLabel(L['Options'],L['Choose what is shown'])
	self:AddToggle('SHOWENCHANT',true,L['Shows missing enchants']).width="full"
	self:AddToggle('SHOWSOCKETS',true,L['Shows number of empty socket']).width="full"
	self:AddToggle('SHOWGEMS',true,L['Shows total number of gems']).width="full"
	self:AddToggle('SHOWBUCKLE',true,L['Assume Buckle on waist']).width="full"
	self:AddLabel(L['Appearance'],L['Change colors and appearance'])
	self:AddSelect('CORNER',"br",
	{br=L['Bottom Right'],
		tr=L['Top Right'],
		tl=L['Top Left'],
		bl=L['Bottom Left']
	},L['Level text aligned to'],L['Position']).width="full"
	self:AddSelect('COLORSCHEME',"qual",
	{
		lvup=L['itemlevel (red best)'],
		lvdn=L['itemlevel (green best)'],
		qual=L['quality'],
		plain=L['none (plain white)']},
	L['Colorize level text by'],
	L['Choose a color scheme']
	).width="full"
	self:AddSelect('GEMCORNER',"br",
	{br=L['Bottom Right'],
		tr=L['Top Right'],
		tl=L['Top Left'],
		bl=L['Bottom Left']
	},L['Gem frame position'],L['Position']).width="full"
	self:AddOpenCmd('showinfo',"cmdInfo",L["Debug info"],L["Show raw item info.Please post the screenshot to Curse Forum"]).width="full"
	self:loadHelp()
	if self:getEnchantLevel() >= 360 then
		Finger0Slot.E=true
		Finger1Slot.E=true
	end
	self:RegisterEvent("UNIT_INVENTORY_CHANGED","markDirty")
	if (not self.db.char.choosen) then
		self:switchProfile(false)
	end

end

function addon:addGemLayer()
	gframe=CreateFrame("frame",addonName .. "main",PaperDollFrame)
	local alarframe=LibStub("AlarFrames-3.0",true)
	gframe:SetHeight(75)
	gframe:SetWidth(50)
	gframe:SetFrameStrata("FULLSCREEN")
	if (alarframe) then
		alarframe:TTAdd(gframe,L["Total compatible gems/Total sockets"],false)
	end
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
		y=-65
	else
		y=40
	end
	if (h=="LEFT") then
		x=55
	else
		h="LEFT"
		x=240
	end
	gframe:ClearAllPoints()
	gframe:SetPoint(v..h,PaperDollFrame,v..h,x,y)
end

local wininfo
local profiles={}
function addon:switchProfile(fromPanel)
	local gui=LibStub("AceGUI-3.0")
	wininfo=gui:Create("AlarConfig")
	wininfo:SetWidth(500)
	wininfo:SetHeight(180)
	print("Finestra ",wininfo:GetHeight())
	wininfo:SetLayout('Flow')
	wininfo:SetTitle('ItemLevelDisplay')
	wininfo:SetUserData("currentprofile",self.db:GetCurrentProfile())
	wininfo:SetUserData("newprofile",self.db:GetCurrentProfile())
	wininfo:SetStatusText("")
	local l0=gui:Create("Label")
	local l1=gui:Create("Label")
	local l2=gui:Create("Label")
	l0:SetFontObject(GameFontNormalLarge)
	l1:SetFontObject(GameFontWhite)
	l2:SetFontObject(GameFontWhite)
	l0:SetText(L["Please, choose between global or per character profile"])
	l0:SetColor(C.Yellow())
	l1:SetText(L['You can now choose if you want all your character share the same configuration or not.'])
	l2:SetText(L['You can change this decision on a per character basis in configuration panel.'])
	l0:SetFullWidth(true)
	l1:SetFullWidth(true)
	l2:SetFullWidth(true)
	local g=gui:Create("Dropdown")
	g:SetList({Default=L["Default"],character=L["Per character profile"]},{'Default','character'})
	if (profile=='Default') then
		g:SetValue('Default')
	else
		g:SetValue('character')
	end
	g:SetFullWidth(true)
	g:SetCallback('OnValueChanged',function(widget,method,key)
		if (key=='Default') then
			wininfo:SetUserData("newprofile","Default")
		else
			wininfo:SetUserData("newprofile",self.db.keys.char)
		end
	end)
	wininfo:AddChild(l0)
	wininfo:AddChild(l1)
	wininfo:AddChild(l2)
	wininfo:AddChild(g)
	wininfo:SetCallback('OnCancel',print)
	wininfo:SetCallback('OnSave',
	function(widget)
		print("Boxclose",fromPanel)
		if (wininfo:GetUserData("currentprofile") ~= wininfo:GetUserData("newprofile")) then
			self.db:SetProfile(wininfo:GetUserData("newprofile"))
		end
		profilelabel.name=L['Current profile is: '] .. C(self.db:GetCurrentProfile(),'green')
		if (fromPanel) then
			print("Reloading gui")
			self:Gui()
		end
		self:markDirty()
		widget:Hide()
		widget:Release()
		self.db.char.choosen=true
	end
	)
	wininfo:Show()
	print("Finestra ",wininfo:GetHeight())

end
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
			C(I:GetItemLevelUpgrade(u),"orange"),
			data or "<empty>"
			)
			)
			wininfo:AddChild(l)
		end
	end
end
function addon:cmdProfiles()
	local gui=LibStub("AceGUI-3.0")
	wininfo=gui:Create("Frame")
	wininfo:SetTitle("Please post this screenshot to curse, thanks")
	wininfo:SetStatusText("Add the expected ilevel for upgraded items")
	wipe(profiles)
	profiles=self.db:GetProfiles(profiles)
	for index,name in pairs(profiles) do
		local gui=LibStub("AceGUI-3.0")
		local l=gui:Create("Label")
		l:SetFullWidth(true)
		l:SetText(format("%s: %s",index,name))
		wininfo:AddChild(l)
	end
end


function addon:getEnchantLevel()
	local p1,p2=GetProfessions()
	if (p1) then
		local name,icon,level=GetProfessionInfo(p1)
		if (icon=='Interface\\Icons\\INV_Misc_Gem') then
			return level
		end
	end
	if (p2) then
		local name,icon,level=GetProfessionInfo(p2)
		if (icon=='Interface\\Icons\\INV_Misc_Gem') then
			return level
		end
	end
	return 0
end

