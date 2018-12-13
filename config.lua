for i,attr in ipairs({"exhaustion","hunger","thirst","sunburn","nyctophoby"}) do
	physio_stress.attributes[attr]=minetest.settings:get("physio_stress."..attr) or false
end

if minetest.get_modpath("3d_armor") == nil then
	physio_stress.attributes.sunburn = false
end
