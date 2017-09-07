--                                                        _____
--  +-+    +-+  +-\    /-+      /--\      +------\  +-+  /  ___|
--  | |    | |  |  \  /  |     / /\ \     | +--+ |  | |  | |___
--  | |    | |  |   \/   |    / /__\ \    | |__| /  | |  \___  \
--  | |    | |  | |\__/| |   / +----+ \   |  __  \  | |       \ \
--  | |____| |  | |    | |  / /      \ \  | |__| |  | |  _____/ |
--  |________|  |_|    |_| /_/        \_\ |______/  |_|  |_____/
--
-- The Ultimate Minetest Authentication, Banning and Identity theft prevention System

local version = {
	major = 0,
	minor = 0,
	patch = 0
}

local registered_on_reload = {}

-- Avoid "Assignement to undeclared global" warning
umabis = nil

local function load()
	umabis = {
		version_major = version.major,
		version_minor = version.minor,
		version_patch = version.patch,
		version_string = version.major.."."..version.minor.."."..version.patch,
		register_on_reload = function(action)
			table.insert(registered_on_reload, action)
		end
	}

	dofile(minetest.get_modpath("umabis") .. "/settings.lua")

	dofile(minetest.get_modpath("umabis") .. "/serverapi.lua")
	if not umabis.serverapi.hello() then
		return false
	end

	for _, action in ipairs(registered_on_reload) do
		if action() == false then
			return false
		end
	end

	minetest.log("action", "[umabis] Umabis version "..umabis.version_string.." loaded!")
	return true
end
if not load() then
	minetest.log("error", "[umabis] Failed to load Umabis version "..umabis.version_string..".")
end

minetest.register_chatcommand("umabis_reload", {
	description = "Reloads Umabis",
	privs = {ban = true},
	params = "",
	func = function(name, param)
		if load() then
			return true, "Successfully reloaded Umabis."
		else
			return false, minetest.colorize("#FF0000", "Error occured while reloading. See debug.txt for more details.")
		end
	end
})

minetest.register_on_prejoinplayer(function(name, ip)
	--[[
	TODO: check if the user is blacklisted
	]]
end)

minetest.register_on_joinplayer(function(player)
	--[[
	TODO: ask the user to register or authenticate
	]]
end)

minetest.register_on_shutdown(function()
	--umabis.sessions.close_all()
end)
