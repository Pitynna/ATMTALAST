// Made by PiroMage (https://github.com/PiroMage)

/datum/map/nova
	name = "Nova"
	map_path = "_maps/map_files/nova/nova.dmm"
	traits = list(
		list(MAIN_STATION, STATION_LEVEL = "First Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP),
		list(STATION_LEVEL = "Second Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
	)
	space_ruins_levels = 0
	station_name = "ИСН Нова"
	english_station_name = "NSS Nova"
	station_short = "Нова"
	dock_name = "АКН Трурль"
	company_name = "\"Нанотрейзен\""
	company_short = "НТ"
	starsys_name = "Эпсилон Лукуста"
	webmap_url = null
