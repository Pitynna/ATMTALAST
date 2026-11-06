/// Ulthor, migrated from the author's 2024 ATMTA layout.
/datum/map/ulthor
	name = "Ulthor"
	map_path = "_maps/map_files/Ulthor/Ulthor.dmm"
	station_name = "Ulthor"
	english_station_name = "NSS Ulthor"
	station_short = "Ulthor"
	dock_name = "Nanotrasen Central Command"
	company_name = "Nanotrasen"
	company_short = "NT"
	starsys_name = "Epsilon Lucustae"

/// Ulthor carries its own six shuttles. The shared CentCom map also has default
/// copies: retire those ports before initialization so each ID has one ship.
/datum/map/ulthor/prepare_map()
	var/list/authored_ships = list()
	for(var/obj/docking_port/mobile/ship in world)
		if(is_station_level(ship.z) && ship.id)
			authored_ships[ship.id] = ship
	for(var/obj/docking_port/mobile/ship in world)
		if(authored_ships[ship.id] && authored_ships[ship.id] != ship)
			qdel(ship, force = TRUE)
	// The original administration shuttle is one column wider than the default.
	for(var/obj/docking_port/stationary/dock in world)
		if(dock.id == "admin_away")
			dock.width = 19
			dock.dwidth = 9
