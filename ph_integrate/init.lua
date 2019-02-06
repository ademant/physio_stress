
local cf={["farming:grain_coffee_cup_hot"]={drink_hp=10},
	["farming:grain_milk"]={drink_hp=20},
	["farming:smoothie"]={drink_hp=20},
	["default:apple"]={drink_hp=4},
	["ethereal:banana"]={drink_hp=4},
	["farming:strawberry_seed"]={drink_hp=3},
	["farming:blackberry_seed"]={drink_hp=3},
	["farming:blueberry_seed"]={drink_hp=3},
	["farming:raspberry_seed"]={drink_hp=3},
	["farming:rhubarb_seed"]={drink_hp=2},
	["default:potato"]={drink_hp=1},
	["default:carrot"]={drink_hp=1},
	["moretrees:coconut_milk"]={drink_hp=10},
	["mtfoods:orange_juice"]={drink_hp=10},
	["mtfoods:apple_juice"]={drink_hp=10},
	["mtfoods:apple_cider"]={drink_hp=15},
}
for i,def in pairs(cf) do
	if minetest.registered_items[i]~=nil then
		local tgroup=minetest.registered_items[i].groups
		if tgroup.drinkable == nil then
			tgroup["drinkable"]=def.drink_hp
		end
		minetest.override_item(i,tgroup)
	end
end
