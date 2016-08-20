-- Externalized capturing

-- TODO add an identification tag to get mob name, stats, and follows
-- consumes said tag, uses mobs nametag image with yellow coloration

-- TODO adda vivarium:fodder to feed animals in general

function chancer(hp,difficulty)
	return math.floor(1000/hp * hp/(hp*0.4) * difficulty)
end

function captivate(mobname,modset)
	local mobe = minetest.registered_entities[mobname]
	if not mobe then
		minetest.debug("Could not process "..mobname.. " - no such mob!")
		return
	end

	local hpindicator = 0
	if mobe.hp_max then
		hpindicator = mobe.hp_max
	elseif modset.chance then
		hpindicator = modset.chance
	else
		minetest.debug("Could not process "..mobname.. " - could not get HP definition")
		return
	end

	local handchance = chancer(hpindicator,0.2)
	local netchance = chancer(hpindicator,0.5)
	local lassochance = chancer(hpindicator,1)
	local feedcount = modset.feedcount or 8
	local override = modset.override or false

	local rc_func = mobe.on_rightclick

	local capturefunction = function(self,clicker) -- lambda time!
		if mobs:feed_tame(self, clicker, feedcount, true, true) then
			return
		end
		minetest.chat_send_player(clicker:get_player_name(),
			"Trying to catch "..self.name.." with chances "..
			handchance..", "..
			netchance..", "..
			lassochance.."...")

		mobs:capture_mob(self, clicker, handchance, netchance, lassochance, override, replacement)
		if rc_func then
			rc_func(self,clicker)
		end
	end
	mobe.on_rightclick = capturefunction

	if modset.mobtype then 
		mobe.type = modset.mobtype
		if modset.follow then 
			mobe.follow = modset.follow
		end
	end

end

function addcapture(modname,moblist,modset)
	for _,mobname in pairs(moblist) do
		captivate(modname..":"..mobname, modset)
	end
end


minetest.debug("--- Start Mob Captivator ---")

dofile(minetest.get_modpath("vivarium") .. "/bestiary.lua")

if vivarium.bestiary then
for _,modset in pairs(vivarium.bestiary) do

	if minetest.get_modpath(modset.name) then
		if modset.beasts then
			modset.mobtype = nil
			addcapture(modset.name,modset.beasts,modset)
		end
		if modset.animals then
			modset.mobtype = "animal"
			addcapture(modset.name,modset.animals,modset)
		end
		if modset.monsters then
			modset.mobtype = "monster"
			addcapture(modset.name,modset.monsters,modset)
		end
		if modset.npcs then
			modset.mobtype = "npc"
			addcapture(modset.name,modset.npcs,modset)
		end
	end

end
end

minetest.debug("-------- Mobs Captivated ------")
