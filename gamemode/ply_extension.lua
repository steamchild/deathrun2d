
local meta = FindMetaTable( "Player" )
if (!meta) then return end 

function meta:ForceFlashlight( switchOn )
	self._ForceFlashlight = true
	self:Flashlight( switchOn )
	self._ForceFlashlight = false
end

function meta:IsSpectating()
	return ( self:Team() == TEAM_SPECTATOR and self:GetObserverMode() > OBS_MODE_NONE )
end

function meta:IsObserver()
	return ( self:GetObserverMode() > OBS_MODE_NONE )
end
