
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "tables.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "overv_chataddtext.lua" )
include( "shared.lua" )
include( "tables.lua" )
include( "overv_chataddtext.lua" )


function GM:OnRoundStart( num )
	UTIL_UnFreezeAllPlayers()
	
end

function GM:OnRoundResult( t )
	UTIL_FreezeAllPlayers()
	team.AddScore( t, 1 )
	
	local rp = RecipientFilter()
	rp:AddAllPlayers( )
	umsg.Start("HaveRunnersWon", rp)
		umsg.Bool(t == TEAM_RUNNERS)
	umsg.End()
	
end

function GM:RoundTimerEnd()
	if ( !GAMEMODE:InRound() ) then return end
	//GAMEMODE:RoundEndWithResult( ROUND_RESULT_DRAW )

end

function GM:Think()

end

function GM:PlayerDeathSound( )
	return false
end

function GM:PlayerDeath( victim )
	victim:EmitSound("../../../common/left 4 dead 2 demo/left4dead2/sound/music/undeath/death.wav")
end
