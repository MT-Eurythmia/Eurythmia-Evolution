local dstone = "default:desert_stone"

minetest.register_craftitem("tincraft:softlock", {
	description = "Malleable Lock",
	inventory_image = "protector_logo.png^[colorize:blue:60"
})

core.register_craft({
	output = "tincraft:softlock",
	type = "cooking",
	cooktime = 20,
	recipe = "tincraft:strong_tin"
})

core.register_craft({
	output = "protector:protect2",
	recipe = {
		{dstone,dstone,dstone},
		{dstone,"tincraft:softlock",dstone},
		{dstone,dstone,dstone},
	}
})


