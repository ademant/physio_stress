minetest.register_globalstep(function(dtime)
	physio_stress.dt=physio_stress.dt+dtime
--	print("dtime "..dtime)
	if physio_stress.dt > physio_stress.dtime then
--		print("ping")
		local starttime=os.clock()
		physio_stress.dt=0
		local players = minetest.get_connected_players()
		for i=1, #players do
			local player=players[i]
			local name = player:get_player_name()
			local ps=physio_stress.player[name]
			local act_pos=player:get_pos()
			local act_light=minetest.get_node_light(act_pos)
--			print(dump2(act_pos))
--			print(act_light)
--			print(dump2(ps))
			local player_armor=0
			if armor ~= nil then -- fail back to check if 3d_armor is used
				local player_armor=armor.def[name].count
			end
			local act_node=minetest.get_node(act_pos)
			
			--sunburn/nyctophoby
			if act_light ~= nil then
				local player_meanlight=xpfw.player_get_attribute(player,"meanlight")
				if act_light > player_meanlight then
					-- act light bigger than player meanlight: check for sunburn
					if (not ps.sunburn_protect) and (physio_stress.sunburn) then
						local sudiff=ps.sunburn_diff
						local sumax=ps.sunburn_maxlight
						if player_armor>0 then
							sudiff=sudiff/ps.sunburn_armor
							sumax=sumax+ps.sunburn_armor_dmaxlight
						end
						-- sunburn is increased if:
						-- 1. Difference between actual light level and player mean light level is to high
						--    simulating the effect when going into full sunlight out of buildings and you can't see enything
						-- 2. Too high sun level with real sunburn; the threshold is increased by armor
						if ((act_light-player_meanlight)>sudiff) or (act_light > sumax) then
							xpfw.player_add_attribute(player,"sunburn",0.5)
							print("sunburn"..act_light,sudiff,sumax,player_meanlight,player_armor)
						end
					end
					-- regeneratr from nyctophoby
						xpfw.player_sub_attribute(player,"nyctophoby",1)
				else
					-- act light smaller than player meanlight: check for nyctophoby
					if (not ps.nyctophoby_protect) and (physio_stress.nyctophoby) then
						-- under water there is no light, so find the nearest air and get this light level
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
							print("dist"..dist)
						end
						if node ~= nil then
							local nydiff=ps.nyctophoby_diff
							local nymin=ps.nyctophoby_minlight
							if player_armor>0 then
								nydiff=nydiff/ps.nyctophoby_armor
							end
							-- nyctophoby is increased by:
							-- 1. Difference between actual light and players mean light
							--    simulating the effect when going into buildings from full sunlight
							-- 2. Too low level (hardcoded)
							if ((player_meanlight-act_light)>nydiff) or (act_light < nymin) then
								print("night"..act_light,player_meanlight,nydiff,name,nymin)
								xpfw.player_add_attribute(player,"nyctophoby",0.5)
							end
						end
					end
					-- regenerate from sunburn
						xpfw.player_sub_attribute(player,"sunburn",1)
				end
			end
			for i,attr in ipairs(physio_stress.phobies) do
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
			if physio_stress.attributes.exhaustion and physio_stress.exhaustion then
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
				if physio_stress[st] then
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
						minetest.chat_send_player(name,"Beware of "..st)
						local hp=player:get_hp()-0.5
						player:set_hp(hp)
					end
				end
			end
			
			-- actuall stats are copied
			for i,attr in ipairs(physio_stress.action_names) do
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
