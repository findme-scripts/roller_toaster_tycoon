AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "AI"
ENT.Author = "find me"
ENT.Information = "It learns things."
ENT.Category = "ai"
ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.PhysRadius = 8

if SERVER then

	function ENT:Initialize()
		self:SetModel("models/maxofs2d/hover_classic.mdl")

		if self:PhysicsInitSphere(self.PhysRadius) then
			self:GetPhysicsObject():EnableGravity(false)

			self:CreateCompass()

			self:CreateChamber()
		end
	end

	function ENT:CreateCompass()
		self.Compass = ents.Create("compass")
		self.Compass:SetPos(self:GetPos())
		self.Compass:Spawn()
		self.Compass.Owner = self
	end

	function ENT:CreateChamber()
		self.Chamber = ents.Create("chamber")
		self.Chamber:SetPos(self:GetPos())
		self.Chamber:Spawn()
		self.Chamber.Owner = self
	end

	function ENT:PhysicsUpdate(phys)

		if self.Compass then self.Compass:SetPos(self:GetPos()) self.Compass:PrePhysThink() end
		if self.Chamber then self.Chamber:SetPos(self:GetPos()) self.Chamber:PrePhysThink() end

		local force = phys:GetMass() * Vector( 0, 0, -3.80665 ) * 39.37
		local dt = engine.TickInterval()
		phys:ApplyForceCenter(force * dt)

	end

end




if CLIENT then

	function ENT:Initialize()
	end

	function ENT:Draw()
		self:DrawModel()
	end

end