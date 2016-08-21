minetest.register_privilege("staffer","Trust players to use staves")

vivarium.forbidden_nodes = {
	"default:stone_with",
	"moreores:mineral_",
	"default:nyancat",
	".+steelblock", -- lua does not include the "|" operator which is a PAIN.
	".+copperblock",
	".+bronzeblock",
	".+goldblock",
	".+diamondblock",
	".+tin_block",
	".+silver_block",
	".+mithril_block",
	"default:mese",
	"protector:",
	"basic_machines:",
	"ethereal:crystal_spike",
	".+crystal_block",
	"mobs:beehive",
	"mobs:spawner",
	"more_chests:"
}

function vivarium:tellem(player,message)
	minetest.chat_send_player(player:get_player_name() , message)
end

function vivarium:wearitem(itemstack,maxuses)
	itemstack:add_wear(math.ceil(65536/maxuses))
	return itemstack
end

function staffcheck(player)
	local stafflevel = 0
	if minetest.check_player_privs(player:get_player_name(), {staffer=true}) then stafflevel = 1; end
	if minetest.check_player_privs(player:get_player_name(), {creative=true}) then stafflevel = 100; end
	--minetest.chat_send_all("Staff level : "..stafflevel)
	return stafflevel
end

function isforbidden(nodename)
	for _,pat in pairs(vivarium.forbidden_nodes) do
		if string.match(nodename,pat) then
			--minetest.chat_send_all("Forbidden : "..nodename)
			return true
		end
	end
	return false
end

function bomf(pos,radius)
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
end


function vivarium:mobheal(user,luae)
	if not luae.owner or user:get_player_name() ~= luae.owner then
		vivarium:tellem(user,"This " ..luae.name .. " is not yours.")
		return
	end
	if luae.health < luae.hp_min then
		luae.health = luae.hp_min
		vivarium:tellem(user,"Your " ..luae.name .. " has been healed.")
	else
		vivarium:tellem(user,"This " ..luae.name .. " does not need healing.")
	end
end

function vivarium:mobtransform(user,luae, forced)
	if not forced and math.random(1,20) > 1 then return ; end -- 1:20 chance of transforming

	luae.state="walk"

	if luae.type == "monster" then
		luae.type="npc"
		luae.attacks_monsters=true
		vivarium:tellem(user,luae.name .. " became a friendly NPC")
	elseif luae.type == "npc" then
		luae.type = "animal"
		vivarium:tellem(user,luae.name .. " became a docile animal")
	elseif luae.type == "animal" then
		luae.type = "monster"
		luae.passive = false
		vivarium:tellem(user,luae.name .. " became a vicious monster")
	end
end

-- Staff of X (based on Staff of Light by Xanthin)

minetest.register_tool("vivarium:staff_stack", { -- this will be the wall staff
	description = "Column Staff (make walls)",
	inventory_image = "water_staff.png^[colorize:yellow:90",
	wield_image = "water_staff.png^[colorize:yellow:90",
	range = 12,
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		local stafflevel = staffcheck(user)
		if stafflevel < 1 then return; end

		if pointed_thing.type ~= "node" then
			if stafflevel < 2 then return; end

			if pointed_thing.type == "object" then
				local newpos = pointed_thing.ref:getpos()
				bomf(newpos,2 )
				local luae = pointed_thing.ref:get_luaentity()
				
				vivarium:mobtransform(user,luae,true)
			end
			return
		end

		local pos = pointed_thing.under
		local pname = user:get_player_name()

		if minetest.is_protected(pos, pname) then
			minetest.record_protection_violation(pos, pname)
			return
		end


		local height = 5
		local targetnode = minetest.get_node(pos).name
		local userpos = user:getpos()

		local relpos = (userpos.y - pos.y)/math.sqrt((userpos.y - pos.y)^2)
		local lower = 0 ; local higher = 0

		if isforbidden(targetnode) and stafflevel < 2 then
			targetnode = "default:dirt"
		end


		if relpos < 0 then
			-- minetest.chat_send_player(pname, "Stack down")
			lower = -1*height
		elseif relpos >= 0 then
			-- minetest.chat_send_player(pname, "Stack up")
			higher = height
		end

                local airnodes = minetest.find_nodes_in_area(
                        {x = pos.x, y = pos.y+lower, z = pos.z},
                        {x = pos.x, y = pos.y+higher, z = pos.z},
                        {"air","default:water_source","default:lava_source","default:river_water_source"}
		)

		bomf(pos,2)
                for _,fpos in pairs(airnodes) do
			minetest.swap_node(fpos, {name = targetnode })
		end
		if staffcheck(user) < 90 then itemstack = vivarium:wearitem(itemstack,50); end
		return itemstack

	end,
})

