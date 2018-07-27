--[[
Fire: flint_and_steel places fire:permanent_flame instead of fire:basic_flame
]]

minetest.override_item("fire:flint_and_steel", {
	on_use = function(itemstack, user, pointed_thing)
		local player_name = user:get_player_name()
		local pt = pointed_thing

		if pt.type == "node" and minetest.get_node(pt.above).name == "air" then
			itemstack:add_wear(1000)
			local node_under = minetest.get_node(pt.under).name

			if minetest.get_item_group(node_under, "flammable") >= 1 then
				if not minetest.is_protected(pt.above, player_name) then
					minetest.set_node(pt.above, {name = "fire:permanent_flame"})
				else
					minetest.chat_send_player(player_name, "This area is protected")
				end
			end
		end

		if not minetest.setting_getbool("creative_mode") then
			return itemstack
		end
	end
})

--[[
Mapgen: add all mt_game tress to the mapgen
]]

-- Aspen tree: everywhere
minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.003,	-- Tree Density
		spread = {x=100, y=100, z=100},
		seed = 25694,
		octaves = 3,
		persist = 0.5
	},
	y_min = 1,
	y_max = 31000,
	schematic = minetest.get_modpath("default").."/schematics/aspen_tree_from_sapling.mts",
	flags = "place_center_x, place_center_z",
})

-- Acacia tree: lower heights
minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.002,
		spread = {x=100, y=100, z=100},
		seed = 61089,
		octaves = 3,
		persist = 0.5
	},
	y_min = 1,
	y_max = 12,
	schematic = minetest.get_modpath("default").."/schematics/acacia_tree_from_sapling.mts",
	flags = "place_center_x, place_center_z",
})

-- Pine tree: higher heights
minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.002,
		spread = {x=100, y=100, z=100},
		seed = 24073,
		octaves = 3,
		persist = 0.5
	},
	y_min = 12,
	y_max = 31000,
	schematic = minetest.get_modpath("default").."/schematics/pine_tree_from_sapling.mts",
	flags = "place_center_x, place_center_z",
})

--[[
Admin chatcommand: players IPs
]]

if minetest.get_modpath("names_per_ip") then
	minetest.register_chatcommand("ip", {
		description = "Get player IP",
		params = "<player>",
		privs = { kick=true },
		func = function(name, params)
			local player = params:match("%S+")
			if not player then
				return false, "Invalid usage"
			end

			if not ipnames.data[player] then
				minetest.chat_send_player(name, "The player '"..player.."' did not join yet.")
				return
			end

			local ip = ipnames.data[player][1]

			return true, ip
		end,
	})
end

--[[
Natural hive: don't allow inventory put if the area is protected (don't do this for artificial hives)
]]
if minetest.get_modpath("mobs_animal") then
	minetest.override_item("mobs:beehive", {
		allow_metadata_inventory_take = function(pos, listname, index, stack, player)
			print(minetest.is_protected(pos, player:get_player_name()))
			if minetest.is_protected(pos, player:get_player_name()) and listname == "beehive" then
				return 0
			end
			return stack:get_count()
		end
	})
end

--[[
Lava bucket: place only in areas protected by the placing player (not at unprotected areas)
]]
local old_bucket_lava_on_place = minetest.registered_items["bucket:bucket_lava"].on_place
minetest.override_item("bucket:bucket_lava", {
	on_place = function(itemstack, user, pointed_thing)
		if next(areas:getAreasAtPos(pointed_thing.under)) == nil then
			local name = user:get_player_name()
			minetest.log("action", (name ~= "" and name or "A mod") .. " tried to place a lava bucket at an unprotected position")
			return
		end
		return old_bucket_lava_on_place(itemstack, user, pointed_thing)
	end
})

--[[
Moderator command: /error, useful to reboot the server
]]
minetest.register_chatcommand("error", {
	description = "Raise an error to make the server to crash with an error exit status, and the run.sh script to reboot it",
	params = "",
	privs = { ban=true },
	func = function(name, params)
		error("/error chatcommand")
		return true
	end,
})

