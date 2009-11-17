//////////////////////////////////////////////////
// DeathRun 2D (by Hurricaaane (Ha3))
// - Main clientside + HUD.
//////////////////////////////////////////////////

include( 'shared.lua' )
include( "overv_chataddtext.lua" )
include( "sh_partialbrush.lua" )
include( "sh_datasharing.lua" )
include( "cl_sidescrolling.lua" )


function GM:Think( )
	self:CheckPartialBrushRender()
	
end

function GM:PositionScoreboard( ScoreBoard )
	ScoreBoard:SetSize( 700, ScrH() - 100 )
	ScoreBoard:SetPos( (ScrW() - ScoreBoard:GetWide()) / 2, 50 )

end

local XHAIR_LEFTOFFS = 32

local GlowSurfId =  surface.GetTextureID( "effects/yellowflare" )
function GM:DrawCrosshair( )

	self:BiltCrosshair( gui.MouseX(), gui.MouseY(), 10, 4, 0, 0, 0, 192 )
	self:BiltCrosshair( gui.MouseX(), gui.MouseY(), 6, 6, 0, 0, 0, 192 )
	
	self:BiltCrosshair( gui.MouseX(), gui.MouseY(), 8, 2, 255, 255, 255, 255 )
	self:BiltCrosshair( gui.MouseX(), gui.MouseY(), 4, 4, 255, 255, 255, 255 )

	if LocalPlayer():Alive() then
		if (LocalPlayer():GetAngles().y % 180 == 0) then
			local pos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 64
			local toscreen = pos:ToScreen()
			self:BiltCrosshair( toscreen.x, toscreen.y, 4, 2 )
			
		elseif self.Data.CamRel and (LocalPlayer():GetMoveType() != MOVETYPE_LADDER) then
			local pos = LocalPlayer():GetShootPos()
			local toscreen = pos:ToScreen()
			local clampedmousey = math.Clamp( gui.MouseY(), toscreen.y - self.Data.CamRel + 4, toscreen.y + self.Data.CamRel - 4 )
			local headcalc = (2 * (math.Clamp( gui.MouseY() - toscreen.y, - self.Data.CamRel, self.Data.CamRel ) + self.Data.CamRel)/(2 * self.Data.CamRel) - 1) * 0.99
			
			self:BiltRectangle( toscreen.x - XHAIR_LEFTOFFS, clampedmousey, 10, 18 - math.abs(18 * headcalc), nil, nil, nil, 128 )
			
			self:BiltRectangle( toscreen.x - XHAIR_LEFTOFFS, toscreen.y + self.Data.CamRel, 20, 2 )
			self:BiltRectangle( toscreen.x - XHAIR_LEFTOFFS, toscreen.y - self.Data.CamRel, 20, 2 )
			
			self:BiltRectangle( toscreen.x - XHAIR_LEFTOFFS, clampedmousey, 12, 1 )
			self:BiltCrosshair( toscreen.x - XHAIR_LEFTOFFS, clampedmousey, 4, 2 )
			
			
			self:BiltRectangle( toscreen.x - XHAIR_LEFTOFFS, toscreen.y, 8, 2 )
			
		elseif (LocalPlayer():GetMoveType() == MOVETYPE_LADDER) then
			local pos = LocalPlayer():GetShootPos()
			local toscreen = pos:ToScreen()
			
			self:BiltCrosshair( toscreen.x, toscreen.y + 32, 4, 2 )
			self:BiltCrosshair( toscreen.x, toscreen.y - 32, 4, 2 )
		end
		
		local hittraceres = util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) )
		local toscreenhit = hittraceres.HitPos:ToScreen()
		self:BiltCrosshair( toscreenhit.x, toscreenhit.y, 8, 2 )
		
		if (not hittraceres.HitWorld and ValidEntity(hittraceres.Entity)) then
			surface.SetTexture( GlowSurfId )
			surface.SetDrawColor(255,255,255,192)
			surface.DrawTexturedRectRotated(toscreenhit.x, toscreenhit.y, 32, 32, CurTime() * 90)
			
		end
		
	end
	
end

function GM:BiltRectangle( screenx, screeny, width, height, oR, oG, oB, oA)
	surface.SetDrawColor( oR or 255, oG or 220, oB or 0, oA or 255 )
	surface.DrawRect(screenx - width/2, screeny - height/2 , width, height  )
end

function GM:BiltCrosshair( screenx, screeny, length, thick , oR, oG, oB, oA)
	self:BiltRectangle( screenx, screeny, length, thick , oR, oG, oB, oA)
	if (length != thick) then
		self:BiltRectangle( screenx, screeny, thick, length , oR, oG, oB, oA)
	end
end

function GM:HUDPaint()
	self.BaseClass:HUDPaint()
	
	self:DrawCrosshair()
end

local RingTrace = {}
local RingTrRes = {}

local CircleMat = Material( "SGM/playercircle" )
function GM:DrawPlayerRing( pPlayer )

	if ( !IsValid( pPlayer ) ) then return end
	if ( !pPlayer:GetNWBool( "DrawRing", false ) ) then return end
	if ( !pPlayer:Alive() ) then return end
	
	/*
	trace.start 	= pPlayer:GetPos()
	trace.start.z   = trace.start.z + 32/3
	trace.endpos 	= pPlayer:GetPos()
	trace.endpos.z  = trace.endpos.z + 32/3
	trace.endpos.y  = trace.endpos.y + 1024
	//trace.filter 	= pPlayer
	trace.mask 	    = PLAYERSOLID_BRUSHONLY
	*/
	
	RingTrace = {}
	RingTrace.start 	= pPlayer:GetPos()
	RingTrace.start.z   = RingTrace.start.z + 32/3
	RingTrace.endpos 	= pPlayer:GetPos() + EyeAngles():Forward() * 1024
	RingTrace.mask 	    = PLAYERSOLID_BRUSHONLY
	
	RingTrRes = util.TraceLine( RingTrace )
	
	if not RingTrRes.HitWorld then
		RingTrRes.HitPos = pPlayer:GetPos()
	end

	local color = table.Copy( team.GetColor( pPlayer:Team() ) )
	color.a = 40;

	local ringScale = 1 
	if (pPlayer != LocalPlayer()) then
		ringScale = 1 + (math.sin(math.rad(CurTime()*90)) + 1) * 0.5 * 0.8
	end
	render.SetMaterial( CircleMat )
	render.DrawQuadEasy( RingTrRes.HitPos + RingTrRes.HitNormal, RingTrRes.HitNormal, GAMEMODE.PlayerRingSize * ringScale, GAMEMODE.PlayerRingSize, color )
	
end


local function HaveRunnersWon( m )
	local runnersHaveWon = m:ReadBool()
	local myTeam = LocalPlayer():Team()

	if (runnersHaveWon and (myTeam == TEAM_RUNNERS)) or (not runnersHaveWon and (myTeam == TEAM_KILLERS)) then
		if (GAMEMODE.Data.EventSounds and GAMEMODE.Data.EventSounds[DR2D_EVENT_RUNNERSWIN] != "") then
			surface.PlaySound(GAMEMODE.Data.EventSounds[DR2D_EVENT_RUNNERSWIN])
		end
		
	else
		if (GAMEMODE.Data.EventSounds and GAMEMODE.Data.EventSounds[DR2D_EVENT_RUNNERSWIN] != "") then
			surface.PlaySound(GAMEMODE.Data.EventSounds[DR2D_EVENT_KILLERSWIN])
		end
		
	end
end
usermessage.Hook( "HaveRunnersWon", HaveRunnersWon )
