local shutdown_time = {year=2000, month=1, day=1, hour=23, min=30} -- don't care about the year, month and day

local CHECK_INTERVAL = 60
local check_timer = 0

minetest.register_globalstep(function(dtime)
	check_timer = check_timer + dtime
	if check_timer < CHECK_INTERVAL then
		return
	end
	check_timer = 0

	if os.date("%H:%M") == os.date("%H:%M", os.time(shutdown_time) - 10 * 60) then
		minetest.chat_send_all("Info: the server will shutdown for power saving purposes in 10 minutes.")
		minetest.chat_send_all("Info: le serveur va s'arrêter dans un but d'économie d'énergie dans 10 minutes.")
	elseif os.date("%H:%M") == os.date("%H:%M", os.time(shutdown_time) - 5 * 60) then
		minetest.chat_send_all("Info: the server will shutdown for power saving purposes in 5 minutes.")
		minetest.chat_send_all("Info: le serveur va s'arrêter dans un but d'économie d'énergie dans 5 minutes.")
	elseif os.date("%H:%M") == os.date("%H:%M", os.time(shutdown_time) - 60) then
		minetest.chat_send_all("Info: the server will shutdown for power saving purposes in a minute.")
		minetest.chat_send_all("Info: le serveur va s'arrêter dans un but d'économie d'énergie dans une minute.")
	elseif os.date("%H:%M") == os.date("%H:%M", os.time(shutdown_time)) then
		minetest.request_shutdown("Le serveur s'arrête ce soir dans un but d'économie d'énergie jusqu'à demain matin à 8:30.\nThe server is shutting down until tomorrow 8:30 AM for power saving purposes. Sorry for the inconvenience.", false)
	end
end)
