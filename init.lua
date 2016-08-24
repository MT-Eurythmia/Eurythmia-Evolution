-- Load the Vivarium features

vivarium = {}

dofile(minetest.get_modpath("vivarium") .. "/falling_light.lua")
dofile(minetest.get_modpath("vivarium") .. "/staves.lua")
dofile(minetest.get_modpath("vivarium") .. "/capturing.lua")
dofile(minetest.get_modpath("vivarium") .. "/mobtamer.lua")
if minetest.get_modpath("nssm") then
	dofile(minetest.get_modpath("vivarium") .. "/nssm_coin.lua")
end
if minetest.get_modpath("moreores") then
	dofile(minetest.get_modpath("vivarium") .. "/tincrafts.lua")
end
