--[[AddCSLuaFile()

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
			self.All = {}
			print("im alive")
		end,

		__index = {
			New = function(self, spline)
				table.insert(self.All, setmetatable(spline, meta_Spline))
				self.Current = self.All[#self.All]
			end
		}
	}

local meta_TrackBuilder =
	{
		__call = function(self)
			self.Building = false
			self.Splines = setmetatable({}, meta_SplineManager); self.Splines();
			hook.Add("PostDrawOpaqueRenderables", "Track Builder - Render Context", function() self:ThinkManager() end)
		end,

		__index = {
			ThinkManager = function(self)
				if self.Building then self:BuildThink() self:BuildRender() end
			end,
			StartBuilding = function(self)
				self.Building = true
				self.Start = LocalPlayer():GetPos()
				--self.Splines:New(self.Start, self.End)
			end,
			BuildThink = function(self)
				local tr = LocalPlayer():GetEyeTraceNoCursor()
				self.End = tr.HitPos
			end,
			BuildRender = function(self)
				render.SetColorMaterial()
				render.DrawSphere( self.Start, 1, 8, 8, color_white)
				render.DrawSphere( self.End, 1, 8, 8, color_white)
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

		local function StopBuilding(pl, cmd, arg)
			TrackBuilder.Building = false
		end
		concommand.Add("StopBuilding", StopBuilding)

	--------END PLAYER COMMANDS-------

end



if SEVER then

end

--]]



--[[
--Jova - Example

local metaTable_Class = {    
    __tostring = function(self)
        return ("Class :\n  %s\n  %s"):format(tostring(self.variables[1]), tostring(self.variables[2]))
    end,

    someFunction = function(self)
        --
    end,
}

metaTable_Class.__index = metaTable_Class

function Class(a, b)
    local Class = {
        variables = {
            a,
            b
        }
    }
    
    return setmetatable( Class, metaTable_Class )
end

--]]