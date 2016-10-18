local filepath = minetest.get_worldpath() .. "/announcement.txt"
local an_data = nil

local fh,err = io.open(filepath,'rb') -- use binary in case of UTF ?

if not err then
	an_data = fh:read("*a")
	fh:close()
else
	an_data = minetest.setting_get("motd") or ""
end
if an_data == "" then an_data = "<no message>" end

local fsn = formspeccer:newform("announcement:billboard","20,10")
formspeccer:add_textarea(fsn,{
	xy="1,1",
	wh="19,8",
	name="announce",
	label="Welcome!",
	value=an_data,
})

formspeccer:add_button(fsn,{name="submit",label="OK",xy="9,8",wh="2,1"},true)

minetest.register_on_joinplayer(function(player)
	minetest.after(0.5,function(...)
		formspeccer:show(player,fsn )
		minetest.debug(formspeccer:to_string(fsn))
	end)
end)
