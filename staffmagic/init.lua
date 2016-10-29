minetest.register_privilege("staffer","Trust players to use staves")
minetest.register_privilege("super_staffer","Trust players to use staves responsibly")
minetest.register_privilege("staff_master","Full trust.")

staffmagic = {}

staffmagic.staff_power = {
	boom = "default:mese",
	expand = "default:obsidian",
	stack = "default:mese_crystal",
	clone = "default:diamond"
}

staffmagic.forbidden_nodes = {
	"default:stone_with",
	"moreores:mineral_",
	"default:nyancat",
	"farming:.+",
	"steel_bottle",
	".+steelblock", -- lua does not include the "|" operator which is a PAIN.
	".+copperblock",
	"copperpatina",
	".+bronzeblock",
	".+goldblock",
	".+diamondblock",
	".+tin_block",
	".+silver_block",
	".+mithril_block",
	"default:mese$",
	"protector:",
	"basic_machines:",
	"ethereal:crystal_spike",
	".+crystal_block",
	"mobs:beehive",
	"mobs:spawner",
	"more_chests:",
	"fire:basic_flame",
	"fire:permanent_fire",
}

function staffmagic:tellem(player,message)
	minetest.chat_send_player(player:get_player_name() , message)
end

function staffmagic:hurtplayer(user)
	local hp = user:get_hp()
	user:set_hp(math.floor(hp/2))
end

function staffmagic:wearitem(itemstack,maxuses)
	itemstack:add_wear(math.ceil(65536/maxuses))
	return itemstack
end

function staffmagic:staffcheck(player,priv)
	local privset = {}
	privset[priv]= true
	return minetest.check_player_privs(player:get_player_name(), privset)
end

function staffmagic:isforbidden(nodename)
	for _,pat in pairs(staffmagic.forbidden_nodes) do
		if string.match(nodename,pat) then
			--minetest.chat_send_all("Forbidden : "..nodename)
			return true
		end
	end
	return false
end

