local random = math.random

-- Cherry tree growing
-- Sapling LBM

-- Cherry tree generation
local function grow_cherry_tree(pos)
	local path = minetest.get_modpath("cherry_tree") ..
		"/schematics/cherry_tree_from_sapling.mts"
	minetest.place_schematic({x = pos.x - 2, y = pos.y - 1, z = pos.z - 2},
									 path, "random", nil, false)
end

local function grow_sapling(pos)
	if not default.can_grow(pos) then
		minetest.get_node_timer(pos):start(random(240, 600))
		return
	end

	local node = minetest.get_node(pos)

	if node.name == "cherry_tree:cherry_sapling" then
		minetest.log("action", "A cherry sapling grows into a tree at "..
							 minetest.pos_to_string(pos))
		grow_cherry_tree(pos)
	end
end

minetest.register_lbm(
	{
		name = "cherry_tree:convert_saplings_to_node_timer",
		nodenames = {"cherry_tree:cherry_sapling"},
		action = function(pos)
			minetest.get_node_timer(pos):start(random(1200, 2400))
		end
	})

-- From BFD, cherry tree
minetest.register_node(
	"cherry_tree:cherry_tree",
	{
		description = "Cherry Tree",
		tiles = {
			"default_cherry_top.png",
			"default_cherry_top.png",
			"default_cherry_tree.png"
		},
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
		sounds = default.node_sound_wood_defaults(),
		on_place = minetest.rotate_node
	})

minetest.register_node(
	"cherry_tree:cherry_plank",
	{
		description = "Cherry Planks",
		paramtype2 = "facedir",
		place_param2 = 0,
		tiles = {"default_wood_cherry_planks.png"},
		is_ground_content = false,
		sounds = default.node_sound_wood_defaults(),
		groups = {oddly_breakable_by_hand=1, flammable=1, choppy=3, wood=1},
	})

minetest.register_node(
	"cherry_tree:cherry_blossom_leaves",
	{
		description = "Cherry Blossom Leaves",
		drawtype = "allfaces_optional",
		visual_scale = 1.3,
		tiles = {"default_cherry_blossom_leaves.png"},
		paramtype = "light",
		waving = 1,
		is_ground_content = false,
		groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
		drop = {
			max_items = 1,
			items = {
				{
					items = {'cherry_tree:cherry_sapling'},
					rarity = 32,
				},
				{
					items = {'cherry_tree:cherry_blossom_leaves'},
				}
			}
		},
		sounds = default.node_sound_leaves_defaults(),
		after_place_node = default.after_place_leaves,
	})

minetest.register_node(
	"cherry_tree:cherry_sapling",
	{
		description = "Cherry Sapling",
		waving = 1,
		visual_scale = 1.0,
		inventory_image = "default_cherry_sapling.png",
		wield_image = "default_cherry_sapling.png",
		drawtype = "plantlike",
		paramtype = "light",
		sunlight_propagates = true,
		tiles = {"default_cherry_sapling.png"},
		walkable = false,
		on_timer = grow_sapling,
		selection_box = {
			type = "fixed",
			fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
		},
		groups = {snappy = 2, dig_immediate = 3, flammable = 2,
					 attached_node = 1, sapling = 1},
		sounds = default.node_sound_leaves_defaults(),
		on_construct = function(pos)
			minetest.get_node_timer(pos):start(random(2400,4800))
		end,
		
		on_place = function(itemstack, placer, pointed_thing)
			itemstack = default.sapling_on_place(
				itemstack, placer, pointed_thing,
				"cherry_tree:cherry_sapling",
				-- minp, maxp to be checked, relative to sapling pos
				-- minp_relative.y = 1 because sapling pos has been checked
				{x = -2, y = 1, z = -2},
				{x = 2, y = 6, z = 2},
				-- maximum interval of interior volume check
				4)
			return itemstack
		end,
	})

default.register_leafdecay(
	{
		trunks = {"cherry_tree:cherry_tree"},
		leaves = {"default:apple", "cherry_tree:cherry_blossom_leaves"},
		radius = 3,
	})

-- Aliases
minetest.register_alias("default:cherry_tree", "cherry_tree:cherry_tree")
minetest.register_alias("default:cherry_log", "cherry_tree:cherry_tree")
minetest.register_alias("default:cherry_plank", "cherry_tree:cherry_plank")
minetest.register_alias("default:cherry_blossom_leaves", "cherry_tree:cherry_blossom_leaves")
minetest.register_alias("default:cherry_leaves_deco", "cherry_tree:cherry_blossom_leaves")
minetest.register_alias("default:cherry_leaves", "cherry_tree:cherry_blossom_leaves")
minetest.register_alias("default:cherry_sapling", "cherry_tree:cherry_sapling")
minetest.register_alias("default:mg_cherry_sapling", "cherry_tree:cherry_sapling")

-- Crafting
minetest.register_craft(
	{
		output = "cherry_tree:cherry_plank 4",
		recipe = {
			{"cherry_tree:cherry_tree"},
		}
	})

-- Fuels
minetest.register_craft({
	type = "fuel",
	recipe = "cherry_tree:cherry_tree",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "cherry_tree:cherry_plank",
	burntime = 7,
})

minetest.register_craft({
	type = "fuel",
	recipe = "cherry_tree:cherry_sapling",
	burntime = 10,
})


