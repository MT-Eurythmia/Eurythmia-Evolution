# Minetest: Vivarium

Some added things for running the Minetest online game DuCake's Vivarium at play.ducakedhare.co.uk:30000

## Falling Light

A simple minetest mod to add a falling light. Use sand and torches to craft a falling light source to illuminate the darkest depths!

## Staves

Several staves ("staffs"?) to help with maintenance.

* Staff of Melting
	* quick attempt to melt areas where freeze-type mobs from NSSM have been running amok
* Staff of Cloning
	* extend surfaces horizontally
* Staff of Stacking
	* create upwards or downwards columns. Useful for building walls and fixing trees
* Staff of Bomf
	* remove lots of nodes of the same type at once

All staves require "creative" privilege

## Captivate

Non-intrusively add capturing code to `mobs_redo`-compatible mobs that are already defined.

List mods, mobs and intended capture settings, and captivation will add `mobs:feed_tame` and `mobs:capture` code to mobs. Capture chances are derived from the `hp_max` property.

