
monstercoin = {}

-- +++++++++++++++++++++++++++++++++++++++++
--[[
core.register_craft( {

	output = "nssm:surimi",
	--type = "shapeless",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:grass","default:grass","default:grass"}, -- group grass?
		{"group:sand","group:sand","group:sand"},
	}

})
--]]

local metals = "default:coal_lump"
if minetest.get_modpath("moreores") then
	metals = "moreores:tin_ingot"
end

function monstercoin:register_coin(coinname,coindesc,cmaterial,overimg)
	local coinimg = "monstercoin_coin.png^"..overimg

	minetest.register_craft_item("monstercoin:coin_"..coinname, {
		description = coindesc,
		inventory_image = coingimg,
	})

	core.register_craft( {

		output = "monstercoin:coin_"..coinname,
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
			"monstercoin:coin_"..coinname,
		}
	})
end

monstercoin:register_coin("nyan","Nyan Coin","default:nyancat","default_nc_front.png")

if minetest.get_modpath("nssm") then
	monstercoin:register_coin("ice","Ice Monster Coin","nssm:frosted_amphibian_heart","frosted_amphibian_heart.png")
	monstercoin:register_coin("worm","Worms Coin","nssm:worm_flesh","worm_flesh.png")
	monstercoin:register_coin("scrausics","Scrausics Coin","nssm:raw_scrausics_wing","raw_scrausics_wing.png")
end
