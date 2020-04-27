local skies = {
	{"DarkStormy", "#1f2226", 0.5, { density = 0.5, color = "#aaaaaae0", ambient = "#000000",
		height = 64, thickness = 32, speed = {x = 6, y = -6},}},
	{"CloudyLightRays", "#5f5f5e", 0.9, { density = 0.4, color = "#efe3d5d0", ambient = "#000000",
		height = 96, thickness = 24, speed = {x = 4, y = 0},}},
	--{"SunSet", "#72624d", 0.4, { density = 0.2, color = "#f8d8e8e0", ambient = "#000000",
	--	height = 120, thickness = 16, speed = {x = 0, y = -2},}},
	{"ThickCloudsWater", "#a57850", 0.8, { density = 0.35, color = "#ebe4ddfb", ambient = "#000000",
		height = 80, thickness = 32, speed = {x = 4, y = 3},}},
	{"TropicalSunnyDay", "#f1f4ee", 1.0, { density = 0.25, color = "#fffffffb", ambient = "#000000",
		height = 120, thickness = 8, speed = {x = -2, y = 0},}},
}

local nightsky = {"FullMoon", "#24292c", 0.2, { density = 0.25, color = "#ffffff80", ambient = "#404040",
		height = 140, thickness = 8, speed = {x = -2, y = 2}}}

local function tod_to_daynight_ratio(tod)
	-- Minetest engine: src/daynighratio.h
	if tod > .5 then
		tod = 1 - tod
	end
	tod = tod * 24000

	local values = {
		{4250 + 125, 175},
		{4500 + 125, 175},
		{4750 + 125, 250},
		{5000 + 125, 350},
		{5250 + 125, 500},
		{5500 + 125, 675},
		{5750 + 125, 875},
		{6000 + 125, 1000},
		{6250 + 125, 1000},
	}

	local sunrise_start = 4625
	local sunrise_end = 6125
	local nightlight = .175
	local daylight = 1
	if tod <= sunrise_start then
		return nightlight
	elseif tod >= sunrise_end then
		return daylight
	end

	for i, v in ipairs(values) do
		if v[1] > tod then
			local td0 = v[1] - values[i - 1][1]
			local f = (tod - values[i - 1][1]) / td0
			return (f * v[2] + (1 - f) * values[i - 1][2]) / 1000
		end
	end
end

local function set_sky(player, sky)
	player:set_sky(sky[2], "skybox", {
		sky[1] .. "Up.jpg",
		sky[1] .. "Down.jpg",
		sky[1] .. "Front.jpg",
		sky[1] .. "Back.jpg",
		sky[1] .. "Left.jpg",
		sky[1] .. "Right.jpg",
	}, true)
	player:set_clouds(sky[4])
end

local function run_every_player(func, ...)
	local players = minetest.get_connected_players()
	for _, player in ipairs(players) do
		func(player, ...)
	end
end

local randomgen = PcgRandom(os.clock())

local night = true
local max_light = false
local current_sky = skies[randomgen:next(1, #skies)]

local time_acc = 0
minetest.register_globalstep(function(dtime)
	time_acc = time_acc + dtime
	if time_acc >= 1 then -- return every second
		time_acc = time_acc - 1
		local tod = minetest.get_timeofday()
		local tod_ratio = tod_to_daynight_ratio(tod)

		if night and tod >= 4625/24000 then
			night = false
			run_every_player(set_sky, current_sky)
		end
		if not night and tod >= 1 - 4625/24000 then
			night = true
			run_every_player(set_sky, nightsky)
			local choice = randomgen:next(1, #skies)
			current_sky = skies[choice]
		end
		if not max_light and tod_ratio >= current_sky[3] then
			max_light = true
			run_every_player(function(player)
				player:override_day_night_ratio(current_sky[3])
			end)
		end
		if max_light and tod_ratio <= current_sky[3] then
			max_light = false
			run_every_player(function(player)
				player:override_day_night_ratio(nil)
			end)
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	if night then
		set_sky(player, nightsky)
	else
		set_sky(player, current_sky)
	end
	if max_light then
		player:override_day_night_ratio(current_sky[3])
	end
end)


-- Start with a nice morning!
minetest.after(0, function()
	minetest.set_timeofday(4625/24000)
end)
