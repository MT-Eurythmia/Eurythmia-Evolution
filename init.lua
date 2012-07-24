-- Unified Dyes Mod by Vanessa Ezekowitz  ~~  2012-07-24
--
-- License: GPL
--
-- This mod depends on ironzorg's flowers mod
--

--===========================================================================
-- First you need something to put the dyes into - glass bottles
--
-- Smelt some sand into glass as usual, then smelt one of the resulting glass
-- blocks to get a 9-pack of empty bottles.

minetest.register_craftitem("unifieddyes:empty_bottle", {
        description = "Empty Glass Bottle",
        inventory_image = "unifieddyes_empty_bottle.png",
})

minetest.register_craftitem("unifieddyes:bottle_9_pack", {
        description = "Empty Glass Bottles (9-pack)",
        inventory_image = "unifieddyes_bottle_9_pack.png",
})

minetest.register_craft({
        type = "cooking",
        output = "unifieddyes:bottle_9_pack",
        recipe = "default:glass",
})

-- The use of this mod will, if the mods that depend on it are written
-- correctly, generate lots of empty bottles, so let's recycle them.

-- First, pack them into a 9-pack unit by placing one into each of the 9
-- crafting slots.

minetest.register_craft( {
       output = "unifieddyes:bottle_9_pack",
       recipe = {
               { "unifieddyes:empty_bottle", "unifieddyes:empty_bottle", "unifieddyes:empty_bottle" },
               { "unifieddyes:empty_bottle", "unifieddyes:empty_bottle", "unifieddyes:empty_bottle" },
               { "unifieddyes:empty_bottle", "unifieddyes:empty_bottle", "unifieddyes:empty_bottle" },
                },
})

-- then smelt the 9-pack back into a glass block:

minetest.register_craft({
        type = "cooking",
        output = "default:glass",
        recipe = "unifieddyes:bottle_9_pack",
})

-- Now, once you have a 9-pack of bottles, craft it with one bucket of water
-- and a piece of jungle grass to get 9 individual portions of the liquid dye
-- base and an empty bucket:

minetest.register_craftitem("unifieddyes:dye_base", {
        description = "Uncolored Dye Base Liquid",
        inventory_image = "unifieddyes_dye_base.png",
})

minetest.register_craft( {
       type = "shapeless",
       output = "unifieddyes:dye_base 9",
       recipe = {
               "bucket:bucket_water",
               "default:junglegrass",
               "unifieddyes:bottle_9_pack",
                },
        replacements = { {'bucket:bucket_water', 'bucket:bucket_empty'}, },
})

--==========================================================================
-- Now we need to turn our color sources (flowers, etc) into pigments and from
-- there into actual usable dyes.  There are seven base colors - one for each
-- flower, plus black (as "carbon black") from coal, and white (as "titanium
-- dioxide") from stone.  Most give two portions of pigment; cactus gives 6,
-- stone gives 10.

pigments = {
	"red",
	"orange",
	"yellow",
	"green",
	"blue",
	"carbon_black",
}

pigmentsdesc = {
	"Red",
	"Orange",
	"Yellow",
	"Green",
	"Blue",
}

dyesdesc = {
	"Red",
	"Orange",
	"Yellow",
	"Green",
	"Blue",
}
	
colorsources = {
	"flowers:flower_rose",
	"flowers:flower_tulip",
	"flowers:flower_dandelion_yellow",
	"flowers:flower_waterlily",
	"flowers:flower_viola",
}

for color = 1, 5 do

	-- the recipes to turn sources into pigments

	minetest.register_craftitem("unifieddyes:pigment_"..pigments[color], {
		description = pigmentsdesc[color].." Pigment",
		inventory_image = "unifieddyes_pigment_"..pigments[color]..".png",
	})

	minetest.register_craft({
		type = "cooking",
		output = "unifieddyes:pigment_"..pigments[color].." 2",
		recipe = colorsources[color],
	})

	-- The recipes to turn pigments into usable dyes

	minetest.register_craftitem("unifieddyes:"..pigments[color], {
		description = dyesdesc[color].." Dye",
		inventory_image = "unifieddyes_"..pigments[color]..".png",
	})

	minetest.register_craft( {
		type = "shapeless",
		output = "unifieddyes:"..pigments[color],
		recipe = {
			"unifieddyes:pigment_"..pigments[color],
			"unifieddyes:dye_base"
		}
	})
end

-- Stone->titanium dioxide and cactus->green pigment are done separately
-- because of their larger yields

minetest.register_craftitem("unifieddyes:titanium_dioxide", {
	description = "Titanium Dioxide",
	inventory_image = "unifieddyes_titanium_dioxide.png",
})

minetest.register_craft({
	type = "cooking",
	output = "unifieddyes:titanium_dioxide 10",
	recipe = "default:stone",
})

minetest.register_craft({
	type = "cooking",
	output = "unifieddyes:pigment_green 6",
	recipe = "default:cactus",
})

-- coal->carbon black and carbon black -> black dye are done separately
-- because of the different names

minetest.register_craftitem("unifieddyes:carbon_black", {
	description = "Carbon Black",
	inventory_image = "unifieddyes_carbon_black.png",
})

minetest.register_craft({
	type = "cooking",
	output = "unifieddyes:carbon_black 2",
	recipe = "default:coal_lump",
})

minetest.register_craftitem("unifieddyes:black", {
	description = "Carbon Black",
	inventory_image = "unifieddyes_black.png",
})

minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:black",
        recipe = {
                "unifieddyes:carbon_black",
                "unifieddyes:dye_base",
        },
})

