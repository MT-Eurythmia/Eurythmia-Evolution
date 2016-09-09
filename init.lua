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
easyvend.VERSION.MAJOR = 0
easyvend.VERSION.MINOR = 1
easyvend.VERSION.PATCH = 1
easyvend.VERSION.STRING = easyvend.VERSION.MAJOR .. "." .. easyvend.VERSION.MINOR .. "." .. easyvend.VERSION.PATCH

-- Set item which is used as payment for vending and depositing machines
easyvend.currency = minetest.setting_get("easyvend_currency")
if easyvend.currency == nil or minetest.registered_items[easyvend.currency] == nil then
	-- Default currency
	easyvend.currency = "default:gold_ingot"
end
easyvend.currency_desc = minetest.registered_items[easyvend.currency].description
if easyvend.currency_desc == nil or easyvend.currency_desc == "" then
	easyvend.currency_desc = easyvend.currency
end

dofile(minetest.get_modpath("easyvend") .. "/easyvend.lua")

local sounds
local soundsplus = {
	place = { name = "easyvend_disable", gain = 1 },
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

if minetest.get_modpath("screwdriver") ~= nil then
	machine_template.on_rotate = screwdriver.rotate_simple
end

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

-- Legacy support for vendor mod:
-- Transform the world and items to use the easyvend nodes/items

-- For safety reasons, vendor mod must be disabled before legacy mode goes on
if minetest.get_modpath("vendor") == nil then
	-- Replace vendor nodes
	minetest.register_lbm({
		name = "easyvend:replace_vendor",
		nodenames = { "vendor:vendor", "vendor:depositor" },
		action = function(pos, node)
			local newnodename
			if node.name == "vendor:vendor" then
				newnodename = "easyvend:vendor"
			elseif node.name == "vendor:depositor" then
				newnodename = "easyvend:depositor"
			end
			minetest.swap_node(pos, { name = newnodename, param2 = node.param2 })
			local meta = minetest.get_meta(pos)
			meta:set_string("status", "Initializing …")
			meta:set_string("message", "Upgrade successful.")
			meta:set_int("stock", -1)
			meta:set_int("joketimer", -1)
			meta:set_int("joke_id", 1)
			local inv = meta:get_inventory()
			inv:set_size("item", 1)
			inv:set_size("gold", 1)
			inv:set_stack("gold", 1, easyvend.currency)

			local itemname = meta:get_string("itemname")
			local configmode = 1
			if itemname == "" or itemname == nil then
				-- If no itemname set, try to scan first item in chest below
				local chest = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z})
				if chest.name == "default:chest_locked" then
					local chest_meta = minetest.get_meta({x=pos.x,y=pos.y-1,z=pos.z})
					local chest_inv = chest_meta:get_inventory()
					if ( chest_meta:get_string("owner") == machine_owner and chest_inv ~= nil ) then
					end
					for i=1,chest_inv:get_size("main") do
						checkstack = chest_inv:get_stack("main", i)
						if not checkstack:is_empty() then
							itemname = checkstack:get_name()
							break
						end
					end
				end
				if itemname ~= "" and itemname ~= nil then
					inv:set_stack("item", 1, itemname)
					meta:set_string("itemname", itemname)
				end
			end
			if itemname ~= "" and itemname ~= nil and meta:get_int("gold") >= 1 or meta:get_int("number") >= 1 then
				configmode = 0
			end

			meta:set_int("configmode", configmode)
			easyvend.machine_check(pos, node)
		end,
	})
end

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
		["easyvend:vendor"] = string.format("A vending machine allows its owner to offer a certain item in exchange for money (%s). The users can pay with money and will some items in return.", easyvend.currency_desc),
		["easyvend:depositor"] = string.format("A depositing machine allows its owner to offer money (%s) in exchange for a certain item. The users can supply the depositing machine with the requested item and will get money in return.", easyvend.currency_desc),
	})
	doc.sub.items.set_items_usagehelp({
		["easyvend:vendor"] = "For customers: The vending machine has to be ready to be used, which is the case if the green LED lights up. Point the vending machine to see its owner and what it has to offer and at which price (item count first). Rightclick it to open the buying menu. You can pay with the number of items shown at “Price” and you will get the item at “Offered item” in return. Click on “Buy” to buy this offer once, repeat this as often as you like.\nFor owners: First, place a locked chest and fill it with the item you want to sell, make sure you leave some inventory slots empty for the price. Place the vending machine directly on top of the locked chest. Rightclick the machine. Set the offered item by moving an item from your invenory into the slot. The price item can not be changed. Now set the number of items per sale and their price and click on “Confirm” to confirm. Check the message and status for any errors. If the status is “Ready.”, the machine works properly. All other status messages are errors. The earnings of the vending machine can be retrieved from the locked chest.",

		["easyvend:depositor"] = "For users: The depositing machine has to be ready to be used, which is the case if the green LED lights up. Point the depositing machine to see its owner and what item it asks for and at which payment (item count first). Rightclick it to open the selling menu. You can give the number of items shown at “Requested item” and you will get the items at “Payment” in return. Click on “Sell” to exchange items, repeat this as often as you like.\nFor owners: First, place a locked chest and supply it with the payment item, make sure you leave some inventory slots empty for the items you want to retrieve. Place the depositing machine directly on top of the locked chest. Rightclick the machine. Set the requested item by moving an item from your invenory into the slot. The payment item can not be changed. Now set the number of requested items and how much you pay for them and click on “Confirm” to confirm. Check the message and status for any errors. If the status is “Ready.”, the machine works properly, all other status messages are errors. The deposited items can be retrieved from the locked chest.",
	})
end
