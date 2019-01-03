minetest.register_privilege("physio_admin", {description="admin physio_stress options"})


minetest.register_chatcommand("psreset", {
	privs = {
		physio_admin = true
	},
	description = "Reset the counter for sunburn/nyctophoby protection",
	func = function(name, param)
		local ps=physio_stress.player[name]
		if ps==nil then return end
		ps.sunburn_delay=physio_stress.default_player.sunburn_delay
		ps.nyctophoby_delay=physio_stress.default_player.nyctophoby_delay
		ps.sunburn_protect=true
		ps.nyctophoby_protect=true
		minetest.chat_send_player(name, "All Attributs resetted")
	end
})
