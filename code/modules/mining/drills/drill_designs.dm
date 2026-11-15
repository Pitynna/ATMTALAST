// Research designs for the stationary mining drills (docs/MINING_DRILLS.md, "РнД").

/datum/design/mining_drill_board
	name = "Machine Board (Mining Drill)"
	desc = "The circuit board for a tier I stationary mining drill."
	id = "mining_drill_board"
	req_tech = list(RESEARCH_TREE_MATERIALS = 1, RESEARCH_TREE_ENGINEERING = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mining_drill
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/// Prints the packed drill with tier I parts already inside. The cost covers the frame, board and parts.
/datum/design/mining_drill
	name = "Mining Drill"
	desc = "A packed tier I stationary mining drill, ready to be set up on an ore deposit. Power cell not included."
	id = "mining_drill"
	req_tech = list(RESEARCH_TREE_MATERIALS = 1, RESEARCH_TREE_ENGINEERING = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12000, MAT_GLASS = 3000)
	build_path = /obj/item/mining_drill_packed
	category = list(PROTOLATHE_CATEGORY_MINING)
