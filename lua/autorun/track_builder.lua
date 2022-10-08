AddCSLuaFile()

local meta_Spline =
	{
		__call = function(self)
			self.S = Vector()
			self.E = Vector()
			self.CP = 1
			self.ControlPoints = {}			
		end,

		__index = {

		}
	}

local meta_SplineManager =
	{
		__call = function(self)
			self.Splines = {}
			print("im alive")
		end,

		__index = {
			New = function(self, spline)
				table.insert(self.Splines, setmetatable(spline, meta_Spline))
			end
		}
	}

local meta_TrackBuilder =
	{
		__call = function(self)
			self.Thinking = false
			self.Rendering = false
			self.SplineManager = setmetatable({}, meta_SplineManager); self.SplineManager();
			hook.Add("PostDrawOpaqueRenderables", "Track Builder - Render Context", function() self:ThinkManager() end)
		end,

		__index = {
			ThinkManager = function(self)
				if self.Thinking then self:Think() end
				if self.Rendering then self:Render() end
			end,
			Think = function(self)
				print("Thinking")
			end,
			Render = function(self)
				print("Rendering")
			end,
			StartBuilding = function(self)
				--build.
			end
		}
	}




if CLIENT then

	----------CREATE TRACK BUILDER----------

		local TrackBuilder = setmetatable({}, meta_TrackBuilder); TrackBuilder()

	---------END CREATE TRACK BUILDER-------






	---------PLAYER COMMANDS---------

		local function StartBuilding(pl, cmd, arg)
			TrackBuilder:StartBuilding()
		end
		concommand.Add("StartBuilding", StartBuilding)

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