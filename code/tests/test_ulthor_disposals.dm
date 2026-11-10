/// End-to-end delivery: real flush(), holders, junctions, move loop and outlets.
GLOBAL_LIST_EMPTY(ulthor_disposal_arrivals)

/obj/item/paper/ulthor_disposal_probe
	var/source_position
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF

/obj/item/paper/ulthor_disposal_probe/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	if(source_position && isturf(loc) && !GLOB.ulthor_disposal_arrivals[source_position])
		GLOB.ulthor_disposal_arrivals[source_position] = get_turf(src)
	return ..()

/datum/unit_test/ulthor_disposal_delivery/Run()
	if(!istype(SSmapping.map_datum, /datum/map/ulthor))
		return
	GLOB.ulthor_disposal_arrivals.Cut()
	var/list/expected = list()
	var/list/special = list("64:161" = list(60,159), "137:190" = list(133,197), "186:168" = list(186,167))
	var/wall_count = 0
	for(var/obj/machinery/disposal/bin in world)
		if(!is_station_level(bin.z))
			continue
		var/key = "[bin.x]:[bin.y]"
		TEST_ASSERT_NOTNULL(bin.trunk, "Bin [key] needs its mapped trunk")
		TEST_ASSERT(bin.powered() && !(bin.stat & (NOPOWER|BROKEN)), "Bin [key] must be operational")
		var/list/destination = special[key]
		if(!destination)
			destination = list(76,109)
		expected[key] = locate(destination[1], destination[2], bin.z)
		if(istype(bin, /obj/machinery/disposal/wall))
			wall_count++
			var/wall_dir
			for(var/direction in GLOB.cardinal)
				if(iswallturf(get_step(bin, direction)))
					TEST_ASSERT_NOT(wall_dir, "Bin [key] must have an unambiguous wall")
					wall_dir = direction
			var/expected_dir = (wall_dir == EAST || wall_dir == WEST) ? REVERSE_DIR(wall_dir) : wall_dir
			TEST_ASSERT_EQUAL(bin.dir, expected_dir, "Bin [key] must use the wall-side DMI frame")
			TEST_ASSERT_EQUAL(bin.pixel_x, 0, "Wall bin [key] must stay on its floor tile")
			TEST_ASSERT_EQUAL(bin.pixel_y, wall_dir == NORTH ? 16 : 0, "North frame must be lifted to the wall")
		var/obj/item/paper/ulthor_disposal_probe/item = allocate(/obj/item/paper/ulthor_disposal_probe, bin)
		item.source_position = key
		INVOKE_ASYNC(bin, TYPE_PROC_REF(/obj/machinery/disposal, flush))
	TEST_ASSERT_EQUAL(length(expected), 53, "All mapped disposal units must participate")
	TEST_ASSERT_EQUAL(wall_count, 17, "All mapped wall bins must participate")
	var/deadline = world.time + 90 SECONDS
	while(length(GLOB.ulthor_disposal_arrivals) < length(expected) && world.time < deadline)
		sleep(1 SECONDS)
	for(var/key in expected)
		var/turf/arrived = GLOB.ulthor_disposal_arrivals[key]
		var/turf/target = expected[key]
		TEST_ASSERT_EQUAL(arrived, target, "Bin [key] must deliver to [target.x]:[target.y], not spill or stall")
	log_world("ULTHOR DISPOSALS: [length(expected)] actual flushes reached their intended outlets; [wall_count] wall sprites verified")
