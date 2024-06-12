--sculk stuff--

--sculk sensors--

--------------------------------------------------------------------

local S = minetest.get_translator(minetest.get_current_modname())

mcl_sculk = {}

local mt_sound_play = minetest.sound_play

local sounds = {
    footstep = {name = "mcl_sculk_block_2", },
    place = {name = "mcl_sculk_block_2", },
    dug = {name = "mcl_sculk_block", "mcl_sculk_2", },
}

---sculk sensor-----------------
------ List of specific wool nodes
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
"mcl_sculk:sculk_sensor_active",
"mcl_sculk:sculk_sensor_active_w_logged",
}

-- Ignored entities for detection
local ignored_entities = {
    "mcl_sculk:vibration",
}

-- Function to check if an entity is in the ignored_entities list
local function contains(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

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

-- Function to calculate velocity
local function calculate_velocity(pos1, pos2, speed)
    local direction = vector.direction(pos1, pos2)
    return vector.multiply(direction, speed)
end

--------------------------------------------
--FIXME Experimental water logging code, to be redo 
-- List of sculk nodes
local sculk_nodes = {
    "mcl_sculk:sculk_sensor_inactive",
    "mcl_sculk:sculk_sensor_inactive_w_logged",
    "mcl_sculk:sculk_sensor_active",
    "mcl_sculk:sculk_sensor_active_w_logged",
}

-- Function to check if a node is a sculk node
local function isSculkNode(name)
    for _, sculk_node in ipairs(sculk_nodes) do
        if name == sculk_node then
            return true
        end
    end
    return false
end

-- Function to handle right-click interaction with buckets
local function handle_bucket_rightclick(pos, node_name, clicker)
    if isSculkNode(node_name) then
        local itemstack = clicker:get_wielded_item()
        -- Check if the itemstack is a water bucket
        if itemstack:get_name() == "mcl_buckets:bucket_water" then
            -- Change sensor block to the logged version
            local new_node_name = node_name:gsub("_w_logged$", "") .. "_w_logged"
            minetest.set_node(pos, {name = new_node_name})

            -- Replace water bucket with empty bucket
            clicker:set_wielded_item(ItemStack("mcl_buckets:bucket_empty"))

            -- Log the action
            minetest.log("action", clicker:get_player_name() .. " transformed " .. node_name .. " to " .. new_node_name)
        elseif itemstack:get_name() == "mcl_buckets:bucket_empty" then
            -- Change sculk block back to the original version
            local original_node_name = node_name:gsub("_w_logged$", "")
            minetest.set_node(pos, {name = original_node_name})

            -- Replace empty bucket with water bucket
            clicker:set_wielded_item(ItemStack("mcl_buckets:bucket_water"))

            -- Log the action
            minetest.log("action", clicker:get_player_name() .. " transformed " .. node_name .. " to " .. original_node_name)
        end
    else
        -- Check if the itemstack is a bucket
        local itemstack = clicker:get_wielded_item()
        if itemstack:get_name() == "mcl_buckets:bucket_empty" then
            -- Replace empty bucket with water bucket
            clicker:set_wielded_item("mcl_buckets:bucket_water")  -- Set the wielded item   
            return
        elseif itemstack:get_name() == "mcl_buckets:bucket_water" then
            -- Replace water bucket with empty bucket
            clicker:set_wielded_item("mcl_buckets:bucket_empty")  -- Set the wielded item
            return
        end
    end
end


-- Function to play sound at a specific position
local function play_sound(pos, sound)
    minetest.sound_play(sound, {
        pos = pos,
        gain = 1.0,
        max_hear_distance = 32,
    })
end

-- Sound mappings for specific nodes
local node_sounds = {
    ["mcl_sculk:sculk_sensor_inactive"] = "mcl_sculk_shrieking",
    -- Add more mappings for other nodes here
}

-- Function to swap sculk_sensor_inactive to sculk_sensor_active and back
local function swap_nodes(pos, node)
    local node_name = minetest.get_node(pos).name
    if node_name == "mcl_sculk:sculk_sensor_inactive" then
        minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor_active"})
        mesecon.receptor_on(pos, mesecon.rules.alldirs)
        local sound = node_sounds[node_name] or "default_dig_oddly_breakable_by_hand"
        play_sound(pos, sound)
    elseif node_name == "mcl_sculk:sculk_sensor_inactive_w_logged" then
        minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor_active_w_logged"})
        mesecon.receptor_on(pos, mesecon.rules.alldirs)
    end
    
    minetest.after(1.5, function()
        if minetest.get_node(pos).name == "mcl_sculk:sculk_sensor_active" then
            minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor_inactive"})
            mesecon.receptor_off(pos, mesecon.rules.alldirs)
            cooldown = false
        elseif minetest.get_node(pos).name == "mcl_sculk:sculk_sensor_active_w_logged" then
            minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor_inactive_w_logged"})
            mesecon.receptor_off(pos, mesecon.rules.alldirs)
            cooldown = false
        end
    end)
end

--------------------------------------------------------
-- Define the traveling entity with an animated texture
minetest.register_entity("mcl_sculk:vibration", {
    initial_properties = {
        physical = false,
        collide_with_objects = false,
        pointable = false,
        visual = "sprite",
        textures = {"mcl_vibration.png"},
        spritediv = {x = 4, y = 1}, -- 4 frames horizontally, 1 frame vertically
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1.0, -- 1 second for a full cycle
        },
        velocity = {x = 0, y = 0, z = 0},
    },

    -- Store the target position
    target_pos = nil,

    -- Store the time since the entity was spawned
    time_since_spawn = 0,

    -- Store whether the entity has collided with wool
    collided_with_wool = false,

    on_step = function(self, dtime)
        -- Update time since spawn
        self.time_since_spawn = self.time_since_spawn + dtime

        if self.target_pos then
            local pos = self.object:get_pos()
            local dir = vector.direction(pos, self.target_pos)
            local distance = vector.distance(pos, self.target_pos)

            if distance < 0.25 or self.time_since_spawn > 0.4 or self.collided_with_wool then
                -- Remove the entity if it reaches the target node, takes too long, or collides with wool
                self.object:remove()
                return
            end

            -- Move towards the target node
            local velocity = vector.multiply(dir, 20) -- Speed of block per second
            self.object:set_velocity(velocity)

            -- Check for wool nodes in the path
            local step = 0.5  -- Adjust the step value as needed for more or less granularity
            local collision_pos = nil
            for t = 0, distance, step do
                local check_pos = vector.add(pos, vector.multiply(dir, t))
                local check_node = minetest.get_node(check_pos)

                if check_node and isWoolNode(check_node.name) then
                    -- Wool node detected in the path, set collision flag and store collision position
                    self.collided_with_wool = true
                    collision_pos = check_pos
                    break
                end
            end

            if self.collided_with_wool then
                -- Remove the entity if it collides with wool
                self.object:remove()
                return
            end
        end
    end,
})

