AddCSLuaFile()

SWEP.PrintName = "Section Builder"
SWEP.Author = "find me"
SWEP.Purpose = "Troller Toasters"
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.Spawnable = true
SWEP.ViewModel = Model( "models/weapons/c_toolgun.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_toolgun.mdl" )
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = falses
SWEP.Secondary.Ammo = "none"
SWEP.Category = "Roller Toaster Tycoon"

if SERVER then return end

---------------------------------------------------------------------------------



SWEP.Initialize = function(self)
	if !Splines then include("autorun/splines.lua") end --am i really dumb or really smart.

	self.Sections = {}
	self.Corners = {}
	self.DrawPoints = {}

	hook.Add("PostDrawOpaqueRenderables", "Section Builder - Render Context", function() if !IsValid(self) then return end self:RenderContext() end)
	--hook.Add("CalcView", "Section Builder - Player View Context", function(pl, pos, ang, fov) if !IsValid(self) then return end self:Calc(pl, pos, ang, fov) end)
end

--[[
hook.Add("CalcView", "Section Builder - Playefefer View Context", function(pl, pos, ang, fov)

		local p = STUPIDDDDD || pos
print("fewdd")
		local view = {
			origin = p,
			angles = angles,
			fov = fov,
			drawviewer = true
		}

	return view
end)--]]


SWEP.RenderContext = function(self)
	if #self.DrawPoints == 0 then return end

	for k, v in pairs(self.DrawPoints) do

		for _, S in pairs(v) do

			local E = v[_+1]
			if _ != #v then
				render.DrawBeam( S, E, 1, 0, 0.5, Color( 255, 80, 80 ))
			end
render.DrawSphere(S, 1, 16, 16, color_white)
		end

	end




	--THICK BLOC OF INTELLIGENCE - uncomment code block above to auto ride the spline.
	if !self.T then self.T = 0 end
	self.T = self.T + 1
	if self.T > 0.1/FrameTime() then
		self.T = 0
	if !self.TestLast then self.TestLast = 0 end
	self.TestLast = self.TestLast + 1
	if self.TestLast > #self.DrawPoints[1] then self.TestLast = 1 end
	STUPIDDDDD = self.DrawPoints[1][self.TestLast]
	end
	if STUPIDDDDD then
		render.DrawSphere(STUPIDDDDD, 1, 16, 16, color_white)
	end






end

SWEP.BezierAllCorners = function(self)
	for i=1, #self.Sections do
		if self.Sections[i+1] then
			local spline = Splines:New( { self.Sections[i]:CalcSplinePos(0.95), self.Sections[i]:CalcSplinePos(0.99), self.Sections[i+1]:CalcSplinePos(0.01), self.Sections[i+1]:CalcSplinePos(0.05) } )
			spline.DebugRender = true
			table.insert(self.Corners, spline)
		end
	end
end

SWEP.PrimaryAttack = function(self)
	if !IsFirstTimePredicted() then return end
	local tr = self:GetOwner():GetEyeTraceNoCursor()

	if self.LastStart then
		local spline = Splines:New( { self.LastStart, tr.HitPos } )
		spline:AddControlPoints(4)
		spline:Randomize_MiddleControlPoints()
		spline.DebugRender = true
		table.insert(self.Sections, spline)
	end

	self.LastStart = tr.HitPos
	self.Cornered = false

end

SWEP.SecondaryAttack = function(self)
	if !IsFirstTimePredicted() then return end

	self.LastStart = nil

	if !self.Cornered then
		self.Cornered = true
		self:BezierAllCorners()
	end

end

SWEP.FixTables = function(self)
	self.CombinedSplines = {}
	for i=1, #self.Sections do
		table.insert(self.CombinedSplines, self.Sections[i])
		if self.Corners[i] then
			table.insert(self.CombinedSplines, self.Corners[i])
		end
	end

	if #self.Corners > #self.Sections then --Add the last corner, probably don't need.
		table.insert(self.CombinedSplines, self.Corners[#self.Corners])
	end
end

SWEP.CalcCombinedSplines = function(self)

	local DrawPoints = {}
	for i=1, #self.CombinedSplines do --Starts with section, then corner, ect.
		if (i%2) != 0 then
			local spline = self.CombinedSplines[i]
			local Num_DrawPoints = #spline.ControlPoints*3
			local t_frac = 0.9 / Num_DrawPoints --0.6

			local AllSplinePos = {}
			for i=0, Num_DrawPoints do
				local spline_pos = spline:CalcSplinePos(i*t_frac+0.05) --0.2
				table.insert(DrawPoints, spline_pos)
			end
		else
			local spline = self.CombinedSplines[i]
			local Num_DrawPoints = #spline.ControlPoints*3
			local t_frac = 1 / Num_DrawPoints

			local AllSplinePos = {}
			for i=0, Num_DrawPoints do
				local spline_pos = spline:CalcSplinePos(i*t_frac)
				table.insert(DrawPoints, spline_pos)
			end
		end
	end

	table.insert(self.DrawPoints, DrawPoints)

end

SWEP.RemoveAllSplines = function(self)
	for i=1, #self.Sections do
		self.Sections[i].DebugRender = false
		self.Sections[i]:Remove()
	end
	for i=1, #self.Corners do
		self.Corners[i].DebugRender = false
		self.Corners[i]:Remove()
	end
	for i=1, #self.CombinedSplines do
		self.CombinedSplines[i].DebugRender = false
		self.CombinedSplines[i]:Remove()
	end
end

SWEP.Reload = function(self)
	self:FixTables()
	self:CalcCombinedSplines()

	self.LastStart = nil
	self.Cornered = false
	self:RemoveAllSplines()
	self.CombinedSplines = {}
	self.Sections = {}
	self.Corners = {}
end

SWEP.HUDShouldDraw = function(self)
	return true
end

SWEP.Holster = function(self)
	return true
end