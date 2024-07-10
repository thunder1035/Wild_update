--sculk stuff--

--sculk shrieker--

--------------------------------------------------------------------

local S = minetest.get_translator(minetest.get_current_modname())

local mt_sound_play = minetest.sound_play

local sounds = {
    footstep = {name = "mcl_sculk_block_2", },
    place = {name = "mcl_sculk_block_2", },
    dug = {name = "mcl_sculk_block", "mcl_sculk_2", },
}

-- List of specific wool nodes
local wool = {
    "mcl_wool:white",
    "mcl_wool:grey",
    "mcl_wool:dark_grey",
    "mcl_wool:silver",
    "mcl_wool:black",
    "mcl_wool:red",
    "mcl_wool:yellow",
    "mcl_wool:green",
    "mcl_wool:cyan",
    "mcl_wool:blue",
    "mcl_wool:magenta",
    "mcl_wool:orange",
    "mcl_wool:violet",
    "mcl_wool:brown",
    "mcl_wool:pink",
    "mcl_wool:purple",
    "mcl_wool:lime",
    "mcl_wool:light_blue",
    "mcl_wool:black_carpet",
    "mcl_wool:blue_carpet",
    "mcl_wool:brown_carpet",
    "mcl_wool:cyan_carpet",
    "mcl_wool:green_carpet",
    "mcl_wool:grey_carpet",
    "mcl_wool:light_blue_carpet",
    "mcl_wool:lime_carpet",
    "mcl_wool:magenta_carpet",
    "mcl_wool:orange_carpet",
    "mcl_wool:pink_carpet",
    "mcl_wool:purple_carpet",
    "mcl_wool:red_carpet",
    "mcl_wool:silver_carpet",
    "mcl_wool:yellow_carpet",
    "mcl_wool:white_carpet",
}

-- Function to check if a node is in the wool list
local function isWoolNode(name)
    for _, wool_node in ipairs(wool) do
        if name == wool_node then
            return true
        end
    end
    return false
end

-- Function to perform raycasting to check for wool nodes in the path
local function raycast_for_wool(pos, target_pos)
    local dir = vector.direction(pos, target_pos)
    local step = 0.5  -- Adjust the step value as needed for more or less granularity

    for t = 0, vector.distance(pos, target_pos), step do
        local check_pos = vector.add(pos, vector.multiply(dir, t))
        local check_node = minetest.get_node(check_pos)

        if check_node and isWoolNode(check_node.name) then
            -- Wool node detected in the path, return true
            return true
        end
    end

    -- No wool node detected in the path, return false
    return false
end

-- Function to emit particles and play sound
local function emit_particles_and_sound(pos, sound)
    local emitter_pos = vector.add(pos, {x=0, y=1, z=0}) -- Position the emitter at the top face of the node

    -- Check if it's within the cooldown period
    local meta = minetest.get_meta(pos)
    local last_emission_time = meta:get_int("last_emission_time") or 0
    local cooldown_duration = 10  -- Cooldown duration in seconds
    local emission_duration = 4.5  -- Duration of particle emission in seconds
    local current_time = minetest.get_gametime()
    local time_since_last_emission = current_time - last_emission_time

    if time_since_last_emission < cooldown_duration then
        return true  -- Particle emission on cooldown, exit
    end

-- Emit particles if a player is nearby or a sculk sensor is detected
    local players_nearby = false
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_pos = player:get_pos()
        local distance = vector.distance(emitter_pos, player_pos)
        if distance <= 1 and not raycast_for_wool(emitter_pos, player_pos) then
            players_nearby = true
            break
        end
    end

    -- Check for sculk sensors in the vicinity
    local radius = 8
    local sculk_sensors = minetest.find_nodes_in_area(
        {x = pos.x - radius, y = pos.y - radius, z = pos.z - radius},
        {x = pos.x + radius, y = pos.y + radius, z = pos.z + radius},
        {"mcl_sculk:sculk_sensor_active", "mcl_sculk:sculk_sensor_active_w_logged"}
    )
    if #sculk_sensors > 0 then
        for _, sensor_pos in ipairs(sculk_sensors) do
            if not raycast_for_wool(emitter_pos, sensor_pos) then
                players_nearby = true
                break
            end
        end
    end

    -- If no players are nearby and no sculk sensor is detected, return without emitting particles
    if not players_nearby then
        return true
    end

    -- Spawn particles
    minetest.add_particlespawner({
        amount = 5,
        time = emission_duration,
        minpos = emitter_pos,
        maxpos = emitter_pos,
        minvel = {x = 0, y = 1, z = 0},
        maxvel = {x = 0, y = 1, z = 0},
        minacc = {x = 0, y = 1, z = 0},
        maxacc = {x = 0, y = 1, z = 0},
        minexptime = 1,
        maxexptime = 1,
        minsize = 10,
        maxsize = 10,
        collisiondetection = true,
        collision_removal = false,
        object_collision = true,
        vertical = false,
	horizontal = true,
        texture = "mcl_sculk_shriek.png^[opacity:128", -- Set the initial opacity to 128 (half-transparent)
	---texture = "mcl_sculk_shriek.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            frame_length = 1.5
        },
        glow = 14,
    })

    -- Play the sound effect when particles emit
    if sound then
        minetest.sound_play(sound, {pos = pos})
    end

    -- Update last emission time
    meta:set_int("last_emission_time", current_time)
    return true
