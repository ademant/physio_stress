minetest.register_globalstep(function(dtime)
	physio_stress.dt=physio_stress.dt+dtime
	if physio_stress.dt > physio_stress.dtime then
--		print("ping")
		physio_stress.dt=0
		local players = minetest.get_connected_players()
		for i=1, #players do
			local player=players[i]
			local name = player:get_player_name()
			local ps=physio_stress.player[name]
			local act_light=minetest.get_node_light(player:get_pos())
--			print(dump2(physio_stress.attributes))
			if physio_stress.attributes.sunburn and act_light then
				local player_meanlight=xpfw.player_get_attribute(player,"meanlight")
				print("sunburn: "..(act_light-player_meanlight))
				if ((act_light-player_meanlight)>ps.sunburn_diff) then
					player:set_hp( player:get_hp() - ps.sunburn_hp )
				end
			end
			if physio_stress.attributes.nyctophoby and act_light then
				local player_meanlight=xpfw.player_get_attribute(player,"meanlight")
				print("nycto: "..(player_meanlight-act_light))
				if ((player_meanlight-act_light)>ps.nyctophoby_diff) then
					player:set_hp( player:get_hp() - ps.nyctophoby_hp )
				end
			end
			if physio_stress.attributes.exhaustion then
				local exh=math.max(xpfw.player_get_attribute(player,"swam_mean_weight"),
							xpfw.player_get_attribute(player,"walked_mean_weight"),
							xpfw.player_get_attribute(player,"dig_mean_weight"),
							xpfw.player_get_attribute(player,"build_mean_weight") )
--				physio_stress.hud_update(player,"exhaustion")
			end
		end
	end
end)
