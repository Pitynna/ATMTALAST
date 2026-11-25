/// Included only by run_guardbuddy_checks.py.
GLOBAL_DATUM_INIT(ulthor_guardbuddy_probe, /datum/ulthor_guardbuddy_probe, new)

/datum/ulthor_guardbuddy_probe
	var/list/checks = list()

/datum/ulthor_guardbuddy_probe/New()
	..()
	INVOKE_ASYNC(src, PROC_REF(run_checks))

/datum/ulthor_guardbuddy_probe/proc/check(label, outcome)
	checks += list(list("check" = label, "passed" = !!outcome))
	log_world("Guardbuddy check: [label]: [outcome ? "pass" : "FAIL"]")
	return outcome

/datum/ulthor_guardbuddy_probe/proc/run_checks()
	UNTIL(SSatoms.initialized && SSair.initialized && SSticker.initialized)
	CONFIG_SET(flag/hub, FALSE)
	world.update_hub_visibility(FALSE)
	GLOB.master_mode = "extended"
	SSticker.force_start = TRUE
	SSticker.delay_end = TRUE
	var/deadline = world.time + 45 SECONDS
	while(!SSticker.HasRoundStarted() && world.time < deadline)
		sleep(1 SECONDS)
	try
		if(check("Ulthor extended round started", SSticker.HasRoundStarted()))
			test_cycle()
	catch(var/exception/error)
		check("Probe completed without an exception: [error]", FALSE)
	rustlib_file_write(json_encode(list("checks" = checks, "runtime_log" = GLOB.world_runtime_log)), "guardbuddy-result.json")

/datum/ulthor_guardbuddy_probe/proc/fit(obj/item/part, obj/item/guardbuddy_chassis/frame, mob/living/carbon/human/technician)
	technician.put_in_hands(part)
	frame.attackby(part, technician)
	return part.loc == frame

/datum/ulthor_guardbuddy_probe/proc/wait_for_dock(obj/machinery/guardbuddy_dock/dock, mob/living/simple_animal/bot/guardbuddy/bot)
	var/deadline = world.time + 65 SECONDS
	while(bot.on && world.time < deadline)
		sleep(0.5 SECONDS)
	return dock.on_pad(bot) && !bot.on

