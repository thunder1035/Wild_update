--sculk stuff--

--1)sculk block--
--2)sculk catalyst--
--3)sculk sensors--
--4)sculk shrieker--
--5)sculk vein--

--------------------------------------------------------------------

local S = minetest.get_translator(minetest.get_current_modname())

mcl_sculk = {}

local mt_sound_play = minetest.sound_play

local spread_to = {"mcl_core:stone","mcl_core:dirt","mcl_core:sand","mcl_core:dirt_with_grass","group:grass_block","mcl_core:andesite","mcl_core:diorite","mcl_core:granite","mcl_core:mycelium","group:dirt","mcl_end:end_stone","mcl_nether:netherrack","mcl_blackstone:basalt","mcl_nether:soul_sand","mcl_blackstone:soul_soil","mcl_crimson:warped_nylium","mcl_crimson:crimson_nylium","mcl_core:gravel"}

local sounds = {
	footstep = {name = "mcl_sculk_block", },
	dug      = {name = "mcl_sculk_block", },
}

local SPREAD_RANGE = 8

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,1,0),
	vector.new(0,-1,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}


-----------------------------------------

local function get_node_xp(pos)
	local meta = minetest.get_meta(pos)
	return meta:get_int("xp")
end
local function set_node_xp(pos,xp)
	local meta = minetest.get_meta(pos)
	return meta:set_int("xp",xp)
end

local function sculk_on_destruct(pos)
	local xp = get_node_xp(pos)
	local n = minetest.get_node(pos)
	if n.param2 == 1 then
		xp = 1
	end
	local obs = mcl_experience.throw_xp(pos,xp)
	for _,v in pairs(obs) do
		local l = v:get_luaentity()
		l._sculkdrop = true
	end
end

local function has_air(pos)
	for _,v in pairs(adjacents) do
		if minetest.get_item_group(minetest.get_node(vector.add(pos,v)).name,"solid") <= 0 then return true end
	end
end

local function has_nonsculk(pos)
	for _,v in pairs(adjacents) do
		local p = vector.add(pos,v)
		if minetest.get_item_group(minetest.get_node(p).name,"sculk") <= 0 and minetest.get_item_group(minetest.get_node(p).name,"solid") > 0 then return p end
	end
end
local function retrieve_close_spreadable_nodes (p)
	local nnn = minetest.find_nodes_in_area(vector.offset(p,-SPREAD_RANGE,-SPREAD_RANGE,-SPREAD_RANGE),vector.offset(p,SPREAD_RANGE,SPREAD_RANGE,SPREAD_RANGE),spread_to)
	local nn={}
	for _,v in pairs(nnn) do
		if has_air(v) then
			table.insert(nn,v)
		end
	end
	table.sort(nn,function(a, b)
		return vector.distance(p, a) < vector.distance(p, b)
	end)
	return nn
end

local function spread_sculk (p, xp_amount)
	local c = minetest.find_node_near(p,SPREAD_RANGE,{"mcl_sculk:catalyst"})
	if c then
		local nn = retrieve_close_spreadable_nodes (p)
		if nn and #nn > 0 then
			if xp_amount > 0 then
				local d = math.random(100)
				--[[ --enable to generate shriekers and sensors
				if d <= 1 then
					minetest.set_node(nn[1],{name = "mcl_sculk:shrieker"})
					set_node_xp(nn[1],math.min(1,self._xp - 10))
					self.object:remove()
					return ret
				elseif d <= 9 then
					minetest.set_node(nn[1],{name = "mcl_sculk:sensor"})
					set_node_xp(nn[1],math.min(1,self._xp - 5))
					self.object:remove()
					return ret
				else --]]


				local r = math.min(math.random(#nn), xp_amount)
				--minetest.log("r: ".. r)

				for i=1,r do
					minetest.set_node(nn[i],{name = "mcl_sculk:sculk" })
					set_node_xp(nn[i],math.floor(xp_amount / r))
				end
				for i=1,r do
					local p = has_nonsculk(nn[i])
					if p and has_air(p) then
						minetest.set_node(vector.offset(p,0,1,0),{name = "mcl_sculk:vein", param2 = 1})
					end
				end
				set_node_xp(nn[1],get_node_xp(nn[1]) + xp_amount % r)
				return true
				--self.object:remove()
				--end
			end
		end
	end
end

function mcl_sculk.handle_death(pos, xp_amount)
	if not pos or not xp_amount then return end
	--local nu = minetest.get_node(vector.offset(p,0,-1,0))
	return spread_sculk (pos, xp_amount)
end

minetest.register_on_dieplayer(function(player)
	if mcl_sculk.handle_death(player:get_pos(), 5) then
		--minetest.log("Player is dead. Sculk")
	else
		--minetest.log("Player is dead. not Sculk")
	end
end)

minetest.register_node("mcl_sculk:sculk", {
	description = S("Sculk"),
	tiles = {
		{ name = "mcl_sculk_sculk.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 3.0,
		}, },
	},
	drop = "",
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	sounds = sounds,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.6,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_sculk:catalyst", {
	description = S("Sculk Catalyst"),
	tiles = {
		"mcl_sculk_catalyst_top.png",
		"mcl_sculk_catalyst_bottom.png",
		"mcl_sculk_catalyst_side.png"
	},
	drop = "",
	sounds = sounds,
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 3,
	light_source  = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_sculk:vein", {
	description = S("Sculk Vein"),
	_doc_items_longdesc = S("Sculk vein."),
	drawtype = "signlike",
	tiles = {
		{ name = "mcl_sculk_vein.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 3.0,
		}, },
	},
	inventory_image = "mcl_sculk_vein.png",
	wield_image = "mcl_sculk_vein.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	buildable_to = true,
	selection_box = {
		type = "wallmounted",
	},
	groups = {
		handy = 1, axey = 1, shearsy = 1, swordy = 1, deco_block = 1,
		dig_by_piston = 1, destroy_by_lava_flow = 1, sculk = 1, dig_by_water = 1,
	},
	sounds = sounds,
	drop = "",
	_mcl_shears_drop = true,
	node_placement_prediction = "",
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	on_rotate = false,
})

