/// Only included in run_layout_checks.py's private copied runtime.
GLOBAL_DATUM_INIT(ulthor_layout_probe, /datum/ulthor_layout_probe, new)

/datum/ulthor_layout_probe/New()
	..()
	spawn(0)
		run_checks()

/datum/ulthor_layout_probe/proc/run_checks()
	UNTIL(config)
	CONFIG_SET(flag/hub, FALSE)
	world.update_hub_visibility(FALSE)
	UNTIL(SSatoms.initialized && SSticker.initialized && SSair.initialized)
	var/list/results = list()
	var/passed = 0
	for(var/test_type in list(/datum/unit_test/ulthor_power, /datum/unit_test/ulthor_atmos, /datum/unit_test/ulthor_lighting, /datum/unit_test/ulthor_cameras, /datum/unit_test/ulthor_door_controls, /datum/unit_test/ulthor_telecomms, /datum/unit_test/ulthor_shuttles, /datum/unit_test/ulthor_arrivals, /datum/unit_test/ulthor_room_layout))
		var/datum/unit_test/test = new test_type
		try
			test.Run()
		catch(var/exception/error)
			test.Fail("Runtime: [error]")
		if(test.succeeded)
			passed++
		results += list(list("test" = "[test_type]", "passed" = test.succeeded, "failures" = test.fail_reasons))
		qdel(test)
	rustlib_file_write(json_encode(list("passed" = passed, "total" = length(results), "tests" = results, "runtime_log" = GLOB.world_runtime_log)), "ulthor-layout-result.json")

/datum/unit_test/ulthor_room_layout/Run()
	var/list/expectations = json_decode(file2text("ulthor-layout-expectations.json"))
	var/station_z = level_name_to_num(MAIN_STATION)
	var/tested = 0
	for(var/list/entry in expectations)
		var/turf/ground = locate(entry["x"], entry["y"], station_z)
		var/device_type = text2path(entry["type"])
		var/obj/device = locate(device_type) in ground
		TEST_ASSERT_NOTNULL(device, "Mapped [entry["type"]] at [entry["x"]]:[entry["y"]] must load")
		var/area/zone = get_area(device)
		TEST_ASSERT_EQUAL("[zone.type]", entry["area"], "Device must register to its physical room")
		if(istype(device, /obj/machinery))
			var/obj/machinery/machine = device
			TEST_ASSERT(machine.powered(), "[machine.type] at [ground.x]:[ground.y] must have area power")
		if(istype(device, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/vent = device
			TEST_ASSERT_NOTNULL(vent.node, "New room vent needs a real pipe connection at [ground.x]:[ground.y]")
			TEST_ASSERT_EQUAL(vent.node.icon_connect_type, "-supply", "Room vents must use the air supply trunk")
			TEST_ASSERT_EQUAL(vent.current_area, zone, "Vent must belong to its own room's air alarm")
			TEST_ASSERT(vent in zone.air_vents, "Vent must register in the room control list")
		if(istype(device, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/scrubber = device
			TEST_ASSERT_NOTNULL(scrubber.node, "New room scrubber needs a real pipe connection at [ground.x]:[ground.y]")
			TEST_ASSERT_EQUAL(scrubber.node.icon_connect_type, "-scrubbers", "Room scrubbers must use the waste trunk")
			TEST_ASSERT_EQUAL(scrubber.current_area, zone, "Scrubber must belong to its own room's air alarm")
			TEST_ASSERT(scrubber in zone.air_scrubs, "Scrubber must register in the room control list")
		if(istype(device, /obj/machinery/alarm))
			var/obj/machinery/alarm/alarm = device
			TEST_ASSERT_EQUAL(alarm.alarm_area, zone, "Air alarm must control its real room")
			TEST_ASSERT(alarm in zone.air_alarms, "Air alarm must register in the room control list")
		if(istype(device, /obj/machinery/firealarm))
			var/obj/machinery/firealarm/alarm = device
			TEST_ASSERT_EQUAL(alarm.myArea, zone, "Fire alarm must control its real room")
			TEST_ASSERT(alarm in zone.firealarms, "Fire alarm must register in the room control list")
		tested++
	log_world("ULTHOR LAYOUT: [tested] fixture registrations and connections verified")
