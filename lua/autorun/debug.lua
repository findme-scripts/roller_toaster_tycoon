AddCSLuaFile()

if SERVER then return end

local DebugMeta = {}
function DebugMeta:__call()
	self:InitializeVariables()
	self:InitializeHooks()
end


local DebugMethods = {}
function DebugMethods:Remove()
	self = nil
end

function DebugMethods:IsValid()
	return true
end

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
	self.Positions = {}
	self.Directions = {}
	self.Lengths = {}

	self.ActiveRenders = {}
	self.ActiveDrawings = {}
end

function DebugMethods:Position(key, vec, args) --Debug:Position( name, vector, {{3D_Render_Arguments}, {Draw_Arguments}} )
	if self.Positions[key] then
		self.Positions[key][1] = vec
	else
		self.Positions[key] = {}
		self.Positions[key][1] = vec

		if args then
			if args[1] then --3D Render Arguments
				self.Positions[key][2] = {}

				self.Positions[key][2][1] = args[1][1] --Radius
				self.Positions[key][2][2] = args[1][2] --Rows
				self.Positions[key][2][3] = args[1][3] --Columns
				self.Positions[key][2][4] = args[1][4] --Color

				self.ActiveRenders[key] = self.Positions[key]
			end

			if args[2] then --2D HUD Draw Arguments
				self.Positions[key][3] = {}

				self.Positions[key][3][1] = args[2][1] --Font
				self.Positions[key][3][2] = args[2][2] --X
				self.Positions[key][3][3] = args[2][3] --Y
				self.Positions[key][3][4] = args[2][4] --Color

				self.ActiveDrawings[key] = self.Positions[key]
			end
		end
	end

	return self.Positions[key]
end

function DebugMethods:Direction(key, vec1, vec2, args) --Debug:Direction( name, vector1, vector2, {{3D_Render_Arguments}, {Draw_Arguments}} )
	if self.Directions[key] then
		self.Directions[key][1] = vec1
		self.Directions[key][2] = vec2
	else
		self.Directions[key] = {}
		self.Directions[key][1] = vec1
		self.Directions[key][2] = vec2

		if args then
			if args[1] then --3D Render Arguments
				self.Directions[key][3] = {}

				self.Directions[key][3][1] = args[1][1] --Color
				self.Directions[key][3][2] = args[1][2] --DrawZ

				self.ActiveRenders[key] = self.Directions[key]
			end

			if args[2] then --2D HUD Draw Arguments
				self.Directions[key][4] = {}

				self.Directions[key][4][1] = args[2][1] --Font
				self.Directions[key][4][2] = args[2][2] --X
				self.Directions[key][4][3] = args[2][3] --Y
				self.Directions[key][4][4] = args[2][4] --Color

				self.ActiveDrawings[key] = self.Directions[key]
			end
		end
	end

	return self.Directions[key]
end

function DebugMethods:Length(key, vec1, vec2, args) --Debug:Length( name, vector1, vector2, {{3D_Render_Arguments}, {Draw_Arguments}} )
	if self.Lengths[key] then
		self.Lengths[key][1] = vec1
		self.Lengths[key][2] = vec2
	else
		self.Lengths[key] = {}
		self.Lengths[key][1] = vec1
		self.Lengths[key][2] = vec2

		if args then
			if args[1] then --3D Render Arguments
				self.Lengths[key][3] = {}

				self.Lengths[key][3][1] = args[1][1] --Color
				self.Lengths[key][3][2] = args[1][2] --DrawZ

				self.ActiveRenders[key] = self.Lengths[key]
			end

			if args[2] then --2D HUD Draw Arguments
				self.Lengths[key][4] = {}

				self.Lengths[key][4][1] = args[2][1] --Font
				self.Lengths[key][4][2] = args[2][2] --X
				self.Lengths[key][4][3] = args[2][3] --Y
				self.Lengths[key][4][4] = args[2][4] --Color

				self.ActiveDrawings[key] = self.Lengths[key]
			end
		end
	end

	return self.Lengths[key]
end

function DebugMethods:IsValid()
	return true
end

function DebugMethods:RenderContext()
	render.SetColorMaterial()

	for k, v in pairs(self.ActiveRenders) do
		if type(v[2]) == "Vector" then --hmmm..
			render.DrawLine(v[1], v[2], v[3][1], v[3][2])
		else
			render.DrawSphere(v[1], v[2][1], v[2][2], v[2][3], v[2][4])
			render.DrawLine(v[1], v[1]+v[1]:GetNormal()*v[2][1]*2, color_black, false)
		end
	end
end

function DebugMethods:DrawContext()
	for k, v in pairs(self.ActiveDrawings) do
		if type(v[2]) == "Vector" then --hmmm..
			draw.SimpleText( tostring(k)..": "..tostring(v[1]), v[4][1], v[4][2], v[4][3], v[4][4] )
		else
			draw.SimpleText( tostring(k)..": "..tostring(v[1]), v[3][1], v[3][2], v[3][3], v[3][4] )
		end
	end
end
DebugMeta.__index = DebugMethods










if !IsValid(Debug) then
	Debug = {}
	setmetatable(Debug, DebugMeta)
	Debug()
else
	Debug:Remove() --TESTING, WILL REMOVE DEBUG FOR OTHER STUFF ON RELOAD.

	Debug = {}
	setmetatable(Debug, DebugMeta)
	Debug()
end











if !IsValid(LocalPlayer()) then return end

hook.Add("Think", "test_reference", function()
	local tr = LocalPlayer():GetEyeTraceNoCursor()

	Debug:Position("HitPos", tr.HitPos, {{1, 16, 16, color_white}, {"DermaDefault", 15, 15, color_white}})

	local forward = (tr.HitPos + (tr.HitPos-LocalPlayer():GetPos()):GetNormal()*10)
	Debug:Direction("Forward", tr.HitPos, forward, {{color_black, false}, {"DermaDefault", 15, 35, color_white}})
	Debug:Length("Up", tr.HitPos, tr.HitPos + Vector(0, 0, 5), {{Color(255, 80, 80), false}, {"DermaDefault", 15, 55, color_white}})
end)