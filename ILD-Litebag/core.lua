local me,ns=...
local addon=ns.addon
local module=ns.module
function module:OnEnabled()
  LiteBag_RegisterHook('LiteBagItemButton_Update', function(button) module:Display(button) end)
end
function module:Display(button)
	self:DrawItem(button,self:GetInfo(button))
end
