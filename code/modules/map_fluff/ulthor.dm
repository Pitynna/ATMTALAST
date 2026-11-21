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
	addition_goals_enabled = FALSE

/// Ulthor carries its own shuttles. The shared CentCom map also has default
/// copies: retire those ports before initialization so each ID has one ship.
/datum/map/ulthor/prepare_map()
	var/list/authored_ships = list()
	for(var/obj/docking_port/mobile/ship in world)
		if(is_station_level(ship.z) && ship.id)
			authored_ships[ship.id] = ship
	for(var/obj/docking_port/mobile/ship in world)
		if(ship.id == AGS_SHUTTLE_ID || (authored_ships[ship.id] && authored_ships[ship.id] != ship))
			qdel(ship, force = TRUE)
	// The original administration shuttle is one column wider than the default.
	for(var/obj/docking_port/stationary/dock in world)
		if(dock.id == AGS_SHUTTLE_CENTCOM_DOCK)
			qdel(dock, force = TRUE)
		else if(dock.id == "admin_away")
			dock.width = 19
			dock.dwidth = 9
	prepare_research_outpost_landing()

/// Use the clear ground east of the outpost's existing exterior airlock.
/datum/map/ulthor/proc/prepare_research_outpost_landing()
	var/datum/space_level/mining_level = GLOB.space_manager.levels_by_name[MINING]
	if(!mining_level)
		return
	var/turf/landing_hatch = locate(159, 184, mining_level.zpos)
	if(!landing_hatch)
		return
	// The shuttle restores the same turf and area throughout the footprint on departure.
	var/obj/docking_port/stationary/ulthor_research_outpost/dock = new(landing_hatch)
	for(var/turf/landing_turf as anything in dock.return_ordered_turfs())
		var/area/landing_area = get_area(landing_turf)
		if(landing_turf?.type != dock.turf_type || landing_area?.type != dock.area_type || (locate(/obj/structure) in landing_turf) || (locate(/obj/machinery) in landing_turf))
			WARNING("The Ulthor research shuttle landing area is obstructed.")
			qdel(dock, force = TRUE)
			return

/obj/docking_port/stationary/ulthor_research_outpost
	id = "ulthor_research_away"
	name = "Research Outpost Landing Zone (EVA)"
	desc = "An open landing zone east of the research outpost's exterior airlock."
	dir = EAST
	width = 5
	dwidth = 2
	height = 4
	turf_type = /turf/simulated/floor/plating/asteroid/airless
	area_type = /area/mine/explored

/obj/machinery/computer/shuttle/science/ulthor
	name = "Research Shuttle Console"
	desc = "Controls the research shuttle between Ulthor and the asteroid research outpost. EVA gear is required at the outpost landing zone."
	req_access = list(ACCESS_XENOARCH)
	shuttleId = "ulthor_research"
	possible_destinations = "ulthor_research_home;ulthor_research_away"

/// Hand-made poster from the maintenance "micro-asylum" on the 2 May 2024 Ulthor layout.
/// The sprite is taken from the author's StrongDMM screenshot, low resolution included.
/obj/structure/sign/poster/contraband/ulthor_orderly
	name = "Санитар"
	desc = "Пережатый до неузнаваемости портрет санитара. Он следит, чтобы вы приняли таблетки."
	icon = 'icons/obj/ulthor_posters.dmi'
	icon_state = "orderly"
	never_random = TRUE
