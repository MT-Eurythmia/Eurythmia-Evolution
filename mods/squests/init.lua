local storage = minetest.get_mod_storage()

squests = {
	quests = minetest.deserialize(storage:get_string("quests")) or {},
	pending_respawns = minetest.deserialize(storage:get_string("pending_respawns")) or {}
}

local function update_mod_storage()
	storage:set_string("quests", minetest.serialize(squests.quests))
	storage:set_string("pending_respawns", minetest.serialize(squests.pending_respawns))
end

local function respawn_player(player)
	local spawn_pos = minetest.setting_get_pos("static_spawnpoint")
	player:set_pos(spawn_pos)
end

function squests.add_quest(pos, name)
	if squests.quests[name] then
		return false, "There is already a quest with name " .. name .. "."
	end

	squests.quests[name] = {
		pos = pos
	}

	update_mod_storage()
	return true, "Successfully added quest " .. name .. "."
end

function squests.stop_quest(name)
	if not squests.quests[name] then
		return false, "Quest " .. name .. "doesn't exist."
	end

	local playername = squests.quests[name].player
	if not playername then
		return false, "There is nobody playing quest " .. name .. "."
	end

	squests.quests[name].player = nil

	respawn_player(minetest.get_player_by_name(playername))

	update_mod_storage()
	return true, "Successfully stopped quest " .. name .. "."
end

function squests.remove_quest(name)
	if not squests.quests[name] then
		return false, "Quest " .. name .. " doesn't exist."
	end

	squests.stop_quest(name)
	squests.quests[name] = nil

	update_mod_storage()
	return true, "Successfully removed quest " .. name .. "."
end

function squests.start_quest(name, playername)
	local quest = squests.quests[name]
	if not quest then
		return false, "Quest " .. name .. " doesn't exist."
	end

	if quest.player then
		return false, "Quest " .. name .. " is currently being attempted by player " .. quest.player .. "."
	end

	quest.player = playername
	local player = minetest.get_player_by_name(playername)
	player:set_pos(quest.pos)

	update_mod_storage()
	return true, "Successfully started quest " .. name .. "."
end

minetest.register_privilege("quests", "Can manage quests")

minetest.register_chatcommand("add_quest", {
	params = "<name>",
	description = "Create a new quest",
	privs = {quests = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		return squests.add_quest(player:get_pos(), param)
	end
})

minetest.register_chatcommand("remove_quest", {
	params = "<name>",
	description = "Remove a quest",
	privs = {quests = true},
	func = function(name, param)
		return squests.remove_quest(param)
	end
})

minetest.register_chatcommand("stop_quest", {
	params = "<name>",
	description = "Stop a quest",
	privs = {quests = true},
	func = function(name, param)
		return squests.stop_quest(param)
	end
})

minetest.register_chatcommand("start_quest", {
	params = "<quest_name> <player_name>",
	description = "Start a quest",
	privs = {quests = true},
	func = function(name, param)
		local quest_name, player_name = param:match("^(%S+)%s(.+)$")
		if not quest_name then
			return false, "Invalid usage, see /help start_quest."
		end

		return squests.start_quest(quest_name, player_name)
	end
})

minetest.register_on_joinplayer(function(player)
	local playername = player:get_player_name()
	if squests.pending_respawns[playername] then
		respawn_player(player)
		squests.pending_respawns[playername] = nil
		update_mod_storage()
	end
end)

minetest.register_on_leaveplayer(function(player)
	local playername = player:get_player_name()
	for name, quest in pairs(squests.quests) do
		if quest.player == playername then
			squests.pending_respawns[playername] = true
			squests.stop_quest(name)
		end
	end
end)

minetest.register_on_dieplayer(function(player)
	local playername = player:get_player_name()
	for name, quest in pairs(squests.quests) do
		if quest.player == playername then
			squests.stop_quest(name)
		end
	end
end)

local counter = 0
minetest.register_globalstep(function(dtime)
	counter = counter + dtime
	if counter >= 5 then
		counter = counter - 5

		for name, quest in pairs(squests.quests) do
			if quest.player then
				local player = minetest.get_player_by_name(quest.player)
				if not player then
					squests.pending_respawns[quest.player] = true
					quest.player = nil
				else
					if vector.distance(player:get_pos(), quest.pos) > 500 then
						minetest.chat_send_player(quest.player, "You have been removed from quest " .. name .. " because you are too far away.")
						squests.stop_quest(name)
					end
				end
			end
		end
	end
end)
