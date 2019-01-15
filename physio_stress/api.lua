

function physio_stress.hud_clamp(value)
	if value == nil then
		return 20
	end
	return math.max(0,math.min(20,value))
end

function physio_stress.eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
	local item = itemstack:get_name()
	local def = minetest.registered_items[item]
	local thirst_change=minetest.get_item_group(item,"drinkable")
	if not def then
		def = {}
		if type(hp_change) ~= "number" then
			hp_change = 1
			core.log("error", "Wrong on_use() definition for item '" .. item .. "'")
		end
		def.saturation = hp_change * 1.3
		def.replace = replace_with_item
	else
		def={saturation=hp_change * 1.3,
			replace=replace_with_item,
			poisen = 0,
			healing = 0,
			sound="eat_generic",}
	end
	local func = physio_stress.item_eat(def.saturation, def.replace, def.poisen, def.healing, thirst_change,def.sound)
	return func(itemstack, user, pointed_thing)
end

function physio_stress.item_eat(hunger_change, replace_with_item, poisen, heal, thirst_change,sound)
--	print(hunger_change,thirst_change)
	return function(itemstack, user, pointed_thing)
		if itemstack:take_item() ~= nil and user ~= nil then
			local name = user:get_player_name()
			local ps=physio_stress.player[name]
			local hp = user:get_hp()
			if hp == nil then
				return
			end
			minetest.sound_play({name = sound or "eat_generic", gain = 1}, {pos=user:getpos(), max_hear_distance = 16})
			-- Saturation
			if physio_stress.attributes["saturation"] then -- is saturation enabled?
				local h = xpfw.player_get_attribute(user,"saturation")
				if h ~= nil then
					if hunger_change then
						if hunger_change > 0 then
							-- factor 2, because for recreation of 1hp 2 saturation are used
							xpfw.player_add_attribute(user,"saturation",2*hunger_change) 
						end
					end
				end
			else -- is saturation is disabled, increase hp
				hp=min(20,max(0,hp+hunger_change))
				user:set_hp(hp)
			end
			-- Thirst
			if physio_stress.attributes["thirst"] then -- is thirst enabled?
				local th = xpfw.player_get_attribute(user,"thirst")
				if thirst_change then
					if thirst_change > 0 then
						xpfw.player_add_attribute(user,"thirst",thirst_change)
					end
				end
			end
			-- Healing
			-- Poison

			if itemstack:get_count() == 0 then
				itemstack:add_item(replace_with_item)
			else
				local inv = user:get_inventory()
				if inv:room_for_item("main", replace_with_item) then
					inv:add_item("main", replace_with_item)
				else
					minetest.add_item(user:getpos(), replace_with_item)
				end
			end
		end
		return itemstack
	end
end

function physio_stress.player_save(playername)
	if playername == nil or playername == "" then
		return
	end
	local def=physio_stress.player[playername]
	for attr,val in pairs(def) do
		if val ~= physio_stress.default_player[attr] and type(val) == "number" then
--			print(attr,val)
			physio_stress.mod_storage:set_float(playername.."_"..attr,val)
		else
	--		print(attr.." not changed")
		end
	end
end

physio_stress.abm={}

function physio_stress.abm.sunburn(player)
	if physio_stress.attributes.sunburn == false then
		return
	end
	local name = player:get_player_name()
	local ps=physio_stress.player[name]
	
	if ps.sunburn_protect then
		return
	end
	local act_pos=player:get_pos()
	local act_light=minetest.get_node_light(act_pos)
	local player_armor=0
	if armor ~= nil then -- fail back to check if 3d_armor is used
		local player_armor=armor.def[name].count
	end
	local act_node=minetest.get_node(act_pos)
	local player_meanlight=xpfw.player_get_attribute(player,"meanlight")
	if act_light > player_meanlight then
		-- act light bigger than player meanlight: check for sunburn
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
--			print("sunburn"..act_light,sudiff,sumax,player_meanlight,player_armor)
		end
	else
		xpfw.player_sub_attribute(player,"sunburn",1)
	end
end

function physio_stress.abm.nyctophoby(player)
	if physio_stress.attributes.nyctophopy == false then
		return
	end
	local name = player:get_player_name()
	local ps=physio_stress.player[name]
	
	if ps.nyctophopy_protect then
		return
	end
	local act_pos=player:get_pos()
	local act_light=minetest.get_node_light(act_pos)
	local player_armor=0
	if armor ~= nil then -- fail back to check if 3d_armor is used
		local player_armor=armor.def[name].count
	end
	local player_meanlight=xpfw.player_get_attribute(player,"meanlight")
	if act_light < player_meanlight then
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
--				print("night"..act_light,player_meanlight,nydiff,name,nymin)
				xpfw.player_add_attribute(player,"nyctophoby",0.5)
			end
		end
	else
		xpfw.player_sub_attribute(player,"nyctophoby",1)
	end
end