--=======================================================================
-- Now that we have the dyes in a usable form, let's mix the various
-- ingredients together to create the rest of the mod's colors and greys.


----------------------------
-- The 5 levels of greyscale

-- White paint

minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:white_paint",
        recipe = {
                "unifieddyes:titanium_dioxide",
                "bucket:bucket_water",
                "default:junglegrass",
        },
})

minetest.register_craftitem("unifieddyes:white_paint", {
        description = "White Paint",
        inventory_image = "unifieddyes_white_paint.png",
	groups = {dye=1},
})

-- Light grey paint

minetest.register_craft( {
       type = "shapeless",
       output = "unifieddyes:lightgrey_paint 3",
       recipe = {
               "unifieddyes:white_paint",
               "unifieddyes:white_paint",
               "unifieddyes:carbon_black",
		},
})

minetest.register_craftitem("unifieddyes:lightgrey_paint", {
        description = "Light grey paint",
        inventory_image = "unifieddyes_lightgrey_paint.png",
	groups = {dye=1},
})

-- Medium grey paint

minetest.register_craft( {
       type = "shapeless",
       output = "unifieddyes:grey_paint 2",
       recipe = {
               "unifieddyes:white_paint",
               "unifieddyes:carbon_black",
		},
})

minetest.register_craftitem("unifieddyes:grey_paint", {
        description = "Medium grey paint",
        inventory_image = "unifieddyes_grey_paint.png",
	groups = {dye=1},
})

-- Dark grey paint

minetest.register_craft( {
       type = "shapeless",
       output = "unifieddyes:darkgrey_paint 3",
       recipe = {
               "unifieddyes:white_paint",
               "unifieddyes:carbon_black",
               "unifieddyes:carbon_black",
		},
})

minetest.register_craftitem("unifieddyes:darkgrey_paint", {
        description = "Dark grey paint",
        inventory_image = "unifieddyes_darkgrey_paint.png",
	groups = {dye=1},
})


--=============================================================================
-- Smelting/crafting recipes needed to generate various remaining 'full' colors
-- (the register_craftitem functions are in the generate-the-rest loop below).

-- Cyan

minetest.register_craft( {
       type = "shapeless",
       output = "unifieddyes:cyan 2",
       recipe = {
               "unifieddyes:blue",
               "unifieddyes:green",
		},
})

-- Magenta

minetest.register_craft( {
       type = "shapeless",
       output = "unifieddyes:magenta 2",
       recipe = {
               "unifieddyes:blue",
               "unifieddyes:red",
		},
})

-- Lime

minetest.register_craft( {
       type = "shapeless",
       output = "unifieddyes:lime 2",
       recipe = {
               "unifieddyes:yellow",
               "unifieddyes:green",
		},
})

-- Aqua

minetest.register_craft( {
       type = "shapeless",
       output = "unifieddyes:aqua 2",
       recipe = {
               "unifieddyes:cyan",
               "unifieddyes:green",
		},
})

-- Sky blue

minetest.register_craft( {
       type = "shapeless",
       output = "unifieddyes:skyblue 2",
       recipe = {
               "unifieddyes:cyan",
               "unifieddyes:blue",
		},
})

