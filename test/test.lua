local S = minetest.get_translator("mcl_core")
------------------------------------------------------------------------

--
-- watered_roots on mangrove roots near water
--

local watered_root_correspondences = {
	["wild_update:mangrove_roots"] = "wild_update:water_logged_roots",
}
minetest.register_abm({
	label = "watered_root",
	nodenames = {"wild_update:mangrove_roots"},
	neighbors = {"mcl_core:water_source"},
	interval = 1,
	chance = 1,
	catch_up = false,
	action = function(pos, node)
		node.name =watered_root_correspondences[node.name]
		if node.name then
			minetest.set_node(pos, node)
		end
	end
})


minetest.register_node("wild_update:propagule_test_1", {
	description = S("Propagule_test"),
	_tt_help = S("Grows into Mangrove tree"),
	groups = {plant = 1, not_in_creative_inventory=1, non_mycelium_plant = 1, deco_block = 1, dig_immediate = 3, dig_by_water = 0, dig_by_piston = 1, destroy_by_lava_flow = 1, compostability = 30},
	paramtype = "light",
	on_rotate = false,
	walkable = true,
	buildable_to = flase,
	pointable = true,
	diggable = true,
	drop = "wild_update:propagule_test",
	use_texture_alpha = "clip",
	drawtype = 'mesh',
    	mesh = 'propagule.obj',
selection_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
			{ -0.5, 0.5, -0.5, 0.5, 1.0, 0.5 },
		}
	},
	tiles = {"mcl_propagule.png"},
	inventory_image = "mcl_mangrove_propagule.png",
	wield_image = "mcl_mangrove_propagule.png",
	node_dig_prediction = "mcl_core:dirt",
	after_dig_node = function(pos)
		local node = minetest.get_node(pos)
		if minetest.get_item_group(node.name, "dirt") == 0 then
			minetest.set_node(pos, {name="mcl_core:dirt"})
		end
	end,
})

---------------------
local soil_block = ("mcl_core:dirt"),("mcl_core:dirt_with_grass")
--------------------------------
	minetest.register_node("wild_update:propagule_test", {
		description = "propagule_test",
		_doc_items_longdesc = "",
		_tt_help = "",
		drawtype = "plantlike_rooted",
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 1,
		tiles = { "dirt.png" },
		special_tiles = { { name = "mcl_mangrove_propagule.png" } },
		inventory_image = "mcl_mangrove_propagule.png",
		wield_image = "mcl_mangrove_propagule.png",
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				{ -0.5, 0.5, -0.5, 0.5, 1.0, 0.5 },
			}
		},
		groups = {
			plant = 1, sapling = 1, non_mycelium_plant = 1, attached_node = 1, not_in_creative_inventory=1,
			deco_block = 1, dig_immediate = 3, dig_by_water = 0, dig_by_piston = 1,
			destroy_by_lava_flow = 1, compostability = 30
		},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		drop = "wild_update:propagule",
		node_placement_prediction = "",
		node_dig_prediction = "mcl_core:dirt",
		after_dig_node = function(pos)
			local node = minetest.get_node(pos)
			if minetest.get_item_group(node.name, "dirt") == 0 then
				minetest.set_node(pos, {name="mcl_core:dirt"})
			end
		end,
		_mcl_hardness = 0,
		_mcl_blast_resistance = 0,
		_mcl_silk_touch_drop = true,
	})

--------------
-- node changer--
minetest.override_item("wild_update:propagule",{
		on_place = function(itemstack, user, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick (pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		-- Place on dirt 
		if pointed_thing.under and node.name == "mcl_core:dirt" then
			local protname = user:get_player_name()
			if minetest.is_protected(pointed_thing.under, protname) then
				minetest.record_protection_violation(pointed_thing.under, protname)
				return itemstack
			end
			minetest.set_node(pointed_thing.under, { name = "wild_update:propagule_test", param2 = node.param2 })
			minetest.sound_play(mcl_sounds.node_sound_leaves_defaults{pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:take_item(1) -- 1 use
			return itemstack
		end
	end
end,
})
