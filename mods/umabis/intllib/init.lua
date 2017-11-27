if not umabis.settings:get_bool("enable_intllib") then
	return
end

dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/intllib/init.lua")

if not debug or not debug.getupvalue or not debug.setupvalue then
	minetest.log("error", "[umabis_intllib] Intllib support requires upvalue management methods (debug.getupvalue, debug.setupvalue)")
	return
end

intllib.umabis = {}

local old_make_gettext_pair = intllib.make_gettext_pair

--- Get the upvalues indexes ---

local index_gettext_getters
local i = 1
while true do
	local name, _ = debug.getupvalue(old_make_gettext_pair, i)
	if not name then
		break
	end
	if name == "gettext_getters" then
		index_gettext_getters = i
	end

	i = i + 1
end

local index_get_locales
local old_get_locales
i = 1
while true do
	local name, value = debug.getupvalue(intllib.get_strings, i)
	if not name then
		break
	end
	if name == "get_locales" then
		index_get_locales = i
		old_get_locales = value
	end

	i = i + 1
end

if not index_gettext_getters or not index_get_locales then
	minetest.log("error", "[umabis_intllib] Umabis didn't succeed to get the indexes of some upvalues. Try to update both umabis and intllib.")
	return
end

--- Override get_locales ---

local function new_get_locales(code)
	if not intllib.umabis.playername then
		return old_get_locales(code)
	end
	local playername = intllib.umabis.playername

	-- Get player language
	local ok, user_info = umabis.serverapi.get_user_info(playername, umabis.session.sessions[playername].token, playername)
	if not ok then
		minetest.log("error", "[umabis_intllib] No able to get user info of player: "..playername)
		return old_get_locales(code)
	end

	return {user_info.language_main, user_info.language_fallback_1, user_info.language_fallback_2, "en"}
end

debug.setupvalue(intllib.get_strings, index_get_locales, new_get_locales)

--- Override intllib.make_gettext_pair ---

function intllib.make_gettext_pair(modname)
	modname = modname or minetest.get_current_modname()
	local fb_gettext, fb_ngettext = old_make_gettext_pair(modname)

	local function gettext_func(msgid, ...)
		intllib.umabis.buffer = {func = "gettext", msgid = msgid, params = {...}, modname = modname, time = os.time(), expected = fb_gettext(msgid, ...)}
		return intllib.umabis.buffer.expected
	end
	local function ngettext_func(msgid, ...)
		intllib.umabis.buffer = {func = "ngettext", msgid = msgid, params = {...}, modname = modname, time = os.time(), expected = fb_ngettext(msgid, ...)}
		return intllib.umabis.buffer.expected
	end

	return gettext_func, ngettext_func
end

--- Override intllib.Getter (deprecated) ---

function intllib.Getter(modname)
	local gettext, ngettext = intllib.make_gettext_pair(modname)
	return gettext
end

--- Override minetest.chat_send_player ---

local old_minetest_chat_send_player = minetest.chat_send_player
function minetest.chat_send_player(name, msg)
	if not intllib.umabis.buffer
		or intllib.umabis.buffer.expected ~= msg
		or intllib.umabis.buffer.time + 1 < os.time() then

		intllib.umabis.buffer = nil
		return old_minetest_chat_send_player(name, msg)
	end

	intllib.umabis.playername = name

	local _, cache_gettext_getters = debug.getupvalue(old_make_gettext_pair, index_gettext_getters)
	local cache_strings = intllib.strings
	intllib.strings = {}
	local cache_getters = intllib.getters
	intllib.getters = {}
	debug.setupvalue(old_make_gettext_pair, index_gettext_getters, {})
	local gettext, ngettext = old_make_gettext_pair(intllib.umabis.buffer.modname)
	debug.setupvalue(old_make_gettext_pair, index_gettext_getters, cache_gettext_getters)
	intllib.strings = cache_strings
	intllib.getters = cache_getters

	local func, msgid, params = intllib.umabis.buffer.func, intllib.umabis.buffer.msgid, intllib.umabis.buffer.params

	if not intllib.umabis.buffer.no_unset then
		intllib.umabis.buffer = nil
	end

	if func == "gettext" then
		return old_minetest_chat_send_player(name, gettext(msgid, unpack(params)))
	else
		return old_minetest_chat_send_player(name, ngettext(msgid, unpack(params)))
	end
end

--- Override minetest.chat_send_all ---

local old_minetest_chat_send_all = minetest.chat_send_all
function minetest.chat_send_all(msg)
	if not intllib.umabis.buffer
		or intllib.umabis.buffer.expected ~= msg
		or intllib.umabis.buffer.time + 1 < os.time()
		or intllib.umabis.buffer.modname ~= minetest.get_current_modname() then

		intllib.umabis.buffer = nil
		return old_minetest_chat_send_all(msg)
	end

	intllib.umabis.buffer.no_unset = true

	local players = minetest.get_connected_players()
	for _, player in ipairs(players) do
		-- Overriden function
		minetest.chat_send_player(player:get_player_name(), msg)
	end

	intllib.umabis.buffer = nil
end
