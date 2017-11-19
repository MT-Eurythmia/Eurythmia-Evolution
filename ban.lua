if not umabis.settings:get_bool("enable_local_ban") then
	return
end

umabis.ban = {}
local db

do
	local f, err = io.open(minetest.get_worldpath() .. "/umabis_bandb.json", "r")
	if not f then
		-- Create the file and try again
		f, err = io.open(minetest.get_worldpath() .. "/umabis_bandb.json", "w")
		if not f then
			minetest.log("error", "[umabis] Error while opening the umabis_bandb.json file: " .. err)
			return false
		end
		f, err = io.open(minetest.get_worldpath() .. "/umabis_bandb.json", "r")
	end

	local json_db = f:read("*a")

	f:close()

	if json_db == "" or json_db == "null\n" then
		db = {ips = {}, bans = {}}
	else
		db = minetest.parse_json(json_db)
		if not db then
			minetest.log("error", "[umabis] Error while parsing the JSON ban database.")
			return false
		end
	end

	db.ips = db.ips or {}
	db.bans = db.bans or {}

	umabis.ban.db = db
end

function umabis.ban.save_db()
	local json_db = minetest.write_json(db, true)
	if not json_db then
		minetest.log("error", "[umabis] Error while writing the JSON ban database.")
		return false
	end

	local f, err = io.open(minetest.get_worldpath() .. "/umabis_bandb.json", "w")
	if not f then
		minetest.log("error", "[umabis] Error while opening the umabis_bandb.json file: " .. err)
		return false
	end

	f:write(json_db)
	f:close()
	return true
end

-- This function returns a table of references.
-- Modifying the return value will modify the database.
-- Don't forget to call umabis.ban.save_db(), though.
function umabis.ban.get_entry(nick_or_ip)
	local entries = {}
	for _, entry in ipairs(db.bans) do
		if entry.nicks[nick_or_ip] then
			table.insert(entries, entry)
		elseif entry.ips[nick_or_ip] then
			table.insert(entries, entry)
		end
	end

	if #entries == 0 then
		return nil
	else
		return entries
	end
end

function umabis.ban.ban_players(source_mod, nicks, ips, reason, drastic, time)
	local entry = {nicks = {}, ips = {}, reason = reason, drastic = drastic, source_mod = source_mod}
	if time then
		entry.exp_time = os.time() + time
	end

	local n_nick = 0
	local n_ip = 0
	local out_str = ""
	for nick, _ in pairs(nicks) do
		if umabis.ban.get_entry(nick) then
			out_str = out_str .. "Warning: nick '" .. nick .. "' is already banned\n"
		elseif minetest.check_player_privs(nick, "ban") then
			out_str = out_str .. "Warning: player '" .. nick .. "' has the ban privilege. Please revoke him the ban privilege first\n"
		else
			entry.nicks[nick] = true
			n_nick = n_nick + 1
			if umabis.ban.db.ips[nick] then
				for ip, _ in pairs(umabis.ban.db.ips[nick]) do
					entry.ips[ip] = true
					n_ip = n_ip + 1
				end
			end
		end
	end
	for ip, _ in pairs(ips) do
		if umabis.ban.get_entry(ip) then
			out_str = out_str .. "Warning: IP address '" .. ip .. "' is already banned\n"
		else
			entry.ips[ip] = true
			n_ip = n_ip + 1
		end
	end

	if n_nick == 0 and n_ip == 0 then
		out_str = out_str .. "0 nick and 0 IP address banned, no new entry created."
		return false, out_str
	else
		table.insert(db.bans, entry)
		out_str = out_str .. n_nick .. " nick(s) and " .. n_ip .. " IP address(es) banned until " .. (entry.exp_time and os.date("%c", entry.exp_time) or "the end of times")
		umabis.ban.save_db()
		return true, out_str
	end
end

function umabis.ban.unban_player(nick_or_ip)
	local n = 0
	local out_str = ""
	for i, entry in ipairs(db.bans) do
		if entry.nicks[nick_or_ip] then
			table.remove(db.bans, i)
			out_str = out_str .. "Unbanned nick " .. nick_or_ip
			n = n + 1
		elseif entry.ips[nick_or_ip] then
			table.remove(db.bans, i)
			n = n + 1
			out_str = out_str .. "Unbanned IP " .. nick_or_ip
		end
	end

	if n == 0 then
		return false, "Nick or IP is not banned"
	elseif n > 1 then
		umabis.ban.save_db()
		return true, out_str .. "\nWarning: more than one corresponding entries found"
	else
		umabis.ban.save_db()
		return true, out_str
	end
end

function umabis.ban.add_ip_to_nick(name, ip)
	if not db.ips[name] then
		db.ips[name] = {}
	end
	db.ips[name][ip] = true
	umabis.ban.save_db()
end

function umabis.ban.on_prejoinplayer(name, ip)
	umabis.ban.add_ip_to_nick(name, ip)

	if minetest.check_player_privs(name, "ban") then
		return
	end

	local entry = umabis.ban.get_entry(name) or umabis.ban.get_entry(ip)
	if entry then
		entry = entry[1] -- We suppose that there is only one entry. If there are many, it's a bug.
		if entry.drastic and not minetest.check_player_privs(name, "ban") then
			entry.nicks[name] = true
			entry.ips[ip] = true
			umabis.ban.save_db()
		end
		return "You are banned on this server.\n" .. umabis.ban.format_entry(name, entry)
	end
end

-- Small helper
function umabis.ban.format_entry(nick_or_ip, entry)
	local str = "Reason: " .. entry.reason
	       .. "\nUntil: " .. (entry.exp_time and os.date("%c", entry.exp_time) or "the end of times")
	       .. "\nDrastic: " .. (entry.drastic and "yes" or "no")

	if umabis.settings:get_bool("ban_show_source_moderator") then
       		str = str .. "\nBy moderator: " .. entry.source_mod
       	end

	str = str .. "\nAlong with: "
	local nobody = true
	for nick, _ in pairs(entry.nicks) do
		if nick ~= nick_or_ip then
			str = str .. nick .. ", "
			nobody = false
		end
	end
	for ip, _ in pairs(entry.ips) do
		if ip ~= nick_or_ip then
			str = str .. ip .. ", "
			nobody = false
		end
	end

	if nobody then
		str = str .. "nobody else, "
	end

	return str:sub(1, -3)
end
