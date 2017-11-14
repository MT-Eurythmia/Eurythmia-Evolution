local commands_descriptors = {
	-- TODO: help
	blacklist = {
		params = 3,
		func = function(name, token, blacklisted_name, reason, category, time)
			-- Thanks xban2!
			local function parse_time(t) --> secs
				local unit_to_secs = {
					s = 1, m = 60, h = 3600,
					D = 86400, W = 604800, M = 2592000, Y = 31104000,
					[""] = 1,
				}

				local secs = 0
				for num, unit in t:gmatch("(%d+)([smhDWMY]?)") do
					secs = secs + (tonumber(num) * (unit_to_secs[unit] or 1))
				end
				return secs
			end

			print("Running the blacklist_user command")
			umabis.serverapi.blacklist_user(name, token, blacklisted_name, reason, category, time and parse_time(time))
			-- TODO: handle error during blacklist_user
		end
	}
}

minetest.register_chatcommand("umabis", {
	params = "<subcommand> [<subcommand parameters...>]",
	description = "Umabis chatcommand interface",
	privs = {},
	func = function(name, paramstr)
		local params = paramstr:split(" ")
		local subcmd = params[1]
		if not subcmd then
			return false, "Please specify a subcommand. Refer to /help umabis and /umabis help for help"
		end

		local scmd_dscptr = commands_descriptors[subcmd]
		if not scmd_dscptr then
			return false, "Invalid subcommand: "..subcmd..". See /umabis help for a list of available subcommands"
		end

		local scmd_params = {}
		local i = 2
		while i <= #params do
			-- Quotes-enclosed strings are treated as a single parameter
			if string.sub(params[i], 1, 1) == "\"" then
				local p = params[i]

				local j = i
				repeat
					j = j + 1
					if not params[j] then
						return false, "Unclosed quote"
					end
					p = p.." "..params[j]
				until string.sub(params[j], string.len(params[j])) == "\""

				table.insert(scmd_params, string.sub(p, 2, string.len(p)-1))
				i = j + 1
			else
				table.insert(scmd_params, params[i])
				i = i + 1
			end
		end

		if #scmd_params < scmd_dscptr.params then
			return false, "Subcommand "..subcmd.." requires at least "..scmd_dscptr.params.." parameters, given "..#scmd_params..". See /umabis help "..subcmd.." for help."
		end

		return scmd_dscptr.func(name, umabis.session.sessions[name].token, unpack(scmd_params))
	end
})

if umabis.register_on_reload then -- If first loading
	umabis.register_on_reload(function()
		minetest.unregister_chatcommand("umabis")
	end)
end
