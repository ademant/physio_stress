
physio_stress = {}
physio_stress.path = minetest.get_modpath("physio_stress")
physio_stress.modname=minetest.get_current_modname()
physio_stress.mod_storage=minetest.get_mod_storage()
physio_stress.attributes={}
physio_stress.player={}

minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- start loading from "..minetest.get_modpath(minetest.get_current_modname()))
-- Load files


dofile(physio_stress.path .. "/api.lua") -- API
dofile(physio_stress.path .. "/config.lua") -- API
--dofile(physio_stress.path .. "/chat_commands.lua")
dofile(physio_stress.path .. "/armor.lua")
dofile(physio_stress.path .. "/abm.lua") -- API

minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded ")
