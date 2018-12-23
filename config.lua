for i,attr in ipairs({"exhaustion","hunger","thirst","sunburn","nyctophoby"}) do
	print(dump2(minetest.settings:get("physio_stress."..attr)))
	physio_stress.attributes[attr]=minetest.settings:get("physio_stress."..attr) or false
end
print(dump2(minetest.settings:get_names()))

physio_stress.dtime=minetest.settings:get("physio_stress.dtime") or 1
physio_stress.dt=0

if minetest.get_modpath("3d_armor") == nil then
	physio_stress.attributes.sunburn = false
end

physio_stress.default_player={}
for i,attr in ipairs({"sunburn_diff","nyctophoby_diff","sunburn_hp","nyctophoby_hp","sunburn_armor","nyctophoby_armor"}) do
	physio_stress.default_player[attr]=minetest.settings:get("physio_stress."..attr) or 1
end