-------------------------------------------
local cooldown_timer = 0
-- Function to handle node change (placement or digging) within spherical range
local function handle_node_change(pos)
    if cooldown_timer > 0 then
        return
    end

    local radius = 8 -- Specify the spherical radius here

    local nodes_around = {}
    for x = -radius, radius do
        for y = -radius, radius do
            for z = -radius, radius do
                local node_pos = vector.add(pos, {x = x, y = y, z = z})
                if vector.distance(pos, node_pos) <= radius then
                    local node_name = minetest.get_node(node_pos).name
                    if (node_name == "mcl_sculk:sculk_sensor_inactive" or node_name == "mcl_sculk:sculk_sensor_inactive_w_logged") and not raycast_for_wool(pos, node_pos) then
                        table.insert(nodes_around, node_pos)
                    end
                end
            end
        end
    end
    
    for _, node_pos in ipairs(nodes_around) do
        -- Spawn the traveling entity instead of a particle
        local entity = minetest.add_entity(pos, "mcl_sculk:vibration")
        entity:get_luaentity().target_pos = node_pos
        swap_nodes(node_pos, minetest.get_node(node_pos))
    end
end

-- Function to handle player motion detection and node contact
local function handle_player_motion_and_contact()
    if cooldown_timer > 0 then
        return
    end

    local players = minetest.get_connected_players()
    local radius = 8 -- Specify the spherical radius here

    for _, player in ipairs(players) do
        local player_meta = player:get_meta()
        local prev_pos_str = player_meta:get_string("prev_pos")
        local prev_pos = minetest.string_to_pos(prev_pos_str)
        local player_pos = player:get_pos()

        -- Check if the previous position exists and the player has moved
        if prev_pos and vector.distance(prev_pos, player_pos) > 0.1 then
            -- Player is in motion, check if not sneaking and touching a node
            if not player:get_player_control().sneak then
                local node_pos_below = vector.round({x = player_pos.x, y = player_pos.y - 1, z = player_pos.z})
                local node_below = minetest.get_node(node_pos_below)

                if minetest.registered_nodes[node_below.name] and minetest.registered_nodes[node_below.name].walkable then
                    -- Player is in motion, not sneaking, and touching a walkable node, trigger the desired actions
                    handle_node_change(player_pos)
                end
            end
        end

        -- Update the player's previous position
        player_meta:set_string("prev_pos", minetest.pos_to_string(player_pos))
    end
