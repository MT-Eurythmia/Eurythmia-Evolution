-- Make a more valuable tin product 

 
minetest.register_craftitem("tincraft:strong_tin", { 
        description = "Strengthened tin", 
        inventory_image = "moreores_tin_ingot.png^[colorize:yellow:30" 
}) 
 
core.register_craft({ 
        output = "tincraft:strong_tin", 
        recipe = { 
                {"moreores:tin_ingot","moreores:tin_ingot","moreores:tin_ingot"}, 
                {"moreores:tin_ingot","default:coal_lump","moreores:tin_ingot"}, 
                {"moreores:tin_ingot","moreores:tin_ingot","moreores:tin_ingot"}, 
        } 
}) 


-- For those who have not been able to mine iron/are afraid of the first mining trip.
-- Making steel from tin is deliberately laborious.

core.register_craft({
        output = "default:steel_ingot",
        recipe = {
                {"tincraft:strong_tin","tincraft:strong_tin","tincraft:strong_tin",},
		{"default:stone","default:stone","default:stone",},
		{"tincraft:strong_tin","tincraft:strong_tin","tincraft:strong_tin",}
        }
})

