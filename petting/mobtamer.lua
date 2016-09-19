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
			local airnodes = minetest.find_nodes_in_area(
				{x = pos.x -1, y = pos.y - 1, z = pos.z -1},
				{x = pos.x +1, y = pos.y + 1, z = pos.z +1},
				{"air","default:water_source","default:river_water_source"}
			)
			pos = airnodes[math.random(1,#airnodes)]

		else
			pos = pointed_thing.under
			pos = {x=pos.x,y=po.y+1,z=pos.z}
		end

		-- here get the mob to the left
		local inventory = user:get_inventory()
		local eggname = nil
		for idx,x in pairs(inventory:get_list("main") ) do
			if x:get_name() == "petting:mobtamer" then
				break
			end
			eggname = x:get_name()
		end

		if eggname == nil then
			minetest.chat_send_player(user:get_player_name(), ".... what. Report Mob Tamer failure to DuCake with screenshot of your inventory.")
			return
		end
		if eggname:sub(1,1) == ":" then
			minetest.chat_send_player(user:get_player_name(), "Your monster is ill-defined. Please let DuCake know")
			return
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
			if luae.attack_type == nil then luae.attack_type = "dogfight" end
			luae.runaway = false

			luae.armor = math.ceil(luae.armor * 0.8)
			local o_wv = luae.walk_velocity or 0
			local o_rv = luae.run_velocity or 0
			luae.walk_velocity = math.ceil(o_wv * 1.2)
			luae.run_velocity = math.ceil(o_rv * 1.2)
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

