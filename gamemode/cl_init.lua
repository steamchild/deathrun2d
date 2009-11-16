include( 'shared.lua' )
include( "overv_chataddtext.lua" )

local myTeam = -1
local myAlive = -1

local function PartialBrushList( m )
	local numDrawRunner = m:ReadShort()
	local numDrawKiller = m:ReadShort()
	
	print("Receiving PartialBrushList : Got "..numDrawRunner.." DrawRunner Brushes and "..numDrawKiller.." DrawKiller Brushes.")
	
	GAMEMODE.Data.DrawRunner = {}
	GAMEMODE.Data.DrawKiller = {}
	
	for k=1,numDrawRunner do
		table.insert(GAMEMODE.Data.DrawRunner, m:ReadEntity())
	end
	for k=1,numDrawKiller do
		table.insert(GAMEMODE.Data.DrawKiller, m:ReadEntity())
	end
end
usermessage.Hook( "PartialBrushList", PartialBrushList )

function GM:Think()
	if (myTeam != LocalPlayer():Team()) or (myAlive != LocalPlayer():Alive()) then
		myTeam = LocalPlayer():Team()
		myAlive = LocalPlayer():Alive()
		
		if (self.Data.DrawRunner) then
			for k,ent in pairs(self.Data.DrawRunner) do
				if ValidEntity(ent) then ent:SetNoDraw( myTeam != TEAM_RUNNERS ) end
			end
		end
		if (self.Data.DrawKiller) then
			for k,ent in pairs(self.Data.DrawKiller) do
				if ValidEntity(ent) then ent:SetNoDraw( myTeam != TEAM_KILLERS ) end
			end
		end
		
	end
	
end

gui.EnableScreenClicker( true )

local calcmark = Vector(0,0,0)
local viewmark = Vector(0,0,0)
local ratemark = {}
ratemark.x = 0.6
ratemark.y = 0.6
ratemark.z = 0.8
local velomark = Vector(0,0,0)
velorate = 0.5

local calccamdist_input = {}
calccamdist_input.mask = 1073741824 - CONTENTS_LADDER
calccamdist_input.startpos = Vector(0,0,0)
calccamdist_input.endpos   = Vector(0,0,0)

local calccamdist_output = {}

function GM:CalcView( ply, origin, angle, fov )
	local view = {}
	local aim = angle
	aim.p = 0
	aim.y = 90
	aim.r = 0
	
	calccamdist_input.start = ply:GetPos()
	calccamdist_input.start.z = calccamdist_input.start.z + 32
	calccamdist_input.endpos = ply:GetPos()
	calccamdist_input.endpos.z = calccamdist_input.endpos.z + 32
	calccamdist_input.endpos.y = calccamdist_input.endpos.y - 1024
	
	calccamdist_output = util.TraceLine( calccamdist_input )
	
	local distance = (calccamdist_input.start - calccamdist_output.HitPos):Length() * 0.9
	//print("distance is : "..distance)
	local velocity = ply:Alive() and ply:GetVelocity() or Vector(0,0,0)
	velocity = math.Clamp(velocity:Length(), 0, (distance + 1)/9) * velocity:Normalize() * 3
	
	velomark.x = velomark.x + (velocity.x - velomark.x) * math.Clamp( velorate * 5 * FrameTime() , 0 , 1 )
	velomark.y = velomark.y + (velocity.y - velomark.y) * math.Clamp( velorate * 5 * FrameTime() , 0 , 1 )
	velomark.z = velomark.z + (velocity.z - velomark.z) * math.Clamp( velorate * 5 * FrameTime() , 0 , 1 )
	
	if not ply:Alive() then
	
		local corpse = LocalPlayer():GetRagdollEntity()
		view.angles = aim
		
		if corpse and corpse:IsValid() then
			view.origin = corpse:GetPos() + velomark
			calcmark.y = view.origin.y - distance
		else
			view.origin = ply:GetPos() + velomark
			calcmark.y = view.origin.y - distance
		end
		
		calcmark.x = view.origin.x
		calcmark.z = view.origin.z + 16
	else
		view.angles = aim
	
		view.origin = ply:GetPos() + velomark
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

function GM:CreateMove( cmd )
	local vpos = LocalPlayer():GetShootPos()

	local ppos = vpos:ToScreen()
	ppos = Vector( ppos.x, ppos.y, 0 )
	local mpos = Vector( gui.MouseX(), gui.MouseY(), 0 )

	local aim = (mpos - ppos):Angle()

	local ang = Angle(0,0,0)

	if (mpos.x < ppos.x) then
		aim:RotateAroundAxis(Vector(0,0,1),180)
		ang.p = -aim.y
		ang.y = 180;
		cmd:SetForwardMove( -cmd:GetSideMove() )
		
	else
		ang.p = aim.y
		ang.y = 0;
		cmd:SetForwardMove( cmd:GetSideMove() )
		
	end
	
	cmd:SetViewAngles( ang )
	cmd:SetSideMove( 0 )
	cmd:SetUpMove( 0 )
