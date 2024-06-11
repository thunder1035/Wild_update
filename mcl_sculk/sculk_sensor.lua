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
    --"mcl_sculk:sculk_sensor_active",
    --"mcl_sculk:sculk_sensor_active_w_logged",
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

-- Define Vibration
local function spawn_particle(pos, target_pos)
    -- Check for wool nodes using the raycasting function before spawning the vibration entity
    if raycast_for_wool(pos, target_pos) then
        -- Prevent vibration spawning if a wool node is detected in the path
        return
    end

    -- Spawn particle entity at the node position moving towards the target position
    local particle = minetest.add_entity(pos, "mcl_sculk:vibration")
    if particle then
        particle:get_luaentity():set_target(target_pos)
        particle:set_properties({
            physical = false,
            collisionbox = {0, 0, 0, 0, 0, 1},
            glow = 14  -- Adjust the glow value (0 to 14) to set the intensity of the glow
        })
        -- Schedule the removal of particle if it doesn't reach the target within seconds
        minetest.after(0.4, function()
            local vibration = particle:get_luaentity()
            if vibration and vibration.target then
                particle:remove()
            end
        end)
    end
end

-- Define Vibration Behavior
minetest.register_entity("mcl_sculk:vibration", {
    visual = "sprite",
    visual_size = {x = 0.8, y = 0.4},
    textures = {"mcl_vibration.png"},
    target = nil,
    on_step = function(self, _)
        local pos = self.object:get_pos()

        if self.target then
            local pos = self.object:get_pos()
            local dir = vector.direction(pos, self.target)
            local velocity = vector.multiply(dir, 20)  -- Increase velocity multiplier to speed up particles (adjust as needed)
            self.object:set_velocity(velocity)

            -- Check if the particle entity is near the emitter node
            local emitter_pos = self.target
            if emitter_pos then
                local distance = vector.distance(pos, emitter_pos)
                if distance <= 1 then -- Adjust the distance as needed
                    local node = minetest.get_node(emitter_pos)
                    if node and (node.name == "mcl_sculk:sculk_sensor_inactive" or node.name == "mcl_sculk:sculk_sensor_inactive_w_logged") then
                        -- Swap emitter node with active sculk sensor node if no other particles nearby
                        local objects = minetest.get_objects_inside_radius(emitter_pos, 1)
                        local found_other_particle = false
                        for _, obj in ipairs(objects) do
                            if obj:get_luaentity() and obj:get_luaentity().name == "mcl_sculk:vibration" and obj ~= self.object then
                                found_other_particle = true
                                break
                            end
                        end
                        if not found_other_particle then
                                  if node.name == "mcl_sculk:sculk_sensor_inactive_w_logged" then
	minetest.set_node(emitter_pos, {name = "mcl_sculk:sculk_sensor_active_w_logged"})
      end
      if node.name == "mcl_sculk:sculk_sensor_inactive" then
	minetest.set_node(emitter_pos, {name = "mcl_sculk:sculk_sensor_active"})
      end
                            self.object:remove()
                        end
                    end
                end
            end
      local node_below = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
      if isWoolNode(node_below.name) then
        -- Handle collision with wool nodes here
        -- For example, remove the particle entity when colliding with wool
        self.object:remove()
      end
        else
            self.object:remove()
        end
    end,

    set_target = function(self, target_pos)
        self.target = target_pos
    end,
})
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


-- mesecon-related functions---------------------
--TODO here signal strength is missing, but that is part of mesecons and cannot be done here
local function emit_mesecon_signal(pos)
  -- Emit mesecon signal when the node becomes a active sculk sensor node
  -- You may adjust the time (in seconds) the signal persists
  mesecon.receptor_on(pos, mesecon.rules.alldirs)

  local timer = minetest.get_node_timer(pos)
  timer:start(2.5) -- Adjust the duration of the mesecon signal as needed
end

local function stop_mesecon_signal(pos)
  -- Stop emitting mesecon signal when the node becomes a inactive sculk sensor
  mesecon.receptor_off(pos, mesecon.rules.alldirs)
          
end

