//////////////////////////////////////////////////
// DeathRun 2D (by Hurricaaane (Ha3))
// - Main serverside.
//////////////////////////////////////////////////

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "tables.lua" )
AddCSLuaFile( "ply_extension.lua" )
AddCSLuaFile( "sh_partialbrush.lua" )
AddCSLuaFile( "sh_datasharing.lua" )
AddCSLuaFile( "cl_sidescrolling.lua" )
AddCSLuaFile( "overv_chataddtext.lua" )
include( "shared.lua" )
include( "tables.lua" )
include( "ply_extension.lua" )
include( "sh_partialbrush.lua" )
include( "sh_datasharing.lua" )
include( "overv_chataddtext.lua" )

resource.AddFile("materials/dr2d/worldicon_use.vmt")
resource.AddFile("materials/dr2d/worldicon_use.vtf")


////////////////////
// Sounds
////////////////////

function GM:SetDeathSound( teamDiscrim, deathSound )
	if not self.Data.DeathSounds then self.Data.DeathSounds = {} end
	
	if (self.Data.DeathSounds[teamDiscrim] != deathSound) and (deathSound != "") then
		print("Death Sound : ", teamDiscrim, deathSound )
		
		local ext = string.Right(deathSound, 4)
		
		if (ext == ".wav") or (ext == ".mp3") then
			resource.AddFile("sound/" .. deathSound)
		end
	end

	self.Data.DeathSounds[teamDiscrim] = deathSound or ""
end

function GM:PlayerDeathSound( )
	return (self.Data.DeathSounds != nil)
end

function GM:PlayerDeath( victim )
	victim:ForceFlashlight( false )

	if self.Data.DeathSounds and self.Data.DeathSounds[victim:Team()] and self.Data.DeathSounds[victim:Team()] != "" then
		victim:EmitSound( self.Data.DeathSounds[victim:Team()] )
	end
	
	//victim:EmitSound("../../../common/left 4 dead 2 demo/left4dead2/sound/music/undeath/death.wav")
end


////////////////////
// Misc
////////////////////

function GM:Think()

end


////////////////////
// Rounds
////////////////////

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
	GAMEMODE:RoundEndWithResult( ROUND_RESULT_DRAW )

end

function GM:InitPostEntity( )
	self:GatherPartialBrushList()
end

function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn( ply )
	
	self:UpdatePartialBrushList( ply )
	self:UpdateEventSounds( ply )
	ply:CrosshairDisable()
end

function GM:PlayerSpawn( ply )
	self.BaseClass:PlayerSpawn( ply )

	if self.Data.FlashlightSpawn and self.Data.FlashlightSpawn != 0 then
		if (self.Data.FlashlightSpawn == 3) or (self.Data.FlashlightSpawn == ply:Team()) then
			ply:ForceFlashlight( true )
		end
	end
end

function GM:PlayerSwitchFlashlight( ply )
	if ply._ForceFlashlight then return true end

	if self.Data.FlashlightSwitch and self.Data.FlashlightSwitch != 0 then
		if (self.Data.FlashlightSwitch == 3) or (self.Data.FlashlightSwitch == ply:Team()) then
			return false
		end
	end
	return true
end

function GM:StartRoundBasedGame( )
	self.BaseClass:StartRoundBasedGame()
	
	self:UpdatePartialBrushList( nil )
end