end

-- Register globalstep to periodically check for player motion and node contact
minetest.register_globalstep(function(dtime)
    handle_player_motion_and_contact()
end)

-- Ensure that the prev_pos is set when the player joins the game
minetest.register_on_joinplayer(function(player)
    local player_meta = player:get_meta()
    local player_pos = player:get_pos()
    player_meta:set_string("prev_pos", minetest.pos_to_string(player_pos))
end)

-- Function to handle entity detection
local function handle_entity_detection(pos)
    local radius = 8 -- Specify the spherical radius here

    local objects = minetest.get_objects_inside_radius(pos, radius)
    for _, obj in ipairs(objects) do
        local obj_pos = obj:get_pos()
        local obj_name = obj:get_luaentity() and obj:get_luaentity().name

        -- Check if the entity is not in the ignored_entities list
        if obj_pos and obj_pos ~= pos and obj_name and not contains(ignored_entities, obj_name) then
            local entity_velocity = obj:get_velocity()
            if entity_velocity and vector.length(entity_velocity) > 0 then
                handle_node_change(obj_pos)
            end
        end
    end
end

-- Register ABM to periodically check for entities
minetest.register_abm({
    label = "Entity Detection",
    nodenames = {"mcl_sculk:sculk_sensor_inactive","mcl_sculk:sculk_sensor_inactive_w_logged"},
    interval = 1,  -- Adjust the interval as needed
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        handle_entity_detection(pos)
    end,
})

-- Register node placement callback
minetest.register_on_placenode(function(pos, new_node, placer, old_node, itemstack)
    -- Check if the placed node is not in the wool group
    if not isWoolNode(new_node.name) then
        handle_node_change(pos)
    end
end)

-- Register node digging callback
minetest.register_on_dignode(function(pos, old_node, digger)
    -- Check if the dug node is not in the wool group
    if not isWoolNode(old_node.name) then
        handle_node_change(pos)
    end
end)


-- Ensure other parts of the code as given above, e.g., handle_node_change, isWoolNode, and other relevant functions are correctly defined and used.


--- Define a list of nodes to be neglected during swapping
local ignored_nodes = {
    "mesecons_lightstone:lightstone_off",
    "mesecons_lightstone:lightstone_on",
    "mesecons_torch:mesecon_torch_off",
    "mesecons_torch:mesecon_torch_on",
    "mesecons_torch:mesecon_torch_on_wall",
    "mesecons_torch:mesecon_torch_off_wall",
    "mesecons_torch:mesecon_torch_overheated_wall",
    "mesecons_torch:mesecon_torch_overheated",
    "mesecons_pistons:piston_up_normal_off",
    "mesecons_pistons:piston_up_sticky_off",
    "mesecons_pistons:piston_sticky_off",
    "mesecons_pistons:piston_normal_off",
    "mcl_sculk:sculk_sensor",
    "mcl_sculk:sculk_sensor_inactive",
    "mcl_sculk:sculk_sensor_active",
    "mcl_sculk:sculk_sensor_active_w_logged",
    "mcl_sculk:sculk_sensor_inactive_w_logged",
    "mesecons_commandblock:commandblock_off",
    "mesecons_commandblock:commandblock_on",
    "mcl_sculk:catalyst_bloom",
    "mcl_sculk:catalyst",
    "mesecons_delayer:delayer_off_locked",
    "mesecons_delayer:delayer_off_1",
    "mesecons_delayer:delayer_off_2",
    "mesecons_delayer:delayer_off_3",
    "mesecons_delayer:delayer_off_4",
    "mesecons_delayer:delayer_on_locked",
    "mesecons_delayer:delayer_on_1",
    "mesecons_delayer:delayer_on_2",
    "mesecons_delayer:delayer_on_3",
    "mesecons_delayer:delayer_on_4",
    "mcl_comparators:comparator_on_comp",
    "mcl_comparators:comparator_on_sub",
    "mcl_comparators:comparator_off_comp",
    "mcl_comparators:comparator_off_sub",
    "mcl_comparators:comparator_on_",
    "mcl_comparators:comparator_off_",
    "mcl_sculk:sculk_sensor_inactive",
    "mcl_sculk:sculk_sensor_active",
    "mcl_sculk:sculk_sensor_inactive_w_logged",
    "mcl_sculk:sculk_sensor_active_w_logged",
}

