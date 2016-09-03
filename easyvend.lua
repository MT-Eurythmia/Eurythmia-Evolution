---
--vendor
--Copyright (C) 2012 Bad_Command
--Rewrited by Andrej
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

-- TODO: Improve mod compability
local slots_max = 31
local currency = "default:gold_ingot"
local currency_desc = minetest.registered_items[currency].description
local registered_chests = {}
local cost_stack_max = ItemStack(currency):get_stack_max()
local maxcost = cost_stack_max * slots_max

-- Allow for other mods to register custom chests
easyvend.register_chest = function(node_name, inv_list, meta_owner)
	registered_chests[node_name] = { inv_list = inv_list, meta_owner = meta_owner }
end

-- Partly a wrapper around contains_item, but does special treatment if the item
-- is a tool. Basically checks whether the items exist in the supplied inventory
-- list. If check_wear is true, only counts items without wear.
easyvend.check_and_get_items = function(inventory, listname, itemtable, check_wear)
	local itemstring = itemtable.name
	local minimum = itemtable.count
	if check_wear == nil then check_wear = false end
	local get_items = {}
	-- Tool workaround
	if minetest.registered_tools[itemstring] ~= nil then
		local count = 0
		local ok = false
		for i=1,inventory:get_size(listname) do
			local stack = inventory:get_stack(listname, i)
			if stack:get_name() == itemstring then
				if not check_wear or stack:get_wear() == 0 then
					count = count + 1
					table.insert(get_items, {id=i, item=stack})
					if count >= minimum then
						return true, get_items
					end
				end
			end
		end
		return false
	else
		-- Normal Minetest check
		return inventory:contains_item(listname, ItemStack(itemtable))
	end
end


if minetest.get_modpath("default") ~= nil then
	easyvend.register_chest("default:chest_locked", "main", "owner")
end

easyvend.free_slots= function(inv, listname)
	local size = inv:get_size(listname)
	local free = 0
	for i=1,size do
		local stack = inv:get_stack(listname, i)
		if stack:is_empty() then
			free = free + 1
		end
	end
	return free
end

easyvend.buysell = function(nodename)
	local buysell = nil
	if ( nodename == "easyvend:depositor" or nodename == "easyvend:depositor_on" ) then
		buysell = "buy"
	elseif ( nodename == "easyvend:vendor" or nodename == "easyvend:vendor_on" ) then
		buysell = "sell"
	end
	return buysell
end

