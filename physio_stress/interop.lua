if minetest.get_modpath("hudbars") then
    hb.register_hudbar('exhaustion', 0xffffff, "Exhaustion", {
        bar = 'physio_stress_hudbars_bar.png',
        icon = 'physio_stress_exhaust_16.png'
    }, 20, 20, false)
    hb.register_hudbar('saturation', 0xffffff, "Saturation", {
        bar = 'physio_stress_hudbars_bar.png',
        icon = 'physio_stress_hunger.png'
    }, physio_stress.saturationmax, physio_stress.saturationmax, false)
    hb.register_hudbar('thirst', 0xffffff, "Thirst", {
        bar = 'physio_stress_hudbars_bar.png',
        icon = 'physio_stress_thirst.png'
    }, physio_stress.thirstmax, physio_stress.thirstmax, false)
    
    
    function physio_stress.hud_init(player,col)
		if col == nil then
			return
		end
        hb.init_hudbar(player, col ,physio_stress.hud_clamp(xpfw.player_get_attribute(player, col)),20, false)
    end
    function physio_stress.hud_update(player, col, value)
		if col == nil then
			return
		end
		if value == nil then
			return
		end
        hb.change_hudbar(player, col, physio_stress.hud_clamp(value), 20)
    end
end
