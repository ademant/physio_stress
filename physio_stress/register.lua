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
	local ps=physio_stress.player[playername]
	ps["disabled"] = 1
end)

minetest.register_on_dieplayer(function(player)
	local playername = player:get_player_name()
	local ps=physio_stress.player[playername]
	ps["disabled"] = 1
end)

minetest.register_on_respawnplayer(function(player)
	local playername = player:get_player_name()
	for i,attr in ipairs(physio_stress.ingestion) do
		if physio_stress.attributes[attr] then
			xpfw.player_reset_single_attribute(player,attr)
			physio_stress.hud_update(player,attr,xpfw.player_get_attribute(player,attr))
		end
	end
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
	end
	if physio_stress.player[playername] == nil then
		physio_stress.player[playername]=table.copy(physio_stress.default_player)
	else
		local ps=physio_stress.player[playername]
		for i,attr in ipairs(physio_stress.player_fields) do
			if ps[attr] == nil then
				ps[attr]=minetest.settings:get("physio_stress."..attr) or 1
			end
		end
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
	for i,attr in ipairs(physio_stress.ingestion) do
		if physio_stress.attributes[attr] then
			if xpfw.player_get_attribute(player,attr)<physio_stress.ingestion_rejoin then
				xpfw.player_set_attribute(player,attr,physio_stress.ingestion_rejoin)
			end
--			xpfw.player_reset_single_attribute(player,attr)
			physio_stress.hud_init(player,attr)
		end
	end
	if physio_stress.attributes.exhaustion then
		xpfw.player_reset_single_attribute(player,"exhaustion")
		physio_stress.hud_init(player,"exhaustion")
	end
	
	if ps["disabled"] ~= nil then
		ps["disabled"] = nil
	end
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