-- Store the original swap_node function
local old_swap_node = minetest.swap_node

-- Override the swap_node function
function minetest.swap_node(pos, node)
    -- Check if the node is in the ignored_nodes list
    for _, ignored_node in ipairs(ignored_nodes) do
        if node.name == ignored_node then
            -- Call the original swap_node function without further action
            old_swap_node(pos, node)
            return
        end
    end
    
    -- Call the original swap_node function
    old_swap_node(pos, node)
    
    -- Check if the swapped node is not in the wool group
    if not isWoolNode(node.name) then
        -- Call the function to handle the node swap action
        handle_node_change(pos)
    end
end

-- Store the original set_node function
local old_set_node = minetest.set_node

-- Override the set_node function
function minetest.set_node(pos, node)
    -- Check if the node is in the ignored_nodes list
    for _, ignored_node in ipairs(ignored_nodes) do
        if node.name == ignored_node then
            -- Call the original set_node function without further action
            old_set_node(pos, node)
            return
        end
    end
    
    -- Call the original set_node function
    old_set_node(pos, node)
    
    -- Check if the swapped node is not in the wool group
    if not isWoolNode(node.name) then
        -- Call the function to handle the node set action
        handle_node_change(pos)
    end
end

-- Register a callback for player eating events
minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing)
    -- Check if the user is a player
    if user and user:is_player() then
        local player_pos = user:get_pos()

        -- Spawn vibration particle entity at the player's position
        handle_player_motion_and_contact(player_pos, player_pos)
    end
end)

-------------------------------------------------
minetest.register_node("mcl_sculk:sculk_sensor", {
description = "Sculk Sensor",
	tiles = {
	{
	name = "mcl_sculk_sensor_tendril_inactive.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_tendril_inactive.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_top.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_side.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_bottom.png",
	animation = {
		type = "vertical_frames",

		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_transparent_water.png", ---water texture here
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 3.0,
	},
	backface_culling = false,
	}
		},
	use_texture_alpha = "blend",		
	drop = "",
	sounds = sounds,
	drawtype = 'mesh',
	mesh = 'mcl_sculk_sensor.obj',
	collision_box = {
			type = 'fixed',
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
   	selection_box = {
			type = "fixed",
   	 		fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
   	},
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1, xp=5},
	place_param2 = 1,
	is_ground_content = false,
	_mcl_blast_resistance = 1.5,
	_mcl_hardness = 1.5,
	_mcl_silk_touch_drop = true and {"mcl_sculk:sculk_sensor",},
    	on_construct = function(pos)
	minetest.after(0.1, function()
    		if minetest.get_node(pos).name == "mcl_sculk:sculk_sensor" then
      	minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor_inactive"})
    		end
  	end)
    	end,
})

