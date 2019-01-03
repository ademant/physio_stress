-- override minetest.node_dig
local old_node_dig = minetest.node_dig
function minetest.node_dig(pos, node, digger)
	if digger ~= nil then
		local player = digger:get_player_name()
		if physio_stress.exhausted_dig[player] ~= nil then
			local dig_change=physio_stress.exhausted_dig[player]
			if math.random(1,dig_change) == 1 then
				return old_node_dig(pos, node, digger)
			else
				return
			end
		else
			return old_node_dig(pos, node, digger)
		end
	else
		return old_node_dig(pos, node, digger)
	end
end

local old_item_place_node = minetest.item_place_node
function minetest.item_place_node(itemstack, placer, pointed_thing)
	if placer ~= nil then
		local player = placer:get_player_name()
		if physio_stress.exhausted_build[player] ~= nil then
			local build_change=physio_stress.exhausted_build[player]
			if math.random(1,build_change) == 1 then
				return old_item_place_node(itemstack, placer, pointed_thing)
			else
				return
			end
		else
			return old_item_place_node(itemstack, placer, pointed_thing)
		end
	else
		return old_item_place_node(itemstack, placer, pointed_thing)
	end
end
