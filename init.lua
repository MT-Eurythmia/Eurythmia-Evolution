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

umabis = {
	-- This function is available only during the initial load.
	register_on_reload = function(action)
		table.insert(registered_on_reload, action)
	end
}

dofile(minetest.get_modpath("umabis") .. "/auth_handler.lua")
dofile(minetest.get_modpath("umabis") .. "/formspecs.lua")
dofile(minetest.get_modpath("umabis") .. "/session.lua")

local function load()
	umabis = {
		version_major = version.major,
		version_minor = version.minor,
		version_patch = version.patch,
		version_string = version.major.."."..version.minor.."."..version.patch
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

	dofile(minetest.get_modpath("umabis") .. "/chatcmds.lua")

	minetest.log("action", "[umabis] Umabis version "..umabis.version_string.." loaded!")
	return true
end

umabis.register_on_reload(function()
	umabis.reload = load
end)

if not load() then
	minetest.log("error", "[umabis] Failed to load Umabis version "..umabis.version_string..".")
	error("Failed to load Umabis version "..umabis.version_string..". See debug.txt for more info.")
end

minetest.register_on_prejoinplayer(function(name, ip)
	--[[
	TODO: check if the user is blacklisted
	]]
	umabis.session.prepare_session(name, ip)
	--[[
	FIXME: the user password must be checked in this callback.
	If this is the first time the user joins this MT server but is already registered
	on the Umabis server, and if the password is wrong, deny their access and set
	their password to the Umabis password.
	The user should also be authenticated in the callback, registration being the only
	operation left in the on_joinplayer callback.
	]]
end)

minetest.register_on_joinplayer(function(player)
	umabis.session.new_session(player:get_player_name())
end)

minetest.register_on_leaveplayer(function(player)
	umabis.session.clear_session(player:get_player_name())
end)

minetest.register_on_shutdown(function()
	umabis.session.clear_all()
end)