minetest.register_node("mcl_sculk:sculk_sensor_inactive", {
description = "Sculk Sensor Inactive",
	tiles = {
	{
	name = "mcl_sculk_sensor_tendril_inactive.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_tendril_inactive.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_top.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_side.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_bottom.png",
	animation = {
		type = "vertical_frames",

		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_transparent_water.png", ---water texture here
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 3.0,
	},
	backface_culling = false,
	}
		},
	use_texture_alpha = "blend",		
	drop = "",
	sounds = sounds,
	drawtype = 'mesh',
	mesh = 'mcl_sculk_sensor.obj',
	collision_box = {
			type = 'fixed',
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
   	selection_box = {
			type = "fixed",
   	 		fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
   	},
	groups = {handy = 1, hoey = 1, building_block=1, liquid=3, sculk = 1, not_in_creative_inventory=1, xp=5},
	place_param2 = 1,
	is_ground_content = false,
	_mcl_blast_resistance = 1.5,
	_mcl_hardness = 1.5,
	_mcl_silk_touch_drop = true and {"mcl_sculk:sculk_sensor"},
    	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        	handle_bucket_rightclick(pos, node.name, clicker)
    	end,
})

minetest.register_node("mcl_sculk:sculk_sensor_active", {
description = "Sculk Sensor Active",
	tiles = {
	{
	name = "mcl_sculk_sensor_tendril_active.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1.0,
	}},
	{
	name = "mcl_sculk_sensor_tendril_active.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1.0,
	}},
	{
	name = "mcl_sculk_sensor_top.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_side.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_bottom.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_transparent_water.png", ---water texture here
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 3.0,
	},
	backface_culling = false,
	}
		},
	use_texture_alpha = "blend",
	drop = "",
	sounds = sounds,
	use_texture_alpha = "clip",
	drawtype = 'mesh',
	mesh = 'mcl_sculk_sensor.obj',
	collision_box = {
			type = 'fixed',
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
   	selection_box = {
			type = "fixed",
   	 		fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
   	},
	groups = {handy = 1, hoey = 1, building_block=1, liquid=3, sculk = 1, not_in_creative_inventory=1,  xp=5},
	place_param2 = 1,
	is_ground_content = false,
	_mcl_silk_touch_drop = true and {"mcl_sculk:sculk_sensor"},
	light_source  = 3,
	_mcl_blast_resistance = -1,
	_mcl_hardness = 1.5,
    		on_construct = function(pos)
		mesecon.receptor_on(pos, mesecon.rules.alldirs)
	minetest.after(1.5, function()
	mesecon.receptor_off(pos, mesecon.rules.alldirs)
 
  	end)
    	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        	handle_bucket_rightclick(pos, node.name, clicker)
    	end,
})

----------------water_logged

minetest.register_node("mcl_sculk:sculk_sensor_inactive_w_logged", {
	description = "Sculk Sensor Inactive Water Logged",
	drawtype = 'mesh',
	mesh = 'mcl_sculk_sensor.obj',
	tiles = {
	{
	name = "mcl_sculk_sensor_tendril_inactive.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_tendril_inactive.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_top.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_side.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_bottom.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_core_water_source_animation_colorised.png", ---water texture here
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 3.0,
	},
	backface_culling = false,
	}
		},
	use_texture_alpha = "blend",		
	drop = "",
	sounds = sounds,
	collision_box = {
			type = 'fixed',
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
   	selection_box = {
			type = "fixed",
   	 		fixed = {-0.5, -0.5, -0.5, 0.5, 0.25, 0.5},
   	},
---
	groups = {handy = 1, hoey = 1, water=3, liquid=3, puts_out_fire=1, building_block=1, sculk = 1, not_in_creative_inventory=1, waterlogged = 1,  xp=5},
	place_param2 = 1,
	is_ground_content = false,
	_mcl_blast_resistance = -1,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true and {"mcl_sculk:sculk_sensor"},
    	on_timer = function(pos)
        	-- Call the function for player and entity detection
        		detect_player_and_entities(pos)
        			return true
    	end,
	after_dig_node = function(pos)
		local node = minetest.get_node(pos)
		local dim = mcl_worlds.pos_to_dimension(pos)
		if minetest.get_item_group(node.name, "water") == 0 and dim ~= "nether" then
			minetest.set_node(pos, {name="mcl_core:water_source"})
		else
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        	handle_bucket_rightclick(pos, node.name, clicker)
    end,
})


