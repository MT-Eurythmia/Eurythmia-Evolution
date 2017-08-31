
anycoin = {}

local metals = "default:coal_lump"
if minetest.get_modpath("moreores") then
	metals = "moreores:tin_ingot"
end

function anycoin:register_coin(coinname,coindesc,cmaterial,overimg,cvalue)

	local coinimg = "anycoin_coin.png^"..overimg
	local value = cvalue
	if not cvalue then
		cvalue = 1
	end

	minetest.register_craftitem(":anycoin:coin_"..coinname, {
		description = coindesc .. " ("..cvalue.." ac-)",
		inventory_image = coinimg,
		coinvalue = cvalue
	})
	
	core.register_craft({
		type = "shapeless",
		output = "anycoin:anycoin "..cvalue,
		recipe = {"anycoin:coin_"..coinname}
	}
	)
	
	if cmaterial == "moreores:tin_ingot" then metals = "default:coal_lump" end
	core.register_craft( {
		output = "anycoin:coin_"..coinname,
		recipe = {
			{metals,metals,metals},
			{cmaterial,metals,cmaterial},
			{metals,metals,metals},
		}

	})

end

-- A base coin to serve as an exchange base

minetest.register_craftitem("anycoin:anycoin", {
	description = "AnyCoin (1 ac-)",
	inventory_image = "anycoin_coin.png",
	coinvalue = 1,
	stack_max = 500,
})

minetest.register_craftitem("anycoin:fivercoin", {
	description = "FiverCoin (5 ac-)",
	inventory_image = "anycoin_coin.png^[colorize:green:60",
	coinvalue = 5,
	stack_max = 500,
})

minetest.register_craftitem("anycoin:tennercoin", {
	description = "TennerCoin (10 ac-)",
	inventory_image = "anycoin_coin.png^[colorize:purple:60",
	coinvalue = 10,
	stack_max = 500,
})

local basecoin = "anycoin:anycoin"

core.register_craft( {

	output = "anycoin:fivercoin",
	type = "shapeless",
	recipe = {
		basecoin,basecoin,basecoin,basecoin,basecoin
	}

})

core.register_craft( {

	output = "anycoin:tennercoin",
	type = "shapeless",
	recipe = {
		"anycoin:fivercoin","anycoin:fivercoin"
	}

})

core.register_craft( {
	type = "shapeless",
	output = "anycoin:anycoin 10",
	recipe = {"anycoin:tennercoin"}

})

core.register_craft( {
	type = "shapeless",
	output = "anycoin:anycoin 5",
	recipe = {"anycoin:fivercoin"}

})

anycoin:register_coin("iron","Iron Coin","default:steel_ingot","[colorize:red:50",10)
anycoin:register_coin("copper","Copper Coin","default:copper_ingot","[colorize:orange:50",15)
anycoin:register_coin("bronze","Bronze Coin","default:bronze_ingot","[colorize:orange:90",20)
anycoin:register_coin("gold","Gold Coin","default:gold_ingot","[colorize:yellow:90",30)
anycoin:register_coin("diamond","Diamond Coin","default:diamond","default_diamond.png",40)
anycoin:register_coin("mese","Mese Coin","default:mese_crystal","default_mese_crystal.png",50)
