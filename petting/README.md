# Petting

A toolset to add petting ability to any mob.

Add a soft dependency to the depends.txt, and edit the bestiary.lua file -- add any mobs you want.

The format is as follows:

	petting.options = {
		nilfollow = "default:grass", -- if mob does not normally follow anything, make it follow this
	}

	petting.bestiary = {
		{
			name = "mobs_animal", -- the modpack to find the mobs in
			monsters = {"pumba","chicken",} -- ensure the pumba (pig) and chicken are monsters that will attack you
			animals = {"bunny", "bee"} -- ensure the bunny and bee are docile animals
			npc = {"cow"}, -- make the cow an NPC
		},
		{
			name = "mobs_turtles",
			beasts = {"turtle",}, -- don't modify the animal type, just add capturing code and requisite "follows"
			rc_callback = "before", -- don't override the rightclick callback, perform the original rightclick "before" or "after" the csutom code
		},

		...
	}

Note that this will override the `on_righclick` method of the mob entirely, unless `rc_callback` is set to `before` or `after`.

The capture chances will also change from their original to being directly derived from their max HP.

## Mob Tamer

The Mob Tamer is a tool you can use to spawn a mob as a `mobs_redo` NPC. This will only affect mobs using `mobs_redo` as their engine, or who can expect the `name` property to be `npc`.
