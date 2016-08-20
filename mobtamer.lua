minetest.register_tool("vivarium:mobtamer", {
	description = "Mob Tamer",
	inventory_image = "mobs_nametag.png^[colorize:blue:90",
	wield_image = "mobs_nametag.png^[colorize:blue:90",
	range = 5,
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		local maxuses = 30

		local pos = user:getpos()
		pos = {x=pos.x+math.random(1,2),y=pos.y+1,z=pos.z+math.random(1,2)}

		-- here get the mob to the left
		local inventory = user:get_inventory()
		local eggname = ''
		for idx,x in pairs(inventory:get_list("main") ) do
			if x:get_name() == "vivarium:mobtamer" then
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
			luae.state="walk"
			luae.owner = user:get_player_name()
			luae.tamed = true
			bomf(pos,2 )
		else
			luaobj:remove()
			minetest.chat_send_player(user:get_player_name(),"Not a mob!")
		end

		itemstack:add_wear(math.ceil(65536/maxuses))
		return itemstack

	end,
})

minetest.register_craft({
	output = "vivarium:mobtamer",
	recipe = {
		{"mobs:leather","mobs:magic_lasso","mobs:leather"},
		{"mobs:nametag","mobs:nametag","mobs:nametag"}
	}
})

