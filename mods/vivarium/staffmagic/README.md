# Minetest - Staff Magic

Several staves ("staffs"?) to help with maintenance.

* Staff of Melting
	* quick attempt to melt areas where freeze-type mobs from NSSM have been running amok
	* does nothing to mobs
* Staff of Cloning
	* extend surfaces horizontally between (x,z) point where you clicked and (x,z) point where you are standing
	* clones the node you were pointing at
	* if used on a mob, spawns another mob of same type
* Staff of Stacking
	* create upwards or downwards columns. Useful for building walls and fixing trees
	* to stack upwards, the node you are pointing at needs to be under your foot level
	* if you click on a mob it turns
		* a monster into a NPC
		* a NPC into an animal
		* an animal into a monster
* Staff of Bomf
	* remove lots of nodes of the same type at once
	* If used on a mob, removes it without drops
* Creator's staff
	* creates a filled block between node(x,y,z) and player(x,y,z) consisting of the material pointed at

All staves require the "staffer" privilege to perform their basic functions.

A list of "forbidden" nodes is specified to prevent duplicating precious items. Staffers cannot duplicate forbidden nodes.

WHen "creative" privilege is active, no nodes are forbidden.

