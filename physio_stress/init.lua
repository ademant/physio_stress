
physio_stress = {}
physio_stress.intprefix="physio_stress"
physio_stress.path = minetest.get_modpath(physio_stress.intprefix)
physio_stress.modname=minetest.get_current_modname()
physio_stress.mod_storage=minetest.get_mod_storage()
physio_stress.attributes={}
physio_stress.player={}
local S = dofile(physio_stress.path .. "/intllib.lua")
physio_stress.intllib = S

minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- start loading from "..minetest.get_modpath(minetest.get_current_modname()))
-- Load files

-- import settingtypes.txt
basic_functions.import_settingtype(physio_stress.path .. "/settingtypes.txt")

dofile(physio_stress.path .. "/api.lua") -- API
dofile(physio_stress.path .. "/config.lua") -- API
dofile(physio_stress.path .. "/chat_commands.lua")
dofile(physio_stress.path .. "/armor.lua")
dofile(physio_stress.path .. "/hunger.lua")
dofile(physio_stress.path .. "/register.lua") -- API
dofile(physio_stress.path .. "/abm.lua") -- API
dofile(physio_stress.path .. "/interop.lua") -- API
dofile(physio_stress.path .. "/playereffects.lua") -- API
dofile(physio_stress.path .. "/overrides.lua") -- overriding base functions

minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded ")
