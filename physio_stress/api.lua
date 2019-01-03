

function physio_stress.hud_clamp(value)
	if value == nil then
		return 20
	end
	return math.max(0,math.min(20,value))
end

function physio_stress.eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
	local item = itemstack:get_name()
	local def = minetest.registered_items[item]
	local thirst_change = 0
	if not def then
		def = {}
		if type(hp_change) ~= "number" then
			hp_change = 1
			core.log("error", "Wrong on_use() definition for item '" .. item .. "'")
		end
		def.saturation = hp_change * 1.3
		def.replace = replace_with_item
		if not def.drink_hp then
			thirst_change=tonumber(def.drink_hp) or 0
		end
	else
		def={saturation=hp_change * 1.3,
			replace=replace_with_item,
			poisen = 0,
			healing = 0,
			sound="hbhunger_eat_generic",}
	end
	local func = physio_stress.item_eat(def.saturation, def.replace, def.poisen, def.healing, thirst_change,def.sound)
	return func(itemstack, user, pointed_thing)
end

function physio_stress.item_eat(hunger_change, replace_with_item, heal, thirst_change,sound)
	return function(itemstack, user, pointed_thing)
		if itemstack:take_item() ~= nil and user ~= nil then
			local name = user:get_player_name()
			local ps=physio_stress.player[name]
			local h = xpfw.player_get_attribute(user,"saturation")
			local th = xpfw.player_get_attribute(user,"thirst")
--			local h = tonumber(ps.saturation)
--			local th = tonumber(ps.thirst)
			local hp = user:get_hp()
			if h == nil or hp == nil then
				return
			end
			minetest.sound_play({name = sound or "hbhunger_eat_generic", gain = 1}, {pos=user:getpos(), max_hear_distance = 16})

			-- Saturation
			if hunger_change then
				if hunger_change > 0 then
					print("eat "..hunger_change)
					xpfw.player_add_attribute(user,"saturation",hunger_change)
				end
			end
			-- Thirst
			if thirst_change then
				if thirst_change > 0 then
					xpfw.player_add_attribute(user,"thirst",thirst_change)
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
