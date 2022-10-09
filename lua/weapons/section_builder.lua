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


SWEP.Stage = -1
SWEP.Drawing = false
SWEP.DrawingPoints = {}






SWEP.Initialize = function(self)
	hook.Add("PostDrawOpaqueRenderables", "Section Builder - Render Context", function() self:RenderContext() end)
end

SWEP.RenderContext = function(self)
	render.SetColorMaterial()

	if self.Drawing then
		local points = self.DrawingPoints

		if self.Stage == 0 then
			local eye = LocalPlayer():EyePos()
			local dist = eye:Distance(points[1])
			local target = eye + LocalPlayer():GetAimVector() * (dist)

			points[2] = Vector(points[1].x, points[1].y, target.z)
		end


		for _, v in pairs(points) do
			render.DrawSphere(v, 1, 16, 16, color_white)
			if points[_+1] then
				render.DrawLine(points[1], points[2], color_white, false)
			end
		end



	end

end

SWEP.NewStage = function(self, tr)
	if self.Stage == -1 then
		self.Drawing = false
		self.DrawingPoints = {}
	elseif self.Stage == 0 then
		table.insert(self.DrawingPoints, tr.HitPos)

		self.Drawing = true
	elseif self.Stage == 1 then

	end
end

SWEP.PrimaryAttack = function(self)
	local tr = self:GetOwner():GetEyeTraceNoCursor()

	self.Stage = self.Stage + 1
	self:NewStage(tr)

end

SWEP.SecondaryAttack = function(self)
	self.Stage = -1
	self:NewStage()
end

SWEP.Reload = function(self)

end

SWEP.HUDShouldDraw = function(self)
	return true
end

SWEP.Holster = function(self)
	return true
end