--------------------------------------------------------
---Vibration Spawning and Detection Logic
-- Define a list of entities to be neglected by the Sculk Sensor
local ignored_entities = {
    "mcl_sculk:vibration",

    --"mobs_mc:warden",
}

-- Function to check if an element exists in a table
local function contains(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Modify the detect_player_and_entities function
local function detect_player_and_entities(pos)
    -- Player detection logic
    local players = minetest.get_connected_players()
    for _, player in ipairs(players) do
        local player_pos = player:get_pos()
        local distance = vector.distance(pos, player_pos)
        local ctrl = player:get_player_control()

        -- Check if the player is within a range of 8 and not sneaking, is moving, jumping, and not flying
        if distance <= 8 and not ctrl.sneak and (ctrl.up or ctrl.down or ctrl.left or ctrl.right or ctrl.jump) then
            local node_pos_below = vector.round({x = player_pos.x, y = player_pos.y - 1, z = player_pos.z})
            local node_below = minetest.get_node(node_pos_below)

            if minetest.registered_nodes[node_below.name] and minetest.registered_nodes[node_below.name].walkable then
                -- Player is in motion, not sneaking, and touching a walkable node, trigger the desired actions
                spawn_particle(player_pos, pos)
                local player_name = player:get_player_name()
                -- Check if the player is not in the ignored_entities list
                if not contains(ignored_entities, player_name) then
                    -- Spawn particle entity at player position moving towards emitter node
                    spawn_particle(player_pos, pos)
                end
            end
        end
    end

    -- Entity detection logic
    local objects = minetest.get_objects_inside_radius(pos, 8)
    for _, obj in ipairs(objects) do
        local obj_pos = obj:get_pos()
        local obj_name = obj:get_luaentity() and obj:get_luaentity().name

        -- Check if the entity is not in the ignored_entities list
        if obj_pos and obj_pos ~= pos and obj_name and not contains(ignored_entities, obj_name) then
            local entity_velocity = obj:get_velocity()
            if entity_velocity and vector.length(entity_velocity) > 0 then
                spawn_particle(obj_pos, pos)
            end
        end
    end
end

-- Node Change Detection logic
--TODO other nodes such as chest, noteblock, bell, etc will be needing other callbacks
local function scan_and_spawn_vibration(center_pos, spawn_pos)
    local range = 8 

    -- Iterate through nearby nodes within the detection range
    for x = -range, range do
        for y = -range, range do
            for z = -range, range do
                local check_pos = vector.add(center_pos, {x = x, y = y, z = z})
                local node_name = minetest.get_node(check_pos).name

                if node_name == "mcl_sculk:sculk_sensor_inactive" or
                   node_name == "mcl_sculk:sculk_sensor_inactive_w_logged" then
                    -- Spawn vibration at the specified spawn position
                    spawn_particle(spawn_pos, check_pos)
                end
            end
        end
    end
end
---------
local function handleNodeAction(pos)

local range = 8 

    -- Include both inactive and inactive water logged nodes in the search
    local node_names = {"mcl_sculk:sculk_sensor_inactive", "mcl_sculk:sculk_sensor_inactive_w_logged"}
    local node_pos = minetest.find_node_near(pos, range, node_names)

    if node_pos then
        -- Spawn vibration at the detected node position
        scan_and_spawn_vibration(pos, pos)
    end
end

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
        handleNodeAction(pos)
    end
end
---[[-------------------------------------------------
-- Store the original add_node function
local old_add_node = minetest.add_node

-- Override the add_node function
function minetest.add_node(pos, node)
    -- Check if the node is in the ignored_nodes list
    for _, ignored_node in ipairs(ignored_nodes) do
        if node.name == ignored_node then
            -- Call the original add_node function without further action
            old_add_node(pos, node)
            return
        end
    end
    
    -- Call the original add_node function
    old_add_node(pos, node)
    
    -- Check if the swapped node is not in the wool group
    if not isWoolNode(node.name) then
        -- Call the function to handle the node add action
        handleNodeAction(pos)
    end
end
--]]-------------------------------------------------
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
        handleNodeAction(pos)
    end
end

-- Register node placement callback
minetest.register_on_placenode(function(pos, new_node, placer, old_node, itemstack)
    -- Check if the placed node is not in the wool group
    if not isWoolNode(new_node.name) then
        handleNodeAction(pos)
    end
end)

-- Register node digging callback
minetest.register_on_dignode(function(pos, old_node, digger)
    -- Check if the dug node is not in the wool group
    if not isWoolNode(old_node.name) then
        handleNodeAction(pos)
    end
end)
---------------------
--[[ Override the on_rightclick function for vibration-triggering nodes
local vibration_trigger_nodes = {
 "group:container",
},

for _, node_name in ipairs(vibration_trigger_nodes) do
    minetest.override_item(node_name, {
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            spawn_vibration(pos)
        end,
    })
end
--]]

--------------------------------------------
-- Register a callback for player eating events
minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing)
    -- Check if the user is a player
    if user and user:is_player() then
        local player_pos = user:get_pos()

        -- Spawn vibration particle entity at the player's position
        scan_and_spawn_vibration(player_pos, player_pos)
    end
