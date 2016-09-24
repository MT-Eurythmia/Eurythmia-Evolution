-- Remove basic flame fast

minetest.register_abm{
	nodenames = {"fire:basic_flame"},
	neighbors = {"group:flammable","air"},
	interval = 1,
	chance = 3,
	action = function(pos)
		minetest.dig_node(pos) -- use "dig" to also stop the sound
	end,
}
