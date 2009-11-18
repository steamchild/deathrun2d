ENT.Base = "base_point"
ENT.Type = "point"

function ENT:KeyValue( key, value )
	if key == "deathsound_runner" then
		GAMEMODE:SetDeathSound( TEAM_RUNNERS , value or "" )
	elseif key == "deathsound_killer" then
		GAMEMODE:SetDeathSound( TEAM_KILLERS , value or "" )
	elseif key == "winsound_runners" then
		GAMEMODE:SetEventSound( DR2D_EVENT_RUNNERSWIN , value or "" )
	elseif key == "winsound_killers" then
		GAMEMODE:SetEventSound( DR2D_EVENT_KILLERSWIN , value or "" )
	elseif key == "drawsound" then
		GAMEMODE:SetEventSound( DR2D_EVENT_DRAW , value or "" )
	elseif key == "timeupsound" then
		GAMEMODE:SetEventSound( DR2D_EVENT_TIMEUP , value or "" )
	elseif key == "flashlight_on_spawn" then
		GAMEMODE:SetTurnOnFlashlightOnSpawn( value )
	elseif key == "flashlight_switch" then
		GAMEMODE:SetAllowFlashlightSwitch( value )
	end
end

function ENT:Initialize()

end
