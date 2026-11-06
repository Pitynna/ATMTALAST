/// Included only by test_server_temp_cleanup.py, never by paradise.dme.
GLOBAL_DATUM_INIT(server_temp_cleanup_probe, /datum/server_temp_cleanup_probe, new)

/datum/server_temp_cleanup_probe/New()
	..()
	spawn(0)
		run_probe()

/datum/server_temp_cleanup_probe/proc/run_probe()
	UNTIL(SSserver_maint.initialized)
	var/datum/unit_test/server_temp_cleanup/test = new
	test.Run()
	rustlib_file_write(json_encode(list("passed" = test.succeeded, "failures" = test.fail_reasons)), "docs/chat_repair/temp-cleanup-result.json")