easyvend.set_formspec = function(pos, player)
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)

	local description = minetest.registered_nodes[node.name].description;
	local number = meta:get_int("number")
	local cost = meta:get_int("cost")
        local bg = ""
	local configmode = meta:get_int("configmode") == 1
        if minetest.get_modpath("default") then
            bg = default.gui_bg .. default.gui_bg_img .. default.gui_slots
        end

        local numbertext, costtext, numbertooltip, costtooltip, buysellbuttontext
        local buysell = easyvend.buysell(node.name)
        if buysell == "sell" then
		numbertext = "Offered item"
		numbertooltip = "Number of items being sold for the specified price"
		costtext = "Price"
		costtooltip = "How much the user is asked to pay for the offered item"
		buysellbuttontext = "Buy"
        elseif buysell == "buy" then
		numbertext = "Requested item"
		numbertooltip = "Number of items the user is asked to supply"
		costtext = "Payment"
		costtooltip = "How much will be given to the user in return"
		buysellbuttontext = "Sell"
        else
		return
	end
	local status = meta:get_string("status")
	if status == "" then status = "Unknown." end
	local message = meta:get_string("message")
	if message == "" then message = "No message." end
	local status_image
	if node.name == "easyvend:vendor_on" or node.name == "easyvend:depositor_on" then
		status_image = "easyvend_status_on.png"
	else
		status_image = "easyvend_status_off.png"
	end

	local formspec = "size[8,7.3;]"
        .. bg
	.."label[3,-0.2;" .. minetest.formspec_escape(description) .. "]"

	.."image[7.5,0.2;0.5,1;" .. status_image .. "]"
	.."textarea[2.8,0.2;5.1,2;;Status: " .. minetest.formspec_escape(status) .. ";]"
	.."textarea[2.8,1.3;5.6,2;;Message: " .. minetest.formspec_escape(message) .. ";]"

		.."label[0,-0.15;"..numbertext.."]"
		.."label[0,1.2;"..costtext.."]"
        .."list[current_player;main;0,3.5;8,4;]"
	if configmode then
		local wear = "false"
		if meta:get_int("wear") == 1 then wear = "true" end
		formspec = formspec
                .."list[current_name;gold;0,1.65;1,1;]"
                .."list[current_name;item;0,0.35;1,1;]"
                .."listring[current_player;main]"
                .."listring[current_name;item]"
		.."field[1.3,0.65;1.5,1;number;;" .. number .. "]"
		.."tooltip[number;"..numbertooltip.."]"
		.."field[1.3,1.95;1.5,1;cost;;" .. cost .. "]"
		.."tooltip[cost;"..costtooltip.."]"
		.."button[6,2.8;2,0.5;save;Confirm]"
		local weartext, weartooltip
		if buysell == "buy" then
			weartext = "Accept worn tools"
			weartooltip = "If disabled, only tools in perfect condition will be bought from sellers."
		else
			weartext = "Sell worn tools"
			weartooltip = "If disabled, only tools in perfect condition will be sold."
		end
		formspec = formspec .."checkbox[2,2.4;wear;"..minetest.formspec_escape(weartext)..";"..wear.."]"
		.."tooltip[wear;"..minetest.formspec_escape(weartooltip).."]"
	else
		local itemname = meta:get_string("itemname")
		formspec = formspec
                .."item_image_button[0,1.65;1,1;"..currency..";currency_image;]"
                .."item_image_button[0,0.35;1,1;"..itemname..";item_image;]"
		.."label[1,1.85;×" .. cost .. "]"
		.."label[1,0.55;×" .. number .. "]"
		.."button[6,2.8;2,0.5;config;Configure]"
		.."button[0,2.8;2,0.5;buysell;"..buysellbuttontext.."]"
		if minetest.registered_tools[itemname] ~= nil then
			local weartext
			if meta:get_int("wear") == 0 then
				if buysell == "buy" then
					weartext = "Only intact tools are bought."
				else
					weartext = "Only intact tools are sold."
				end
			elseif buysell == "sell" then
				weartext = "Warning: Might sell worn tools."
			end
			if weartext ~= nil then
				formspec = formspec .."textarea[2.3,2.6;3,1;;"..minetest.formspec_escape(weartext)..";]"
			end
		end
	end

	meta:set_string("formspec", formspec)
end

easyvend.machine_disable = function(pos, node, playername)
	if node.name == "easyvend:vendor_on" then
                easyvend.sound_disable(pos)
		minetest.swap_node(pos, {name="easyvend:vendor", param2 = node.param2})
		return true
	elseif node.name == "easyvend:depositor_on" then
                easyvend.sound_disable(pos)
		minetest.swap_node(pos, {name="easyvend:depositor", param2 = node.param2})
		return true
	else
		if playername ~= nil then
			easyvend.sound_error(playername)
		end
		return false
	end
end

easyvend.machine_enable = function(pos, node)
        if node.name == "easyvend:vendor" then
                easyvend.sound_setup(pos)
		minetest.swap_node(pos, {name="easyvend:vendor_on", param2 = node.param2})
		return true
	elseif node.name == "easyvend:depositor" then
                easyvend.sound_setup(pos)
		minetest.swap_node(pos, {name="easyvend:depositor_on", param2 = node.param2})
		return true
	else
		return false
	end
end