minetest.register_node("mcl_sculk:sculk_sensor_active_w_logged", {
	description = "Sculk Sensor Active Water Logged",
	drawtype = 'mesh',
	mesh = 'mcl_sculk_sensor.obj',
	tiles = {
	{
	name = "mcl_sculk_sensor_tendril_active.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1.0,
	}},
	{
	name = "mcl_sculk_sensor_tendril_active.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1.0,
	}},
	{
	name = "mcl_sculk_sensor_top.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_side.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_bottom.png",
	animation = {
		type = "vertical_frames",

		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_core_water_source_animation_colorised.png", ---water texture here
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 3.0,
	},
	backface_culling = false,
	}
		},
	use_texture_alpha = "blend",		
	drop = "",
	sounds = sounds,
	collision_box = {
			type = 'fixed',
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
   	selection_box = {
			type = "fixed",
   	 		fixed = {-0.5, -0.5, -0.5, 0.5, 0.25, 0.5},
   	},
	groups = {handy = 1, hoey = 1, liquid=3, puts_out_fire=1, building_block=1, sculk = 1, not_in_creative_inventory=1, waterlogged = 1,  xp=5},
	liquids_pointable = true,
	place_param2 = 1,
	is_ground_content = false,
	_mcl_blast_resistance = 3,
	light_source  = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true and {"mcl_sculk:sculk_sensor"},
	on_construct = function(pos)
		mesecon.receptor_on(pos, mesecon.rules.alldirs)
	minetest.after(1.6, function()
	mesecon.receptor_off(pos, mesecon.rules.alldirs)
    		if minetest.get_node(pos).name == "mcl_sculk:sculk_sensor_active_w_logged" then
      	minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor_inactive_w_logged"})
    		end
  	end)
    	end,
	after_dig_node = function(pos)
		local node = minetest.get_node(pos)
		local dim = mcl_worlds.pos_to_dimension(pos)
		if minetest.get_item_group(node.name, "water") == 0 and dim ~= "nether" then
			minetest.set_node(pos, {name="mcl_core:water_source"})
		else
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        	handle_bucket_rightclick(pos, node.name, clicker)
    end,
})

-------------------------------------------------
minetest.register_abm({
    label = "sculk_sensor_active to sculk_sensor_inactive",
    nodenames = {"group:sculk", },
    interval = 2.5,
    chance = 1,
    action = function(pos)
        local node = minetest.get_node(pos)
        if node.name == "mcl_sculk:sculk_sensor"or
           node.name == "mcl_sculk:sculk_sensor_active" then
            local meta = minetest.get_meta(pos)
            local creation_time = meta:get_int("creation_time") or 0
            local current_time = minetest.get_gametime()

            -- Check if the node has existed for at least 5 seconds (100 ticks per second)
            local existence_time = current_time - creation_time
            local existence_seconds = existence_time / 100
            if existence_seconds >= 5 then
                -- Revert to inactive sculk sensor node after turning off mesecon signal
                mesecon.receptor_off(pos, mesecon.rules.alldirs)
                minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor_inactive"})
            end
        end
    end,
})

minetest.register_abm({
    label = "sculk_sensor_active_w_logged to sculk_sensor_inactive_w_logged",
    nodenames = {"mcl_sculk:sculk_sensor_active_w_logged"},
    interval = 2.5,
    chance = 1,
    action = function(pos)
        local node = minetest.get_node(pos)
        if node.name == "mcl_sculk:sculk_sensor_active_w_logged" then
            local meta = minetest.get_meta(pos)
            local creation_time = meta:get_int("creation_time") or 0
            local current_time = minetest.get_gametime()

            -- Check if the node has existed for at least 5 seconds (100 ticks per second)
            local existence_time = current_time - creation_time
            local existence_seconds = existence_time / 100
            if existence_seconds >= 5 then
                -- Revert to inactive sculk sensor node after turning off mesecon signal
                mesecon.receptor_off(pos, mesecon.rules.alldirs)
                minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor_inactive_w_logged"})
            end
        end
    end,
})

