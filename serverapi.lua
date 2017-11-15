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

local error_codes = {
	["001"] = "user is not registered",
	["002"] = "password hash does not match",
	["003"] = "user is already authenticated",
	["004"] = "more than 3 unsuccessful authentication attemps in last 30 minutes",
	["005"] = "user is blacklisted",
	["006"] = "name and token do not match",
	["007"] = "user e-mail is not public",
	["008"] = "unsufficient privileges",
	["009"] = "requested nick does not exist",
	["010"] = "user already (not) blacklisted/whitelisted",
	["011"] = "invalid category",
	["012"] = "missing parameter",
	["013"] = "session expired",
	["014"] = "user is not authenticated",
	["015"] = "name already registered",
	["016"] = "blacklisting a whitelisted user/whitelisting a blacklisted user"
}

local function check_code(code, command)
	if not code then
		umabis.errstr = "no code returned"
		minetest.log("error", "[umabis] No code returned after serverapi command "..command)
		return false, "No code returned. This is a bug. Please contact the server administrator."
	end

	if error_codes[code] then
		umabis.errstr = error_codes[code]
		minetest.log("warning", "[umabis] Command '"..command.."' failed: "..error_codes[code])
		return false, string.gsub(error_codes[code], "^%l", string.upper)
	end

	return true
end

function umabis.serverapi.hello()
	local code, body = do_request("GET", "hello", {})
	local ret, e = check_code(code, "hello")
	if not ret then
		return ret, e
	end

	local server_params = minetest.parse_json(body)

	if not server_params or type(server_params) ~= "table" then
		return false
	end

	umabis.serverapi.params = {
		session_expiration_time = server_params.SESSION_EXPIRATION_TIME,
		version_string = server_params.VERSION,
		name = server_params.NAME,
		available_blacklist_categories = server_params.AVAILABLE_BLACKLIST_CATEGORIES
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

function umabis.serverapi.ping(name, token)
	local code, body = do_request("POST", "ping", {name = name, token = token})
	local ret, e = check_code(code, "ping")
	if not ret then
		return ret, e
	end

	umabis.session.update_last_sign_of_life(name)

	return true
end

function umabis.serverapi.is_registered(name, ip_address)
	local code, body = do_request("GET", "is_registered", {name = name, ip_address = ip_address})
	local ret, e = check_code(code, "is_registered")
	if not ret then
		return ret, e
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

	return check_code(code, "register")
end

function umabis.serverapi.authenticate(name, hash, ip_address)
	local code, body = do_request("POST", "authenticate", {
		name = name,
		hash = hash,
		ip_address = ip_address
	})

	local ret, e = check_code(code, "authenticate")
	if not ret then
		return ret, e
	end

	umabis.session.update_last_sign_of_life(name)

	return body
end

function umabis.serverapi.close_session(name, token)
	local code, body = do_request("POST", "close_session", {name = name, token = token})

	return check_code(code, "close_session")
end

function umabis.serverapi.blacklist_user(name, token, blacklisted_name, reason, category, time)
	local code, body = do_request("POST", "blacklist_user", {name = name, token = token, blacklisted_name = blacklisted_name, reason = reason, category = category, time = time})

	return check_code(code, "blacklist_user")
end
