/// Only included in run_playable_checks.py's private copied runtime.
GLOBAL_DATUM_INIT(ulthor_playable_probe, /datum/ulthor_playable_probe, new)

/datum/ulthor_playable_probe/New()
	..()
	spawn(0)
		run_checks()

/datum/ulthor_playable_probe/proc/run_checks()
	UNTIL(config)
	CONFIG_SET(flag/hub, FALSE)
	world.update_hub_visibility(FALSE)
	UNTIL(SSatoms.initialized && SSticker.initialized && SSair.initialized)
	var/list/results = list()
	var/passed = 0
	for(var/test_type in list(/datum/unit_test/ulthor_mining_diag, /datum/unit_test/ulthor_power, /datum/unit_test/ulthor_atmos, /datum/unit_test/ulthor_lighting, /datum/unit_test/ulthor_cameras, /datum/unit_test/ulthor_door_controls, /datum/unit_test/ulthor_telecomms, /datum/unit_test/ulthor_shuttles, /datum/unit_test/ulthor_arrivals, /datum/unit_test/ulthor_ai_vision, /datum/unit_test/ulthor_gravity, /datum/unit_test/ulthor_job_starts, /datum/unit_test/ulthor_navbeacons, /datum/unit_test/ulthor_light_power, /datum/unit_test/ulthor_mining_diag))
		var/datum/unit_test/test = new test_type
		try
			test.Run()
		catch(var/exception/error)
			test.Fail("Runtime: [error]")
		if(test.succeeded)
			passed++
		results += list(list("test" = "[test_type]", "passed" = test.succeeded, "failures" = test.fail_reasons))
		qdel(test)
	rustlib_file_write(json_encode(list("passed" = passed, "total" = length(results), "tests" = results, "metrics" = GLOB.ulthor_playable_metrics, "runtime_log" = GLOB.world_runtime_log)), "ulthor-playable-result.json")

GLOBAL_LIST_EMPTY(ulthor_playable_metrics)

/// What the AI eye can actually see: the cameranet's own chunks over the watched rooms.
/datum/unit_test/ulthor_ai_vision/Run()
	var/list/targets = json_decode(file2text("ulthor-camera-targets.json"))
	var/station_z = level_name_to_num(MAIN_STATION)
	var/seen = 0
	var/list/blind = list()
	for(var/list/point in targets)
		var/turf/T = locate(point[1], point[2], station_z)
		var/datum/camerachunk/chunk = GLOB.cameranet.getCameraChunk(T.x, T.y, T.z)
		if(chunk.visibleTurfs[T])
			seen++
		else
			blind += list(list(T.x, T.y))
	var/percent = round(100 * seen / max(1, length(targets)), 0.1)
	GLOB.ulthor_playable_metrics["ai_vision"] = list("targets" = length(targets), "seen" = seen, "percent" = percent, "blind" = blind)
	log_world("ULTHOR AI VISION: [seen]/[length(targets)] watched tiles visible ([percent]%)")
	TEST_ASSERT(percent >= 95, "AI must see at least 95% of watched rooms, got [percent]%")

/datum/unit_test/ulthor_gravity/Run()
	var/station_z = level_name_to_num(MAIN_STATION)
	var/obj/machinery/gravity_generator/main/station/gen = locate() in locate(153, 99, station_z)
	TEST_ASSERT_NOTNULL(gen, "Gravity generator must load at 153:99")
	TEST_ASSERT(gen.on, "Gravity generator must start on")
	TEST_ASSERT_EQUAL(length(gen.generator_parts), 8, "Gravity generator must build its 3x3 body")
	TEST_ASSERT(gen.powered(ENVIRON), "Gravity generator room must have environmental power")
	var/area/zone = get_area(gen)
	TEST_ASSERT_EQUAL(zone.type, /area/station/engineering/gravity_generator, "Generator must be in its own room")
	for(var/list/point in list(list(120, 170), list(80, 100), list(170, 130), list(130, 185)))
		var/turf/T = locate(point[1], point[2], station_z)
		TEST_ASSERT(T.has_gravity(T), "Station turf [T.x]:[T.y] must have gravity")
	GLOB.ulthor_playable_metrics["gravity"] = list("charge" = gen.charge_count, "state" = gen.charging_state)

/datum/unit_test/ulthor_job_starts/Run()
	var/list/counts = list()
	for(var/obj/effect/landmark/start/mark in GLOB.landmarks_list)
		if(is_station_level(mark.z))
			counts[mark.name] = (counts[mark.name] || 0) + 1
	var/list/report = list()
	for(var/datum/job/job as anything in SSjobs.occupations)
		if(job.admin_only || job.hidden_from_job_prefs || job.spawn_positions <= 0)
			continue
		report[job.title] = list(counts[job.title] || 0, job.spawn_positions)
		TEST_ASSERT(counts[job.title], "[job.title] needs a start landmark on the station")
	GLOB.ulthor_playable_metrics["job_starts"] = report

/datum/unit_test/ulthor_navbeacons/Run()
	var/station_z = level_name_to_num(MAIN_STATION)
	var/list/patrol = list()
	var/list/locations = list()
	for(var/obj/machinery/navbeacon/beacon in GLOB.navbeacons["[station_z]"])
		locations[beacon.location] = beacon
		if(beacon.codes["patrol"])
			patrol += beacon
	TEST_ASSERT(length(patrol) >= 10, "Ulthor needs a patrol route")
	for(var/obj/machinery/navbeacon/beacon as anything in patrol)
		var/next = beacon.codes["next_patrol"]
		TEST_ASSERT(locations[next], "Patrol beacon [beacon.location] points to missing [next]")
	var/delivery = 0
	for(var/obj/machinery/navbeacon/beacon in GLOB.deliverybeacons)
		if(beacon.z == station_z)
			delivery++
	TEST_ASSERT(delivery >= 10, "Ulthor needs delivery beacons")
	GLOB.ulthor_playable_metrics["beacons"] = list("patrol" = length(patrol), "delivery" = delivery)

/datum/unit_test/ulthor_light_power/Run()
	var/total = 0
	var/powered = 0
	var/list/dark = list()
	for(var/obj/machinery/light/lamp in world)
		if(!is_station_level(lamp.z))
			continue
		total++
		if(lamp.has_power())
			powered++
		else
			var/area/zone = get_area(lamp)
			dark["[zone.type]"] = (dark["[zone.type]"] || 0) + 1
	GLOB.ulthor_playable_metrics["lights"] = list("total" = total, "powered" = powered, "unpowered_by_area" = dark)
	TEST_ASSERT(powered >= total * 0.97, "Lights without area power: [total - powered] of [total]")

/// Diagnostic only: why the mining shuttle round trip fails.
/datum/unit_test/ulthor_mining_diag/Run()
	var/obj/docking_port/mobile/miner = SSshuttle.getShuttle("mining")
	var/obj/docking_port/stationary/away = SSshuttle.getDock("mining_away")
	var/obj/docking_port/stationary/home = SSshuttle.getDock("mining_home")
	GLOB.ulthor_playable_metrics["mining"] = list(
		"docked" = miner?.getDockedId(),
		"can_dock_away" = miner?.canDock(away),
		"can_dock_home" = miner?.canDock(home),
		"away" = away ? list(away.x, away.y, away.z, away.width, away.height, away.dwidth, away.dheight, away.dir) : null,
		"ship" = miner ? list(miner.x, miner.y, miner.z, miner.width, miner.height, miner.dwidth, miner.dheight, miner.dir) : null,
		"mode" = miner?.mode)
