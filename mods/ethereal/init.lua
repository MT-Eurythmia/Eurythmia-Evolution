--[[

	Minetest Ethereal Mod (1st March 2017)

	Created by ChinChow

	Updated by TenPlus1

]]

ethereal = {} -- DO NOT change settings below, use the settings.conf file
ethereal.version = "1.22"
ethereal.leaftype = 0 -- 0 for 2D plantlike, 1 for 3D allfaces
ethereal.leafwalk = false -- true for walkable leaves, false to fall through
ethereal.cavedirt = true -- caves chop through dirt when true
ethereal.torchdrop = true -- torches drop when touching water
ethereal.papyruswalk = true -- papyrus can be walked on
ethereal.lilywalk = true -- waterlilies can be walked on
ethereal.xcraft = true -- allow cheat crafts for cobble->gravel->dirt->sand, ice->snow, dry dirt->desert sand
ethereal.glacier   = 1 -- Ice glaciers with snow
ethereal.bamboo    = 1 -- Bamboo with sprouts
ethereal.mesa      = 1 -- Mesa red and orange clay with giant redwood
ethereal.alpine    = 1 -- Snowy grass
ethereal.healing   = 1 -- Snowy peaks with healing trees
ethereal.snowy     = 1 -- Cold grass with pine trees and snow spots
ethereal.frost     = 1 -- Blue dirt with blue/pink frost trees
ethereal.grassy    = 1 -- Green grass with flowers and trees
ethereal.caves     = 1 -- Desert stone ares with huge caverns underneath
ethereal.grayness  = 1 -- Grey grass with willow trees
ethereal.grassytwo = 1 -- Sparse trees with old trees and flowers
ethereal.prairie   = 1 -- Flowery grass with many plants and flowers
ethereal.jumble    = 1 -- Green grass with trees and jungle grass
ethereal.junglee   = 1 -- Jungle grass with tall jungle trees
ethereal.desert    = 1 -- Desert sand with cactus
ethereal.grove     = 1 -- Banana groves and ferns
ethereal.mushroom  = 1 -- Purple grass with giant mushrooms
ethereal.sandstone = 1 -- Sandstone with smaller cactus
ethereal.quicksand = 1 -- Quicksand banks
ethereal.plains    = 1 -- Dry dirt with scorched trees
ethereal.savannah  = 1 -- Dry yellow grass with acacia tree's
ethereal.fiery     = 1 -- Red grass with lava craters
ethereal.sandclay  = 1 -- Sand areas with clay underneath
ethereal.swamp     = 1 -- Swamp areas with vines on tree's, mushrooms, lilly's and clay sand
ethereal.sealife   = 1 -- Enable coral and seaweed
ethereal.reefs     = 1 -- Enable new 0.4.15 coral reefs in default

local path = minetest.get_modpath("ethereal")

-- Load new settings if found
local input = io.open(path.."/settings.conf", "r")
if input then
	dofile(path .. "/settings.conf")
	input:close()
	input = nil
end

-- Intllib
local S
if minetest.global_exists("intllib") then
	if intllib.make_gettext_pair then
		-- New method using gettext.
		S = intllib.make_gettext_pair()
	else
		-- Old method using text files.
		S = intllib.Getter()
	end
else
	S = function(s) return s end
end
ethereal.intllib = S

-- Falling node function
ethereal.check_falling = minetest.check_for_falling or nodeupdate

dofile(path .. "/plantlife.lua")
dofile(path .. "/mushroom.lua")
dofile(path .. "/onion.lua")
dofile(path .. "/crystal.lua")
dofile(path .. "/water.lua")
dofile(path .. "/dirt.lua")
dofile(path .. "/food.lua")
dofile(path .. "/wood.lua")
dofile(path .. "/leaves.lua")
dofile(path .. "/sapling.lua")
dofile(path .. "/strawberry.lua")
dofile(path .. "/fishing.lua")
dofile(path .. "/extra.lua")
dofile(path .. "/sealife.lua")
dofile(path .. "/fences.lua")
dofile(path .. "/gates.lua")
dofile(path .. "/mapgen.lua")
dofile(path .. "/compatibility.lua")
dofile(path .. "/stairs.lua")
dofile(path .. "/lucky_block.lua")

-- Use bonemeal mod instead of ethereal's own if found
if minetest.get_modpath("bonemeal") then
	minetest.register_alias("ethereal:bone", "bonemeal:bone")
	minetest.register_alias("ethereal:bonemeal", "bonemeal:bonemeal")
else
	dofile(path .. "/bonemeal.lua")
end

if minetest.get_modpath("xanadu") then
	dofile(path .. "/plantpack.lua")
end

print (S("[MOD] Ethereal loaded"))
