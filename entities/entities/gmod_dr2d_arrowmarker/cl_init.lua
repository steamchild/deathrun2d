include('shared.lua')

ENT.Material = Material("dr2d/worldicon_arrow")
ENT.Size = 32
ENT.Color = Color(255,255,192)
ENT.MagicNumber = 0

function ENT:Initialize()
	self.A_RBWS = self.Entity:GetPos()
	self.A_RBWS.x = self.A_RBWS.x - self.Size
	self.A_RBWS.y = self.A_RBWS.y -self.Size
	
	self.B_RBWS = self.Entity:GetPos()
	self.B_RBWS.x = self.B_RBWS.x + self.Size
	self.B_RBWS.y = self.B_RBWS.y + self.Size
	
	self.MagicNumber = (self:EntIndex() % 11) * 17 + self:EntIndex() * 21
	
	self.Entity:SetRenderBoundsWS(self.A_RBWS, self.B_RBWS)
	
end

function ENT:Draw()
	local oscill = math.cos( math.rad( CurTime() * 90 + self.MagicNumber ) ) * self.Size * 0.2
	
	render.SetMaterial( self.Material )
	render.DrawQuadEasy( self:GetPos(), self:GetForward(), self.Size + oscill, self.Size + oscill, self.Color , 180 + self:GetAngles().r )
	
end
