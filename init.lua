--[[

Unified Dyes

This mod provides an extension to the Minetest 0.4.x dye system

==============================================================================

Copyright (C) 2012-2013, Vanessa Ezekowitz
Email: vanessaezekowitz@gmail.com

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

==============================================================================

--]]

--=====================================================================

unifieddyes = {}

-- Boilerplate to support localized strings if intllib mod is installed.
local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end

unifieddyes.hue_to_idx = {
	red = 2,
	orange = 3,
	yellow = 4,
	lime = 5,
	green = 6,
	aqua = 7,
	cyan = 8,
	skyblue = 9,
	blue = 10,
	violet = 11,
	magenta = 12,
	redviolet = 13,

	grey = 1
}

-- helper functions for other mods that use this one

-- code borrowed from homedecor

function unifieddyes.select_node(pointed_thing)
	local pos = pointed_thing.under
	local node = minetest.get_node_or_nil(pos)
	local def = node and minetest.registered_nodes[node.name]

	if not def or not def.buildable_to then
		pos = pointed_thing.above
		node = minetest.get_node_or_nil(pos)
		def = node and minetest.registered_nodes[node.name]
	end
	return def and pos, def
end

function unifieddyes.is_buildable_to(placer_name, ...)
	for _, pos in ipairs({...}) do
		local node = minetest.get_node_or_nil(pos)
		local def = node and minetest.registered_nodes[node.name]
		if not (def and def.buildable_to) or minetest.is_protected(pos, placer_name) then
			return false
		end
	end
	return true
end

-- code borrowed from cheapie's plasticbox mod

function unifieddyes.getpaletteidx(color)
	local aliases = {
		["pink"] = "light_red",
		["brown"] = "dark_orange",
	}

	local grayscale = {
		["white"] = 1,
		["light_grey"] = 2,
		["grey"] = 3,
		["dark_grey"] = 4,
		["black"] = 5,
	}

	local hues = {
		["red"] = 1,
		["orange"] = 2,
		["yellow"] = 3,
		["lime"] = 4,
		["green"] = 5,
		["aqua"] = 6,
		["cyan"] = 7,
		["skyblue"] = 8,
		["blue"] = 9,
		["violet"] = 10,
		["magenta"] = 11,
		["redviolet"] = 12,
	}

	local shades = {
		[""] = 1,
		["s50"] = 2,
		["light"] = 3,
		["medium"] = 4,
		["mediums50"] = 5,
		["dark"] = 6,
		["darks50"] = 7,
	}

	if string.sub(color,1,4) == "dye:" then
		color = string.sub(color,5,-1)
	elseif string.sub(color,1,12) == "unifieddyes:" then
		color = string.sub(color,13,-1)
	else
		return
	end

	color = aliases[color] or color

	if grayscale[color] then
		return(grayscale[color])
	end

	local shade = ""
	if string.sub(color,1,6) == "light_" then
		shade = "light"
		color = string.sub(color,7,-1)
	elseif string.sub(color,1,7) == "medium_" then
		shade = "medium"
		color = string.sub(color,8,-1)
	elseif string.sub(color,1,5) == "dark_" then
		shade = "dark"
		color = string.sub(color,6,-1)
	end
	if string.sub(color,-4,-1) == "_s50" then
		shade = shade.."s50"
		color = string.sub(color,1,-5)
	end

	if hues[color] and shades[shade] then
		return(hues[color] * 8 + shades[shade])
	end
end

function unifieddyes.on_destruct(pos)
	local meta = minetest.get_meta(pos)
	local prevdye = meta:get_string("dye")
	if minetest.registered_items[prevdye] then
		minetest.add_item(pos,prevdye)
	end
end

function unifieddyes.on_rightclick(pos, node, player, stack, pointed_thing, newnode)
	local name = player:get_player_name()
	if minetest.is_protected(pos,name) and not minetest.check_player_privs(name,{protection_bypass=true}) then
		minetest.record_protection_violation(pos,name)
		return stack
	end
	local name = stack:get_name()

	local paletteidx = unifieddyes.getpaletteidx(name)
	if paletteidx then

		local meta = minetest.get_meta(pos)
		local prevdye = meta:get_string("dye")
		if minetest.registered_items[prevdye] then
			local inv = player:get_inventory()
			if inv:room_for_item("main",prevdye) then
				inv:add_item("main",prevdye)
			else
				minetest.add_item(pos,prevdye)
			end
		end
		meta:set_string("dye",name)
		stack:take_item()
		node.param2 = paletteidx
		if newnode then
			node.name = newnode
			minetest.swap_node(pos, node)
		else
			minetest.swap_node(pos, node)
		end
	else
		local pos2 = unifieddyes.select_node(pointed_thing)
		if unifieddyes.is_buildable_to(player:get_player_name(), pos2) and
		  minetest.registered_nodes[name] then
			local oldnode = minetest.registered_nodes[stack:get_name()]
			minetest.set_node(pos2, oldnode)
			stack:take_item()
			return stack
		end
	end
