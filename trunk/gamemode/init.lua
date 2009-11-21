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

GM.Data.PlayerKillerCookie = {}
function GM:GetKillerCookie( )
	if not self.Data.KillerCookie then
		self.Data.KillerCookie = 0
	end
	
	return self.Data.KillerCookie
end

function GM:UpgradeKillerCookie( )
	self.Data.KillerCookie = self:GetGamemodeKillerCookie() + 1
	
	for k,ply in pairs(player.GetAll()) do
		ply:NormalizeKillerCookie()
	end
end

function GM:SelectKillers( )
	for k,ply in pairs(team.GetPlayers(TEAM_KILLERS)) do
		ply:SetTeam( TEAM_RUNNERS )
	end
	
	local players = table.Copy( team.GetPlayers(TEAM_RUNNERS) )
	
	if #players <= 1 then
		print("Not enough players to start a game.")
		return
	end
	
	local eligibleplys = {}
	for k,ply in pairs(players) do
		if ply:IsKillerEligible() then
			table.insert( eligibleplys , ply )
		end
	end
	
	if #eligibleplys == 0 then
		self:UpgradeKillerCookie()
	end
	
	local playerPickCount = 0
	if (#players >= 5) and (#eligibleplys >= 2) then
		playerPickCount = 2
	else
		playerPickCount = 1
	end
	
	for i=1,playerPickCount do
		local chosen = table.remove( eligibleplys , math.random(1,#eligibleplys) )
		chosen:UpgradeKillerCookie()
		choser:SetTeam( TEAM_KILLERS )
	end
end

function GM:OnPreRoundStart( num )
	self.BaseClass:OnPreRoundStart( num )
	self:SelectKillers( )
	
end

function GM:StartRoundBasedGame( )
	self.BaseClass:StartRoundBasedGame()
	
	self:UpdatePartialBrushList( nil )
	//self:SelectKillers( )
end

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
	
	ply:SetAllowFullRotation( false )

	if self.Data.FlashlightSpawn and self.Data.FlashlightSpawn != 0 then
		if (self.Data.FlashlightSpawn == 3) or (self.Data.FlashlightSpawn == ply:Team()) then
			ply:ForceFlashlight( true )
		end
	end
end
/*
function GM:PlayerSelectTeamSpawn( TeamID, pl )

	local SpawnPoints = table.ClearKeys( team.GetSpawnPoint( TeamID ) )
	local NumSpawnPoints = (SpawnPoints != nil) and table.Count( SpawnPoints )
	if ( not SpawnPoints or NumSpawnPoints == 0 ) then return end
	
	local ChosenSpawnPoint = nil
	local i = 1
	repeat
		ChosenSpawnPoint = GAMEMODE:GetBestSpawnPoint( pl, SpawnPoints[i] )
		
		i = i + 1
	until (not ChosenSpawnPoint) and (i <= NumSpawnPoints)
	
	if not ChosenSpawnPoint then
		return table.Random(SpawnPoints)
	end
	
	return ChosenSpawnPoint

end

function GM:GetBestSpawnPoint( pl, spawnpointent )

	local Pos = spawnpointent:GetPos()
	local Ents = ents.FindInBox( Pos + Vector( -16, -16, 0 ), Pos + Vector( 16, 16, 64 ) )
	
	if ( pl:Team() == TEAM_SPECTATOR || pl:Team() == TEAM_UNASSIGNED ) then return true end
	
	local Blockers = 0
	local k = 0
	repeat
		local v = Ents[k]
		if ( IsValid( v ) and v:IsPlayer() and v:Alive() and not v:IsObserver() ) then
		
			Blockers = Blockers + 1
			
		end
	until (Blockers == 0) and (k <= #Ents)
	
	if ( Blockers > 0 ) then return false end
	
	return true

end
*/

function GM:IsSpawnpointSuitable( pl, spawnpointent, bMakeSuitable )
	// Don't ask questions, it's always OK to spawn you here.
	return true

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

