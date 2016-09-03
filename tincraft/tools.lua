-- Tin Dagger
-- Useful in that it's better than your bare hands or a wooden/stone sword
-- Pretty patheritc in that it breaks fairly quickly


local tindagcap = {
                full_punch_interval = 2.0,
                max_drop_level = 0,
                groupcaps = {
                        snappy = {times = {[2] = 1.2, [3] = 0.3}, uses = 2, maxlevel = 1},
                },
                damage_groups = {fleshy = 5},
        }

minetest.register_tool("tincraft:tin_dagger", {
        description = "Cheap Tin Dagger",
        inventory_image = "tincraft_tin_dagger.png",
        tool_capabilities = tindagcap, -- overridden by use of on_use ....
	on_use = function(itemstack,user,pointedthing)
		if pointedthing.type == "object" then
			pointedthing.ref:punch(user,1,tindagcap)
		        itemstack:add_wear(math.ceil(65536/25))
		end
	        return itemstack
	end
})

core.register_craft({
	output = "tincraft:tin_dagger",
	recipe = {
	{"moreores:tin_ingot"},
	{"moreores:tin_ingot"},
	{"default:stick"}
	}
})