/datum/ulthor_guardbuddy_probe/proc/test_cycle()
	var/station_z = level_name_to_num(MAIN_STATION)
	var/turf/pad = locate(163, 178, station_z)
	var/turf/workbench = locate(163, 177, station_z)
	var/obj/machinery/guardbuddy_dock/dock = locate() in pad
	var/obj/machinery/mecha_part_fabricator/fabricator = locate() in locate(162, 175, station_z)
	if(!check("mapped dock and exosuit fabricator have station power", dock?.is_operational() && fabricator?.is_operational()))
		return
	var/mob/living/carbon/human/technician = new(workbench)
	technician.equipOutfit(/datum/outfit/job/roboticist)
	var/mob/living/carbon/human/crewmember = new(locate(162, 177, station_z))
	crewmember.equipOutfit(/datum/outfit/job/assistant)
	check("regular robotics ID grants dock access and assistant ID does not", dock.allowed(technician) && !dock.allowed(crewmember))

	var/datum/component/material_container/materials = fabricator.GetComponent(/datum/component/material_container)
	materials.insert_amount(30000, MAT_METAL)
	materials.insert_amount(5000, MAT_GLASS)
	var/turf/output = get_step(fabricator, fabricator.dir)
	for(var/id in list("guardbuddy_chassis", "guardbuddy_board", "borg_l_arm", "borg_r_arm", "guardbuddy_lamp", "guardbuddy_announcer"))
		var/datum/design/design = fabricator.local_designs.known_designs[id]
		if(!check("mechfab prints [id] with round-start research", design && fabricator.build_design(design)))
			return
		var/deadline = world.time + 30 SECONDS
		while(fabricator.being_built && world.time < deadline)
			sleep(0.5 SECONDS)
		if(!check("printing produced [id]", locate(design.build_path) in output))
			return

	var/obj/item/guardbuddy_chassis/frame = locate() in output
	frame.forceMove(pad)
	var/obj/item/guardbuddy_board/board = locate() in output
	var/obj/item/robot_parts/l_arm/left_arm = locate() in output
	var/obj/item/robot_parts/r_arm/right_arm = locate() in output
	var/obj/item/stock_parts/cell/cell = new(workbench)
	var/obj/item/crowbar/crowbar = new(workbench)
	var/obj/item/screwdriver/screwdriver = new(workbench)
	if(!check("board, standard cell and left arm fit in sequence", fit(board, frame, technician) && fit(cell, frame, technician) && fit(left_arm, frame, technician)))
		return
	frame.crowbar_act(technician, crowbar)
	check("unfitting returns the exact left arm", !frame.arm && !QDELETED(left_arm) && left_arm.loc != frame)
	technician.drop_item_ground(left_arm)
	if(!check("right arm fits in the same chassis", fit(right_arm, frame, technician)))
		return
	frame.unit_name = "Ulthor Buddy"
	frame.screwdriver_act(technician, screwdriver)
	var/mob/living/simple_animal/bot/guardbuddy/bot = locate() in pad
	if(!check("assembled unit carries the selected name and the original cell and chassis", bot?.name == "Ulthor Buddy" && bot.cell == cell && bot.chassis == frame))
		return

	var/obj/item/guardbuddy_module/lamp/lamp = locate() in output
	var/obj/item/guardbuddy_module/announcer/announcer = locate() in output
	bot.attackby(technician.wear_id, technician)
	bot.screwdriver_act(technician, screwdriver)
	technician.put_in_hands(lamp)
	bot.attackby(lamp, technician)
	bot.screwdriver_act(technician, screwdriver)
	check("robotics ID and service panel install the printed lamp", !bot.locked && !bot.open && bot.tool_module == lamp)

	var/datum/tgui/dock_ui = new(technician, dock, "GuardbuddyDock")
	dock_ui.status = UI_INTERACTIVE
	var/datum/tgui/guest_ui = new(crewmember, dock, "GuardbuddyDock")
	guest_ui.status = UI_INTERACTIVE
	check("unauthorized pairing is declined", !dock.ui_act("pair", list(), guest_ui, guest_ui.state) && !dock.assigned)
	dock.ui_act("pair", list(), dock_ui, dock_ui.state)
	if(!check("dock UI pairs the assembled unit", dock.assigned == bot && bot.home_dock == dock))
		return
	dock.ui_act("program", list("program" = "patrol"), dock_ui, dock_ui.state)
	dock.ui_act("dispatch", list(), dock_ui, dock_ui.state)
	if(!check("dock dispatch activates the lamp and patrol assignment", bot.on && bot.light_on && bot.program == "patrol"))
		return
	var/starting_charge = cell.charge
	var/list/visited = list()
	var/deadline = world.time + 80 SECONDS
	while(bot.on && length(visited) < 2 && world.time < deadline)
		for(var/obj/machinery/navbeacon/beacon in bot.loc)
			if(beacon.location in list("Fore Robotics West", "Fore Robotics East"))
				visited |= beacon.location
		sleep(0.2 SECONDS)
	check("bot actually walks out of Robotics and reaches both linked corridor beacons", length(visited) == 2)
	check("patrol draws charge from the installed cell", cell.charge < starting_charge)
	var/list/status = dock.ui_data(technician)
	check("dock reports patrol name, location, tool and assignment", status["name"] == bot.name && status["zone"] == get_area_name(bot) && status["tool"] == lamp.name && status["program"] == "patrol")
	dock.ui_act("recall", list(), dock_ui, dock_ui.state)
	if(!check("manual recall returns the unit to the pad", wait_for_dock(dock, bot)))
		log_world("Guardbuddy stopped at [COORD(bot)] with [bot.stop_reason]")
		return
	cell.charge = min(cell.charge, cell.maxcharge - 100)
	var/recalled_charge = cell.charge
	sleep(4 SECONDS)
	check("powered pad replenishes the same cell", cell.charge > recalled_charge)

	bot.screwdriver_act(technician, screwdriver)
	bot.crowbar_act(technician, crowbar)
	check("service returns the original lamp", !bot.tool_module && lamp.loc != bot)
	technician.drop_item_ground(lamp)
	technician.put_in_hands(announcer)
	bot.attackby(announcer, technician)
	bot.screwdriver_act(technician, screwdriver)
	check("annunciator fits in the original chassis", bot.tool_module == announcer && !bot.open)
	dock.ui_act("program", list("program" = "escort", "target" = crewmember.UID()), dock_ui, dock_ui.state)
	dock.ui_act("dispatch", list(), dock_ui, dock_ui.state)
	crewmember.forceMove(locate(162, 174, station_z))
	deadline = world.time + 30 SECONDS
	while(bot.on && !bot.Adjacent(crewmember) && world.time < deadline)
		sleep(0.5 SECONDS)
	check("escort follows an assigned assistant beyond the docking tile", bot.on && !dock.on_pad(bot) && bot.Adjacent(crewmember))
	check("annunciator sends one call and throttles an immediate repeat", bot.request_help(crewmember) && !bot.request_help(crewmember))
	cell.charge = cell.maxcharge * 0.2
	check("low battery recalls a working escort", wait_for_dock(dock, bot) && bot.stop_reason == "Low battery.")
	test_reagents(bot, technician, crewmember, screwdriver, crowbar)

	qdel(dock_ui)
	qdel(guest_ui)