minetest.register_tool("vivarium:staff_clone", { -- this will be the floor staff
	description = "Staff of Cloning (make floors)",
	inventory_image = "water_staff.png^[colorize:green:90",
	wield_image = "water_staff.png^[colorize:green:90",
	range = 12,
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		local stafflevel = staffcheck(user)
		if stafflevel < 1 then return; end

		if pointed_thing.type ~= "node" then

			if stafflevel < 2 then -- can only clone mobs if super staffer else abuse
				return
			end
			if pointed_thing.type == "object" then
				local newpos = pointed_thing.ref:getpos()
				newpos = {x=newpos.x+math.random(-1,1), y=newpos.y+0.5, z=newpos.z+math.random(-1,1)}
				bomf(newpos,2 )
				minetest.add_entity(newpos, pointed_thing.ref:get_luaentity().name)
			end
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
		--[[
		local relpos = 0
		if (userpos.y - pos.y)^2 > 2 then -- if clearly above/below
			relpos = (userpos.y - pos.y)/math.sqrt((userpos.y - pos.y)^2)
		end
		--]]

		if isforbidden(targetnode) and stafflevel < 2 then
			targetnode = "default:dirt"
		end

                local airnodes = minetest.find_nodes_in_area(
                        {x = pos.x - breadth, y = pos.y, z = pos.z - breadth},
                        {x = pos.x + breadth, y = pos.y, z = pos.z + breadth},
                        {"air","default:water_source","default:lava_source","default:river_water_source"}
		)
		
		bomf(pos,breadth*2)

                for _,fpos in pairs(airnodes) do
			minetest.swap_node(fpos, {name = targetnode })
		end

		if staffcheck(user) < 90 then itemstack = vivarium:wearitem(itemstack,50); end
		return itemstack

	end,
})

minetest.register_tool("vivarium:staff_boom", {
	description = "Bomf Staff (delete nodes)",
	inventory_image = "water_staff.png^[colorize:black:140",
	wield_image = "water_staff.png^[colorize:black:140",
	range = 12,
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		local stafflevel = staffcheck(user)
		if stafflevel < 2 then return; end

		if pointed_thing.type ~= "node" then
			if pointed_thing.type == "object" then
				bomf(pointed_thing.ref:getpos(),1 )
				pointed_thing.ref:remove()
			end
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

		bomf(pos,radius)

                for _,fpos in pairs(targetnodes) do
			minetest.swap_node(fpos, {name = "air" })
		end
		return itemstack

	end,
})

-- quick and dirty tool to repair carnage caused by NSSM ice mobs
minetest.register_tool("vivarium:staff_melt", {
	description = "Staff of Melting (Fix Ice Mobs damage)",
	inventory_image = "water_staff.png^[colorize:blue:90",
	wield_image = "water_staff.png^[colorize:blue:90",
	range = 12,
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)

		if pointed_thing.type ~= "node" then
			if pointed_thing.type == "object" then
				local newpos = pointed_thing.ref:getpos()
				bomf(newpos,2 )
				local luae = pointed_thing.ref:get_luaentity()
				
				vivarium:mobheal(user,luae)
				vivarium:mobtransform(user,luae)
			end
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

		bomf(pos,breadth*2)

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
				--minetest.chat_send_all("Replicating "..replname)
				if isforbidden(replname) then
					replname = "default:dirt"
				end
				minetest.swap_node(fpos, {name = replname })
		end

		if staffcheck(user) < 90 then itemstack = vivarium:wearitem(itemstack,50); end
		return itemstack

	end,
})

minetest.register_craft(
{
	output = "vivarium:staff_melt",
	recipe = {
		{"default:mese_crystal_fragment","bucket:bucket_lava","default:mese_crystal_fragment"},
		{"","default:obsidian_shard",""},
		{"","default:obsidian_shard",""},
	}
}
)
