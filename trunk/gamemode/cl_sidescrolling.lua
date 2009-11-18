//////////////////////////////////////////////////
// DeathRun 2D (by Hurricaaane (Ha3))
// - Client Sidescrolling.
//////////////////////////////////////////////////

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
	self.Data.CamDist = distance
	
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
		calcmark.z = view.origin.z + 32
	else
		view.angles = aim
	
		view.origin = ply:GetPos() + velomark
		calcmark.x = view.origin.x
		calcmark.y = view.origin.y - distance
		calcmark.z = view.origin.z + 32
		
		if (ply:GetAngles().y % 180) != 0 and (ply:GetMoveType() != MOVETYPE_LADDER) then
			calcmark.x = calcmark.x + math.Clamp(1 - (distance/900), 0, 1) * 900 * 0.15
		end
	
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

	local ang = Angle(0,0,0)
	
	local fwmov = cmd:GetForwardMove()
	
	if (LocalPlayer():GetMoveType() != MOVETYPE_LADDER) then
		if (fwmov == 0) then // Sidescroll movements
			//self.Data.CamFoundLadder = false
			
			local aim = (mpos - ppos):Angle()
			
			if (mpos.x < ppos.x) then
				aim:RotateAroundAxis(Vector(0,0,1),180)
				ang.p = -aim.y
				ang.y = 180
				cmd:SetForwardMove( -cmd:GetSideMove() )
				
			else
				ang.p = aim.y
				ang.y = 0
				cmd:SetForwardMove( cmd:GetSideMove() )
				
			end
			cmd:SetSideMove( 0 )
			
		else // Special aim.
			self.Data.CamRel = (ScrH()*0.2)*(300/(self.Data.CamDist + 1))
			local headcalc = 2 * (math.Clamp( gui.MouseY() - ppos.y, - self.Data.CamRel, self.Data.CamRel ) + self.Data.CamRel)/(2*self.Data.CamRel) - 1
			local aimang = math.deg( math.asin( headcalc ) )*0.99
			cmd:SetForwardMove( 0 )
			
			if (fwmov > 0) then // Looking to the wall
				ang.p = aimang
				ang.y = 90
				/*
				if not self.Data.CamFoundLadder then
					local ladderdetect = util.QuickTrace(vpos, ang:Forward() * 48, LocalPlayer())
					if ValidEntity(ladderdetect.Entity) and ladderdetect.Entity:GetClass() == "func_brush" then
						self.Data.CamFoundLadder = true
						
					end
				end
				*/
			else
				//self.Data.CamFoundLadder = false
			
				ang.p = aimang
				ang.y = -90
				cmd:SetSideMove( - cmd:GetSideMove( ) )
			end
		end
		
	else // Player is on a Ladder
		//self.Data.CamFoundLadder = false
		
		if (cmd:GetSideMove() == 0) then
			ang.y = 90
			ang.p = -88
			
			/*
			if (mpos.y < ppos.y) then
				ang.p = -88
			else
				ang.p = 88
				cmd:SetForwardMove( -fwmov )
				// Needs retest.
			end
			*/
			
		else
			ang.p = 0
			if (cmd:GetSideMove() < 0) then
				ang.y = 180
			else
				ang.y = 0
			end
			
			//No autolatchout anymore, players will have to use to unlatch.
			//cmd:SetForwardMove( 1 )
			cmd:SetForwardMove( 0 )
			cmd:SetSideMove( 0 )
			
		end
	end
	
	cmd:SetViewAngles( ang )
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


// Garry's Mod Regular version fix
local function SideScrollShouldDrawLocalPlayer()
	return true
end
hook.Add( "ShouldDrawLocalPlayer", "SideScrollShouldDrawLocalPlayer", SideScrollShouldDrawLocalPlayer );
