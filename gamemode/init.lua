
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
	GAMEMODE:RoundEndWithResult( ROUND_RESULT_DRAW )

end

function GM:InitPostEntity()
	if not self.Data.DrawRunner then self.Data.DrawRunner = {} end
	if not self.Data.DrawKiller then self.Data.DrawKiller = {} end
	
	self.Data.DrawRunner = table.Copy( ents.FindByName("DR2D_RUNNER_*") )
	self.Data.DrawKiller = table.Copy( ents.FindByName("DR2D_KILLER_*") )
end

function GM:UpdatePartialBrushList( plyNet )
	local rp = nil
	if not plyNet then
		rp = RecipientFilter()
		rp:AddAllPlayers()
		plyNet = rp
	end

	umsg.Start("PartialBrushList", plyNet)
		umsg.Short( #self.Data.DrawRunner )
		umsg.Short( #self.Data.DrawKiller )
		for k,ent in pairs(self.Data.DrawRunner) do
			umsg.Entity(ent)
		end
		for k,ent in pairs(self.Data.DrawKiller) do
			umsg.Entity(ent)
		end
	umsg.End()
end

function GM:PlayerInitialSpawn( ply )
	self:UpdatePartialBrushList( ply )
end

function GM:StartRoundBasedGame( )
	self.BaseClass:StartRoundBasedGame()
	
	self:UpdatePartialBrushList( nil )
end

function GM:Think()

end

function GM:SetDeathSound( teamDiscrim, deathSound )
	if not self.Data.DeathSounds then self.Data.DeathSounds = {} end
	//if deathSound != "" then resource.AddFile("sound/" .. deathSound) end

	self.Data.DeathSounds[teamDiscrim] = deathSound or ""
	
	print("Death Sound : ", teamDiscrim, deathSound )
end

function GM:PlayerDeathSound( )
	return (self.Data.DeathSounds != nil)
end

function GM:PlayerDeath( victim )
	if self.Data.DeathSounds and self.Data.DeathSounds[victim:Team()] and self.Data.DeathSounds[victim:Team()] != "" then
		victim:EmitSound( self.Data.DeathSounds[victim:Team()] )
	end
	//victim:EmitSound("../../../common/left 4 dead 2 demo/left4dead2/sound/music/undeath/death.wav")
end