-- Mapgen
minetest.register_biome(
	{
		name = "cherry_blossom_forest",
		--node_shore_filler = "default:sand",
		node_top = "default:dirt_with_grass",
		depth_top = 1,
		node_filler = "default:dirt",
		depth_filler = 3,
		--node_dust = "air",
		--node_underwater = "default:gravel",
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_min = 50,
		y_max = 60,
		heat_point = 47,
		humidity_point = 60,
	})

-- Decoration
-- Cherry tree and log

-- Cherry trees
minetest.register_decoration(
	{
		deco_type = "schematic",
		place_on = {"default:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.036,
			scale = 0.022,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"cherry_blossom_forest",
		},
		y_min = 1,
		y_max = 31000,
		schematic = minetest.get_modpath("cherry_tree") ..
			"/schematics/cherry_tree.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

minetest.register_decoration(
	{
		deco_type = "schematic",
		place_on = {"default:dirt_with_snow", "default:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.0009,
			scale = 0.0006,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"deciduous_forest",
			"taiga"
		},
		y_min = 1,
		y_max = 31000,
		schematic = minetest.get_modpath("cherry_tree") ..
			"/schematics/cherry_tree.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

-- cherry logs
minetest.register_decoration(
	{
		deco_type = "schematic",
		place_on = {"default:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.0018,
			scale = 0.0011,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"cherry_blossom_forest",
		},
		y_min = 1,
		y_max = 31000,
		schematic = minetest.get_modpath("cherry_tree") ..
			"/schematics/cherry_log.mts",
		flags = "place_center_x",
		rotation = "random",
	})

minetest.register_decoration(
	{
		deco_type = "schematic",
		place_on = {"default:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.0004,
			scale = 0.0003,
			spread = {x = 250, y = 250, z = 250},
			seed = 3,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"deciduous_forest",
		},
		y_min = 1,
		y_max = 31000,
		schematic = minetest.get_modpath("cherry_tree") ..
			"/schematics/cherry_log.mts",
		flags = "place_center_x",
		rotation = "random",
	})

if minetest.get_modpath("doors") then
	-- Door from BFD: Cherry planks doors
	doors.register(
		"door_cherry",
		{
			tiles = {"doors_door_cherry.png"},
			description = "Cherry Door",
			inventory_image = "doors_item_cherry.png",
			groups = {choppy=2, oddly_breakable_by_hand=2, flammable=2, door=1},
			sounds = default.node_sound_wood_defaults(),
			recipe = {
				{"cherry_tree:cherry_plank", "cherry_tree:cherry_plank"},
				{"cherry_tree:cherry_plank", "cherry_tree:cherry_plank"},
				{"cherry_tree:cherry_plank", "cherry_tree:cherry_plank"}
			}
		})
	minetest.register_alias("doors:door_wood_cherry", "doors:door_cherry")

	doors.register_trapdoor(
		"cherry_tree:trapdoor_cherry",
		{
			description = "Cherry tree trapdoor",
			inventory_image = "doors_trapdoor_cherry.png",
			wields_images = "doors_trapdoor_cherry.png",
			tile_front = "doors_trapdoor_cherry.png",
			tile_side = "default_wood_cherry_planks.png",
			groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=2, door=1},
			sounds = default.node_sound_wood_defaults(),
			sound_open = "doors_door_open",
			sound_close = "doors_door_close"
		})

	minetest.register_craft(
		{
			output = 'cherry_tree:trapdoor_cherry 2',
			recipe = {
				{'cherry_tree:cherry_plank', 'cherry_tree:cherry_plank', 'cherry_tree:cherry_plank'},
				{'cherry_tree:cherry_plank', 'cherry_tree:cherry_plank', 'cherry_tree:cherry_plank'},
			}
		})
	
	minetest.register_alias("doors:trapdoor_cherry", "cherry_tree:trapdoor_cherry")

	-- fuels
	minetest.register_craft(
		{
			type = "fuel",
			recipe = "cherry_tree:trapdoor_cherry",
			burntime = 7,
		})

	minetest.register_craft(
		{
			type = "fuel",
			recipe = "doors:door_cherry",
			burntime = 14,
		})
	
end

if minetest.get_modpath("moreblocks") then
	-- planks
	local nodename = "cherry_tree:cherry_plank"
	local ndef = table.copy(minetest.registered_nodes[nodename])
	ndef.sunlight_propagates = true
	ndef.place_param2 = nil

	stairsplus:register_all(
		"cherry_tree",
		"cherry_plank",
		nodename,
		ndef
	)

	-- tree
	nodename = "cherry_tree:cherry_tree"
	ndef = table.copy(minetest.registered_nodes[nodename])
	ndef.sunlight_propagates = true

	stairsplus:register_all(
		"cherry_tree",
		"cherry_tree",
		nodename,
		ndef
	)

elseif minetest.get_modpath("stairs") then
	-- From BFD:
	
	stairs.register_stair_and_slab(
		"cherry_wood",
		"cherry_tree:cherry_plank",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"default_wood_cherry_planks.png"},
		"Cherry Plank Stair",
		"Cherry Plank Slab",
		"Cherry Plank Corner Stair",
		default.node_sound_wood_defaults()
	)
end
