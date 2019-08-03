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

--[[
Lava shield
]]
if minetest.get_modpath("3d_armor") then
	local function play_sound_effect(player, name)
		if not disable_sounds and player then
			local pos = player:get_pos()
			if pos then
				minetest.sound_play(name, {
					pos = pos,
					max_hear_distance = 10,
					gain = 0.5,
				})
			end
		end
	end
	armor:register_armor("misc:shield_lava", {
		description = "Lava Shield",
		inventory_image = "misc_inv_shield_lava.png",
		groups = {armor_shield=1, armor_heal=1, armor_use=900, armor_fire=6, flammable=1},
		armor_groups = {},
		damage_groups = {cracky=2, snappy=1, level=3},
		reciprocate_damage = false,
		on_damage = function(player, index, stack)
			play_sound_effect(player, "default_dig_metal")
		end,
		on_destroy = function(player, index, stack)
			play_sound_effect(player, "default_dug_metal")
		end,
	})
	minetest.register_craft({
		output = "misc:shield_lava",
		type = "shapeless",
		recipe = {
			"shields:shield_diamond",
			"bucket:bucket_lava",
		}
	})

	--[[
	Stop evil torches
	]]
	-- Because of changes in indexation when entries are removed, it is necessary
	-- to entirely re-iterate for each type of torch.
	for _, torch_name in ipairs({"default:torch", "default:torch_ceiling", "default:torch_wall"}) do
		for i, v in ipairs(armor.fire_nodes) do
			if v[1] == torch_name then
				table.remove(armor.fire_nodes, i)
				break
			end
		end
	end
end

--[[
Tree aliases
]]
if minetest.get_modpath("moretrees") then
	minetest.register_alias_force("moretrees:jungletree_trunk", "default:jungletree")
	if minetest.get_modpath("ethereal") then
		minetest.register_alias_force("ethereal:birch_trunk", "moretrees:birch_trunk")
		minetest.register_alias_force("ethereal:birch_wood", "moretrees:birch_planks")
		minetest.register_alias_force("stairs:slab_birch_wood", "stairs:slab_moretrees_birch_planks")
		minetest.register_alias_force("stairs:stair_birch_wood", "stairs:stair_moretrees_birch_planks")
		minetest.register_alias_force("stairs:stair_inner_birch_wood", "stairs:stair_inner_moretrees_birch_planks")
		minetest.register_alias_force("stairs:stair_outer_birch_wood", "stairs:stair_outer_moretrees_birch_planks")
	end
end

--[[
Send death position in chat when players die
]]
minetest.register_on_dieplayer(function(player)
	minetest.chat_send_player(player:get_player_name(), string.format("You died at position %s.", minetest.pos_to_string(player:get_pos(), 0)))
end)

--[[
Workbench -> moreblocks aliases
]]
if minetest.get_modpath("moreblocks") then
	-- Some blocks could be cut with the workbench but are not anymore with the circular saw.
	-- Re-register some useful ones.
	if minetest.get_modpath("caverealms") then
		stairsplus:register_all("caverealms", "thin_ice", "caverealms:thin_ice", {
			description = "Thin Ice",
			tiles = {"caverealms_thin_ice.png"},
			is_ground_content = true,
			groups = {cracky=3},
			sounds = default.node_sound_glass_defaults(),
			use_texture_alpha = true,
			drawtype = "glasslike",
			sunlight_propagates = true,
			freezemelt = "default:water_source",
			paramtype = "light",
		})
		-- Plus some aliases for hanging thin ice
		minetest.register_alias("stairs:slab_hanging_thin_ice", "caverealms:slab_thin_ice")
		minetest.register_alias("stairs:stair_hanging_thin_ice", "caverealms:stair_thin_ice")
	end

	-- Create an alias for every old workbench node.
	local function register_workbench_alias(nodename)
		local modname, sub_nodename = string.match(nodename, "(.*):(.*)")
		if modname == "default" then
			modname = "moreblocks"
		end
		minetest.register_alias(nodename .. "_nanoslab", modname .. ":micro_" .. sub_nodename .. "_1")
		minetest.register_alias(nodename .. "_micropanel", modname .. ":panel_" .. sub_nodename .. "_1")
		minetest.register_alias(nodename .. "_microslab", modname .. ":slab_" .. sub_nodename .. "_1")
		minetest.register_alias(nodename .. "_thinstair", modname .. ":stair_" .. sub_nodename .. "_alt_1")
		minetest.register_alias(nodename .. "_cube", modname .. ":micro_" .. sub_nodename)
		minetest.register_alias(nodename .. "_panel", modname .. ":panel_" .. sub_nodename)
		minetest.register_alias(nodename .. "_doublepanel", modname .. ":stair_" .. sub_nodename .. "_alt")
		minetest.register_alias(nodename .. "_halfstair", modname .. ":stair_" .. sub_nodename .. "_half")
		minetest.register_alias(nodename .. "_outerstair", modname .. ":stair_" .. sub_nodename .. "_outer")
		minetest.register_alias(nodename .. "_innerstair", modname .. ":stair_" .. sub_nodename .. "_inner")

		-- Moreblocks automatically creates the aliases, and moretrees requires different aliases.
		if modname ~= "moreblocks" and modname ~= "moretrees" then
			minetest.register_alias("stairs:stair_" .. sub_nodename, modname .. ":stair_" .. sub_nodename)
			minetest.register_alias("stairs:slab_" .. sub_nodename, modname .. ":slab_" .. sub_nodename)
		end
	end
	local nodes = {}
	for node, def in pairs(minetest.registered_nodes) do
		if (def.drawtype == "normal" or def.drawtype:sub(1,5) == "glass") and
			(def.groups.cracky or def.groups.choppy) and
			not def.on_construct and
			not def.after_place_node and
			not def.on_rightclick and
			not def.on_blast and
			not def.allow_metadata_inventory_take and
			not (def.groups.not_in_creative_inventory == 1) and
			not (def.groups.not_cuttable == 1) and
			(def.tiles and type(def.tiles[1]) == "string" and not
			def.tiles[1]:find("default_mineral")) and
			not def.mesecons and
			def.description and
			def.description ~= "" and
			def.light_source == 0
		then
			nodes[node] = true
			register_workbench_alias(node)
		end
	end

	-- Also create a stairs alias for every moreblocks node (fixes moretrees & ethereal unknwon blocks)
	for nodename, def in pairs(circular_saw.known_nodes) do
		local modname, sub_nodename = def[1], def[2]
		if modname == "moretrees" then
			minetest.register_alias("stairs:stair_" .. modname .. "_" .. sub_nodename, modname .. ":stair_" .. sub_nodename)
			minetest.register_alias("stairs:slab_" .. modname .. "_" .. sub_nodename, modname .. ":slab_" .. sub_nodename)
		elseif modname == "default" or modname == "moreblocks" or nodes[nodename] then
			-- Do nothing, no alias required
		elseif modname == "ethereal" then
			minetest.register_alias("stairs:stair_" .. sub_nodename, modname .. ":stair_" .. sub_nodename)
			minetest.register_alias("stairs:slab_" .. sub_nodename, modname .. ":slab_" .. sub_nodename)
		else
			minetest.log("warning", "[misc] Unkown moreblocks alias format for mod: " .. modname)
		end
	end
end
