AddCSLuaFile()

include("autorun/gmod-spline/spline.lua")

SWEP.PrintName = "Track Builder"
SWEP.Author = "find me"
SWEP.Purpose = "Build cool roller toasters."
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
SWEP.Category = "find me"
SWEP.ClassName = "track_builder"

local DenySound = Sound( "common/wpn_denyselect.wav" )
local SuccessSound = Sound( "common/bugreporter_succeeded.wav" )

local S = Vector()
local E = Vector()
local Drawing = false
local MaxExtension = 256


if CLIENT then

	function SWEP:ToolEffects()
		local tr = self.Owner:GetEyeTraceNoCursor()
		local HitPos = self.Owner:GetEyeTraceNoCursor().HitPos

		local RenderColor = Color(255, 70, 70)
		if tr.HitWorld then
			RenderColor = Color(255, 180, 0)
		end

		if !Drawing then
			--Always Active Indicator
			render.SetColorMaterial()
			render.DrawSphere( HitPos, 24, 8, 8, RenderColor)
		else
			--StartPos Indicator
			render.SetColorMaterial()
			render.DrawSphere( S, 8, 8, 8, Color(255, 180, 0))

			--EndPos Indicator
			render.SetColorMaterial()
			render.DrawSphere( HitPos, 24, 8, 8, RenderColor)
		end

		self:DrawSpline()

	end

	function SWEP:Fail(pos)
		if ( IsFirstTimePredicted() ) then
			sound.Play( DenySound, self.Owner:GetPos(), 75, 100, 1 )

			local effect = EffectData()
			effect:SetOrigin( pos )
			util.Effect( "ManhackSparks", effect)
		end

		return
	end

	function SWEP:Success()
		if ( IsFirstTimePredicted() ) then
			sound.Play( SuccessSound, self.Owner:GetPos(), 75, 100, 1 )

			local effect = EffectData()
			effect:SetOrigin( E )
			util.Effect( "HL1GaussWallPunchEnter", effect)

			local effect = EffectData()
			effect:SetOrigin( S )
			util.Effect( "HL1GaussWallPunchEnter", effect)
		end

		return
	end

end

function SWEP:Initialize()

	if CLIENT then
		self:GetOwner():DrawViewModel(false)

		local me = self
		hook.Add("PostDrawOpaqueRenderables", "I suck", function() me:ToolEffects() end)
		hook.Add("StartCommand", "eggs", function(pl, cmd) me:PlayerInput(pl, cmd) end)

		self.Audio = CreateSound(self, "ambient/atmosphere/city_rumble_loop1.wav")
	end

end

function SWEP:PrimaryAttack()

	if CLIENT then

		local tr = self.Owner:GetEyeTraceNoCursor()
		if !tr.HitWorld then self:Fail(tr.HitPos) return end

		if !Drawing then
			self:NewDrawing(tr)
		else
			self:ContinueDrawing(tr)
		end

	else
		self:SetNextPrimaryFire( CurTime() + 0.3 )
	end

end

function SWEP:NewDrawing(tr)
	if Drawing then return end

	self.ControlPoints = {}
	S = tr.HitPos
	table.insert(self.ControlPoints, S)
	table.insert(self.ControlPoints, S)

	Drawing = true
	self.Audio:Play()
	self.Audio:ChangePitch(60, 0)
	self.Audio:SetDSP(5)

	self:BuildSpline()
end

function SWEP:ContinueDrawing(tr)
	if !Drawing then return end

	LastPoint = tr.HitPos
	table.insert(self.ControlPoints, LastPoint)

	self:RebuildSpline()

end

function SWEP:FinishDrawing()
	if !Drawing then return end

	E = LastPoint
	Drawing = false
	self.Audio:Stop()
	self:Success()

end

function SWEP:BuildSpline()
	if !self.Splines then self.Splines = {} end

	local spline = CreateSpline(S, E)
	spline.ControlPoints = self.ControlPoints
	spline:Calc_Spline()
	spline.CycleIncrement = 1/( (1/FrameTime()) * #self.ControlPoints)

	table.insert(self.Splines, spline)
end

function SWEP:RebuildSpline()
	local CurrentSpline = self.Splines[#self.Splines]

	CurrentSpline.ControlPoints = self.ControlPoints
	CurrentSpline:Calc_Spline()
	CurrentSpline.CycleIncrement = 1/( (1/FrameTime()) * #self.ControlPoints)
end

function SWEP:DrawSpline()
	if !self.Splines then return end

	for k, v in pairs(self.Splines) do
		local points = self.ControlPoints
		local tr = LocalPlayer():GetEyeTraceNoCursor()
		if #v.ControlPoints == 1 then
			table.insert(v.ControlPoints, tr.HitPos)
			self.faking = true
		end

		for l, b in pairs(v.ControlPoints) do
			render.SetColorMaterial()
			render.DrawSphere( b, 12, 16, 16, Color(80, 255, 80) )
		end

		v:CycleFull()

		render.SetColorMaterial()
		render.DrawSphere( v.SplinePos, 8, 16, 16, Color(80, 255, 80) )

		if #v.ControlPoints == 2 && self.faking then
			table.remove(v.ControlPoints, 2)
		end
	end
end

function SWEP:DoubleControlPoints()
	local CurrentSpline = self.Splines[#self.Splines]
	
	local NewControlPoints = {}
	for k, v in pairs(self.ControlPoints) do
		table.insert(NewControlPoints, v)
		if k != #self.ControlPoints then
			table.insert(NewControlPoints, LerpVector(0.5, v, self.ControlPoints[k+1]) )
		end
	end

	self.ControlPoints = NewControlPoints
	self:RebuildSpline()
end

function SWEP:SecondaryAttack()

	if CLIENT then

		self:DoubleControlPoints()

	else
		self:SetNextSecondaryFire( CurTime() + 0.3 )


	end

end

function SWEP:Reload()

	if CLIENT then
		self:FinishDrawing()

	else


	end

end

function SWEP:HUDShouldDraw()
	return false
end

function SWEP:PlayerInput(pl, cmd)
	if ( cmd:GetMouseWheel() != 0 ) then
		self.WheelInput = cmd:GetMouseWheel()
	end
end

function SWEP:CalcView(pl, pos, ang, fov)
	--if !self.WheelInput then return end
	if !self.LastZ then self.LastZ = 0 end

	if self.LastZ < 1 then
		pl:DrawViewModel(true, 0)
	else
		pl:DrawViewModel(false, 0)
	end

	local NewPos = pos+Vector(0, 0, math.Clamp(self.WheelInput*10+self.LastZ, 0, 1024*4))
	self.LastZ = math.Clamp(self.WheelInput*64+self.LastZ, 0, 1024*4)

	self.WheelInput = 0

	return NewPos, ang, fov
end

function SWEP:Holster()
	if CLIENT then
		Drawing = false
	end

	return true
end