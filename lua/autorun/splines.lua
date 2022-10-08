AddCSLuaFile()
if SERVER then return end

Splines = 
{
	__call = function(self)
		hook.Add("PostDrawOpaqueRenderables", "Source Spline - Render Context", function() self:RenderContext() end)
	end,

	__index = {
		Active = {},
		
		New = function(self)
			local tbl = {}
			setmetatable(tbl, {__call = self.__SplineCall, __index = self.__SplineIndex})

			table.insert(self.Active, tbl)
			tbl.Key = #self.Active

			return tbl
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



	__SplineCall = function(self)
		print("Setting up new spline.")
		self.Start = Vector()
	end,

	__SplineIndex = {
		Key = 0,

		Render = function(self)
			render.SetColorMaterial()
			render.DrawSphere(self.Start, 2, 16, 16, color_white)
		end
	}
}

setmetatable(Splines, Splines)
Splines()








------------TESTING------------

for i=1, 12 do
	local spline = Splines:New()
	spline.Start = LocalPlayer():GetPos() + Vector(0, 0, math.random(4, 64))
end

local Random_Spline = Splines:GetAll()[ math.random( 1, #Splines:GetAll() ) ]
print( Splines:Get( Random_Spline.Key ).Key )

----------END TESTING----------