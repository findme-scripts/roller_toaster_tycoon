AddCSLuaFile()

local function Load_Scripts()
	local scripts, _ = file.Find( "autorun/scripts/*", "LUA" )

	for _, v in ipairs( scripts ) do
		AddCSLuaFile("autorun/scripts/"..v)
		include("autorun/scripts/"..v)
	end
end

Load_Scripts()