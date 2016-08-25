-- Load the Vivarium features

vivarium = {}

dofile(minetest.get_modpath("vivarium") .. "/falling_light.lua")
dofile(minetest.get_modpath("vivarium") .. "/staves.lua")

if minetest.get_modpath("nssm") then
	dofile(minetest.get_modpath("vivarium") .. "/nssm_coin.lua")
end
if minetest.get_modpath("moreores") then
	dofile(minetest.get_modpath("vivarium") .. "/tincrafts.lua")
end

-- ++++ backwards compat with old deployments

function vivarium:realias(newmod,toolname)
	minetest.register_alias("vivarium:"..toolname,newmod..":"..toolname)
end

vivarium:realias("petting","mobtamer")
vivarium:realias("staffmagic","staff_clone")
vivarium:realias("staffmagic","staff_stack")
vivarium:realias("staffmagic","staff_boom")
vivarium:realias("staffmagic","staff_creator")
vivarium:realias("staffmagic","staff_melt")
vivarium:realias("fallinglight","light")
