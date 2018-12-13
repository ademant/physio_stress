local local_get_recipe=function(tool,material)
	local out_recipe={}
	if tool == "helmet" then
		out_recipe = {
		{material, material, material},
		{material, '', material},}
	elseif tool == "chestplate" then
		out_recipe = {
		{material, '', material},
		{material, material, material},
		{material, material, material},}
	elseif tool == "leggings" then
	out_recipe = {
		{material, material, material},
		{material, '', material},
		{material, '', material},}
	elseif tool == "boots" then
	out_recipe = {
		{material, '', material},
		{material, '', material},}
	elseif tool == "shield" then
	out_recipe = {
		{material, material, material},
		{material, material, material},
		{'', material, ''},}
	else
		out_recipe={}
	end
	return out_recipe
end

if minetest.get_modpath("3d_armor") ~= nil then

	for _,tool in ipairs({"helmet","chestplate","leggings","boots"}) do
		minetest.register_craft({
			output=physio_stress.modname..":"..tool.."_grass",
			recipe=local_get_recipe(tool,"default:grass_1")
		})
		tt_def={description="Grass "..tool,
			inventory_image=physio_stress.modname.."_inv_"..tool.."_grass.png",
			damage_groups = {level = 2},
			armor_groups={fleshy=2},
			groups={armor_heal=0,armor_use=100,}
			}
		if tool == "helmet" then
			tt_def.groups.armor_head=1
		elseif tool == "chestplate" then
			tt_def.groups.armor_torso=1
		elseif tool == "leggings" then
			tt_def.groups.armor_legs=1
		elseif tool == "boots" then
			tt_def.groups.armor_feet=1
		end
		toolname=physio_stress.modname..":"..tool.."_grass"
		armor:register_armor(toolname,tt_def)
	end
end
