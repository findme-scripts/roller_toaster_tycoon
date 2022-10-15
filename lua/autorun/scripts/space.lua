AddCSLuaFile()
if SERVER then return end
if !IsValid(LocalPlayer()) then return end

local Meta = {}
function Meta:__call(pos, ang, size)
	self:CreateBasicMatrix()
	self:SetPos(pos || Vector())
	self:SetAngles(ang || Angle())
	self:SetSize(size || Vector())
	self:Initialize()

	return self
end


local Method = {}
function Method:CreateBasicMatrix()
	self.Matrix = Matrix(
		{
			{0, -1, 0, 0},
			{1, 0, 0, 0},
			{0, 0, 1, 0},
			{0, 0, 0, 0}
		})
end

function Method:Move(vec)
	self.Matrix:Translate(vec)
end

function Method:Rotate(ang)
	self.Matrix:Rotate(ang)
end

function Method:SetPos(vec)
	self.Matrix:SetTranslation(vec)
end

function Method:SetAngles(ang)
	self.Matrix:SetAngles(ang)
end

function Method:GetPos()
	return self.Matrix:GetTranslation()
end

function Method:GetAngles()
	return self.Matrix:GetAngles()
end

function Method:GetForward()
	return self.Matrix:GetForward()
end

function Method:GetRight()
	return self.Matrix:GetRight()
end

function Method:GetUp()
	return self.Matrix:GetUp()
end

function Method:NullifyMatrix()
	self.Matrix:Zero()
end

function Method:UnPackMatrix()
	return self.Matrix:Unpack()
end

function Method:ToTable()
	return self.Matrix:ToTable()
end

function Method:SetMatrixField(row, column, val)
	self.Matrix:SetField(row, column, val)
end

function Method:GetMatrixField(row, column)
	return self.Matrix:GetField(row, column)
end

function Method:IsValid()
	return true
end

function Method:Remove()
	self = nil
end

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

function Method:TestRender()
	--self:Rotate(Angle( 0, 1/(1/FrameTime()), 0 ))
end

function Method:RenderContext()
	self:DrawAxis()
	self:DrawGround()
	self:DrawOutline()

	self:TestRender()
end




function Method:Dump()
	PrintTable(self:ToTable())
	print("Position: "..tostring(self:GetPos()))
	print("Angles: "..tostring(self:GetAngles()))
	print("Size: "..tostring(self:GetSize()))
end

Meta.__index = Method












local function CreateSpace(pl, cmd, arg)
	local tr = pl:GetEyeTraceNoCursor()

	local space = setmetatable({}, Meta)
	space(tr.HitPos+Vector(0, 0, 16), Angle(), Vector(16, 16, 16))
	space:Dump()
end
concommand.Add("Space", CreateSpace)