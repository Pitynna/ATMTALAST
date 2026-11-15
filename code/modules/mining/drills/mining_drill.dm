#define DRILL_STATUS_ACTIVE "Active"
#define DRILL_STATUS_OFF "Off"
#define DRILL_STATUS_NO_POWER "No power"
#define DRILL_STATUS_BUFFER_FULL "Buffer full"
#define DRILL_STATUS_NO_DEPOSIT "No ore deposit"
#define DRILL_STATUS_DEPLETED "Deposit depleted"

/// Charge drawn from the cell per minute of active drilling, the same for every tier.
#define DRILL_CHARGE_PER_MINUTE 1000
/// Time to deploy or pack up a drill.
#define DRILL_DEPLOY_TIME (5 SECONDS)

/**
 * # Stationary mining drill
 *
 * Stands on an ore deposit and extracts its ore into an internal buffer.
 * Runs only on a power cell. Stats come from the tier, not from the parts:
 * a drill accepts only stock parts of its own tier (`part_rating`).
 *
 * The same machine is carried around folded inside [/obj/item/mining_drill_packed],
 * so the cell, module, parts and buffered ore stay with it.
 */
/obj/machinery/mining_drill
	name = "mining drill"
	desc = "A compact stationary drill. Set it on an exposed ore deposit and it will slowly mine the whole seam."
	icon = 'icons/obj/mining_drills.dmi'
	icon_state = "drill1"
	base_icon_state = "drill1"
	density = TRUE
	anchored = TRUE
	dir = SOUTH
	max_integrity = 300
	integrity_failure = 0
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 10, BOMB = 20, BIO = 0, FIRE = 60, ACID = 60)
	// Destruction by fire or acid would delete the drill without leaving its frame and parts.
	resistance_flags = FIRE_PROOF | ACID_PROOF
	use_power = NO_POWER_USE
	interaction_flags_click = ALLOW_SILICON_REACH
	/// Shown in interfaces and on the packed item.
	var/tier = 1
	/// Stock part rating this drill is built from. Parts of any other rating are refused.
	var/part_rating = 1
	/// Time to extract one unit of ore.
	var/dig_time = 30 SECONDS
	/// Ore units the buffer holds.
	var/buffer_capacity = 50
	/// The circuit board type of this drill.
	var/board_type = /obj/item/circuitboard/mining_drill
	/// Packed form we fold into.
	var/packed_type = /obj/item/mining_drill_packed
	/// Whether the operator switched us on.
	var/on = FALSE
	/// The installed power cell.
	var/obj/item/stock_parts/cell/cell
	/// The installed output module. Added by later stages; empty for now.
	var/obj/item/mining_drill_module/module
	/// The deposit we stand on and drill.
	var/datum/ore_deposit/deposit
	/// Set when our deposit ran dry while we were on it.
	var/deposit_depleted = FALSE
	/// Buffered ore: ore type = units.
	var/list/buffer = list()
	/// Time accumulated towards the next unit of ore.
	var/dig_progress = 0
	/// Status of the last processing tick, for icons and the interface.
	var/status = DRILL_STATUS_OFF

/obj/machinery/mining_drill/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new board_type(null)
	var/obj/item/circuitboard/board = component_parts[1]
	for(var/part_type in board.req_components)
		var/part_path = get_tier_part(part_type)
		for(var/i in 1 to board.req_components[part_type])
			component_parts += new part_path(null)
	RefreshParts()
	find_deposit()
	update_status()

/obj/machinery/mining_drill/Destroy()
	release_deposit()
	QDEL_NULL(cell)
	QDEL_NULL(module)
	return ..()

/obj/machinery/mining_drill/get_cell()
	return cell

/// The concrete stock part of our tier for a generic part type from the board.
/obj/machinery/mining_drill/proc/get_tier_part(part_type)
	if(!ispath(part_type, /obj/item/stock_parts))
		return part_type
	for(var/obj/item/stock_parts/candidate as anything in typesof(part_type))
		if(initial(candidate.rating) == part_rating)
			return candidate
	return part_type

/obj/machinery/mining_drill/exchange_parts(mob/user, obj/item/storage/part_replacer/replacer)
	if(!istype(replacer))
		return FALSE
	to_chat(user, span_warning("[src] only works with parts of its own tier; its parts cannot be exchanged."))
	return TRUE

// MARK: Deposit

/// Links us to the free deposit under us, if there is one.
/obj/machinery/mining_drill/proc/find_deposit()
	if(deposit || !isturf(loc))
		return
	var/obj/effect/ore_deposit_tile/tile = locate() in loc
	if(!tile?.deposit || tile.is_covered())
		return
	var/obj/machinery/mining_drill/other = tile.deposit.get_drill()
	if(other && other != src)
		return
	deposit = tile.deposit
	deposit.drill_ref = WEAKREF(src)
	deposit_depleted = FALSE
	RegisterSignal(deposit, COMSIG_QDELETING, PROC_REF(on_deposit_deleted))

