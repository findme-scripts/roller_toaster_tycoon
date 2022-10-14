AddCSLuaFile()
if SERVER then return end
if !IsValid(LocalPlayer()) then return end

local Meta = {}
function Meta:__call(vec, ang)
	self:CreateBasicMatrix()
	self:SetPos(vec || Vector())
	self:SetAngles(ang || Angle())
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
	return self:GetTranslation()
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

function Method:Dump()
	PrintTable(self:ToTable())
end

function Method:Initialize()

end

Meta.__index = Method




local function CreateSpace(pl, cmd, arg)
	local tr = pl:GetEyeTraceNoCursor()

	local space = setmetatable({}, Meta)
	space(tr.HitPos)
	space:Dump()
end
concommand.Add("Space", CreateSpace)