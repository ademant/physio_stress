-- check, which submodule should be enabled
for i,attr in ipairs({"exhaustion","saturation","thirst","sunburn","nyctophoby"}) do
	physio_stress.attributes[attr]=(minetest.settings:get(physio_stress.intprefix.."."..attr)=="true") or false
	local is_status=" is enabled"
	if physio_stress.attributes[attr] == false then
		is_status = " is disabled"
	end
	print(attr..is_status)
end

-- no sunburn if 3d armor is not available
if armor == nil then
	physio_stress.attributes.sunburn = false
end

physio_stress.dtime=tonumber(minetest.settings:get(physio_stress.intprefix..".dtime")) or 1
physio_stress.dtime_heal=tonumber(minetest.settings:get(physio_stress.intprefix..".dtime_heal")) or 1
physio_stress.dt=0
physio_stress.dt_heal=0
physio_stress.saturationmax=tonumber(minetest.settings:get(physio_stress.intprefix..".saturation_max")) or 20
physio_stress.saturation_minhealing=tonumber(minetest.settings:get(physio_stress.intprefix..".saturation_minhealing")) or 3
physio_stress.thirstmax=tonumber(minetest.settings:get(physio_stress.intprefix..".thirst_max")) or 20
physio_stress.saturation_recreation=tonumber(minetest.settings:get(physio_stress.intprefix..".saturation_recreation")) or 0.5
physio_stress.ingestion_rejoin=tonumber(minetest.settings:get(physio_stress.intprefix..".ingestion_rejoin")) or 3
physio_stress.player={}
physio_stress.exhausted_build={}
physio_stress.exhausted_dig={}
physio_stress.st_coeff_names={"walked","swam","dug","build","playtime","craft"}
physio_stress.action_names={"walked","swam","dug","build","craft"}
physio_stress.dig_groups={"cracky","crumbly","snappy","choppy"}
physio_stress.player_fields={"sunburn_armor_dmaxlight","sunburn_maxlight","sunburn_delay","sunburn_diff","nyctophoby_diff","sunburn_hp","nyctophoby_delay","nyctophoby_hp","sunburn_armor","nyctophoby_armor","nyctophoby_minlight"}


-- check, which phobies are enabled and initialize xpfw attribute
physio_stress.phobies={}
for i,attr in ipairs({"sunburn","nyctophoby"}) do
	if physio_stress.attributes[attr]~=nil then
		if physio_stress.attributes[attr] == true then
			table.insert(physio_stress.phobies,attr)
			xpfw.register_attribute(attr,{min=0,max=20,default=0,hud=1})
		end
	end
end

--check which ingestions are enabled and enable xpfw attribute
physio_stress.ingestion={}
for i,attr in ipairs({"saturation","thirst"}) do
	if physio_stress.attributes[attr]~=nil then
		if physio_stress.attributes[attr] == true then
			table.insert(physio_stress.ingestion,attr)
			local att_max=tonumber(minetest.settings:get(physio_stress.intprefix.."."..attr.."_max")) or 20
			xpfw.register_attribute(attr,{min=0,max=att_max,default=att_max,
				hud=1,})
		end
	end
end

-- check for global variables, stored in mod_storage
for i,attr in ipairs({"playerlist"}) do
	physio_stress[attr]=physio_stress.mod_storage:get_string(attr)
end

-- get default values for new players
physio_stress.default_player={}
for i,attr in ipairs(physio_stress.player_fields) do
	physio_stress.default_player[attr]=tonumber(minetest.settings:get(physio_stress.intprefix.."."..attr)) or 1
end
for j,st in ipairs(physio_stress.ingestion) do 
	local coeff_names=table.copy(physio_stress.st_coeff_names)
	table.insert(coeff_names,"exhaustion")
	for i,attr in ipairs(coeff_names) do
		local sat_coeff = tonumber(minetest.settings:get(physio_stress.intprefix.."."..st.."_"..attr)) or 100
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
	physio_stress.dig_correction[attr]=tonumber(minetest.settings:get(physio_stress.intprefix..".dig_"..attr)) or 1
end


-- initialize exhaustion
if physio_stress.attributes["exhaustion"] then
	local attr_def={min=0,max=20,default=0,hud=1,
		moving_average_factor=tonumber(minetest.settings:get(physio_stress.intprefix..".exhaustion_mean_weight")) or 50,
		recreation_factor=tonumber(minetest.settings:get(physio_stress.intprefix..".exhaustion_recreation")) or 10,
		}
	xpfw.register_attribute("exhaustion",attr_def)
end