----------------
-- off sculk sensor
minetest.register_node("mcl_sculk:sculk_sensor_inactive", {
description = "Sculk Sensor",
tiles = {"mcl_sculk_sensor.png",
},
	overlay_tiles = {{
	name = "mcl_sculk_sensor_tendril_inactive.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 32,
		aspect_h = 16,
		length = 2.0,
	}},
},
	drop = "",
	sounds = sounds,
	use_texture_alpha = "clip",
	drawtype = 'mesh',
	mesh = 'mcl_sculk_sensor.obj',
	collision_box = {
			type = 'fixed',
			fixed = {-0.5000, -0.5000, -0.5000, 0.5000, 0.000, 0.5000}
		},
   	selection_box = {
  	  type = "fixed",
   	 fixed = {-0.5, -0.5, -0.5, 0.5, 0.25, 0.5},
   	},
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 1.5,
	_mcl_hardness = 1.5,
	_mcl_silk_touch_drop = true,
    --sounds = default.node_sound_stone_defaults(),
    	mesecons = {receptor = {
			state = mesecon.state.off,
		}},
})

--on sculk sensor
minetest.register_node("mcl_sculk:sculk_sensor_active", {
description = "Sculk Sensor active",
tiles = {"mcl_sculk_sensor.png",
},
	overlay_tiles = {{
	name = "mcl_sculk_sensor_tendril_active.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 32,
		aspect_h = 16,
		length = 1.0,
	}},
},
	drop = "mcl_sculk:sculk_sensor_inactive",
	sounds = sounds,
	use_texture_alpha = "clip",
	drawtype = 'mesh',
	mesh = 'mcl_sculk_sensor.obj',
	collision_box = {
			type = 'fixed',
			fixed = {-0.5000, -0.5000, -0.5000, 0.5000, 0.000, 0.5000}
		},
   	selection_box = {
  	  type = "fixed",
   	 fixed = {-0.5, -0.5, -0.5, 0.5, 0.25, 0.5},
   	},
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	light_source  = 3,
	_mcl_blast_resistance = 1.5,
	_mcl_hardness = 1.5,
    --sounds = default.node_sound_stone_defaults(),
    	mesecons = {receptor = {
			state = mesecon.state.on,
		}},
	
})

