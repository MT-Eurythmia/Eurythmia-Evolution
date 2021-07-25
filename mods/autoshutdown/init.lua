local CHECK_INTERVAL = 60
local check_timer = 0

minetest.register_globalstep(function(dtime)
	check_timer = check_timer + dtime
	if check_timer < CHECK_INTERVAL then
		return
	end
	check_timer = 0

	local shutdown_time = {year=2000, month=1, day=1} -- year, month and day are not important.
	local timestring = minetest.settings:get("autoshutdown.time")
	if not timestring then
		minetest.log("warning", "[autoshutdown] Disabling autoshutdown because shutdown time is not set in minetest.conf.")
		return
	end
	shutdown_time.hour, shutdown_time.min = string.match(timestring, "(%d%d):(%d%d)")
	shutdown_time.hour, shutdown_time.min  = tonumber(shutdown_time.hour), tonumber(shutdown_time.min)
	if not shutdown_time.hour or not shutdown_time.min then
		minetest.log("error", "[autoshutdown] Invalid time format in minetest.conf.")
		return
	end

	if os.date("%H:%M") == os.date("%H:%M", os.time(shutdown_time) - 10 * 60) then
		minetest.chat_send_all("Info: le serveur va redémarrer dans 10 minutes.")
	elseif os.date("%H:%M") == os.date("%H:%M", os.time(shutdown_time) - 5 * 60) then
		minetest.chat_send_all("Info: le serveur va redémarrer dans 5 minutes.")
	elseif os.date("%H:%M") == os.date("%H:%M", os.time(shutdown_time) - 60) then
		minetest.chat_send_all("Info: le serveur va redémarrer dans une minute.")
	elseif os.date("%H:%M") == os.date("%H:%M", os.time(shutdown_time)) then
		error("Redémarrage nocturne")
	end
end)
