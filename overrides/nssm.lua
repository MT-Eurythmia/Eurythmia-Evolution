minetest.debug("Loading overrides")


function register_energy_ball(itemname,desc,boost,duration)
	minetest.register_craftitem(":nssm:"..itemname,{
		description = desc,
		image = itemname..".png",
		on_use = function (itemstack, user, pointed_thing)
			-- give a power boost
			local player = user:get_player_name()
			local physics = {}
			if minetest.get_modpath("3d_armor") and armor and armor[player] then
				physics = armor.def[player]
			end
			physics.speed = physics.speed or 1
			physics.jump = physics.jump or 1
			physics.gravity = physics.gravity or 1

			user:set_physics_override({
				speed = physics.speed + boost, -- move faster
				jump = physics.jump + 1, -- jump twice as high
				gravity = physics.gravity - 0.1*boost, -- defy gravity
			})

			if math.random(1,5) ~= 1 then
				itemstack:take_item()
			end

			-- then retract it after time
			minetest.after(duration, function()
				user:set_physics_override(physics)
			end)

			return itemstack

		end,
	})
end

-- function register_energy_ball(itemname,desc,boost,duration)
register_energy_ball("life_energy","Life Energy",1,2.0)
register_energy_ball("energy_globe","Energy Globe",1,2.0)
register_energy_ball("great_energy_globe","Great Energy Globe",2,2.0)
register_energy_ball("superior_energy_globe","Superior Energy Globe",2,10.0)

minetest.register_node(":nssm:web", { -- make it choppable
        description = "Web",
        inventory_image = "web.png",
        tile_images = {"web.png"} ,
    drawtype = "plantlike",
        paramtype = "light",
        walkable = false,
        pointable = true,
        diggable = true,
        buildable_to = false,
        drop = "farming:cotton",
        drowning = 0,
        liquid_renewable = false,
        liquidtype = "source",
        liquid_range= 0,
        liquid_alternative_flowing = "nssm:web",
        liquid_alternative_source = "nssm:web",
        liquid_viscosity = 20,
        groups = {flammable=2, snappy=2, liquid=1},
})

