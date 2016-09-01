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

local currency = "default:gold_ingot"
local maxcost = ItemStack(currency):get_stack_max()

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

	meta:set_string("formspec", "size[8,7;]"
                .. bg
		.."label[0,0;" .. description .. "]"

        .."list[current_name;item;0,1;1,1;]"
		.."field[1.3,1.3;1,1;number;Count:;" .. number .. "]"

        .."list[current_name;gold;0,2;1,1;]"
		.."field[1.3,2.3;1,1;cost;Price:;" .. cost .. "]"

		.."button[3,2;2,0.5;save;OK]"
        .."list[current_player;main;0,3;8,4;]")
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
    local maxnumber = itemstack:get_stack_max()
	
        if ( itemstack == nil or itemstack:is_empty() ) then
                minetest.chat_send_player(sender:get_player_name(), "You must specify an item!")
                easyvend.sound_error(sender:get_player_name())
                return
	elseif ( number == nil or number < 1 or number > maxnumber ) then
                if maxnumber > 1 then
                         minetest.chat_send_player(sender:get_player_name(), string.format("Invalid item count; must be between 1 and %d!", maxnumber) )
                else
                         minetest.chat_send_player(sender:get_player_name(), "Invalid item count; must be exactly 1!")
                end
                easyvend.sound_error(sender:get_player_name())
                meta:set_int("number", oldnumber)
                easyvend.set_formspec(pos, sender)
                return
	elseif ( cost == nil or cost < 1 or cost > maxcost ) then
                if maxcost > 1 then
                         minetest.chat_send_player(sender:get_player_name(), string.format("Invalid cost; must be between 1 and %d!", maxcost) )
                else
                         minetest.chat_send_player(sender:get_player_name(), "Invalid cost; must be exactly 1!")
                end
                easyvend.sound_error(sender:get_player_name())
                meta:set_int("cost", oldcost)
                easyvend.set_formspec(pos, sender)
                return
        end
        meta:set_int("number", number)
        meta:set_int("cost", cost)
        itemname=itemstack:get_name()
	meta:set_string("itemname", itemname)
    
        easyvend.sound_setup(pos)
        easyvend.set_formspec(pos, sender)

        local iname = minetest.registered_items[itemname].description
        if iname == nil then iname = itemname end
        local d = ""
        local owner = meta:get_string("owner")
        if node.name == "easyvend:vendor" then
            d = string.format("Vending machine selling %s %d:%d (owned by %s)", iname, number, cost, owner)
        elseif node.name == "easyvend:depositor" then
            d = string.format("Depositing machine buying %s %d:%d (owned by %s)", iname, number, cost, owner)
        end
        meta:set_string("infotext", d)
end

easyvend.on_receive_fields_customer = function(pos, formname, fields, sender)
    if not fields.save then
        return
    end

	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
    local number = meta:get_int("number")
    local cost = meta:get_int("cost")
    local itemname=meta:get_string("itemname")
    local buysell =  "sell"
	if ( node.name == "easyvend:depositor" ) then	
		buysell = "buy"
	end
	
        local maxnumber = ItemStack(itemname):get_stack_max()
	if ( number == nil or number < 1 or number > maxnumber ) or
	( cost == nil or cost < 1 or cost > maxcost ) or
	( itemname == nil or itemname=="") then
		minetest.chat_send_player(sender:get_player_name(), "Machine has not been configured properly!")
		easyvend.sound_error(sender:get_player_name())
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
            if buysell == "sell" then
                chest_has = chest_inv:contains_item("main", stack)
                player_has = player_inv:contains_item("main", price)
                chest_free = chest_inv:room_for_item("main", stack)
                player_free = chest_inv:room_for_item("main", price)
                if chest_has and player_has and chest_free and player_free then
                   player_inv:remove_item("main", price)
                   stack = chest_inv:remove_item("main", stack)
                   chest_inv:add_item("main", price)
                   player_inv:add_item("main", stack)
                   minetest.chat_send_player(sender:get_player_name(), "You bought item.")
                   easyvend.sound_vend(pos)
                elseif chest_has and player_has then
                    local msg
                    if not player_free and not chest_free then
                        msg = "No room in neither your nor the chest's inventory!"
                    elseif not player_free then
                        msg = "No room in your inventory!"
                    elseif not chest_free then
                        msg = "No room in the chest's inventory!"
                    end
                    minetest.chat_send_player(sender:get_player_name(), msg)
                    easyvend.sound_error(sender:get_player_name())
                else
                    if not chest_has and not player_has then
                        msg = "You can't afford this item, and the vending machine has insufficient materials!"
                    elseif not chest_has then
                        msg = "The vending machine has insufficient materials!"
                    elseif not player_has then
                        msg = "You can't afford this item!"
                    end
                    minetest.chat_send_player(sender:get_player_name(), msg)
                    easyvend.sound_error(sender:get_player_name())
                end
            else
                chest_has = chest_inv:contains_item("main", price)
                player_has = player_inv:contains_item("main", stack)
                chest_free = chest_inv:room_for_item("main", price)
                player_free = chest_inv:room_for_item("main", stack)
                if chest_has and player_has and chest_free and player_free then
                   stack = player_inv:remove_item("main", stack)
                   chest_inv:remove_item("main", price)
                   chest_inv:add_item("main", stack)
                   player_inv:add_item("main", price)
                   minetest.chat_send_player(sender:get_player_name(), "You sold item.")
                   easyvend.sound_deposit(pos)
                elseif chest_has and player_has then
                    local msg
                    if not player_free and not chest_free then
                        msg = "No room in neither your nor the chest's inventory!"
                    elseif not player_free then
                        msg = "No room in your inventory!"
                    elseif not chest_free then
                        msg = "No room in the chest's inventory!"
                    end
                    minetest.chat_send_player(sender:get_player_name(), msg)
                    easyvend.sound_error(sender:get_player_name())
                else
                    if not chest_has and not player_has then
                        msg = "You have insufficient materials, and the depositing machine can't afford to pay you!"
                    elseif not chest_has then
                        msg = "The depositing machine can't afford to pay you!"
                    elseif not player_has then
                        msg = "You have insufficient materials!"
                    end
                    minetest.chat_send_player(sender:get_player_name(), msg)
                    easyvend.sound_error(sender:get_player_name())
                end
            end
        else
            minetest.chat_send_player(sender:get_player_name(), "The machine's storage can't be accessed because it is owned by a different person!")
            easyvend.sound_error(sender:get_player_name())
        end
    else
        if sender and sender:is_player() then
            minetest.chat_send_player(sender:get_player_name(), "Machine has no storage; it requires a locked chest below it to function.")
            easyvend.sound_error(sender:get_player_name())
        end
    end

    
    --do transaction here
    
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
	minetest.sound_play("easyvend_error", {to_player = playername, gain = 1.0})
end

easyvend.sound_setup= function(pos)
	minetest.sound_play("easyvend_activate", {pos = pos, gain = 1.0, max_hear_distance = 10,})
end

easyvend.sound_vend = function(pos) 
	minetest.sound_play("easyvend_vend", {pos = pos, gain = 1.0, max_hear_distance = 5,})
end

easyvend.sound_deposit = function(pos)
	minetest.sound_play("easyvend_deposit", {pos = pos, gain = 1.0, max_hear_distance = 5,})
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