easyvend.machine_check = function(pos, node)
	local active = true
	local status = "Ready."

	local chest = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z})
	local meta = minetest.get_meta(pos)
	local number = meta:get_int("number")
	local cost = meta:get_int("cost")
	local inv = meta:get_inventory()
	local itemstack = inv:get_stack("item",1)
	local itemname=meta:get_string("itemname")
	local machine_owner = meta:get_string("owner")
	local check_wear = meta:get_int("wear") == 0
	local chestdef = registered_chests[chest.name]

	if chestdef then
		local chest_meta = minetest.get_meta({x=pos.x,y=pos.y-1,z=pos.z})
		local chest_inv = chest_meta:get_inventory()

		if ( chest_meta:get_string(chestdef.meta_owner) == machine_owner and chest_inv ~= nil ) then
			local buysell = easyvend.buysell(node.name)

			if not itemstack:is_empty() then

				local number_stack_max = itemstack:get_stack_max()
				local maxnumber = number_stack_max * slots_max

				local stack = {name=itemname, count=number, wear=0, metadata=""}
				local price = {name=currency, count=cost, wear=0, metadata=""}

				local chest_has, chest_free

				local coststacks = math.modf(cost / cost_stack_max)
				local costremainder = math.fmod(cost, cost_stack_max)
				local numberstacks = math.modf(number / number_stack_max)
				local numberremainder = math.fmod(number, number_stack_max)
				local numberfree = numberstacks
				local costfree = coststacks
				if numberremainder > 0 then numberfree = numberfree + 1 end
				if costremainder > 0 then costfree = costfree + 1 end

				if buysell == "sell" then
					chest_has = easyvend.check_and_get_items(chest_inv, chestdef.inv_list, stack, check_wear)
					chest_free = chest_inv:room_for_item(chestdef.inv_list, price)
			                if chest_has and chest_free then
						if cost <= cost_stack_max and number <= number_stack_max then
							active = true
						elseif easyvend.free_slots(chest_inv, chestdef.inv_list) < costfree then
							active = false
							status =  "No room in the chest's inventory!"
						end
					elseif not chest_has then
						active = false
						status = "The vending machine has insufficient materials!"
					elseif not chest_free then
						active = false
						status = "No room in the chest's inventory!"
					end
				elseif buysell == "buy" then
					chest_has = easyvend.check_and_get_items(chest_inv, chestdef.inv_list, price, check_wear)
					chest_free = chest_inv:room_for_item(chestdef.inv_list, stack)
			                if chest_has and chest_free then
						if cost <= cost_stack_max and number <= number_stack_max then
							active = true
						elseif easyvend.free_slots(chest_inv, chestdef.inv_list) < numberfree then
							active = false
							status =  "No room in the chest's inventory!"
						end
					elseif not chest_has then
						active = false
						status = "The depositing machine is out of money!"
					elseif not chest_free then
						active = false
						status = "No room in the chest's inventory!"
					end
				end
			else
				active = false
				status = "Awaiting configuration by owner."
			end
		else
			active = false
                        status = "Storage can't be accessed because it is owned by a different person!"
		end
	else
		active = false
                status = "No storage; machine needs a locked chest below it."
        end
	if meta:get_int("configmode") == 1 then
		active = false
		status = "Awaiting configuration by owner."
	end

	meta:set_string("status", status)

	if not itemstack:is_empty() then
		if itemname == nil or itemname == "" then
			itemname = itemstack:get_name()
		end
		meta:set_string("infotext", easyvend.make_infotext(node.name, machine_owner, cost, number, itemname))
	end
	itemname=itemstack:get_name()
	meta:set_string("itemname", itemname)

	local change
	if node.name == "easyvend:vendor" or node.name == "easyvend:depositor" then
		if active then change = easyvend.machine_enable(pos, node) end
	elseif node.name == "easyvend:vendor_on" or node.name == "easyvend:depositor_on" then
		if not active then change = easyvend.machine_disable(pos, node) end
	end
        easyvend.set_formspec(pos)
	return change
end

