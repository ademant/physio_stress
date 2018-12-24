minetest.register_globalstep(function(dtime)
	physio_stress.dt=physio_stress.dt+dtime
	if physio_stress.dt > physio_stress.dtime then
		physio_stress.dt=0
		local players = minetest.get_connected_players()
		for i=1, #players do
			local player=players[i]
			local name = player:get_player_name()
			local ps=physio_stress.player[name]
			local act_pos=player:get_pos()
			local act_light=minetest.get_node_light(act_pos)
			local player_armor=armor.def[name].count
			if physio_stress.attributes.sunburn and act_light then
				local player_meanlight=xpfw.player_get_attribute(player,"meanlight")
--				print("sunburn: "..(act_light-player_meanlight))
				if ((act_light-player_meanlight)>ps.sunburn_diff) then
					local diff_hp=ps.sunburn_hp
					if player_armor>0 then
						diff_hp=diff_hp*ps.sunburn_armor
					end
					player:set_hp( player:get_hp() - diff_hp )
				end
			end
			if physio_stress.attributes.nyctophoby and act_light then
				local node=minetest.get_node(act_pos)
				if node.name == "water" then
					local bair=true
					local dist=5
					while bair do
						node=minetest.find_node_near(act_pos,dist,"air")
						if node==nil then
							dist=math.ceil(1.5*dist)
						else
							bair=false
							act_light=minetest.get_node_light(node)
						end
						if dist>50 then bair=false end
					end
				end
				if node ~= nil then
					local player_meanlight=xpfw.player_get_attribute(player,"meanlight")
					print("nycto: "..(player_meanlight-act_light))
					if ((player_meanlight-act_light)>ps.nyctophoby_diff) then
						local diff_hp=ps.nyctophoby_hp
						if player_armor>0 then
							diff_hp=diff_hp*ps.nyctophoby_armor
						end
						player:set_hp( player:get_hp() - diff_hp )
--						player:set_hp( player:get_hp() - ps.nyctophoby_hp )
					end
				end
			end
			if physio_stress.attributes.exhaustion then
				local exh=math.max(xpfw.player_get_attribute(player,"mean_swam_speed"),
							xpfw.player_get_attribute(player,"mean_walked_speed"),
							xpfw.player_get_attribute(player,"mean_dig_speed"),
							xpfw.player_get_attribute(player,"mean_build_speed") )
				print("exhaust "..exh)
				print(xpfw.player_get_attribute(player,"mean_swam_speed"),
							xpfw.player_get_attribute(player,"mean_walked_speed"),
							xpfw.player_get_attribute(player,"mean_dig_speed"),
							xpfw.player_get_attribute(player,"mean_build_speed"))
				physio_stress.hud_update(player,exh)
			end
		end
	end
end)