end

-- Items/recipes needed to generate the few base colors that are not
-- provided by the standard dyes mod.

-- Lime

minetest.register_craftitem(":dye:lime", {
        description = S("Lime Dye"),
        inventory_image = "unifieddyes_lime.png",
	groups = { dye=1, excolor_lime=1, unicolor_lime=1, not_in_creative_inventory=1 }
})

minetest.register_craft( {
       type = "shapeless",
       output = "dye:lime 2",
       recipe = {
               "dye:yellow",
               "dye:green",
		},
})

-- Aqua

minetest.register_craftitem(":dye:aqua", {
        description = S("Aqua Dye"),
        inventory_image = "unifieddyes_aqua.png",
	groups = { dye=1, excolor_aqua=1, unicolor_aqua=1, not_in_creative_inventory=1 }
})

minetest.register_craft( {
       type = "shapeless",
       output = "dye:aqua 2",
       recipe = {
               "dye:cyan",
               "dye:green",
		},
})

-- Sky blue

minetest.register_craftitem(":dye:skyblue", {
        description = S("Sky-blue Dye"),
        inventory_image = "unifieddyes_skyblue.png",
	groups = { dye=1, excolor_sky_blue=1, unicolor_sky_blue=1, not_in_creative_inventory=1 }
})

minetest.register_craft( {
       type = "shapeless",
       output = "dye:skyblue 2",
       recipe = {
               "dye:cyan",
               "dye:blue",
		},
})

-- Red-violet

minetest.register_craftitem(":dye:redviolet", {
        description = S("Red-violet Dye"),
        inventory_image = "unifieddyes_redviolet.png",
	groups = { dye=1, excolor_red_violet=1, unicolor_red_violet=1, not_in_creative_inventory=1 }
})

minetest.register_craft( {
       type = "shapeless",
       output = "dye:redviolet 2",
       recipe = {
               "dye:red",
               "dye:magenta",
		},
})


-- Light grey

minetest.register_craftitem(":dye:light_grey", {
        description = S("Light Grey Dye"),
        inventory_image = "unifieddyes_lightgrey.png",
	groups = { dye=1, excolor_lightgrey=1, unicolor_light_grey=1, not_in_creative_inventory=1 }
})

minetest.register_craft( {
       type = "shapeless",
       output = "dye:light_grey 2",
       recipe = {
               "dye:grey",
               "dye:white",
		},
})

-- Extra craft for black dye

minetest.register_craft( {
       type = "shapeless",
       output = "dye:black 4",
       recipe = {
               "default:coal_lump",
		},
})

-- Extra craft for dark grey dye

minetest.register_craft( {
       type = "shapeless",
       output = "dye:dark_grey 3",
       recipe = {
               "dye:black",
               "dye:black",
               "dye:white",
		},
})

-- Extra craft for light grey dye

minetest.register_craft( {
       type = "shapeless",
       output = "dye:light_grey 3",
       recipe = {
               "dye:black",
               "dye:white",
               "dye:white",
		},
})

-- Extra craft for green dye

minetest.register_craft( {
       type = "shapeless",
       output = "dye:green 4",
       recipe = {
               "default:cactus",
		},
})

-- =================================================================

-- Generate all of additional variants of hue, saturation, and
-- brightness.

-- "s50" in a file/item name means "saturation: 50%".
-- Brightness levels in the textures are 33% ("dark"), 66% ("medium"),
-- 100% ("full", but not so-named), and 150% ("light").

