Tadpol Model of Minecraft wildupdate for mcl_2 (mcl_5?)
By Thunder1035

-------
Animation Frames-
(0 to 10){Still}
(10 to 30){movement}


--FIXME todo-----------------------

--In [mobs_mc/init.lua] add
--dofile(path .. "/tadpole.lua") -- Thunder1035

--make tadpole grow into frog

--In [mcl_achievements/init.lua] add this awards)
--[
awards.register_achievement("mcl:bukkit_bukkit", {
	title = S("Bukkit Bukkit"),
	description = S("Catch a Tadpole in a Bucket"),
	icon = "mcl_buckets_tadpole_bucket.png",
	type = "Advancement",
	group = "Husbandry",
})
--]

--In [mobs_mc/axolotl.lua] add this in axolotl specific_attack)
--"mobs_mc:tadpole"

--In [mcl_buckets/fishbuckets.lua] add this in local fish names
--["tadpole"] = "Tadpole",
