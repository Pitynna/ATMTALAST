/**
 * # Ore pipe
 *
 * Instant ore transport for stationary mining drills. Segments join every
 * neighbouring segment automatically. Ore handed to any segment appears at once
 * in front of the network's single [/obj/structure/ore_pipe/outlet].
 * A network without an outlet accepts nothing, so the ore stays in the drill.
 * Laid and removed with [/obj/item/ore_pipe_layer] on floors and lattices.
 */
/obj/structure/ore_pipe
	name = "ore pipe"
	desc = "A sturdy pipe that carries ore from mining drills straight to its outlet."
	icon = 'icons/obj/mining_drills.dmi'
	icon_state = "ore_pipe_0"
	anchored = TRUE
	density = FALSE
	layer = GAS_PIPE_VISIBLE_LAYER
	max_integrity = 60
	armor = list(MELEE = 20, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 80, ACID = 50)
	resistance_flags = FIRE_PROOF

/obj/structure/ore_pipe/Initialize(mapload)
	. = ..()
	update_connections(TRUE)

/obj/structure/ore_pipe/Destroy()
	var/list/neighbours = get_connected_pipes()
	. = ..()
	for(var/obj/structure/ore_pipe/neighbour as anything in neighbours)
		if(!QDELETED(neighbour))
			neighbour.update_icon()

/obj/structure/ore_pipe/examine(mob/user)
	. = ..()
	var/list/outlets = find_outlets()
	if(!length(outlets))
		. += span_warning("This pipe network has no outlet; drills cannot send ore into it.")
	. += span_notice("Use an ore pipe layer on it to remove it.")

/// Whether this piece joins a neighbour in `direction`.
/obj/structure/ore_pipe/proc/connects_to(direction)
	return TRUE

/obj/structure/ore_pipe/proc/get_connected_pipes()
	. = list()
	for(var/direction in GLOB.cardinal)
		if(!connects_to(direction))
			continue
		for(var/obj/structure/ore_pipe/neighbour in get_step(src, direction))
			if(!QDELETED(neighbour) && neighbour.connects_to(REVERSE_DIR(direction)))
				. += neighbour

/// Refreshes our sprite, and our neighbours' when `update_neighbours` is set.
/obj/structure/ore_pipe/proc/update_connections(update_neighbours = FALSE)
	update_icon()
	if(update_neighbours)
		for(var/obj/structure/ore_pipe/neighbour as anything in get_connected_pipes())
			neighbour.update_icon()

/obj/structure/ore_pipe/proc/get_connection_mask()
	. = NONE
	for(var/direction in GLOB.cardinal)
		if(!connects_to(direction))
			continue
		for(var/obj/structure/ore_pipe/neighbour in get_step(src, direction))
			if(!QDELETED(neighbour) && neighbour.connects_to(REVERSE_DIR(direction)))
				. |= direction
				break

/obj/structure/ore_pipe/update_icon_state()
	icon_state = "ore_pipe_[get_connection_mask()]"

/// Every segment and outlet joined to this one.
/obj/structure/ore_pipe/proc/get_network()
	var/list/network = list(src)
	var/index = 1
	while(index <= length(network))
		var/obj/structure/ore_pipe/current = network[index++]
		for(var/obj/structure/ore_pipe/neighbour as anything in current.get_connected_pipes())
			if(!(neighbour in network))
				network += neighbour
	return network

/obj/structure/ore_pipe/proc/find_outlets()
	. = list()
	for(var/obj/structure/ore_pipe/outlet/outlet in get_network())
		. += outlet

/// Where ore entering this network ends up right now, or null if it cannot be delivered.
/obj/structure/ore_pipe/proc/get_output_receiver()
	var/list/outlets = find_outlets()
	if(length(outlets) != 1)
		return null
	var/obj/structure/ore_pipe/outlet/outlet = outlets[1]
	return outlet.get_front_receiver()

/obj/structure/ore_pipe/deconstruct(disassembled = TRUE)
	qdel(src)

/**
 * # Ore pipe outlet
 *
 * The end of an ore pipe network. Lays the ore on the tile in front of it:
 * into an ore box, onto a conveyor or the floor. Rotate it with a wrench.
 */
/obj/structure/ore_pipe/outlet
	name = "ore pipe outlet"
	desc = "The end of an ore pipe. Ore from the whole network comes out on the tile it faces."
	icon_state = "ore_pipe_outlet"
	dir = SOUTH
	layer = LOW_OBJ_LAYER

/obj/structure/ore_pipe/outlet/connects_to(direction)
	return direction != dir

/obj/structure/ore_pipe/outlet/update_icon_state()
	icon_state = "ore_pipe_outlet"

/obj/structure/ore_pipe/outlet/update_overlays()
	. = ..()
	var/mask = get_connection_mask()
	for(var/direction in GLOB.cardinal)
		if(mask & direction)
			. += "ore_pipe_stub_[direction]"

/obj/structure/ore_pipe/outlet/examine(mob/user)
	. = ..()
	. += span_notice("It faces [dir2text(dir)]. Use a wrench to rotate it.")
	if(!get_front_receiver())
		. += span_warning("The tile in front of it is blocked.")

