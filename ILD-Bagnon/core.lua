local me,ns=...
local addon=ns.addon
local module=ns.module
local pp=print
if LibDebug then LibDebug() end
local Bagnon=Bagnon
function module:OnInitialized()
	Bagnon=_G['Bagnon']
end
function module:OnEnabled()
	self:SecureHook(Bagnon.ItemSlot,"Update","Display")
end
function module:Display(frame,...)
	local info=frame:GetInfo()
  local class
	if info and info.link then
	  if info.link then
		  class =self:GetItemInfo(info.link,12)
    end
  end
  return self:DrawItem(frame,info.quality,info.link,class)
end
