AddCSLuaFile()

SWEP.PrintName = "Spline Viewer"
SWEP.Author = "find me"
SWEP.Purpose = "Visual of this mathness."
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.Spawnable = true
SWEP.ViewModel = Model( "models/weapons/c_toolgun.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_toolgun.mdl" )
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = falses
SWEP.Secondary.Ammo = "none"
SWEP.Category = "Roller Toaster Tycoon"

if SERVER then return end

---------------------------------------------------------------------------------

SWEP.C =
	{
		Color(80, 80, 80, 160),
		Color(230, 80, 80, 255),
		Color(80, 80, 200, 255)
	}



function SWEP:Initialize()
	hook.Add("PostDrawOpaqueRenderables", "Spline Viewer - Render Context", function() if !IsValid(self) then return end self:RenderContext() end)
	concommand.Add("drop", function(pl, cmd, arg) self:Command_Drop(pl, cmd, arg) end)
end

function SWEP:Splat(pos)
	if !self.Splats then self.Splats = {} end

	table.insert(self.Splats, pos)
end

function SWEP:RenderContext()
	if !self.S then return end

	render.SetColorMaterial()

	if !self.E then --Ghost if no E.
		local tr = self:GetOwner():GetEyeTraceNoCursor()
		local M = (tr.HitPos+self.S) * 0.5
		local dir = (self.S-M):GetNormal()
		local dist = self.S:Distance(M)
		render.DrawWireframeBox( M, Angle(), -dir*dist, dir*dist+Vector(0, 0, dist), color_white, false )
	end

	if !self.E then return end

	if !self.Min then
		self.M = (self.S+self.E) * 0.5
		self.dir = (self.S-self.M):GetNormal()
		self.dist = self.S:Distance(self.M)
		self.Min = self.dir*self.dist
		self.Max = -self.dir*self.dist+Vector(0, 0, self.dist)
		self.Point = Vector(0, 0, 0)
		self.Acc = Vector(0.15, 0.09, 0.04)
	end

	render.DrawWireframeBox( self.M, Angle(), -self.dir*self.dist, self.dir*self.dist+Vector(0, 0, self.dist), color_white, false )


	if !self.Point then return end

	self.Point = self.Point + self.Acc
	self.OldPoint = self.Point
	self.Point = Vector(math.Clamp(self.Point.x, self.Min.x, self.Max.x), math.Clamp(self.Point.y, self.Min.y, self.Max.y), math.Clamp(self.Point.z, self.Min.z, self.Max.z))

	if self.Point.x != self.OldPoint.x then
		self.Acc.x = -self.Acc.x
		self:Splat((self.M+Vector(0, 0, 0)) + self.Point)
	end
	if self.Point.y != self.OldPoint.y then
		self.Acc.y = -self.Acc.y
		self:Splat((self.M+Vector(0, 0, 0)) + self.Point)
	end
	if self.Point.z != self.OldPoint.z then
		self.Acc.z = -self.Acc.z
		self:Splat((self.M+Vector(0, 0, 0)) + self.Point)
	end

	render.DrawSphere((self.M+Vector(0, 0, 0)) + self.Point, 1, 16, 16, self.C[2])



	if !self.Splats then return end

	for _, v in pairs(self.Splats) do
		render.DrawSphere(v, 0.25, 16, 16, self.C[3])
	end


	if !self.Drop then return end

	local p = self.Drop:GetPos()

	if p.x > self.M.x+self.Min.x && p.x < self.M.x+self.Max.x then

		if p.y > self.M.y+self.Min.y && p.y < self.M.y+self.Max.y then

			if p.z > self.M.z+self.Min.z && p.z < self.M.z+self.Max.z then

				LocalPlayer():ChatPrint("["..tostring(math.Round(CurTime())).."] We in the matrix.")
				if IsValid(self.Drop:GetPhysicsObject()) then
					local phys = self.Drop:GetPhysicsObject()

					local Acc = phys:GetVelocity():Length()
					local Vel = phys:GetVelocity()
					self.Drop:GetPhysicsObject():SetVelocity(Vel*0.96)
				end

			end

		end

	end


end

function SWEP:Command_Drop(pl, cmd, arg)
	self.Drop = ents.CreateClientProp("models/props_junk/PopCan01a.mdl")
	self.Drop:SetPos(self.M + Vector(0, 0, 1)*self.dist*1)
	self.Drop:Spawn()
	print(self.Drop:GetPhysicsObject())
end

function SWEP:DrawDebug()
	if !self.S then return end

	draw.RoundedBox( 4, 0, 0, 300, 400, self.C[1] )
	draw.SimpleText( "S: "..tostring(self.S), "DermaDefault", 15, 20, color_white )

	if !self.E then return end

	draw.SimpleText( "E: "..tostring(self.E), "DermaDefault", 15, 35, color_white )

	if !self.Min then return end

	draw.SimpleText( "Min: "..tostring(self.Min), "DermaDefault", 15, 60, color_white )
	draw.SimpleText( "Max: "..tostring(self.Max), "DermaDefault", 15, 75, color_white )

end

function SWEP:Think()

end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() then return end
	local tr = self:GetOwner():GetEyeTraceNoCursor()

	if !self.S then
		self.S = tr.HitPos
	elseif !self.E then
		self.E = tr.HitPos
	end

end

function SWEP:SecondaryAttack()
	if !IsFirstTimePredicted() then return end

	
end

function SWEP:Reload()
	self.S = nil
	self.E = nil
	self.M = nil
	self.dir = nil
	self.dist = nil
	self.Min = nil
	self.Max = nil
	self.Point = nil
	self.Acc = nil
	self.Splats = nil
end

function SWEP:DrawHUD()
	self:DrawDebug()
end

function SWEP:HUDShouldDraw()
	return true
end

function SWEP:Holster()
	return true
end