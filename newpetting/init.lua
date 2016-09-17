
local chancer = function(hp,difficulty)
        return math.floor(1000/hp * hp/(hp*0.4) * difficulty)
end

local capturedef = function(def)
	local handchance = chancer(def.hp,0.2)
	local netchance = chancer(def.hp,0.5)
	local lassochance = chancer(def.hp,1)
	local feedcount = def.feedcount or 8
	local override = def.override or false
	local replacement = def.replacement or nil

	local capturing = function(self,clicker)

		if mobs:feed_tame(self, clicker, feedcount, true, true) then
			return
		end
		mobs:capture_mob(self, clicker, handchance, netchance, lassochance, override, replacement)
	end
	return capturing
end

local getfollows = function(followt)
	if type(followt) == "string" then return followt
	elseif type(followt) ~= "table" then return "nothing"
	end

	local followstring = ""
	for _,s in pairs(followt) do
		followstring = followstring .. " " .. s
	end
	return followstring
end

local identification = function(self,clicker)
	if self.owner and self.owner ~= clicker:get_player_name() then
		minetest.chat_send_player(clicker:get_player_name(),
			"This is a "..self.name..". It eats: "..getfollows(self.follow)
		)
	end
	return true
end

local moborder = function(self,clicker)
	if self.owner
	  and clicker:get_wielded_item():get_name() == "petting:mobtamer"
	  and self.owner == clicker:get_player_name() then
		if self.order == "follow" then
			self.order = "stand"
			minetest.chat_send_player(clicker:get_player_name(),self.name .." will now stand.")
		else
			self.order = "follow"
			minetest.chat_send_player(clicker:get_player_name(),self.name .." will now follow you.")
		end
	end
	return true
end

-- table concatenation
local cattable = function(oldtable,newtable)
	local targettable = {}
	for i,j in pairs(oldtable) do targettable[i] = j end
	for i,j in pairs(newtable) do targettable[i] = j end
	return targettable
end


local cattables = function(tablestable)
	local targettable = {}
	for i,thetable in pairs(tablestable) do
		for k,v in pairs(thetable) do targettable[k] = v end
	end
	return targettable
end

local nilcheck = function(oldval) return oldval ~= nil end

-- first assign capturing if necessary
-- then assign id and order

local fighttable = {
	attack_type={check=nilcheck,value="dogfight"},
	damage={check=nilcheck,value=1}, -- small animals most likely
	passive = false,
	attacks_monsters = true,
}

local function processanimals(modname,moblist,prop) -- just overrides the capturing
	if prop == nil then prop = {} end


	for _,mobname in pairs(moblist) do
		local mymob = minetest.registered_entities[modname..":"..mobname]
		if mymob then
			prop.on_rightclick=capturedef({hp=mymob.hp_max}) -- rightlick override
			override.rewrite(modname..":"..mobname,prop)
			override.rewrite(modname..":"..mobname,{on_rightclick={fchain_type="before",fchain_func=identification} }) -- insert functions (not overrides)
			override.rewrite(modname..":"..mobname,{on_rightclick={fchain_type="before",fchain_func=moborder} })
		end
	end
end

processanimals("mobs_animal",{"cow","kitten","pumba","bunny","chicken"},fighttable)
processanimals("mobs_animal",{"sheep_black","sheep_blue","sheep_brown","sheep_cyan","sheep_dark_green","sheep_dark_grey","sheep_green","sheep_grey","sheep_magenta","sheep_orange","sheep_pink","sheep_red","sheep_violet","sheep_white","sheep_yellow"},fighttable)
processanimals("mobs_turtles",{"turtle","seaturtle"},cattables({fighttable,{follow="farming:carrot"} }))
processanimals("mobs_giraffe",{"jeraf"},fighttable)
processanimals("mobs_wolf",{"wolf","dog"},{hp_max=20,armor=100})
processanimals("mobs_deer",{"deer"},cattables({fighttable,{hp_max=20,armor=60,damage=4}}) )
processanimals("mobs_",{"snowman"},{follow={value={"farming:carrot","default:snow"} }} )
processanimals("mobs_bear",{"medved"},{hp_max=30,armor=90})
processanimals("mobs_mr_goat",{"goat"},fighttable)
processanimals("mobs_yeti",{"yeti"})
processanimals("mobs_horse",{"horse"},{hp_max=40,armor=100})
processanimals("mobs_slimes",{"green_small","green_medium","green_big","lava_small","lava_medium","lava_big"},{follow="mobs_slimes:slimeball"})
processanimals("mobs_sandworm",{"sandworm"},{follow="default:sandstone"})
processanimals("mobs_senderman",{"senderman"},{follow="default:nyan"},{hp_max=50})
processanimals("mobs_creeper",{"creeper"},{follow={value={"default:coal_lump","basic_machines:charcoal"}}})
processanimals("mobs_zombie",{"zombie","zombie_mini"},{follow="mobs_zombie:rotten_flesh"})
processanimals("mobs_monster",{"dirt_monster"},{follow="default:dirt"})
processanimals("mobs_monster",{"sand_monster"},{follow="default:sandstone"})
processanimals("mobs_monster",{"oerkki"},{follow="default:obsidian_shard"})
processanimals("mobs_monster",{"lava_flan"},{follow="group:tree"})
processanimals("mobs_monster",{"mese_monster"},{follow="default:mese_crystal_fragment"})
processanimals("mobs_monster",{"stone_monster"},{follow="default:stone"})
processanimals("mobs_monster",{"spider"},{follow="mobs_bugslive:bug"})
processanimals("mobs_monster",{"dungeon_master"},{follow="default:mese_crystal_fragment"})
processanimals("mobs_monster",{"tree_monster"},{follow="group:wood"})
processanimals("dmobs",{"whale"},cattables({fighttable,{follow="mobs_bugslive:bug"} }))
processanimals("dmobs",{"gnorm","pig"},cattables({fighttable,{follow="default:apple"}}))
processanimals("dmobs",{"pig_evil"},{follow="mobs:pork_raw"})

