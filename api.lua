
minetest.register_on_joinplayer(function(player)
	local playername = player:get_player_name()
	if physio_stress.player[playername] == nil then
		physio_stress.player[playername]=table.copy(physio_stress.default_player)
	else
		local ps=physio_stress.player[playername]
		for i,attr in ipairs({"sunburn_diff","nyctophoby_diff","sunburn_hp","nyctophoby_hp","sunburn_armor","nyctophoby_armor"}) do
			if ps[attr] == nil then
				ps[attr]=minetest.settings:get("physio_stress."..attr) or 1
			end
		end
	end
	physio_stress.hud_init(player)
end)

function physio_stress.hud_clamp(value)
    if value < 0 then
        return 0
    elseif value > 20 then
        return 20
    else
        return math.ceil(value)
    end
end
if minetest.get_modpath("hudbars") then
    hb.register_hudbar('exhaust', 0xffffff, "Exhaustion", {
        bar = 'physio_stress_hudbars_bar.png',
        icon = 'physio_stress_exhaust_16.png'
    }, 20, 20, false)
    function physio_stress.hud_init(player)
        hb.init_hudbar(player, 'exhaust',
            physio_stress.hud_clamp(xpfw.player_get_attribute(player, 'exhaustion')),
        20, false)
    end
    function physio_stress.hud_update(player, value)
        hb.change_hudbar(player, 'exhaust', physio_stress.hud_clamp(value), 20)
    end
end