end

function GM:GUIMousePressed( mousecode )
	if (mousecode == MOUSE_LEFT) then
		RunConsoleCommand("+attack")
	elseif (mousecode == MOUSE_RIGHT) then
		RunConsoleCommand("+attack2")
	elseif (mousecode == MOUSE_MIDDLE) then
		RunConsoleCommand("lastinv")
	elseif (mousecode == MOUSE_4) then
		RunConsoleCommand("+voicerecord")
	elseif (mousecode == MOUSE_5) then
		RunConsoleCommand("+voicerecord")
	end
end

function GM:GUIMouseReleased( mousecode )
	if (mousecode == MOUSE_LEFT) then
		RunConsoleCommand("-attack")
	elseif (mousecode == MOUSE_RIGHT) then
		RunConsoleCommand("-attack2")
	elseif (mousecode == MOUSE_4) then
		RunConsoleCommand("-voicerecord")
	elseif (mousecode == MOUSE_5) then
		RunConsoleCommand("-voicerecord")
	end
end

/*
function GM:PlayerBindPress( ply, bind, pressed )
	if string.find( bind , "forward" ) then
		if pressed then
			RunConsoleCommand( "+jump" )
		else
			RunConsoleCommand( "-jump" )
		end
		return false
	end
	
	if string.find( bind , "back" ) then
		if pressed then
			RunConsoleCommand( "+duck" )
		else
			RunConsoleCommand( "-duck" )
		end
		return false
	end
end
*/

/*
function GM:CreateMove( cmd )

	local ang = cmd:GetViewAngles()
	ang.y = 0
	
	cmd:SetUpMove( 0 )
	cmd:SetSideMove( 0 )
	cmd:SetViewAngles( ang )
	
	AIMDISTtodyna = math.Clamp( AIMDISTtodyna - cmd:GetMouseY() / 5, 25, 2100 )
	
end
*/

function GM:PositionScoreboard( ScoreBoard )
	ScoreBoard:SetSize( 700, ScrH() - 100 )
	ScoreBoard:SetPos( (ScrW() - ScoreBoard:GetWide()) / 2, 50 )

end

function GM:DrawCrosshair( )

	self:BiltCrosshair( gui.MouseX(), gui.MouseY(), 10, 4, 0, 0, 0, 192 )
	self:BiltCrosshair( gui.MouseX(), gui.MouseY(), 6, 6, 0, 0, 0, 192 )
	
	self:BiltCrosshair( gui.MouseX(), gui.MouseY(), 8, 2, 255, 255, 255, 255 )
	self:BiltCrosshair( gui.MouseX(), gui.MouseY(), 4, 4, 255, 255, 255, 255 )

	if LocalPlayer():Alive() then
		local pos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 64
		local toscreen = pos:ToScreen()
		self:BiltCrosshair( toscreen.x, toscreen.y, 4, 2 )
		
		local hittraceres = util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) )
		local toscreenhit = hittraceres.HitPos:ToScreen()
		self:BiltCrosshair( toscreenhit.x, toscreenhit.y, 8, 2 )
		
	end
	
end

function GM:BiltCrosshair( screenx, screeny, length, thick , oR, oG, oB, oA)
	surface.SetDrawColor( oR or 255, oG or 220, oB or 0, oA or 255 )
	surface.DrawRect(screenx - length/2, screeny - thick/2 , length, thick  )
	if (length != thick) then
		surface.DrawRect(screenx - thick/2 , screeny - length/2,  thick, length )
	end
end

function GM:HUDPaint()
	self.BaseClass:HUDPaint()
	
	self:DrawCrosshair()
end

local CircleMat = Material( "SGM/playercircle" )

function GM:DrawPlayerRing( pPlayer )

	if ( !IsValid( pPlayer ) ) then return end
	if ( !pPlayer:GetNWBool( "DrawRing", false ) ) then return end
	if ( !pPlayer:Alive() ) then return end
	
	local trace = {}
	trace.start 	= pPlayer:GetPos()
	trace.start.z   = trace.start.z + 32/3
	trace.endpos 	= pPlayer:GetPos()
	trace.endpos.z  = trace.endpos.z + 32/3
	trace.endpos.y  = trace.endpos.y + 1024
	//trace.filter 	= pPlayer
	trace.mask 	    = PLAYERSOLID_BRUSHONLY
	
	local tr = util.TraceLine( trace )
	
	if not tr.HitWorld then
		tr.HitPos = pPlayer:GetPos()
	end

	local color = table.Copy( team.GetColor( pPlayer:Team() ) )
	color.a = 40;

	render.SetMaterial( CircleMat )
	render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, GAMEMODE.PlayerRingSize, GAMEMODE.PlayerRingSize, color )	

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
