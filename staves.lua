-- Staff of X (based on Staff of Light by Xanthin)

minetest.register_tool("vivarium:staff_stack", { -- this will be the wall staff
	description = "Stacking Staff (build big columns)",
	inventory_image = "water_staff.png^[colorize:yellow:90",
	wield_image = "water_staff.png^[colorize:yellow:90",
	range = 5,
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


		local height = 10
		local targetnode = minetest.get_node(pos).name
		local userpos = user:getpos()

		local relpos = (userpos.y - pos.y)/math.sqrt((userpos.y - pos.y)^2)
		local lower = 0 ; local higher = 0
		if relpos < 0 then
			-- minetest.chat_send_player(pname, "Stack down")
			lower = -1*height
		elseif relpos > 0 then
			-- minetest.chat_send_player(pname, "Stack up")
			higher = height
		end

                local airnodes = minetest.find_nodes_in_area(
                        {x = pos.x, y = pos.y+lower, z = pos.z},
                        {x = pos.x, y = pos.y+higher, z = pos.z},
                        {"air"}
		)
		minetest.sound_play("vivarium_pom", {
			pos = pos,
			max_hear_distance = 10
		})

                for _,fpos in pairs(airnodes) do
			minetest.swap_node(fpos, {name = targetnode })
		end
		return itemstack

	end,
})

minetest.register_tool("vivarium:staff_clone", { -- this will be the floor staff
	description = "Floor Master Staff (extend nodes horzontally from above, side or below)",
	inventory_image = "water_staff.png^[colorize:green:90",
	wield_image = "water_staff.png^[colorize:green:90",
	range = 5,
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


		local breadth = 2 -- full square is 2*breadth+1 on side
		local targetnode = minetest.get_node(pos).name
		local userpos = user:getpos()
		local relpos = 0
		if (userpos.y - pos.y)^2 > 2 then -- if clearly above/below
			relpos = (userpos.y - pos.y)/math.sqrt((userpos.y - pos.y)^2)
		end
                local airnodes = minetest.find_nodes_in_area(
                        {x = pos.x - breadth, y = pos.y+relpos, z = pos.z - breadth},
                        {x = pos.x + breadth, y = pos.y+relpos, z = pos.z + breadth},
                        {"air"}
		)
		minetest.sound_play("vivarium_pom", {
			pos = pos,
			max_hear_distance = 10
		})

                for _,fpos in pairs(airnodes) do
			minetest.swap_node(fpos, {name = targetnode })
		end
		return itemstack

	end,
})

minetest.register_tool("vivarium:staff_boom", { -- this will be the floor staff
	description = "Bomf Staff (remove nodes of pointed type)",
	inventory_image = "water_staff.png^[colorize:black:90",
	wield_image = "water_staff.png^[colorize:black:90",
	range = 10,
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


		local radius = 3
		local targetnode = minetest.get_node(pos).name
		local userpos = user:getpos()
                local targetnodes = minetest.find_nodes_in_area(
                        {x = pos.x - radius, y = pos.y-radius, z = pos.z - radius},
                        {x = pos.x + radius, y = pos.y+radius, z = pos.z + radius},
                        {targetnode}
		)

		minetest.add_particlespawner(
			200, --amount
			0.1, --time
			{x=pos.x-radius/2, y=pos.y-radius/2, z=pos.z-radius/2}, --minpos
			{x=pos.x+radius/2, y=pos.y+radius/2, z=pos.z+radius/2}, --maxpos
			{x=-0, y=-0, z=-0}, --minvel
			{x=1, y=1, z=1}, --maxvel
			{x=-0.5,y=5,z=-0.5}, --minacc
			{x=0.5,y=5,z=0.5}, --maxacc
			0.1, --minexptime
			1, --maxexptime
			3, --minsize
			4, --maxsize
			false, --collisiondetection
			"tnt_smoke.png" --texture
		)
		minetest.sound_play("vivarium_pom", {
			pos = pos,
			max_hear_distance = 10
		})


                for _,fpos in pairs(targetnodes) do
			minetest.swap_node(fpos, {name = "air" })
		end
		return itemstack

	end,
})

-- quick and dirty tool to repair carnage caused by NSSM ice mobs
minetest.register_tool("vivarium:staff_melt", {
	description = "Staff of Melting (replace snow/ice with node under it, or above it)",
	inventory_image = "water_staff.png^[colorize:blue:90",
	wield_image = "water_staff.png^[colorize:blue:90",
	range = 12,
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


		local breadth = 2 -- full square is 2*breadth+1 on side
                local frostarea = minetest.find_nodes_in_area(
                        {x = pos.x - breadth, y = pos.y, z = pos.z - breadth},
                        {x = pos.x + breadth, y = pos.y, z = pos.z + breadth},
                        {"default:ice","default:snowblock"}
		)

                for _,fpos in pairs(frostarea) do
				local replname = minetest.get_node({x=fpos.x,y=fpos.y-1,z=fpos.z}).name
				if replname == "default:ice" or replname == "default:snowblock" then
					local newreplname = minetest.get_node({x=fpos.x,y=fpos.y+1,z=fpos.z}).name
					if newreplname ~= "air" then --  don't dig down so much
						-- TODO if replname == air, then get average node around  that is not air, use that
						replname = newreplname
					end
				end
				local sealevel = 0 -- TODO get the custom setting for sealevel
				if fpos.y > 0 and replname == "default:water_source" then -- don't bother with water above sea level
					replname = "air"
				end
				minetest.swap_node(fpos, {name = replname })
		end
		return itemstack

	end,
})

minetest.register_alias("vivarium:water_staff","vivarium:staff_melt")