local old_nodes = {}
local old_entities = {
"nssm_vanilla:amphibian_heart",
"nssm_vanilla:ant_dirt",
"nssm_vanilla:ant_leg",
"nssm_vanilla:ant_mandible",
"nssm_vanilla:ant_queen",
"nssm_vanilla:ant_queen_abdomen",
"nssm_vanilla:ant_soldier",
"nssm_vanilla:ant_sword",
"nssm_vanilla:ant_worker",
"nssm_vanilla:black_ice_tooth",
"nssm_vanilla:black_sand",
"nssm_vanilla:black_widow",
"nssm_vanilla:bloco",
"nssm_vanilla:brain",
"nssm_vanilla:capture_mob",
"nssm_vanilla:check_for_death_hydra",
"nssm_vanilla:chichibios_heron_leg",
"nssm_vanilla:crab",
"nssm_vanilla:crab_chela",
"nssm_vanilla:crab_heavy_mace",
"nssm_vanilla:crab_light_mace",
"nssm_vanilla:crocodile",
"nssm_vanilla:crocodile_tail",
"nssm_vanilla:cursed_pumpkin_seed",
"nssm_vanilla:daddy_long_legs",
"nssm_vanilla:digging_ability",
"nssm_vanilla:dolidrosaurus",
"nssm_vanilla:duck",
"nssm_vanilla:duck_beak",
"nssm_vanilla:duck_explosion",
"nssm_vanilla:duck_father",
"nssm_vanilla:duckking",
"nssm_vanilla:duck_legs",
"nssm_vanilla:echidna",
"nssm_vanilla:enderduck",
"nssm_vanilla:energy_globe",
"nssm_vanilla:explosion",
"nssm_vanilla:explosion_particles",
"nssm_vanilla:explosion_web",
"nssm_vanilla:eyed_tentacle",
"nssm_vanilla:feed_tame",
"nssm_vanilla:flying_duck",
"nssm_vanilla:frosted_amphibian_heart",
"nssm_vanilla:gas_explosion",
"nssm_vanilla:giant_sandworm",
"nssm_vanilla:great_energy_globe",
"nssm_vanilla:hellzone_grenade",
"nssm_vanilla:heron_leg",
"nssm_vanilla:ice_explosion",
"nssm_vanilla:icelamander",
"nssm_vanilla:icesnake",
"nssm_vanilla:ice_tooth",
"nssm_vanilla:ink",
"nssm_vanilla:king_duck_crown",
"nssm_vanilla:kraken",
"nssm_vanilla:larva",
"nssm_vanilla:lava_arrow",
"nssm_vanilla:lava_titan",
"nssm_vanilla:lava_titan_eye",
"nssm_vanilla:life_energy",
"nssm_vanilla:little_ice_tooth",
"nssm_vanilla:magic_lasso",
"nssm_vanilla:manticore",
"nssm_vanilla:manticore_spine",
"nssm_vanilla:mantis",
"nssm_vanilla:mantis_beast",
"nssm_vanilla:mantis_claw",
"nssm_vanilla:mantis_sword",
"nssm_vanilla:masticone",
"nssm_vanilla:masticone_fang",
"nssm_vanilla:masticone_fang_sword",
"nssm_vanilla:masticone_skull",
"nssm_vanilla:masticone_skull_crowned",
"nssm_vanilla:masticone_skull_fragments",
"nssm_vanilla:mese_dragon",
"nssm_vanilla:mese_egg",
"nssm_vanilla:mese_meteor",
"nssm_vanilla:midas_ability",
"nssm_vanilla:modders_block",
"nssm_vanilla:moonheron",
"nssm_vanilla:nametag",
"nssm_vanilla:net",
"nssm_vanilla:night_feather",
"nssm_vanilla:night_master",
"nssm_vanilla:night_master_1",
"nssm_vanilla:night_master_2",
"nssm_vanilla:night_sword",
"nssm_vanilla:node_ok",
"nssm_vanilla:octopus",
"nssm_vanilla:phoenix",
"nssm_vanilla:phoenix_arrow",
"nssm_vanilla:phoenix_nuggets",
"nssm_vanilla:phoenix_tear",
"nssm_vanilla:pumpbomb",
"nssm_vanilla:pumpboom_large",
"nssm_vanilla:pumpboom_medium",
"nssm_vanilla:pumpboom_small",
"nssm_vanilla:pumpking",
"nssm_vanilla:putting_ability",
"nssm_vanilla:rainbow",
"nssm_vanilla:rainbow_staff",
"nssm_vanilla:raw_scrausics_wing",
"nssm_vanilla:register_arrow",
"nssm_vanilla:register_egg",
"nssm_vanilla:register_mob",
"nssm_vanilla:register_spawn",
"nssm_vanilla:roar_of_the_dragon",
"nssm_vanilla:roasted_amphibian_heart",
"nssm_vanilla:roasted_ant_leg",
"nssm_vanilla:roasted_brain",
"nssm_vanilla:roasted_crocodile_tail",
"nssm_vanilla:roasted_duck_legs",
"nssm_vanilla:roasted_spider_leg",
"nssm_vanilla:roasted_tentacle",
"nssm_vanilla:roasted_werewolf_leg",
"nssm_vanilla:roasted_worm_flesh",
"nssm_vanilla:rope",
"nssm_vanilla:round",
"nssm_vanilla:sand_bloco",
"nssm_vanilla:sandworm",
"nssm_vanilla:scrausics",
"nssm_vanilla:signosigno",
"nssm_vanilla:sky_feather",
"nssm_vanilla:snake_scute",
"nssm_vanilla:snow_arrow",
"nssm_vanilla:snow_biter",
"nssm_vanilla:spawn_specific",
"nssm_vanilla:spear_",
"nssm_vanilla:spicy_scrausics_wing",
"nssm_vanilla:spiderduck",
"nssm_vanilla:spider_leg",
"nssm_vanilla:spine",
"nssm_vanilla:stoneater_mandible",
"nssm_vanilla:stoneater_pick",
"nssm_vanilla:stone_eater",
"nssm_vanilla:sun_feather",
"nssm_vanilla:sun_sword",
"nssm_vanilla:super_gas",
"nssm_vanilla:superior_energy_globe",
"nssm_vanilla:surimi",
"nssm_vanilla:swimming_duck",
"nssm_vanilla:tarantula",
"nssm_vanilla:tarantula_chelicerae",
"nssm_vanilla:tarantula_propower",
"nssm_vanilla:tentacle",
"nssm_vanilla:tentacle_curly",
"nssm_vanilla:uloboros",
"nssm_vanilla:venomous_gas",
"nssm_vanilla:web",
"nssm_vanilla:webball",
"nssm_vanilla:webber_ability",
"nssm_vanilla:werewolf",
"nssm_vanilla:werewolf_leg",
"nssm_vanilla:white_werewolf",
"nssm_vanilla:white_wolf_fur",
"nssm_vanilla:wolf_fur",
"nssm_vanilla:worm_flesh",
"nssm_vanilla:xgaloctopus",
}


-- ======= old things deletions

for _,node_name in ipairs(old_nodes) do
    minetest.register_node(":"..node_name, {
        groups = {old=1},
    })
end

minetest.register_abm({
    nodenames = {"group:old"},
    interval = 1,
    chance = 1,
    action = function(pos, node)
        minetest.env:remove_node(pos)
    end,
})

for _,entity_name in ipairs(old_entities) do
    minetest.register_entity(":"..entity_name, {
        on_activate = function(self, staticdata)
            self.object:remove()
        end,
    })
end


minetest.debug("Done loading overrides")

