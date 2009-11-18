
local meta = FindMetaTable( "Player" )
if (!meta) then return end 

function meta:ForceFlashlight( switchOn )
	self._ForceFlashlight = true
	self:Flashlight( switchOn )
	self._ForceFlashlight = false
end

function meta:IsObserver()
	return ( self:Team() == TEAM_SPECTATOR && self:GetObserverMode() > OBS_MODE_NONE );
end
