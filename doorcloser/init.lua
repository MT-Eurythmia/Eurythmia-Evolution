-- Close doors automatically

doorcloser = {}

-- table used to aid door opening/closing
local transform = {
	{
		{ v = "_a", param2 = 3 },
		{ v = "_a", param2 = 0 },
		{ v = "_a", param2 = 1 },
		{ v = "_a", param2 = 2 },
	},
	{
		{ v = "_b", param2 = 1 },
		{ v = "_b", param2 = 2 },
		{ v = "_b", param2 = 3 },
		{ v = "_b", param2 = 0 },
	},
	{
		{ v = "_b", param2 = 1 },
		{ v = "_b", param2 = 2 },
		{ v = "_b", param2 = 3 },
		{ v = "_b", param2 = 0 },
	},
	{
		{ v = "_a", param2 = 3 },
		{ v = "_a", param2 = 0 },
		{ v = "_a", param2 = 1 },
		{ v = "_a", param2 = 2 },
	},
}

local toggledoor = function(pos) -- taken from doors mod in default game
	local meta = minetest.get_meta(pos)
	local def = minetest.registered_nodes[minetest.get_node(pos).name]
	local name = def.door.name

	local state = meta:get_string("state")
	if state == "" then
		-- fix up lvm-placed right-hinged doors, default closed
		if minetest.get_node(pos).name:sub(-2) == "_b" then
			state = 2
		end
	else
		state = tonumber(state)
	end

	local old = state
	-- until Lua-5.2 we have no bitwise operators :(
	if state % 2 == 1 then
		state = state - 1
	else
		state = state + 1
	end

	local dir = minetest.get_node(pos).param2
	if state % 2 == 0 then
		minetest.sound_play(def.door.sounds[1], {pos = pos, gain = 0.3, max_hear_distance = 10})
	else
		minetest.sound_play(def.door.sounds[2], {pos = pos, gain = 0.3, max_hear_distance = 10})
	end

	minetest.swap_node(pos, {
		name = name .. transform[state + 1][dir+1].v,
		param2 = transform[state + 1][dir+1].param2
	})
	meta:set_int("state", state)

	return true		
end

doorcloser.autoclose = function(doorname)
	local doordef = minetest.registered_nodes[doorname.."_a"]
	local originalrc = doordef.on_rightclick
	doordef.on_rightclick = function(pos,clicker)
		originalrc(pos,clicker)
		if minetest.get_node(pos).name:sub(-2) == "_b" then
			minetest.after(1.0, function()
				if minetest.get_node(pos).name:sub(-2) == "_b" then -- player might have closed it themselves
					toggledoor(pos)
				end
			end)
		end
	end
end

doorcloser.autoclose("doors:door_obsidian_glass")
--doorcloser.autoclose("doors:door_wood") -- _a and _b states are inverted! d'oh!
doorcloser.autoclose("doors:door_glass")