easyvend.on_receive_fields_config = function(pos, formname, fields, sender)
    local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)

	local number = tonumber(fields.number)
	local cost = tonumber(fields.cost)
    local inv_self = meta:get_inventory()

    if fields.config then
        meta:set_int("configmode", 1)
	easyvend.machine_check(pos, node)
	return
    end

    if not fields.save then
        return
    end

    local itemstack = inv_self:get_stack("item",1)
    local itemname=""

    local oldnumber = meta:get_int("number")
    local oldcost = meta:get_int("cost")
    local number_stack_max = itemstack:get_stack_max()
    local maxnumber = number_stack_max * slots_max
	
        if ( itemstack == nil or itemstack:is_empty() ) then
                meta:set_string("status", "Awaiting configuration by owner.")
		meta:set_string("message", "You must specify an item.")
                easyvend.sound_error(sender:get_player_name())
                easyvend.set_formspec(pos, sender)
                return
	elseif ( number == nil or number < 1 or number > maxnumber ) then
                if maxnumber > 1 then
			meta:set_string("message", string.format("Invalid item count; must be between 1 and %d!", maxnumber))
                else
			meta:set_string("message", "Invalid item count; must be exactly 1!")
                end
                meta:set_int("number", oldnumber)
                easyvend.sound_error(sender:get_player_name())
                easyvend.set_formspec(pos, sender)
                return
	elseif ( cost == nil or cost < 1 or cost > maxcost ) then
                if maxcost > 1 then
			meta:set_string("message", string.format("Invalid cost; must be between 1 and %d!", maxcost))
                else
			meta:set_string("message", "Invalid cost; must be exactly 1!")
                end
                meta:set_int("cost", oldcost)
                easyvend.sound_error(sender:get_player_name())
                easyvend.set_formspec(pos, sender)
                return
        end
        meta:set_int("number", number)
        meta:set_int("cost", cost)
        itemname=itemstack:get_name()
	meta:set_string("itemname", itemname)
        meta:set_int("configmode", 0)
    
        local change = easyvend.machine_check(pos, node)
	meta:set_string("message", "Configuration successful.")

	if not change then
		if (node.name == "easyvend:vendor_on" or node.name == "easyvend:depositor_on") then
			easyvend.sound_setup(pos)
			meta:set_string("status", "Ready.")
		else
			easyvend.sound_disable(pos)
		end
	end
        easyvend.machine_check(pos, node)
end

easyvend.make_infotext = function(nodename, owner, cost, number, itemstring)
	local iname = minetest.registered_items[itemstring].description
	if iname == nil then iname = itemstring end
	local d = ""
	local printitem, printcost
	if number == 1 then
		printitem = iname
	else
		printitem = string.format("%d×%s", number, iname)
	end
	if cost == 1 then
		printcost = currency_desc
	else
		printcost = string.format("%d×%s", cost, currency_desc)
	end
	if nodename == "easyvend:vendor" or nodename == "easyvend:vendor_on" then
		d = string.format("Vending machine (owned by %s)\nSelling: %s\nPrice: %s", owner, printitem, printcost)
	elseif nodename == "easyvend:depositor" or nodename == "easyvend:depositor_on" then
		d = string.format("Depositing machine (owned by %s)\nBuying: %s\nPayment: %s", owner, printitem, printcost)
	end
	return d
end

