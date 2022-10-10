--let's call these rough drafts.

--[[
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

SWEP.LastEntry = 0






SWEP.Initialize = function(self)
	if !Splines then include("autorun/splines.lua") end --am i really dumb or really smart.

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
		elseif self.Stage == 1 then
			local tr = LocalPlayer():GetEyeTraceNoCursor()

			points[3] = Vector(tr.HitPos.x, tr.HitPos.y, points[2].z)
		elseif self.Stage > 1 then



			if self.Stage != self.LastEntry then
				self.LastEntry = self.Stage

				print("NEWWW")
				local spline = Splines:New( { points[self.Stage], LerpVector(0.3, points[self.Stage], points[self.Stage+1]), LerpVector(0.7, points[self.Stage], points[self.Stage+1]), points[self.Stage+1] } )
				spline:Randomize_MiddleControlPoints()
				--spline.DebugRender = true



				if self.LastSpline then
					self.InterPoints = {}

					table.insert(self.InterPoints, self.LastSpline:CalcSplinePos(0.8))
					table.insert(self.InterPoints, self.LastSpline:CalcSplinePos(0.99))
					table.insert(self.InterPoints, spline:CalcSplinePos(0.01))
					table.insert(self.InterPoints, spline:CalcSplinePos(0.2))

					print("INTERRR")
					local InterSpline = Splines:New( self.InterPoints )
					--InterSpline.DebugRender = true

				end		

				self.LastSpline = spline


			end

			local tr = LocalPlayer():GetEyeTraceNoCursor()
			points[2 + self.Stage] = Vector(tr.HitPos.x, tr.HitPos.y, points[1 + self.Stage].z)



		end


		for _, v in pairs(points) do
			render.DrawSphere(v, 1, 16, 16, color_white)
			if points[_+1] then
				render.DrawLine(points[_], points[_+1], color_white, false)
			end
		end

	end

	if self.NewNewPoints != nil && #self.NewNewPoints > 0 then
		--PrintTable(self.NewNewPoints)
		for k, v in pairs(self.NewNewPoints) do

			local ToVec = self.NewNewPoints[k+1]
			if k != #self.NewNewPoints then
				render.DrawLine( v, ToVec, Color( 255, 0, 0 ), false)
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
	
	if !IsFirstTimePredicted() then return end

	local tr = self:GetOwner():GetEyeTraceNoCursor()

	self.Stage = self.Stage + 1
	self:NewStage(tr)

	if self.Stage > 1 then
		if !self.TESTTotalSplines then self.TESTTotalSplines = 1 end
		self.TESTTotalSplines = self.TESTTotalSplines + 1

		if self.TestFlip then
			self.TestFlip = false

			if !self.TESTTotalSplines then self.TESTTotalSplines = 1 end
			self.TESTTotalSplines = self.TESTTotalSplines + 1
		else
			self.TestFlip = true
		end
	end

end

SWEP.SecondaryAttack = function(self)

	if !IsFirstTimePredicted() then return end

	if self.TESTTotalSplines then
		self.NewNewPoints = {}

		self.SaveTable = {}

		local SplineTbl = {}

		local TotalRealSplines = #Splines:GetAll()
		local fuckitallup = TotalRealSplines-1
		for i=1, fuckitallup do
			print(TotalRealSplines-(fuckitallup-(i-1)))
			table.insert(SplineTbl, Splines:GetAll()[TotalRealSplines-(fuckitallup-i)])
		end

		for k, v in pairs(SplineTbl) do
			print((2%k))
			if k == 1 then --kill me.

				local ControlPoints = v.ControlPoints
				local Num = (#ControlPoints-1) * 2
				local t_frac = 0.8 / Num

				local AllSplinePos = {}
				for i=0, Num do
					if i != Num-1 then
						local spline_pos = v:CalcSplinePos(i*t_frac)
						table.insert(self.NewNewPoints, spline_pos)
					end
				end

				print("Non")

			elseif (k%2) == 0 then --Should flip appropriately

				local ControlPoints = v.ControlPoints
				local Num = (#ControlPoints-1) * 2
				local t_frac = 0.6 / Num

				local AllSplinePos = {}
				for i=0, Num do
					if i != Num-1 then
						local spline_pos = v:CalcSplinePos(i*t_frac+0.2)
						if k == #SplineTbl then
							table.insert(self.NewNewPoints, spline_pos)
						else
							table.insert(self.SaveTable, spline_pos)
						end
					end
				end

				print("Non")

			else

				local ControlPoints = v.ControlPoints
				local Num = (#ControlPoints-1) * 2
				local t_frac = 1 / Num

				local AllSplinePos = {}
				for i=0, Num do
					if i != Num-1 then
						local spline_pos = v:CalcSplinePos(i*t_frac)
						table.insert(self.NewNewPoints, spline_pos)
					end
				end

				if #self.SaveTable > 0 then --come back and input previous non.
					for k, v in pairs(self.SaveTable) do
						table.insert(self.NewNewPoints, v)
					end

					self.SaveTable = {}
				end

				print("Inter")

			end
		end

		PrintTable(self.NewNewPoints)
	end


	self.Stage = -1
	self:NewStage()
	self.LastSpline = nil
end

SWEP.Reload = function(self)

end

SWEP.HUDShouldDraw = function(self)
	return true
end

SWEP.Holster = function(self)
	return true
end
--]]





























--[[
AddCSLuaFile()

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





function SWEP:Holster()
	if CLIENT then
		Drawing = false
	end

	return true
end

--]]