ENT.Base = "base_point"
ENT.Type = "point"

function ENT:KeyValue( key, value )
	if key == "deathsound_runner" then
		GAMEMODE:SetDeathSound( TEAM_RUNNERS , value or "" )
	elseif key == "deathsound_killer" then
		GAMEMODE:SetDeathSound( TEAM_KILLERS , value or "" )
	end
end

function ENT:Initialize()

end
