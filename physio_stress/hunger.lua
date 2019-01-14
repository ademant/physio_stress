
if physio_stress.attributes.saturation or physio_stress.attributes.thirst then
	-- only use new eating mechanism, if thirst or saturation is enabled
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
end
