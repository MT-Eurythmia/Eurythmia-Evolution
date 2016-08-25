-- Load the Vivarium features

vivarium = {}

dofile(minetest.get_modpath("vivarium")..'/soundeffects.lua')

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


