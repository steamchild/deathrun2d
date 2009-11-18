//////////////////////////////////////////////////
// DeathRun 2D (by Hurricaaane (Ha3))
// - Shared Data Sharing.
//////////////////////////////////////////////////

if ( SERVER ) then
	function GM:SetEventSound( event, sound )
		if not self.Data.EventSounds then self.Data.EventSounds = {} end
		
		self.Data.EventSounds[event] = sound
	end

	function GM:UpdateEventSounds( plyNet )
		if not (self.Data.EventSounds) then return end
		
		local rp = nil
		if not plyNet then
			rp = RecipientFilter()
			rp:AddAllPlayers()
			plyNet = rp
		end

		umsg.Start("EventSounds", plyNet)
			umsg.String( self.Data.EventSounds[DR2D_EVENT_RUNNERSWIN] or "" )
			umsg.String( self.Data.EventSounds[DR2D_EVENT_KILLERSWIN] or "" )
			umsg.String( self.Data.EventSounds[DR2D_EVENT_DRAW] or "" )
			umsg.String( self.Data.EventSounds[DR2D_EVENT_TIMEUP] or "" )
		umsg.End()
	end
	
	function GM:SetTurnOnFlashlightOnSpawn( value )
		self.Data.FlashlightSpawn = tonumber(value)
	end
	
	function GM:SetAllowFlashlightSwitch( value )
		self.Data.FlashlightSwitch = tonumber(value)
	end

else

	local function EventSounds( m )
		print("Receiving EventSounds.")
		
		GAMEMODE.Data.EventSounds = {}
		
		for k=DR2D_EVENT_RUNNERSWIN,DR2D_EVENT_TIMEUP do
			GAMEMODE.Data.EventSounds[ k ] = m:ReadString()
		end
	end
	usermessage.Hook( "EventSounds", EventSounds )

end