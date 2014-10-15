
-- Coiny.lua

-- Implements the main entrypoint for the plugin





--- Initializes the "strict" Lua mode - all global variables need to be initialized before being used
-- Adapted from code at http://lua-users.org/wiki/DetectingUndefinedVariables
-- Specifically, http://www.lua.org/extras/5.1/strict.lua
local function initializeStrictMode()
	local getinfo, error, rawset, rawget = debug.getinfo, error, rawset, rawget

	local mt = getmetatable(_G)
	if mt == nil then
		mt = {}
		setmetatable(_G, mt)
	end

	mt.__declared = {}

	local function what ()
		local d = getinfo(3, "S")
		return d and d.what or "C"
	end

	mt.__newindex = function (t, n, v)
		if not mt.__declared[n] then
			local w = what()
			if w ~= "main" and w ~= "C" then
				error("assign to undeclared variable '"..n.."'", 2)
			end
			mt.__declared[n] = true
		end
		rawset(t, n, v)
	end
		
	mt.__index = function (t, n)
		if not mt.__declared[n] and what() ~= "C" then
			error("variable '"..n.."' is not declared", 2)
		end
		return rawget(t, n)
	end
end





function Initialize(a_Plugin)
	-- Initialize strict mode - error on reading non-existing globals:
	initializeStrictMode()
	
	-- Initialize commands:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	RegisterPluginInfoCommands()
	RegisterPluginInfoConsoleCommands()
	
	LoadSettings()
	InitializeStorage()
	
	a_Plugin:AddWebTab("Manage", HandleRequest_Manage)
	return true
end




