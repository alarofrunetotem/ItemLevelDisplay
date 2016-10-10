local me,ns=...
local addon=ns.addon
local module=ns.module
local one
if LibDebug then LibDebug() end
function module:OnInitialized()
	one=LibStub("AceAddon-3.0"):GetAddon("OneBag3")
	print(one)
end
function module:OnEnabled()
	self:SecureHook(one,"UpdateBag","Display")
end
function module:Display(obj,bag)
	if not obj.frame.bags then return end
	if not obj.frame.bags[bag] then return end
	if bag==-1 or bag==-3 then return end -- managed via bank
	local frame=obj.frame.bags[bag]
	if frame.size and frame.size > 0 then
		local bagId = frame:GetID();
		local name = frame:GetName();
		for i=1,frame.size do
			local button=_G[name .. "Item" ..i]
			local quality,itemlink,class=self:GetInfo(nil,bagId,button:GetID())
			self:DrawItem(button,quality,itemlink,class)
		end
	end
end
