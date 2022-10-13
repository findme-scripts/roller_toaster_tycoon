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
	self.Variables[3] = nil --Active Position
	self.Variables[4] = nil --End Position
	self.Variables[5] = nil --Middle Position
	self.Variables[6] = nil --Mins
	self.Variables[7] = nil --Maxs
end

function SWEP:Set(index, content)
	self.Variables[index] = content
end

function SWEP:Get(index)
	return self.Variables[index]
end

function SWEP:RenderContext()
	local CurrentStage = self:Get(1)

	if CurrentStage == 1 then
		self:Set(3, self:GetOwner():GetEyeTraceNoCursor().HitPos) --Active Position
		Debug:Position("Active", self:Get(3), {{1, 16, 16, color_white}, {"DermaDefault", 15, 30, color_white}})

		self:CalculateLocals(self:Get(2), self:Get(3))
		render.DrawWireframeBox( (self:Get(2)+self:Get(3))*0.5, Angle(0, 0, 0), self:Get(6), self:Get(7), color_white, false )
	elseif CurrentStage == 2 then
		render.DrawWireframeBox( self:Get(5), Angle(0, 0, 0), self:Get(6), self:Get(7), color_white, false )
	end
end

function SWEP:CalculateLocals(pos1, pos2)
	local mid = (pos1-pos2)*0.5
	local x, y, z = math.abs(mid.x), math.abs(mid.y), math.abs(mid.z)

	self:Set(6, Vector(-x, -y, -z)) --Mins
	Debug:Position("Mins", mid + self:Get(6), {{1, 16, 16, color_black}, {"DermaDefault", 15, 85, color_white}})
	self:Set(7, Vector(x, y, z)) --Maxs
	Debug:Position("Maxs", mid + self:Get(7), {{1, 16, 16, color_black}, {"DermaDefault", 15, 100, color_white}})
	
end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() then return end
	local tr = self:GetOwner():GetEyeTraceNoCursor()
	local CurrentStage = self:Get(1)

	if CurrentStage == 0 then --place start, modify existing

		local StartPos = self:Get(2)
		if !StartPos then
			self:Set(2, tr.HitPos)	--Start Position
			Debug:Position("Start", self:Get(2), {{1, 16, 16, color_white}, {"DermaDefault", 15, 15, color_white}})
			self:Set(1, 1) --Set Current Stage to 1
		end

	elseif CurrentStage == 1 then

		local EndPos = self:Get(4)
		if !EndPos then
			self:Set(4, tr.HitPos)	--End Position
			Debug:Position("End", self:Get(4), {{1, 16, 16, color_white}, {"DermaDefault", 15, 45, color_white}})
			Debug:RemovePosition("Active")

			self:Set(5, (self:Get(2)+self:Get(4))/2) --Middle Position
			Debug:Position("Middle", self:Get(5), {{1, 16, 16, color_white}, {"DermaDefault", 15, 60, color_white}})

			self:CalculateLocals(self:Get(2), self:Get(4))

			self:Set(1, 2) --Set Current Stage to 2
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