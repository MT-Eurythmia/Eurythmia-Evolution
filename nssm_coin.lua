
-- +++++++++++++++++++++++++++++++++++++++++
core.register_craft( {

	output = "nssm:surimi",
	--type = "shapeless",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:grass","default:grass","default:grass"}, -- group grass?
		{"group:sand","group:sand","group:sand"},
	}

})

local metals = "default:steel_ingot"
if minetest.get_modpath("moreores") then
	metals = "moreores:tin_ingot"
end

function vivarium:register_coin(coinname,coindesc,cmaterial,overimg)
	minetest.register_craftitem("vivarium:coin_"..coinname, {
		description = coindesc,
	})

	minetest.register_node("vivarium:coin_"..coinname, {
		description = coindesc,
		drawtype = "plantlike",
		paramtype = "light",
		tiles = {"vmg_mushroom_steak.png"},
		inventory_image = "vivarium_coin.png^"..overimg,
		groups = {dig_immediate = 3},
	})

	core.register_craft( {

		output = "vivarium:coin_"..coinname,
		recipe = {
			{metals,cmaterial,metals},
			{cmaterial,cmaterial,cmaterial},
			{metals,cmaterial,metals},
		}

	})


	core.register_craft( {
		output = cmaterial.." 5",
		type = "shapeless",
		recipe = {
			"vivarium:coin_"..coinname,
		}
	})
end

vivarium:register_coin("nyan","Nyan Coin","default:nyancat","default_nc_front.png")
vivarium:register_coin("ice","Ice Monster Coin","nssm:frosted_amphibian_heart","frosted_amphibian_heart.png")
vivarium:register_coin("worm","Worms Coin","nssm:worm_flesh","worm_flesh.png")
vivarium:register_coin("scrausics","Scrausics Coin","nssm:raw_scrausics_wing","raw_scrausics_wing.png")