--[[
Unbreakable nodes: add unbreakable obsidian glass and unbreakable stairs and slabs to maptools
]]
minetest.register_node(":maptools:obsidian_glass", {
	description = "Unbreakable Obsidian Glass",
	drawtype = "glasslike_framed_optional",
	tiles = {"default_obsidian_glass.png", "default_obsidian_glass_detail.png"},
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	sounds = default.node_sound_glass_defaults(),
	range = 12,
	stack_max = 10000,
	drop = "",
	groups = {unbreakable = 1, not_in_creative_inventory = maptools.creative},
})
local function register_stair_and_slab_maptools(name, description, tiles, sounds)
	minetest.register_node(":maptools:slab_"..name, {
		description = "Unbreakable "..description.." Slab",
		drawtype = "nodebox",
		tiles = {tiles},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {unbreakable = 1, not_in_creative_inventory = maptools.creative},
		sounds = sounds,
		range = 12,
		stack_max = 10000,
		drop = "",
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		}
	})
	minetest.register_node(":maptools:stair_"..name, {
		description = "Unbreakable "..description.." Stair",
		drawtype = "nodebox",
		tiles = {tiles},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {unbreakable = 1, not_in_creative_inventory = maptools.creative},
		sounds = sounds,
		range = 12,
		stack_max = 10000,
		drop = "",
		drawtype = "mesh",
		mesh = "stairs_stair.obj",
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		}
	})
end
register_stair_and_slab_maptools("sandstonebrick", "Sandstone Brick", "default_sandstone_brick.png", default.node_sound_stone_defaults())
register_stair_and_slab_maptools("stonebrick", "Stone Brick", "default_stone_brick.png", default.node_sound_stone_defaults())
register_stair_and_slab_maptools("stone", "Stone", "default_stone.png", default.node_sound_stone_defaults())
register_stair_and_slab_maptools("cobble", "Cobblestone", "default_cobble.png", default.node_sound_stone_defaults())

-- Unbreakable Public streets and Lighting (EmuRe style)
default.register_fence(":maptools:fence_aspen_wood", {
	description = "Unbreakable Aspen Fence",
	texture = "default_fence_aspen_wood.png",
	inventory_image = "default_fence_overlay.png^default_aspen_wood.png^default_fence_overlay.png^[makealpha:255,126,126",
	wield_image = "default_fence_overlay.png^default_aspen_wood.png^default_fence_overlay.png^[makealpha:255,126,126",
	material = "default:aspen_wood",
	groups = {unbreakable = 1, not_in_creative_inventory = maptools.creative},
	sounds = default.node_sound_wood_defaults()
})
-- Side effect: clear the auto-generated recipe for this uncraftable node
minetest.clear_craft({output = ":maptools:fence_aspen_wood"})

--[[
Screwdriver: do not rotate unbreakable nodes
]]
local old_screwdriver_handler = screwdriver.handler
screwdriver.handler = function(itemstack, user, pointed_thing, mode, uses)
	if pointed_thing.type ~= "node" then
		return
	end

	local under_node = minetest.get_node(pointed_thing.under)
	if minetest.get_item_group(under_node.name, "unbreakable") ~= 0 then
		return
	end

	return old_screwdriver_handler(itemstack, user, pointed_thing, mode, uses)
end

--[[
Require carts modifications if a carts mod is loaded
--]]
if minetest.get_modpath("carts") or minetest.get_modpath("boost_cart") then
	dofile(minetest.get_modpath("misc").."/carts.lua")
end

--[[
Markers: increase MAX_SIZE to 128x128
]]
if markers then
	markers.MAX_SIZE = 128 * 128
end

--[[
Rotate protection violators
]]
dofile(minetest.get_modpath("misc").."/violation.lua")

--[[
Deactivate serveressentials Welcome message (first_hour already sends one)
]]
if SHOW_FIRST_TIME_JOIN_MSG then
	SHOW_FIRST_TIME_JOIN_MSG = false
end

--[[
Serveressentials: disable afkkick
]]
if AFK_CHECK then
	AFK_CHECK = false
