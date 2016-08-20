-- Supported animals

local bestiary = {
	{
		name = "dmobs",
		beasts = {"panda","badger"}, -- leave their types alone
		animals = {"elephant","fox"}, -- make sure these are "animal"
		monsters = {"ogre","orc"}, -- make sure these are "monster"
		npcs = {"medved","dragon"}, -- make sure these are NPC.
		follow = "farming:bread"
	},
	{
		name = "nssm",
		animals = nil,
		monsters = {"masticone","phoenix"},
		npcs = {"mese_companion"}
	},
}

bestiary = {} -- turn it off for now
