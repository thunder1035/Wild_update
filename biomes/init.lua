--mangrove_swamp--

minetest.register_biome({
    name = "MangroveSwamp",
    node_top = "mcl_mud:mud",
    depth_top = 2,
    node_filler = "mcl_mud:mud",
    depth_filler = 3,
    y_max = 1000,
    y_min = -5,
    node_water_top = "mcl_core:water_source",
    depth_water_top = 3,
    node_water = "mcl_core:water_source",
    heat_point = 60,
    humidity_point = 90,
    _mcl_biome_type = "medium",
    _mcl_palette_index = 28,
})

minetest.register_decoration({
	deco_type = "simple",
	spawn_by = {"group:water"},
	num_spawn_by = 1,
	place_on = {"mcl_mud:mud"},
	sidelen = 8,
	noise_params = {
		offset = 0.08,
		scale = 0.03,
		spread = {x = 100, y = 100, z = 100},
		octaves = 3,
		persist = 0.6
		},
	flags = "force_placement",
	place_offset_y = -1,
	y_min = mcl_vars.overworld_min,
	y_max = -5,
	biomes = {"MangroveSwamp"},
	decoration = "mcl_ocean:seagrass_",
})

minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:grass_block_no_snow", "mcl_mud:mud"},
		noise_params = {
			offset = -0.3,
			scale = 0.7,
			spread = {x = 100, y = 100, z = 100},
			octaves = 3,
			persist = 0.7
		},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_flowers:tallgrass",
	})

		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"group:grass_block_no_snow", "mcl_mud:mud"},
			sidelen = 80,
			fill_ratio = 0.005,
			biomes = {"MangroveSwamp"},
			y_min = -2,
			y_max = mcl_vars.mg_overworld_max,
			schematic = minetest.get_modpath("biomes") .. "/schems/tree_1.mts",
			flags = "place_center_x, place_center_z",
    			rotation = "random",
})

		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"group:grass_block_no_snow", "mcl_mud:mud"},
			sidelen = 80,
			fill_ratio = 0.005,
			biomes = {"MangroveSwamp"},
			y_min = -2,
			y_max = mcl_vars.mg_overworld_max,
			schematic = minetest.get_modpath("biomes") .. "/schems/tree_2.mts",
			flags = "place_center_x, place_center_z",
    			rotation = "random",
})

		
		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"group:grass_block_no_snow", "mcl_mud:mud"},
			sidelen = 80,
			fill_ratio = 0.005,
			biomes = {"MangroveSwamp"},
			y_min = -2,
			y_max = mcl_vars.mg_overworld_max,
			schematic = minetest.get_modpath("biomes") .. "/schems/tree_3.mts",
			flags = "place_center_x, place_center_z",
    			rotation = "random",
})



