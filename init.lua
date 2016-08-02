-- Falling Light
-- A simple mod for explorers
-- (C) Tai "DuCake" Kedzierski 2016
-- Provided to you under LGPLv2

minetest.register_node("falling_light:light", {
	description = "Falling Light",
	paramtype = "light",
	light_source = 14,
	light_propagates = true,
	sunlight_propagates = true,
	tiles = {"default_sand.png"},
	groups = {crumbly = 3, falling_node = 1},
})

minetest.register_craft ({
        output = "falling_light:light 2",
	type = "shapeless",
        recipe = {"group:sand","default:torch"}
}
)
