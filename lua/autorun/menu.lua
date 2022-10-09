AddCSLuaFile()

local function GoTo_ControlPoint(pl, cmd, arg)
	if !arg[1] then return end

	local Player_Pos = pl:GetShootPos()
	local ControlPoint_Pos = Vector(tonumber(arg[1]), tonumber(arg[2]), tonumber(arg[3]))

	local Ang = (ControlPoint_Pos-Player_Pos):Angle()

	pl:SetEyeAngles(Ang)
end
concommand.Add("GoTo_ControlPoint", GoTo_ControlPoint)





local s = SysTime()
for i=1, 1000 do
	LerpVector(0.5, Vector(100000, 100000, 100000), Vector(-100000, -100000, -100000))
	LerpVector(0.5, Vector(100000, 100000, 100000), Vector(-100000, -100000, -100000))
	LerpVector(0.5, Vector(100000, 100000, 100000), Vector(-100000, -100000, -100000))
	LerpVector(0.5, Vector(100000, 100000, 100000), Vector(-100000, -100000, -100000))
	LerpVector(0.5, Vector(100000, 100000, 100000), Vector(-100000, -100000, -100000))
end
local e = SysTime()
print(e-s)





local s = SysTime()
for i=1, 1000 do

		local n = 2
		local t = 0.5

		local function N_Factorial(n)
			local sum = n
			for i=1, n-1 do
				sum = sum*(n-i)
			end
			return sum
		end

		local tbl = {Vector(100000, 100000, 100000), Vector(-100000, -100000, -100000), Vector(-100000, -100000, 100000)}
		local WeightedSum = Vector()
		for i=0, n do --(Bernstein-Bezier Form)
			local Fraction = N_Factorial(n) / ( N_Factorial(i) * N_Factorial(n-i) )
			if Fraction == math.huge then Fraction = 1 end
			local weight = Fraction * math.pow(t, i) * math.pow( 1-t, (n-i) )

			WeightedSum = WeightedSum + (tbl[i+1] * weight)
		end
		--print(WeightedSum)

end
local e = SysTime()
print("m "..e-s)








if SERVER then return end

