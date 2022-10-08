
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "toaster"
ENT.Author = "find me"
ENT.Information = "sick"
ENT.Category = "find me"

ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()

	if ( CLIENT ) then return end

	self:SetModel("models/props_junk/sawblade001a.mdl")
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)

	self.Seat = ents.Create("prop_vehicle_prisoner_pod")
	self.Seat:SetModel("models/props_phx/carseat2.mdl")
	self.Seat:SetPos(self:GetPos()+Vector(0, 0, 20))
	self.Seat:Spawn()

	self.Seat:GetPhysicsObject():EnableMotion(false)
	self.Seat.Think = function(self)
		if !IsValid(self:GetPassenger()) then return end

		print("lets ride")
	end

end

function ENT:Think()
	if !IsValid(self.Seat) then return end
	if !IsValid(self.Seat:GetPassenger(0)) then return end
	
	print("let's ride")
end




if ( SERVER ) then return end -- We do NOT want to execute anything below in this FILE on SERVER

function ENT:Draw()
	self:DrawModel()

	--return true
end
