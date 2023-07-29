---------Tadpole-----------

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

local tadpole = {
	type = "animal",
	spawn_class = "water_ambient",
	can_despawn = true,
	passive = true,
	hp_min = 6,
	hp_max = 6,
	xp_min = 0,
	xp_max = 0,
	armor = 100,
	rotate = 180,
	spawn_in_group_min = 2,
	spawn_in_group = 4, 
	tilt_swim = true,
	collisionbox = {-0.5000, -0.5000, -0.5000, -0.2500, -0.3125, -0.06250},
	visual = "mesh",
	mesh = "mobs_mc_tadpole.b3d",
	textures = {
		{"mobs_mc_tadpole.png"}
	},
	sounds = {
		damage = "mobs_mc_tadpole_hurt",
		death = "mobs_mc_tadpole_death",
		distance = 16,
	},
	animation = {
		stand_start = 0,
		stand_end = 1,
		walk_start = 2,
		walk_end = 30,
		run_start = 1,
		run_end = 30,
	},
	drops = {},
	visual_size = {x=30, y=30},
	makes_footstep_sound = false,
    fly = true,
    fly_in = { "mcl_core:water_source", "mclx_core:river_water_source" },
	breathes_in_water = true,
	jump = false,
	view_range = 16,
	runaway = true,
	fear_height = 4,
	do_custom = function(self)
		--[[ this is supposed to make them jump out the water but doesn't appear to work very well
		self.object:set_bone_position("body", vector.new(0,1,0), vector.new(degrees(dir_to_pitch(self.object:get_velocity())) * -1 + 90,0,0))
		if minetest.get_item_group(self.standing_in, "water") ~= 0 then
			if self.object:get_velocity().y < 5 then
				self.object:add_velocity({ x = 0 , y = math.random(-.007, .007), z = 0 })
			end
		end
--]]
		for _,object in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), 10)) do
			local lp = object:get_pos()
			local s = self.object:get_pos()
			local vec = {
				x = lp.x - s.x,
				y = lp.y - s.y,
				z = lp.z - s.z
			}
			if object and not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "mobs_mc:cod" then
				self.state = "runaway"
				self.object:set_rotation({x=0,y=(atan(vec.z / vec.x) + 3 * pi / 2) - self.rotate,z=0})
			end
		end
	end,
	on_rightclick = function(self, clicker)
		local bn = clicker:get_wielded_item():get_name()
		if bn == "mcl_buckets:bucket_water" or bn == "mcl_buckets:bucket_river_water" then
			self.object:remove()
			clicker:set_wielded_item("mcl_buckets:bucket_tadpole")
			awards.unlock(clicker:get_player_name(), "mcl:bukkit_bukkit")
		end
	end
}

mcl_mobs.register_mob("mobs_mc:tadpole", tadpole)

mcl_mobs.register_egg("mobs_mc:tadpole", S("Tadpole"), "#4c3e30", "#1b0200", 0)
