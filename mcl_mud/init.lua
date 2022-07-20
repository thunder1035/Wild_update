---mcl_mud---

local S = minetest.get_translator("mcl_core")
---just in case mud is added in mcl 2 and 5-
--if minetest.get_modpath("mcl_mud") then
--minetest.override_item("mcl_mud:mud",{
--groups = {handy = 1, soil = 1, shovely = 1, grass_block = 1, dirt = 2, soil_sugarcane = 1, --building_block = 1 enderman_takeable = 1},
--_mcl_blast_resistance = 0.5,
--_mcl_hardness = 0.5,
--})
--end

minetest.register_node("mcl_mud:mud", {
	description = S("Mud"),
	_tt_help = "Entities standing on mud sink",
	_doc_items_longdesc = S("Mud is a block from mangrove swamp.It drowns player a bit inside it"),
	stack_max = 64,
	tiles = {"mcl_mud.png"},
	is_ground_content = true,
	groups = {handy = 1, soil = 1, shovely = 1, grass_block = 1, dirt = 2, soil_sugarcane = 1, building_block = 1},
	collision_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 0.5 - 2/16, 0.5 },
	},
	sounds = mcl_sounds.node_sound_sand_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mcl_mud:packed_mud", {
	description = ("Packed Mud"),
	_tt_help = "Used for crafting Mud Bricks",
	_doc_items_longdesc = (""),
	_doc_items_hidden = false,
	tiles = {"mcl_packed_mud.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	drop = "mcl_mud:packed_mud",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 1,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_mud:mudbrick", {
	description = ("Mud Bricks"),
	_tt_help = "crafted with 4x4 packed mud",
	tiles = {"mcl_mud_bricks.png"},
	stack_max = 64,
	groups = {pickaxey=1, stone=1, stonebrick=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 1.5,
})


minetest.register_craft({
		output = "mcl_mud:mudbrick",
		recipe = {
			{"mcl_mud:packed_mud", "mcl_mud:packed_mud",},
			{"mcl_mud:packed_mud", "mcl_mud:packed_mud",},
		}
	})

mcl_stairs.register_stair("mudbrick", "mcl_mud:mudbrick",
		{pickaxey=3},
		{"mcl_mud_bricks.png"},
		S("Mud Brick Stairs"),
		mcl_sounds.node_sound_stone_defaults(), 6, 1.5,
		"woodlike")

mcl_stairs.register_slab("mudbrick", "mcl_mud:mudbrick",
		{pickaxey=3},
		{"mcl_mud_bricks.png"},
		S("Mud Brick Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Mud Brick Slab"))

minetest.register_craft({
		output = "mcl_mud:packed_mud",
		recipe = {
			{"mcl_mud:mud", "mcl_farming:wheat_item",},
		}
	})

-----dirt_to_mud-------

-- node changer--
minetest.override_item("mcl_potions:water", {
		on_place = function(itemstack, user, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick (pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		-- Place water bottle into dirt for mud
		if pointed_thing.under and node.name == "mcl_core:dirt" or node.name == "mcl_core:coarse_dirt" then
			local protname = user:get_player_name()
			if minetest.is_protected(pointed_thing.under, protname) then
				minetest.record_protection_violation(pointed_thing.under, protname)
				return itemstack
			end
			minetest.set_node(pointed_thing.under, { name = "mcl_mud:mud", param2 = node.param2 })
				minetest.sound_play("mcl_potions_bottle_pour", {pos=pointed_thing.under, gain=0.2, max_hear_range=16}, true)
				if minetest.is_creative_enabled(user:get_player_name()) then
					return itemstack
				else
					return "mcl_potions:glass_bottle"
			end
		end
end,
})
