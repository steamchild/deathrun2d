GM.Name     = "DeathRun 2D"  
GM.Author   = "Hurricaaane"  
GM.Email    = ""  
GM.Website  = ""  
  
DeriveGamemode( "fretta" )  
IncludePlayerClasses()

function convertTime(hours, minutes, seconds, base)
	if (base == "m") then
		return hours * 60 + minutes + seconds / 60
	elseif (base == "h") then
		return hours + minutes / 60 + seconds / 3600
	end
	return hours * 60 * 60 + minutes * 60 + seconds
end

GM.Help     = "Run, with one dimension missing !"  
GM.TeamBased = true
GM.AllowAutoTeam = false
GM.AllowSpectating = true
GM.SelectClass = false
GM.SecondsBetweenTeamSwitches = 2
GM.GameLength = convertTime(0, 14, 0, "m")
GM.NoPlayerSuicide = false
GM.NoPlayerDamage = false
GM.NoPlayerSelfDamage = false
GM.NoPlayerTeamDamage = true
GM.NoPlayerPlayerDamage = false
GM.NoNonPlayerPlayerDamage = false
GM.SuicideString = "Suicided"

GM.MaximumDeathLength = 0			// Player will repspawn if death length > this (can be 0 to disable)
GM.MinimumDeathLength = 5			// Player has to be dead for at least this long
GM.ForceJoinBalancedTeams = false	// Players won't be allowed to join a team if it has more players than another team
GM.RoundPreStartTime = 2			// Preperation time before a round starts
GM.NoAutomaticSpawning = true		// Players don't spawn automatically when they die, some other system spawns them
GM.RoundBased = true				// Round based, like CS
GM.RoundLength = convertTime(0, 8, 0, "s") // Round length, in seconds 
GM.RoundEndsWhenOneTeamAlive = true	
GM.HudSkin = "SimpleSkin"

TEAM_RUNNERS = 1  
TEAM_KILLERS = 2  
  
function GM:CreateTeams()  
    if ( !GAMEMODE.TeamBased ) then return end  
      
	// The team setup for spawnpoints is NOT     police / people
	//                                   BUT  good guys / bad guys   for each game
	
    team.SetUp( TEAM_RUNNERS, "Runners", Color( 255, 80, 80 ), true )  
    team.SetSpawnPoint( TEAM_RUNNERS, { "info_player_counterterrorist", "info_player_rebel" } )  
    team.SetClass( TEAM_RUNNERS, { "Runner" } )
	
    team.SetUp( TEAM_KILLERS, "Killers", Color( 80, 150, 255 ), true )  
    team.SetSpawnPoint( TEAM_KILLERS, { "info_player_terrorist", "info_player_combine" } )
    team.SetClass( TEAM_KILLERS, { "Killer" } ) 
	
    team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 200, 200, 200 ), true )  
    team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_start", "info_player_terrorist", "info_player_counterterrorist" } )
end
