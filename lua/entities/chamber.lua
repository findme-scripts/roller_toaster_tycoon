AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Chamber"
ENT.Author = "find me"
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Bounds = {}
ENT.Bounds[1] = Vector(-32, -32, -32)
ENT.Bounds[2] = Vector(32, 32, 32)

if SERVER then

	function ENT:Initialize()
		self:SetModel("models/maxofs2d/cube_tool.mdl")
		self:DrawShadow(false)

	end

	function ENT:PrePhysThink()

	end

end




if CLIENT then

	function ENT:Initialize()
		self:SetModel("models/Gibs/HGIBS.mdl")

		if !Splines then include("autorun/splines.lua") end
		self.Splines = {}

		self:PopulateChamber()
	end

	function ENT:PopulateChamber()
		if !self.Points then self.Points = {} end

		for i=1, 6 do
			self.Points[i] = {Acc = Vector((0.03+math.random(-1000, 1000)*0.0005), (0.03+math.random(-1000, 1000)*0.0005), (0.03+math.random(-1000, 1000)*0.00003) ), Position = Vector(0, 0, 0)}
			self.Splines[i] = Splines:New( { self:GetPos(), self:GetPos(), self:GetPos() } )
			self.Splines[i].DebugRender = true

			--Debug:Position("["..tostring(i).."] Point", self.Points[i].Position, {{0.5, 16, 16, color_white}, {"DermaDefault", 15, 15, color_white}})
		end
	end

	ENT.TestAverageOfBounds = Vector()
	function ENT:PointHitBounds(index)
		self.TestAverageOfBounds = (self.TestAverageOfBounds + self.Points[index].Position)/2
		--print(self.TestAverageOfBounds)
	end

	function ENT:Draw()
		--render.DrawWireframeBox(self:GetPos(), self:GetAngles(), self.Bounds[1], self.Bounds[2], color_white, false)

		self:SetAngles( (LocalPlayer():EyePos()-self:GetPos()):Angle() )
		self:DrawModel()

		if #self.Points <= 0 then return end

		for i=1, #self.Points do
			local Position = self.Points[i].Position
			local acc = self.Points[i].Acc

			Position = Position + acc + self:GetVelocity()*0.001
			local PrePosition = Position
			Position = Vector(math.Clamp(Position.x, self.Bounds[1].x, self.Bounds[2].x), math.Clamp(Position.y, self.Bounds[1].y, self.Bounds[2].y), math.Clamp(Position.z, self.Bounds[1].z, self.Bounds[2].z))

			local pladd = 0
			if Position.x != PrePosition.x then
				self.Points[i].Acc.x = -acc.x
				self:PointHitBounds(i)
				pladd = pladd+1
			end
			if Position.y != PrePosition.y then
				self.Points[i].Acc.y = -acc.y
				self:PointHitBounds(i)
				pladd = pladd+1
			end
			if Position.z != PrePosition.z then
				self.Points[i].Acc.z = -acc.z
				self:PointHitBounds(i)
				pladd = pladd+1
			end

			if pladd != 0 then
				if self.TestAverageOfBounds then
					self.TestAverageOfBounds = (self.TestAverageOfBounds + ((  ((LocalPlayer():EyePos())-self:GetPos()) - self.TestAverageOfBounds )) ) * 0.4
				end
			end

			local tr = util.TraceLine( {
				start = self:GetPos() + Position,
				endpos = (self:GetPos() + Position) + Vector(0, 0, -5),
				filter = {self}
			} )

			if tr.HitWorld then
				self.Points[i].Acc.z = math.abs(acc.z)
				self:PointHitBounds(i)
			end

			self.Points[i].Position = Position
			--Debug:Position("["..tostring(i).."] Point", self:GetPos() + Position, {{0.5, 16, 16, color_white}, {"DermaDefault", 15, i*15, color_white}})

			local NewPos = (self:GetPos()+(self:GetPos() + Position))*0.5
			if !self.Points[i].MidP then self.Points[i].MidP = NewPos end
			local mid = self.Points[i].MidP

			local endpos = self:GetPos() + Position
			self.Points[i].MidP = self.Points[i].MidP+self.Points[i].Acc*4
			self.Points[i].MidP = Vector( math.Clamp(self.Points[i].MidP.x, endpos.x-5, endpos.x+5), math.Clamp(self.Points[i].MidP.y, endpos.y-5, endpos.y+5), math.Clamp(self.Points[i].MidP.z, endpos.z-5, endpos.z+5) )
			
			self.Splines[i]:Update({[1] = self:GetPos(), [2] = self.Points[i].MidP, [3] = self:GetPos() + Position})
		end

		if self.TestAverageOfBounds && self.Owner then
			if !self.OldPos then self.OldPos = self:GetPos() end
			self.OldPos = self:GetPos()
			self:SetPos( LerpVector(0.007, self:GetPos(), self.OldPos+self.TestAverageOfBounds) )
			--Debug:Position("Average", self:GetPos() + self.TestAverageOfBounds, {{4, 16, 16, color_white}, {"DermaDefault", 15, 180, color_white}})
		end

	end

end