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
	end,

	__SplineIndex = {

		Render = function(self)
			for i=1, #self.ControlPoints do
				render.SetColorMaterial()
				render.DrawSphere(self.ControlPoints[i], 2, 16, 16, color_white)
			end
		end

		


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

for i=1, 12 do
	local spline = Splines:New({LocalPlayer():GetPos()+Vector(0, 0, 20), LocalPlayer():GetPos()+Vector(0, 20, 20)})
	PrintTable(spline)
end

----------END TESTING----------