end

--[[
Decapitalize chat messages
]]
dofile(minetest.get_modpath("misc").."/decapitalizer.lua")

--[[
Babelfish: don't display compliance
]]
if minetest.get_modpath("babelfish") then
	babel.compliance = nil
end

--[[
Add remove_nodes chatcommand for mega-giga's skywars.
]]
dofile(minetest.get_modpath("misc") .. "/remove_nodes.lua")

--[[
Grant spawn and pvp to players who have interact
]]
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local privs = minetest.get_player_privs(name)
	if privs.interact then
		privs.spawn = true
		privs.pvp = true
		minetest.set_player_privs(name, privs)
	end
end)

--[[
Clear admin pencil craft
]]
if minetest.get_modpath("books") and minetest.settings:get_bool("books.editor") then
	minetest.clear_craft({output="books:admin_pencil"})
end

--[[
Make more NPCs spawning
]]
if minetest.get_modpath("mobs_npc") then
	mobs:spawn({
		name = "mobs_npc:npc",
		nodes = {"default:dirt_with_grass"},
		min_light = 0,
		chance = 3500,
		active_object_count = 1,
		min_height = 0,
	})
	mobs:spawn({
		name = "mobs_npc:igor",
		nodes = {"default:dirt_with_grass"},
		min_light = 0,
		chance = 10500,
		active_object_count = 1,
		min_height = 0,
	})
	mobs:spawn({
		name = "mobs_npc:trader",
		nodes = {"default:dirt_with_grass"},
		min_light = 0,
		chance = 10000,
		active_object_count = 1,
		min_height = 0,
	})

	-- Set trader names
	mobs.human.names = {
		"AkitoNaaki93", "PlasticNeeSan", "mysteryboss", "Winner", "miniloup", "paul",
		"annie11", "kumma", "WolfTueur", "johan"
	}
end

--[[
/announce chatcommand
]]
minetest.register_privilege("announce", "Can use /announce")
minetest.register_chatcommand("announce", {
	params = "msg",
	privs = {announce = true},
	description = "Makes a well-visible announcement",
	func = function(name, param)
		minetest.chat_send_all(minetest.colorize("#ff0000", "**** ANNOUNCEMENT by "..name.." **** "..param))
	end
})

--[[ Sneak ladder and jump 2017-04-20. Commit 58c083f305
In the new player movement code, the replications of sneak ladder and 2 node sneak jump
are an option which is controlled [server-side] by the 'sneak_glitch' physics override,
the option is now disabled by default.
To enable for all players use a mod with this code:
--]]
minetest.register_on_joinplayer(function(player)
   local override_table = player:get_physics_override()
   override_table.sneak_glitch = true
   player:set_physics_override(override_table)
end)

--[[
Awesome wood frames!
]]
xpanes.register_pane("wood_frame", {
	description = "Wood Frame",
	tiles = {"xdecor_wood_frame.png"},
	drawtype = "airlike",
	paramtype = "light",
	textures = {"xdecor_wood_frame.png", "xdecor_wood_frame.png", "xpanes_space.png"},
	inventory_image = "xdecor_wood_frame.png",
	wield_image = "xdecor_wood_frame.png",
	groups = {choppy=2, pane=1, flammable=2},
	sounds = default.node_sound_wood_defaults(),
	recipe = {{"group:wood", "group:stick", "group:wood"},
		  {"group:stick", "group:stick", "group:stick"},
		  {"group:wood", "group:stick", "group:wood"}}
})

minetest.register_alias("xpanes::xdecor:wood_frame_flat", "xpanes:wood_frame_flat")

--[[
Double uses of all tools
]]
minetest.register_on_mods_loaded(function()
	for tool, def in pairs(minetest.registered_tools) do
		local caps = (def.tool_capabilities or {}).groupcaps
		if caps then
			for _, cap in ipairs({"cracky", "crumbly", "snappy", "choppy"}) do
				local gr = caps[cap]
				if gr then
					gr.uses = gr.uses * 2
				end
			end
		end
	end
end)
