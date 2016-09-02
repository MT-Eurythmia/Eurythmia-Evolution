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
local cost_stack_max = ItemStack(currency):get_stack_max()
local maxcost = cost_stack_max * slots_max

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
        if minetest.get_modpath("default") then
            bg = default.gui_bg .. default.gui_bg_img .. default.gui_slots
        end

        local numbertext, costtext
        local buysell = easyvend.buysell(node.name)
        if buysell == "sell" then
		numbertext = "Offered item"
		numbertooltip = "Number of items being sold for the specified price"
		costtext = "Price"
		costtooltip = "How much the user is asked to pay for the offered item"
		oktooltip = "Buy items / configure machine"
        elseif buysell == "buy" then
		numbertext = "Requested item"
		numbertooltip = "Number of items the user is asked to supply"
		costtext = "Payment"
		costtooltip = "How much will be given to the user in return"
		oktooltip = "Sell items / configure machine"
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

	meta:set_string("formspec", "size[8,7.3;]"
                .. bg
	.."label[3,-0.2;" .. minetest.formspec_escape(description) .. "]"

	.."image[7.5,0.2;0.5,1;" .. status_image .. "]"
	.."textarea[2.8,0.2;5.1,2;;Status: " .. minetest.formspec_escape(status) .. ";]"
	.."textarea[2.8,1.3;5.6,2;;Last message: " .. minetest.formspec_escape(message) .. ";]"

        .."list[current_name;item;0,0.5;1,1;]"
		.."label[0,0.05;"..numbertext.."]"
		.."field[1.3,0.8;1.5,1;number;;" .. number .. "]"
		.."tooltip[number;"..numbertooltip.."]"

        .."list[current_name;gold;0,1.8;1,1;]"
		.."label[0,1.35;"..costtext.."]"
		.."field[1.3,2.1;1.5,1;cost;;" .. cost .. "]"
		.."tooltip[cost;"..costtooltip.."]"

	.."button[3,2.7;2,0.5;save;OK]"
	.."tooltip[save;"..oktooltip.."]"
        .."list[current_player;main;0,3.5;8,4;]"
        .."listring[current_player;main]"
        .."listring[current_name;item]")
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

	if chest.name=="default:chest_locked" then
		local chest_meta = minetest.get_meta({x=pos.x,y=pos.y-1,z=pos.z})
		local chest_inv = chest_meta:get_inventory()

		if ( chest_meta:get_string("owner") == machine_owner and chest_inv ~= nil ) then
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
					chest_has = chest_inv:contains_item("main", stack)
					chest_free = chest_inv:room_for_item("main", price)
			                if chest_has and chest_free then
						if cost <= cost_stack_max and number <= number_stack_max then
							active = true
						elseif easyvend.free_slots(chest_inv, "main") < costfree then
							active = false
							status =  "No room in the chest's inventory!"
						end
					elseif not chest_has then
						active = false
						status = "The vending machine has insufficient materials!"
					elseif not chest_free then
						active = false
						status = "No room in the locked chest's inventory!"
					end
				elseif buysell == "buy" then
					chest_has = chest_inv:contains_item("main", price)
					chest_free = chest_inv:room_for_item("main", stack)
			                if chest_has and chest_free then
						if cost <= cost_stack_max and number <= number_stack_max then
							active = true
						elseif easyvend.free_slots(chest_inv, "main") < numberfree then
							active = false
							status =  "No room in the chest's inventory!"
						end
					elseif not chest_has then
						active = false
						status = "The depositing machine has insufficient money!"
					elseif not chest_free then
						active = false
						status = "No room in the locked chest's inventory!"
					end
				end
			else
				active = false
				status = "The machine has not been configured yet."
			end
		else
			active = false
                        status = "Storage can't be accessed because it is owned by a different person!"
		end
	else
		active = false
                status = "No storage; machine needs a locked chest below it."
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
        easyvend.set_formspec(pos, sender)
	return change
end

easyvend.on_receive_fields_owner = function(pos, formname, fields, sender)
    if not fields.save then
        return
    end

    local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)

	local number = tonumber(fields.number)
	local cost = tonumber(fields.cost)
    local inv_self = meta:get_inventory()

    local itemstack = inv_self:get_stack("item",1)
    local itemname=""

    local oldnumber = meta:get_int("number")
    local oldcost = meta:get_int("cost")
    local number_stack_max = itemstack:get_stack_max()
    local maxnumber = number_stack_max * slots_max
	
        if ( itemstack == nil or itemstack:is_empty() ) then
                meta:set_string("status", "The machine has not been configured yet.")
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
    
        easyvend.set_formspec(pos, sender)

        local change = easyvend.machine_check(pos, node)
	meta:set_string("message", "Reconfiguration successful.")

	if not change then
		if (node.name == "easyvend:vendor_on" or node.name == "easyvend:depositor_on") then
			easyvend.sound_setup(pos)
			meta:set_string("status", "Ready.")
		else
			easyvend.sound_disable(pos)
		end
	end
end

easyvend.make_infotext = function(nodename, owner, cost, number, itemstring)
	local iname = minetest.registered_items[itemstring].description
	if iname == nil then iname = itemstring end
	local d = ""
	if nodename == "easyvend:vendor" or nodename == "easyvend:vendor_on" then
		d = string.format("Vending machine selling %s at %d:%d (owned by %s)", iname, number, cost, owner)
	elseif nodename == "easyvend:depositor" or nodename == "easyvend:depositor_on" then
		d = string.format("Depositing machine buying %s at %d:%d (owned by %s)", iname, number, cost, owner)
	end
	return d
