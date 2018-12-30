for i,attr in ipairs({"exhaustion","saturation","thirst","sunburn","nyctophoby"}) do
	physio_stress.attributes[attr]=minetest.settings:get("physio_stress."..attr) or false
end

physio_stress.dtime=tonumber(minetest.settings:get("physio_stress.dtime")) or 1
physio_stress.dt=0
physio_stress.saturationmax=tonumber(minetest.settings:get("physio_stress.saturation_max")) or 30
physio_stress.thirstmax=tonumber(minetest.settings:get("physio_stress.thirst_max")) or 30
physio_stress.saturation_recreation=tonumber(minetest.settings:get("physio_stress.saturation_recreation")) or 1

if minetest.get_modpath("3d_armor") == nil then
	physio_stress.attributes.sunburn = false
end

physio_stress.default_player={}
for i,attr in ipairs({"sunburn_diff","nyctophoby_diff","sunburn_hp","nyctophoby_hp","sunburn_armor","nyctophoby_armor"}) do
	physio_stress.default_player[attr]=tonumber(minetest.settings:get("physio_stress."..attr)) or 1
end

if minetest.settings:get("physio_stress.exhaustion") then
	xpfw.register_attribute("exhaustion",{min=0,max=20,
		recreation_factor=(tonumber(minetest.settings:get("physio_stress.exhaust_recreation")) or 30),
		default=0,
		hud=1
		})
end
if minetest.settings:get("physio_stress.saturation") then
	xpfw.register_attribute("saturation",{min=0,max=physio_stress.saturationmax,
		default=physio_stress.saturationmax,
		hud=1
		})
end
if minetest.settings:get("physio_stress.thirst") then
xpfw.register_attribute("thirst",{min=0,max=physio_stress.thirstmax,
	default=physio_stress.thirstmax,
	hud=1
	})
end
