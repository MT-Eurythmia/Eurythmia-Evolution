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
vivarium:realias("staffmagic","staff_creative")
vivarium:realias("staffmagic","staff_melt")
vivarium:realias("fallinglight","falling_light")
--fallinglight:falling_light


if minetest.get_modpath("nssm") then
	anycoin:register_coin("scrausics","Scrausics Coin","nssm:raw_scrausics_wing","raw_scrausics_wing.png",3)
	anycoin:register_coin("moonheron","Moonheron Coin","nssm:heron_leg","heron_leg.png",3)
end
