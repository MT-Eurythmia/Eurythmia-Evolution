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
easyvend.VERSION = {}
easyvend.VERSION.MAJOR = 1
easyvend.VERSION.MINOR = 0
easyvend.VERSION.PATCH = 0
easyvend.VERSION.STRING = easyvend.VERSION.MAJOR .. "." .. easyvend.VERSION.MINOR .. "." .. easyvend.VERSION.PATCH

dofile(minetest.get_modpath("easyvend") .. "/easyvend.lua")

local sounds
local soundsplus = {
	place = { name = "easyvend_activate", gain = 1 },
	dug = { name = "easyvend_disable", gain = 1 }, }
if minetest.get_modpath("default") ~= nil then
	sounds = default.node_sound_wood_defaults(soundsplus)
else
	sounds = soundsplus
end

local machine_template = {
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2},

	after_place_node = easyvend.after_place_node,
	can_dig = easyvend.can_dig,
	on_receive_fields = easyvend.on_receive_fields,
	sounds = sounds,

	allow_metadata_inventory_put = easyvend.allow_metadata_inventory_put,
	allow_metadata_inventory_take = easyvend.allow_metadata_inventory_take,
	allow_metadata_inventory_move = easyvend.allow_metadata_inventory_move,
	on_punch = easyvend.machine_check,
}

local vendor_on = table.copy(machine_template)
vendor_on.description = "Vending Machine"
vendor_on.tile_images ={"easyvend_vendor_side.png", "easyvend_vendor_bottom.png", "easyvend_vendor_side.png",
	"easyvend_vendor_side.png", "easyvend_vendor_side.png", "easyvend_vendor_front_on.png"}
vendor_on.groups.not_in_creative_inventory = 1
vendor_on.groups.not_in_doc = 1
vendor_on.drop = "easyvend:vendor"

local vendor_off = table.copy(machine_template)
vendor_off.description = vendor_on.description
vendor_off.tile_images = table.copy(vendor_on.tile_images)
vendor_off.tile_images[6] = "easyvend_vendor_front_off.png"

local depositor_on = table.copy(machine_template)
depositor_on.description = "Depositing Machine"
depositor_on.tile_images ={"easyvend_depositor_side.png", "easyvend_depositor_bottom.png", "easyvend_depositor_side.png",
	"easyvend_depositor_side.png", "easyvend_depositor_side.png", "easyvend_depositor_front_on.png"}
depositor_on.groups.not_in_creative_inventory = 1
depositor_on.groups.not_in_doc = 1
depositor_on.drop = "easyvend:depositor"

local depositor_off = table.copy(machine_template)
depositor_off.description = depositor_on.description
depositor_off.tile_images = table.copy(depositor_on.tile_images)
depositor_off.tile_images[6] = "easyvend_depositor_front_off.png"

minetest.register_node("easyvend:vendor", vendor_off)
minetest.register_node("easyvend:vendor_on", vendor_on)
minetest.register_node("easyvend:depositor", depositor_off)
minetest.register_node("easyvend:depositor_on", depositor_on)

if minetest.get_modpath("default") ~= nil then
	minetest.register_craft({
		output = 'easyvend:vendor',
		recipe = {
	                {'group:wood', 'group:wood', 'group:wood'},
	                {'group:wood', 'default:steel_ingot', 'group:wood'},
	                {'group:wood', 'default:steel_ingot', 'group:wood'},
	        }
	})

	minetest.register_craft({
		output = 'easyvend:depositor',
		recipe = {
	                {'group:wood', 'default:steel_ingot', 'group:wood'},
	                {'group:wood', 'default:steel_ingot', 'group:wood'},
	                {'group:wood', 'group:wood', 'group:wood'},
	        }
	})
end

if minetest.get_modpath("doc_items") ~= nil then
	doc.add_entry_alias("nodes", "easyvend:vendor", "easyvend:vendor_on")
	doc.add_entry_alias("nodes", "easyvend:depositor", "easyvend:depositor_on")
	doc.sub.items.set_items_longdesc({
		["easyvend:vendor"] = "A vending machine allows its owner to offer a certain item in exchange for gold ingots. The users can pay with gold ingots and will get the item or items in return.",
		["easyvend:depositor"] = "A depositing machine allows its owner to offer gold ingots in exchange for a certain item. The users can supply the depositing machine with the requested item and will get gold ingots in return.",
	})
	doc.sub.items.set_items_usagehelp({
		["easyvend:vendor"] = "For customers: The vending machine has to be ready to be used. If a green LED lights up, it is ready. Point the vending machine to see its owner and what it has to offer and at which price (item count first). Rightclick the vending machine to open the buying menu. You will pay with the number of items shown at “Price” and you will get the item at “Offered item” in return. Click on “OK” to buy this offer once, repeat this as often as you like.\nFor owners: First, place a locked chest and fill it with the item you want to sell, make sure you leave some inventory slots empty for the gold ingots. Place the vending machine directly on top of the locked chest. Rightclick the machine. Set the offered item by moving an item from your invenory into the slot. The price item can not be changed. Now set the number of items per sale and their price and click on “OK” to confirm. Check the message and status for any errors. If the status is “Ready.”, the machine works properly. All other status messages are errors. The earnings of the vending machine can be retrieved from the locked chest.",

		["easyvend:depositor"] = "For users: The depositing machine has to be ready to be used. If a green LED lights up, it is ready. Point the depositing machine to see its owner and what item it asks for and at which payment (item count first). Rightclick the depositing machine to open the selling menu. You will pay with the number of items shown at “Requested items” and you will get the items at “Payment” in return. Click on “OK” to start a single exchange, repeat this as often as you like.\nFor owners: First, place a locked chest and supply it with gold ingots, make sure you leave some inventory slots empty for the items you want to retrieve. Place the depositing machine directly on top of the locked chest. Rightclick the machine. Set the requested item by moving an item from your invenory into the slot. The payment item can not be changed. Now set the number of requested items and their price and click on “OK” to confirm. Check the message and status for any errors. If the status is “Ready.”, the machine works properly, all other status messages are errors. The deposited items can be retrieved from the locked chest.",
	})
end
