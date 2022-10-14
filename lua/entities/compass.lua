AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Compass"
ENT.Author = "find me"
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.PhysRadius = 8

if SERVER then

	function ENT:Initialize()
		self:SetModel("models/maxofs2d/hover_plate.mdl")
		self:DrawShadow(false)
	end

	function ENT:PrePhysThink()
		
	end

end




if CLIENT then

	function ENT:Initialize()
		self:SetModel("models/maxofs2d/hover_plate.mdl")
	end

	function ENT:Draw()
		--self:DrawModel()
	end

end