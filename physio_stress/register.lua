minetest.register_on_shutdown(function()
	for i,attr in ipairs({"playerlist"}) do
		physio_stress.mod_storage:set_string(attr,physio_stress[attr])
	end
	for pl,def in pairs(physio_stress.player) do
		physio_stress.player_save(pl)
	end
end)

minetest.register_on_leaveplayer(function(player)
	local playername = player:get_player_name()
	physio_stress.player_save(playername)
end)

minetest.register_on_respawnplayer(function(player)
	local playername = player:get_player_name()
	local ps=physio_stress.player[playername]
	ps.exhaustion=0
	ps.saturation=physio_stress.saturationmax
	ps.thirst=physio_stress.thirstmax
end)

minetest.register_on_joinplayer(function(player)
	local playername = player:get_player_name()
	local players=physio_stress.playerlist:split(",")
	if basic_functions.has_value(players,playername) == false then
		if #players > 1 then
			physio_stress.playerlist=physio_stress.playerlist..","..playername
		else
			physio_stress.playerlist=playername
		end
		print(physio_stress.playerlist)
	end
	if physio_stress.player[playername] == nil then
		physio_stress.player[playername]=table.copy(physio_stress.default_player)
	else
		local ps=physio_stress.player[playername]
		print(dump2(ps))
		for i,attr in ipairs({"sunburn_diff","nyctophoby_diff","sunburn_hp","nyctophoby_hp","sunburn_armor","nyctophoby_armor"}) do
			if ps[attr] == nil then
				ps[attr]=minetest.settings:get("physio_stress."..attr) or 1
			end
		end
		ps.saturation=physio_stress.saturationmax
		ps.thirst=physio_stress.thirstmax
	end
	local ps=physio_stress.player[playername]
	
	-- copy dug/build/walked/swam stats per user
	for i,attr in ipairs(physio_stress.st_coeff_names) do
		local patt=xpfw.player_get_attribute(player,attr)
		if patt ~= nil then
			ps[attr]=patt
		end
	end
	for i,attr in ipairs({"cracky","crumbly","snappy","choppy"}) do
		ps[attr] = 0
	end
	physio_stress.hud_init(player,"exhaustion")
	physio_stress.hud_init(player,"saturation")
	physio_stress.hud_init(player,"thirst")
end)

minetest.register_on_dignode(function(pos,oldnode,player)
	if player ~= nil then
		local ps=physio_stress.player[player:get_player_name()]
		if ps ~= nil then
			for i,attr in ipairs(physio_stress.dig_groups) do
				ps[attr] = ps[attr]+minetest.get_item_group(oldnode.name,attr)
			end
		end
	end
end)

