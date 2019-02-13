
playereffects.register_effect_type("slow_dig", "Slow dig", "physio_stress_exhaust_16", {"dig"}, 
	function(player)
		physio_stress.exhausted_dig[player:get_player_name()]=3
	end,
	
	function(effect, player)
		physio_stress.exhausted_dig[player:get_player_name()]=nil
	end
)
playereffects.register_effect_type("slow_build", "Slow build", "physio_stress_exhaust_16", {"build"}, 
	function(player)
		physio_stress.exhausted_build[player:get_player_name()]=3
	end,
	
	function(effect, player)
		physio_stress.exhausted_build[player:get_player_name()]=nil
	end
)
playereffects.register_effect_type("exhausted", "Exhausted", "physio_stress_exhaust_16.png", {"exhaust"}, 
	function(player)
		physio_stress.exhausted_build[player:get_player_name()]=3
		physio_stress.exhausted_dig[player:get_player_name()]=3
		player:set_physics_override(0.5,nil,nil)
	end,
	
	function(effect, player)
		physio_stress.exhausted_build[player:get_player_name()]=nil
		physio_stress.exhausted_dig[player:get_player_name()]=nil
		player:set_physics_override(1,nil,nil)
	end
)

-- based on examples.lua out of playereffects mod
-- Slows the user down
playereffects.register_effect_type("low_speed", "Low speed", "physio_stress_exhaust_16.png", {"speed"}, 
	function(player)
		player:set_physics_override(0.25,nil,nil)
	end,
	
	function(effect, player)
		player:set_physics_override(1,nil,nil)
	end
)

-- Repeating effect type: Adds 1 HP per second
playereffects.register_effect_type("regen", "Regeneration", "heart.png", {"health"},
	function(player)
		player:set_hp(player:get_hp()+1)
	end,
	nil, nil, nil, 1
)
