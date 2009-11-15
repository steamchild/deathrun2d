local CLASS = {}  
  
CLASS.DisplayName           = "Killer"
CLASS.WalkSpeed             = 350
CLASS.CrouchedWalkSpeed     = 0.2
CLASS.RunSpeed              = 350
CLASS.DuckSpeed             = 0.4
CLASS.JumpPower             = 175
CLASS.DrawTeamRing          = true
CLASS.MaxHealth				= 150
CLASS.StartHealth			= 150
CLASS.Description           = ""

CLASS.RespawnTime           = 3
CLASS.DropWeaponOnDie		= true
CLASS.TeammateNoCollide 	= true
CLASS.AvoidPlayers			= false

function CLASS:Loadout( pl )  
   pl:Give("weapon_crowbar")
end

function CLASS:ShouldDrawLocalPlayer( pl )
	return true
end
     
player_class.Register( "Killer", CLASS )  