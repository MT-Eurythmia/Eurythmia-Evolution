-- Externalized capturing

-- TODO add an identification tag to get mob name, stats, and follows
-- consumes said tag, uses mobs nametag image with yellow coloration

function petting:chancer(hp,difficulty)
	return math.floor(1000/hp * hp/(hp*0.4) * difficulty)
end

function petting:damagerate(hp)
	return math.ceil(hp/10)
end

function petting:getfollows(followt)
	if type(followt) == "string" then return followt
	elseif type(followt) ~= "table" then return "nothing"
	end

	local followstring = ""
	for _,s in pairs(followt) do
		followstring = followstring .. " " .. s
	end
	return followstring
end

function petting:captivate(mobname,modset)
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

	local handchance = petting:chancer(hpindicator,0.2)
	local netchance = petting:chancer(hpindicator,0.5)
	local lassochance = petting:chancer(hpindicator,1)
	local feedcount = modset.feedcount or 8
	local override = modset.override or false
	local replacement = modset.replacement or nil

	local rc_func = mobe.on_rightclick
	local callbackmoment = modset.rc_callback
		
	end

	if modset.mobtype then 
		mobe.type = modset.mobtype
		mobe.passive = false
		mobe.attacks_monsters = true -- if animal respawned as NPC this will be in effect
		mobe.damage = petting:damagerate(mobe.hp_max)

	end
	if modset.follow then 
		mobe.follow = modset.follow
		--minetest.debug("follow: "..dump(mobe.follow))
	elseif mobe.follow == nil and petting.options.nilfollow then
		mobe.follow = petting.options.nilfollow
	end

	local capturefunction = function(self,clicker) -- lambda time!
		if rc_func and callbackmoment == "before" then
			rc_func(self,clicker)
		end
		if mobs:feed_tame(self, clicker, feedcount, true, true) then
			return
		end
		if self.owner and self.owner ~= clicker:get_player_name() then
			minetest.chat_send_player(clicker:get_player_name(),
				"Mob: "..self.name.." ( "..
				handchance..", "..
				netchance..", "..
				lassochance.."). It follows: "..
				petting:getfollows(self.follow)
			)
		end

		mobs:capture_mob(self, clicker, handchance, netchance, lassochance, override, replacement)
		if clicker:get_wielded_item():get_name() == "petting:mobtamer" and self.owner == clicker:get_player_name() then
			if self.order == "follow" then
				self.order = "stand"
				minetest.chat_send_player(clicker:get_player_name(),self.name .." will now stand.")
			else
				self.order = "follow"
				minetest.chat_send_player(clicker:get_player_name(),self.name .." will now follow you.")
			end
		end
		if rc_func and callbackmoment == "after" then
			rc_func(self,clicker)
		end
	end
	mobe.on_rightclick = capturefunction

end

function petting:addcapture(modname,moblist,modset)
	for _,mobname in pairs(moblist) do
		petting:captivate(modname..":"..mobname, modset)
	end
end

function petting:loadbeasts(bestiary)
	for _,modset in pairs(bestiary) do

		if minetest.get_modpath(modset.name) then
			if modset.beasts then
				modset.mobtype = nil
				petting:addcapture(modset.name,modset.beasts,modset)
			end
			if modset.animals then
				modset.mobtype = "animal"
				petting:addcapture(modset.name,modset.animals,modset)
			end
			if modset.monsters then
				modset.mobtype = "monster"
				petting:addcapture(modset.name,modset.monsters,modset)
			end
			if modset.npcs then
				modset.mobtype = "npc"
				petting:addcapture(modset.name,modset.npcs,modset)
			end
		end

	end
end


minetest.debug("--- Start Mob Captivator ---")

dofile(minetest.get_modpath("petting") .. "/bestiary.lua")

if petting.bestiary then
	petting:loadbeasts(petting.bestiary)
end

-- ned to add a way for mobs to define their own bestiary separately

minetest.debug("-------- Mobs Captivated ------")
