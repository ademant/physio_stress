
local cf={["farming:grain_coffee_cup_hot"]={drink_hp=10},
	["farming:grain_milk"]={drink_hp=20},
	["farming:smoothie"]={drink_hp=20},
}
for i,def in pairs(cf) do
	if minetest.registered_items[i]~=nil then
		minetest.override_item(i,def)
	end
end
