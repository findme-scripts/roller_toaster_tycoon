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
		print("Setting up new spline.")
		self.ControlPoints = controlpoints || {}
		self.t = 0
		self.SplinePos = Vector()
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

		end

--[[

local function N_Factorial(n)
	local sum = n
	for i=1, n-1 do
		sum = sum*(n-i)
	end
	return sum
end

--]]

		--[[Add = function(self)
			local Total_ControlPoints = self.NumCP+2
			local Spacing = self.SP:Distance(self.EP)/(Total_ControlPoints-1)
			local Direction = (self.EP-self.SP); Direction:Normalize();

			for i=0, Total_ControlPoints-1 do --(i=0, -1) we steppin back.
				table.insert(self.ControlPoints, self.SP+Direction*i*Spacing)
			end
		end

		Calc_Spline = function(self)
			local n = #self.ControlPoints-1
			local t = self.t

			local WeightedSum = Vector()
			for i=0, n do --(Bernstein-Bezier Form)
				local Derive = N_Factorial(n) / ( N_Factorial(i) * N_Factorial(n-i) )
				if Derive == math.huge then Derive = 1 end

				local weight = Derive * math.pow(t, i) * math.pow( 1-t, (n-i) )

				WeightedSum = WeightedSum + (self.ControlPoints[i+1] * weight)
			end
					
			self.SplinePos = WeightedSum
		end--]]
	}
}

setmetatable(Splines, Splines)
Splines()








------------TESTING------------
if !IsValid(LocalPlayer()) then return end

local tr = LocalPlayer():GetEyeTraceNoCursor()
local pos = LocalPlayer():GetPos()

for i=1, 12 do
	local StartPos = pos + (tr.HitPos-pos):GetNormal()*(64+i*12) + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*-64 + Vector(0, 0, 32)
	local EndPos = StartPos + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*128

	local spline = Splines:New( { StartPos, EndPos } )
end

----------END TESTING----------