/// The atom ore is delivered into: an ore box in front, or the free tile itself.
/obj/structure/ore_pipe/outlet/proc/get_front_receiver()
	var/turf/front = get_step(src, dir)
	if(!front || front.density)
		return null
	var/obj/structure/ore_box/box = locate() in front
	if(box)
		return box
	if(front.is_blocked_turf(exclude_mobs = TRUE))
		return null
	return front

/obj/structure/ore_pipe/outlet/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	var/old_dir = dir
	var/new_dir = turn(dir, -90)
	if(!can_face(new_dir))
		to_chat(user, span_warning("Turning [src] that way would join a network that already has an outlet."))
		return
	if(!tool.use_tool(src, user, 0, volume = tool.tool_volume))
		return
	setDir(new_dir)
	for(var/direction in list(old_dir, new_dir))
		for(var/obj/structure/ore_pipe/neighbour in get_step(src, direction))
			neighbour.update_icon()
	update_icon()
	to_chat(user, span_notice("You turn [src] to face [dir2text(dir)]."))

/// Whether facing `new_dir` keeps every joined network down to one outlet.
/obj/structure/ore_pipe/outlet/proc/can_face(new_dir)
	var/old_dir = dir
	dir = new_dir
	var/list/outlets = find_outlets()
	dir = old_dir
	return length(outlets) <= 1

/**
 * # Ore pipe layer
 *
 * Lays ore pipe segments and outlets on floors and lattices, and removes them.
 * No materials are used and there is no limit on length.
 */
/obj/item/ore_pipe_layer
	name = "ore pipe layer"
	desc = "A handheld tool that lays and removes ore pipes. Use it in hand to switch between pipe and outlet; outlets face the way you are facing."
	icon = 'icons/obj/mining_drills.dmi'
	icon_state = "pipe_layer"
	item_state = "rpd"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	flags = CONDUCT
	force = 6
	origin_tech = "materials=2;engineering=2"
	/// Lays outlets instead of pipe segments.
	var/outlet_mode = FALSE

/obj/item/ore_pipe_layer/examine(mob/user)
	. = ..()
	. += span_notice("It is set to lay [outlet_mode ? "outlets" : "pipe segments"].")

/obj/item/ore_pipe_layer/attack_self(mob/user)
	outlet_mode = !outlet_mode
	to_chat(user, span_notice("[src] will now lay [outlet_mode ? "outlets" : "pipe segments"]."))
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	return TRUE

/obj/item/ore_pipe_layer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	// Only work on the map: clicks on bags and other storage must still put the layer inside.
	if(isstorage(interacting_with) || (!isturf(interacting_with) && !isturf(interacting_with.loc)))
		return NONE
	var/turf/target = get_turf(interacting_with)
	if(!target || !user.Adjacent(target))
		return NONE
	var/obj/structure/ore_pipe/existing = locate() in target
	if(existing)
		if(!do_after(user, 1 SECONDS, target))
			return ITEM_INTERACT_BLOCKING
		if(QDELETED(existing))
			return ITEM_INTERACT_BLOCKING
		to_chat(user, span_notice("You remove [existing]."))
		playsound(target, 'sound/items/deconstruct.ogg', 40, TRUE)
		qdel(existing)
		return ITEM_INTERACT_SUCCESS
	if(!isfloorturf(target) && !(locate(/obj/structure/lattice) in target))
		to_chat(user, span_warning("Ore pipes can only be laid on a floor or a lattice."))
		return ITEM_INTERACT_BLOCKING
	var/new_dir = outlet_mode ? user.dir : SOUTH
	if(!network_allows(target, outlet_mode, new_dir))
		to_chat(user, span_warning("Network already has an outlet."))
		return ITEM_INTERACT_BLOCKING
	if(!do_after(user, 0.5 SECONDS, target))
		return ITEM_INTERACT_BLOCKING
	if((locate(/obj/structure/ore_pipe) in target) || !network_allows(target, outlet_mode, new_dir))
		return ITEM_INTERACT_BLOCKING
	var/obj/structure/ore_pipe/laid
	if(outlet_mode)
		laid = new /obj/structure/ore_pipe/outlet(target)
		laid.setDir(new_dir)
		laid.update_connections(TRUE)
	else
		laid = new /obj/structure/ore_pipe(target)
	laid.add_fingerprint(user)
	playsound(target, 'sound/machines/click.ogg', 40, TRUE)
	return ITEM_INTERACT_SUCCESS

/// Whether a new piece on `target` would leave every joined network with at most one outlet.
/obj/item/ore_pipe_layer/proc/network_allows(turf/target, outlet, new_dir)
	var/list/outlets = list()
	for(var/direction in GLOB.cardinal)
		if(outlet && direction == new_dir)
			continue
		for(var/obj/structure/ore_pipe/neighbour in get_step(target, direction))
			if(!neighbour.connects_to(REVERSE_DIR(direction)))
				continue
			outlets |= neighbour.find_outlets()
	return length(outlets) + (outlet ? 1 : 0) <= 1

/datum/design/ore_pipe_layer
	name = "Ore Pipe Layer"
	desc = "A tool that lays and removes ore pipes for stationary mining drills."
	id = "ore_pipe_layer"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_ENGINEERING = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 2000)
	build_path = /obj/item/ore_pipe_layer
	category = list(PROTOLATHE_CATEGORY_MINING)
