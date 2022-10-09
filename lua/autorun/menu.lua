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

	SplineViewer.Think = function()

		----------------Generate Control Points list----------------
		if !SplineViewer.SplineColumn then return end
		if !SplineViewer.SplineColumn:GetSelectedItem() then return end

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
	--Container:SetPaintBackgroundEnabled( true )
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
	ControlPointsTree.OnNodeSelected = function( selected )
		--CONTROL POINT SELECTED IN SECOND TREE
	end

	SplineViewer.ControlPointColumn = ControlPointsTree
	--------------END Generate Control Points list--------------




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