local HUES = {
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

local HUES2 = {
	"Red",
	"Orange",
	"Yellow",
	"Lime",
	"Green",
	"Aqua",
	"Cyan",
	"Sky-blue",
	"Blue",
	"Violet",
	"Magenta",
	"Red-violet"
}


for i = 1, 12 do

	local hue = HUES[i]
	local hue2 = HUES2[i]

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:dark_" .. hue .. "_s50 2",
        recipe = {
                "dye:" .. hue,
                "dye:dark_grey",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:dark_" .. hue .. "_s50 4",
        recipe = {
                "dye:" .. hue,
                "dye:black",
                "dye:black",
		"dye:white"
	        },
	})

	if hue == "green" then

		minetest.register_craft( {
		type = "shapeless",
		output = "dye:dark_green 3",
		recipe = {
		        "dye:" .. hue,
		        "dye:black",
		        "dye:black",
			},
		})
	else
		minetest.register_craft( {
		type = "shapeless",
		output = "unifieddyes:dark_" .. hue .. " 3",
		recipe = {
		        "dye:" .. hue,
		        "dye:black",
		        "dye:black",
			},
		})
	end

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:medium_" .. hue .. "_s50 2",
        recipe = {
                "dye:" .. hue,
                "dye:grey",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:medium_" .. hue .. "_s50 3",
        recipe = {
                "dye:" .. hue,
		"dye:black",
                "dye:white",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:medium_" .. hue .. " 2",
        recipe = {
                "dye:" .. hue,
                "dye:black",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:" .. hue .. "_s50 2",
        recipe = {
                "dye:" .. hue,
                "dye:grey",
                "dye:white",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:" .. hue .. "_s50 4",
        recipe = {
                "dye:" .. hue,
                "dye:white",
                "dye:white",
                "dye:black",
	        },
	})

	if hue ~= "red" then
		minetest.register_craft( {
		type = "shapeless",
		output = "unifieddyes:light_" .. hue .. " 2",
		recipe = {
			"dye:" .. hue,
			"dye:white",
			},
		})
	end

	minetest.register_craftitem("unifieddyes:dark_" .. hue .. "_s50", {
		description = S("Dark " .. hue2 .. " Dye (low saturation)"),
		inventory_image = "unifieddyes_dark_" .. hue .. "_s50.png",
		groups = { dye=1, ["unicolor_dark_"..hue.."_s50"]=1, not_in_creative_inventory=1 }
	})

	if hue ~= "green" then
		minetest.register_craftitem("unifieddyes:dark_" .. hue, {
			description = S("Dark " .. hue2 .. " Dye"),
			inventory_image = "unifieddyes_dark_" .. hue .. ".png",
			groups = { dye=1, ["unicolor_dark_"..hue]=1, not_in_creative_inventory=1 }
		})
	end

	minetest.register_craftitem("unifieddyes:medium_" .. hue .. "_s50", {
		description = S("Medium " .. hue2 .. " Dye (low saturation)"),
		inventory_image = "unifieddyes_medium_" .. hue .. "_s50.png",
		groups = { dye=1, ["unicolor_medium_"..hue.."_s50"]=1, not_in_creative_inventory=1 }
	})

	minetest.register_craftitem("unifieddyes:medium_" .. hue, {
		description = S("Medium " .. hue2 .. " Dye"),
		inventory_image = "unifieddyes_medium_" .. hue .. ".png",
		groups = { dye=1, ["unicolor_medium_"..hue]=1, not_in_creative_inventory=1 }
	})

	minetest.register_craftitem("unifieddyes:" .. hue .. "_s50", {
		description = S(hue2 .. " Dye (low saturation)"),
		inventory_image = "unifieddyes_" .. hue .. "_s50.png",
		groups = { dye=1, ["unicolor_"..hue.."_s50"]=1, not_in_creative_inventory=1 }
	})

	if hue ~= "red" then
		minetest.register_craftitem("unifieddyes:light_" .. hue, {
			description = S("Light " .. hue2 .. " Dye"),
			inventory_image = "unifieddyes_light_" .. hue .. ".png",
			groups = { dye=1, ["unicolor_light_"..hue]=1, not_in_creative_inventory=1 }
		})
	end
	minetest.register_alias("unifieddyes:"..hue, "dye:"..hue)
	minetest.register_alias("unifieddyes:pigment_"..hue, "dye:"..hue)
end

minetest.register_alias("unifieddyes:light_red",  "dye:pink")
minetest.register_alias("unifieddyes:dark_green", "dye:dark_green")
minetest.register_alias("unifieddyes:black",      "dye:black")
minetest.register_alias("unifieddyes:darkgrey",   "dye:dark_grey")
minetest.register_alias("unifieddyes:grey",       "dye:grey")
minetest.register_alias("unifieddyes:lightgrey",  "dye:light_grey")
minetest.register_alias("unifieddyes:white",      "dye:white")

minetest.register_alias("unifieddyes:white_paint", "dye:white")
minetest.register_alias("unifieddyes:titanium_dioxide", "dye:white")
minetest.register_alias("unifieddyes:lightgrey_paint", "dye:light_grey")
minetest.register_alias("unifieddyes:grey_paint", "dye:grey")
minetest.register_alias("unifieddyes:darkgrey_paint", "dye:dark_grey")
minetest.register_alias("unifieddyes:carbon_black", "dye:black")

print(S("[UnifiedDyes] Loaded!"))

