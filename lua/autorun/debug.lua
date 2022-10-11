AddCSLuaFile()

if SERVER then return end

local DebugMeta = {}
function DebugMeta:__call()
	self:InitializeVariables()
	self:InitializeHooks()
end


local DebugMethods = {}
function DebugMethods:InitializeHooks()
	hook.Add("PostDrawOpaqueRenderables", "Debug - 3D Render Context", function()
		if !IsValid(self) then hook.Remove("PostDrawOpaqueRenderables", "Debug - 3D Render Context") return end
		self:RenderContext()
	end)

	hook.Add("HUDPaint", "Debug - 2D Draw Context", function()
		if !IsValid(self) then hook.Remove("HUDPaint", "Debug - 2D Draw Context") return end
		self:DrawContext()
	end)
end

function DebugMethods:InitializeVariables()
	self.Points = {}
	self.ActiveRenders = {}
	self.ActiveDrawings = {}
end

function DebugMethods:Point(key, vec, args) --Debug:Point( name, vector, {{3D_Render_Arguments}, {}} )
	if self.Points[key] then
		self.Points[key][1] = vec
	else
		self.Points[key] = {}
		self.Points[key][1] = vec

		if args then
			if args[1] then --3D Render Arguments
				self.Points[key][2] = {}

				self.Points[key][2][1] = args[1][1] --Radius
				self.Points[key][2][2] = args[1][2] --Rows
				self.Points[key][2][3] = args[1][3] --Columns
				self.Points[key][2][4] = args[1][4] --Color

				self.ActiveRenders[key] = self.Points[key]
			end

			if args[2] then --2D HUD Draw Arguments
				self.Points[key][3] = {}

				self.Points[key][3][1] = args[2][1] --Font
				self.Points[key][3][2] = args[2][2] --X
				self.Points[key][3][3] = args[2][3] --Y
				self.Points[key][3][4] = args[2][4] --Color

				self.ActiveDrawings[key] = self.Points[key]
			end
		end
	end

	return self.Points[key]
end

function DebugMethods:IsValid()
	return true
end

function DebugMethods:RenderContext()
	render.SetColorMaterial()

	for k, v in pairs(self.ActiveRenders) do
		render.DrawSphere(v[1], v[2][1], v[2][2], v[2][3], v[2][4])
	end
end

function DebugMethods:DrawContext()
	for k, v in pairs(self.ActiveDrawings) do
		draw.SimpleText( tostring(k)..": "..tostring(v[1]), v[3][1], v[3][2], v[3][3], v[3][4] )
	end
end
DebugMeta.__index = DebugMethods

Debug = {}
setmetatable(Debug, DebugMeta)
Debug()










if !IsValid(LocalPlayer()) then return end

hook.Add("Think", "test_reference", function()
	local tr = LocalPlayer():GetEyeTraceNoCursor()

	Debug:Point("HitPos", tr.HitPos, {{1, 16, 16, color_white}, {"DermaDefault", 15, 15, color_white}})
end)