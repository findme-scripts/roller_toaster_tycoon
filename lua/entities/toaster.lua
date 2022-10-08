
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "wall"
ENT.Author = "find me"
ENT.Information = "It's a wall."
ENT.Category = "walls"

ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()

	if CLIENT then
		local me = self
		hook.Add("PostDrawOpaqueRenderables", "I suck eggs"..self:EntIndex(), function() me:NewDraw() end)
	end

	if ( CLIENT ) then return end

	self:DrawShadow(false)
--[[
local min1 = Vector( -30, -10, 0 ) -- Box1 minimum corner
local max1 = Vector( -10, 10, 20 ) -- Box1 maximum corner

local min2 = Vector( 10, -5, 10 ) -- Box2 minimum corner
local max2 = Vector( 30, 5, 40 ) -- Box2 maximum corner

		self:SetModel( "models/props_c17/oildrum001.mdl" )

		-- Initializing the multi-convex physics mesh
		self:PhysicsInitMultiConvex( {
			{ -- Each sub-table is a set of vertices of a convex piece, order doesn't matter
				Vector( min1.x, min1.y, min1.z ), -- The first box vertices
				Vector( min1.x, min1.y, max1.z ),
				Vector( min1.x, max1.y, min1.z ),
				Vector( min1.x, max1.y, max1.z ),
				Vector( max1.x, min1.y, min1.z ),
				Vector( max1.x, min1.y, max1.z ),
				Vector( max1.x, max1.y, min1.z ),
				Vector( max1.x, max1.y, max1.z ),
			},
			{ -- All these tables together form a concave collision mesh
				Vector( min2.x, min2.y, min2.z ), -- The second box vertices
				Vector( min2.x, min2.y, max2.z ),
				Vector( min2.x, max2.y, min2.z ),
				Vector( min2.x, max2.y, max2.z ),
				Vector( max2.x, min2.y, min2.z ),
				Vector( max2.x, min2.y, max2.z ),
				Vector( max2.x, max2.y, min2.z ),
				Vector( max2.x, max2.y, max2.z ),
			},
		} )

		self:SetSolid( SOLID_VPHYSICS ) -- Setting the solidity
		self:SetMoveType( MOVETYPE_VPHYSICS ) -- Setting the movement type

		self:EnableCustomCollisions( true ) -- Enabling the custom collision mesh

		--self:PhysWake() -- Enabling the physics motion
--]]
end

if SERVER then
	util.AddNetworkString("PhysTable_ToClient")

	function ENT:UpdateTransmitState()

		return TRANSMIT_ALWAYS
	end
end

if CLIENT then
	net.Receive( "PhysTable_ToClient", function( len, ply )
		local ent = net.ReadEntity()
		local tbl = net.ReadTable()

		print("here")
		print(ent, tbl)
		ent.PhysTable = tbl
	end )
end

function ENT:Inject(PhysTable)
	self.PhysTable = PhysTable

	PrintTable(self.PhysTable)

	self:RebuildPhysics()

	local PhysSTable = PhysTable
	local UHME = self

	timer.Simple( 1, function()

		net.Start( "PhysTable_ToClient" )
			net.WriteEntity(UHME)
			net.WriteTable(PhysSTable)
		net.Broadcast()

	end )

end

function ENT:RebuildPhysics()

		local tbl = self.PhysTable
		--PrintTable(tbl)

		local tbl_fix = {}
		for k, v in pairs(tbl) do
			print("ewf")
			table.insert( tbl_fix, {
				Vector( v[1].x, v[1].y, v[1].z ),
				Vector( v[1].x, v[1].y, v[2].z ),
				Vector( v[1].x, v[2].y, v[1].z ),
				Vector( v[1].x, v[2].y, v[2].z ),
				Vector( v[2].x, v[1].y, v[1].z ),
				Vector( v[2].x, v[1].y, v[2].z ),
				Vector( v[2].x, v[2].y, v[1].z ),
				Vector( v[2].x, v[2].y, v[2].z ),
			} )
		end

		--PrintTable(tbl_fix)

		-- Initializing the multi-convex physics mesh
		print(self:PhysicsInitMultiConvex( tbl_fix ))

		self:SetSolid( MOVETYPE_VPHYSICS ) -- Setting the solidity
		self:SetMoveType( MOVETYPE_VPHYSICS ) -- Setting the movement type

		self:EnableCustomCollisions( true ) -- Enabling the custom collision mesh

		self:PhysWake() -- Enabling the physics motion

		self:GetPhysicsObject():SetMass(1000)
		self:GetPhysicsObject():EnableMotion(false)

end





if ( SERVER ) then return end -- We do NOT want to execute anything below in this FILE on SERVER

function ENT:Draw()
	return false
end

function ENT:NewDraw()

	print("draw")
	--self:DrawModel()
	if self.PhysTable then

		--PrintTable(self.PhysTable)
		for k, v in pairs(self.PhysTable) do
			render.SetMaterial( Material("models/props_wasteland/wood_fence01a") )
			render.DrawBox(self:GetPos(), self:GetAngles(), v[1], v[2], color_white)
		end

	end

end
