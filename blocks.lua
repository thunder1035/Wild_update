--wild_update_blocks--

local S = minetest.get_translator("mcl_core")

local register_tree_trunk = function(subname, description_trunk, description_bark, longdesc, tile_inner, tile_bark)
minetest.register_node("wild_update:"..subname, {
		description = description_trunk,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		tiles = {tile_inner, tile_inner, tile_bark},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 64,
		groups = {handy=1,axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
	})

	minetest.register_craft({
		output = "wild_update:"..subname.."_bark 3",
		recipe = {
			{ "wild_update:"..subname, "wild_update:"..subname },
			{ "wild_update:"..subname, "wild_update:"..subname },
		}
	})
end

local register_wooden_planks = function(subname, description, tiles)
minetest.register_node("wild_update:"..subname, {
		description = description,
		_doc_items_longdesc = doc.sub.items.temp.build,
		_doc_items_hidden = false,
		tiles = tiles,
		stack_max = 64,
		is_ground_content = false,
		groups = {handy=1,axey=1, flammable=3,wood=1,building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_blast_resistance = 3,
		_mcl_hardness = 2,
	})
end

local register_leaves = function(subname, description, longdesc, tiles, sapling, drop_apples, sapling_chances, leafdecay_distance)
	local drop
	if leafdecay_distance == nil then
		leafdecay_distance = 4
	end
	local apple_chances = {200, 180, 160, 120, 40}
	local stick_chances = {50, 45, 30, 35, 10}
	
	local function get_drops(fortune_level)
		local drop = {
			max_items = 1,
			items = {
				{
					items = {sapling},
					rarity = sapling_chances[fortune_level + 1] or sapling_chances[fortune_level]
				},
				{
					items = {"mcl_core:stick 1"},
					rarity = stick_chances[fortune_level + 1]
				},
				{
					items = {"mcl_core:stick 2"},
					rarity = stick_chances[fortune_level + 1]
				},
			}
		}
		if drop_apples then
			table.insert(drop.items, {
				items = {"mcl_core:apple"},
				rarity = apple_chances[fortune_level + 1]
			})
		end
		return drop
	end
minetest.register_node("wild_update:"..subname, {
		description = description,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		drawtype = "allfaces_optional",
		waving = 2,
		place_param2 = 1, -- Prevent leafdecay for placed nodes
		tiles = tiles,
		paramtype = "light",
		stack_max = 64,
		groups = {handy=1,shearsy=1,swordy=1, leafdecay=leafdecay_distance, flammable=2, leaves=1, deco_block=1, dig_by_piston=1, fire_encouragement=30, fire_flammability=60},
		_mcl_shears_drop = true,
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0.2,
		_mcl_hardness = 0.2,
		_mcl_silk_touch_drop = true,
		_mcl_fortune_drop = { get_drops(1), get_drops(2), get_drops(3), get_drops(4) },
	})
end

local function register_sapling(subname, description, longdesc, tt_help, texture, selbox)
	minetest.register_node("wild_update:"..subname, {
		description = description,
		_tt_help = tt_help,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		drawtype = "plantlike",
		waving = 1,
		visual_scale = 1.0,
		tiles = {texture},
		inventory_image = texture,
		wield_image = texture,
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = selbox
		},
		stack_max = 64,
		groups = {
			plant = 1, sapling = 1, non_mycelium_plant = 1, attached_node = 1,
			deco_block = 1, dig_immediate = 3, dig_by_water = 0, dig_by_piston = 1,
			destroy_by_lava_flow = 1, compostability = 30
		},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("stage", 0)
		end,
		on_place = mcl_util.generate_on_place_plant_function(function(pos, node)
			local node_under = minetest.get_node_or_nil({x=pos.x,y=pos.y-1,z=pos.z})
			if not node_under then return false end
			local nn = node_under.name
			return ((minetest.get_item_group(nn, "grass_block") == 1) or
					nn=="mcl_core:podzol" or nn=="mcl_core:podzol_snow" or
					nn=="mcl_core:dirt")
		end),
		node_placement_prediction = "",
		_mcl_blast_resistance = 0,
		_mcl_hardness = 0,
	})
end


------------------------------------------

---plank,tree,leaves and sampling--

register_tree_trunk("mangrove_tree", S("Mangrove Wood"), S("Mangrove Bark"), S("The trunk of an Mangrove tree."), "mcl_mangrove_log_top.png", "mcl_mangrove_log.png")
register_wooden_planks("mangrove_wood", S("Mangrove Wood Planks"), {"mcl_mangrove_planks.png"})
register_sapling("propagule", S("mangrove_propagule"),
	S("When placed on soil (such as dirt) and exposed to light, an propagule will grow into an mangrove after some time."),
	S("Needs soil and light to grow"),
	"mcl_mangrove_propagule.png", {-5/16, -0.5, -5/16, 5/16, 0.5, 5/16})
register_leaves("mangroveleaves", S("Mangrove Leaves"), S("mangrove leaves are grown from mangrove trees."), {"mcl_mangrove_leaves.png"}, "mcl_core:propagule", true, {20, 16, 12, 10})

--doors and trapdoors--

mcl_doors:register_door("wild_update:mangrove_door", {
	description = ("mangrove door"),
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "mcl_mangrove_doors.png",
	groups = {handy=1,axey=1, material_wood=1, flammable=-1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 3,
	tiles_bottom = {"mcl_mangrove_door_bottom.png", "mcl_mangrove_planks.png"},
	tiles_top = {"mcl_mangrove_door_top.png", "mcl_mangrove_planks.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:mangrove_door 3",
	recipe = {
		{"wild_update:mangrove_wood", "wild_update:mangrove_wood"}, 
		{"wild_update:mangrove_wood", "wild_update:mangrove_wood"}, 
		{"wild_update:mangrove_wood", "wild_update:mangrove_wood"}, 
	}
})

local woods = {
	-- id, desc, texture, craftitem
	{ "trapdoor", S("Mangrove Trapdoor"), "mcl_mangrove_trapdoor.png", "mcl_mangrove_planks.png", "wild_update:mangrove_wood" },}

for w=1, #woods do
	mcl_doors:register_trapdoor("wild_update:"..woods[w][1], {
		description = woods[w][2],
		_doc_items_longdesc = S("Wooden trapdoors are horizontal barriers which can be opened and closed by hand or a redstone signal. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
		_doc_items_usagehelp = S("To open or close the trapdoor, rightclick it or send a redstone signal to it."),
		tile_front = woods[w][3],
		tile_side = woods[w][4],
		wield_image = woods[w][3],
		groups = {handy=1,axey=1, mesecon_effector_on=1, material_wood=1, flammable=-1},
		_mcl_hardness = 3,
		_mcl_blast_resistance = 3,
		sounds = mcl_sounds.node_sound_wood_defaults(),
	})

minetest.register_craft({
		output = "mcl_doors:"..woods[w][1].." 2",
		recipe = {
			{woods[w][5], woods[w][5], woods[w][5]},
			{woods[w][5], woods[w][5], woods[w][5]},
		}
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_doors:"..woods[w][1],
		burntime = 15,
	})
end

--fence and fence gates--

mcl_fences.register_fence_and_fence_gate(
	"mangrove_wood_fence",
	S("Mangrove Wood Fence"), S("Mangrove Wood Plank Fence"),
	"mcl_mangrove_fence.png",
	{handy=1,axey=1, flammable=2,fence_wood=1, fire_encouragement=5, fire_flammability=20},
	minetest.registered_nodes["mcl_core:wood"]._mcl_hardness,
	minetest.registered_nodes["mcl_core:wood"]._mcl_blast_resistance,
	{"group:fence_wood"},
	mcl_sounds.node_sound_wood_defaults(), "wild_update_mangrove_wood_fence_gate_open", "wild_update_mangrove_wood_fence_gate_close", 1, 1,
	"mcl_mangrove_fence_gate.png")

minetest.register_craft({
		output = "wild_update:mangrove_wood_fence_gate",
		recipe = {
			{"mcl_core:stick", "wild_update:mangrove_wood", "mcl_core:stick"},
			{"mcl_core:stick", "wild_update:mangrove_wood", "mcl_core:stick"},
		}
	})

minetest.register_craft({
		output = "wild_update:mangrove_wood_fence 3",
		recipe = {
			{"wild_update:mangrove_wood", "mcl_core:stick", "wild_update:mangrove_wood"},
			{"wild_update:mangrove_wood", "mcl_core:stick", "wild_update:mangrove_wood"},
		}
	})

minetest.register_craft({
		output = "wild_update:wood 4",
		recipe = {
			{"wild_update:mangrove_tree"},
		}
	})

minetest.register_craft({
	type = "fuel",
	recipe = "group:fence_wood",
	burntime = 15,
})

---stairs and slabs---

local woods = {
	{ "mangrove_wood", "mcl_mangrove_planks.png", S("Mangrove Wood Stairs"), S("Mangrove Wood Slab"), S("Double Mangrove Wood Slab") },}

for w=1, #woods do
	local wood = woods[w]
	mcl_stairs.register_stair(wood[1], "mcl_core:"..wood[1],
			{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
			{wood[2]},
			wood[3],
			mcl_sounds.node_sound_wood_defaults(), 3, 2,
			"woodlike")
	mcl_stairs.register_slab(wood[1], "mcl_core:"..wood[1],
			{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
			{wood[2]},
			wood[4],
			mcl_sounds.node_sound_wood_defaults(), 3, 2,
			wood[5])
end

------testing------

minetest.register_node("wild_update:mangrove_roots", {
	description = "Mangrove_Roots",
	_doc_items_longdesc = "Mangrove roots are decorative blocks that form as part of mangrove trees.",
	_doc_items_hidden = false,
	drawtype = "allfaces_optional",
	waving = 0,
	place_param2 = 1, -- Prevent leafdecay for placed nodes
	tiles = {
		"mcl_mangrove_roots_top.png", "mcl_mangrove_roots_top.png",
		"mcl_mangrove_roots_side.png", "mcl_mangrove_roots_side.png",
		"mcl_mangrove_roots_side.png", "mcl_mangrove_roots_side.png"
	},
	paramtype = "light",
	stack_max = 64,
	groups = {
		handy = 1, hoey = 1, shearsy = 1, swordy = 1, dig_by_piston = 0,
		leaves = 1, leafdecay = leafdecay_distance, deco_block = 1,
		flammable = 2, fire_encouragement = 30, fire_flammability = 60,
		compostability = 30
	},
	drop = "wild_update:mangrove_roots",
	_mcl_shears_drop = true,
	sounds = mcl_sounds.node_sound_leaves_defaults(),			_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = { "wild_update:mangrove_roots 1", "wild_update:mangrove_roots 2", "wild_update:mangrove_roots 3", "wild_update:mangrove_roots 4" },
})

--
-- watered_roots on mangrove roots near water
--

local watered_root_correspondences = {
	["wild_update:mangrove_roots"] = "wild_update:water_logged_roots",
}
minetest.register_abm({
	label = "watered_root",
	nodenames = {"wild_update:mangrove_roots"},
	neighbors = {"mcl_core:water_source","mcl_core:water_flowing"},
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

minetest.register_node("wild_update:water_logged_roots", {
	description = ("water_logged_mangrove_roots"),
	_doc_items_entry_name = S("water_logged_roots"),
	_doc_items_longdesc =
("Mangrove roots are decorative blocks that form as part of mangrove trees.").."\n\n"..
("Mangrove roots, despite being a full block, can be waterlogged and do not flow water out").."\n\n"..
("These cannot be crafted yet only occure when get in contact of water."),
	_doc_items_hidden = false,
	drawtype = "liquid",
	tiles = {
		"water_logged_roots.png^mcl_mangrove_roots_top.png", "water_logged_roots.png^mcl_mangrove_roots_top.png",
		"water_logged_roots.png^mcl_mangrove_roots_side.png", "water_logged_roots.png^mcl_mangrove_roots_side.png",
		"water_logged_roots.png^mcl_mangrove_roots_side.png", "water_logged_roots.png^mcl_mangrove_roots_side.png"
	},
	sounds = mcl_sounds.node_sound_water_defaults(),
	is_ground_content = false,
	paramtype = "light",
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = true,
	drop = "wild_update:mangrove_roots",
	stack_max = 64,
		groups = {
		handy = 1, hoey = 1, shearsy = 1, swordy = 1, dig_by_piston = 1,
		leaves = 1, leafdecay = leafdecay_distance, deco_block = 1,
		flammable = 2, not_in_creative_inventory=1, fire_encouragement = 30, fire_flammability = 60,
		compostability = 30
	},
	_mcl_blast_resistance = 10,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
})

----------testing--------------

minetest.register_node("wild_update:hanging_propagule_1", {
	description = S("Hanging Propagule"),
	_tt_help = S("Grows on Mangrove leaves"),
	_doc_items_longdesc = "",
	_doc_items_usagehelp = "",
	groups = {
			plant = 1, not_in_creative_inventory=1, non_mycelium_plant = 1,
			deco_block = 1, dig_immediate = 3, dig_by_water = 0, dig_by_piston = 1,
			destroy_by_lava_flow = 1, compostability = 30
		},
	paramtype = "light",
	paramtype2 = "",
	on_rotate = false,
	walkable = false,
	drop = "wild_update:propagule",
	use_texture_alpha = "clip",
	drawtype = 'mesh',
    	mesh = 'propagule_hanging.obj',
selection_box = {
	type = "fixed",
	fixed = {
		{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Base
	},
},
	tiles = {"mcl_mangrove_propagule_hanging.png"},
	inventory_image = "mcl_mangrove_propagule.png",
	wield_image = "mcl_mangrove_propagule.png",
})

--minetest.register_abm({
--    nodenames = {"wild_update:mangroveleaves"},
--    interval = 1,
--   chance = 1,
--    action = function(pos, node, active_object_count, active_object_count_wider)
--        grow_pos = {pos.x, pos.y - 1, pos.z}
--       minetest.set_node(grow_pos, {name = "wild_update:mangroveleaves"})
--  end
--})
---------------------
local sp_blocks=("mcl_core:dirt"),("mcl_core:dirt_with_grass")
--------------------------------

local function coral_on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer then
		return itemstack
	end

	local player_name = placer:get_player_name()
	local pos_under = pointed_thing.under
	local pos_above = pointed_thing.above
	local node_under = minetest.get_node(pos_under)
	local def_under = minetest.registered_nodes[node_under.name]
	
	if (node_under ~= sp_blocks) then
		return itemstack
	end

	if def_under and def_under.on_rightclick and not placer:get_player_control().sneak then
		return def_under.on_rightclick(pos_under, node_under,
				placer, itemstack, pointed_thing) or itemstack
	end

	if pos_under.y >= pos_above.y then
		return itemstack
	end
	
	local g_block = minetest.get_item_group(node_under.name, "dirt")
	local g_coral = minetest.get_item_group(itemstack:get_name(), "propagule_test")
	-- Placement rules:
	-- Coral plant can only be placed on top of a matching coral block.
	if g_block == 0 or (g_coral ~= g_block) then
		return itemstack
	end

	if minetest.is_protected(pos_under, player_name) or
			minetest.is_protected(pos_above, player_name) then
		minetest.log("action", player_name
			.. " tried to place " .. itemstack:get_name()
			.. " at protected position "
			.. minetest.pos_to_string(pos_under))
		minetest.record_protection_violation(pos_under, player_name)
		return itemstack
	end

	node_under.name = itemstack:get_name()
	node_under.param2 = minetest.registered_items[node_under.name].place_param2 or 1
	if node_under.param2 < 8 and math.random(1,2) == 1 then
		-- Random horizontal displacement
		node_under.param2 = node_under.param2 + 8
	end
	minetest.set_node(pos_under, node_under)
	local def_node = minetest.registered_nodes[node_under.name]
	if def_node.sounds then
		minetest.sound_play(def_node.sounds.place, { gain = 0.5, pos = pos_under }, true)
	end
	if not minetest.is_creative_enabled(player_name) then
		itemstack:take_item()
	end

	return itemstack
end

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
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				{ -0.5, 0.5, -0.5, 0.5, 1.0, 0.5 },
			}
		},
		groups = { dig_immediate = 3, deco_block = 1, coral=1, coral_plant=1, coral_species=c, },
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		drop = "wild_update:propagule_test",
		node_placement_prediction = "",
		node_dig_prediction = "mcl_core:dirt",
		on_place = coral_on_place,
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