easyvend.on_receive_fields_buysell = function(pos, formname, fields, sender)
    local sendername = sender:get_player_name()
    local meta = minetest.get_meta(pos)

    if not fields.buysell then
        return
    end

	local node = minetest.get_node(pos)
    local number = meta:get_int("number")
    local cost = meta:get_int("cost")
    local itemname=meta:get_string("itemname")
    local item=meta:get_inventory():get_stack("item", 1)
    local check_wear = meta:get_int("wear") == 0 and minetest.registered_tools[itemname] ~= nil

    local buysell = easyvend.buysell(node.name)
	
        local number_stack_max = item:get_stack_max()
        local maxnumber = number_stack_max * slots_max
	if ( number == nil or number < 1 or number > maxnumber ) or
	( cost == nil or cost < 1 or cost > maxcost ) or
	( itemname == nil or itemname=="") then
		meta:set_string("status", "Invalid item count or price!")
	        easyvend.machine_disable(pos, node, sendername)
		return
	end

    
    local chest = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z})
    local chestdef = registered_chests[chest.name]
    if chestdef and sender and sender:is_player() then
        local chest_meta = minetest.get_meta({x=pos.x,y=pos.y-1,z=pos.z})
        local chest_inv = chest_meta:get_inventory()
        local player_inv = sender:get_inventory()
        if ( chest_meta:get_string(chestdef.meta_owner) == meta:get_string("owner") and chest_inv ~= nil and player_inv ~= nil ) then
            
            local stack = {name=itemname, count=number, wear=0, metadata=""} 
            local price = {name=currency, count=cost, wear=0, metadata=""}
            local chest_has, player_has, chest_free, player_free, chest_out, player_out
            local msg = ""
            if buysell == "sell" then
                chest_has, chest_out = easyvend.check_and_get_items(chest_inv, "main", stack, check_wear)
                player_has, player_out = easyvend.check_and_get_items(player_inv, "main", price, check_wear)
                chest_free = chest_inv:room_for_item("main", price)
                player_free = player_inv:room_for_item("main", stack)
                if chest_has and player_has and chest_free and player_free then
                   if cost <= cost_stack_max and number <= number_stack_max then
                       easyvend.machine_enable(pos, node)
                       player_inv:remove_item("main", price)
                       if check_wear then
                           chest_inv:set_stack("main", chest_out[1].id, "")
                           player_inv:add_item("main", chest_out[1].item)
                       else
                           stack = chest_inv:remove_item("main", stack)
                           player_inv:add_item("main", stack)
                       end
                       chest_inv:add_item("main", price)
                       meta:set_string("status", "Ready.")
                       meta:set_string("message", "Item bought.")
                       easyvend.sound_vend(pos)
                   else
                       -- Large item counts (multiple stacks)
                       local coststacks = math.modf(cost / cost_stack_max)
                       local costremainder = math.fmod(cost, cost_stack_max)
                       local numberstacks = math.modf(number / number_stack_max)
                       local numberremainder = math.fmod(number, number_stack_max)
                       local numberfree = numberstacks
                       local costfree = coststacks
                       if numberremainder > 0 then numberfree = numberfree + 1 end
                       if costremainder > 0 then costfree = costfree + 1 end
                       if easyvend.free_slots(player_inv, "main") < numberfree then
                           if numberfree > 1 then
                               msg = string.format("No room in your inventory (%d empty slots required)!", numberfree)
                           else
                               msg = "No room in your inventory!"
                           end
                           meta:set_string("message", msg)
                       elseif easyvend.free_slots(chest_inv, "main") < costfree then
                           meta:set_string("status", "No room in the chest's inventory!")
	                   easyvend.machine_disable(pos, node, sendername)
                       else
                           -- Remember items for transfer
                           local cheststacks = {}
                           easyvend.machine_enable(pos, node)
                           for i=1, coststacks do
                               price.count = cost_stack_max
                               player_inv:remove_item("main", price)
                           end
                           if costremainder > 0 then
                               price.count = costremainder
                               player_inv:remove_item("main", price)
                           end
                           if check_wear then
                               for o=1,#chest_out do
                                   chest_inv:set_stack("main", chest_out[o].id, "")
                               end
                           else
                               for i=1, numberstacks do
                                   stack.count = number_stack_max
                                   table.insert(cheststacks, chest_inv:remove_item("main", stack))
                               end
                           end
                           if numberremainder > 0 then
                               stack.count = numberremainder
                               table.insert(cheststacks, chest_inv:remove_item("main", stack))
                           end
                           for i=1, coststacks do
                               price.count = cost_stack_max
                               chest_inv:add_item("main", price)
                           end
                           if costremainder > 0 then
                               price.count = costremainder
                               chest_inv:add_item("main", price)
                           end
                           if check_wear then
                               for o=1,#chest_out do
                                   player_inv:add_item("main", chest_out[o].item)
                               end
                           else
                               for i=1,#cheststacks do
                                   player_inv:add_item("main", cheststacks[i])
                               end
                           end
                           meta:set_string("message", "Item bought.")
                           easyvend.sound_vend(pos)
                       end
                   end
                elseif chest_has and player_has then
                    if not player_free then
                        msg = "No room in your inventory!"
                        meta:set_string("message", msg)
                        easyvend.sound_error(sendername)
                    elseif not chest_free then
                        msg = "No room in the chest's inventory!"
                        meta:set_string("status", msg)
	                easyvend.machine_disable(pos, node, sendername)
                    end
                else
                    if not chest_has then
                        msg = "The vending machine has insufficient materials!"
                        meta:set_string("status", msg)
	                easyvend.machine_disable(pos, node, sendername)
                    elseif not player_has then
                        msg = "You can't afford this item!"
                        meta:set_string("message", msg)
                        easyvend.sound_error(sendername)
                    end
                end
            else
                chest_has, chest_out = easyvend.check_and_get_items(chest_inv, "main", price, check_wear)
                player_has, player_out = easyvend.check_and_get_items(player_inv, "main", stack, check_wear)
                chest_free = chest_inv:room_for_item("main", stack)
                player_free = player_inv:room_for_item("main", price)
                if chest_has and player_has and chest_free and player_free then
                   if cost <= cost_stack_max and number <= number_stack_max then
                       easyvend.machine_enable(pos, node)
                       if check_wear then
                           player_inv:set_stack("main", player_out[1].id, "")
                           chest_inv:add_item("main", player_out[1].item)
                       else
                           stack = player_inv:remove_item("main", stack)
                           chest_inv:add_item("main", stack)
                       end
                       chest_inv:remove_item("main", price)
                       player_inv:add_item("main", price)
                       meta:set_string("status", "Ready.")
                       meta:set_string("message", "Item sold.")
                       easyvend.sound_deposit(pos)
                   else
                       -- Large item counts (multiple stacks)
                       local coststacks = math.modf(cost / cost_stack_max)
                       local costremainder = math.fmod(cost, cost_stack_max)
                       local numberstacks = math.modf(number / number_stack_max)
                       local numberremainder = math.fmod(number, number_stack_max)
                       local numberfree = numberstacks
                       local costfree = coststacks
                       if numberremainder > 0 then numberfree = numberfree + 1 end
                       if costremainder > 0 then costfree = costfree + 1 end
                       if easyvend.free_slots(player_inv, "main") < costfree then
                           if costfree > 1 then
                               msg = string.format("No room in your inventory (%d empty slots required)!", costfree)
                           else
                               msg = "No room in your inventory!"
                           end
                           meta:set_string("status", msg)
                           easyvend.sound_error(sendername)
                       elseif easyvend.free_slots(chest_inv, "main") < numberfree then
	                   easyvend.machine_disable(pos, node, sendername)
                       else
                           easyvend.machine_enable(pos, node)
                           -- Remember removed items for transfer
                           local playerstacks = {}
                           for i=1, coststacks do
                               price.count = cost_stack_max
                               chest_inv:remove_item("main", price)
                           end
                           if costremainder > 0 then
                               price.count = costremainder
                               chest_inv:remove_item("main", price)
                           end
                           if check_wear then
                               for o=1,#player_out do
                                   player_inv:set_stack("main", player_out[o].id, "")
                               end
                           else
                               for i=1, numberstacks do
                                   stack.count = number_stack_max
                                   table.insert(playerstacks, player_inv:remove_item("main", stack))
                               end
                           end
                           if numberremainder > 0 then
                               stack.count = numberremainder
                               table.insert(playerstacks, player_inv:remove_item("main", stack))
                           end
                           for i=1, coststacks do
                               price.count = cost_stack_max
                               player_inv:add_item("main", price)
                           end
                           if costremainder > 0 then
                               price.count = costremainder
                               player_inv:add_item("main", price)
                           end
                           if check_wear then
                               for o=1,#player_out do
                                   chest_inv:add_item("main", player_out[o].item)
                               end
                           else
                               for i=1,#playerstacks do
                                   chest_inv:add_item("main", playerstacks[i])
                               end
                           end
                           meta:set_string("message", "Item sold.")
                           easyvend.sound_deposit(pos)
                       end
                    end
                elseif chest_has and player_has then
                    if not player_free then
                        msg = "No room in your inventory!"
                        meta:set_string("message", msg)
                        easyvend.sound_error(sendername)
                    elseif not chest_free then
                        msg = "No room in the chest's inventory!"
                        meta:set_string("status", msg)
	                easyvend.machine_disable(pos, node, sendername)
                    end
                else
                    if not player_has then
                        msg = "You have insufficient materials!"
                        meta:set_string("message", msg)
                        easyvend.sound_error(sendername)
                    elseif not chest_has then
                        msg = "The depositing machine is out of money!"
                        meta:set_string("status", msg)
	                easyvend.machine_disable(pos, node, sendername)
                    end
                end
            end
        else
            meta:set_string("status", "Storage can't be accessed because it is owned by a different person!")
	    easyvend.machine_disable(pos, node, sendername)
        end
    else
        if sender and sender:is_player() then
            meta:set_string("status", "No storage; machine needs a locked chest below it.")
	    easyvend.machine_disable(pos, node, sendername)
        end
    end

    easyvend.set_formspec(pos, sender)
    
