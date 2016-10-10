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
	_G.Combuctor=Combuctor
end
function module:OnEnabled()
	self:SecureHook(Combuctor.ItemFrame,"UpdateSlot","Display")
end
function module:Display(frame,bag,slot)
	local index = ToIndex(bag, slot)
	local item = frame.items[index]
	if not item then return end --filtered bag
	local quality,itemlink,class=self:GetInfo(nil,bag,slot)
	return self:DrawItem(item,quality,itemlink,class)
end
