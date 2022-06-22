--sculk stuff--

--1)sculk block--
--2)sculk catalyst--
--3)sculk sensors--
--4)sculk shrieker--
--5)sculk vein--

---------------
--1) sculk block--
minetest.register_node("wild_update:sculk", {
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
	sounds = mcl_sounds.node_sound_sand_defaults(),
	is_ground_content = false,
	on_destruct = function(pos)
		mcl_experience.throw_xp(pos,math.random(15,43))
	end,
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.6,
	_mcl_silk_touch_drop = true,
})
