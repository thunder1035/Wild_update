--Todo
Since recovery compass is already added in mcl_2, there will be no need of making one here.
But in that the crafting recipe is incorrect as Echo Shard is not added in that so this file contains the code only for Echo Shard.

--Add this to mcl_compass/init.lua in mcl_2
minetest.register_craftitem("mcl_compass:echo_shard",{
description = "Echo Shard",
inventory_image = "mcl_echo_shard.png",
})
