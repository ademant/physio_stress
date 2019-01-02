for i,attr in ipairs({"exhaustion","saturation","thirst","sunburn","nyctophoby"}) do
	physio_stress.attributes[attr]=minetest.settings:get("physio_stress."..attr) or false
end

physio_stress.dtime=tonumber(minetest.settings:get("physio_stress.dtime")) or 1
physio_stress.dt=0
physio_stress.saturationmax=tonumber(minetest.settings:get("physio_stress.saturation_max")) or 20
physio_stress.thirstmax=tonumber(minetest.settings:get("physio_stress.thirst_max")) or 20
physio_stress.saturation_recreation=tonumber(minetest.settings:get("physio_stress.saturation_recreation")) or 0.5
physio_stress.player={}
physio_stress.st_coeff_names={"walked","swam","dug","build","base","craft"}

for i,attr in ipairs({"playerlist"}) do
	physio_stress[attr]=physio_stress.mod_storage:get_string(attr)
end

if minetest.get_modpath("3d_armor") == nil then
	physio_stress.attributes.sunburn = false
end

physio_stress.default_player={}
for i,attr in ipairs({"sunburn_diff","nyctophoby_diff","sunburn_hp","nyctophoby_hp","sunburn_armor","nyctophoby_armor"}) do
	physio_stress.default_player[attr]=tonumber(minetest.settings:get("physio_stress."..attr)) or 1
end
for i,attr in ipairs(physio_stress.st_coeff_names) do
	for j,st in ipairs({"saturation","thirst"}) do 
		local sat_coeff = tonumber(minetest.settings:get("physio_stress."..st.."_"..attr)) or 100
		if sat_coeff > 0 then
			physio_stress.default_player[st.."_"..attr] = sat_coeff
		end
	end
end

if physio_stress.playerlist ~= "" then
	local players=physio_stress.playerlist:split(",",true)
	for i,pl in ipairs(players) do
		print(i,pl)
		physio_stress.player[pl]=table.copy(physio_stress.default_player)
		for j,attr in pairs(physio_stress.player[pl]) do
			local modval=physio_stress.mod_storage:get(pl.."_"..j)
			if modval ~= nil then
				physio_stress.player[pl]=tonumber(modval)
			end
		end
	end
end
print(dump2(physio_stress.player))

if minetest.settings:get("physio_stress.exhaustion") then
	xpfw.register_attribute("exhaustion",{min=0,max=20,
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
