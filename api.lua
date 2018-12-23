
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

if minetest.get_modpath("hud") then
    local position = { x=0.5, y=1 }
    local offset   = { x=15, y=-133} -- above AIR
    hud.register('exhaustion', {
        hud_elem_type = "statbar",
        position = position,
        text = "physio_stress_exhaust.png",
--        background = "sunburn_sun_bg.png",
        number = 20,
        max = 20,
        size = HUD_SD_SIZE, -- by default { x=24, y=24 },
        offset = offset,
    })
    function physio_stress.hud_init(player)
        -- automatic by [hud]
    end
    function physio_stress.hud_update(player, value)
        hud.change_item(player, 'exhaustion', {
            number = physio_stress.hud_clamp(value)
        })
    end
end
