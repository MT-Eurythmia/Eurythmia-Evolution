if not minetest.settings:get_bool("disallow_empty_password") then
	minetest.settings:set_bool("disallow_empty_password", true)
end

local umabis_auth_handler = table.copy(core.builtin_auth_handler)
umabis_auth_handler.set_password = function(name, password)
	core.builtin_auth_handler.set_password(name, password)

	umabis.session.set_password(name, password)
	return true
end

minetest.register_authentication_handler(umabis_auth_handler)
