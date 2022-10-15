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
end

function DebugMethods:ClearAllPositions()
	table.Empty(self.Positions)
end

function DebugMethods:PositionExists(name)
	for i=1, #self.Positions do
		if self.Positions[i][1] == name then
			return true
		end
	end

	return false
end

function DebugMethods:GetByValue(name)
	for i=1, #self.Positions do
		if self.Positions[i][1] == name then
			return i
		end
	end

	return nil
end

function DebugMethods:RenderContext()
	render.SetColorMaterial()

	for _, v in pairs(self.Positions) do
		if v[2] && v[3] then
			render.DrawSphere(v[2], v[3][1], v[3][2], v[3][3], v[3][4])
			render.DrawLine(v[2], v[2] + v[2]:GetNormal()*v[3][1]*2,  color_black, false)
		end
	end

end

function DebugMethods:DrawContext()
	for _, v in pairs(self.Positions) do
		if v[4] then
			draw.SimpleText( tostring(v[1])..": "..tostring(v[2]), v[4][1], v[4][2], v[4][3], v[4][4] )
		end
	end
end

function DebugMethods:RemovePosition(name)
	if self:PositionExists(name) then
		local index = self:GetByValue(name)
		table.remove(self.Positions, index)
	end
end

function DebugMethods:Position(name, vec, args) --Debug:Position( name, vector, {{3D_Render_Arguments}, {Draw_Arguments}} )

		local tbl = {}
		tbl[1] = name
		tbl[2] = vec
		
		if args then
			if args[1] then --3D Render Arguments
				tbl[3] = {}

				tbl[3][1] = args[1][1] --Sphere Radius
				tbl[3][2] = args[1][2] --Long Steps
				tbl[3][3] = args[1][3] --Lat Steps
				tbl[3][4] = args[1][4] --Color
			end

			if args[2] then --2D HUD Draw Arguments
				tbl[4] = {}

				tbl[4][1] = args[2][1] --Font
				tbl[4][2] = args[2][2] --X
				tbl[4][3] = args[2][3] --Y
				tbl[4][4] = args[2][4] --Color
			end
		end

	if !self:PositionExists(name) then
		table.insert(self.Positions, tbl)
	else --Existing debug position.
		local index = self:GetByValue(name)
		self.Positions[index] = tbl
	end

	return 
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










--[[
if !IsValid(LocalPlayer()) then return end

hook.Add("Think", "test_reference", function()
	local tr = LocalPlayer():GetEyeTraceNoCursor()
	Debug:Position("HitPos", tr.HitPos, {{1, 16, 16, color_white}, {"DermaDefault", 15, 15, color_white}})
end)--]]