/**
 * # Ore Ejector Module
 *
 * Moves the drill's buffered ore onto the neighbouring tile on its output side
 * (the drill's dir, shown by the yellow arrow): into an ore box, onto a conveyor or the floor.
 * When that tile is blocked, the ore stays in the buffer.
 */
/obj/item/mining_drill_module/ejector
	name = "ore ejector module"
	desc = "An output module for a stationary mining drill. Pushes mined ore out onto the tile the drill's arrow points at: into an ore pipe, an ore box, onto a conveyor or onto the floor."
	icon_state = "module_ejector"
	origin_tech = "materials=2;engineering=2"

/obj/item/mining_drill_module/ejector/process_output(obj/machinery/mining_drill/drill)
	if(!drill.buffer_total() || !isturf(drill.loc))
		return
	var/turf/target = get_step(drill, drill.dir)
	if(!target || target.density)
		return
	var/atom/receiver = find_receiver(target)
	if(!receiver)
		return
	for(var/obj/item/stack/ore/ore_type as anything in drill.buffer.Copy())
		var/amount = drill.take_from_buffer(ore_type, drill.buffer[ore_type])
		if(amount > 0)
			new ore_type(receiver, amount)

/// Where ejected ore goes on `target`, or null if there is nowhere to put it.
/obj/item/mining_drill_module/ejector/proc/find_receiver(turf/target)
	// An ore pipe takes the ore straight to its outlet, or keeps it in the buffer without one.
	var/obj/structure/ore_pipe/pipe = locate() in target
	if(pipe)
		return pipe.get_output_receiver()
	var/obj/structure/ore_box/box = locate() in target
	if(box)
		return box
	if(target.is_blocked_turf(exclude_mobs = TRUE))
		return null
	return target

/obj/item/mining_drill_module/ejector/get_ui_data(obj/machinery/mining_drill/drill)
	return list(
		"kind" = "ejector",
		"direction" = dir2text(drill.dir),
		"blocked" = isturf(drill.loc) && !find_receiver_safe(drill),
	)

/obj/item/mining_drill_module/ejector/proc/find_receiver_safe(obj/machinery/mining_drill/drill)
	var/turf/target = get_step(drill, drill.dir)
	if(!target || target.density)
		return null
	return find_receiver(target)

/obj/item/mining_drill_module/ejector/ui_act_module(action, list/params, obj/machinery/mining_drill/drill, mob/user)
	if(action != "set_direction")
		return FALSE
	var/new_dir = text2dir(params["direction"])
	if(!(new_dir in GLOB.cardinal))
		return FALSE
	drill.setDir(new_dir)
	return TRUE

/datum/design/mining_drill_ejector
	name = "Ore Ejector Module"
	desc = "An output module that pushes a mining drill's ore onto a neighbouring tile."
	id = "mining_drill_ejector"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_ENGINEERING = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000)
	build_path = /obj/item/mining_drill_module/ejector
	category = list(PROTOLATHE_CATEGORY_MINING)
