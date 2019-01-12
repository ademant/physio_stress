-- check, which submodule should be enabled
for i,attr in ipairs({"exhaustion","saturation","thirst","sunburn","nyctophoby"}) do
	physio_stress.attributes[attr]=minetest.settings:get("physio_stress."..attr) or false
end

physio_stress.dtime=tonumber(minetest.settings:get("physio_stress.dtime")) or 1
physio_stress.dt=0
physio_stress.saturationmax=tonumber(minetest.settings:get("physio_stress.saturation_max")) or 20
physio_stress.thirstmax=tonumber(minetest.settings:get("physio_stress.thirst_max")) or 20
physio_stress.saturation_recreation=tonumber(minetest.settings:get("physio_stress.saturation_recreation")) or 0.5
physio_stress.player={}
physio_stress.exhausted_build={}
physio_stress.exhausted_dig={}
physio_stress.st_coeff_names={"walked","swam","dug","build","base","craft"}
physio_stress.action_names={"walked","swam","dug","build","craft"}
physio_stress.dig_groups={"cracky","crumbly","snappy","choppy"}
physio_stress.phobies={"sunburn","nyctophoby"}
physio_stress.ingestion={"saturation","thirst"}
physio_stress.player_fields={"sunburn_armor_dmaxlight","sunburn_maxlight","sunburn_delay","sunburn_diff","nyctophoby_diff","sunburn_hp","nyctophoby_delay","nyctophoby_hp","sunburn_armor","nyctophoby_armor","nyctophoby_minlight"}

-- check for global variables, stored in mod_storage
for i,attr in ipairs({"playerlist"}) do
	physio_stress[attr]=physio_stress.mod_storage:get_string(attr)
end

-- no sunburn if 3d armor is not available
if minetest.get_modpath("3d_armor") == nil then
	physio_stress.attributes.sunburn = false
end

-- get default values for new players
physio_stress.default_player={}
for i,attr in ipairs(physio_stress.player_fields) do
	physio_stress.default_player[attr]=tonumber(minetest.settings:get("physio_stress."..attr)) or 1
end
print(dump2(physio_stress.default_player))
for i,attr in ipairs(physio_stress.st_coeff_names) do
	for j,st in ipairs(physio_stress.ingestion) do 
		local sat_coeff = tonumber(minetest.settings:get("physio_stress."..st.."_"..attr)) or 100
		if sat_coeff > 0 then
			physio_stress.default_player[st.."_"..attr] = sat_coeff
		end
	end
end

-- first protect against sunburn/nyctophoby
for i,attr in ipairs({"sunburn_protect","nyctophoby_protect"}) do
	physio_stress.default_player[attr]=true
end

-- restore player settings, if stored in mod_storage
if physio_stress.playerlist ~= "" then
	local players=physio_stress.playerlist:split(",",true)
	for i,pl in ipairs(players) do
		physio_stress.player[pl]=table.copy(physio_stress.default_player)
		for j,attr in pairs(physio_stress.player[pl]) do
			local modval=physio_stress.mod_storage:get(pl.."_"..j)
			if modval ~= nil then
				physio_stress.player[pl][attr]=tonumber(modval)
			end
		end
	end
end


-- dig correction values for saturation
physio_stress.dig_correction={}
for i,attr in ipairs(physio_stress.dig_groups) do
	physio_stress.dig_correction[attr]=tonumber(minetest.settings:get("physio_stress.dig_"..attr)) or 1
end


-- initialize saturation
if minetest.settings:get("physio_stress.saturation") then
	xpfw.register_attribute("saturation",{min=0,max=physio_stress.saturationmax,
		default=physio_stress.saturationmax,
		hud=1
		})
end

-- initialize thirst
if minetest.settings:get("physio_stress.thirst") then
xpfw.register_attribute("thirst",{min=0,max=physio_stress.thirstmax,
	default=physio_stress.thirstmax,
	hud=1
	})
end

-- initialize nyctophoby/sunburn/exhaustion
for i,attr in ipairs({"sunburn","nyctophoby","exhaustion"}) do
	if minetest.settings:get("physio_stress."..attr) then
	local attr_def={min=0,max=20,default=0,hud=1}
	if attr=="exhaustion" then
		attr_def.moving_average_factor=tonumber(minetest.settings:get("physio_stress.exhaustion_mean_weight")) or 50
		attr_def.recreation_factor=tonumber(minetest.settings:get("physio_stress.exhaustion_recreation")) or 10
	end
	xpfw.register_attribute(attr,attr_def)
	end
end
