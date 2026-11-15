/**
 * Lays out the ore deposits of the mining asteroid.
 *
 * Runs once per round after the caves are carved and the random ore walls have resolved.
 * Each ore type gets a fixed number of deposits. Rare ores are placed first,
 * so their minimum counts are guaranteed before common ores take the space.
 */
/datum/ore_deposit_generator
	var/min_size = 2
	var/max_size = 5
	var/min_amount = 50
	var/max_amount = 200
	/// Minimum distance between tiles of two different deposits.
	var/deposit_spacing = 9
	/// Minimum distance from any outpost, camp or other mapped building.
	var/base_distance = 15
	/// Attempts to grow an irregular shape from a single starting tile.
	var/shape_attempts = 6
	/// id = list(ore type, deposit count, name), rarest first.
	var/list/deposit_kinds = list(
		"diamond" = list(/obj/item/stack/ore/diamond, 3, "diamond deposit"),
		"bluespace" = list(/obj/item/stack/ore/bluespace_crystal, 3, "bluespace crystal deposit"),
		"uranium" = list(/obj/item/stack/ore/uranium, 4, "uranium ore deposit"),
		"titanium" = list(/obj/item/stack/ore/titanium, 5, "titanium ore deposit"),
		"gold" = list(/obj/item/stack/ore/gold, 5, "gold ore deposit"),
		"silver" = list(/obj/item/stack/ore/silver, 6, "silver ore deposit"),
		"plasma" = list(/obj/item/stack/ore/plasma, 8, "plasma ore deposit"),
		"iron" = list(/obj/item/stack/ore/iron, 15, "iron ore deposit"),
	)
	/// Turfs still free for deposit tiles, turf = TRUE.
	var/list/free_turfs

/datum/ore_deposit_generator/proc/generate(z_level)
	var/list/distance_to_base = compute_base_distance(z_level)
	var/list/candidates = list()
	free_turfs = list()
	for(var/turf/simulated/mineral/rock as anything in Z_TURFS(z_level))
		if(!istype(rock) || istype(rock, /turf/simulated/mineral/gibtonite))
			continue
		if(!istype(get_area(rock), /area/mine/unexplored))
			continue
		if(distance_to_base[(rock.y - 1) * world.maxx + rock.x] < base_distance)
			continue
		if(locate(/obj/effect/ore_deposit_tile) in rock)
			continue
		candidates += rock
		free_turfs[rock] = TRUE
	shuffle_inplace(candidates)

	var/list/report = list()
	var/next_candidate = 1
	for(var/ore_id in deposit_kinds)
		var/list/kind = deposit_kinds[ore_id]
		var/placed = 0
		while(placed < kind[2] && next_candidate <= length(candidates))
			var/turf/start = candidates[next_candidate++]
			if(!free_turfs[start])
				continue
			var/list/shape = grow_shape(start)
			if(!shape)
				continue
			new /datum/ore_deposit(ore_id, kind[1], kind[3], rand(min_amount, max_amount), shape)
			reserve_area(shape)
			placed++
			CHECK_TICK
		report += "[ore_id] [placed]/[kind[2]]"
		if(placed < kind[2])
			stack_trace("Ore deposits: only [placed] of [kind[2]] [ore_id] deposits fit on the mining asteroid.")
	free_turfs = null
	log_world("Ore deposits: [length(GLOB.ore_deposits)] placed ([report.Join(", ")]).")

/// Grows a connected, non-rectangular group of free tiles from `start`. Returns null on failure.
/datum/ore_deposit_generator/proc/grow_shape(turf/start)
	for(var/attempt in 1 to shape_attempts)
		var/target_size = rand(min_size, max_size)
		var/list/shape = list(start)
		while(length(shape) < target_size)
			var/list/options = list()
			for(var/turf/member as anything in shape)
				for(var/direction in GLOB.cardinal)
					var/turf/neighbour = get_step(member, direction)
					if(neighbour && free_turfs[neighbour] && !(neighbour in shape))
						options |= neighbour
			if(!length(options))
				break
			shape += pick(options)
		if(length(shape) < min_size)
			return null
		// Two tiles are always a straight pair; larger deposits must not be plain lines or blocks.
		if(length(shape) >= 3 && is_rectangle(shape))
			continue
		return shape
	return null

/datum/ore_deposit_generator/proc/is_rectangle(list/turf/shape)
	var/min_x = INFINITY
	var/max_x = -INFINITY
	var/min_y = INFINITY
	var/max_y = -INFINITY
	for(var/turf/member as anything in shape)
		min_x = min(min_x, member.x)
		max_x = max(max_x, member.x)
		min_y = min(min_y, member.y)
		max_y = max(max_y, member.y)
	return (max_x - min_x + 1) * (max_y - min_y + 1) == length(shape)

/// Keeps every other deposit at least `deposit_spacing` tiles away from this one.
/datum/ore_deposit_generator/proc/reserve_area(list/turf/shape)
	for(var/turf/member as anything in shape)
		for(var/turf/nearby as anything in RANGE_TURFS(deposit_spacing - 1, member))
			free_turfs -= nearby

/// Builds a flat x/y grid with the distance (in tiles, like get_dist) from each turf to the nearest building.
/datum/ore_deposit_generator/proc/compute_base_distance(z_level)
	var/width = world.maxx
	var/height = world.maxy
	var/far = width + height
	var/list/distance = new /list(width * height)
	for(var/y in 1 to height)
		for(var/x in 1 to width)
			distance[(y - 1) * width + x] = is_base_turf(locate(x, y, z_level)) ? 0 : far
		CHECK_TICK
	// Two-pass chamfer transform with unit diagonal steps gives the exact Chebyshev distance.
	for(var/y in 1 to height)
		for(var/x in 1 to width)
			var/index = (y - 1) * width + x
			var/best = distance[index]
			if(x > 1)
				best = min(best, distance[index - 1] + 1)
			if(y > 1)
				best = min(best, distance[index - width] + 1)
				if(x > 1)
					best = min(best, distance[index - width - 1] + 1)
				if(x < width)
					best = min(best, distance[index - width + 1] + 1)
			distance[index] = best
		CHECK_TICK
	for(var/y in height to 1 step -1)
		for(var/x in width to 1 step -1)
			var/index = (y - 1) * width + x
			var/best = distance[index]
			if(x < width)
				best = min(best, distance[index + 1] + 1)
			if(y < height)
				best = min(best, distance[index + width] + 1)
				if(x < width)
					best = min(best, distance[index + width + 1] + 1)
				if(x > 1)
					best = min(best, distance[index + width - 1] + 1)
			distance[index] = best
		CHECK_TICK
	return distance

/// Anything mapped on the asteroid other than rock, dug paths and space counts as a base.
/datum/ore_deposit_generator/proc/is_base_turf(turf/target)
	var/area/target_area = get_area(target)
	if(istype(target_area, /area/mine/unexplored) || istype(target_area, /area/mine/explored) || istype(target_area, /area/space))
		return FALSE
	return TRUE

/// Placed by [/datum/controller/subsystem/mapping/proc/loadMiningAsteroid].
/// Waits for the random ore walls to resolve during Initialize, then lays out the deposits.
/obj/effect/landmark/ore_deposit_initializer
	name = "ore deposit initialization"

/obj/effect/landmark/ore_deposit_initializer/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/ore_deposit_initializer/LateInitialize()
	var/datum/ore_deposit_generator/generator = new
	generator.generate(z)
	qdel(generator)
	qdel(src)