/datum/ulthor_guardbuddy_probe/proc/test_reagents(mob/living/simple_animal/bot/guardbuddy/bot, mob/living/carbon/human/technician, mob/living/carbon/human/crewmember, obj/item/screwdriver/screwdriver, obj/item/crowbar/crowbar)
	var/turf/pad = get_turf(bot)
	var/turf/open_floor = get_step(pad, SOUTH)
	technician.forceMove(get_step(open_floor, WEST))
	crewmember.forceMove(get_step(technician, WEST))
	var/obj/item/guardbuddy_module/reagent/medicator/medicator = new(open_floor)
	var/obj/item/guardbuddy_module/reagent/smoker/smoker = new(open_floor)
	var/obj/item/reagent_containers/cup/beaker/beaker = new(open_floor)
	var/obj/item/old_module = bot.remove_tool()
	check("removing previous tool preserves the original object", old_module && old_module.loc == pad)
	bot.screwdriver_act(technician, screwdriver)
	technician.put_in_hands(medicator)
	bot.attackby(medicator, technician)
	technician.put_in_hands(beaker)
	bot.attackby(beaker, technician)
	bot.screwdriver_act(technician, screwdriver)
	if(!check("docked service fits the same empty beaker inside Medicator", medicator.beaker == beaker && bot.tool_module == medicator && beaker.loc == medicator))
		return
	bot.set_assignment("standby", null)
	bot.cell.charge = bot.cell.maxcharge
	bot.dispatch()
	check("empty beaker refuses to fire", !bot.use_module(open_floor) && !beaker.reagents.total_volume && !!medicator.tool_error)
	beaker.reagents.add_reagent("water", 22)
	beaker.reagents.add_reagent("colorful_reagent", 11)
	check("out-of-range shot consumes no reagents", !bot.use_module(locate(1, 1, bot.z)) && beaker.reagents.total_volume == 33)
	check("Medicator spends one 10u portion on a shot at an empty tile", bot.use_module(open_floor) && round(beaker.reagents.total_volume, 0.1) == 23)
	check("immediate duplicate shot leaves the mixture untouched", !bot.use_module(open_floor) && round(beaker.reagents.total_volume, 0.1) == 23)
	check("shot preserves the two-to-one mixture ratio", round(beaker.reagents.get_reagent_amount("water") / beaker.reagents.get_reagent_amount("colorful_reagent"), 0.1) == 2)

	bot.turn_off()
	bot.screwdriver_act(technician, screwdriver)
	bot.crowbar_act(technician, crowbar)
	check("detached Medicator still owns the original beaker and remaining mixture", !bot.tool_module && beaker.loc == medicator && round(beaker.reagents.total_volume, 0.1) == 23)
	check("a late activation on the original unit cannot spend a detached module's mixture", !bot.use_module(open_floor) && round(beaker.reagents.total_volume, 0.1) == 23)
	var/mob/living/simple_animal/bot/guardbuddy/other = new(open_floor)
	other.locked = FALSE
	other.open = TRUE
	other.attackby(medicator, technician)
	check("loaded module transfers to another bot with the same beaker and residue", other.tool_module == medicator && medicator.beaker == beaker && round(beaker.reagents.total_volume, 0.1) == 23)
	other.crowbar_act(technician, crowbar)
	medicator.attack_self(technician)
	check("ejecting from the loose module returns the beaker with the exact residue", !medicator.beaker && beaker.loc != medicator && round(beaker.reagents.total_volume, 0.1) == 23)
	technician.drop_item_ground(medicator)
	smoker.attackby(beaker, technician)
	qdel(other)
	technician.put_in_hands(smoker)
	bot.attackby(smoker, technician)
	bot.screwdriver_act(technician, screwdriver)
	bot.dispatch()
	COOLDOWN_RESET(bot, tool_cycle)
	check("Smoker accepts the same beaker and emits one smoke cloud for 15u", smoker.beaker == beaker && bot.use_module(open_floor) && round(beaker.reagents.total_volume, 0.1) == 8)
	check("a chemical smoke effect appears at the bot", locate(/obj/effect/particle_effect/fluid/smoke/chem) in pad)
	check("immediate duplicate smoke request consumes no second portion", !bot.use_module(open_floor) && round(beaker.reagents.total_volume, 0.1) == 8)
	COOLDOWN_RESET(bot, tool_cycle)
	check("Smoker refuses an incomplete portion and keeps the remaining 8u", !bot.use_module(open_floor) && round(beaker.reagents.total_volume, 0.1) == 8 && !!smoker.tool_error)
	bot.turn_off()
