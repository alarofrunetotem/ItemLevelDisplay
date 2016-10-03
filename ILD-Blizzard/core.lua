local me,ns=...
local addon=ns.addon
local module=ns.module
function module:IsItemButton(name)
	return name:find("ContainerFrame%dItem")
end
