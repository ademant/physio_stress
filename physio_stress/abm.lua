minetest.register_globalstep(function(dtime)
	physio_stress.dt=physio_stress.dt+dtime
	if physio_stress.dt > physio_stress.dtime then
		local starttime=os.clock()
		physio_stress.dt=0
		local players = minetest.get_connected_players()
		for i=1, #players do
			local player=players[i]
			local name = player:get_player_name()
			local ps=physio_stress.player[name]
			local act_pos=player:get_pos()
			local act_light=minetest.get_node_light(act_pos)
			local player_armor=armor.def[name].count
			local act_node=minetest.get_node(act_pos)
			
			--sunburn/nyctophoby
			if act_light ~= nil then
				local player_meanlight=xpfw.player_get_attribute(player,"meanlight")
				if act_light > player_meanlight then
					-- act light bigger than player meanlight: check for sunburn
					if not ps.sunburn_protect then
						local sudiff=ps.sunburn_diff
						if player_armor>0 then
							sudiff=sudiff/ps.sunburn_armor
						end
						if ((act_light-player_meanlight)>sudiff) then
							print(act_light,player_meanlight,sudiff,name)
							xpfw.player_add_attribute(player,"sunburn",1)
						end
					end
					-- regeneratr from nyctophoby
					if xpfw.player_get_attribute(player,"nyctophoby")>1 then
						xpfw.player_sub_attribute(player,"nyctophoby",1)
					end
				else
					-- act light smaller than player meanlight: check for nyctophoby
					if not ps.nyctophoby_protect then
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
							local nydiff=ps.nyctophoby_diff
							if player_armor>0 then
								nydiff=nydiff/ps.nyctophoby_armor
							end
							if ((player_meanlight-act_light)>nydiff) then
								print(act_light,player_meanlight,nydiff,name)
								xpfw.player_add_attribute(player,"nyctophoby",1)
							end
						end
					end
					-- regenerate from sunburn
					if xpfw.player_get_attribute(player,"sunburn")>1 then
						xpfw.player_sub_attribute(player,"sunburn",1)
					end
				end
			end
			-- count down then sunburn protection;
			if ps.sunburn_protect then
				ps.sunburn_delay=ps.sunburn_delay - dtime
				if ps.sunburn_delay < 0 then
					ps.sunburn_protect = false
				end
			end
			-- count down then nyctophoby protection;
			if ps.nyctophoby_protect then
				ps.nyctophoby_delay=ps.nyctophoby_delay - dtime
				if ps.nyctophoby_delay < 0 then
					minetest.chat_send_player(name,"no sunburn/nycto protection")
					ps.nyctophoby_protect = false
				end
			end
			for i,attr in ipairs({"sunburn","nyctophoby"}) do
				if xpfw.player_get_attribute(player,attr)>19 then
					minetest.chat_send_player(name,"Beware of "..attr)
					player:set_hp( player:get_hp() - ps[attr.."_hp"] )
				end
			end
			-- exhaustion
			if physio_stress.attributes.exhaustion then
				-- get max of speeds
				local exh=math.max(xpfw.player_get_attribute(player,"mean_swam_speed"),
							xpfw.player_get_attribute(player,"mean_walked_speed"),
							xpfw.player_get_attribute(player,"mean_dig_speed"),
							xpfw.player_get_attribute(player,"mean_craft_speed"),
							xpfw.player_get_attribute(player,"mean_build_speed") )
				local act_exh=xpfw.player_get_attribute(player,"exhaustion")
				-- if one speed excel actual exhaustion level than set to max.
				if (exh > act_exh) then
					xpfw.player_set_attribute(player,"exhaustion",exh)
				elseif (act_exh > 0) and (act_exh-exh)>=1 then
					xpfw.player_sub_attribute(player,"exhaustion",1)
				end
				if exh > 18 then
					local ret = playereffects.apply_effect_type("exhausted", 60, player)
				end
				physio_stress.hud_update(player,"exhaustion",xpfw.player_get_attribute(player,"exhaustion"))
			end
			
			-- saturation/thirst
			
			for j,st in ipairs({"saturation","thirst"}) do -- call for saturation/thirst similar calls
				local dsat=0
				-- for each coefficient (walked, swam, dug, build, base consumption) the sum of saturation/thirst consumption is added
				for i,attr in ipairs(physio_stress.st_coeff_names) do
					local dref=ps[st.."_"..attr]
					if dref==nil then
						dref=physio_stress.default_player[st.."_"..attr]
					end
					if dref==nil then dref=1 end
					dsat=dsat+math.max(0,(xpfw.player_get_attribute(player,attr)-ps[attr])/(dref))
				end
				
				-- small corrections due to hardness of dug nodes (by group stage): harder stones need more energy
				local dref=ps[st.."_dug"]
				if dref==nil then
					dref=physio_stress.default_player[st.."_dug"]
				end
				for i,attr in ipairs(physio_stress.dig_groups) do
					local correction=physio_stress.dig_correction[attr] or 1
					dsat=dsat+math.max(0,(ps[attr]*correction)/(3*dref))
				end
				-- if player has enough saturation/thirst, this is reduced
				if xpfw.player_get_attribute(player,st)>dsat then
					xpfw.player_sub_attribute(player,st,dsat)
					physio_stress.hud_update(player,st,xpfw.player_get_attribute(player,st))

				else
				-- otherwise hitpoints are reduced
					local hp=player:get_hp()-0.5
					player:set_hp(hp)
				end
			end
			
			-- actuall stats are copied
			for i,attr in ipairs(physio_stress.st_coeff_names) do
				local patt=xpfw.player_get_attribute(player,attr)
				if patt ~= nil then
					ps[attr]=patt
				end
			end
			-- dig groups are resetted
			for i,attr in ipairs(physio_stress.dig_groups) do
				ps[attr]=0
			end
			
			-- heal by saturation
			local hp=player:get_hp()
			local sat=tonumber(xpfw.player_get_attribute(player,"saturation"))
			if hp<20 and sat>hp then
				xpfw.player_sub_attribute(player,"saturation",2*physio_stress.saturation_recreation)
				physio_stress.hud_update(player,"saturation",xpfw.player_get_attribute(player,"saturation"))
				hp=hp+physio_stress.saturation_recreation
				player:set_hp(hp)
			end
			
			-- thirst recreation in water
			if minetest.get_item_group(act_node.name,"water")>0 then
				if xpfw.player_get_attribute(player,"thirst")<physio_stress.thirstmax then
					xpfw.player_add_attribute(player,"thirst",2)
					physio_stress.hud_update(player,"thirst",xpfw.player_get_attribute(player,"thirst"))
				end
			end
		end
--	print("physio_stress_abm: "..1000*(os.clock()-starttime))
	end
end)
