# Minetest: Vivarium

Some added things for running the Minetest online game DuCake's Vivarium at play.ducakedhare.co.uk:30000

## Captivate

Non-intrusively add capturing code to `mobs_redo`-compatible mobs that are already defined.

List mods, mobs and intended capture settings, and captivation will add `mobs:feed_tame` and `mobs:capture` code to mobs. Capture chances are derived from the `hp_max` property.

## Mob Tamer

In the inventory, place the mob egg to the left of the Mob Tamer

Then use the mob tamer (not the egg!) and the mob will be spawned as a NPC, and fight monsters for you.

## Falling Light

A simple minetest mod to add a falling light. Use sand and torches to craft a falling light source to illuminate the darkest depths!

## Staves

Several staves ("staffs"?) to help with maintenance.

* Staff of Melting
	* quick attempt to melt areas where freeze-type mobs from NSSM have been running amok
	* does nothing to mobs
* Staff of Cloning
	* extend surfaces horizontally
	* if used on a mob, spawns another mob of same type
* Staff of Stacking
	* create upwards or downwards columns. Useful for building walls and fixing trees
	* if you click on a mob it turns
		* a monster into a NPC
		* a NPC into an animal
		* an animal into a monster
* Staff of Bomf
	* remove lots of nodes of the same type at once
	* If used on a mob, removes it without drops

All staves require "creative" privilege

