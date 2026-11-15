// Tier II and III stationary mining drills (docs/MINING_DRILLS.md, "Буры").
// Stats come from the tier; each tier accepts only stock parts of its own rating.

// MARK: Tier II

/obj/machinery/mining_drill/rig
	name = "drilling rig"
	desc = "A stationary drilling rig on guide rails with a heavy drill head. Mines an ore deposit twice as fast as a basic drill."
	icon_state = "drill2"
	base_icon_state = "drill2"
	tier = 2
	part_rating = 3
	dig_time = 15 SECONDS
	buffer_capacity = 200
	board_type = /obj/item/circuitboard/mining_drill/rig
	packed_type = /obj/item/mining_drill_packed/rig

/obj/item/mining_drill_packed/rig
	icon_state = "drill2_packed"
	drill_type = /obj/machinery/mining_drill/rig

/obj/item/circuitboard/mining_drill/rig
	board_name = "Drilling Rig"
	build_path = /obj/machinery/mining_drill/rig
	origin_tech = "materials=5;engineering=5;programming=3"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/sheet/plasteel = 5,
	)
	part_rating = 3
	tier_parts = list(
		/obj/item/stock_parts/manipulator = /obj/item/stock_parts/manipulator/pico,
		/obj/item/stock_parts/micro_laser = /obj/item/stock_parts/micro_laser/ultra,
		/obj/item/stock_parts/capacitor = /obj/item/stock_parts/capacitor/super,
		/obj/item/stock_parts/matter_bin = /obj/item/stock_parts/matter_bin/super,
	)

// MARK: Tier III

/obj/machinery/mining_drill/deep_core
	name = "deep core drilling rig"
	desc = "A dense, compact deep core drilling rig wrapped in coolant pipes. Mines an ore deposit six times as fast as a basic drill."
	icon_state = "drill3"
	base_icon_state = "drill3"
	tier = 3
	part_rating = 4
	dig_time = 5 SECONDS
	buffer_capacity = 200
	board_type = /obj/item/circuitboard/mining_drill/deep_core
	packed_type = /obj/item/mining_drill_packed/deep_core

/obj/item/mining_drill_packed/deep_core
	icon_state = "drill3_packed"
	drill_type = /obj/machinery/mining_drill/deep_core

/obj/item/circuitboard/mining_drill/deep_core
	board_name = "Deep Core Drilling Rig"
	build_path = /obj/machinery/mining_drill/deep_core
	origin_tech = "materials=7;engineering=6;programming=5;bluespace=5"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/sheet/mineral/diamond = 2,
	)
	part_rating = 4
	tier_parts = list(
		/obj/item/stock_parts/manipulator = /obj/item/stock_parts/manipulator/femto,
		/obj/item/stock_parts/micro_laser = /obj/item/stock_parts/micro_laser/quadultra,
		/obj/item/stock_parts/capacitor = /obj/item/stock_parts/capacitor/quadratic,
		/obj/item/stock_parts/matter_bin = /obj/item/stock_parts/matter_bin/bluespace,
	)

// MARK: Designs

/datum/design/mining_drill_rig_board
	name = "Machine Board (Drilling Rig)"
	desc = "The circuit board for a tier II drilling rig."
	id = "mining_drill_rig_board"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_PROGRAMMING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mining_drill/rig
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/// The cost covers the board, the tier II parts and the frame with plasteel.
/datum/design/mining_drill_rig
	name = "Drilling Rig"
	desc = "A packed tier II drilling rig, ready to be set up on an ore deposit. Power cell not included."
	id = "mining_drill_rig"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_POWERSTORAGE = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20000, MAT_GLASS = 5000, MAT_PLASMA = 8000, MAT_SILVER = 3000, MAT_GOLD = 3000)
	build_path = /obj/item/mining_drill_packed/rig
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/mining_drill_deep_core_board
	name = "Machine Board (Deep Core Drilling Rig)"
	desc = "The circuit board for a tier III deep core drilling rig."
	id = "mining_drill_deep_core_board"
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_BLUESPACE = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mining_drill/deep_core
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/// The cost covers the board, the tier III parts and the frame with plasteel and diamonds.
/datum/design/mining_drill_deep_core
	name = "Deep Core Drilling Rig"
	desc = "A packed tier III deep core drilling rig, ready to be set up on an ore deposit. Power cell not included."
	id = "mining_drill_deep_core"
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_BLUESPACE = 5, RESEARCH_TREE_MAGNETS = 6, RESEARCH_TREE_POWERSTORAGE = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30000, MAT_GLASS = 8000, MAT_PLASMA = 12000, MAT_SILVER = 4000, MAT_GOLD = 6000, MAT_DIAMOND = 6000, MAT_BLUESPACE = 4000)
	build_path = /obj/item/mining_drill_packed/deep_core
	category = list(PROTOLATHE_CATEGORY_MINING)
