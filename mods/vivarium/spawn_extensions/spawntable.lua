-- Beasts and where to spawn them
-- Adds extra spawn rules for the specified mobs
-- Mobs can br grouped this way

spawnex.spawnrules = {}

function spawnex:add_spawns(ruleset)
	spawnex.spawnrules[#spawnex.spawnrules+1] = ruleset
end

function spawnex:deepcopy(table)
	if type(table) ~= "table" then return table end
	-- what about dealing with circular references?
	local newtable = {}

	for i,n in pairs(table) do
		if type(n) == "table" then
			newtable[i] = spawnex:deepcopy(n)
		else
			newtable[i] = n -- newtable[i] is the new reference we need?
		end
	end
	return newtable
end

function spawnex:havemobs(modname,mobnames)
	if not minetest.get_modpath(modname) then return {} end

	local moblist = {}
	for _,x in mobnames do
		moblist[#moblist+1] = modname..":"..mobname
	end
	return moblist
end

function apend(ar1,ar2)
	for _,x in pairs(ar2) do
		ar1[#ar1+1] = x
	end
	return ar1
end

--[[

spawnex:add_spawns({
	spawn_on = {}, --nodes, e.g. default:dirt_with_grass
	when_near = {}, --nodes, e.g. default:leaves
	light = {0,20}, -- minimum and maximum light
	altitudes = {-31000,31000}, --altitude range
	daytoggle = nil, -- nil -> anytime, true -> only by day, false -> only at night
	chance = 900, -- FIXME NO!!
	mobs = {
		{"modname:mobname",chance}, -- FIXME shuold have been like this!!
		{"modname:mobname",chance},
	}
},)

--function mobs:spawn_specific(name, nodes, neighbors, min_light, max_light,
--        interval, chance, active_object_count, min_height, max_height, day_toggle)

--]]
-- Supported animals

-- ==============
-- Things that spawn in fields -- ethereal support

local fieldmobs = {}
fieldmobs = apend(fieldmobs,spawnex:havemobs("mobs_animal",{"cow","kitten","pumba","bunny","chicken"}) )
fieldmobs = apend(fieldmobs,spawnex:havemobs("mobs_wolf",{"wolf"}) )
fieldmobs = apend(fieldmobs,spawnex:havemobs("mobs_horse",{"horse"}) )

spawnex:addspawns( {
	spawn_on = {"ethereal:green_grass"},
	when_near = {"air"},
	light = {0,20},
	altitudes = {-20,31000},
	chance = 1500,
	daytoggle = nil,
	mobs = fieldmobs
} )

-- ==============
-- Things that spawn in forests -- ethereal support

local forestmobs = {}
fieldmobs = apend(fieldmobs,petdting:havemobs("mobs_deer",{"deer"}) )
fieldmobs = apend(fieldmobs,petdting:havemobs("mobs_bear",{"medved"}) )

spawnex:addspawns( {
	spawn_on = {"ethereal:green_grass"},
	when_near = {"group:wood"}, -- group trunks??
	light = {0,20},
	altitudes = {-20,31000},
	chance = 900,
	daytoggle = nil,
	mobs = forestmobs
} )

-- ==============
-- Things that spawn in dark damp places

local sewermobs = spawnex:havemobs("mobs_animal",{"rat"})

spawnex:addspawns( {
	spawn_on = {"default:stone","default:cobblestone","default:desertstone"},
	when_near = {"default:water_source"},
	light = {0,5},
	altitudes = {-31000,31000},
	chance = 300,
	daytoggle = nil,
	mobs = sewermobs
} )

-- ===============
-- Things that spawn in bamboo groves

local bamboomobs = spawnex:havemobs("dmobs",{"panda"})

spawnex:addspawns( {
	spawn_on = {"ethereal:dirt_grove"}, -- FIXME check itemstring
	when_near = {"ethereal:bamboo"}, -- FIXME check itemstring
	light = {0,20},
	altitudes = {-31000,31000},
	chance = 300,
	daytoggle = nil,
	mobs = bamboomobs
} )

-- ==============
-- Things that spawn in deep places

local deepspawn = {
	spawn_on = {"default:stone","default:cobblestone","default:desertstone","default:sandstone"},
	when_near = {"air"},
	light = {0,5},
	chance = 300,
	daytoggle = nil,
}
local deepmobs = {}

-- -100 : 0
deepmobs = spawnex:havemobs("mobs_monster",{"stone_monster"})
deepmobs = apend(deepmobs,spawnex:havemobs("mobs_monster",{"oerkki"}) )
deepspawn.altitudes = {-100,0}
deepspawn.mobs = deepmobs
spawnex:addspawns(deepspawn)

-- -500 : -100
deepmobs = spawnex:havemobs("mobs_senderman",{"senderman"}) -- resets deepmobs variable
deepmobs = apend(deepmobs,spawnex:havemobs("mobs_monster",{"stone_monster"}) )
deepmobs = apend(deepmobs,spawnex:havemobs("mobs_monster",{"mese_monster"}) )
deepspawn.altitudes = {-500,-100}
deepspawn.mobs = deepmobs
spawnex:addspawns(deepspawn)

-- -1500 : -500
deepmobs = spawnex:havemobs("mobs_senderman",{"senderman"}) -- resets deepmobs variable
deepmobs = apend(deepmobs,spawnex:havemobs("mobs_monster",{"dungeon_master"}) )
deepmobs = apend(deepmobs,spawnex:havemobs("mobs_monster",{"mese_monster"}) )
deepspawn.altitudes = {-500,-100}
deepspawn.mobs = deepmobs
spawnex:addspawns(deepspawn)


-- ==============
-- Beach mobs

local beachmobs = spawnex:havemobs("mobs_turtles",{"turtle"})

spawnex:addspawns( {
	spawn_on = {"default:sand"},
	when_near = {"default:water_source"},
	light = {0,5},
	altitudes = {-31000,31000},
	chance = 300,
	daytoggle = nil,
	mobs = beachmobs
} )

-- TODO
-- Populate ethereal locations with NSSM mobs and dragons

-- ============================
--	{name = "dmobs",beasts = {"dragon","dragon2","dragon3","dragon4","dragon_armor_steel","dragon_black","dragon_blue","dragon_egg_fire","dragon_egg_ice","dragon_egg_lightning","dragon_egg_poison","dragon_gem","dragon_gem_fire","dragon_gem_ice","dragon_gem_lightning","dragon_gem_poison","dragon_great","dragon_great_tame","dragon_green","dragon_red"},follow={"mobs:lava_orb","bucket:bucket_lava"}},
--	{name = "f46_dragon",beasts = {"dragon",},follow={"mobs:lava_orb","bucket:bucket_lava"}},
	{
		name = "nssm",
		monsters = {"night_master","night_master_2","night_master_1","moonheron","lava_titan","crocodile","echidna","ant_soldier","giant_sandworm","ant_worker","mantis_beast","mese_dragon","snow_biter","swimming_duck","uloboros","sandworm","icelamander","manticore","larva","mese_dragon_tame","duckking","ant_queen","dolidrosaurus","octopus","xgaloctopus","daddy_long_legs","pumpking","tarantula","tarantula_propower","sand_bloco","flying_duck","bloco","duck","crab","enderduck","pumpboom_small","pumpboom_medium","pumpboom_large","werewolf","mantis","phoenix","scrausics","spiderduck","white_werewolf","masticone","kraken","signosigno","icesnake","black_widow"},
		follow={"nssm:worm_flesh","nssm:tentacle","nssm:duck_legs"} -- interim solution until I get fodder
	},


