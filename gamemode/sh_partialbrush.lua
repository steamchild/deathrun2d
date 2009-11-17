//////////////////////////////////////////////////
// DeathRun 2D (by Hurricaaane (Ha3))
// - Shared Partial Brush.
//////////////////////////////////////////////////

if ( SERVER ) then
	function GM:GatherPartialBrushList( )
		if not self.Data.DrawRunner then self.Data.DrawRunner = {} end
		if not self.Data.DrawKiller then self.Data.DrawKiller = {} end
		
		self.Data.DrawRunner = table.Copy( ents.FindByName("DR2D_RUNNER_*") )
		self.Data.DrawKiller = table.Copy( ents.FindByName("DR2D_KILLER_*") )
	end

	function GM:UpdatePartialBrushList( plyNet )
		if not (self.Data.DrawRunner or self.Data.DrawKiller) then return end
	
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

else
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
	
	function GM:CheckPartialBrushRender()
		if (self.Data.PBTeam != LocalPlayer():Team()) or (self.Data.PBAlive != LocalPlayer():Alive()) then
			self.Data.PBTeam = LocalPlayer():Team()
			self.Data.PBAlive = LocalPlayer():Alive()
			
			if (self.Data.DrawRunner) then
				for k,ent in pairs(self.Data.DrawRunner) do
					if ValidEntity(ent) then ent:SetNoDraw( self.Data.PBTeam != TEAM_RUNNERS ) end
				end
			end
			if (self.Data.DrawKiller) then
				for k,ent in pairs(self.Data.DrawKiller) do
					if ValidEntity(ent) then ent:SetNoDraw( self.Data.PBTeam != TEAM_KILLERS ) end
				end
			end
			
		end
	end
	
end
