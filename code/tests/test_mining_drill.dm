/// A protolathe drill comes packed with tier I parts and no power cell.
/datum/unit_test/mining_drill_packed/Run()
	var/obj/item/mining_drill_packed/packed = allocate(/obj/item/mining_drill_packed)
	var/obj/machinery/mining_drill/drill = packed.drill
	TEST_ASSERT_NOTNULL(drill, "The packed item must hold a drill")
	TEST_ASSERT_EQUAL(drill.loc, packed, "The drill must travel inside the packed item")
	TEST_ASSERT_NULL(drill.cell, "Drills never ship with a power cell")
	TEST_ASSERT_EQUAL(packed.w_class, WEIGHT_CLASS_GIGANTIC, "The packed drill must not fit in any storage")
	var/part_count = 0
	for(var/obj/item/stock_parts/part in drill.component_parts)
		part_count++
		TEST_ASSERT_EQUAL(part.rating, drill.part_rating, "[part] must match the drill tier")
	TEST_ASSERT_EQUAL(part_count, 5, "Tier I drills use five stock parts")
	TEST_ASSERT_NOTNULL(locate(/obj/item/circuitboard/mining_drill) in drill.component_parts, "The drill must contain its board")

/// A drill set up off a deposit reports it and does not run.
/datum/unit_test/mining_drill_without_deposit/Run()
	var/obj/machinery/mining_drill/drill = allocate(/obj/machinery/mining_drill)
	drill.on = TRUE
	drill.update_status()
	TEST_ASSERT_EQUAL(drill.status, "No ore deposit", "A drill off a deposit must say so")
