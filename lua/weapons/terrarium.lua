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
		Color(80, 80, 80, 160) --4 Background / Transparent
	}




function SWEP:RenderContext()

end

function SWEP:Think()

end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() then return end
	local tr = self:GetOwner():GetEyeTraceNoCursor()


end

function SWEP:SecondaryAttack()
	if !IsFirstTimePredicted() then return end

	
end

function SWEP:Reload()
	self.S = nil
	self.E = nil
	self.M = nil
	self.dir = nil
	self.dist = nil
	self.Min = nil
	self.Max = nil
	self.Point = nil
	self.Acc = nil
	self.Splats = nil
	self.Spline = nil
end

function SWEP:DrawDebug()

end

function SWEP:DrawHUD()
	self:DrawDebug()
end

function SWEP:HUDShouldDraw()
	return true
end

function SWEP:Holster()
	return true
end