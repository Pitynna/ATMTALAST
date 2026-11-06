/// A map marker for the winding, airless caves from ATMTA's mining asteroid.
/turf/simulated/floor/plating/asteroid/airless/cave_seed

/// Carves only unexplored asteroid rock, preserving the hull, outposts and mapped paths.
/datum/map_generator/asteroid_tunnels
	/// Keep roughly the original tunnel density as the asteroid grows.
	var/rocks_per_seed = 1400
	var/seed_spacing = 18
	var/list/mob_types = list(
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 1,
		/mob/living/simple_animal/hostile/asteroid/goliath = 5,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 4,
		/mob/living/simple_animal/hostile/asteroid/hivelord = 3,
	)

/datum/map_generator/asteroid_tunnels/generate_terrain(list/turfs, area/generate_in)
	var/list/seeds = list()
	var/list/candidates = list()
	for(var/turf/simulated/floor/plating/asteroid/airless/cave_seed/seed as anything in turfs)
		if(istype(seed))
			seeds += seed
	for(var/turf/simulated/mineral/rock as anything in turfs)
		if(istype(rock) && istype(get_area(rock), /area/mine/unexplored))
			candidates += rock
	var/target_seed_count = max(length(seeds), CEILING(length(candidates) / rocks_per_seed, 1))
	while(length(seeds) < target_seed_count && length(candidates))
		var/turf/candidate = pick_n_take(candidates)
		if(!can_carve(candidate))
			continue
		var/too_close = FALSE
		for(var/turf/existing as anything in seeds)
			if(get_dist(candidate, existing) < seed_spacing)
				too_close = TRUE
				break
		if(!too_close)
			seeds += candidate
		CHECK_TICK
	log_world("Asteroid caves: [length(seeds)] starting points across the unexplored rock.")
	for(var/turf/seed as anything in seeds)
		var/direction = pick(GLOB.alldirs)
		carve_tunnel(seed, direction, rand(25, 50))
		carve_tunnel(seed, REVERSE_DIR(direction), rand(25, 50))
		seed.ChangeTurf(/turf/simulated/floor/plating/asteroid/airless)

/datum/map_generator/asteroid_tunnels/proc/carve_tunnel(turf/start, direction, tunnel_length, depth = 0)
	var/turf/current = start
	var/turn_offset = pick(-45, 45)
	for(var/i in 1 to tunnel_length)
		var/turf/next = get_step(current, direction)
		if(!can_carve(next))
			break
		current = next.ChangeTurf(/turf/simulated/floor/plating/asteroid/airless)
		var/turf/edge = get_step(current, turn(direction, 45))
		if(can_carve(edge))
			edge.ChangeTurf(/turf/simulated/floor/plating/asteroid/airless)
		spawn_asteroid_mob(current)
		if(i > 3 && depth < 2 && prob(20))
			carve_tunnel(current, turn(direction, -45), rand(10, 15), depth + 1)
		if(i > 2 && prob(33))
			turn_offset = -turn_offset
			direction = turn(direction, turn_offset)

/datum/map_generator/asteroid_tunnels/proc/can_carve(turf/target)
	if(!ismineralturf(target) || !istype(get_area(target), /area/mine/unexplored))
		return FALSE
	for(var/turf/nearby as anything in RANGE_TURFS(2, target))
		if(isspaceturf(nearby) || !istype(get_area(nearby), /area/mine/unexplored))
			return FALSE
	return TRUE

/datum/map_generator/asteroid_tunnels/proc/spawn_asteroid_mob(turf/target)
	if(!prob(30))
		return
	for(var/mob/living/simple_animal/hostile/asteroid/nearby in range(15, target))
		return
	var/mob_type = pickweight(mob_types)
	new mob_type(target)
