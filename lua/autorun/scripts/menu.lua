AddCSLuaFile()
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

		--if !Should_RenderStuff then return end
		--3D RENDERING CONTEXT AFTER THIS POINT--
		--render.SetColorMaterial() --this is all really bad



		if !ActiveSpline then 
			--Check before death.
			if !SplineViewer then return end
			if !SplineViewer.SplineColumn then return end
			if !SplineViewer.SplineColumn:GetSelectedItem() then return end
			ActiveSpline = Splines:GetAll()[SplineViewer.SplineColumn:GetSelectedItem().SplineID]
			return
		else
			--Deselected & changed item.
			if !SplineViewer then return end
			if !SplineViewer.SplineColumn then return end
			if !SplineViewer.SplineColumn:GetSelectedItem() then return end
			if ActiveSpline != Splines:GetAll()[SplineViewer.SplineColumn:GetSelectedItem().SplineID] then
				ActiveSpline = Splines:GetAll()[SplineViewer.SplineColumn:GetSelectedItem().SplineID]
			end
		end

		if ActiveSpline.DebugRender != Should_RenderStuff then --messyyyyy
			ActiveSpline.DebugRender = Should_RenderStuff
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
	if !SplineViewer then BuildSplineViewer() return end

	if SplineViewer:IsVisible() then
		SplineViewer:Remove()
	else
		BuildSplineViewer()
	end
end
concommand.Add("ToggleMenu", Command_ToggleMenu)






--[[
local function GoTo_ControlPoint(pl, cmd, arg)
	if !arg[1] then return end

	local Player_Pos = pl:GetShootPos()
	local ControlPoint_Pos = Vector(tonumber(arg[1]), tonumber(arg[2]), tonumber(arg[3]))

	local Ang = (ControlPoint_Pos-Player_Pos):Angle()

	pl:SetEyeAngles(Ang)
end
concommand.Add("GoTo_ControlPoint", GoTo_ControlPoint)--]]