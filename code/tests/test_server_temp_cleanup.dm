/// Server startup and shutdown must preserve nested tool artifacts in tmp/.
/datum/unit_test/server_temp_cleanup/Run()
	var/sentinel_path = "tmp/server-temp-cleanup-test/sentinel.txt"
	text2file("preserve tool files", sentinel_path)
	TEST_ASSERT(fexists(sentinel_path), "Could not create the cleanup sentinel")

	SSserver_maint.Initialize()
	TEST_ASSERT(fexists(sentinel_path), "Server initialization deleted a nested tmp file")

	SSserver_maint.Shutdown()
	TEST_ASSERT(fexists(sentinel_path), "Server shutdown deleted a nested tmp file")

	// Delete only the file this test owns; never recurse through tmp/.
	fdel(sentinel_path)
