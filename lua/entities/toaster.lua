
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

function ENT:SetupDataTables()
 
	self:NetworkVar( "Bool", 0, "Operating" )
 
 end

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

end

function ENT:Think()
	if CLIENT then return end

	if !IsValid(self.Seat) then return end
	if IsValid(self.Seat:GetPassenger(0)) then
		if !self:GetOperating() then
			self:SetOperating(true)
		end
	else
		if self:GetOperating() then
			self:SetOperating(false)
		end
	end
end



if ( SERVER ) then return end -- We do NOT want to execute anything below in this FILE on SERVER

function ENT:GhostRender()
	print("rrssr")
end

function ENT:Draw()
	self:DrawModel()

	if self:GetOperating() then
		self:GhostRender()
	end

	--return true
end
