-- Load the Vivarium features

vivarium = {}
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


if minetest.get_modpath("nssm") then
	anycoin:register_coin("scrausics","Scrausics Coin","nssm:raw_scrausics_wing",3)
	anycoin:register_coin("moonheron","Moonheron Coin","nssm:raw_moonheron_leg",3)
end
