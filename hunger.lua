-- wrapper for minetest.item_eat (this way we make sure other mods can't break this one)
local org_eat = core.do_item_eat
core.do_item_eat = function(hp_change, replace_with_item, itemstack, user, pointed_thing)
	local old_itemstack = itemstack
	itemstack = physio_stress.eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
	for _, callback in pairs(core.registered_on_item_eats) do
		local result = callback(hp_change, replace_with_item, itemstack, user, pointed_thing, old_itemstack)
		if result then
			return result
		end
	end
	return itemstack
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
			def.replace=replace_with_item
			def.poisen = 0
			def.healing = 0
			def.sound="hbhunger_eat_generic",}
	end
	local func = physio_stress.item_eat(def.saturation, def.replace, def.poisen, def.healing, thirst_change,def.sound)
	return func(itemstack, user, pointed_thing)
end

function physio_stress.item_eat(hunger_change, replace_with_item, heal, thirst_change,sound)
	return function(itemstack, user, pointed_thing)
		if itemstack:take_item() ~= nil and user ~= nil then
			local name = user:get_player_name()
			local ps=physio_stress.player[name]
			local h = tonumber(ps.saturation)
			local th = tonumber(ps.thirst)
			local hp = user:get_hp()
			if h == nil or hp == nil then
				return
			end
			minetest.sound_play({name = sound or "hbhunger_eat_generic", gain = 1}, {pos=user:getpos(), max_hear_distance = 16})

			-- Saturation
			if h < physio_stress.hungermax and hunger_change then
				h = h + hunger_change
				if h > physio_stress.hungermax then h = physio_stress.hungermax end
				ps.saturation = h
			end
			-- Thirst
			if th < physio_stress.thirstmax and thirst_change then
				th = th + thirst_change
				if th > physio_stress.thirstmax then th = physio_stress.thirstmax end
				ps.thirst = th
			end
			-- Healing
			if hp < 20 and heal then
				hp = hp + heal
				if hp > 20 then hp = 20 end
				user:set_hp(hp)
			end
			-- Poison
			if poisen then
				-- Set poison bar
				hb.change_hudbar(user, "health", nil, nil, "hbhunger_icon_health_poison.png", nil, "hbhunger_bar_health_poison.png")
				hbhunger.poisonings[name] = hbhunger.poisonings[name] + 1
				poisenp(1, poisen, 0, user)
			end

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
