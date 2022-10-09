AddCSLuaFile()
if SERVER then return end
if !IsValid(LocalPlayer()) then return end

local meta = FindMetaTable( "Vector" )
meta.ToCircle = function(self, radius, numpoints)
	local Pos = self || Vector() --I suck.
	local Num = numpoints || 0
	local Rad = radius || 0
	local Wedge = 360/Num
	local Points = {}

	for i = 1, Num+1 do
		local angle = (i*Wedge) * math.pi / 180
		local ptx, pty = Pos.x + Rad * math.cos( angle ), Pos.y + Rad * math.sin( angle )

		table.insert(Points, Vector(ptx, pty, Pos.z))
	end

	return Points
end

Splines = 
{
	__call = function(self)
		hook.Add("PostDrawOpaqueRenderables", "Splines - Render Context", function() self:RenderContext() end)
		hook.Add("CalcView", "Splines - Player View Context", function(pl, pos, ang, fov) return self:RenderPlayerView(pl, pos, ang, fov) end)
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
		end,

		RenderPlayerView = function(self, pl, pos, ang, fov)
			return self.Active[#self.Active]:LastSpline_PlayerViewCalc(pl, pos, ang, fov)
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
				render.DrawSphere(self.ControlPoints[i], 6, 16, 16, color_white)
			end

			self:Cycle()
		end,

		Cycle = function(self)
			local TimeStep = 0.0003

			if self.t+TimeStep > 1 then
				self.t = 0
			else
				self.t = self.t+TimeStep
			end

			self.SplinePos = self:CalcSplinePos()
			render.DrawSphere(self.SplinePos, 16, 16, 16, Color(255, 80, 80))
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

		--TODO Replace, just testing. --THIS HAS CIRCLE CREATE CODE IN IT.
		AddControlPoints = function(self, num)
			local Total_ControlPoints = 2+ (num || 0)
			local S = self.ControlPoints[1]
			local E = self.ControlPoints[#self.ControlPoints]
			local Spacing = S:Distance(E)/(Total_ControlPoints-1)
			local Direction = (E-S); Direction:Normalize();

			self.ControlPoints = {}
			for _, Point in pairs(S:ToCircle(800, 128)) do --for i=0, Total_ControlPoints-1 do --(i=0, -1) we steppin back.
				table.insert(self.ControlPoints, Point)
			end
		end,

		--TODO Replace, just testing.
		Randomize_MiddleControlPoints = function(self)
			for i=2, #self.ControlPoints-2 do
				self.ControlPoints[i] = self.ControlPoints[i] + Vector(math.random(-50, 50), math.random(-50, 50), math.random(-512, 2500))
			end
		end,

		--TODO Replace, just testing.
		Randomize_AllControlPoints = function(self, num)
			local range = num || math.random(1, 128)
			for k, v in pairs(self.ControlPoints) do
				if math.random(1, 2) == 1 then
				self.ControlPoints[k] = v + Vector(math.random(0, range), math.random(0, range), math.random(0, range+3000))
				end
			end
		end,

		--TODO Replace, just testing.
		LastSpline_PlayerViewCalc = function(self, pl, pos, ang, fov)
			if !pl.PUTMEONTHERIDE then return end
			if !self.SplinePos then return end

				local ThePartySpot = self.SplinePos

				local view = {
					origin = ThePartySpot,
					angles = angles,
					fov = fov,
					drawviewer = true
				}

			return view
		end

	}
}

setmetatable(Splines, Splines)
Splines()








------------TESTING------------
if !IsValid(LocalPlayer()) then return end





local function New_RoundTrack()
	local tr = LocalPlayer():GetEyeTraceNoCursor()
	local pos = LocalPlayer():GetPos()

	local StartPos = pos + (tr.HitPos-pos):GetNormal()*1 + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*-256 + Vector(0, 0, 32)
	local EndPos = StartPos + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*128

	local spline = Splines:New( { StartPos, EndPos } )
	spline:AddControlPoints(128)
	spline:Randomize_AllControlPoints(512)

end

New_RoundTrack()







local function ToggleRide(pl, cmd, arg)
	pl.PUTMEONTHERIDE = !pl.PUTMEONTHERIDE
end
concommand.Add("ToggleRide", ToggleRide)

----------END TESTING----------







--[[
for i=1, 0 do
	local StartPos = pos + (tr.HitPos-pos):GetNormal()*64 + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*-64 + Vector(0, 0, 32) + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*128*i
	local EndPos = StartPos + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*128

	local spline = Splines:New( { StartPos, EndPos } )
	spline:AddControlPoints(math.random(0, 9))
	spline:Randomize_MiddleControlPoints()
end

for i=1, 0 do
	local StartPos = pos + (tr.HitPos-pos):GetNormal()*(128+i*24) + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*-64 + Vector(0, 0, 32)
	local EndPos = StartPos + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*128

	local spline = Splines:New( { StartPos, EndPos } )
	spline:AddControlPoints(math.random(0, 9))
	spline:Randomize_MiddleControlPoints()
end

for i=1, 0 do
	local StartPos = pos + (tr.HitPos-pos):GetNormal()*64 + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*-256 + Vector(0, 0, 32)
	local EndPos = StartPos + ((tr.HitPos-pos):GetNormal():Cross(Vector(0, 0, 1)))*128

	local spline = Splines:New( { StartPos+Vector(0, 0, 512), EndPos+Vector(0, 0, 512) } )
	spline:AddControlPoints(math.random(0, 9))
	spline:Randomize_MiddleControlPoints()
end
--]]