AddCSLuaFile()
if SERVER then return end

local meta = FindMetaTable( "Vector" )

meta.ToCircle = function(self, radius, numpoints)
	local Pos = self || Vector() --I suck.
	local Num = numpoints || 0
	local Rad = radius || 0
	local Wedge = 360/Num
	local Points = {}

	for i = 1, Num do
		local angle = (i*Wedge) * math.pi / 180
		local ptx, pty = Pos.x + Rad * math.cos( angle ), Pos.y + Rad * math.sin( angle )

		table.insert(Points, Vector(ptx, pty, Pos.z))
	end

	return Points
end

local function set_hook(tr)

	local function RenderContext(tr)
		local pos = tr.HitPos

		render.SetColorMaterial()
		render.DrawSphere(pos, 2, 16, 16, color_white)

		for _, Point in pairs(pos:ToCircle(40, 16)) do
			render.DrawSphere(Point, 2, 16, 16, color_white)
		end
		
	end

	hook.Add("PostDrawOpaqueRenderables", "Test circle", function() RenderContext(tr) end)
end




local function circle_test(pl, cmd, arg)
	local tr = pl:GetEyeTraceNoCursor()
	
	set_hook(tr)
end
concommand.Add("cir", circle_test)