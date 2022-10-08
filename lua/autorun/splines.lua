AddCSLuaFile()
if SERVER then return end

Splines = 
{
	__call = function(self)
		hook.Add("PostDrawOpaqueRenderables", "Splines - Render Context", function() self:RenderContext() end)
	end,

	__index = {
		Active = {},
		
		New = function(self, controlpoints)
			local spline = {}
			setmetatable(spline, {__call = self.__SplineCall, __index = self.__SplineIndex})
			spline(controlpoints)

			table.insert(self.Active, spline)
			spline.Key = #self.Active

			return spline
		end,

		Get = function(self, key)
			return self.Active[key]
		end,

		GetAll = function(self)
			return self.Active
		end,

		RenderContext = function(self)
			for i=1, #self.Active do
				self.Active[i]:Render()
			end
		end
	},



	__SplineCall = function(self, controlpoints)
		self.ControlPoints = controlpoints || {}
		self.t = 0
	end,

	__SplineIndex = {

		Render = function(self)
			render.SetColorMaterial()

			for i=1, #self.ControlPoints do
				render.DrawSphere(self.ControlPoints[i], 2, 16, 16, color_white)
			end

			self:Cycle()
		end,

		Cycle = function(self)
			local TimeStep = 0.001

			if self.t+TimeStep > 1 then
				self.t = 0
			else
				self.t = self.t+TimeStep
			end

			render.DrawSphere(self:CalcSplinePos(), 1, 16, 16, Color(255, 80, 80))
		end,

		CalcSplinePos = function(self, int)
			local n = #self.ControlPoints-1
			local t = int || self.t

			local function N_Factorial(n)
				local sum = n
				for i=1, n-1 do
					sum = sum*(n-i)
				end
				return sum
			end

			local WeightedSum = Vector()
			for i=0, n do --(Bernstein-Bezier Form)
				local Fraction = N_Factorial(n) / ( N_Factorial(i) * N_Factorial(n-i) )
				if Fraction == math.huge then Fraction = 1 end
				local weight = Fraction * math.pow(t, i) * math.pow( 1-t, (n-i) )

				WeightedSum = WeightedSum + (self.ControlPoints[i+1] * weight)
			end

			return WeightedSum

		end,

		--TODO Replace, just testing.
		AddControlPoints = function(self, num)
			local Total_ControlPoints = 2+ (num || 0)
			local S = self.ControlPoints[1]
			local E = self.ControlPoints[#self.ControlPoints]
			local Spacing = S:Distance(E)/(Total_ControlPoints-1)
			local Direction = (E-S); Direction:Normalize();

			self.ControlPoints = {}
			for i=0, Total_ControlPoints-1 do --(i=0, -1) we steppin back.
				table.insert(self.ControlPoints, S+Direction*i*Spacing)
			end
		end,

		--TODO Replace, just testing.
		Randomize_MiddleControlPoints = function(self)
			for i=2, #self.ControlPoints-2 do
				self.ControlPoints[i] = self.ControlPoints[i] + Vector(0, 0, math.random(-32, 32))
			end
		end

	}
}

setmetatable(Splines, Splines)
Splines()








------------TESTING------------
if !IsValid(LocalPlayer()) then return end

local tr = LocalPlayer():GetEyeTraceNoCursor()
local pos = LocalPlayer():GetPos()

for i=1, 12 do
	local StartPos = pos + (tr.HitPos-pos):GetNormal()*64 + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*-64 + Vector(0, 0, 32) + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*128*i
	local EndPos = StartPos + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*128

	local spline = Splines:New( { StartPos, EndPos } )
	spline:AddControlPoints(math.random(0, 9))
	spline:Randomize_MiddleControlPoints()
end

for i=1, 12 do
	local StartPos = pos + (tr.HitPos-pos):GetNormal()*(128+i*24) + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*-64 + Vector(0, 0, 32)
	local EndPos = StartPos + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*128

	local spline = Splines:New( { StartPos, EndPos } )
	spline:AddControlPoints(math.random(0, 9))
	spline:Randomize_MiddleControlPoints()
end

for i=1, 12 do
	local StartPos = pos + (tr.HitPos-pos):GetNormal()*64 + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*-256 + Vector(0, 0, 32)
	local EndPos = StartPos + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*128

	local spline = Splines:New( { StartPos, EndPos } )
	spline:AddControlPoints(math.random(0, 9))
	spline:Randomize_MiddleControlPoints()
end

----------END TESTING----------