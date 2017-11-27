if false then
	minetest.register_chatcommand("umabis_show_formspec", {
		description = "Displays a Umabis formspec",
		privs = {},
		params = "<formname>",
		func = function(name, param)
			minetest.show_formspec(name, param, umabis.formspecs[param])
		end
	})
end

umabis.register_on_reload(function()
	local languages_string = ""
	local en_id = 0

	local id = 1
	for line in io.lines(minetest.get_modpath("umabis").."/languages.txt") do
		languages_string = languages_string .. line .. ","
		if line == "en" then
			en_id = id
		end
		id = id + 1
	end
	languages_string = string.sub(languages_string, 1, -2)

	umabis.formspecs = {
		welcome = [[
size[8,2.5]
label[0,0;Welcome, %s! It seems this is the first time I see you :-)
I need to ask you a few questions to complete your registration before you can actually play.
You will need to do this only once to play on all servers connected the
]]..umabis.serverapi.params.name..[[ Umabis server.]
button_exit[1,2;2,1;continue;Continue]
button[5,2;2,1;exit;Abandon and exit]
]],
		provide_info = [[
size[8,7]
label[0,0;Please fill in the fields below.]
field[0.5,1;7,1;email;E-mail address (optional but highly recommended):;]
checkbox[0.5,1.5;is_email_public;Allow players to see your e-mail address;true]
label[0,2.5;Main language:]
dropdown[2,2.5;2;language_main;]]..languages_string..";"..en_id..[[]
label[0,3.5;The fallback languages are used if a translation is not available in your main language.
English is always the last fallback.]
label[0,4.5;Fallback language #1:]
dropdown[2,4.5;2;language_fallback_1;]]..languages_string..[[;0]
label[0,5.5;Fallback language #2:]
dropdown[2,5.5;2;language_fallback_2;]]..languages_string..[[;0]
button_exit[1,6.5;2,1;continue;Continue]
button[5,6.5;2,1;exit;Abandon and exit]
]],
		registration_done = [[
size[8,2.5]
label[0,0;Your registration is completed. Thank you! You can now play :-)
Remember that all your personal information, including your password, is shared between
all servers connected to the ]]..umabis.serverapi.params.name..[[ Umabis server.
This means that you will have to use the same password on all of those servers.]
button_exit[2.5,2;3,1;continue;Okay, let me play now :-)]
]]
	}
end)