/obj/machinery/mining_drill/proc/release_deposit()
	if(!deposit)
		return
	UnregisterSignal(deposit, COMSIG_QDELETING)
	if(deposit.get_drill() == src)
		deposit.drill_ref = null
	deposit = null

/obj/machinery/mining_drill/proc/on_deposit_deleted(datum/source)
	SIGNAL_HANDLER
	deposit = null
	deposit_depleted = TRUE
	on = FALSE
	update_status()

/obj/machinery/mining_drill/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	release_deposit()
	deposit_depleted = FALSE
	find_deposit()
	update_status()

// MARK: Drilling

/obj/machinery/mining_drill/proc/buffer_total()
	. = 0
	for(var/ore_type in buffer)
		. += buffer[ore_type]

/obj/machinery/mining_drill/proc/get_status()
	if(!isturf(loc))
		return DRILL_STATUS_OFF
	if(!deposit)
		return deposit_depleted ? DRILL_STATUS_DEPLETED : DRILL_STATUS_NO_DEPOSIT
	if(!on)
		return DRILL_STATUS_OFF
	if(!cell || cell.charge <= 0)
		return DRILL_STATUS_NO_POWER
	if(buffer_total() >= buffer_capacity)
		return DRILL_STATUS_BUFFER_FULL
	return DRILL_STATUS_ACTIVE

/obj/machinery/mining_drill/proc/update_status()
	var/new_status = get_status()
	if(new_status == status)
		return
	status = new_status
	update_icon()
	SStgui.update_uis(src)

/obj/machinery/mining_drill/process(seconds_per_tick)
	if(!isturf(loc))
		return
	module?.process_output(src)
	update_status()
	if(status != DRILL_STATUS_ACTIVE)
		return
	if(!cell.use(DRILL_CHARGE_PER_MINUTE * seconds_per_tick / 60))
		cell.charge = 0
		update_status()
		return
	dig_progress += seconds_per_tick SECONDS
	while(dig_progress >= dig_time && status == DRILL_STATUS_ACTIVE)
		dig_progress -= dig_time
		dig_one()
		update_status()
	module?.process_output(src)
	update_status()

/// Moves one unit of ore from the deposit into the buffer.
/obj/machinery/mining_drill/proc/dig_one()
	var/ore_type = deposit.ore_type
	if(!deposit.extract(1))
		return
	buffer[ore_type] += 1
	if(is_mining_level(z))
		SSticker?.score?.score_ore_mined++
	SSblackbox.record_feedback("tally", "ore_drilled", 1, ore_type)

/// Takes up to `amount` ore units of `ore_type` out of the buffer. Returns how many were taken.
/obj/machinery/mining_drill/proc/take_from_buffer(ore_type, amount)
	. = min(amount, buffer[ore_type])
	if(. <= 0)
		return 0
	buffer[ore_type] -= .
	if(buffer[ore_type] <= 0)
		buffer -= ore_type
	update_status()

/// Drops the whole buffer onto `target` as ore stacks.
/obj/machinery/mining_drill/proc/dump_buffer(atom/target)
	for(var/obj/item/stack/ore/ore_type as anything in buffer.Copy())
		var/amount = take_from_buffer(ore_type, buffer[ore_type])
		var/max_stack = initial(ore_type.max_amount)
		while(amount > 0)
			var/stack_amount = min(amount, max_stack)
			new ore_type(target, stack_amount)
			amount -= stack_amount

// MARK: Interaction

/obj/machinery/mining_drill/examine(mob/user)
	. = ..()
	. += span_notice("Status: <b>[status]</b>.")
	if(deposit)
		. += span_notice("It is mining \a [deposit.name].")
	. += span_notice("The maintenance panel is [panel_open ? "open" : "closed"].")
	if(panel_open)
		. += span_notice("The power cell is [cell ? "installed" : "missing"]; use a screwdriver to close the panel.")
	. += span_notice("Use a wrench to pack it up for carrying. Damage can be repaired with a welding tool.")

/obj/machinery/mining_drill/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)
	return TRUE

