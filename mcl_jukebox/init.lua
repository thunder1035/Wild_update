--#Music Disc 5--

mcl_jukebox.register_record("Music Disc 5", "Thunder1035", "disc_5", "mcl_jukebox_record_disc_5.png", "mcl_jukebox_track_9")

minetest.register_craftitem("mcl_jukebox:disc_fragment", {
description = "Disc Fragment",
inventory_image = "disc_fragment_5.png",
})

minetest.register_craft({
	output = "mcl_jukebox:record_9",
	recipe = {
		{"mcl_jukebox:disc_fragment", "mcl_jukebox:disc_fragment", "mcl_jukebox:disc_fragment"},
		{"mcl_jukebox:disc_fragment", "mcl_jukebox:disc_fragment", "mcl_jukebox:disc_fragment"},
		{"mcl_jukebox:disc_fragment", "mcl_jukebox:disc_fragment", "mcl_jukebox:disc_fragment"},
	}
})
minetest.register_alias("mcl_jukebox:record_9", "mcl_jukebox:record_disc_5")