local getarea = function (pos,radius)
	-- get nodes in an area around origin pos
	-- nearer the centre, greater chance of capturing a node
	-- at the edges, minimal chance
	-- for y, y-1 and y+1
	
	local nodeset = {}
	for dy=-1,1 do
	  for dx=-radius,radius do
	    for dz=-radius,radius do
		local tpos = {
		  x=pos.x+dx,
		  y=pos.y+dy,
		  z=pos.z+dz,
		  }
		local tnode = minetest.get_node(tpos).name
		if minetest.get_node_group(tnode,"cracky") ~= 0
		  or minetest.get_node_group(tnode,"crumbly") > 0
		  --or tnode == "air"
		  then
			local amp = vector.distance(pos,tpos)
			if (1-amp/radius)*math.random(1,radius) > amp then
				nodeset[#nodeset+1] = tpos
			end
		end
	    end -- dz
	  end -- dx
	end
	return nodeset
end

function staffmagic:max(x,y)
	if x < y then return y
	else return x
	end
end
function staffmagic:min(x,y)
	if x < y then return x
	else return y
	end
end

function staffmagic:countpower(user,staff)
	local inventory = user:get_inventory()
	local powerup = staffmagic.staff_power[staff]
	for idx,x in pairs(inventory:get_list("main") ) do
		if x:get_name() == powerup then
			local count = x:get_count()
			if count > 100 then count = 100 end
			return math.floor(count/10)
		end
	end
	minetest.chat_send_player(user:get_player_name(),"No powerups! You need 10 "..staffmagic.staff_power[staff].." per extra 1 node")
	return 0
end

function staffmagic:mobheal(user,luae)
	if (not minetest.check_player_privs(user:get_player_name(), {creative=true}) ) and ( not luae.owner or user:get_player_name() ~= luae.owner) then
		staffmagic:tellem(user,"This " ..luae.name .. " is not yours.")
		return
	end
	if luae.health < luae.hp_min then
		luae.health = luae.hp_min
		staffmagic:tellem(user,"The " ..luae.name .. " has been healed.")
	else
		staffmagic:tellem(user,"The " ..luae.name .. " does not need healing.")
	end
end

function staffmagic:mobtransform(user,luae, forced)
	if not forced and math.random(1,20) > 1 then return ; end -- 1:20 chance of transforming

	luae.state="walk"

	if luae.type == "monster" then
		luae.type="npc"
		luae.attacks_monsters=true
		staffmagic:tellem(user,luae.name .. " became a friendly NPC")
	elseif luae.type == "npc" then
		luae.type = "animal"
		staffmagic:tellem(user,luae.name .. " became a docile animal")
	elseif luae.type == "animal" then
		luae.type = "monster"
		luae.passive = false
		staffmagic:tellem(user,luae.name .. " became a vicious monster")
	end
end

minetest.register_tool("staffmagic:staff_stack", { -- this will be the wall staff
	description = "Stack Staff",
	inventory_image = "staffmagic_staff.png^[colorize:yellow:90",
	wield_image = "staffmagic_staff.png^[colorize:yellow:90",
	range = 12,
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if not staffmagic:staffcheck(user,"staffer") then return end

		if pointed_thing.type ~= "node" then
			return
		end

		local pos = pointed_thing.under
		local pname = user:get_player_name()

		if minetest.is_protected(pos, pname) then
			minetest.record_protection_violation(pos, pname)
			return
		end


		local height = 2
		height = height + staffmagic:countpower(user,"stack")
		local targetnode = minetest.get_node(pos).name
		local userpos = user:getpos()

		local relpos = (userpos.y - pos.y)/math.sqrt((userpos.y - pos.y)^2)
		local lower = 0 ; local higher = 0

		if staffmagic:isforbidden(targetnode) then
			staffmagic:hurtplayer(user)
			return
			--targetnode = "default:dirt"
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

		vivarium:bomf(pos,2)
                for _,fpos in pairs(airnodes) do
			minetest.swap_node(fpos, {name = targetnode })
		end

		itemstack = staffmagic:wearitem(itemstack,50);
		return itemstack

	end,
})

minetest.register_tool("staffmagic:staff_clone", {
	description = "Floor Staff",
	inventory_image = "staffmagic_staff.png^[colorize:green:90",
	wield_image = "staffmagic_staff.png^[colorize:green:90",
	range = 10,
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if not staffmagic:staffcheck(user,"staffer") then return end

		if pointed_thing.type ~= "node" then
			return
		end

		local pos = pointed_thing.under
		local playerpos = user:getpos()
		local pname = user:get_player_name()

		if minetest.is_protected(pos, pname) then
			minetest.record_protection_violation(pos, pname)
			return
		end


		local targetnode = minetest.get_node(pos).name
		local userpos = user:getpos()
		local range = 2 + staffmagic:countpower(user,"clone")

		-- first pos needs all coords smaller than end pos - normalize here
		local startpos = {x = staffmagic:min(pos.x,playerpos.x),y = pos.y,z = staffmagic:min(pos.z,playerpos.z)}
		local endpos = {x = staffmagic:max(pos.x,playerpos.x),y = pos.y,z = staffmagic:max(pos.z,playerpos.z)}

		local vdist = vector.distance(startpos,endpos)
		if vdist > range then
			minetest.chat_send_player(user:get_player_name(),"You are too far ("..math.ceil(vdist).."m). Your range is "..range.."m")
			return
		end

		if staffmagic:isforbidden(targetnode) then
			staffmagic:hurtplayer(user)
			return
		end

                local airnodes = minetest.find_nodes_in_area(
                        startpos,
			endpos,
                        {"air","default:water_source","default:lava_source","default:river_water_source"}
		)
		
		vivarium:bomf({x = (playerpos.x+pos.x)/2 , y = (playerpos.y+pos.y)/2 , z = (playerpos.z+pos.z)/2},4)

                for _,fpos in pairs(airnodes) do
			minetest.swap_node(fpos, {name = targetnode })
		end

		itemstack = staffmagic:wearitem(itemstack,50)
		return itemstack

	end,
})

minetest.register_tool("staffmagic:staff_sending",{
	description = "Sending Staff",
	inventory_image = "staffmagic_staff.png^[colorize:purple:90",
	wield_image = "staffmagic_staff.png^[colorize:purple:90",
	range = 5,
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		--if not staffmagic:staffcheck(user,"staffer") then return end
		if pointed_thing.type ~= "node" then
			if pointed_thing.ref and pointed_thing.ref:is_player() then return end
			if pointed_thing.type == "object" then
				local mobpos = pointed_thing.ref:getpos()
				local newpos = mobpos
				local playerpos = user:getpos()
				local distance = 10
				if pointed_thing.ref:get_luaentity().view_range then
					distance = math.ceil(pointed_thing.ref:get_luaentity().view_range * 1.5)
				end
				if distance > 30 then -- TODO this should be function of powerups
					distance = 30
				end
				
				local count = 10
				while (vector.distance(playerpos,newpos) < distance/2) and count > 0 do
					local airnodes = minetest.find_nodes_in_area(
						{x = playerpos.x -distance, y = playerpos.y - 10, z = playerpos.z -distance},
						{x = playerpos.x +distance, y = playerpos.y + 10, z = playerpos.z +distance},
						{"air","default:water_source","default:lava_source","default:river_water_source"}
					)
					newpos = airnodes[ math.random(1,#airnodes) ]
					count = count -1
				end

				vivarium:bomf( mobpos , 3)
				vivarium:bomf( newpos , 5)
				staffmagic:tellem(user,"You sent the " ..pointed_thing.ref:get_luaentity().name .. " packing "..math.ceil(vector.distance(mobpos,newpos)).."m away")
				pointed_thing.ref:moveto(newpos,true)
				itemstack = staffmagic:wearitem(itemstack,50)
				return itemstack
			end
			return
		end
	end
})

minetest.register_tool("staffmagic:staff_expand", {
	description = "Expansion Staff (spread nodes)",
	inventory_image = "staffmagic_staff.png^[colorize:pink:140",
	wield_image = "staffmagic_staff.png^[colorize:pink:140",
	range = 12,
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if not staffmagic:staffcheck(user,"staffer") then return end

		local radius = 3
		radius = radius + 2*staffmagic:countpower(user,"expand")

		if pointed_thing.type ~= "node" then
			return
		end

		if not staffmagic:staffcheck(user,"super_staffer") then return end

		local pos = pointed_thing.under
		local pname = user:get_player_name()

		if minetest.is_protected(pos, pname) then
			minetest.record_protection_violation(pos, pname)
			return
		end


		local targetnode = minetest.get_node(pos).name
		local userpos = user:getpos()
                local targetnodes = getarea(pos,radius)

		vivarium:bomf(pos,radius)

                for _,fpos in pairs(targetnodes) do
			if string.match("fire:",targetnode) then
				--minetest.dig_node(fpos)
			else
				minetest.swap_node(fpos, {name = targetnode })
			end
		end
		return itemstack

	end,
})

minetest.register_tool("staffmagic:staff_boom", {
	description = "Boom Staff (delete nodes)",
	inventory_image = "staffmagic_staff.png^[colorize:black:140",
	wield_image = "staffmagic_staff.png^[colorize:black:140",
	range = 12,
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if not staffmagic:staffcheck(user,"staffer") then return end

		local radius = 1
		radius = radius + staffmagic:countpower(user,"boom")

		if pointed_thing.type ~= "node" then
			if not pointed_thing.ref then return end
			local mob = pointed_thing.ref
			local mobe = mob:get_luaentity()

			if mob:is_player() then return end

			for _,obj in pairs(minetest.get_objects_inside_radius(mob:getpos() ,radius)) do
				if not obj:is_player() then
				if mobe.name == obj:get_luaentity()["name"] then
					vivarium:bomf(obj:getpos(),1 )
					obj:remove()
				end
				end -- playercheck
			end
			return
		end

		if not staffmagic:staffcheck(user,"super_staffer") then return end

		local pos = pointed_thing.under
		local pname = user:get_player_name()

		if minetest.is_protected(pos, pname) then
			minetest.record_protection_violation(pos, pname)
			return
		end


		local targetnode = minetest.get_node(pos).name
		local userpos = user:getpos()
                local targetnodes = minetest.find_nodes_in_area(
                        {x = pos.x - radius, y = pos.y-radius, z = pos.z - radius},
                        {x = pos.x + radius, y = pos.y+radius, z = pos.z + radius},
                        {targetnode}
		)

		vivarium:bomf(pos,radius)

                for _,fpos in pairs(targetnodes) do
			if string.match("fire:",targetnode) then -- stop fire sound at same time.
				minetest.dig_node(fpos)
			else
				local amp = vector.distance(pos,fpos) -- make the hole more "organic" :-P
				if (1-amp/radius)*math.random(1,radius) > amp then
					minetest.swap_node(fpos, {name = "air" })
				end
			end
		end
		return itemstack

	end,
})

-- quick and dirty tool to repair carnage caused by NSSM ice mobs
minetest.register_tool("staffmagic:staff_melt", {
	description = "Staff of Melting (Fix Ice Mobs damage)",
	inventory_image = "staffmagic_staff.png^[colorize:blue:90",
	wield_image = "staffmagic_staff.png^[colorize:blue:90",
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
                        {"default:ice"}
		)

		vivarium:bomf(pos,breadth*2)

                for _,fpos in pairs(frostarea) do
			local oldmeta = minetest.get_meta(fpos)
			if oldmeta and oldmeta:get_string("nssm") ~= "" then
				minetest.swap_node(fpos, {name = oldmeta:get_string("nssm") }) -- the meta data is otherwise already there
			else -- node saving not enabled
				local targetnode = minetest.get_node({x=fpos.x,y=fpos.y-1,z=fpos.z})
				local replname = targetnode.name
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
				if staffmagic:isforbidden(replname) then
					staffmagic:hurtplayer(user)
					return
				end
				minetest.swap_node(fpos, {name = replname })
			end
		end

		itemstack = staffmagic:wearitem(itemstack,50)
		return itemstack

	end,
})


minetest.register_craft(
{
	output = "staffmagic:staff_melt",
	recipe = {
		{"default:mese_crystal_fragment","bucket:bucket_water","default:mese_crystal_fragment"},
		{"","default:obsidian_shard",""},
		{"","default:obsidian_shard",""},
	}
}
)

minetest.register_craft(
{
	output = "staffmagic:staff_sending",
	recipe = {
		{"default:mese_crystal_fragment","default:apple","default:mese_crystal_fragment"},
		{"","default:obsidian_shard",""},
		{"","default:obsidian_shard",""},
	}
}
)
