local sessions = {}

local function unpriv(name)
	sessions[name].old_privs = minetest.get_player_privs(name)
	minetest.set_player_privs(name, minetest.string_to_privs(umabis.settings:get("auth_privs")))

	local player = minetest.get_player_by_name(name)
	sessions[name].old_physics_override = player:get_physics_override()
	player:set_physics_override({
		speed = 0,
		jump = 0
	})
end

local function priv_back(name)
	minetest.set_player_privs(name, sessions[name].old_privs)
	sessions[name].old_privs = nil
	minetest.get_player_by_name(name):set_physics_override(sessions[name].old_physics_override)
	sessions[name].old_physics_override = nil
end

local function create_session(name)
	unpriv(name)
	minetest.show_formspec(name, "umabis:welcome", string.format(umabis.formspecs.welcome, name))
end

local function authenticate(name)
	local token = umabis.serverapi.authenticate(name, minetest.get_auth_handler().get_auth(name).password, sessions[name].ip_address)
	-- TODO: error handling
	sessions[name].token = token
	minetest.log("action", "[umabis] Player "..name.." was successfully authenticated.")
end

local function register(name)
	umabis.serverapi.register(name, minetest.get_auth_handler().get_auth(name).password, sessions[name].email,
		sessions[name].is_email_public, sessions[name].ip_address)
	-- TODO: error handling
	authenticate(name)
	priv_back(name)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()

	if not string.find(formname, ":") then
		formname = "umabis:" .. formname
	end

	if formname == "umabis:welcome" then
		if fields.continue then
			sessions[name].is_email_public = true
			minetest.show_formspec(name, "umabis:provide_info", umabis.formspecs.provide_info)
		elseif fields.exit then
			minetest.kick_player(name, "Exiting.")
			-- Session will be cleared in the on_leaveplayer callback.
		else
			minetest.after(0.2, minetest.show_formspec, name, "umabis:welcome", string.format(umabis.formspecs.welcome, name))
		end
	elseif formname == "umabis:provide_info" then
		if fields.is_email_public then
			sessions[name].is_email_public = fields.is_email_public == "true"
		elseif fields.continue then
			sessions[name].email = fields.email
			sessions[name].language_main = fields.language_main
			sessions[name].language_fallback_1 = fields.language_fallback_1
			sessions[name].language_fallback_2 = fields.language_fallback_2

			register(name)

			minetest.show_formspec(name, "umabis:registration_done", umabis.formspecs.registration_done)
		elseif fields.exit then
			minetest.kick_player(name, "Exiting.")
			-- Session will be cleared in the on_leaveplayer callback.
		else
			minetest.after(0.2, minetest.show_formspec, name, "umabis:provide_info", umabis.formspecs.provide_info)
		end
	end
end)

umabis.register_on_reload(function()
	umabis.session = {}
	umabis.session.sessions = sessions

	function umabis.session.prepare_session(name, ip_address)
		sessions[name] = {
			ip_address = ip_address
		}
	end

	function umabis.session.new_session(name)
		local session = sessions[name]

		if not session then
			minetest.kick_player(name, "Sorry, it seems that your Umabis session was not prepared. This is a bug. Use the latest version of Minetest and contact the server administrator (their nick is "..minetest.settings:get("name")..").")
		end

		local is_registered = umabis.serverapi.is_registered(name, session.ip_address)
		if is_registered == 0 then
			create_session(name)
		else
			authenticate(name)
		end
	end

	function umabis.session.clear_session(name)
		if sessions[name].token then
			umabis.serverapi.close_session(name, sessions[name].token)
		end
		sessions[name] = nil
	end

	function umabis.session.clear_all()
		for name, _ in pairs(sessions) do
			umabis.session.clear_session(name)
		end
	end

	function umabis.session.set_password(name, password)
		-- FIXME: Unimplemented
	end


	-- Pinging
	function umabis.session.update_last_sign_of_life(name)
		sessions[name].last_sign_of_life = os.time()
	end

	do
		local ping_interval = tonumber(umabis.settings:get("ping_interval"))
		if not ping_interval or ping_interval == 0 then
			ping_interval = math.max(umabis.serverapi.params.session_expiration_time * 2/3, umabis.serverapi.params.session_expiration_time - 60)
		end
		umabis.session.ping_interval = ping_interval
	end
end)

local time_count = 0
minetest.register_globalstep(function(dtime)
	-- Execute the globalstep every second only.
	time_count = time_count + dtime
	if time_count < 1 then
		return
	end
	time_count = 0

	local current_time = os.time()
	for name, t in pairs(sessions) do
		if t.token and t.last_sign_of_life + umabis.session.ping_interval <= current_time then
			minetest.log("info", "[umabis] Pinging for session "..name)
			umabis.serverapi.ping(name, sessions[name].token)
		end
	end
end)