end

easyvend.after_place_node = function(pos, placer)
    local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local player_name = placer:get_player_name()
    inv:set_size("item", 1)
    inv:set_size("gold", 1)
    
    inv:set_stack( "gold", 1, currency )

    local d = ""
    if node.name == "easyvend:vendor" then
        d = string.format("New vending machine (owned by %s)", player_name)
        meta:set_int("wear", 1)
    elseif node.name == "easyvend:depositor" then
        d = string.format("New depositing machine (owned by %s)", player_name)
        meta:set_int("wear", 0)
    end
    meta:set_string("infotext", d)
    local chest = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z})
    if registered_chests[chest.name] then
        meta:set_string("status", "Awaiting configuration by owner.")
    else
        meta:set_string("status", "No storage; machine needs a locked chest below it.")
    end
    meta:set_string("message", "Welcome! Please prepare the machine.")
    meta:set_int("number", 1)
    meta:set_int("cost", 1)
    meta:set_int("configmode", 1)
	meta:set_string("itemname", "")

	meta:set_string("owner", player_name or "")
    
    easyvend.set_formspec(pos, placer)
end

easyvend.can_dig = function(pos, player)
    local meta = minetest.get_meta(pos)
    local name = player:get_player_name()
    -- Owner can always dig shop
    if meta:get_string("owner") == name then
        return true
    end
    local chest = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z})
    local meta_chest = minetest.get_meta({x=pos.x,y=pos.y-1,z=pos.z});
    if registered_chests[chest.name] then
         if player and player:is_player() then
            local owner_chest = meta_chest:get_string(registered_chests[chest.name].meta_owner)
            if name == owner_chest then
                return true --chest owner can also dig shop
            end
         end
         return false
    else
        return true --if no chest, enyone can dig this shop
    end
