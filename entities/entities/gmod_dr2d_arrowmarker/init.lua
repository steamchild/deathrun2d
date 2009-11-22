
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_NONE )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
	self.Entity:SetTrigger( false )
	self.Entity:DrawShadow( false )

end

function ENT:Think()

end 

function ENT:AcceptInput( name, activator, caller, data )
    if (name == "Disappear") then 
        self:Remove()
    end
end
