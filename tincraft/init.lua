--some crafts to make tin less useless.

tincraft = {}

local tin = "moreores:tin_ingot"
local s_tin = "tincraft:strong_tin"

-- Make a more valuable tin product

minetest.register_craftitem("tincraft:strong_tin", {
	description = "Strengthened tin",
	inventory_image = "moreores_tin_ingot.png^[colorize:yellow:30"
})

core.register_craft({
	output = "tincraft:strong_tin",
	recipe = {
		{tin,tin,tin},
		{tin,"default:coal_lump",tin},
		{tin,tin,tin},
	}
})

-- For those who have not been able to mine iron/are afraid of the first mining trip.
-- Making steel from tin is deliberately laborious.

core.register_craft({
	output = "default:steel_ingot",
	type = "shapeless",
	recipe = {
		s_tin,s_tin,s_tin,s_tin,s_tin,s_tin,"default:stone","default:stone","default:stone",
	}
})


if minetest.get_modpath("protector") then
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

end

if minetest.get_modpath("inbox") then
	core.register_craft({
		output = "inbox:empty",
		recipe = {
			{"",s_tin,""},
			{s_tin,"",s_tin},
			{s_tin,s_tin,s_tin},
		}
	})
end

