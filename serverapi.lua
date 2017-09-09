umabis.serverapi = {}

local http = require("socket.http")

local function encode_post_body(params)
	local body = ""
	for k, v in pairs(params) do
		body = body .. k .. "=" .. v .. "&"
	end
	return body
end

local function do_request(post_get, command, params)
	local URI = umabis.settings:get("api_uri") .. command

	local body, code
	if post_get == "GET" then
		body, code = http.request(URI .. "?" .. encode_post_body(params))
	else
	 	body, code = http.request(URI, encode_post_body(params))
	end

	if not body then
		minetest.log("error", "[umabis] "..post_get.." request to server ("..URI..") failed: "..code)
		return false
	end
	if code ~= 200 then
		minetest.log("error", "[umabis] "..post_get.." request to server ("..URI..") returned a non-200 code: "..code)
		return false
	end

	local umabis_code = body:sub(1,3)
	local umabis_body = body:sub(4)

	return umabis_code, umabis_body
end

function umabis.serverapi.hello()
	local code, body = do_request("GET", "hello", {})
	if not code then
		return false
	end

	local server_params = minetest.parse_json(body)

	if not server_params or type(server_params) ~= "table" then
		return false
	end

	umabis.serverapi.params = {
		session_expiration_time = server_params.SESSION_EXPIRATION_TIME,
		version_string = server_params.VERSION,
		name = server_params.NAME
	}

	local major, minor, patch = string.match(server_params.VERSION, "(%d+)%.(%d+)%.(%d+)")
	umabis.serverapi.params.version_major = tonumber(major)
	umabis.serverapi.params.version_minor = tonumber(minor)
	umabis.serverapi.params.version_patch = tonumber(patch)

	if tonumber(major) ~= umabis.version_major then
		minetest.log("error", "[umabis] Server version is "..server_params.VERSION.." while my version is "..umabis.version_string..". "..
			"Different major versions are incompatible.")
		return false
	end

	if tonumber(minor) < umabis.version_minor then
		minetest.log("info", "[umabis] Server version is "..server_params.VERSION.." while my version is "..umabis.version_string..". "..
			"You should update me!")
	end

	if tonumber(minor) > umabis.version_minor then
		minetest.log("info", "[umabis] Server version is "..server_params.VERSION.." while my version is "..umabis.version_string..". "..
			"You should update the server!")
	end

	return true
end

-- FIXME: code redundancy

function umabis.serverapi.ping(name, token)
	local code, body = do_request("POST", "ping", {name = name, token = token})
	if not code then
		return false
	end
	if code == "012" then
		minetest.log("error", "[umabis] Command 'ping' failed: missing parameter.")
		return false, "Missing parameter."
	end

	umabis.session.update_last_sign_of_life(name)

	return true
end

function umabis.serverapi.is_registered(name, ip_address)
	local code, body = do_request("GET", "is_registered", {name = name, ip_address = ip_address})
	if not code then
		return false
	end
	if code == "012" then
		minetest.log("error", "[umabis] Command 'is_registered' failed: missing parameter.")
		return false, "Missing parameter."
	end

	return tonumber(body)
end

function umabis.serverapi.register(name, hash, email, is_email_public, language_main,
	language_fallback_1, language_fallback_2, ip_address)
	local code, body = do_request("POST", "register", {
		name = name,
		hash = hash,
		["e-mail"] = email,
		is_email_public = is_email_public and 1 or 0,
		language_main = language_main,
		language_fallback_1 = language_fallback_1,
		language_fallback_2 = language_fallback_2,
		ip_address = ip_address
	})

	if not code then
		return false
	end
	if code == "012" then
		minetest.log("error", "[umabis] Command 'register' failed: missing parameter.")
		return false, "012"
	end
	if code == "015" then
		minetest.log("error", "[umabis] Command 'register' failed: there is already an account with the same name.")
		return false, "015"
	end
	if code == "005" then
		minetest.log("error", "[umabis] Command 'register' failed: IP is blacklisted. Entry: "..body)
		return false, "005", minetest.parse_json(body)
	end

	return true
end

function umabis.serverapi.authenticate(name, hash, ip_address)
	local code, body = do_request("POST", "authenticate", {
		name = name,
		hash = hash,
		ip_address = ip_address
	})

	if not code then
		return false
	end
	if code == "012" then
		minetest.log("error", "[umabis] Command 'authenticate' failed: missing parameter.")
		return false, "012"
	end
	if code == "005" then
		minetest.log("error", "[umabis] Command 'authenticate' failed: IP is blacklisted. Entry: "..body)
		return false, "005", minetest.parse_json(body)
	end
	if code == "001" then
		minetest.log("error", "[umabis] Command 'authenticate' failed: user is not registered.")
		return false, "001"
	end
	if code == "002" then
		minetest.log("error", "[umabis] Command 'authenticate' failed: password does not match.")
		return false, "002"
	end
	if code == "003" then
		minetest.log("error", "[umabis] Command 'authenticate' failed: user is already authenticated.")
		return false, "003"
	end
	if code == "004" then
		minetest.log("error", "[umabis] Command 'authenticate' failed: more than 3 unsuccessful attemps to authenticate.")
		return false, "002"
	end

	umabis.session.update_last_sign_of_life(name)

	return body
end

function umabis.serverapi.close_session(name, token)
	local code, body = do_request("POST", "close_session", {name = name, token = token})

	if not code then
		return false
	end
	if code == "012" then
		minetest.log("error", "[umabis] Command 'close_session' failed: missing parameter.")
		return false, "012"
	end
	if code == "006" then
		minetest.log("error", "[umabis] Command 'close_session' failed: session token does not match.")
		return false, "006"
	end
	if code == "013" then
		minetest.log("error", "[umabis] Command 'close_session' failed: session expired.")
		return false, "013"
	end
	if code == "014" then
		minetest.log("error", "[umabis] Command 'close_session' failed: user is not authenticated.")
		return false, "014"
	end
end
