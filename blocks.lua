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

local register_sapling = function(subname, description, longdesc, tt_help, texture, selbox)
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
		groups = {dig_immediate=3, plant=1,sapling=1,non_mycelium_plant=1,attached_node=1,dig_by_water=1,dig_by_piston=1,destroy_by_lava_flow=1,deco_block=1},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("stage", 0)
		end,
		on_place = mcl_util.generate_on_place_plant_function(function(pos, node)
			local node_below = minetest.get_node_or_nil({x=pos.x,y=pos.y-1,z=pos.z})
			if not node_below then return false end
			local nn = node_below.name
			return ((minetest.get_item_group(nn, "grass_block") == 1) or
					nn=="mcl_core:podzol" or nn=="mcl_core:podzol_snow" or
					nn=="mcl_core:dirt")
		end),
		node_placement_prediction = "",
		_mcl_blast_resistance = 0,
		_mcl_hardness = 0,
	})
end
---

register_tree_trunk("tree", S("Mangrove Wood"), S("Mangrove Bark"), S("The trunk of an Mangrove tree."), "mcl_mangrove_log_top.png", "mcl_mangrove_log.png")
register_wooden_planks("wood", S("Mangrove Wood Planks"), {"mcl_mangrove_planks.png"})
register_sapling("propagule", S("mangrove_propagule"),
	S("When placed on soil (such as dirt) and exposed to light, an propagule will grow into an mangrove after some time."),
	S("Needs soil and light to grow"),
	"mcl_mangrove_propagule.png", {-5/16, -0.5, -5/16, 5/16, 0.5, 5/16})
register_leaves("mangroveleaves", S("Mangrove Leaves"), S("mangrove leaves are grown from mangrove trees."), {"mcl_mangrove_leaves.png"}, "mcl_core:propagule", true, {20, 16, 12, 10})

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
		{"wild_update:mangrove_wood", "wild_update:mangrove_wood"}
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
