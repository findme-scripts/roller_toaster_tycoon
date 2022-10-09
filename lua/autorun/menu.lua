AddCSLuaFile()
if SERVER then return end

local function circle_test(pl, cmd, arg)
	print("oi")
end
concommand.Add("cir", circle_test)