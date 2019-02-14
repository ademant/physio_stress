minetest.register_globalstep(function(dtime)
	physio_stress.dt=physio_stress.dt+dtime
	physio_stress.dt_heal=physio_stress.dt_heal+dtime
--	print("dtime "..dtime)
	if physio_stress.dt > physio_stress.dtime then
--		print("ping")
		local starttime=os.clock()
		physio_stress.dt=0
		physio_stress.dtime=tonumber(minetest.settings:get(physio_stress.intprefix..".dtime")) or 1
		physio_stress.dtime=math.max(0.1,physio_stress.dtime+(math.random(1,3)-2)/10) -- random time between global steps
		local players = minetest.get_connected_players()
		for i=1, #players do
			local player=players[i]
			local name = player:get_player_name()
			local ps=physio_stress.player[name]
			if ps["disabled"] == nil then --check if player is disabled (dies, left etc.)
				local act_pos=player:get_pos()
				local act_light=minetest.get_node_light(act_pos)
				local player_armor=0
				if armor ~= nil then -- fail back to check if 3d_armor is used
					local player_armor=armor.def[name].count
				end
				local act_node=minetest.get_node(act_pos)
				
				--sunburn/nyctophoby
				
				for i,attr in ipairs(physio_stress.phobies) do
					physio_stress.abm[attr](player)
					if xpfw.player_get_attribute(player,attr)>19 then
						minetest.chat_send_player(name,S("Beware of "..attr))
						player:set_hp( player:get_hp() - ps[attr.."_hp"] )
						xpfw.player_sub_attribute(player,attr,2)
					end
					if ps[attr.."_protect"] then
						ps[attr.."_delay"]=ps[attr.."_delay"]-dtime
						if ps[attr.."_delay"] < 0 then
							minetest.chat_send_player(name,S("no".." "..attr.." ".."protection"))
							ps[attr.."_protect"] = false
						end
					end
				end
				-- exhaustion
				if physio_stress.attributes.exhaustion then
					-- get max of speeds
					local no_speeds=0
					local exh=0
					for i,attr in ipairs(physio_stress.action_names) do --swam, walk etc.
						local aspeed=xpfw.player_get_attribute(player,"mean_"..attr.."_speed")
						if aspeed ~= nil then
							if aspeed > 0 then
								no_speeds=no_speeds+1
								exh=exh+aspeed*aspeed
							end
						end
					end
					if no_speeds>0 then
						exh=math.sqrt(exh)
					else
						exh = 0
					end
					-- if one speed excel actual exhaustion level than set to max.
					xpfw.player_add_attribute(player,"exhaustion",exh)
					if xpfw.player_get_attribute(player,"exhaustion") > 19 then
						local ret = playereffects.apply_effect_type("exhausted", 60, player)
					end
					physio_stress.hud_update(player,"exhaustion",xpfw.player_get_attribute(player,"exhaustion"))
				end
				
				-- saturation/thirst
				
				for j,st in ipairs(physio_stress.ingestion) do -- call for saturation/thirst similar calls
					if physio_stress.attributes[st] then
						local dsat=0
						-- for each coefficient (walked, swam, dug, build, base consumption) the sum of saturation/thirst consumption is added
						for i,attr in ipairs(physio_stress.st_coeff_names) do
							local dref=ps[st.."_"..attr]
							if dref==nil then
								dref=physio_stress.default_player[st.."_"..attr]
							end
							if dref==nil then dref=1 end
	--						print(st.." "..attr.." "..math.max(0,(xpfw.player_get_attribute(player,attr)-ps[attr])/(dref)).." dref "..dref)
							dsat=dsat+math.max(0,(xpfw.player_get_attribute(player,attr)-ps[attr])/(dref))
						end
						if physio_stress.attributes.exhaustion then
							local dref=ps[st.."_exhaustion"]
							if dref==nil then
								dref=physio_stress.default_player[st.."_exhaustion"]
							end
							if dref==nil then dref=1 end
	--						print(st.." exhaustion "..math.max(0,(xpfw.player_get_attribute(player,"exhaustion")/dtime)/(dref)).." dref "..dref)
							dsat=dsat+math.max(0,(xpfw.player_get_attribute(player,"exhaustion")/dtime)/(dref))
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
	--					print(st.." "..dsat)
						xpfw.player_sub_attribute(player,st,math.min(dsat,xpfw.player_get_attribute(player,st)))
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
			end
			
		end
--	print("physio_stress_abm: "..1000*(os.clock()-starttime))
	end
	if physio_stress.dt_heal > physio_stress.dtime_heal then
		physio_stress.dt_heal = 0
		physio_stress.dtime_heal=tonumber(minetest.settings:get(physio_stress.intprefix..".dtime_heal")) or 1
		physio_stress.dtime_heal=math.max(0.1,physio_stress.dtime_heal+(math.random(1,3)-2)/10) -- random time between global steps
		local players = minetest.get_connected_players()
		for i=1, #players do
			local player=players[i]
			local name = player:get_player_name()
			local ps=physio_stress.player[name]
			if ps["disabled"] == nil then --check if player is disabled (dies, left etc.)
				local act_pos=player:get_pos()
				local act_node=minetest.get_node(act_pos)
			
				-- thirst recreation in water
				if physio_stress.attributes.thirst then
					if minetest.get_item_group(act_node.name,"water")>0 then
						if xpfw.player_get_attribute(player,"thirst")<physio_stress.thirstmax then
							if ps["drinking"] == nil then
								xpfw.player_add_attribute(player,"thirst",2)
								physio_stress.hud_update(player,"thirst",xpfw.player_get_attribute(player,"thirst"))
								ps["drinking"] = 1
							else
								ps["drinking"] = nil
							end
						end
					end
				end

				-- heal by saturation
				if physio_stress.attributes.saturation then
					local hp=player:get_hp()
					local sat=tonumber(xpfw.player_get_attribute(player,"saturation"))
					if hp<20 and sat>hp and sat >= physio_stress.saturation_minhealing then
						if ps["healing"] == nil then
							xpfw.player_sub_attribute(player,"saturation",2*physio_stress.saturation_recreation)
							physio_stress.hud_update(player,"saturation",xpfw.player_get_attribute(player,"saturation"))
							hp=hp+physio_stress.saturation_recreation
							player:set_hp(hp)
							ps["healing"] = 1
						else
							ps["healing"] = nil
						end
					end
				end

				-- saturation/thirst
				-- if saturation/thirst is zero, reduce health points
				for j,st in ipairs(physio_stress.ingestion) do -- call for saturation/thirst similar calls
					if physio_stress.attributes[st] then
						if xpfw.player_get_attribute(player,st)==0 then
							if ps["hp_"..st] == nil then
								player:set_hp(player:get_hp()-0.5)
								ps["hp_"..st] = 1
							else
								ps["hp_"..st] = nil
							end
						end
					end
				end
				
			end
		end
	end
end)
