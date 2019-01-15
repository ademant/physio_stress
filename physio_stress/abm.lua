minetest.register_globalstep(function(dtime)
	physio_stress.dt=physio_stress.dt+dtime
--	print("dtime "..dtime)
	if physio_stress.dt > physio_stress.dtime then
--		print("ping")
		local starttime=os.clock()
		physio_stress.dt=0
		physio_stress.dtime=math.random(3,7)/10 -- random time between global steps
		local players = minetest.get_connected_players()
		for i=1, #players do
			local player=players[i]
			local name = player:get_player_name()
			local ps=physio_stress.player[name]
			local act_pos=player:get_pos()
			local act_light=minetest.get_node_light(act_pos)
			local player_armor=0
			if armor ~= nil then -- fail back to check if 3d_armor is used
				local player_armor=armor.def[name].count
			end
			local act_node=minetest.get_node(act_pos)
			
			--sunburn/nyctophoby
			
			for i,attr in ipairs(physio_stress.phobies) do
				print(attr)
				physio_stress.abm[attr](player)
				if xpfw.player_get_attribute(player,attr)>19 then
					minetest.chat_send_player(name,"Beware of "..attr)
					player:set_hp( player:get_hp() - ps[attr.."_hp"] )
					xpfw.player_sub_attribute(player,attr,1)
				end
				if ps[attr.."_protect"] then
					ps[attr.."_delay"]=ps[attr.."_delay"]-dtime
					if ps[attr.."_delay"] < 0 then
						minetest.chat_send_player(name,"no "..attr.." protection")
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
					if xpfw.player_get_attribute(player,st)>dsat then
						xpfw.player_sub_attribute(player,st,dsat)
						physio_stress.hud_update(player,st,xpfw.player_get_attribute(player,st))

					else
					-- otherwise hitpoints are reduced
						minetest.chat_send_player(name,"Beware of "..st)
						if (xpfw.player_get_attribute(player,st)>1) then
							xpfw.player_set_attribute(player,st,1)
						end
						local hp=player:get_hp()-0.5
						player:set_hp(hp)
					end
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
			if physio_stress.attributes.saturation then
				local hp=player:get_hp()
				local sat=tonumber(xpfw.player_get_attribute(player,"saturation"))
				if hp<20 and sat>hp then
					xpfw.player_sub_attribute(player,"saturation",2*physio_stress.saturation_recreation)
					physio_stress.hud_update(player,"saturation",xpfw.player_get_attribute(player,"saturation"))
					hp=hp+physio_stress.saturation_recreation
					player:set_hp(hp)
				end
			end
			
			-- thirst recreation in water
			if physio_stress.attributes.thirst then
				if minetest.get_item_group(act_node.name,"water")>0 then
					if xpfw.player_get_attribute(player,"thirst")<physio_stress.thirstmax then
						xpfw.player_add_attribute(player,"thirst",2)
						physio_stress.hud_update(player,"thirst",xpfw.player_get_attribute(player,"thirst"))
					end
				end
			end
		end
--	print("physio_stress_abm: "..1000*(os.clock()-starttime))
	end
end)
