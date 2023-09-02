---------Frog-----------

local pi = math.pi
local atann = math.atan
local atan = function(x)
	if not x or x ~= x then
		return 0
	else
		return atann(x)
	end
end

local dir_to_pitch = function(dir)
	local dir2 = vector.normalize(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end

local function degrees(rad)
	return rad * 180.0 / math.pi
end

local S = minetest.get_translator(minetest.get_current_modname())


-- Define common properties for all frogs
local frog = {
	type = "animal",
	spawn_class = "water_ambient",
	can_despawn = true,
	passive = true,
	hp_min = 10,
	hp_max = 10,
	xp_min = 1,
	xp_max = 3,
	armor = 100,
	rotate = 180,
	spawn_in_group_min = 2,
	spawn_in_group = 4, 
	tilt_swim = true,
	collisionbox = {-0.2505, -0.01, -0.2505, 0.2505, 0.50, 0.2505},
	visual = "mesh",
	-- TODO: add mesh(WIP)
	mesh = "mobs_mc_frog.b3d",
	----textures are done by biome type texture----
	sounds = {
		random = "mobs_mc_frog_croak_1",
		random = "mobs_mc_frog_croak_2",
		damage = "mobs_mc_hurt_1",
		damage = "mobs_mc_hurt_2",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	-- TODO: Add animations(after mseh is done)
	animation = {
	},
	follow = {
		"mcl_mobitems:slimeball",
	},
	drops = {},
	visual_size = {x=5, y=5},--depends on mesh
	makes_footstep_sound = true,
	reach = 2,
	fly = true,
	fly_in = { "mcl_core:water_source", "mclx_core:river_water_source" },
	breath_max = -1,
	jump = true,
	jump_height = 8,
	view_range = 6,
	runaway = true,
	fear_height = 9,
	attack_animals = true,
	specific_attack = {
		"mobs_mc:slime_tiny",
		"mobs_mc:magma_cube_tiny"
		 },
	on_breed = function(self, partner)

	-- Check if one of the frogs is pregnant (has a timer)
	if self.timer or partner.timer then
		return
	end
	-- Check if there's a water block with air above nearby
	local pos = self.object:get_pos()
	local water_pos = minetest.find_node_near(pos, 1, {"group:water",})
    	if not water_pos then
		return
	end

	-- Set a timer for the pregnant frog
	self.timer = minetest.after(1200, function()
		self.timer = nil
	-- Spawn frogspawn node at water_pos
	minetest.set_node(water_pos, {name = "mobs_mc:frogspawn"})
		end)
	end,
	do_custom = function(self)
local frog_name = self.object:get_luaentity().name  -- Get the frog's name

-- Check if the frog has killed a mob listed in specific_attack
local predator = self.object
for _, prey in pairs(self.specific_attack) do
    local prey_entity = minetest.get_nearest_entity(predator:get_pos(), 1, prey)
    if prey_entity then
        local pos = self.object:get_pos()
        local special_item = "mcl_mobitems:slimeball"  -- Default special item

        if prey == "mobs_mc:magma_cube_tiny" then
            if frog_name == "mobs_mc:frog_temperate" then
                special_item = "mcl_froglight:ochre"
            elseif frog_name == "mobs_mc:frog_warm" then
                special_item = "mcl_froglight:pearlescent"
            elseif frog_name == "mobs_mc:frog_cold" then
                special_item = "mcl_froglight:verdant"
            end
        end

        -- Now we can use the special_item as needed
		end
	end
end
}
----------------------------
local frog_temperate_textures = {"mobs_mc_frog_temperate_texture.png"}
local frog_warm_textures = {"mobs_mc_frog_warm_texture.png"}
local frog_cold_textures = {"mobs_mc_frog_cold_texture.png"}
---------------------

-- Register the Temperate Frog
mcl_mobs.register_mob("mobs_mc:frog_temperate", frog, frog_temperate_textures)
mcl_mobs.register_mob("mobs_mc:frog_warm", frog, frog_warm_textures)
mcl_mobs.register_mob("mobs_mc:frog_cold", frog, frog_cold_textures)

------------------

-- Override the mcl_mobs.register_egg function for your frog spawn eggs
mcl_mobs.register_egg("mobs_mc:frog_temperate", S("Temperate Frog"), "#FFA500", "#DAA520", 0, function(itemstack, user, pointed_thing)
    if pointed_thing.type == "node" then
        local pos = pointed_thing.under
        local biome = minetest.find_biome_name(pos)

        local frog_name

        if biome == "temperate_biome" then
            frog_name = "mobs_mc:frog_temperate"
        elseif biome == "warm_biome" then
            frog_name = "mobs_mc:frog_warm"
        elseif biome == "cold_biome" then
            frog_name = "mobs_mc:frog_cold"
        else
            -- Default logic if biome is not recognized
            frog_name = "mobs_mc:frog_temperate"
        end

        -- Spawn the corresponding frog entity
        minetest.add_entity(pos, frog_name)

        -- Decrease the spawn egg count
        itemstack:take_item()

        return itemstack
    end
end)

---other_features-------------
minetest.register_node("mobs_mc:frogspawn", {
    description = "Frogspawn",
    tiles = {
        {
            name = "mcl_frogspawn.png",
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 2.0,
		},
	},
},
	drawtype = "signlike",
	sunlight_propagates = true,
	inventory_image = "mcl_frogspawn.png",
	wield_image = "mcl_frogspawn.png",
	walkable = false,
	paramtype = "light",
	groups = {oddly_breakable_by_hand = 3,snappy = 3, destroy_by_lava_flow = 1,
		dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1,},
	drop = "",
	liquids_pointable = true,
	floodable = true,
	selection_box = {
		type = "fixed",
		fixed = {-7 / 16, -0.5, -7 / 16, 7 / 16, -15 / 32, 7 / 16}
	},

	
})

minetest.register_abm({
    nodenames = {"mobs_mc:frogspawn"},
    interval = 1200,  -- 20 minutes
    chance = 1,
    action = function(pos, node)
        -- Spawn tadpoles
        local num_tadpoles = math.random(2, 5)
        for i = 1, num_tadpoles do
            minetest.add_entity(pos, "mobs_mc:tadpole")
        end
        -- Remove frogspawn
        minetest.remove_node(pos)
    end,
})

-- Function to spawn a tadpole
local spawn_tadpole = function(pos)
    -- Spawn the tadpole entity
    local tadpole_entity = minetest.add_entity(pos, "mobs_mc:tadpole")

    -- Set a timer for tadpole to frog transformation (20 minutes)
    minetest.after(1200, function()
        if tadpole_entity and tadpole_entity:get_luaentity() then
            local tadpole_pos = tadpole_entity:get_pos()

            -- Determine the biome category
            local biome = minetest.find_biome_name(tadpole_pos)
            local frog_name

            -- Assign the frog type based on biome
            if biome == "temperate_biome" then
                frog_name = "mobs_mc:frog_temperate"
            elseif biome == "warm_biome" then
                frog_name = "mobs_mc:frog_warm"
            elseif biome == "cold_biome" then
                frog_name = "mobs_mc:frog_cold"
            else
                -- Default to Temperate if biome is not recognized
                frog_name = "mobs_mc:frog_temperate"
            end

            -- Spawn the corresponding frog entity
            minetest.add_entity(tadpole_pos, frog_name)

            -- Remove the tadpole entity
            tadpole_entity:remove()
        end
    end)
end

--TODO---------------------------------------
-- Table to categorize biomes
local biome_categories = {
    Temperate = {
        "biome1",
        "biome2",
        -- Add more temperate biomes as needed
    },
    Warm = {
        "biome3",
        "biome4",
        -- Add more warm biomes as needed
    },
    Cold = {
        "biome5",
        "biome6",
        -- Add more cold biomes as needed
    },
}



