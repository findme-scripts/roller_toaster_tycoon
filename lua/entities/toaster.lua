
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Base = "prop_vehicle_prisoner_pod"
ENT.PrintName = "toaster"
ENT.Author = "find me"
ENT.Information = "sick"
ENT.Category = "find me"

ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
self:SetModel("models/props_phx/carseat2.mdl")
	if ( CLIENT ) then return end

	--self:SetModel("prop_vehicle_prisoner_pod")
	--self:PhysicsInit(SOLID_VPHYSICS)
	--self:SetMoveType(MOVETYPE_VPHYSICS)

	--self:GetPhysicsObject():SetMass(1000)
	--self:GetPhysicsObject():EnableMotion(true)

	--self:PhysWake()


	--self:DrawShadow(false)

	--local seat = ents.Create("prop_vehicle_prisoner_pod")
	--seat:SetModel("models/props_phx/carseat2.mdl")
	--seat:SetPos(self:GetPos())
	--seat:Spawn()

end




if ( SERVER ) then return end -- We do NOT want to execute anything below in this FILE on SERVER

function ENT:Draw()
	self:DrawModel()

	--return true
end
