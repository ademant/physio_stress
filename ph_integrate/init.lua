
local cf={["farming:grain_coffee_cup_hot"]={drink_hp=10},
	["farming:grain_milk"]={drink_hp=20},
	["farming:smoothie"]={drink_hp=20},
	["default:apple"]={drink_hp=5},
	["farming:strawberry_seed"]={drink_hp=4},
	["farming:blackberry_seed"]={drink_hp=4},
	["farming:blueberry_seed"]={drink_hp=4},
	["farming:raspberry_seed"]={drink_hp=4},
	["farming:rhubarb_seed"]={drink_hp=3},
	["default:potato"]={drink_hp=2},
	["default:carrot"]={drink_hp=2},
	["moretrees:coconut_milk"]={drink_hp=10},
}
for i,def in pairs(cf) do
	if minetest.registered_items[i]~=nil then
		minetest.override_item(i,def)
	end
end
