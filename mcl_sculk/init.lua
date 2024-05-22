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
    footstep = {name = "mcl_sculk_block_2", },
    place = {name = "mcl_sculk_block_2", },
    dug = {name = "mcl_sculk_block", "mcl_sculk_2", },
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

local function set_node_xp(pos, xp)
    local meta = minetest.get_meta(pos)
    return meta:set_int("xp", xp)
end

local function sculk_on_destruct(pos)
    local xp = get_node_xp(pos)
    local n = minetest.get_node(pos)
    if n.param2 == 1 then
        xp = 1
    end
    local obs = mcl_experience.throw_xp(pos, xp)
    for _,v in pairs(obs) do
        local l = v:get_luaentity()
        l._sculkdrop = true
    end
end

local function has_air(pos)
    for _,v in pairs(adjacents) do
        if minetest.get_item_group(minetest.get_node(vector.add(pos,v)).name, "solid") <= 0 then
            return true
        end
    end
end

local function has_nonsculk(pos)
    for _,v in pairs(adjacents) do
        local p = vector.add(pos,v)
        if minetest.get_item_group(minetest.get_node(p).name, "sculk") <= 0 and minetest.get_item_group(minetest.get_node(p).name, "solid") > 0 then
            return p
        end
    end
end

local function retrieve_close_spreadable_nodes(p)
    local nnn = minetest.find_nodes_in_area(vector.offset(p, -SPREAD_RANGE, -SPREAD_RANGE, -SPREAD_RANGE), vector.offset(p, SPREAD_RANGE, SPREAD_RANGE, SPREAD_RANGE), spread_to)
    local nn = {}
    for _,v in pairs(nnn) do
        if has_air(v) then
            table.insert(nn, v)
        end
    end
    table.sort(nn, function(a, b)
        return vector.distance(p, a) < vector.distance(p, b)
    end)
    return nn
end

local function spread_sculk(p, xp_amount)
    local c = minetest.find_node_near(p, SPREAD_RANGE, {"mcl_sculk:catalyst"} or {"mcl_sculk:catalyst_bloom"})
    if c then
        local nn = retrieve_close_spreadable_nodes(p)
        if nn and #nn > 0 then
            if xp_amount > 0 then
                local d = math.random(100)
                
		if d <= 0 then
			minetest.set_node(nn[1],{name = "mcl_sculk:shrieker"})
			set_node_xp(nn[1],math.min(1,self._xp - 10))
			return ret
		elseif d <= 0 then
			minetest.set_node(nn[1],{name = "mcl_sculk:sculk_sensor_inactive"})
			set_node_xp(nn[1],math.min(1,self._xp - 5))
			return ret
		else
   
                local r = math.min(math.random(#nn), xp_amount)

                for i=1,r do
                    minetest.set_node(nn[i], {name = "mcl_sculk:sculk"})
                    set_node_xp(nn[i], math.floor(xp_amount / r))
                end

	for i=1,r do
	if minetest.get_node(c).name == "mcl_sculk:catalyst" then
	minetest.set_node(c, {name = "mcl_sculk:catalyst_bloom"})
               end

                for i=1,r do
                    local p = has_nonsculk(nn[i])
                    if p and has_air(p) then
                        minetest.set_node(vector.offset(p, 0, 1, 0), {name = "mcl_sculk:vein", param2 = 1})
                    end
                end

                set_node_xp(nn[1], get_node_xp(nn[1]) + xp_amount % r)
                return true
            end
          end
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
			length = 2.5,
		}, },
	},
	drop = "",
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1, xp=1},
	place_param2 = 1,
	sounds = sounds,
	is_ground_content = false,
	--on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
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
	sounds = {
    footstep = {name = "mcl_sculk_block_2", },
    place = {name = "mcl_sculk_block_2", },
    dug = {name = "mcl_sculk_catalyst_breaking",},
	},
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1, xp=5},
	place_param2 = 1,
	is_ground_content = false,
	--on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 3,
	light_source  = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_sculk:catalyst_bloom", {
	description = S("Sculk Catalyst"),
	tiles = {
	{ name="mcl_sculk_catalyst_top_bloom.png",
				animation={
				type="vertical_frames",
				aspect_w=16,
				aspect_h=16,
				length=1.0
			},
		},
	"mcl_sculk_catalyst_bottom.png",
	{ name="mcl_sculk_catalyst_side_bloom.png",
				animation={
				type="vertical_frames",
				aspect_w=16,
				aspect_h=16,
				length=1.0
			},
		},
	},
	drop = "",
	sounds = sounds,
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1, not_in_creative_inventory=1, xp=5},
	place_param2 = 1,
	is_ground_content = false,
	--on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 3,
	light_source  = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true and {"mcl_sculk:catalyst"},
	    on_construct = function(pos)
        	minetest.add_particle({
		pos = {x=pos.x, y=pos.y+0.2, z=pos.z},
		velocity = {x = 0, y = 0.6, z = 0},
		expirationtime = 1.2,
		size = 5,
		--texture = "mcl_soul_particle.png",
		texture = "mcl_soul_particle.png",
        	animation = {
            	type = "vertical_frames",
            	frames_w = 16,
            	frames_h = 16,
            	frame_length = 1.0,
        	},
        })
                	minetest.after(0.7, function() -- Delay of seconds
            	minetest.swap_node(pos, {name = "mcl_sculk:catalyst"})
        	end)
    end,
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
			length = 2.5,
		}, },
	},
	inventory_image = "mcl_sculk_vein.png^[verticalframe:3:0",
	wield_image = "mcl_sculk_vein.png^[verticalframe:3:0",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = false,
	buildable_to = true,
	selection_box = {
		type = "wallmounted",
	},
	groups = {
		handy = 1, hoey = 1, shearsy = 1, swordy = 1, deco_block = 1,
		dig_by_piston = 1, sculk = 1,
	},
	sounds = sounds,
	drop = "",
	_mcl_shears_drop = true,
	node_placement_prediction = "",
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	on_rotate = false,
})

