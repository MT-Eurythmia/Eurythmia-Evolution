--some crafts to make tin less useless.

tincraft = {}

local tin = "moreores:tin_ingot"
local s_tin = "tincraft:strong_tin"

function tcimport(filename)
	dofile(minetest.get_modpath("tincraft").."/"..filename)
end

tcimport("strongtin.lua")
tcimport("tools.lua")



if minetest.get_modpath("protector") then
	tcimport("protector.lua")
end

if minetest.get_modpath("inbox") then
	tcimport("inbox.lua")
end