local function BuildSplineViewer()
	SplineViewer = vgui.Create( "DFrame" )
	SplineViewer:SetPos( 5, 5 )
	SplineViewer:SetSize( 700, 500 )
	SplineViewer:SetTitle( "Spline Viewer" )
	SplineViewer:SetVisible( true )
	SplineViewer:SetDraggable( true )
	SplineViewer:ShowCloseButton( true )
	SplineViewer:MakePopup()

	local ActiveSpline = nil
	local Should_RenderStuff = false
	local DebugRenderSpline = function()
		if SplineViewer.ShouldRenderPanel then
			Should_RenderStuff = SplineViewer.ShouldRenderPanel:GetChecked()
		end

		if !Should_RenderStuff then return end
		--3D RENDERING CONTEXT AFTER THIS POINT--
		render.SetColorMaterial()



		if !ActiveSpline then 
			--Check before death.
			if !SplineViewer then return end
			if !SplineViewer.SplineColumn then return end
			if !SplineViewer.SplineColumn:GetSelectedItem() then return end
			ActiveSpline = Splines:GetAll()[SplineViewer.SplineColumn:GetSelectedItem().SplineID]
			return
		end
	
		local ControlPoints = ActiveSpline.ControlPoints
		local Precision = #ControlPoints
		local t_frac = 1 / Precision

		local AllSplinePos = {}
		for i=1, Precision do
			local spline_pos = ActiveSpline:CalcSplinePos(i*t_frac)
			table.insert(AllSplinePos, spline_pos)
		end

		render.DrawSphere(self.ControlPoints[i], 6, 16, 16, color_white)

		for k, v in pairs(AllSplinePos) do

			local ToVec = AllSplinePos[k+1]
			if k == #AllSplinePos then
				ToVec = AllSplinePos[1]
			end

			render.DrawLine( v, ToVec, Color( 255, 80, 80 ), false )
		end



	end

	SplineViewer.Think = function()

		----------------Generate Control Points list----------------
		if !SplineViewer.SplineColumn then return end
		if !SplineViewer.SplineColumn:GetSelectedItem() then Should_RenderStuff = false return end

		--SPLINE SELECTED IN COLUMN AT THIS POINT--
		Should_RenderStuff = true
		local SelectedSpline = SplineViewer.SplineColumn:GetSelectedItem()
		local ControlPoints = SelectedSpline.ControlPoints


		if !SplineViewer.ControlPointColumn then return end
		if !SplineViewer.ControlPointColumn.Active then SplineViewer.ControlPointColumn.Active = -1 end

		if SplineViewer.LastSelected == nil then SplineViewer.LastSelected = SelectedSpline.SplineID end
		if SplineViewer.ControlPointColumn.HasContent && (SplineViewer.LastSelected == SelectedSpline.SplineID) then return end

		if SplineViewer.ControlPointColumn.Active != SelectedSpline.SplineID then


			--REMOVE CONTROL POINTS TREE CURRENT CONTENT
			for _, v in ipairs( SplineViewer.ControlPointColumn:Root():GetChildNodes() ) do
				v:Remove()
			end

			--POPULATE CONTROL POINTS TREE
			for i=1, #ControlPoints do
				local point = SplineViewer.ControlPointColumn:AddNode( tostring(ControlPoints[i]) )
				point:SetIcon( "icon16/bullet_blue.png" )
				point.Vec = ControlPoints[i]
			end


			SplineViewer.ControlPointColumn.Active = SelectedSpline.SplineID
			SplineViewer.ControlPointColumn.HasContent = true
			SplineViewer.LastSelected = SelectedSpline.SplineID
		end

		----------------Generate Control Points list----------------

	end





	local Container = vgui.Create( "DPanel", SplineViewer )
	Container:SetPos(0, 25)
	Container:SetSize(120 + 280, 350)
	Container:SetBackgroundColor( Color(80, 80, 80) )




	----------------Generate Splines list----------------
	if !Splines then return end

	local NumSplines = #Splines:GetAll()


	local SplineTree = vgui.Create( "DTree", Container )
	SplineTree:SetPos(0, 0)
	SplineTree:SetSize(120, Container:GetTall())
	SplineTree.OnNodeSelected = function( selected )
		--SPLINE SELECTED IN FIRST TREE.
	end

	SplineViewer.Splines = {}
	for i=1, NumSplines do
		SplineViewer.Splines[i] = SplineTree:AddNode( "Spline #"..tostring(i) )
		SplineViewer.Splines[i]:SetIcon( "icon16/vector.png" )

		SplineViewer.Splines[i].SplineID = i
		SplineViewer.Splines[i].ControlPoints = Splines:GetAll()[i].ControlPoints
	end

	SplineViewer.SplineColumn = SplineTree
	--------------END Generate Splines list--------------




	----------------Generate Control Points list----------------
	local ControlPointsTree = vgui.Create( "DTree", Container )
	ControlPointsTree:SetPos(SplineTree:GetWide(), 0)
	ControlPointsTree:SetSize(280, Container:GetTall())
	ControlPointsTree.OnNodeSelected = function( self, selected )
		local ControlPoint_Pos = selected.Vec

		LocalPlayer():ConCommand("GoTo_ControlPoint "..tostring(ControlPoint_Pos))
	end

	SplineViewer.ControlPointColumn = ControlPointsTree
	--------------END Generate Control Points list--------------





	local SettingsContainer = vgui.Create( "DPanel", SplineViewer )
	SettingsContainer:SetPos(Container:GetWide(), 25)
	SettingsContainer:SetSize(SplineViewer:GetWide()-Container:GetWide(), 350)
	SettingsContainer:SetBackgroundColor( Color(80, 80, 80) )








	local DermaCheckbox = SettingsContainer:Add( "DCheckBoxLabel", SettingsContainer )
	DermaCheckbox:SetPos( 4, 4 )
	DermaCheckbox:SetSize(120, 25)
	DermaCheckbox:SetText("render spline [debug]")
	DermaCheckbox:SetValue( false )

	SplineViewer.ShouldRenderPanel = DermaCheckbox




	hook.Add("PostDrawOpaqueRenderables", "Spline Viewer - Render Context", DebugRenderSpline)

end


local function Command_ToggleMenu(pl, cmd, arg)
	if !SplineViewer then BuildSplineViewer() end

	if SplineViewer:IsVisible() then
		SplineViewer:Remove()
	else
		BuildSplineViewer()
	end
end
concommand.Add("ToggleMenu", Command_ToggleMenu)









--[[
	local node = dtree:AddNode( "Node One" )

	local node = dtree:AddNode( "Node Two" )
	local cnode = node:AddNode( "Node 2.1" )
	local gcnode = cnode:AddNode( "Node 2.5" )
	local cnode = node:AddNode( "Node 2.6" )
--]]