local me,ns=...
local L=LibStub("AceLocale-3.0"):GetLocale(me,true)
local hlp=LibStub("AceAddon-3.0"):GetAddon(me)
-- $Id: RelNotes.lua 191 2010-12-26 17:09:14Z alar $
function hlp:loadHelp()
self:RelNotes(1,1,0,[[
Upgrade: Accounts for 5.1 item upgrades
Feature: Level text can now be moved via /ild gui
]])
self:RelNotes(1,0,8,[[
Fixed: Head slot is no longer enchantable
]])
self:RelNotes(1,0,5,[[
Feature: Now you can reverse color (red itemes are better) 
]])
self:RelNotes(1,0,3,[[
Fixed: Removed chat spam  18 [Name of item in slot 18] item type
Feature: Config menu via blizzard menu or /ild gui 
]])
self:RelNotes(1,0,2,[[
Fixed: Waist slot no longer display -1 when you have a belt buckle filled
Fixed: Now only guns/bows/crossbows should check for enchants
]])
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
]])
end

