---
--easyvend
--Copyright (C) 2012 Bad_Command, 2016 Wuzzy
--
--This library is free software; you can redistribute it and/or
--modify it under the terms of the GNU Lesser General Public
--License as published by the Free Software Foundation; either
--version 2.1 of the License, or (at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU Lesser General Public
--License along with this library; if not, write to the Free Software
--Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
---

easyvend = {}
easyvend.version = 1.02

dofile(minetest.get_modpath("easyvend") .. "/easyvend.lua")

minetest.register_node("easyvend:vendor", {
	description = "Vending Machine",
	tile_images ={"easyvend_side.png", "easyvend_side.png", "easyvend_side.png",
		"easyvend_side.png", "easyvend_side.png", "easyvend_vendor_front.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},

	after_place_node = easyvend.after_place_node,
	can_dig = easyvend.can_dig,
	on_receive_fields = easyvend.on_receive_fields,
    allow_metadata_inventory_put = easyvend.allow_metadata_inventory_put,
    allow_metadata_inventory_take = easyvend.allow_metadata_inventory_take,
    allow_metadata_inventory_move = easyvend.allow_metadata_inventory_move,
})

minetest.register_node("easyvend:depositor", {
	description = "Depositing Machine",
	tile_images ={"easyvend_side.png", "easyvend_side.png", "easyvend_side.png",
		"easyvend_side.png", "easyvend_side.png", "easyvend_depositor_front.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},

	after_place_node = easyvend.after_place_node,
	can_dig = easyvend.can_dig,
	on_receive_fields = easyvend.on_receive_fields,
    allow_metadata_inventory_put = easyvend.allow_metadata_inventory_put,
    allow_metadata_inventory_take = easyvend.allow_metadata_inventory_take,
    allow_metadata_inventory_move = easyvend.allow_metadata_inventory_move,
})

minetest.register_craft({
	output = 'easyvend:vendor',
	recipe = {
                {'default:wood', 'default:wood', 'default:wood'},
                {'default:wood', 'default:steel_ingot', 'default:wood'},
                {'default:wood', 'default:steel_ingot', 'default:wood'},
        }
})

minetest.register_craft({
	output = 'easyvend:depositor',
	recipe = {
                {'default:wood', 'default:steel_ingot', 'default:wood'},
                {'default:wood', 'default:steel_ingot', 'default:wood'},
                {'default:wood', 'default:wood', 'default:wood'},
        }
})
