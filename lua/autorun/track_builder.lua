AddCSLuaFile()

local meta_Spline =
	{
		S = Vector(),
		E = Vector(),
		CP = 1,
		ControlPoints = {}
	}

local meta_SplineManager =
	{
		Splines = {},

		CreateSpline = function(self, spline)
			table.insert(self.Splines, setmetatable(spline, meta_Spline))
		end
	}

local meta_TrackBuilder =
	{
		Thinking = false,
		Rendering = false,
		ThinkManager = function(self)
			if self.Thinking then self:Think() end
			if self.Rendering then self:Render() end
		end,
		Think = function(self)
			print("Thinking")
		end,
		Render = function(self)
			print("Rendering")
		end
	}




if CLIENT then

	----------CREATE TRACK BUILDER----------

		local TrackBuilder = setmetatable({}, { __index = meta_TrackBuilder })
		hook.Add("PostDrawOpaqueRenderables", "Track Builder - Render Context", function() TrackBuilder:ThinkManager() end)

	---------END CREATE TRACK BUILDER-------






	---------PLAYER COMMANDS---------

		local function Toggle_Rendering(pl, cmd, arg)
			TrackBuilder.Rendering = !TrackBuilder.Rendering
		end
		concommand.Add("ToggleRendering", Toggle_Rendering)

		local function Toggle_Thinking(pl, cmd, arg)
			TrackBuilder.Thinking = !TrackBuilder.Thinking
		end
		concommand.Add("ToggleThinking", Toggle_Thinking)

	--------END PLAYER COMMANDS-------

end



if SEVER then

end