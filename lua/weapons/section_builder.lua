AddCSLuaFile()

SWEP.PrintName = "Section Builder"
SWEP.Author = "find me"
SWEP.Purpose = "Build sections out of thin air."
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.Spawnable = true
SWEP.ViewModel = Model( "models/weapons/c_toolgun.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_toolgun.mdl" )
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = falses
SWEP.Secondary.Ammo = "none"
SWEP.Category = "Roller Toaster Tycoon"

if SERVER then return end


SWEP.S = Vector()
SWEP.E = Vector()
SWEP.Drawing = false






SWEP.Initialize = function(self)
	hook.Add("PostDrawOpaqueRenderables", "Section Builder - Render Context", function() self:RenderContext() end)
end

SWEP.RenderContext = function(self)
	render.SetColorMaterial()

	if self.Drawing then
		--Indicator
		render.DrawSphere(self.S, 1, 16, 16, color_white)
		render.DrawSphere(self.E, 1, 16, 16, color_white)
		local eye = LocalPlayer():EyePos()
		local dist = eye:Distance(self.S)
		local target = eye + LocalPlayer():GetAimVector() * (dist)

		self.E = Vector(self.S.x, self.S.y, target.z)

		render.DrawLine(self.S, Vector(self.S.x, self.S.y, target.z), color_white, false)

	end

end

SWEP.PrimaryAttack = function(self)
	local tr = self:GetOwner():GetEyeTraceNoCursor()

	if self.Drawing then
		self.Drawing = false
	else
		self.S = tr.HitPos
		self.Drawing = true
	end
end

SWEP.SecondaryAttack = function(self)

end

SWEP.Reload = function(self)

end

SWEP.HUDShouldDraw = function(self)
	return true
end

SWEP.Holster = function(self)
	return true
end