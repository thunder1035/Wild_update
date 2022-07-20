--not in use until the full set is ready--

--sculk stuff--

--1)sculk block--
--2)sculk catalyst--
--3)sculk sensors--
--4)sculk shrieker--
--5)sculk vein--

--------------
local sculk = mcl_sounds.node_sound_sand_defaults({
	footstep = {name = "mcl_sculk_block",  gain = 0.4},
	dug      = {name = "mcl_sculk_block", gain = 0.44},
})
---------------
--1) sculk block--
minetest.register_node("mcl_sculk:sculk", {
	description = ("Sculk"),
	tiles = {
		{ name = "mcl_sculk.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 3.0,
		}, },
	},
	stack_max = 64,
	drop = "",
	groups = {handy = 1, hoey = 1, building_block=1,},
	sounds = sculk,
	is_ground_content = false,
	on_destruct = function(pos)
		mcl_experience.throw_xp(pos,math.random(15,43))
	end,
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.6,
	_mcl_silk_touch_drop = true,
})

--2)sculk catalyst--
--sculk catalyst off--
minetest.register_node("mcl_sculk:sculk_catalyst", {
	description = ("Sculk Catalyst"),
	tiles = {"mcl_sculk_catalyst_top.png",
	"mcl_sculk_catalyst_bottom.png","mcl_sculk_catalyst_side.png"
	},
	stack_max = 64,
	drop = "",
	groups = {handy = 1, hoey = 1, building_block=1,},
	sounds = sculk,
	is_ground_content = false,
	on_destruct = function(pos)
		mcl_experience.throw_xp(pos,math.random(20,20))
	end,
	_mcl_blast_resistance = 3,
	light_source  = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})

--sculk catalyst on--