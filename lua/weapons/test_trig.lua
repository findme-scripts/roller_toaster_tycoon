AddCSLuaFile()

SWEP.PrintName = "Test Trig"
SWEP.Author = "find me"
SWEP.Purpose = "Trol Trig"
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.Spawnable = true
SWEP.ViewModel = Model( "models/weapons/c_toolgun.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_toolgun.mdl" )
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = falses
SWEP.Secondary.Ammo = "none"
SWEP.Category = "Roller Toaster Tycoon"

if SERVER then return end

---------------------------------------------------------------------------------



SWEP.Initialize = function(self)
	hook.Add("PostDrawOpaqueRenderables", "Trig testing - Render Context", function() if !IsValid(self) then return end self:RenderContext() end)
end



SWEP.RenderContext = function(self)
	if !self.S then return end

	render.SetColorMaterial()
	render.DrawSphere(self.E, 2, 16, 16, color_white)
	render.DrawSphere(self.Target, 2, 16, 16, color_white)
end

SWEP.Think = function(self)
	if !self.A then return end
	local tr = self:GetOwner():GetEyeTraceNoCursor()

	local diff = self:GetOwner():EyeAngles() - self.A
	local degrees = math.Clamp(-diff.x, 0, 70)
	local td = math.tan(math.rad(degrees))
	local Adj = self:GetOwner():EyePos():Distance(self.E)
	local RealHyp = Adj * td


	print(RealHyp)

	self.Target = self.E + Vector(0, 0, 1)*RealHyp--self.E+Vector(0, 0, 1)*self.Opp
end

SWEP.PrimaryAttack = function(self)
	if !IsFirstTimePredicted() then return end
	local tr = self:GetOwner():GetEyeTraceNoCursor()

	self.E = tr.HitPos
	self.A = self:GetOwner():EyeAngles()


end

SWEP.SecondaryAttack = function(self)
	if !IsFirstTimePredicted() then return end

	
end

SWEP.Reload = function(self)

end

SWEP.HUDShouldDraw = function(self)
	return true
end

SWEP.Holster = function(self)
	return true
end