-- Violet

minetest.register_craft( {
       type = "shapeless",
       output = "unifieddyes:violet 2",
       recipe = {
               "unifieddyes:blue",
               "unifieddyes:magenta",
		},
})

minetest.register_craft( {
       type = "shapeless",
       output = "unifieddyes:violet 3",
       recipe = {
               "unifieddyes:blue",
               "unifieddyes:blue",
               "unifieddyes:red",
		},
})


-- Red-violet

minetest.register_craft( {
       type = "shapeless",
       output = "unifieddyes:redviolet 2",
       recipe = {
               "unifieddyes:red",
               "unifieddyes:magenta",
		},
})


-- =================================================================

-- Finally, generate all of additional variants of hue, saturation, and
-- brightness.

-- "s50" in a file/item name means "saturation: 50%".
-- Brightness levels in the textures are 33% ("dark"), 66% ("medium"),
-- 100% ("full" but not so-named), and 150% ("light").

HUES = {
	"red",
	"orange",
	"yellow",
	"lime",
	"green",
	"aqua",
	"cyan",
	"skyblue",
	"blue",
	"violet",
	"magenta",
	"redviolet"
}

for i = 1, 12 do

	hue = HUES[i]

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:dark_" .. hue .. "_s50 2",
        recipe = {
                "unifieddyes:" .. hue,
                "unifieddyes:darkgrey_paint",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:dark_" .. hue .. "_s50 4",
        recipe = {
                "unifieddyes:" .. hue,
                "unifieddyes:black",
                "unifieddyes:black",
		"unifieddyes:white_paint"
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:dark_" .. hue .. " 3",
        recipe = {
                "unifieddyes:" .. hue,
                "unifieddyes:black",
                "unifieddyes:black",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:medium_" .. hue .. "_s50 2",
        recipe = {
                "unifieddyes:" .. hue,
                "unifieddyes:grey_paint",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:medium_" .. hue .. "_s50 3",
        recipe = {
                "unifieddyes:" .. hue,
		"unifieddyes:black",
                "unifieddyes:white_paint",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:medium_" .. hue .. " 2",
        recipe = {
                "unifieddyes:" .. hue,
                "unifieddyes:black",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:" .. hue .. "_s50 2",
        recipe = {
                "unifieddyes:" .. hue,
                "unifieddyes:lightgrey_paint",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:" .. hue .. "_s50 4",
        recipe = {
                "unifieddyes:" .. hue,
                "unifieddyes:white_paint",
                "unifieddyes:white_paint",
                "unifieddyes:black",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:light_" .. hue .. " 2",
        recipe = {
                "unifieddyes:" .. hue,
                "unifieddyes:white_paint",
	        },
	})

	minetest.register_craftitem("unifieddyes:dark_" .. hue .. "_s50", {
		description = "Dark " .. hue .. " (low saturation)",
		inventory_image = "unifieddyes_dark_" .. hue .. "_s50.png",
		groups = {dye=1},
	})

	minetest.register_craftitem("unifieddyes:dark_" .. hue, {
		description = "Dark " .. hue,
		inventory_image = "unifieddyes_dark_" .. hue .. ".png",
		groups = {dye=1},
	})

	minetest.register_craftitem("unifieddyes:medium_" .. hue .. "_s50", {
		description = "Medium " .. hue .. " (low saturation)",
		inventory_image = "unifieddyes_medium_" .. hue .. "_s50.png",
		groups = {dye=1},
	})

	minetest.register_craftitem("unifieddyes:medium_" .. hue, {
		description = "Medium " .. hue,
		inventory_image = "unifieddyes_medium_" .. hue .. ".png",
		groups = {dye=1},
	})

	minetest.register_craftitem("unifieddyes:" .. hue .. "_s50", {
		description = "Full " .. hue .. " (low saturation)",
		inventory_image = "unifieddyes_" .. hue .. "_s50.png",
		groups = {dye=1},
	})

	minetest.register_craftitem("unifieddyes:" .. hue, {
		description = "Full " .. hue,
		inventory_image = "unifieddyes_" .. hue .. ".png",
		groups = {dye=1},
	})

	minetest.register_craftitem("unifieddyes:light_" .. hue, {
		description = "Light " .. hue,
		inventory_image = "unifieddyes_light_" .. hue .. ".png",
		groups = {dye=1},
	})

end



print("[UnifiedDyes] Loaded!")

