/// One tier I drill waits in the cargo bay at round start (docs/MINING_DRILLS.md, "Источники").
/proc/spawn_cargo_mining_drill()
	var/list/candidates = list()
	for(var/turf/simulated/floor/floor in get_area_turfs(/area/station/cargo/storage, subtypes = TRUE))
		if(istype(get_area(floor), /area/station/cargo/storage/mining))
			continue
		if(!is_station_level(floor.z) || floor.is_blocked_turf(exclude_mobs = TRUE))
			continue
		if(locate(/obj/machinery/conveyor) in floor)
			continue
		candidates += floor
	if(!length(candidates))
		log_world("Mining drills: no free cargo bay floor for the round-start drill.")
		return
	var/turf/spot = pick(candidates)
	new /obj/item/mining_drill_packed(spot)
	log_world("Mining drills: round-start drill placed in the cargo bay at [spot.x],[spot.y],[spot.z].")

/datum/supply_packs/misc/mining_drill
	name = "Mining Drill Kit"
	cost = 50
	contains = list(
		/obj/item/mining_drill_module/ejector,
		/obj/item/ore_pipe_layer,
	)
	loose_contains = list(
		/obj/item/mining_drill_packed,
	)
	containername = "mining drill kit crate"