--back to on to off--
-- Revert replacement nodes back to emitter nodes
minetest.register_abm({
  label = "Active Sculk Check",
  nodenames = {"mcl_sculk:sculk_sensor_active"},
  interval = 2.5,
  chance = 1,
  action = function(pos)
    local node = minetest.get_node(pos)
    if node.name == "mcl_sculk:sculk_sensor_active" then
      local meta = minetest.get_meta(pos)
      local creation_time = meta:get_int("creation_time") or 0
      local current_time = minetest.get_gametime()

      -- Check if the node has existed for at least 5 seconds (100 ticks per second)
      local existence_time = current_time - creation_time
      local existence_seconds = existence_time / 100
      if existence_seconds >= 5 then
        -- Revert to particle emitter node after turning off mesecon signal
        stop_mesecon_signal(pos)
        minetest.set_node(pos, {name = "mcl_sculk:sculk_sensor_inactive"})
      end
    end
  end,
})
------------------
--[[----Better_sensor(WIP)-------------------------------
--TODO Register better mesecon output on sculk sensor
minetest.register_node("mcl_sculk:sculk_sensor_inactive", {
	description = "Sculk Sensor",
	drawtype = 'mesh',
	mesh = 'mcl_sculk_sensor.obj',
--new_mesh_with_multi_material_feature--arrange the texture list wise
--base_texture(texture of no use, is add as mesh was dealing with some error)
--sculk tendril(mcl_sculk_sensor_tendril)
--sculk box_vertical_top(mcl_sculk_sensor_top)
--sculk box_vertical_bottom(mcl_sculk_sensor_bottom)
--sculk box_horizontal(mcl_sculk_sensor_side)
	tiles = {
	{
	name = "mcl_sculk_sensor_base.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1.0,
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
		length = 1.0,
	}},
	{
	name = "mcl_sculk_sensor_bottom.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1.0,
	}},
	{
	name = "mcl_sculk_sensor_side.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1.0,
	}}
		},
	use_texture_alpha = "clip",		
	drop = "",
	sounds = sounds,

	collision_box = {
			type = 'fixed',
			fixed = {-0.5000, -0.5000, -0.5000, 0.5000, 0.000, 0.5000}
		},
   	selection_box = {
  	  type = "fixed",
   	 fixed = {-0.5, -0.5, -0.5, 0.5, 0.25, 0.5},
   	},
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 3,
	light_source  = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
    --sounds = default.node_sound_stone_defaults(),
    mesecons = {
        effector = {
            rules = sculk_sensor_effector_rules,
            action_on = function(pos, node)
                -- Emit vibration particles
                minetest.add_particlespawner({
                    amount = 16,
                    time = 0.5,
                    minpos = {x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5},
                    maxpos = {x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5},
                    minvel = {x = -1, y = -1, z = -1},
                    maxvel = {x = 1, y = 1, z = 1},
                    minacc = {x = 0, y = 0, z = 0},
                    maxacc = {x = 0, y = 0, z = 0},
                    minexptime = 0.5,
                    maxexptime = 1,
                    minsize = 3,
                    maxsize = 5,
                    collisiondetection = true,
                    collision_removal = true,
                    object_collision = true,
                    vertical = false,
                    texture = "mcl_sculk_catalyst_top_bloom.png",
                    glow = 14,
                })
                
                -- Play sound effect
                --minetest.sound_play("modname_sculk_sound", {pos = pos, gain = 1.0})
                
                -- Emit mesecon signal
                mesecon.receptor_on(pos, sculk_sensor_effector_rules)
                
                -- Schedule mesecon signal turn off after 0.1 seconds
                minetest.after(0.1, function()
                    mesecon.receptor_off(pos, sculk_sensor_effector_rules)
                end)
            end
        }
    },
})

--[[ ----------------water_logged
minetest.register_node("mcl_sculk:sculk_sensor_inactive_water_logged", {
	description = "Sculk Sensor",
	drawtype = 'mesh',
	mesh = 'mcl_sculk_sensor_water_logged.obj',
--new_mesh_texture--arrange the texture list wise
--base_texture(texture of no use, is add as model was dealing with some error)
--sculk tendril(mcl_sculk_sensor_tendril)
--sculk box_vertical_top(mcl_sculk_sensor_top)
--sculk box_vertical_bottom(mcl_sculk_sensor_bottom)
--sculk box_horizontal(mcl_sculk_sensor_side)
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
	name = "mcl_sculk_sensor_top.png",
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
	name = "mcl_sculk_sensor_side.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}},
	{
	name = "water".png", ---water texture here
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	}}
		},
	use_texture_alpha = "clip",		
	drop = "",
	sounds = sounds,

	collision_box = {
			type = 'fixed',
			fixed = {-0.5000, -0.5000, -0.5000, 0.5000, 0.000, 0.5000}
		},
   	selection_box = {
  	  type = "fixed",
   	 fixed = {-0.5, -0.5, -0.5, 0.5, 0.25, 0.5},
   	},
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 3,
	light_source  = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})
	
--]]
--]]
-----------------
minetest.register_node("mcl_sculk:shrieker", {
	description = S("Sculk shrieker"),
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
	name = "mcl_sculk_shrieker_inner_top.png",
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
	}}
	},
	use_texture_alpha = "clip",
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
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})

--Add this in mcl_deepslate----------------------
--if minetest.get_modpath("mcl_deepslate") then

--minetest.register_node("mcl_deepslate:reinforced_deepslate", {
--	description = S("Reinforced Deepslate"),
--	tiles = {
--		"mcl_deepslate_reinforced_deepslate_top.png",
--		"mcl_deepslate_reinforced_deepslate_bottom.png",
--		"mcl_deepslate_reinforced_deepslate_side.png"
--	},
--	drop = "",
--	sounds = mcl_sounds.node_sound_stone_defaults(),
--	groups = {creative_breakable=1, building_block=1, material_stone=1},
--	sounds = mcl_sounds.node_sound_stone_defaults(),
--	is_ground_content = false,
--	on_blast = function() end,
--	drop = "",
--	_mcl_blast_resistance = 3600000,
--	_mcl_hardness = -1,
--})
--end

--------------------------------------------------------------------
--local modpath = minetest.get_modpath("mcl_sculk")

-- Load files

--dofile(modpath .. "/sculk_block.lua")
--dofile(modpath .. "/sculk_catalyst.lua")
--dofile(modpath .. "/sculk_sensors.lua")
--dofile(modpath .. "/sculk_shrieker.lua")
--dofile(modpath .. "/sculk_vein.lua")
