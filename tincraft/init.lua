--some crafts to make tin less useless.

local tin = "moreores:tin_ingot"
local dstone = "default:desert_stone"

core.register_craft({
	output = "tincraft:strong_tin",
	recipe = {
		{tin,tin,tin},
		{tin,"default:coal_lump",tin},
		{tin,tin,tin},
	}
})

core.register_craft({
	output = "tincraft:softlock",
	type = "cooking",
	cooktime = 20,
	recipe = "tincraft:strong_tin"
})

if minetest.get_modpath("protector") then
	core.register_craft({
		output = "protector:protect2",
		recipe = {
			{dstone,dstone,dstone},
			{dstone,"tincraft:softlock",dstone},
			{dstone,dstone,dstone},
		}
	})

	minetest.register_craftitem("tincraft:softlock", {
		description = "Malleable Lock",
		inventory_image = "protector_logo.png^[colorize:blue:60"
	})
end

minetest.register_craftitem("tincraft:strong_tin", {
	description = "Strengthened tin",
	inventory_image = "moreores_tin_ingot.png^[colorize:yellow:30"
})