override.rewrite("dmobs:pig",{drops={value={ {name = "mobs:pork_raw", chance = 1, min = 1, max = 1}, }}})
override.rewrite("dmobs:pig_evil",{drops={value={ {name = "mobs:pork_raw", chance = 1, min = 2, max = 3}, }}})

processanimals("dmobs",{"panda","elephant","hedgehog"},cattables({fighttable,{follow="farming:bread",type="animal"}}))
processanimals("dmobs",{"fox","badger","owl"},cattables({fighttable,{follow="mobs:meat_raw",type="animal",walk_chance=2}}))
processanimals("dmobs",
	{"dragon","dragon2","dragon3","dragon4","dragon_black","dragon_blue","dragon_great","dragon_great_tame","dragon_green","dragon_red"},
	{follow={value={"mobs:lava_orb","bucket:bucket_lava"}} }
	)
processanimals("dmobs",{"orc","orc_redesign","ogre"},{follow="mobs_zombie:rotten_flesh",hp_max=50,armor=80})
processanimals("f46_dragon",{"dragon"},{follow={value={"mobs:lava_orb","bucket:bucket_lava"}} })
processanimals("banth",{"banth"},{follow="mobs:meat_raw",hp_max=40,armor=80})
processanimals("mobs_sharks",{"shark_lg","shark_md","shark_sm"},{follow="mobs_turtles:turtle"})

processanimals("mobs_crocs",{"crocodile","crocodile_float","crocodile_swim"},{follow="mobs_jellyfish:jellyfish"})
processanimals("nssm",{"crocodile","dolidrosaurus"},{follow="mobs_jellyfish:jellyfish"})

processanimals("nssm",{"stone_eater"},{follow="default:stone"})
processanimals("nssm",{"night_master","night_master_2","night_master_1","moonheron"},{follow="nssm:amphibian_heart"})
processanimals("nssm",{"scrausics","phoenix"},{follow="nssm:worm_flesh"})
processanimals("nssm",{"lava_titan"},{follow="default:obsidian"})
processanimals("nssm",{"echidna"},{follow="default:sword_stone"}) -- tee hee
processanimals("nssm",{"ant_soldier","ant_worker","ant_queen"},{follow="nssm:larva"}) -- sworn enemies
processanimals("nssm",{"mantis","mantis_beast"},{follow={value={"ant_soldier","ant_worker"}}}) -- sworn enemies
processanimals("nssm",{"sandworm","giant_sandworm"},{follow="default:sandstone"})
processanimals("nssm",{"mese_dragon"},{follow={value={"mobs:lava_orb","bucket:bucket_lava","default:obsidian"}}})
processanimals("nssm",{"snow_biter","ice_snake","icelamander"},{follow="bucket:bucket_water"})
processanimals("nssm",{"duck","swimming_duck","flying_duck","spiderduck","enderduck","duckking","crab"},{follow="nssm:tentacle"})
processanimals("nssm",{"uloboros","block_widow","tarantula","tarantula_propower","daddy_long_legs"},{follow={value={"mobs_bugslive:bug","mobs_animal:bee","mobs_air:butterfly"} }})
processanimals("nssm",{"manticore"},{follow="mobs:meat_raw"})
processanimals("nssm",{"octopus","xgaloctopus","kraken"},{follow="nssm:duck_legs"})
processanimals("nssm",{"pumpking","pumpboom_small","pumpboom_medium","pumpboom_large"},{follow={value={"farming:wheat_seed","farming:cotton_seed"} }}) -- FIXME check itemstrings
processanimals("nssm",{"sand_bloco"},{follow="default:desertstone"}) -- FIXME check itemstring
processanimals("nssm",{"bloco"},{follow="default:stone"})
processanimals("nssm",{"werewolf","white_werewolf"},{follow="nssm:duck_legs"})
processanimals("nssm",{"masticone"},{follow="nssm:worm_flesh"})
processanimals("nssm",{"signosigno"},{follow="default:torch"})

-- override nssm:larva and mobs_air and mobs_water with simple capturing

for _,mob in pairs({"mobs_animal:bee","mobs_animal:rat","nssm:larva","mobs_butterfly:butterfly","mobs_bat:bat","mobs_birds:gull","mobs_birds:bird_sm","mobs_birds:bird_lg","mobs_fish:clownfish","mobs_fish:tropical","mobs_jellyfish:jellyfish"}) do
	local def = {}
	local mymob = minetest.registered_entities[mob]
	if mymob then
		def.on_rightclick = capturedef({hp=mymob.hp_max,override=true})
		override.rewrite(mob,def)
	end
end

-- TODO override nssm drops

