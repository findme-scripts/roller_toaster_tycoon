AddCSLuaFile()

local function Load_Scripts()
	local scripts, _ = file.Find( "autorun/scripts/*", "LUA" )

	for _, v in ipairs( scripts ) do
		AddCSLuaFile("autorun/scripts/"..v)
		include("autorun/scripts/"..v)
	end
end



if SERVER then
	Load_Scripts()
end

if CLIENT then
	hook.Add("InitPostEntity", "Client Ready", function()
		Load_Scripts()
	end)
end