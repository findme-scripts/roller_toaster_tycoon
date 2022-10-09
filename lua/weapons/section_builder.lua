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



SWEP.Initialize = function()

end

SWEP.PrimaryAttack = function()
	self:SetNextPrimaryFire( CurTime() + 0.3 )
end

SWEP.SecondaryAttack = function()
	self:SetNextSecondaryFire( CurTime() + 0.3 )
end

SWEP.Reload = function()

end

SWEP.HUDShouldDraw = function()
	return false
end

SWEP.Holster = function()

end