AddCSLuaFile()
if SERVER then return end

local function BuildSplineViewer()
	SplineViewer = vgui.Create( "DFrame" )
	SplineViewer:SetPos( 5, 5 ) 
	SplineViewer:SetSize( 300, 150 ) 
	SplineViewer:SetTitle( "Spline Viewer" ) 
	SplineViewer:SetVisible( true ) 
	SplineViewer:SetDraggable( true ) 
	SplineViewer:ShowCloseButton( true ) 
	SplineViewer:MakePopup()
end


local function Command_ToggleMenu(pl, cmd, arg)
	if !SplineViewer then BuildSplineViewer() end

	if SplineViewer:IsVisible() then
		SplineViewer = nil
	else
		BuildSplineViewer()
	end
end
concommand.Add("ToggleMenu", Command_ToggleMenu)