pipeworks = {
	enable_deployer = true,
	enable_dispenser = false,
	enable_node_breaker = true,

	rules_all = {{x=0, y=0, z=1},{x=0, y=0, z=-1},{x=1, y=0, z=0},{x=-1, y=0, z=0},
		{x=0, y=1, z=1},{x=0, y=1, z=-1},{x=1, y=1, z=0},{x=-1, y=1, z=0},
		{x=0, y=-1, z=1},{x=0, y=-1, z=-1},{x=1, y=-1, z=0},{x=-1, y=-1, z=0},
		{x=0, y=1, z=0}, {x=0, y=-1, z=0}}
}

function pipeworks.may_configure(pos, player)
	local name = player:get_player_name()
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")

	if owner ~= "" then -- wielders and filters
		return owner == name
	end
	return not minetest.is_protected(pos, name)
end

function pipeworks.logger(msg)
	print("[pipeworks] "..msg)
end

dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/common.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/autocrafter.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/wielder.lua")

for _, name in ipairs({"deployer"}) do
	hopper:add_container({
		{"bottom", "pw_like:"..name.."_off", "main"},
		{"side", "pw_like:"..name.."_off", "main"},

		{"bottom", "pw_like:"..name.."_on", "main"},
		{"side", "pw_like:"..name.."_on", "main"},
	})
end

for _, name in ipairs({"nodebreaker"}) do
	hopper:add_container({
		{"top", "pw_like:"..name.."_off", "main"},

		{"top", "pw_like:"..name.."_on", "main"},
	})
end