-------------------------------------------------------------------------------------------------------------
--[[--
--WIP function to register Sculk Sensor node
local function register_sculk_sensor(name, description, tendril_texture, water_texture)
    local node_def = {
        description = "Sculk Sensor",
        tiles = {
	{
	name = tendril_texture,
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = tendril_texture,
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_top.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_side.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "mcl_sculk_sensor_bottom.png",
	animation = {
		type = "vertical_frames",

		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
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
	use_texture_alpha = "blend",	
	drop = "",
	sounds = sounds,
	mesh = 'mcl_sculk_sensor.obj',
	collision_box = {
			type = 'fixed',
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
   	selection_box = {
			type = "fixed",
   	 		fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
   	},
        groups = {handy = 1, hoey = 1, building_block=1, sculk = 1, xp=5},
        place_param2 = 1,
	is_ground_content = false,
	_mcl_hardness = 1.5,
	_mcl_silk_touch_drop = true and {"mcl_sculk:sculk_sensor",},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        	handle_bucket_rightclick(pos, node.name, clicker)
    	end,
}

    minetest.register_node(name, node_def)
end

-- Register particle emitter nodes
register_sculk_sensor("mcl_sculk:sculk_sensor", "mcl_sculk_sensor_tendril_inactive.png", "mcl_transparent_water.png")
register_sculk_sensor("mcl_sculk:sculk_sensor_inactive", "mcl_sculk_sensor_tendril_inactive.png", "mcl_transparent_water.png")
register_sculk_sensor("mcl_sculk:sculk_sensor_active", "mcl_sculk_sensor_tendril_active.png", "mcl_transparent_water.png")
register_sculk_sensor("mcl_sculk:sculk_sensor_inactive_w_logged", "mcl_sculk_sensor_tendril_inactive.png", "mcl_core_water_source_animation_colorised.png")
register_sculk_sensor("mcl_sculk:sculk_sensor_active_w_logged", "mcl_sculk_sensor_tendril_active.png", "mcl_core_water_source_animation_colorised.png")

--For adding other features of sculk sensor

minetest.override_item("mcl_sculk:sculk_sensor",{
	groups = {handy = 1, hoey = 1, building_block=1, liquid=3, sculk = 1, not_in_creative_inventory=1,  xp=5},
	_mcl_blast_resistance = 1.5,
	on_construct = function(pos)
	minetest.after(0.1, function()
    		if minetest.get_node(pos).name == "mcl_sculk:sculk_sensor" then
      	minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor_inactive"})
    		end
  	end)
    	end,
})

minetest.override_item("mcl_sculk:sculk_sensor_inactive",{
	groups = {handy = 1, hoey = 1, building_block=1, liquid=3, sculk = 1, not_in_creative_inventory=1,  xp=5},
	_mcl_blast_resistance = 1.5,
})

minetest.override_item("mcl_sculk:sculk_sensor_active",{
	groups = {handy = 1, hoey = 1, building_block=1, liquid=3, sculk = 1, not_in_creative_inventory=1,  xp=5},
	_mcl_blast_resistance = 1.5,
	light_source  = 3,
	on_construct = function(pos)
		mesecon.receptor_on(pos, mesecon.rules.alldirs)
	minetest.after(1.6, function()
	mesecon.receptor_off(pos, mesecon.rules.alldirs)
    		if minetest.get_node(pos).name == "mcl_sculk:sculk_sensor_active" then
      	minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor_inactive"})
    		end
  	end)
    	end,
})

minetest.override_item("mcl_sculk:sculk_sensor_inactive_w_logged",{
	groups = {handy = 1, hoey = 1, liquid=3, puts_out_fire=1, building_block=1, sculk = 1, not_in_creative_inventory=1, waterlogged = 1,  xp=5},
	_mcl_blast_resistance = -1,
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

minetest.override_item("mcl_sculk:sculk_sensor_active_w_logged",{
	groups = {handy = 1, hoey = 1, liquid=3, puts_out_fire=1, building_block=1, sculk = 1, not_in_creative_inventory=1, waterlogged = 1,  xp=5},
	_mcl_blast_resistance = -1,
	light_source  = 3,
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
	on_construct = function(pos)
		mesecon.receptor_on(pos, mesecon.rules.alldirs)
	minetest.after(1.6, function()
	mesecon.receptor_off(pos, mesecon.rules.alldirs)
    		if minetest.get_node(pos).name == "mcl_sculk:sculk_sensor" then
      	minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor_inactive"})
    		end
  	end)
    	end,
})
--]]--
sculk_sensor_test.lua
38 KB