end

easyvend.on_receive_fields_customer = function(pos, formname, fields, sender)
    if not fields.save then
        return
    end

    local sendername = sender:get_player_name()
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
    local number = meta:get_int("number")
    local cost = meta:get_int("cost")
    local itemname=meta:get_string("itemname")
    local item=meta:get_inventory():get_stack("item", 1)

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
    if chest.name=="default:chest_locked" and sender and sender:is_player() then
        local chest_meta = minetest.get_meta({x=pos.x,y=pos.y-1,z=pos.z})
        local chest_inv = chest_meta:get_inventory()
        local player_inv = sender:get_inventory()
        if ( chest_meta:get_string("owner") == meta:get_string("owner") and chest_inv ~= nil and player_inv ~= nil ) then
            
            local stack = {name=itemname, count=number, wear=0, metadata=""} 
            local price = {name=currency, count=cost, wear=0, metadata=""}
            local chest_has, player_has, chest_free, player_free
            local msg = ""
            if buysell == "sell" then
                chest_has = chest_inv:contains_item("main", stack)
                player_has = player_inv:contains_item("main", price)
                chest_free = chest_inv:room_for_item("main", stack)
                player_free = player_inv:room_for_item("main", price)
                if chest_has and player_has and chest_free and player_free then
                   if cost <= cost_stack_max and number <= number_stack_max then
                       easyvend.machine_enable(pos, node)
                       player_inv:remove_item("main", price)
                       stack = chest_inv:remove_item("main", stack)
                       chest_inv:add_item("main", price)
                       player_inv:add_item("main", stack)
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
                           easyvend.machine_enable(pos, node)
                           for i=1, coststacks do
                               price.count = cost_stack_max
                               player_inv:remove_item("main", price)
                           end
                           if costremainder > 0 then
                               price.count = costremainder
                               player_inv:remove_item("main", price)
                           end
                           for i=1, numberstacks do
                               stack.count = number_stack_max
                               chest_inv:remove_item("main", stack)
                           end
                           if numberremainder > 0 then
                               stack.count = numberremainder
                               chest_inv:remove_item("main", stack)
                           end
                           for i=1, coststacks do
                               price.count = cost_stack_max
                               chest_inv:add_item("main", price)
                           end
                           if costremainder > 0 then
                               price.count = costremainder
                               chest_inv:add_item("main", price)
                           end
                           for i=1, numberstacks do
                               stack.count = number_stack_max
                               player_inv:add_item("main", stack)
                           end
                           if numberremainder > 0 then
                               stack.count = numberremainder
                               player_inv:add_item("main", stack)
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
                chest_has = chest_inv:contains_item("main", price)
                player_has = player_inv:contains_item("main", stack)
                chest_free = chest_inv:room_for_item("main", price)
                player_free = player_inv:room_for_item("main", stack)
                if chest_has and player_has and chest_free and player_free then
                   if cost <= cost_stack_max and number <= number_stack_max then
                       easyvend.machine_enable(pos, node)
                       stack = player_inv:remove_item("main", stack)
                       chest_inv:remove_item("main", price)
                       chest_inv:add_item("main", stack)
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
                           for i=1, coststacks do
                               price.count = cost_stack_max
                               chest_inv:remove_item("main", price)
                           end
                           if costremainder > 0 then
                               price.count = costremainder
                               chest_inv:remove_item("main", price)
                           end
                           for i=1, numberstacks do
                               stack.count = number_stack_max
                               player_inv:remove_item("main", stack)
                           end
                           if numberremainder > 0 then
                               stack.count = numberremainder
                               player_inv:remove_item("main", stack)
                           end
                           for i=1, coststacks do
                               price.count = cost_stack_max
                               player_inv:add_item("main", price)
                           end
                           if costremainder > 0 then
                               price.count = costremainder
                               player_inv:add_item("main", price)
                           end
                           for i=1, numberstacks do
                               stack.count = number_stack_max
                               chest_inv:add_item("main", stack)
                           end
                           if numberremainder > 0 then
                               stack.count = numberremainder
                               chest_inv:add_item("main", stack)
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
    elseif node.name == "easyvend:depositor" then
        d = string.format("New depositing machine (owned by %s)", player_name)
    end
    meta:set_string("infotext", d)
    local chest = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z})
    if chest.name=="default:chest_locked" then
        meta:set_string("status", "The machine has not been configured yet.")
    else
        meta:set_string("status", "No storage; machine needs a locked chest below it.")
    end
    meta:set_string("message", "Welcome! Please prepare the machine.")
    meta:set_int("number", 1)
    meta:set_int("cost", 1)
	meta:set_string("itemname", "")

	meta:set_string("owner", player_name or "")
    
    easyvend.set_formspec(pos, placer)
end

easyvend.can_dig = function(pos, player)
    local chest = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z})
    local meta_chest = minetest.get_meta({x=pos.x,y=pos.y-1,z=pos.z});
    if chest.name=="default:chest_locked" then
         if player and player:is_player() then
            local owner_chest = meta_chest:get_string("owner")
            local name = player:get_player_name()
            if name == owner_chest then
                return true --chest owner can dig shop
            end
         end
         return false
    else
        return true --if no chest, enyone can dig this shop
    end
end

easyvend.on_receive_fields = function(pos, formname, fields, sender)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
    
	if sender:get_player_name() == owner then
		easyvend.on_receive_fields_owner(pos, formname, fields, sender)
    else
        easyvend.on_receive_fields_customer(pos, formname, fields, sender)
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
