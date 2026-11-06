/// Included only by test_atmta_port.py in a separate, copied runtime.
GLOBAL_DATUM_INIT(atmta_port_probe, /datum/atmta_port_probe, new)

/datum/atmta_port_probe/New()
	..()
	spawn(0)
		run_tests()

/datum/atmta_port_probe/proc/run_tests()
	UNTIL(config)
	CONFIG_SET(flag/hub, FALSE)
	world.update_hub_visibility(FALSE)
	UNTIL(SSatoms.initialized && SSserver_maint.initialized && SSticker.initialized)
	// A sealed, breathable room in the otherwise unused map corner.
	for(var/turf/ground in block(locate(19, 19, 1), locate(21, 21, 1)))
		if(ground.x == 20 && ground.y == 20)
			ground.ChangeTurf(/turf/simulated/floor/plasteel)
		else
			ground.ChangeTurf(/turf/simulated/wall)
	var/list/results = list()
	var/passed = 0
	var/list/tests = list(
		/datum/unit_test/atmta_loadout_catalogue,
		/datum/unit_test/atmta_loadout_role_access,
		/datum/unit_test/atmta_parasha_scavenging,
		/datum/unit_test/atmta_gallows_rescue,
		/datum/unit_test/atmta_gallows_crafting_and_cutting,
	)
	for(var/test_type in tests)
		var/datum/unit_test/test = new test_type
		try
			test.Run()
		catch(var/exception/error)
			test.Fail("Runtime: [error]")
		if(test.succeeded)
			passed++
		results += list(list("test" = "[test_type]", "passed" = test.succeeded, "failures" = test.fail_reasons))
		qdel(test)
	var/parashas = 0
	var/ordinary_prison_toilets = 0
	for(var/obj/structure/toilet/toilet in world)
		if(!istype(get_area(toilet), /area/station/security/prison))
			continue
		if(istype(toilet, /obj/structure/toilet/parasha))
			parashas++
		else
			ordinary_prison_toilets++
	rustlib_file_write(json_encode(list("passed" = passed, "total" = length(tests), "tests" = results, "prison_parashas" = parashas, "ordinary_prison_toilets" = ordinary_prison_toilets, "runtime_log" = GLOB.world_runtime_log)), "atmta-port-result.json")
