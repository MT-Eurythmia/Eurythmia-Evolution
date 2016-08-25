
anycoin = {}

local metals = "default:coal_lump"
if minetest.get_modpath("moreores") then
	metals = "moreores:tin_ingot"
end

function anycoin:register_coin(coinname,coindesc,cmaterial,cvalue)
	local overimg = cmaterial.inventory_image or "default_dirt_with_grass.png"
	local coinimg = "anycoin_coin.png^"..overimg
	local value = cvalue
	if not cvalue then
		cvalue = 1
	end

	minetest.register_craft_item("anycoin:coin_"..coinname, {
		description = coindesc .. " ("..cvalue.." ac-)",
		inventory_image = coingimg,
		coinvalue = cvalue
	})
	
	if cmaterial =~ nil then
		core.register_craft({
			type = "shapeless",
			output = "anycoin:coin_base "..cvalue,
			recipe = {"anycoin:coin_"..coinname}
		}
		)
	end

	core.register_craft( {

		output = "anycoin:coin_"..coinname,
		recipe = {
			{metals,cmaterial,metals},
			{cmaterial,cmaterial,cmaterial},
			{metals,cmaterial,metals},
		}

	})

end

-- A base coin to serve as an exchange base
anycoin:register_coin("base","AnyCoin",nil,1)

local basecoin = "anycoin:coin_base"

core.register_craft( {

	output = "anycoin:coin_base9",
	recipe = {
		{basecoin,basecoin,basecoin},
		{basecoin,basecoin,basecoin},
		{basecoin,basecoin,basecoin},
	}

})

minetest.register_craft_item("anycoin:coin_base", {
	description = "AnyCoin9 (9 ac-)",
	inventory_image = "default_dirt_with_dry_grass.png",
	coinvalue = 9
})

