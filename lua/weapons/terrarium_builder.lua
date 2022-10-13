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
	self:InitializeVariables()
	self:InitializeHooks()
end

function SWEP:InitializeHooks()
	hook.Add("PostDrawOpaqueRenderables", "Terrarium Builder - Render Context", function()
		if !IsValid(self) then hook.Remove("PostDrawOpaqueRenderables", "Terrarium Builder - Render Context") return end
		self:RenderContext()
	end)
end

function SWEP:InitializeVariables()
	self.Variables = {}
	self.Variables[1] = 0 --Current Stage
	self.Variables[2] = nil --Start Position
end

function SWEP:Set(index, content)
	self.Variables[index] = content
end

function SWEP:Get(index)
	return self.Variables[index]
end

function SWEP:RenderContext()

end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() then return end
	local tr = self:GetOwner():GetEyeTraceNoCursor()
	local CurrentStage = self:Get(1)

	if CurrentStage == 0 then --place start, modify existing

		local StartPos = self:Get(2)
		if !StartPos then
			self:Set(2, tr.HitPos)
			Debug:Position("Start", self:Get(2), {{1, 16, 16, color_white}, {"DermaDefault", 15, 15, color_white}})
		end

	end
end

function SWEP:SecondaryAttack()
	if !IsFirstTimePredicted() then return end

end

function SWEP:Reload()
	self:InitializeVariables()
	Debug:ClearAllPositions()
end

function SWEP:HUDShouldDraw()
	return true
end

function SWEP:Holster()
	return true
end