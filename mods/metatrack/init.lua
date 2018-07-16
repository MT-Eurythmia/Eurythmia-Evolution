--[[
Metatrack adds metadata to items when they are created to help keeping track of them.
Items with a meta field `creative` set to a player name are not allowed to be:
* Dropped
* Moved into a chest or another inventory (except the unified_inventory trash)
* Placed anywhere but in areas explicitely authorized using the `/allow_creative <player> <area ID>` command.
]]

local storage = minetest.get_mod_storage()

local allowed_areas = minetest.deserialize(storage:get_string("allowed_areas")) or {}

local function get_allowed_areas(name)
	return allowed_areas[name] or {}
end
local function set_allowed_areas(name, areas)
	allowed_areas[name] = areas
	storage:set_string("allowed_areas", minetest.serialize(allowed_areas))
end

minetest.register_chatcommand("allow_creative", {
	params = "<name> [<area ID>]",
	description = "List allowed areas for a player or (dis)allows a player to use self-given nodes in an area",
	privs = {give = true},
	func = function(name, param)
		local name, arid = string.match(param, "([^ ]+) ([0-9]+)")
		arid = tonumber(arid)
		if not name or not arid then
			if minetest.player_exists(param) then
				local allowed = get_allowed_areas(param)
				local str = "Allowed areas for player " .. param .. ":"
				for id, _ in pairs(allowed) do
					str = str .. " " .. id
				end
				return true, str
			end

			return false, "Invalid parameters (see /help allow_creative)"
		elseif not minetest.player_exists(name) then
			return false, "Player " .. name .. " does not exist."
		end

		local allowed = get_allowed_areas(name)
		local str
		if allowed[arid] then
			allowed[arid] = nil
			str = string.format("Removed area %d from allowed areas for player %s.", arid, name)
		else
			allowed[arid] = true
			str = string.format("Added area %d to allowed areas for player %s.", arid, name)
		end
		set_allowed_areas(name, allowed)
		return true, str
	end
})

minetest.register_allow_player_inventory_action(function(player, inventory, action, inventory_info)
	print(dump(inventory_info))
	local stack
	if action == "take" then
		stack = inventory_info.stack
	elseif inventory_info.from_list then -- seems "action" is userdata when it should have the "move" value.
		if inventory_info.to_list == "main" then
			-- Allow
			return
		end

		-- Also the inventory prameter seems not to have the correct methods.
		local inv = player:get_inventory()
		stack = inv:get_stack(inventory_info.from_list, inventory_info.from_index)
	else
		return
	end

	local meta = stack:get_meta()
	if meta:contains("creative") then
		-- Disallow
		return 0
	end
end)

local old_item_drop = minetest.item_drop
function minetest.item_drop(itemstack, dropper, pos)
	local meta = itemstack:get_meta()
	if meta:contains("creative") then
		local name = dropper:get_player_name()
		if meta:get_string("creative") ~= name then
			-- This is a security risk and should never happen
			minetest.log("warning", string.format("Player %s tried to drop item %s at position %s with a creative metadata set to %s.",
				name, itemstack:get_name(), minetest.pos_to_string(pos), meta:get_string("creative")))
			return
		end

		return
	end

	return old_item_drop(itemstack, dropper, pos)
end


minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local meta = itemstack:get_meta()
	if meta:contains("creative") then
		local name = placer:get_player_name()
		if meta:get_string("creative") ~= name then
			-- This is a security risk and should never happen
			minetest.log("warning", string.format("Player %s tried to place item %s at position %s with a creative metadata set to %s.",
				name, itemstack:get_name(), minetest.pos_to_string(pos), meta:get_string("creative")))
			minetest.remove_node(pos)
			return
		end

		local areas = areas:getAreasAtPos(pos)
		local allowed = false
		for id, _ in pairs(get_allowed_areas(name)) do
			if areas[id] then
				allowed = true
				break
			end
		end
		if not allowed then
			minetest.log("action", string.format("Player %s tried to place creative item %s at unallowed position %s.",
				name, itemstack:get_name(), minetest.pos_to_string(pos)))
			minetest.remove_node(pos)
		end
	end
end)