end)

--------------------------------------------
minetest.register_craftitem("mcl_sculk:vibration", {
    description = "Vibration",
    inventory_image = "mcl_vibration.png",
    groups = {not_in_creative_inventory=1,},
    on_place = function(itemstack, placer, pointed_thing)
        local pos = pointed_thing.under
        if pos then
            if not minetest.is_creative_enabled(placer:get_player_name()) then
                itemstack:take_item()
                return itemstack
            end
            -- Call the scan_and_spawn_vibration function with both positions
            scan_and_spawn_vibration(pos, pos)
        end
    end,
})
-------------------------------------------------
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
    	on_timer = function(pos)
       	 -- Call the function for player and entity detection
        		detect_player_and_entities(pos)
       	 	return true
    	end,
    	on_construct = function(pos)
    	 	minetest.after(0.1, function()
    	 	minetest.get_node_timer(pos):start(0.1)
  		end)
  	end,
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
	light_source  = 4,
	_mcl_blast_resistance = 1.5,
	_mcl_hardness = 1.5,
    	on_construct = function(pos)
        	-- Emit mesecon signal when the active sculk sensor node is created
        	mesecon.receptor_on(pos, mesecon.rules.alldirs)
        	emit_mesecon_signal(pos)
        	minetest.sound_play("mcl_sculk_sensor_active", {
        	pos = pos,
        	gain = 0.5,
        	max_hear_distance = 16
    		})
  	minetest.after(1.5, function()
    		if minetest.get_node(pos).name == "mcl_sculk:sculk_sensor_active" then
      		minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor"})
      		stop_mesecon_signal(pos)
    			end
  		minetest.sound_play("mcl_sculk_sensor_inactive", {
        	pos = pos,
        	gain = 0.2,
        	max_hear_distance = 16
    		})
  		end)
    	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        	handle_bucket_rightclick(pos, node.name, clicker)
    	end,
})

----------------water_logged

minetest.register_node("mcl_sculk:sculk_sensor_w_logged", {
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
    	on_construct = function(pos)
	minetest.after(0.1, function()
    		if minetest.get_node(pos).name == "mcl_sculk:sculk_sensor_w_logged" then
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
})

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
    	on_construct = function(pos)
    	 	minetest.after(0.1, function()
    	 	minetest.get_node_timer(pos):start(0.1)
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
	_mcl_blast_resistance = -1,
	light_source  = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true and {"mcl_sculk:sculk_sensor"},
    	on_construct = function(pos)
        	-- Emit mesecon signal when the active sculk sensor node is created
        	mesecon.receptor_on(pos, mesecon.rules.alldirs)
        	emit_mesecon_signal(pos)
        	minetest.sound_play("mcl_sculk_sensor_active", {
        	pos = pos,
        	gain = 0.5,
        	max_hear_distance = 16
    		})
  	minetest.after(1.5, function()
    		if minetest.get_node(pos).name == "mcl_sculk:sculk_sensor_active_w_logged" then
      		minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor_w_logged"})
      		stop_mesecon_signal(pos)
    			end
  		minetest.sound_play("mcl_sculk_sensor_inactive", {
        	pos = pos,
        	gain = 0.2,
        	max_hear_distance = 16
    		})
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


