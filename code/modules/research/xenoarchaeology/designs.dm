/datum/design/xenoarch_depth_scanner
	id = "xenoarch_depth_scanner"
	req_tech = list(RESEARCH_TREE_MAGNETS = 2, RESEARCH_TREE_MATERIALS = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/xenoarch_tool/depth_scanner
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/xenoarch_core_sampler
	id = "xenoarch_core_sampler"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_MATERIALS = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 500)
	build_path = /obj/item/xenoarch_tool/core_sampler
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/xenoarch_counter
	id = "xenoarch_counter"
	req_tech = list(RESEARCH_TREE_MAGNETS = 3, RESEARCH_TREE_BLUESPACE = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000, MAT_SILVER = 500)
	build_path = /obj/item/xenoarch_tool/anomaly_scanner
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/xenoarch_picks
	id = "xenoarch_picks"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_ENGINEERING = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/storage/box/excavation
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/xenoarch_battery
	id = "xenoarch_battery"
	req_tech = list(RESEARCH_TREE_MAGNETS = 3, RESEARCH_TREE_BLUESPACE = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/xenoarch_battery
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/xenoarch_utilizer
	id = "xenoarch_utilizer"
	req_tech = list(RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_BLUESPACE = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 2000, MAT_GOLD = 2000)
	build_path = /obj/item/xenoarch_utilizer
	category = list(PROTOLATHE_CATEGORY_MINING)

/obj/item/circuitboard/xenoarch_spectrometer
	board_name = "Geological Mass Spectrometer"
	build_path = /obj/machinery/xenoarch/spectrometer
	board_type = "machine"
	req_components = list(/obj/item/stock_parts/scanning_module = 2, /obj/item/stock_parts/micro_laser = 1, /obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/xenoarch_analyser
	board_name = "Artifact Analyser"
	build_path = /obj/machinery/xenoarch/analyser
	board_type = "machine"
	req_components = list(/obj/item/stock_parts/scanning_module = 2, /obj/item/stock_parts/micro_laser = 2, /obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/xenoarch_harvester
	board_name = "Exotic Particle Harvester"
	build_path = /obj/machinery/xenoarch/harvester
	board_type = "machine"
	req_components = list(/obj/item/stock_parts/scanning_module = 1, /obj/item/stock_parts/capacitor = 2, /obj/item/stock_parts/manipulator = 2)

/obj/item/circuitboard/xenoarch_suspension
	board_name = "Anomaly Suspension Generator"
	build_path = /obj/machinery/xenoarch/suspension
	board_type = "machine"
	req_components = list(/obj/item/stock_parts/capacitor = 2, /obj/item/stock_parts/micro_laser = 2)

/datum/design/xenoarch_board
	id = "xenoarch_spectrometer_board"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 2, RESEARCH_TREE_MAGNETS = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_SILVER = 500)
	build_path = /obj/item/circuitboard/xenoarch_spectrometer
	category = list(CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/xenoarch_board/analyser
	id = "xenoarch_analyser_board"
	build_path = /obj/item/circuitboard/xenoarch_analyser
/datum/design/xenoarch_board/harvester
	id = "xenoarch_harvester_board"
	build_path = /obj/item/circuitboard/xenoarch_harvester
/datum/design/xenoarch_board/suspension
	id = "xenoarch_suspension_board"
	build_path = /obj/item/circuitboard/xenoarch_suspension
