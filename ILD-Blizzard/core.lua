local me,ns=...
local addon=ns.addon
local module=ns.module
function module:IsItemButton(name)
	return name:find("ContainerFrame%dItem")
end
function module:OnInitialized()
	for i=1,5 do
		self:SetTriggerFrame(("ContainerFrame%d"):format(i))
	end
end
