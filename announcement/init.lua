local filepath = minetest.get_worldpath() .. "/announcement.txt"
local an_data = nil
local fsn = "announcement:billboard"

local reload = function()
	local fh,err = io.open(filepath,'rb') -- use binary in case of UTF ?

	if not err then
		an_data = fh:read("*a")
		fh:close()
	else
		an_data = minetest.setting_get("motd") or ""
	end
	if an_data == "" then an_data = "<no message>" end

	formspeccer:clear(fsn)
	formspeccer:newform(fsn,"20,10")
	formspeccer:add_textarea(fsn,{
		xy="1,1",
		wh="19,8",
		name="announce",
		label="Welcome!",
		value=an_data,
	})

	formspeccer:add_button(fsn,{name="submit",label="OK",xy="9,8",wh="2,1"},true)
end

reload() -- call once to initialize

minetest.register_chatcommand("reannounce",{
	params = "",
	description = "reload the announcement message",
	privs = {server=true},
	func = function(playername,params)
		reload()
	end
})

minetest.register_chatcommand("announcement",{
	params = "",
	description = "Display the announcement message",
	func = function(playername,params)
		formspeccer:show(minetest.get_player_by_name(playername) ,fsn )
	end
})

minetest.register_on_joinplayer(function(player)
	minetest.after(0.5,function(...)
		formspeccer:show(player,fsn )
	end)
end)
