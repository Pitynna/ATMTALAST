/// Only included by run_disposal_checks.py in its private copied runtime.
GLOBAL_DATUM_INIT(ulthor_disposal_probe_runner, /datum/ulthor_disposal_probe_runner, new)

/datum/ulthor_disposal_probe_runner/New()
	..()
	spawn(0)
		run_checks()

/datum/ulthor_disposal_probe_runner/proc/run_checks()
	UNTIL(config)
	CONFIG_SET(flag/hub, FALSE)
	world.update_hub_visibility(FALSE)
	UNTIL(SSatoms.initialized && SSticker.initialized && SSair.initialized)
	sleep(2 SECONDS)
	var/list/results = list()
	var/passed = 0
	for(var/test_type in list(/datum/unit_test/ulthor_disposal_delivery, /datum/unit_test/wall_disposal_rejects_mobs, /datum/unit_test/wall_disposal_items, /datum/unit_test/wall_disposal_construction))
		var/datum/unit_test/test = new test_type
		try
			test.Run()
		catch(var/exception/error)
			test.Fail("Runtime: [error]")
		if(test.succeeded)
			passed++
		results += list(list("test" = "[test_type]", "passed" = test.succeeded, "failures" = test.fail_reasons))
		qdel(test)
	rustlib_file_write(json_encode(list("passed" = passed, "total" = length(results), "tests" = results, "deliveries" = length(GLOB.ulthor_disposal_arrivals), "runtime_log" = GLOB.world_runtime_log)), "ulthor-disposal-result.json")
