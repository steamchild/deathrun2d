
local meta = FindMetaTable( "Player" )
if (!meta) then return end 

function meta:ForceFlashlight( switchOn )
	self._ForceFlashlight = true
	self:Flashlight( switchOn )
	self._ForceFlashlight = false
end

function meta:GetKillerCookie( )
	return GAMEMODE.Data.PlayerKillerCookie[self:UniqueID()] or 0
end

function meta:UpgradeKillerCookie( )
	if GAMEMODE.Data.PlayerKillerCookie[self:UniqueID()] <= GAMEMODE:GetCurrentKillerCookie() then
		GAMEMODE.Data.PlayerKillerCookie[self:UniqueID()] = GAMEMODE:GetCurrentKillerCookie() + 1
	end
end

function meta:NormalizeKillerCookie( )
	if GAMEMODE.Data.PlayerKillerCookie[self:UniqueID()] < GAMEMODE:GetCurrentKillerCookie() then
		GAMEMODE.Data.PlayerKillerCookie[self:UniqueID()] = GAMEMODE:GetCurrentKillerCookie()
	end
end

function meta:IsKillerEligible()
	return GAMEMODE:GetKillerCookie() == self:GetKillerCookie( )
end


function meta:IsSpectating()
	return ( self:Team() == TEAM_SPECTATOR and self:GetObserverMode() > OBS_MODE_NONE )
end

function meta:IsObserver()
	return ( self:GetObserverMode() > OBS_MODE_NONE )
end
