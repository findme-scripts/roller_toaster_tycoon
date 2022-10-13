AddCSLuaFile()

SWEP.PrintName = "Terrarium Builder"
SWEP.Author = "find me"
SWEP.Purpose = "It's Stephen, with a ph."
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

---------------------------------------------------------------------------------
function SWEP:Initialize()
	hook.Add("PostDrawOpaqueRenderables", "Terrarium Builder - Render Context", function() if !IsValid(self) then return end self:RenderContext() end)
	hook.Add("CalcView", "DUMB", function(pl, pos, ang, fov) if IsValid(self) then return self:calcView(pl, pos, ang, fov) end end)
end

SWEP.C =
	{
		Color(255, 80, 80, 255), --1 Red
		Color(80, 255, 80, 255), --2 Green
		Color(80, 80, 255, 255), --3 Blue
		Color(80, 80, 80, 160),   --4 Background / Transparent
		Color(255, 255, 80, 255)--5 Yellow
	}





function SWEP:DebugRender(tr)
	if !self.ZUnlock then Debug:Position("HitPos", tr.HitPos, {{0.5, 16, 16, color_white}, {"DermaDefault", 15, 15, color_white}}) end
	if self.S then Debug:Position("S", self.S, {{0.5, 16, 16, color_white}, {"DermaDefault", 15, 45, color_white}}) end
	if self.E then Debug:Position("E", self.E, {{0.5, 16, 16, color_white}, {"DermaDefault", 15, 65, color_white}}) end
	if self.M then Debug:Position("M", self.M, {{0.5, 16, 16, color_white}, {"DermaDefault", 15, 85, color_white}}) end
	if self.Vert then Debug:Position("Opp", self.Vert, {{1, 16, 16, self.C[2]}, {"DermaDefault", 15, 115, color_white}}) end
end

function SWEP:RenderContext()
	local tr = self:GetOwner():GetEyeTraceNoCursor()
	self:DebugRender(tr)

	self:Check_ZUnlock(tr)
end

function SWEP:Check_ZUnlock(tr)
	if self:GetOwner():KeyReleased(IN_ATTACK2) then return end

	if !self.S then if self.ZUnlock then self.ZUnlock = !self.ZUnlock end return end
	if !self:GetOwner():KeyDown(IN_ATTACK2) then if self.ZUnlock then self.ZUnlock = !self.ZUnlock self:GetOwner():SetEyeAngles((self.Vert-self:GetOwner():EyePos()):Angle()) end return end

	self.ZUnlock = true
end

function SWEP:calcView(pl, pos, ang, fov)
	if !self.OldAngle then self.OldAngle = ang end

	if (self.OldAngle-ang) != Angle(0, 0, 0) then
		self.AngleDiff = (self.OldAngle-ang)
	end
	self.OldAngle = ang

	local a = ang
	if self.ZUnlock then

		local original = self.E || LocalPlayer():GetEyeTraceNoCursor().HitPos
		local change = self.AngleDiff.x*3
		if !self.Accum then self.Accum = change end
		self.Accum = self.Accum + change

		self.Vert = original + Vector(0, 0, self.Accum)

		if self.Vert.z < self.E.z then
			self.Accum = 0
		end

		a = (self.Vert-self:GetOwner():EyePos()):Angle()

	end

	local view = {
		origin = pos,
		angles = a,
		fov = fov,
		drawviewer = false
	}

	return view
end


function SWEP:Think()

end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() then return end
	local tr = self:GetOwner():GetEyeTraceNoCursor()

	if !self.S then
		self.S = tr.HitPos
	elseif !self.E then
		self.E = tr.HitPos
		self.M = (self.S+self.E) * 0.5
	end

end

function SWEP:SecondaryAttack()
	if !IsFirstTimePredicted() then return end

end

function SWEP:Reload()
	self.S = nil
	self.E = nil
end

function SWEP:HUDShouldDraw()
	return true
end

function SWEP:Holster()
	return true
end