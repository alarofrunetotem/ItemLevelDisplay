local me,ns=...
local L=LibStub("AceLocale-3.0"):GetLocale(me,true)
local hlp=LibStub("AceAddon-3.0"):GetAddon(me)
function hlp:loadHelp()
self:HF_Title("Quick Item Level Display","RELNOTES")
self:HF_Paragraph("Description")
self:HF_Pre([[
ItemLevelDisplay adds a tiny layer on each equipment slot in your paperdoll frame showing:

		ItemLevel
		Socket Status
		Enchant Status

]])
self:RelNotes(1,3,2,[[
Feature: Configuration can now be global.(i.e. all characters share the same settings)
Fix: Best green and best red were swapped
]])
self:RelNotes(1,3,1,[[
Feature: Refined configuration panel
Feature: Added enchantable rings for enchanter
Fix: gem mini panel is now always updated
]])
self:RelNotes(1,3,0,[[
Feature: Refactored appearance with now 4 color schemes:
 * Quality: based on item quality from poor to Heirloom
 * Plain: no color at all
 * Level green: based on relative level (green are best)
 * Level red: based on relative level (red are best)
Thanks to KVLtv for donating the code
]])
self:RelNotes(1,2,7,[[
Upgrade: Accounts for 5.4.8 item upgrades
]])
self:RelNotes(1,2,6,[[
Upgrade: Accounts for 5.4 item upgrades
]])
self:RelNotes(1,2,4,[[
Feature: More localization
]])
self:RelNotes(1,1,2,[[
Fixed: Gem count was inaccurate
Fixed: Gem layer was appearing even when on different Character Frame tab
Fixed: Upgraded item was displayed incorrectly
Fixed: /ild showinfo was giving an error
]])
self:RelNotes(1,1,2,[[
Upgrade: Accounts for 5.3 item upgrades
]])
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

end

