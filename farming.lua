if minetest.registered_items["farming:grain_coffee_cup_hot"]~=nil then
	minetest.override_item("farming:grain_coffee_cup_hot", {drink_hp=10})
end
if minetest.registered_items["farming:grain_milk"]~=nil then
	minetest.override_item("farming:grain_milk", {drink_hp=20})
end
if minetest.registered_items["farming:smoothie"]~=nil then
	minetest.override_item("farming:smoothie", {drink_hp=20})
end
