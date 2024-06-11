--------------------------------------------------------------------

local S = minetest.get_translator(minetest.get_current_modname())

mcl_froglight = {}

local mt_sound_play = minetest.sound_play

local sounds = {
	footstep = {name = "mcl_froglight", },
	dug      = {name = "mcl_froglight", },
	place = {name="mcl_froglight",},
}

--Ochre
minetest.register_node("mcl_froglight:ochre", {
	description = S("Ochre Froglight "),
	tiles = {
		"mcl_ochre_froglight_top.png",
		"mcl_ochre_froglight_side.png"
	},
	drop = "mcl_froglight:ochre",
	groups = {handy = 1, glass=1, building_block=1},
	paramtype = "light",
	paramtype2 = "facedir",
	sounds = sounds,
	light_source = 15,
	is_ground_content = false,
	_mcl_blast_resistance = 0.3,
	_mcl_hardness = 0.3,
	_mcl_silk_touch_drop = true,
})


--Pearlescent
minetest.register_node("mcl_froglight:pearlescent", {
	description = S("Pearlescent Froglight "),
	tiles = {
		"mcl_pearlescent_froglight_top.png",
		"mcl_pearlescent_froglight_side.png"
	},
	drop = "mcl_froglight:pearlescent",
	groups = {handy = 1, glass=1, building_block=1},
	paramtype = "light",
	paramtype2 = "facedir",
	sounds = sounds,
	light_source = 15,
	is_ground_content = false,
	_mcl_blast_resistance = 0.3,
	_mcl_hardness = 0.3,
	_mcl_silk_touch_drop = true,
})

--Verdant
minetest.register_node("mcl_froglight:verdant", {
	description = S("Verdant Froglight "),
	tiles = {
		"mcl_verdant_froglight_top.png",
		"mcl_verdant_froglight_side.png"
	},
	drop = "mcl_froglight:verdant",
	groups = {handy = 1, glass=1, building_block=1},
	paramtype = "light",
	paramtype2 = "facedir",
	sounds = sounds,
	light_source = 15,
	is_ground_content = false,
	_mcl_blast_resistance = 0.3,
	_mcl_hardness = 0.3,
	_mcl_silk_touch_drop = true,
})

--achievement
awards.register_achievement("mcl:froglights", {
	title = S("With our powers combined!"),
	description = S("Have all 3 froglights in your inventory"),
	icon = "froglight_award.png",
	type = "Advancement",
	group = "Husbandry",
})
