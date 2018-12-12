
physio_stress = {}
physio_stress.path = minetest.get_modpath("xpfw")
physio_stress.modname=minetest.get_current_modname()
physio_stress.mod_storage=minetest.get_mod_storage()
physio_stress.store_table={}--xpfw.mod_storage:to_table()
physio_stress.attributes={}

minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- start loading from "..minetest.get_modpath(minetest.get_current_modname()))
-- Load files


dofile(xpfw.path .. "/api.lua") -- API
dofile(xpfw.path .. "/config.lua") -- API
dofile(xpfw.path .. "/chat_commands.lua")

minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded ")
