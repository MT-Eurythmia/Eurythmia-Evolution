if not minetest.settings:get_bool("disallow_empty_password") then
	minetest.settings:set_bool("disallow_empty_password", true)
end

local umabis_auth_handler = table.copy(core.builtin_auth_handler)
umabis_auth_handler.set_password = function(name, password)
	if not umabis.session.set_password(name, password) then
		return false
	end

	if not core.builtin_auth_handler.set_password(name, password) then
		-- Revert any chagne
		umabis.session.set_password(name, minetest.get_auth_handler().get_auth(name).password)
		return false
	end

	return true
end

minetest.register_authentication_handler(umabis_auth_handler)
