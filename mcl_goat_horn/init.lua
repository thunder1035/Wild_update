-- Define the mod
mcl_goat_horn = {}

-- Define a table to store cooldown timers for players
mcl_goat_horn.cooldowns = {}

-- Define multiple Goat Horn items with different sounds and descriptions
local goat_horns = {
    {name = "goat_horn_1", sound = "mcl_goat_horn_sound_1", description = "Ponder"},
    {name = "goat_horn_2", sound = "mcl_goat_horn_sound_2", description = "Sing"},
    {name = "goat_horn_3", sound = "mcl_goat_horn_sound_3", description = "Seek"},
    {name = "goat_horn_4", sound = "mcl_goat_horn_sound_4", description = "Feel"},
    {name = "goat_horn_5", sound = "mcl_goat_horn_sound_5", description = "Admire"},
    {name = "goat_horn_6", sound = "mcl_goat_horn_sound_6", description = "Call"},
    {name = "goat_horn_7", sound = "mcl_goat_horn_sound_7", description = "Yearn"},
    {name = "goat_horn_8", sound = "mcl_goat_horn_sound_8", description = "Dream"},
}

for _, variant in ipairs(goat_horns) do
    minetest.register_craftitem("mcl_goat_horn:" .. variant.name, {
        description = variant.description,
        inventory_image = "mcl_goat_horn_goat_horn.png", -- Replace with your shared texture
        on_secondary_use = function(itemstack, user, pointed_thing)
            local player_name = user:get_player_name()

            -- Check if the player has a cooldown timer
            if not mcl_goat_horn.cooldowns[player_name] or mcl_goat_horn.cooldowns[player_name] <= 0 then
                -- Play the sound
                minetest.sound_play(variant.sound, {
                    to_player = player_name,
                    gain = 3.0,
                    max_hear_distance = 256,
                })

--[[--For Fun ;) (Not in MC)
                -- Spawn particles moving in the player's looking direction
                local player_pos = user:get_pos()
                local dir = user:get_look_dir()
                local particle_texture = "mcl_goat_horn_cooldown_particle.png"

                minetest.add_particlespawner({
                    amount = 10, -- Number of particles
                    time = 5, -- Duration of particle spawning (matches cooldown time)
                    minpos = vector.add(player_pos, {x = 0, y = 2, z = 0}), -- Start position
                    maxpos = vector.add(player_pos, vector.multiply(dir, 4)), -- End position based on look direction
                    minvel = {x = 0, y = 1, z = 0}, -- Minimum velocity
                    maxvel = {x = 0, y = 1, z = 0}, -- Maximum velocity
                    minexptime = 1, -- Minimum expiration time
                    maxexptime = 2, -- Maximum expiration time
                    minsize = 5, -- Minimum particle size
                    maxsize = 5, -- Maximum particle size
                    collisiondetection = false, -- Enable collision detection
                    collision_removal = false, -- Remove particles on collision
                    vertical = false, -- Allow particles to move vertically
                    texture = particle_texture, -- Particle texture
                })

--]]--

                -- Set a cooldown (in seconds) before the item can be used again
                mcl_goat_horn.cooldowns[player_name] = 5 -- Cooldown time is 5 seconds for all variants

                -- Automatically reset the cooldown after 5 seconds
                minetest.after(5, function()
                    if mcl_goat_horn.cooldowns[player_name] then
                        mcl_goat_horn.cooldowns[player_name] = 0 -- Reset the cooldown
                    end
                end)
            end

            return itemstack
        end,
    })
end