end

-- Function to register particle emitter node
local function register_sculk_shrieker(name, description, texture_inside, water_texture, sound)
    minetest.register_node(name, {
        description = description,
        tiles = {
	{
	name = "mcl_sculk_shrieker_top.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1.0,
	}},
	{
	name = "mcl_sculk_shrieker_top.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1.0,
	}},
	{
	name = "mcl_sculk_shrieker_side.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1.0,
	}},
	{
	name = texture_inside,
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_shrieker_bottom.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1.0,
	}},
	{
	name = water_texture, ---water texture here
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 3.0,
	},
	backface_culling = true,
	}
		},
	sounds = sounds,
	use_texture_alpha = "blend",	
	drawtype = 'mesh',
	mesh = 'mcl_sculk_shrieker.obj',
	collision_box = {
		type = 'fixed',
		fixed = {-0.5000, -0.5000, -0.5000, 0.5000, 0.000, 0.5000}
	},
   	selection_box = {
  	 	type = "fixed",
   		fixed = {-0.5, -0.5, -0.5, 0.5, 0.25, 0.5},
   	},
	drop = "",
	sounds = sounds,
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,  xp=5},
	place_param2 = 1,
	is_ground_content = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true and {"mcl_sculk:shrieker"},
        on_timer = function(pos, elapsed)
            return emit_particles_and_sound(pos, sound)
        end,
        on_construct = function(pos)
            minetest.get_node_timer(pos):start(1)
        end,
    })
end

-- Register sculk shrieker nodes example-
register_sculk_shrieker("mcl_sculk:shrieker", "Sculk Shrieker", "mcl_sculk_shrieker_inner_top.png", "mcl_transparent_water.png", "mcl_sculk_shrieking")

register_sculk_shrieker("mcl_sculk:shrieker_can_summon", "Sculk Shrieker", "mcl_sculk_shrieker_can_summon_inner_top.png", "mcl_transparent_water.png", "mcl_sculk_shrieking")

register_sculk_shrieker("mcl_sculk:shrieker_w_logged", "Sculk Shrieker", "mcl_sculk_shrieker_inner_top.png", "mcl_core_water_source_animation_colorised.png", nil)

register_sculk_shrieker("mcl_sculk:shrieker_can_summon_w_logged", "Sculk Shrieker", "mcl_sculk_shrieker_can_summon_inner_top.png", "mcl_core_water_source_animation_colorised.png", nil)


--for adding features of water logged version
minetest.override_item("mcl_sculk:shrieker_can_summon_w_logged",{
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1, not_in_creative_inventory=1, waterlogged = 1,  xp=5},
	liquids_pointable = true,
	after_dig_node = function(pos)
		local node = minetest.get_node(pos)
		local dim = mcl_worlds.pos_to_dimension(pos)
		if minetest.get_item_group(node.name, "water") == 0 and dim ~= "nether" then
			minetest.set_node(pos, {name="mcl_core:water_source"})
		else
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
})

minetest.override_item("mcl_sculk:shrieker_w_logged",{
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1, not_in_creative_inventory=1, waterlogged = 1,  xp=5},
	liquids_pointable = true,
	after_dig_node = function(pos)
		local node = minetest.get_node(pos)
		local dim = mcl_worlds.pos_to_dimension(pos)
		if minetest.get_item_group(node.name, "water") == 0 and dim ~= "nether" then
			minetest.set_node(pos, {name="mcl_core:water_source"})
		else
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
})
