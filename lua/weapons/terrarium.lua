AddCSLuaFile()

SWEP.PrintName = "The Terrarium"
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
	hook.Add("PostDrawOpaqueRenderables", "Spline Viewer - Render Context", function() if !IsValid(self) then return end self:RenderContext() end)
end


SWEP.C =
	{
		Color(255, 80, 80, 255), --1
		Color(80, 255, 80, 255), --2
		Color(80, 80, 255, 255), --3
		Color(80, 80, 80, 160)   --4 Background / Transparent
	}


function SWEP:DebugRender(hitpos)
	render.SetColorMaterial()
	render.DrawSphere(hitpos, 0.25, 16, 16, color_black)

	if !self.S then return end

	render.DrawSphere(self.S, 0.5, 16, 16, color_white)
	render.DrawLine( self.S, self.S+Vector(0, 0, 0.5), self.C[2], false)

	if !self.E then return end

	render.DrawSphere(self.E, 0.5, 16, 16, color_white)
	render.DrawLine( self.E, self.E+Vector(0, 0, 0.5), self.C[1], false)
end

function SWEP:RenderContext()
	local tr = self:GetOwner():GetEyeTraceNoCursor()
	self:DebugRender(tr.HitPos)
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
	end

end

function SWEP:SecondaryAttack()
	if !IsFirstTimePredicted() then return end

	
end

function SWEP:Reload()
	self.S = nil
	self.E = nil
end

function SWEP:DebugHUD()
	local tr = self:GetOwner():GetEyeTraceNoCursor()

	draw.RoundedBox( 4, 0, 0, 260, 300, self.C[4] )
	draw.SimpleText( "HitPos: "..tostring(tr.HitPos), "DermaDefault", 15, 15, color_white )

	if !self.S then return end

	draw.SimpleText( "S: "..tostring(self.S), "DermaDefault", 15, 40, color_white )

	if !self.E then return end

	draw.SimpleText( "E: "..tostring(self.E), "DermaDefault", 15, 55, color_white )

end

function SWEP:DrawHUD()
	self:DebugHUD()
end

function SWEP:HUDShouldDraw()
	return true
end

function SWEP:Holster()
	return true
end