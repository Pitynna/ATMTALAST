/// Regression checks for Ulthor's migrated utilities. Other stations skip them.
/datum/unit_test/ulthor_power/Run()
	if(!istype(SSmapping.map_datum, /datum/map/ulthor))
		return
	var/count = 0
	for(var/obj/machinery/power/apc/apc in world)
		if(!is_station_level(apc.z))
			continue
		count++
		var/area/zone = get_area(apc)
		TEST_ASSERT_NOT(istype(zone, /area/space), "APC at [apc.x]:[apc.y] must control a station room")
		TEST_ASSERT_EQUAL(length(zone.apc), 1, "Each Ulthor APC needs an independent area")
		TEST_ASSERT_NOTNULL(apc.terminal?.powernet, "APC at [apc.x]:[apc.y] must connect to a cable network")
	TEST_ASSERT(count, "Ulthor must load its mapped APCs")
	for(var/obj/machinery/machine in world)
		if(!is_station_level(machine.z) || !machine.use_power)
			continue
		var/area/zone = get_area(machine)
		if(zone.requires_power)
			TEST_ASSERT(length(zone.apc), "Powered [machine.type] at [machine.x]:[machine.y] needs an area APC")
	for(var/obj/machinery/power/smes/smes in world)
		if(!is_station_level(smes.z))
			continue
		TEST_ASSERT_NOTNULL(smes.terminal?.powernet, "SMES at [smes.x]:[smes.y] needs an input network")
		TEST_ASSERT_NOTNULL(smes.powernet, "SMES at [smes.x]:[smes.y] needs an output network")
		TEST_ASSERT_NOTEQUAL(smes.terminal.powernet, smes.powernet, "SMES at [smes.x]:[smes.y] input must remain separate from its output")


/datum/unit_test/ulthor_atmos/Run()
	if(!istype(SSmapping.map_datum, /datum/map/ulthor))
		return
	var/station_z = level_name_to_num(MAIN_STATION)
	var/list/filter_positions = list(
		list(173, 141, TLV_CO2), list(173, 138, TLV_PL),
		list(180, 138, TLV_O2), list(173, 135, TLV_N2O), list(180, 135, TLV_N2),
	)
	for(var/list/position in filter_positions)
		var/obj/machinery/atmospherics/trinary/filter/filter = locate() in locate(position[1], position[2], station_z)
		TEST_ASSERT_NOTNULL(filter, "The mapped gas filter must exist")
		TEST_ASSERT_EQUAL(filter.filter_type, position[3], "Old numeric filter values must be migrated to gas IDs")
		TEST_ASSERT(filter.node1 && filter.node2 && filter.node3, "Each gas filter needs all three ports")
	var/obj/machinery/atmospherics/unary/vent_scrubber/scrubber = locate() in locate(161, 147, station_z)
	TEST_ASSERT_NOTNULL(scrubber?.node, "The server scrubber must connect to its waste line")
	TEST_ASSERT_EQUAL(scrubber.node.icon_connect_type, "-scrubbers", "The scrubber must not join the heat-exchange circuit")
	var/obj/machinery/atmospherics/unary/vent_pump/pump = locate() in locate(170, 136, station_z)
	TEST_ASSERT_NOTNULL(pump, "The N2O tank outlet must exist")
	TEST_ASSERT_NOT(pump.releasing, "The tank outlet must siphon instead of injecting station air")

/datum/unit_test/ulthor_lighting/Run()
	if(!istype(SSmapping.map_datum, /datum/map/ulthor))
		return
	var/count = 0
	for(var/obj/machinery/light_switch/lightswitch in world)
		if(!is_station_level(lightswitch.z))
			continue
		count++
		TEST_ASSERT_NOTNULL(lightswitch.area, "Every switch must resolve its controlled area before icon updates")
		lightswitch.update_appearance()
	TEST_ASSERT(count, "Ulthor must have working light switches")

/datum/unit_test/ulthor_shuttles/Run()
	if(!istype(SSmapping.map_datum, /datum/map/ulthor))
		return
	// Initial docking runs asynchronously through MILLA.
	sleep(5 SECONDS)
	var/list/ids = list()
	for(var/obj/docking_port/mobile/ship in SSshuttle.mobile)
		TEST_ASSERT_NOT(ids[ship.id], "Mobile shuttle ID [ship.id] must be registered once")
		ids[ship.id] = TRUE
	for(var/id in list("supply", "emergency", "admin", "specops", "mining", "laborcamp"))
		var/obj/docking_port/mobile/ship = SSshuttle.getShuttle(id)
		TEST_ASSERT_NOTNULL(ship, "Ulthor must retain its [id] shuttle")
		TEST_ASSERT_NOTNULL(ship.areaInstance, "Each ship needs a dedicated shuttle area")
		var/obj/docking_port/stationary/home = SSshuttle.getDock("[id]_home")
		TEST_ASSERT_NOTNULL(home, "The [id] home dock must exist")
		var/docking_status = ship.canDock(home)
		TEST_ASSERT(docking_status == SHUTTLE_CAN_DOCK || docking_status == SHUTTLE_ALREADY_DOCKED, "The authored [id] ship must fit its home dock")
	// A real round trip exercises the copied hull, contents and docking geometry.
	var/obj/docking_port/mobile/miner = SSshuttle.getShuttle("mining")
	for(var/destination in list("mining_away", "mining_home"))
		var/obj/docking_port/stationary/dock = SSshuttle.getDock(destination)
		TEST_ASSERT_NOTNULL(dock, "The mining route must have both endpoints")
		miner.dock(dock)
		for(var/attempt in 1 to 100)
			if(miner.getDockedId() == destination)
				break
			sleep(1)
		TEST_ASSERT_EQUAL(miner.getDockedId(), destination, "The mining shuttle must actually complete its trip")

/datum/unit_test/ulthor_arrivals/Run()
	if(!istype(SSmapping.map_datum, /datum/map/ulthor))
		return
	TEST_ASSERT(length(GLOB.latejoin), "Ulthor must register late arrival locations")
	TEST_ASSERT(length(GLOB.latejoin_cryo), "Ulthor must register cryosleep locations")
	TEST_ASSERT(length(GLOB.latejoin_cyborg), "Ulthor must register late cyborg locations")
	TEST_ASSERT(length(GLOB.latejoin_gateway), "Ulthor must register gateway arrivals")
	for(var/turf/arrival as anything in GLOB.latejoin)
		TEST_ASSERT(isfloorturf(arrival) && is_station_level(arrival.z), "Arrival points must be on a station floor")
