include( 'shared.lua' )
include( "overv_chataddtext.lua" )


function GM:PositionScoreboard( ScoreBoard )
	ScoreBoard:SetSize( 700, ScrH() - 100 )
	ScoreBoard:SetPos( (ScrW() - ScoreBoard:GetWide()) / 2, 50 )

end

local AIMDISTtodyna = 100

function GM:CreateMove( cmd )

	local ang = cmd:GetViewAngles()
	ang.y = 0
	
	cmd:SetUpMove( 0 )
	cmd:SetSideMove( 0 )
	cmd:SetViewAngles( ang )
	
	AIMDISTtodyna = math.Clamp( AIMDISTtodyna - cmd:GetMouseY() / 5, 25, 2100 )
	
end

function GM:DrawCrosshair( )
	if not LocalPlayer():Alive() then return end

	local pos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 64
	local toscreen = pos:ToScreen()
	
	self:BiltCrosshair( toscreen, 4, 2 )
	
	local hittraceres = util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) )
	local toscreenhit = hittraceres.HitPos:ToScreen()
	self:BiltCrosshair( toscreenhit, 8, 2 )
	
end

function GM:BiltCrosshair( toscreenData, length, thick )
	surface.SetDrawColor( 255, 220, 0, 255 )
	surface.DrawRect(toscreenData.x - length/2, toscreenData.y - thick/2 , length, thick  )
	surface.DrawRect(toscreenData.x - thick/2 , toscreenData.y - length/2,  thick, length )
end

function GM:HUDPaint()
	self.BaseClass:HUDPaint()
	
	self:DrawCrosshair()
end

local calcmark = {}
calcmark.x = 0
calcmark.y = 0
calcmark.z = 0
local viewmark = {}
viewmark.x = 0
viewmark.y = 0
viewmark.z = 0
local ratemark = {}
ratemark.x = 0.4
ratemark.y = 0.4
ratemark.z = 0.8

local calccamdist_input = {}
calccamdist_input.mask = SOLID_BRUSHONLY

local calccamdist_output = {}

function GM:CalcView( ply, origin, angle, fov )
	local view = {}
	local aim = angle
	aim.p = 0
	aim.y = 90
	aim.r = 0
	
	calccamdist_input.startpos = ply:GetPos()
	calccamdist_input.startpos.z = calccamdist_input.startpos.z + 32
	calccamdist_input.endpos = ply:GetPos()
	calccamdist_input.endpos.z = calccamdist_input.endpos.z + 32
	calccamdist_input.endpos.y = calccamdist_input.endpos.y - 1024
	
	calccamdist_output = util.TraceLine( calccamdist_input )
	
	local distance = (calccamdist_input.startpos - calccamdist_output.HitPos):Length() * 0.9

	if not ply:Alive() then
	
		local corpse = LocalPlayer():GetRagdollEntity()
		view.angles = aim
		
		if corpse and corpse:IsValid() then
			view.origin = corpse:GetPos()
			calcmark.y = view.origin.y - distance
		else
			view.origin = ply:GetPos()
			calcmark.y = view.origin.y - distance
		end
		
		calcmark.x = view.origin.x
		calcmark.z = view.origin.z
	else
		view.angles = aim
	
		view.origin = ply:GetPos()
		calcmark.x = view.origin.x
		calcmark.y = view.origin.y - distance
		calcmark.z = view.origin.z + 32
	
	end	
	
	viewmark.x = viewmark.x + (calcmark.x - viewmark.x) * math.Clamp( ratemark.x * 5 * FrameTime() , 0 , 1 )
	viewmark.y = viewmark.y + (calcmark.y - viewmark.y) * math.Clamp( ratemark.y * 5 * FrameTime() , 0 , 1 )
	viewmark.z = viewmark.z + (calcmark.z - viewmark.z) * math.Clamp( ratemark.z * 5 * FrameTime() , 0 , 1 )

	view.origin.x = viewmark.x
	view.origin.y = viewmark.y
	view.origin.z = viewmark.z
	
	return view

end


local function HaveRunnersWon( m )
	local runnersHaveWon = m:ReadBool()
	local myTeam = LocalPlayer():Team()

	if (runnersHaveWon and (myTeam == TEAM_RUNNERS)) or (not runnersHaveWon and (myTeam == TEAM_KILLERS)) then
		//surface.PlaySound("winSound")
	else
		//surface.PlaySound("failSound")
	end
end
usermessage.Hook( "HaveRunnersWon", HaveRunnersWon )