/obj/machinery/mining_drill/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/mining_drill/attackby(obj/item/item, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(iscell(item))
		add_fingerprint(user)
		if(!panel_open)
			to_chat(user, span_warning("Open the maintenance panel first."))
			return ATTACK_CHAIN_PROCEED
		if(cell)
			to_chat(user, span_warning("[src] already has a power cell."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(item, src))
			return ATTACK_CHAIN_PROCEED
		cell = item
		user.visible_message(span_notice("[user] inserts [item] into [src]."), span_notice("You insert [item] into [src]."))
		update_status()
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL
	if(istype(item, /obj/item/mining_drill_module))
		add_fingerprint(user)
		if(!panel_open)
			to_chat(user, span_warning("Open the maintenance panel first."))
			return ATTACK_CHAIN_PROCEED
		if(module)
			to_chat(user, span_warning("[src] already has a module."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(item, src))
			return ATTACK_CHAIN_PROCEED
		module = item
		module.on_install(src)
		user.visible_message(span_notice("[user] installs [item] into [src]."), span_notice("You install [item] into [src]."))
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/machinery/mining_drill/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(!tool.use_tool(src, user, 0, volume = tool.tool_volume))
		return
	panel_open = !panel_open
	to_chat(user, span_notice("You [panel_open ? "open" : "close"] the maintenance panel of [src]."))
	update_icon()
	SStgui.update_uis(src)

/obj/machinery/mining_drill/crowbar_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return FALSE
	. = TRUE
	default_deconstruction_crowbar(user, tool)

/obj/machinery/mining_drill/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	pack_up(user, tool)

/obj/machinery/mining_drill/welder_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(obj_integrity >= max_integrity)
		to_chat(user, span_notice("[src] is not damaged."))
		return
	if(!tool.tool_use_check(user, 1))
		return
	user.visible_message(span_notice("[user] starts repairing [src]."), span_notice("You start repairing [src]."))
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 1, volume = tool.tool_volume))
		return
	update_integrity(max_integrity)
	to_chat(user, span_notice("You repair [src]."))

/// Folds the drill into its packed item. Everything inside stays inside.
/obj/machinery/mining_drill/proc/pack_up(mob/living/user, obj/item/tool)
	if(!isturf(loc))
		return FALSE
	to_chat(user, span_notice("You start packing up [src]..."))
	if(tool)
		if(!tool.use_tool(src, user, DRILL_DEPLOY_TIME, volume = tool.tool_volume))
			return FALSE
	else if(!do_after(user, DRILL_DEPLOY_TIME, src))
		return FALSE
	if(!isturf(loc))
		return FALSE
	on = FALSE
	var/obj/item/mining_drill_packed/packed = new packed_type(loc, src)
	user.visible_message(span_notice("[user] packs up [src]."), span_notice("You pack up [src]."))
	user.put_in_hands(packed)
	return TRUE

/obj/machinery/mining_drill/on_deconstruction()
	var/atom/drop_location = drop_location()
	cell?.forceMove(drop_location)
	cell = null
	if(module)
		module.on_uninstall(src)
		module.forceMove(drop_location)
		module = null
	dump_buffer(drop_location)

// MARK: Icon

/obj/machinery/mining_drill/update_icon_state()
	icon_state = "[base_icon_state][status == DRILL_STATUS_ACTIVE ? "_on" : ""]"

/obj/machinery/mining_drill/update_overlays()
	. = ..()
	if(panel_open)
		. += "[base_icon_state]_panel"

// MARK: Interface

/obj/machinery/mining_drill/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MiningDrill", name)
		ui.open()

/obj/machinery/mining_drill/ui_data(mob/user)
	var/list/data = list()
	data["tier"] = tier
	data["status"] = status
	data["on"] = on
	data["has_deposit"] = !!deposit
	data["deposit_name"] = deposit?.name
	data["deposit_amount"] = deposit?.amount
	data["deposit_initial"] = deposit?.initial_amount
	data["has_cell"] = !!cell
	data["cell_charge"] = cell ? round(cell.charge) : 0
	data["cell_max"] = cell ? cell.maxcharge : 0
	data["charge_per_minute"] = DRILL_CHARGE_PER_MINUTE
	data["dig_time"] = dig_time / (1 SECONDS)
	data["buffer_total"] = buffer_total()
	data["buffer_capacity"] = buffer_capacity
	var/list/buffer_contents = list()
	for(var/obj/item/stack/ore/ore_type as anything in buffer)
		buffer_contents += list(list("name" = initial(ore_type.name), "amount" = buffer[ore_type]))
	data["buffer"] = buffer_contents
	data["panel_open"] = panel_open
	data["module"] = module?.name
	data["module_data"] = module?.get_ui_data(src)
	return data

/obj/machinery/mining_drill/ui_act(action, list/params)
	if(..())
		return
	var/mob/living/user = usr
	switch(action)
		if("toggle")
			if(!on && !deposit)
				to_chat(user, span_warning("[src] is not standing on an ore deposit."))
				return FALSE
			on = !on
			update_status()
			return TRUE
		if("dump")
			if(!buffer_total())
				return FALSE
			dump_buffer(drop_location())
			to_chat(user, span_notice("You unload the ore from [src]."))
			return TRUE
		if("pack")
			if(!istype(user) || !Adjacent(user))
				return FALSE
			INVOKE_ASYNC(src, PROC_REF(pack_up), user)
			return TRUE
	if(module)
		return module.ui_act_module(action, params, src, user)

/**
 * # Packed mining drill
 *
 * The carried form of [/obj/machinery/mining_drill]. Holds the machine itself.
 * Too large for any bag, but carried in the hands without slowing down.
 * Use it on an exposed ore deposit tile to set the drill up.
 */
/obj/item/mining_drill_packed
	name = "packed mining drill"
	desc = "A folded stationary mining drill. Use it on an exposed ore deposit to set it up."
	icon = 'icons/obj/mining_drills.dmi'
	icon_state = "drill1_packed"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_GIGANTIC
	slowdown = 0
	resistance_flags = FIRE_PROOF | ACID_PROOF
	/// Machine built when the item is created on its own, e.g. by a protolathe.
	var/drill_type = /obj/machinery/mining_drill
	/// The folded machine.
	var/obj/machinery/mining_drill/drill

/obj/item/mining_drill_packed/Initialize(mapload, obj/machinery/mining_drill/packed_drill)
	. = ..()
	if(packed_drill)
		drill = packed_drill
		drill.forceMove(src)
	else
		drill = new drill_type(src)
	name = "packed [drill.name]"
	drill.update_status()

/obj/item/mining_drill_packed/Destroy()
	QDEL_NULL(drill)
	return ..()

/obj/item/mining_drill_packed/examine(mob/user)
	. = ..()
	if(!drill)
		return
	. += span_notice("Power cell: [drill.cell ? "[round(drill.cell.percent())]%" : "none"]. Module: [drill.module ? drill.module.name : "none"].")
	if(drill.buffer_total())
		. += span_notice("It holds [drill.buffer_total()] units of ore.")

/obj/item/mining_drill_packed/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/turf/target = get_turf(interacting_with)
	if(!target || !user.Adjacent(target))
		return NONE
	var/obj/effect/ore_deposit_tile/tile = locate() in target
	if(!tile?.deposit || tile.is_covered())
		to_chat(user, span_warning("[src] must be set up on an exposed ore deposit."))
		return ITEM_INTERACT_BLOCKING
	if(tile.deposit.get_drill())
		to_chat(user, span_warning("Another drill is already working this deposit."))
		return ITEM_INTERACT_BLOCKING
	if(target.is_blocked_turf(exclude_mobs = TRUE))
		to_chat(user, span_warning("There is no room to set up [src] there."))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You start setting up [src]..."))
	if(!do_after(user, DRILL_DEPLOY_TIME, target))
		return ITEM_INTERACT_BLOCKING
	if(QDELETED(tile) || !tile.deposit || tile.deposit.get_drill() || target.is_blocked_turf(exclude_mobs = TRUE))
		to_chat(user, span_warning("You can no longer set up [src] there."))
		return ITEM_INTERACT_BLOCKING
	var/obj/machinery/mining_drill/deployed = drill
	drill = null
	deployed.setDir(user.dir)
	deployed.forceMove(target)
	deployed.add_fingerprint(user)
	user.visible_message(span_notice("[user] sets up [deployed]."), span_notice("You set up [deployed] on [tile.deposit.name]."))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/**
 * # Mining drill output module
 *
 * Base for the modules that take ore out of a drill's buffer (ejector, bluespace transmitter).
 */
/obj/item/mining_drill_module
	name = "mining drill module"
	desc = "An output module for a stationary mining drill."
	icon = 'icons/obj/mining_drills.dmi'
	icon_state = "module"
	w_class = WEIGHT_CLASS_SMALL
	abstract_type = /obj/item/mining_drill_module

/obj/item/mining_drill_module/proc/on_install(obj/machinery/mining_drill/drill)
	return

/obj/item/mining_drill_module/proc/on_uninstall(obj/machinery/mining_drill/drill)
	return

/// Called every processing tick of the drill; moves ore out of its buffer.
/obj/item/mining_drill_module/proc/process_output(obj/machinery/mining_drill/drill)
	return

/obj/item/mining_drill_module/proc/get_ui_data(obj/machinery/mining_drill/drill)
	return null

/obj/item/mining_drill_module/proc/ui_act_module(action, list/params, obj/machinery/mining_drill/drill, mob/user)
	return FALSE

/obj/item/circuitboard/mining_drill
	board_name = "Mining Drill"
	build_path = /obj/machinery/mining_drill
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	origin_tech = "materials=1;engineering=1"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/matter_bin = 1,
	)

#undef DRILL_STATUS_ACTIVE
#undef DRILL_STATUS_OFF
#undef DRILL_STATUS_NO_POWER
#undef DRILL_STATUS_BUFFER_FULL
#undef DRILL_STATUS_NO_DEPOSIT
#undef DRILL_STATUS_DEPLETED
#undef DRILL_CHARGE_PER_MINUTE
#undef DRILL_DEPLOY_TIME
