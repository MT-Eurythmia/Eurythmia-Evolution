
-- Staff of Water (based on Staff of Light by Xanthin)
minetest.register_tool("vivarium:water_staff", {
	description = "Staff of Water",
	inventory_image = "water_staff.png^[colorize:blue:30",
	wield_image = "water_staff.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)

		if pointed_thing.type ~= "node" then
			return
		end

		local pos = pointed_thing.under
		local pname = user:get_player_name()

		if minetest.is_protected(pos, pname) then
			minetest.record_protection_violation(pos, pname)
			return
		end

		local node = minetest.get_node(pos).name

		if node == "default:ice"
		or node == "default:snowblock" then

			minetest.swap_node(pos, {name = "default:water_source"})

			return itemstack
		end

	end,
})
