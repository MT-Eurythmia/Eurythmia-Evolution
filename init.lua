--                                                        _____
--  +-+    +-+  +-\    /-+      /--\      +------\  +-+  /  ___|
--  | |    | |  |  \  /  |     / /\ \     | +--+ |  | |  | |___
--  | |    | |  |   \/   |    / /__\ \    | |__| /  | |  \___  \
--  | |    | |  | |\__/| |   / +----+ \   |  __  \  | |       \ \
--  | |____| |  | |    | |  / /      \ \  | |__| |  | |  _____/ |
--  |________|  |_|    |_| /_/        \_\ |______/  |_|  |_____/
--
-- The Ultimate Minetest Authentication, Banning and Identity theft prevention System

umabis = {
	version_major = 0,
	version_minor = 0,
	version_patch = 0
}
umabis.version_string = umabis.version_major.."."..umabis.version_minor.."."..umabis.version_patch

dofile(minetest.get_modpath("umabis") .. "/settings.lua")
dofile(minetest.get_modpath("umabis") .. "/serverapi.lua")

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

if not umabis.serverapi.hello() then
	return false
end

minetest.log("action", "[umabis] Umabis version "..umabis.version_string.." loaded!")
