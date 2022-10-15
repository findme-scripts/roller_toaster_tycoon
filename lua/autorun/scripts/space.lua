AddCSLuaFile()
if SERVER then return end
if !IsValid(LocalPlayer()) then return end

local Meta = {}
function Meta:__call(pos, ang, size)
	Use_Base(self, pos||Vector(), ang||Angle()) --Inherit base meta.
	self:SetSize(size || 0)
	self:Initialize()
	return self
end


local Method = {}
function Method:SetSize(vec)
	self.Size = vec
end

function Method:GetSize()
	return self.Size
end

function Method:SetLength(val)
	self.Size.y = val
end

function Method:SetWidth(val)
	self.Size.x = val
end

function Method:SetHeight(val)
	self.Size.z = val
end

function Method:GetLength(val)
	return self.Size.y
end

function Method:GetWidth(val)
	return self.Size.x
end

function Method:GetHeight(val)
	return self.Size.z
end




function Method:SetupVariables()
	self.Materials = {"phoenix_storms/bluemetal", "concrete/concretefloor001a", "hunter/myplastic"}

	self.Hooks = {}
	self.Hooks[1] = {"PostDrawOpaqueRenderables", "["..SysTime().."]Space Meta - Render Context", self.RenderContext}
end

function Method:SetupHooks()
	for i=1, #self.Hooks do
		hook.Add(self.Hooks[i][1], self.Hooks[i][2], function() if IsValid(self) then self.Hooks[i][3](self) end end)
	end
end

function Method:SetupMaterials()
	for i=1, #self.Materials do
		local tex = self.Materials[i]
		self.Materials[i] = CreateMaterial( tostring(SysTime()).." "..tex, "UnlitGeneric", {
		  ["$basetexture"] = tex,
		  ["$model"] = 1
		} )
	end
end

function Method:Initialize()
	self:SetupVariables()
	self:SetupMaterials()
	self:SetupHooks()
end




function Method:DrawAxis()
	debugoverlay.Axis(self:GetPos(), self:GetAngles(), 6, 1/(1/FrameTime()), false)
end

function Method:DrawGround()
	render.SetMaterial(self.Materials[3])
	local pos, size = self:GetPos(), self:GetSize()
	render.DrawQuad( pos+Vector(-size.x, -size.y, -size.z), pos+Vector(-size.x, size.y, -size.z), pos+Vector(size.x, size.y, -size.z), pos+Vector(size.x, -size.y, -size.z), color_white)
end

function Method:DrawOutline()
	render.DrawWireframeBox(self:GetPos(), self:GetAngles(), self:GetSize()*-1, self:GetSize(), color_white, false)
end

function Method:RenderContext()
	self:DrawAxis()
	self:DrawGround()
	self:DrawOutline()
end



--[[
function Method:Dump()
	PrintTable(self:ToTable())
	print("Position: "..tostring(self:GetPos()))
	print("Angles: "..tostring(self:GetAngles()))
	print("Size: "..tostring(self:GetSize()))
end--]]

Meta.__index = Method












local function CreateSpace(pl, cmd, arg)
	local tr = pl:GetEyeTraceNoCursor()

	local space = setmetatable({}, Meta)
	space(tr.HitPos+Vector(0, 0, 16), Angle(), Vector(16, 16, 16))
	space:Dump()
end
concommand.Add("Space", CreateSpace)