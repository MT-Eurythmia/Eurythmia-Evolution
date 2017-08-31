-- Adding spawning 

dofile(minetest.get_modpath("petting").."/spawntable.lua")

--[[

spawnex:add_spawns({
        spawn_on = {}, --nodes, e.g. default:dirt_with_grass
        when_near = {}, --nodes, e.g. default:leaves
        light = {0,20}, -- minimum and maximum light
        altitudes = {-31000,31000}, --altitude range
        daytoggle = nil, -- nil -> anytime, true -> only by day, false -> only at night
        chance = 900, -- FIXME NO!!
        mobs = {
                {"modname:mobname",chance}, -- FIXME this is how it was MEANT to be
                {"modname:mobname",chance},
        }
},)

--function mobs:spawn_specific(name, nodes, neighbors, min_light, max_light,
--        interval, chance, active_object_count, min_height, max_height, day_toggle)

--]]

for i,rs in pairs(spawnex.spawnrules) do -- process RuleSets
	for j,mobname in pairs(rs.mobs) do
		mobs:spawn_specific(
			mobname,
			rs.spawn_on,
			rs.spawn_near,
			rs.light[1],
			rs.light[2],
			5,
			rs.chance,
			2,
			rs.altitudes[1],
			rs.altitudes[2],
			rs.daytoggle
		)
	end
end
