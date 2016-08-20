-- Supported animals

vivarium.bestiary = {
	{
		name = "mobs_animal",
		beasts = {"cow","sheep_","kitten","pumba","bunny","bee","rat","chicken"}
	},
	{name = "mobs_giraffe", beasts = {"jeraf",}},
	{name = "mobs_wolf",beasts = {"dog",}},
	{name = "mobs_deer",beasts = {"deer",}},
	{name = "mobs_snowman",beasts = {"snowman",},follow= {"farming:carrot","default:snow"}},
	{name = "mobs_bear",beasts = {"medved",}},
	{name = "mobs_mr_goat",beasts = {"goat",}},
	{name = "mobs_yeti",beasts = {"yeti",}},
	{name = "mobs_slimes",beasts = {"green_small","green_medium","green_big","lava_small","lava_medium","lava_big"}, follow="mobs_slimes:slimeball"},
	{name = "mobs_sandworm",beasts = {"sandworm",},follow="default:stone_desert"},
	{name = "mobs_senderman",beasts = {"senderman",},follow="default:nyan"},
	{name = "mobs_creeper",beasts = {"creeper",},follow={"default:coal_lump","basic_machines:charcoal"}},
	{name = "mobs_zombie",beasts = {"zombie","zombie_mini"},follow="mobs_zombie:rotten_flesh"},
	{name = "mobs_monster",beasts = {"dirt_monster",},follow="default:dirt"},
	{name = "mobs_monster",beasts = {"sand_monster",},follow={"default:sand","default:desert_sand"}},
	{name = "mobs_monster",beasts = {"oerkki",},follow="default:obsidian_shard"},
	{name = "mobs_monster",beasts = {"lava_flan",},follow="group:wood"},
	{name = "mobs_monster",beasts = {"mese_monster",},follow="default:mese_crystal_fragment"},
	{name = "mobs_monster",beasts = {"stone_monster",},follow="default:stone"},
	{name = "mobs_monster",beasts = {"spider",},follow="farming:cotton"},
	{name = "mobs_monster",beasts = {"dungeon_master",},follow="default:mese_crystal_fragment"},
	{name = "mobs_monster",beasts = {"tree_monster",},follow="group:wood"},
	{
		name = "dmobs",
		beasts = {"panda","elephant","fox","badger","owl","hedgehog"},
	},
	-- {name = "dmobs",beasts = {"dragon",},follow="mobs:meat"},
	{name = "dmobs",beasts = {"orc","ogre"},follow="mobs_zombie:rotten_flesh"},
	{name = "banth",beasts = {"banth",},follow="mobs:meat"},
	{name = "mobs_crocs",beasts = {"crocodile","crocodile_float","crocodile_swim"},follow="mobs_jellyfish:jellyfish"},
	{name = "mobs_sharks",beasts = {"shark_lg","shark_md","shark_sm"},follow="mobs_turtles:turtle"},
	{
		name = "nssm",
		monsters = {"night_master","night_master_2","night_master_1","moonheron","lava_titan","crocodile","echidna","ant_soldier","giant_sandworm","ant_worker","mantis_beast","mese_dragon","snow_biter","swimming_duck","uloboros","sandworm","icelamander","manticore","larva","mese_dragon_tame","duckking","ant_queen","dolidrosaurus","octopus","xgaloctopus","daddy_long_legs","pumpking","tarantula","tarantula_propower","sand_bloco","flying_duck","bloco","duck","crab","enderduck","pumpboom_small","pumpboom_medium","pumpboom_large","werewolf","mantis","phoenix","scrausics","stone_eater","spiderduck","white_werewolf","masticone","firesnake","kraken","signosigno","icesnake","black_widow"},
		follow="homedecor:coin" -- interim solution until I get fodder
	},
	-- {name = "",beasts = {"",},follow=""},
}


