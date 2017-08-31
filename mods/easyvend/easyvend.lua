-- TODO: Improve mod compability
local slots_max = 31

local traversable_node_types = {
	["easyvend:vendor"] = true,
	["easyvend:depositor"] = true,
	["easyvend:vendor_on"] = true,
	["easyvend:depositor_on"] = true,
}
local registered_chests = {}
local cost_stack_max = minetest.registered_items[easyvend.currency].stack_max
local maxcost = cost_stack_max * slots_max

local joketimer_start = 3

-- Allow for other mods to register custom chests
easyvend.register_chest = function(node_name, inv_list, meta_owner)
	registered_chests[node_name] = { inv_list = inv_list, meta_owner = meta_owner }
	traversable_node_types[node_name] = true
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

easyvend.is_active = function(nodename)
	if ( nodename == "easyvend:depositor_on" or nodename == "easyvend:vendor_on" ) then
		return true
	elseif ( nodename == "easyvend:depositor" or nodename == "easyvend:vendor" ) then
		return false
	else
		return nil
	end
end

easyvend.set_formspec = function(pos, player)
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)

	local description = minetest.registered_nodes[node.name].description;
	local number = meta:get_int("number")
	local cost = meta:get_int("cost")
	local itemname = meta:get_string("itemname")
		local bg = ""
	local configmode = meta:get_int("configmode") == 1
		if minetest.get_modpath("default") then
			bg = default.gui_bg .. default.gui_bg_img .. default.gui_slots
		end

		local numbertext, costtext, buysellbuttontext
	local itemcounttooltip = "Item count (append “s” to multiply with maximum stack size)"
		local buysell = easyvend.buysell(node.name)
		if buysell == "sell" then
		numbertext = "Offered item"
		costtext = "Price"
		buysellbuttontext = "Buy"
		elseif buysell == "buy" then
		numbertext = "Requested item"
		costtext = "Payment"
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

	-- TODO: Expose number of items in stock

	local formspec = "size[8,7.3;]"
		.. bg
	.."label[3,-0.2;" .. minetest.formspec_escape(description) .. "]"

	.."image[7.5,0.2;0.5,1;" .. status_image .. "]"
	.."textarea[2.8,0.2;5.1,2;;Status: " .. minetest.formspec_escape(status) .. ";]"
	.."textarea[2.8,1.3;5.6,2;;Message: " .. minetest.formspec_escape(message) .. ";]"

		.."label[0,-0.15;"..numbertext.."]"
		.."label[0,1.2;"..costtext.."]"
		.."list[current_player;main;0,3.5;8,4;]"
	if minetest.get_modpath("doc") and minetest.get_modpath("doc_items") then
		if (doc.VERSION.MAJOR >= 1) or (doc.VERSION.MAJOR == 0 and doc.VERSION.MINOR >= 8) then
			formspec = formspec .. "image_button[7.25,2;0.75,0.75;doc_button_icon_lores.png;doc;]" ..
			"tooltip[doc;Help]"
		end
	end

	if configmode then
		local wear = "false"
		if meta:get_int("wear") == 1 then wear = "true" end
		formspec = formspec
				.."item_image_button[0,1.65;1,1;"..easyvend.currency..";easyvend.currency_image;]"
				.."list[current_name;item;0,0.35;1,1;]"
				.."listring[current_player;main]"
				.."listring[current_name;item]"
		.."field[1.3,0.65;1.5,1;number;;" .. number .. "]"
		.."tooltip[number;"..itemcounttooltip.."]"
		.."field[1.3,1.95;1.5,1;cost;;" .. cost .. "]"
		.."tooltip[cost;"..itemcounttooltip.."]"
		.."button[6,2.8;2,0.5;save;Confirm]"
		.."tooltip[save;Confirm configuration and activate machine (only for owner)]"
		local weartext, weartooltip
		if buysell == "buy" then
			weartext = "Buy worn tools"
			weartooltip = "If disabled, only tools in perfect condition will be bought from sellers (only settable by owner)"
		else
			weartext = "Sell worn tools"
			weartooltip = "If disabled, only tools in perfect condition will be sold (only settable by owner)"
		end
		if minetest.registered_tools[itemname] ~= nil then
			formspec = formspec .."checkbox[2,2.4;wear;"..minetest.formspec_escape(weartext)..";"..wear.."]"
			.."tooltip[wear;"..minetest.formspec_escape(weartooltip).."]"
		end
	else
		formspec = formspec
				.."item_image_button[0,1.65;1,1;"..easyvend.currency..";easyvend.currency_image;]"
				.."item_image_button[0,0.35;1,1;"..itemname..";item_image;]"
		.."label[1,1.85;×" .. cost .. "]"
		.."label[1,0.55;×" .. number .. "]"
		.."button[6,2.8;2,0.5;config;Configure]"
		if buysell == "sell" then
			formspec = formspec .. "tooltip[config;Configure offered items and price (only for owner)]"
		else
			formspec = formspec .. "tooltip[config;Configure requested items and payment (only for owner)]"
		end
		formspec = formspec .."button[0,2.8;2,0.5;buysell;"..buysellbuttontext.."]"
		if minetest.registered_tools[itemname] ~= nil then
			local weartext
			if meta:get_int("wear") == 0 then
				if buysell == "buy" then
					weartext = "Only intact tools are bought."
				else
					weartext = "Only intact tools are sold."
				end
			else
				if buysell == "sell" then
					weartext = "Warning: Might sell worn tools."
				else
					weartext = "Worn tools are bought, too."
				end
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

	local meta = minetest.get_meta(pos)

	local machine_owner = meta:get_string("owner")
	local number = meta:get_int("number")
	local cost = meta:get_int("cost")
	local itemname = meta:get_string("itemname")
	local check_wear = meta:get_int("wear") == 0
	local inv = meta:get_inventory()
	local itemstack = inv:get_stack("item",1)
	local buysell = easyvend.buysell(node.name)

	local chest_pos_remove, chest_error_remove, chest_pos_add, chest_error_add
	if buysell == "sell" then
		chest_pos_remove, chest_error_remove = easyvend.find_connected_chest(machine_owner, pos, itemname, check_wear, number, true)
			chest_pos_add, chest_error_add = easyvend.find_connected_chest(machine_owner, pos, easyvend.currency, check_wear, cost, false)
	else
		chest_pos_remove, chest_error_remove = easyvend.find_connected_chest(machine_owner, pos, easyvend.currency, check_wear, cost, true)
			chest_pos_add, chest_error_add = easyvend.find_connected_chest(machine_owner, pos, itemname, check_wear, number, false)
	end
	if chest_pos_remove and chest_pos_add then
		local rchest, rchestdef, rchest_meta, rchest_inv
		rchest = minetest.get_node(chest_pos_remove)
		rchestdef = registered_chests[rchest.name]
		rchest_meta = minetest.get_meta(chest_pos_remove)
		rchest_inv = rchest_meta:get_inventory()

		local checkstack, checkitem
		if buysell == "buy" then
			checkitem = easyvend.currency
		else
			checkitem = itemname
		end
		local stock = 0
		-- Count stock
		-- FIXME: Ignore tools with bad wear level
		for i=1,rchest_inv:get_size(rchestdef.inv_list) do
			checkstack = rchest_inv:get_stack(rchestdef.inv_list, i)
			if checkstack:get_name() == checkitem then
				stock = stock + checkstack:get_count()
			end
		end
		meta:set_int("stock", stock)

		if not itemstack:is_empty() then
			local number_stack_max = itemstack:get_stack_max()
			local maxnumber = number_stack_max * slots_max
			if not(number >= 1 and number <= maxnumber and cost >= 1 and cost <= maxcost) then
				active = false
				if buysell == "sell" then
					status = "Invalid item count or price."
				else
					status = "Invalid item count or payment."
				end
			end
		else
			active = false
			status = "Awaiting configuration by owner."
		end
	else
		active = false
		meta:set_int("stock", 0)
		if chest_error_remove == "no_chest" and chest_error_add == "no_chest" then
			status = "No storage; machine needs to be connected with a locked chest."
		elseif chest_error_remove == "not_owned" or chest_error_add == "not_owned" then
			status = "Storage can’t be accessed because it is owned by a different person!"
		elseif chest_error_remove == "no_stock" then
			if buysell == "sell" then
				status = "The vending machine has insufficient materials!"
			else
				status = "The depositing machine is out of money!"
			end
		elseif chest_error_add == "no_space" then
			status = "No room in the machine’s storage!"
		else
			status = "Unknown error!"
		end
	end
	if meta:get_int("configmode") == 1 then
		active = false
		status = "Awaiting configuration by owner."
	end

	if itemname == easyvend.currency and number == cost and active then
		local jt = meta:get_int("joketimer")
		if jt > 0 then
			jt = jt - 1
		end
		if jt == 0 then
			if buysell == "sell" then
				meta:set_string("message", "Item bought.")
			else
				meta:set_string("message", "Item sold.")
			end
			jt = -1
		end
		meta:set_int("joketimer", jt)
	end
	meta:set_string("status", status)

	meta:set_string("infotext", easyvend.make_infotext(node.name, machine_owner, cost, number, itemname))
	itemname=itemstack:get_name()
	meta:set_string("itemname", itemname)

	if minetest.get_modpath("awards") and buysell == "sell" then
		if minetest.get_player_by_name(machine_owner) then
			local earnings = meta:get_int("earnings")
			if earnings >= 1 then
				awards.unlock(machine_owner, "easyvend_seller")
			end
			if earnings >= easyvend.powerseller then
				awards.unlock(machine_owner, "easyvend_powerseller")
			end
		end
	end

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
	local inv_self = meta:get_inventory()
	local itemstack = inv_self:get_stack("item",1)
	local buysell = easyvend.buysell(node.name)
 
	if fields.config then
		meta:set_int("configmode", 1)
		local was_active = easyvend.is_active(node.name)
		if was_active then
			meta:set_string("message", "Configuration mode activated; machine disabled.")
		else
			meta:set_string("message", "Configuration mode activated.")
		end
		easyvend.machine_check(pos, node)
		return
	end

	if not fields.save then
		return
	end

	local number = fields.number
	local cost = fields.cost

	--[[ Convenience function:
	When appending “s” or “S” to the number, it is multiplied
	by the maximum stack size.
	TODO: Expose this in user documentation ]]
	local number_stack_max = itemstack:get_stack_max()
	local ss = string.sub(number, #number, #number)
	if ss == "s" or ss == "S" then
		local n = tonumber(string.sub(number, 1, #number-1))
		if string.len(number) == 1 then n = 1 end
		if n ~= nil then
			number = n * number_stack_max
		end
	end
	ss = string.sub(cost, #cost, #cost)
	if ss == "s" or ss == "S" then
		local n = tonumber(string.sub(cost, 1, #cost-1))
		if string.len(cost) == 1 then n = 1 end
		if n ~= nil then
			cost = n * cost_stack_max
		end
	end
	number = tonumber(number)
	cost = tonumber(cost)

	local itemname=""

	local oldnumber = meta:get_int("number")
	local oldcost = meta:get_int("cost")
	local maxnumber = number_stack_max * slots_max
	
	if ( itemstack == nil or itemstack:is_empty() ) then
		meta:set_string("status", "Awaiting configuration by owner.")
		meta:set_string("message", "No item specified.")
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

	if itemname == easyvend.currency and number == cost and cost <= cost_stack_max then
		meta:set_string("message", "Configuration successful. I am feeling funny.")
		meta:set_int("joketimer", joketimer_start)
		meta:set_int("joke_id", easyvend.assign_joke(buysell))
	else
		meta:set_string("message", "Configuration successful.")
	end

	local change = easyvend.machine_check(pos, node)

	if not change then
		if (node.name == "easyvend:vendor_on" or node.name == "easyvend:depositor_on") then
			easyvend.sound_setup(pos)
		else
			easyvend.sound_disable(pos)
		end
	end
end

easyvend.make_infotext = function(nodename, owner, cost, number, itemstring)
	local d = ""
	if itemstring == nil or itemstring == "" or number == 0 or cost == 0 then
		if easyvend.buysell(nodename) == "sell" then
			d = string.format("Inactive vending machine (owned by %s)", owner)
		else
			d = string.format("Inactive depositing machine (owned by %s)", owner)
		end
		return d
	end
	local iname
	if minetest.registered_items[itemstring] then
		iname = minetest.registered_items[itemstring].description
	else
		iname = string.format("Unknown Item (%s)", itemstring)
	end
	if iname == nil then iname = itemstring end
	local printitem, printcost
	if number == 1 then
		printitem = iname
	else
		printitem = string.format("%d×%s", number, iname)
	end
	if cost == 1 then
		printcost = easyvend.currency_desc
	else
		printcost = string.format("%d×%s", cost, easyvend.currency_desc)
	end
	if nodename == "easyvend:vendor_on" then
		d = string.format("Vending machine (owned by %s)\nSelling: %s\nPrice: %s", owner, printitem, printcost)
	elseif nodename == "easyvend:vendor" then
		d = string.format("Inactive vending machine (owned by %s)\nSelling: %s\nPrice: %s", owner, printitem, printcost)
	elseif nodename == "easyvend:depositor_on" then
		d = string.format("Depositing machine (owned by %s)\nBuying: %s\nPayment: %s", owner, printitem, printcost)
	elseif nodename == "easyvend:depositor" then
		d = string.format("Inactive depositing machine (owned by %s)\nBuying: %s\nPayment: %s", owner, printitem, printcost)
	end
	return d
end

if minetest.get_modpath("awards") then
	awards.register_achievement("easyvend_seller",{
		title = "First Sale",
		description = "Sell something with a vending machine.",
		icon = "easyvend_vendor_front_on.png^awards_level1.png",
	})
	local desc_powerseller
	if easyvend.currency == "default:gold_ingot" then
		desc_powerseller = string.format("Earn %d gold ingots by selling goods with a single vending machine.", easyvend.powerseller)
	else
		desc_powerseller = string.format("Earn %d currency items by selling goods with a single vending machine.", easyvend.powerseller)
	end
	awards.register_achievement("easyvend_powerseller",{
		title = "Power Seller",
		description = desc_powerseller,
		icon = "easyvend_vendor_front_on.png^awards_level2.png",
	})
end

easyvend.check_earnings = function(buyername, nodemeta)
	local owner = nodemeta:get_string("owner")
	if buyername ~= owner then
		local cost = nodemeta:get_int("cost")
		local itemname = nodemeta:get_string("itemname")
		-- First sell
		if minetest.get_modpath("awards") and minetest.get_player_by_name(owner) ~= nil then
			awards.unlock(owner, "easyvend_seller")
		end
		if itemname ~= easyvend.currency then
			local newearnings = nodemeta:get_int("earnings") + cost
			if newearnings >= easyvend.powerseller and minetest.get_modpath("awards") then
				if minetest.get_player_by_name(owner) ~= nil then
					awards.unlock(owner, "easyvend_powerseller")
				end
			end
			nodemeta:set_int("earnings", newearnings)
		end
	end
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
	local machine_owner = meta:get_string("owner")

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

	local chest_pos_remove, chest_error_remove, chest_pos_add, chest_error_add
	if buysell == "sell" then
		chest_pos_remove, chest_error_remove = easyvend.find_connected_chest(machine_owner, pos, itemname, check_wear, number, true)
		chest_pos_add, chest_error_add = easyvend.find_connected_chest(machine_owner, pos, easyvend.currency, check_wear, cost, false)
	else
		chest_pos_remove, chest_error_remove = easyvend.find_connected_chest(machine_owner, pos, easyvend.currency, check_wear, cost, true)
		chest_pos_add, chest_error_add = easyvend.find_connected_chest(machine_owner, pos, itemname, check_wear, number, false)
	end

	if chest_pos_remove ~= nil and chest_pos_add ~= nil and sender and sender:is_player() then
		local rchest = minetest.get_node(chest_pos_remove)
		local rchestdef = registered_chests[rchest.name]
		local rchest_meta = minetest.get_meta(chest_pos_remove)
		local rchest_inv = rchest_meta:get_inventory()
		local achest = minetest.get_node(chest_pos_add)
		local achestdef = registered_chests[achest.name]
		local achest_meta = minetest.get_meta(chest_pos_add)
		local achest_inv = achest_meta:get_inventory()

		local player_inv = sender:get_inventory()

		local stack = {name=itemname, count=number, wear=0, metadata=""}
		local price = {name=easyvend.currency, count=cost, wear=0, metadata=""}
		local chest_has, player_has, chest_free, player_free, chest_out, player_out
		local msg = ""
		if buysell == "sell" then
			chest_has, chest_out = easyvend.check_and_get_items(rchest_inv, rchestdef.inv_list, stack, check_wear)
			player_has, player_out = easyvend.check_and_get_items(player_inv, "main", price, check_wear)
			chest_free = achest_inv:room_for_item(achestdef.inv_list, price)
			player_free = player_inv:room_for_item("main", stack)
			if chest_has and player_has and chest_free and player_free then
				if cost <= cost_stack_max and number <= number_stack_max then
					easyvend.machine_enable(pos, node)
					player_inv:remove_item("main", price)
					if check_wear then
						rchest_inv:set_stack(rchestdef.inv_list, chest_out[1].id, "")
						player_inv:add_item("main", chest_out[1].item)
					else
						stack = rchest_inv:remove_item(rchestdef.inv_list, stack)
						player_inv:add_item("main", stack)
					end
					achest_inv:add_item(achestdef.inv_list, price)
					if itemname == easyvend.currency and number == cost and cost <= cost_stack_max then
						meta:set_string("message", easyvend.get_joke(buysell, meta:get_int("joke_id")))
						meta:set_int("joketimer", joketimer_start)
					else
						meta:set_string("message", "Item bought.")
					end
					easyvend.check_earnings(sendername, meta)
					easyvend.sound_vend(pos)
					easyvend.machine_check(pos, node)
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
					if not player_free and easyvend.free_slots(player_inv, "main") < numberfree then
						if numberfree > 1 then
							msg = string.format("No room in your inventory (%d empty slots required)!", numberfree)
						else
							msg = "No room in your inventory!"
						end
						meta:set_string("message", msg)
					elseif not chest_free and easyvend.free_slots(achest_inv, achestdef.inv_list) < costfree then
						meta:set_string("status", "No room in the machine’s storage!")
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
								rchest_inv:set_stack(rchestdef.inv_list, chest_out[o].id, "")
							end
						else
							for i=1, numberstacks do
								stack.count = number_stack_max
								table.insert(cheststacks, rchest_inv:remove_item(rchestdef.inv_list, stack))
							end
						end
						if numberremainder > 0 then
							stack.count = numberremainder
							table.insert(cheststacks, rchest_inv:remove_item(rchestdef.inv_list, stack))
						end
						for i=1, coststacks do
							price.count = cost_stack_max
							achest_inv:add_item(achestdef.inv_list, price)
						end
						if costremainder > 0 then
							price.count = costremainder
							achest_inv:add_item(achestdef.inv_list, price)
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
						easyvend.check_earnings(sendername, meta)
						easyvend.sound_vend(pos)
						easyvend.machine_check(pos, node)
					end
				end
			elseif chest_has and player_has then
				if not player_free then
					msg = "No room in your inventory!"
					meta:set_string("message", msg)
					easyvend.sound_error(sendername)
				elseif not chest_free then
					msg = "No room in the machine’s storage!"
					meta:set_string("status", msg)
					easyvend.machine_disable(pos, node, sendername)
				end
			else
				if not chest_has then
					msg = "The vending machine has insufficient materials!"
					meta:set_string("status", msg)
					easyvend.machine_disable(pos, node, sendername)
				elseif not player_has then
					msg = "You can’t afford this item!"
					meta:set_string("message", msg)
					easyvend.sound_error(sendername)
				end
			end
		else
			chest_has, chest_out = easyvend.check_and_get_items(rchest_inv, rchestdef.inv_list, price, check_wear)
			player_has, player_out = easyvend.check_and_get_items(player_inv, "main", stack, check_wear)
			chest_free = achest_inv:room_for_item(achestdef.inv_list, stack)
			player_free = player_inv:room_for_item("main", price)
			if chest_has and player_has and chest_free and player_free then
				if cost <= cost_stack_max and number <= number_stack_max then
					easyvend.machine_enable(pos, node)
					if check_wear then
						player_inv:set_stack("main", player_out[1].id, "")
						achest_inv:add_item(achestdef.inv_list, player_out[1].item)
					else
						stack = player_inv:remove_item("main", stack)
						achest_inv:add_item(achestdef.inv_list, stack)
					end
					rchest_inv:remove_item(rchestdef.inv_list, price)
					player_inv:add_item("main", price)
					meta:set_string("status", "Ready.")
					if itemname == easyvend.currency and number == cost and cost <= cost_stack_max then
						meta:set_string("message", easyvend.get_joke(buysell, meta:get_int("joke_id")))
						meta:set_int("joketimer", joketimer_start)
					else
						meta:set_string("message", "Item sold.")
					end
					easyvend.sound_deposit(pos)
					easyvend.machine_check(pos, node)
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
					if not player_free and easyvend.free_slots(player_inv, "main") < costfree then
						if costfree > 1 then
							msg = string.format("No room in your inventory (%d empty slots required)!", costfree)
						else
							msg = "No room in your inventory!"
						end
						meta:set_string("message", msg)
						easyvend.sound_error(sendername)
					elseif not chest_free and easyvend.free_slots(achest_inv, achestdef.inv_list) < numberfree then
						meta:set_string("status", "No room in the machine’s storage!")
						easyvend.machine_disable(pos, node, sendername)
					else
						easyvend.machine_enable(pos, node)
						-- Remember removed items for transfer
						local playerstacks = {}
						for i=1, coststacks do
							price.count = cost_stack_max
							rchest_inv:remove_item(rchestdef.inv_list, price)
						end
						if costremainder > 0 then
							price.count = costremainder
							rchest_inv:remove_item(rchestdef.inv_list, price)
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
								achest_inv:add_item(achestdef.inv_list, player_out[o].item)
							end
						else
							for i=1,#playerstacks do
								achest_inv:add_item(achestdef.inv_list, playerstacks[i])
							end
						end
						meta:set_string("message", "Item sold.")
						easyvend.sound_deposit(pos)
						easyvend.machine_check(pos, node)
					end
				end
			elseif chest_has and player_has then
				if not player_free then
					msg = "No room in your inventory!"
					meta:set_string("message", msg)
					easyvend.sound_error(sendername)
				elseif not chest_free then
					msg = "No room in the machine’s storage!"
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
		local status
		meta:set_int("stock", 0)
		if chest_error_remove == "no_chest" and chest_error_add == "no_chest" then
			status = "No storage; machine needs to be connected with a locked chest."
		elseif chest_error_remove  == "not_owned" or chest_error_add == "not_owned" then
			status = "Storage can’t be accessed because it is owned by a different person!"
		elseif chest_error_remove  == "no_stock" then
			if buysell == "sell" then
				status = "The vending machine has insufficient materials!"
			else
				status = "The depositing machine is out of money!"
			end
		elseif chest_error_add  == "no_space" then
			status = "No room in the machine’s storage!"
		else
			status = "Unknown error!"
		end
		meta:set_string("status", status)
		easyvend.sound_error(sendername)
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

	inv:set_stack( "gold", 1, easyvend.currency )

	local d = ""
	if node.name == "easyvend:vendor" then
		d = string.format("Inactive vending machine (owned by %s)", player_name)
		meta:set_int("wear", 1)
		-- Total number of currency items earned for the machine's life time (excluding currency-currency trading)
		meta:set_int("earnings", 0)
	elseif node.name == "easyvend:depositor" then
		d = string.format("Inactive depositing machine (owned by %s)", player_name)
		meta:set_int("wear", 0)
	end
	meta:set_string("infotext", d)
	meta:set_string("status", "Awaiting configuration by owner.")
	meta:set_string("message", "Welcome! Please prepare the machine.")
	meta:set_int("number", 1)
	meta:set_int("cost", 1)
	meta:set_int("stock", -1)
	meta:set_int("configmode", 1)
	meta:set_int("joketimer", -1)
	meta:set_int("joke_id", 1)
	meta:set_string("itemname", "")

	meta:set_string("owner", player_name or "")

	easyvend.set_formspec(pos, placer)
end

easyvend.can_dig = function(pos, player)
	local meta = minetest.get_meta(pos)
	local name = player:get_player_name()
	local owner = meta:get_string("owner")
	-- Owner can always dig shop
	if owner == name then
		return true
	end
	local chest_pos = easyvend.find_connected_chest(owner, pos)
	local chest, meta_chest
	if chest_pos then
		chest = minetest.get_node(chest_pos)
		meta_chest = minetest.get_meta(chest_pos)
	else
		return true --if no chest, enyone can dig this shop
	end
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
	local sendername = sender:get_player_name()

	if fields.doc then
		if minetest.get_modpath("doc") and minetest.get_modpath("doc_items") then
			if easyvend.buysell(node.name) == "buy" then
				doc.show_entry(sendername, "nodes", "easyvend:depositor", true)
			else
				doc.show_entry(sendername, "nodes", "easyvend:vendor", true)
			end
		end
	elseif fields.config or fields.save or fields.usermode then
		if sender:get_player_name() == owner then
			easyvend.on_receive_fields_config(pos, formname, fields, sender)
		else
			meta:set_string("message", "Only the owner may change the configuration.")
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
					meta:set_string("message", "Used tools won’t be sold anymore.")
				end
				meta:set_int("wear", 0)
			end
			easyvend.set_formspec(pos, sender)
			return
		else
			meta:set_string("message", "Only the owner may change the configuration.")
			easyvend.sound_error(sendername)
			easyvend.set_formspec(pos, sender)
			return
		end
	elseif fields.buysell then
		easyvend.on_receive_fields_buysell(pos, formname, fields, sender)
	end
end

-- Jokes: Appear when machine exchanges currency for currency at equal rate

-- Vendor
local jokes_vendor = {
	"Thank you. You have made a vending machine very happy.",
	"Humans have a strange sense of humor.",
	"Let’s get this over with …",
	"Item “bought”.",
	"Tit for tat.",
	"Do you realize what you’ve just bought?",
}
-- Depositor
local jokes_depositor = {
	"Thank you, the money started to smell inside.",
	"Money doesn’t grow on trees, you know?",
	"Sanity sold.",
	"Well, that was an awkward exchange.",
	"Are you having fun?",
	"Is this really trading?",
}

easyvend.assign_joke = function(buysell)
	local jokes
	if buysell == "sell" then
		jokes = jokes_vendor
	elseif buysell == "buy" then
		jokes = jokes_depositor
	end
	local r = math.random(1,#jokes)
	return r
end

easyvend.get_joke = function(buysell, id)
	local joke
	if buysell == nil or id == nil then
		-- Fallback message (should never happen)
		return "Items exchanged."
	end
	if buysell == "sell" then
		joke = jokes_vendor[id]
		if joke == nil then joke = jokes_vendor[1] end
	elseif buysell == "buy" then
		joke = jokes_depositor[id]
		if joke == nil then joke = jokes_depositor[1] end
	end
	return joke
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

--[[ Tower building ]]

easyvend.is_traversable = function(pos)
	local node = minetest.get_node_or_nil(pos)
	if (node == nil) then
		return false
	end
	return traversable_node_types[node.name] == true
end

easyvend.neighboring_nodes = function(pos)
	local check = {
		{x=pos.x, y=pos.y-1, z=pos.z},
		{x=pos.x, y=pos.y+1, z=pos.z},
	}
	local trav = {}
	for i=1,#check do
		if easyvend.is_traversable(check[i]) then
			table.insert(trav, check[i])
		end
	end
	return trav
end

easyvend.find_connected_chest = function(owner, pos, nodename, check_wear, amount, removing)
	local nodes = easyvend.neighboring_nodes(pos)

	if (#nodes < 1 or  #nodes > 2) then
		return nil, "no_chest"
	end

	-- Find the stack direction
	local first = nil
	local second = nil
	for i=1,#nodes do
		if ( first == nil ) then
			first = nodes[i]
		else
			second = nodes[i]
		end
	end

	local chest_pos, chest_internal

	if (first ~= nil and second ~= nil) then
		local dy = (first.y - second.y)/2
		chest_pos, chest_internal = easyvend.find_chest(owner, pos, dy, nodename, check_wear, amount, removing)
		if ( chest_pos == nil ) then
			chest_pos, chest_internal = easyvend.find_chest(owner, pos, -dy, nodename, check_wear, amount, removing, chest_internal)
		end
	else
		local dy = first.y - pos.y
		chest_pos, chest_internal = easyvend.find_chest(owner, pos, dy, nodename, check_wear, amount, removing)
	end

	if chest_internal.chests == 0 then
		return nil, "no_chest"
	elseif chest_internal.chests == chest_internal.other_chests then
		return nil, "not_owned"
	elseif removing and chest_internal.stock < 1 then
		return nil, "no_stock"
	elseif not removing and chest_internal.space < 1 then
		return nil, "no_space"
	elseif chest_pos ~= nil then
		return chest_pos
	else
		return nil, "unknown"
	end
end

easyvend.find_chest = function(owner, pos, dy, itemname, check_wear, amount, removing, internal)
	pos = {x=pos.x, y=pos.y + dy, z=pos.z}

	if internal == nil then
		internal = {}
		internal.chests = 0
		internal.other_chests = 0
		internal.stock = 0
		internal.space = 0
	end

	local node = minetest.get_node_or_nil(pos)
	if ( node == nil ) then
		return nil, internal
	end
	local chestdef = registered_chests[node.name]
	if (chestdef ~= nil) then
		internal.chests = internal.chests + 1
		local meta = minetest.get_meta(pos)
		if (owner ~= meta:get_string(chestdef.meta_owner)) then
			internal.other_chests = internal.other_chests + 1
			return nil, internal
		end
		local inv = meta:get_inventory()
		if (inv ~= nil) then
			if (itemname ~= nil and minetest.registered_items[itemname] and amount ~= nil and removing ~= nil and check_wear ~= nil) then
				local chest_has, chest_free
				local stack = {name=itemname, count=amount, wear=0, metadata=""}
				local stack_max = minetest.registered_items[itemname].stack_max

				local stacks = math.modf(amount / stack_max)
				local stacksremainder = math.fmod(amount, stack_max)
				local free = stacks
				if stacksremainder > 0 then free = free + 1 end

				chest_has = easyvend.check_and_get_items(inv, chestdef.inv_list, stack, check_wear)
				if chest_has then
					internal.stock = internal.stock + 1
				end
				chest_free = inv:room_for_item(chestdef.inv_list, stack) and easyvend.free_slots(inv, chestdef.inv_list) >= free
				if chest_free then
					internal.space = internal.space + 1
				end

				if (removing and internal.stock == 0) or (not removing and internal.space == 0) then
					return easyvend.find_chest(owner, pos, dy, itemname, check_wear, amount, removing, internal)
				else
					return pos, internal
				end
			else
				return nil, internal
			end
		else
			return nil, internal
		end
	elseif (node.name ~= "easyvend:vendor" and node.name~="easyvend:depositor" and node.name~="easyvend:vendor_on" and node.name~="easyvend:depositor_on") then
		return nil, internal
	end

	return easyvend.find_chest(owner, pos, dy, itemname, check_wear, amount, removing, internal)
end

-- Pseudo-inventory handling
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
				meta:set_string("itemname", stack:get_name())
				easyvend.set_formspec(pos, player)
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

-- Legacy support for vendor mod:
-- Transform the world and items to use the easyvend nodes/items

-- For safety reasons, only do this when player requested so
if minetest.setting_getbool("easyvend_convert_vendor") == true then
	-- Replace vendor nodes
	minetest.register_lbm({
		name = "easyvend:replace_vendor",
		nodenames = { "vendor:vendor", "vendor:depositor" },
		run_at_every_load = true,
		action = function(pos, node)
			-- Replace node
			local newnodename
			if node.name == "vendor:vendor" then
				newnodename = "easyvend:vendor"
			elseif node.name == "vendor:depositor" then
				newnodename = "easyvend:depositor"
			end
			-- Remove axis rotation; only allow 4 facedirs
			local p2 = math.fmod(node.param2, 4)
			minetest.swap_node(pos, { name = newnodename, param2 = p2 })

			-- Initialize metadata
			local meta = minetest.get_meta(pos)
			if node.name == "vendor:vendor" then
				meta:set_int("earnings", 0)
			end
			meta:set_int("stock", -1)
			meta:set_int("joketimer", -1)
			meta:set_int("joke_id", 1)
			local inv = meta:get_inventory()
			inv:set_size("item", 1)
			inv:set_size("gold", 1)
			inv:set_stack("gold", 1, easyvend.currency)

			-- In vendor, all machines accepted worn tools
			meta:set_int("wear", 1)

			-- Set item
			local itemname = meta:get_string("itemname")
			if itemname == "" or itemname == nil then
				itemname = meta:get_string("itemtype")
			end
			if itemname ~= "" and itemname ~= nil then
				inv:set_stack("item", 1, itemname)
				meta:set_string("itemname", itemname)
			end

			-- Check for valid item, item count and price
			local configmode = 1
			if itemname ~= "" and itemname ~= nil then
				local itemstack = inv:get_stack("item", 1)
				local number_stack_max = itemstack:get_stack_max()
				local maxnumber = number_stack_max * slots_max
				local cost = meta:get_int("cost")
				local number = meta:get_int("number")
				if number >= 1 and number <= maxnumber and cost >= 1 and cost <= maxcost then
					-- Everything's OK, get out of config mode!
					configmode = 0
				end
			end

			-- Final initialization stuff
			meta:set_int("configmode", configmode)

			local owner = meta:get_string("owner")
			if easyvend.buysell(newnodename) == "sell" then
				meta:set_string("infotext", string.format("Vending machine (owned by %s)", owner))
			else
				meta:set_string("infotext", string.format("Depositing machine (owned by %s)", owner))
			end


			meta:set_string("status", "Initializing …")
			meta:set_string("message", "Upgrade successful.")
			easyvend.machine_check(pos, node)
		end,
	})
end
