minetest.register_tool("petting:mobtamer", {
	description = "Mob Tamer",
	inventory_image = "petting_mobtamer.png",
	wield_image = "petting_mobtamer.png",
	range = 10,
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		local maxuses = 30

		local pos = {}
		if pointed_thing.type ~= "node" then
			pos = user:getpos()
		else
			pos = pointed_thing.under
		end
		local airnodes = minetest.find_nodes_in_area(
			{x = pos.x -1, y = pos.y - 1, z = pos.z -1},
			{x = pos.x +1, y = pos.y + 1, z = pos.z +1},
			{"air","default:water_source","default:lava_source","default:river_water_source"}
		)
		pos = airnodes[math.random(1,#airnodes)]


		-- here get the mob to the left
		local inventory = user:get_inventory()
		local eggname = ''
		for idx,x in pairs(inventory:get_list("main") ) do
			if x:get_name() == "petting:mobtamer" then
				break
			end
			eggname = x:get_name()
		end


		local luaobj = minetest.add_entity(pos,eggname )
		local luae = luaobj:get_luaentity()
		if luae then
			inventory:remove_item("main", eggname)

			luae.type="npc"
			luae.attacks_monsters=true
			luae.state="stand"
			luae.owner = user:get_player_name()
			luae.tamed = true
			luae.health = luae.hp_max
			vivarium:bomf(pos,2 )
		else
			luaobj:remove()
			minetest.chat_send_player(user:get_player_name(),"Not a mob!")
		end

		if not minetest.check_player_privs(user:get_player_name(), {creative=true}) then
			itemstack:add_wear(math.ceil(65536/maxuses))
		end
		return itemstack

	end,
})

minetest.register_craft({
	output = "petting:mobtamer",
	recipe = {
		{"mobs:leather","mobs:magic_lasso","mobs:leather"},
		{"mobs:nametag","mobs:nametag","mobs:nametag"}
	}
})