minetest.register_abm({
    label = "mcl_sculk_revert_mcl_sculk:catalyst_bloom",
    nodenames = {"mcl_sculk:catalyst_bloom"},
    interval = 2.5,
    chance = 1,
    action = function(pos)
        local node = minetest.get_node(pos)
        if node.name == "mcl_sculk:catalyst_bloom" then
            local meta = minetest.get_meta(pos)
            local creation_time = meta:get_int("creation_time") or 0
            local current_time = minetest.get_gametime()

            -- Check if the node has existed for at least 5 seconds (100 ticks per second)
            local existence_time = current_time - creation_time
            local existence_seconds = existence_time / 100
            if existence_seconds >= 5 then
                -- Revert to inactive sculk sensor node after turning off mesecon signal
                minetest.set_node(pos, {name = "mcl_sculk:catalyst"})
            end
        end
    end,
})

----------------------------------------------------
--[[--Add this in mcl_deepslate----------------------
if minetest.get_modpath("mcl_deepslate") then

minetest.register_node("mcl_deepslate:reinforced_deepslate", {
	description = S("Reinforced Deepslate"),
	tiles = {
		"mcl_deepslate_reinforced_deepslate_top.png",
		"mcl_deepslate_reinforced_deepslate_bottom.png",
		"mcl_deepslate_reinforced_deepslate_side.png"
	},
	drop = "",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {creative_breakable=1, building_block=1, material_stone=1, },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	on_blast = function() end,
	drop = "",
	_mcl_blast_resistance = 3600000,
	_mcl_hardness = -1,
	_mcl_silk_touch_drop = false,
})
end
--]]
--Add this in mesecons_mvps.lua----------------------
mesecon.register_mvps_stopper("mcl_sculk:shrieker")
mesecon.register_mvps_stopper("mcl_sculk:sculk_sensor_inactive")
mesecon.register_mvps_stopper("mcl_sculk:sculk_sensor_active")
mesecon.register_mvps_stopper("mcl_sculk:sculk_sensor_inactive_w_logged")
mesecon.register_mvps_stopper("mcl_sculk:sculk_sensor_active_w_logged")
--mesecon.register_mvps_stopper("mcl_deepslate:reinforced_deepslate")

--------------------------------------------------------------------
local modpath = minetest.get_modpath("mcl_sculk")

-- Load files
dofile(modpath .. "/sculk_sensor.lua")
dofile(modpath .. "/sculk_shrieker.lua")
