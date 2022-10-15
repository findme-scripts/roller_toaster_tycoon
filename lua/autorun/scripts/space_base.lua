AddCSLuaFile()
if SERVER then return end
if !IsValid(LocalPlayer()) then return end

local Meta = {}
function Meta:__call(pos, ang)
	self:CreateBasicMatrix()
	self:SetPos(pos || Vector())
	self:SetAngles(ang || Angle())

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

function Method:Dump()
	debugoverlay.Axis(self:GetPos(), self:GetAngles(), 6, 20, false)
	PrintTable(self:ToTable())
	print("Position: "..tostring(self:GetPos()))
	print("Angles: "..tostring(self:GetAngles()))
end
Meta.__index = Method



function Use_Base(tbl, pos, ang)
	return setmetatable( (tbl || {}), Meta )( pos||Vector(), ang||Angle() ) --Return what call returns.
end








local function Create_NewBase(pl, cmd, arg)
	local tr = pl:GetEyeTraceNoCursor()

	local world = Use_Base()
	world(tr.HitPos)
	world:Dump()
end
concommand.Add("NewBase", Create_NewBase)