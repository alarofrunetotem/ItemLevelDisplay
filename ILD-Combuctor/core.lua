local me,ns=...
local addon=ns.addon
local module=ns.module
if LibDebug then LibDebug() end
local Combuctor
-- Ripped from Combuctor code
local function ToIndex(bag, slot)
	return (bag<0 and bag*100 - slot) or (bag*100 + slot)
end

function module:OnInitialized()
	Combuctor=LibStub("AceAddon-3.0"):GetAddon("Combuctor",true)
end
function module:OnEnabled()
  self:SecureHook(Combuctor.ItemSlot,"Update","Display")
end
function module:Display(frame)
  if not frame then return end --Cant update
  local icon, count, locked, quality, readable, lootable, itemlink = frame:GetInfo()
	self:DrawItem(frame,quality,itemlink)
end
