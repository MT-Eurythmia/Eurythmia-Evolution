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
	local URI = umabis.settings():get("api_uri") .. command

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
		version_string = server_params.VERSION
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