end

easyvend.on_receive_fields = function(pos, formname, fields, sender)
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)
	local owner = meta:get_string("owner")
    
	if fields.config or fields.save or fields.usermode then
		if sender:get_player_name() == owner then
			easyvend.on_receive_fields_config(pos, formname, fields, sender)
		else
			meta:set_string("message", "Access denied.")
			easyvend.sound_error(sendername)
			easyvend.set_formspec(pos, sender)
			return
		end
	elseif fields.wear ~= nil then
		if sender:get_player_name() == owner then
			if fields.wear == "true" then
				if easyvend.buysell(node.name) == "buy" then
					meta:set_string("message", "Used tools are now accepted.")
				else
					meta:set_string("message", "Used tools are now for sale.")
				end
				meta:set_int("wear", 1)
			elseif fields.wear == "false" then
				if easyvend.buysell(node.name) == "buy" then
					meta:set_string("message", "Used tools are now rejected.")
				else
					meta:set_string("message", "Used tools won't be sold anymore.")
				end
				meta:set_int("wear", 0)
			end
			easyvend.set_formspec(pos, sender)
			return
		else
			meta:set_string("message", "Access denied.")
			easyvend.sound_error(sendername)
			easyvend.set_formspec(pos, sender)
			return
		end
	elseif fields.buysell then
		easyvend.on_receive_fields_buysell(pos, formname, fields, sender)
	end
end

easyvend.sound_error = function(playername) 
	minetest.sound_play("easyvend_error", {to_player = playername, gain = 0.25})
end

easyvend.sound_setup = function(pos)
	minetest.sound_play("easyvend_activate", {pos = pos, gain = 0.5, max_hear_distance = 12,})
end

easyvend.sound_disable = function(pos)
	minetest.sound_play("easyvend_disable", {pos = pos, gain = 0.9, max_hear_distance = 12,})
end

easyvend.sound_vend = function(pos) 
	minetest.sound_play("easyvend_vend", {pos = pos, gain = 0.4, max_hear_distance = 5,})
end

easyvend.sound_deposit = function(pos)
	minetest.sound_play("easyvend_deposit", {pos = pos, gain = 0.4, max_hear_distance = 5,})
end

easyvend.allow_metadata_inventory_put = function(pos, listname, index, stack, player)
    if listname=="item" then
        local meta = minetest.get_meta(pos);
        local owner = meta:get_string("owner")
        local name = player:get_player_name()
        if name == owner then
            local inv = meta:get_inventory()
            if stack==nil then
                inv:set_stack( "item", 1, nil )
            else
                inv:set_stack( "item", 1, stack:get_name() )
            end
        end
    end
	return 0
end

easyvend.allow_metadata_inventory_take = function(pos, listname, index, stack, player)
	return 0
end

easyvend.allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	return 0
end

minetest.register_abm({
	nodenames = {"easyvend:vendor", "easyvend:vendor_on", "easyvend:depositor", "easyvend:depositor_on"},
	interval = 5,
	chance = 1,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		easyvend.machine_check(pos, node)
	end
})
