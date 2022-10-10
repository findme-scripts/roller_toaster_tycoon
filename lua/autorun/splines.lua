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
		--hook.Add("CalcView", "Splines - Player View Context", function(pl, pos, ang, fov) return self:RenderPlayerView(pl, pos, ang, fov) end)
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

		Remove = function(self)
			Splines:GetAll()[self.Key] = nil
			table.remove(Splines.Active, self.Key)
		end,

		Render = function(self)

			render.SetColorMaterial()

			if self.DebugRender then --new

				local ControlPoints = self.ControlPoints
				local Precision = #ControlPoints*3
				local t_frac = 1 / Precision

				local AllSplinePos = {}
				for i=0, Precision do
					local spline_pos = self:CalcSplinePos(i*t_frac)
					table.insert(AllSplinePos, spline_pos)
				end

				--self:Cycle()

				for k, v in pairs(AllSplinePos) do

					local ToVec = AllSplinePos[k+1]
					if k != #AllSplinePos then
						--render.DrawLine( v, ToVec, Color( 255, 80, 80 ), false )
						render.DrawBeam( v, ToVec, 2, 0, 1, Color( 255, 80, 80 ))
					end
				end

			end


			for i=1, #self.ControlPoints do
				--render.DrawSphere(self.ControlPoints[i], 0.5, 8, 8, Color( 80, 80, 255 ))
			end


			self:Cycle()

		end,

		Cycle = function(self)
			local TimeStep = 0.0008

			if self.t+TimeStep > 1 then
				self.t = 0
			else
				self.t = self.t+TimeStep
			end

			self.SplinePos = self:CalcSplinePos()
			--render.DrawSphere(self.SplinePos, 1, 16, 16, Color(80, 255, 80))
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
			for i=2, #self.ControlPoints-1 do
				self.ControlPoints[i] = self.ControlPoints[i] + Vector(math.random(-60, 60), math.random(-60, 60), math.random(0, 120))
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
	--spline:Randomize_AllControlPoints(512)

end

New_RoundTrack()




local function CopyLast(pl, cmd, arg)
	local New_Controls = {}
	for i=0, 3 do
		print(i)
		local spline = Splines:GetAll()[#Splines:GetAll() - (3-i)]

		for k, v in pairs(spline.ControlPoints) do
			table.insert(New_Controls, v)
		end

	end
	local spline = Splines:New(New_Controls)
end
concommand.Add("copy_track", CopyLast)


local function ToggleRide(pl, cmd, arg)
	pl.PUTMEONTHERIDE = !pl.PUTMEONTHERIDE
end
concommand.Add("ToggleRide", ToggleRide)

----------END TESTING----------

