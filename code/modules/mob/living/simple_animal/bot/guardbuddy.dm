/obj/item/guardbuddy_board
	name = "Guardbuddy control board"
	desc = "The control circuitry for a PR-6 Guardbuddy."
	icon = 'icons/obj/guardbuddy/parts.dmi'
	icon_state = "robuddy_core-6"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/guardbuddy_chassis
	name = "Guardbuddy chassis"
	desc = "A PR-6 shell with slots for a control board, a power cell and a cyborg arm."
	icon = 'icons/obj/guardbuddy/pr-6.dmi'
	icon_state = "frame-1"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_BULKY
	var/obj/item/guardbuddy_board/board
	var/obj/item/stock_parts/cell/cell
	var/obj/item/robot_parts/arm
	var/unit_name = "Guardbuddy"

/obj/item/guardbuddy_chassis/update_icon_state()
	if(arm)
		icon_state = "body"
	else if(cell)
		icon_state = "frame-3"
	else if(board)
		icon_state = "frame-2"
	else
		icon_state = "frame-1"

/obj/item/guardbuddy_chassis/examine(mob/user)
	. = ..()
	. += span_notice("Name: [unit_name]. Use a pen to change it.")
	if(arm)
		. += span_notice("Use a screwdriver on the chassis on the floor to finish assembly.")
	else
		. += span_notice("Next part: [cell ? "left or right cyborg arm" : board ? "power cell" : "Guardbuddy control board"].")
	if(board)
		. += span_notice("Use a crowbar to remove the last installed part.")

/obj/item/guardbuddy_chassis/attackby(obj/item/part, mob/user, params)
	if(istype(part, /obj/item/pen))
		var/new_name = tgui_input_text(user, "Enter a name for the robot.", "Guardbuddy", unit_name, MAX_NAME_LEN)
		if(new_name && !QDELETED(src) && user.Adjacent(src) && !user.incapacitated())
			unit_name = new_name
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(part, /obj/item/guardbuddy_board))
		if(!board && user.drop_transfer_item_to_loc(part, src))
			board = part
	else if(istype(part, /obj/item/stock_parts/cell))
		if(board && !cell && user.drop_transfer_item_to_loc(part, src))
			cell = part
	else if(istype(part, /obj/item/robot_parts/l_arm) || istype(part, /obj/item/robot_parts/r_arm))
		if(cell && !arm && user.drop_transfer_item_to_loc(part, src))
			arm = part
	else
		return ..()

	if(part.loc == src)
		to_chat(user, span_notice("You install [part] in [src]."))
		update_icon()
	else
		to_chat(user, span_warning("The chassis is unready for that part. Examine it to see the next step."))
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/item/guardbuddy_chassis/crowbar_act(mob/living/user, obj/item/tool)
	var/obj/item/part = arm ? arm : cell ? cell : board
	if(!part)
		return FALSE
	if(!tool.use_tool(src, user, volume = tool.tool_volume))
		return TRUE
	part.forceMove(get_turf(src))
	user.put_in_hands(part)
	to_chat(user, span_notice("You remove [part] from [src]."))
	return TRUE

/obj/item/guardbuddy_chassis/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == arm)
		arm = null
	if(gone == cell)
		cell = null
	if(gone == board)
		board = null
	update_icon()

/obj/item/guardbuddy_chassis/screwdriver_act(mob/living/user, obj/item/tool)
	if(!board || !cell || !arm || !isturf(loc))
		to_chat(user, span_warning("Set a fully fitted chassis on the floor first."))
		return TRUE
	if(!tool.use_tool(src, user, volume = tool.tool_volume))
		return TRUE
	var/mob/living/simple_animal/bot/guardbuddy/bot = new(loc, src)
	user.visible_message(span_notice("[user] finishes assembling [bot]."), span_notice("You finish assembling [bot]."))
	return TRUE

/obj/item/guardbuddy_module
	name = "Guardbuddy tool module"
	desc = "A replaceable tool for a Guardbuddy's manipulator."
	icon = 'icons/obj/guardbuddy/parts.dmi'
	icon_state = "tool_generic"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/guardbuddy_module/lamp
	name = "Guardbuddy lamp"
	desc = "A lamp that lights the way for a working Guardbuddy."
	icon_state = "pdamod_light"

/obj/item/guardbuddy_module/announcer
	name = "Guardbuddy annunciator"
	desc = "A radio module that lets an escorted crewmember call for help."
	icon_state = "pdamod_alert"

/obj/machinery/bot_core/guardbuddy
	req_access = list(ACCESS_ROBOTICS)

/mob/living/simple_animal/bot/guardbuddy
	name = "Guardbuddy"
	desc = "A PR-6 station companion with a replaceable tool and a rechargeable power cell."
	icon = 'icons/obj/guardbuddy/pr-6.dmi'
	icon_state = "body"
	model = "PR-6"
	bot_type = "Guardbuddy PR-6"
	bot_core_type = /obj/machinery/bot_core/guardbuddy
	bot_purpose = "assist the station crew"
	window_name = "Guardbuddy"
	radio_config = list(AI_FREQ_NAME = 1, PUB_FREQ_NAME = 1, SEC_FREQ_NAME = 1)
	base_speed = 4
	allow_pai = FALSE
	on = FALSE
	light_on = FALSE
	light_range = 4
	light_power = 1
	light_color = COLOR_WHITE
	var/obj/item/guardbuddy_chassis/chassis
	var/obj/item/stock_parts/cell/cell
	var/obj/item/guardbuddy_module/tool_module
	var/obj/machinery/guardbuddy_dock/home_dock
	var/program = "standby"
	var/datum/weakref/assignment_target
	var/stop_reason = "Waiting for assignment."
	var/obj/machinery/navbeacon/current_beacon
	var/turf/navigation_target
	var/navigation_pending = FALSE
	/// Invalidates path callbacks when a newer command supersedes a route.
	var/navigation_revision = 0
	var/failed_routes = 0
	COOLDOWN_DECLARE(help_call)
	COOLDOWN_DECLARE(tool_cycle)
	var/tool_service_revision = 0

/mob/living/simple_animal/bot/guardbuddy/Initialize(mapload, obj/item/guardbuddy_chassis/new_chassis)
	. = ..()
	access_card.access |= ACCESS_RESEARCH
	prev_access = access_card.access.Copy()
	chassis = new_chassis
	if(chassis)
		name = chassis.unit_name
		bot_name = name
		cell = chassis.cell
		chassis.forceMove(src)
		cell?.forceMove(src)
	update_icon()

/mob/living/simple_animal/bot/guardbuddy/Destroy()
	monitor_ward(null)
	if(home_dock)
		home_dock.unbind()
	var/turf/drop_turf = get_turf(src)
	if(drop_turf)
		tool_module?.forceMove(drop_turf)
		cell?.forceMove(drop_turf)
		chassis?.forceMove(drop_turf)
	tool_module = null
	cell = null
	chassis = null
	return ..()

/mob/living/simple_animal/bot/guardbuddy/turn_on()
	if(open || !cell || cell.charge < 1)
		return FALSE
	. = ..()
	if(.)
		update_lamp()

/mob/living/simple_animal/bot/guardbuddy/turn_off()
	tool_service_revision++
	monitor_ward(null)
	return ..()

/mob/living/simple_animal/bot/guardbuddy/proc/update_lamp()
	set_light_on(on && istype(tool_module, /obj/item/guardbuddy_module/lamp))

/mob/living/simple_animal/bot/guardbuddy/update_icon_state()
	icon_state = "body"

/mob/living/simple_animal/bot/guardbuddy/update_overlays()
	. = ..()
	if(on)
		. += mutable_appearance(icon, cell?.percent() <= 20 ? "face-battery" : "face-neutral")
		. += mutable_appearance(icon, "lights-on")

/mob/living/simple_animal/bot/guardbuddy/handle_automated_action()
	if(on && (!cell || cell.charge < 1))
		stop_reason = "Battery depleted. Return the unit by hand or replace its cell."
		turn_off()
		return FALSE
	if(on)
		if(cell.percent() <= 20 && mode != BOT_GO_HOME)
			if(!recall("Low battery."))
				stop_mission("Low battery. Home dock unavailable.")
				return FALSE
		var/draw = istype(tool_module, /obj/item/guardbuddy_module/lamp) ? 2 : 1
		cell.use(min(draw, cell.charge))
	if(!..() || !on || client)
		return FALSE
	var/obj/item/guardbuddy_module/weapon/weapon_mount = tool_module
	if(istype(weapon_mount) && mode != BOT_GO_HOME && cell.percent() > 20)
		weapon_mount.fabricate(src)
	if(mode == BOT_GO_HOME)
		if(!home_dock || !home_dock.is_operational() || home_dock.z != z)
			stop_mission("Home dock is unavailable.")
		else if(home_dock.on_pad(src))
			turn_off()
		else if(home_dock.pad_blocked(src))
			if(++failed_routes >= 3)
				stop_mission("The charging pad is occupied.")
		else
			navigate_to(get_turf(home_dock), "Could not reach the home dock.")
	else if(program == "patrol")
		var/mob/living/threat = scan_threats()
		if(threat)
			record_threat(threat)
		patrol_beacons()
	else if(program == "escort")
		escort()
	else if(is_security_assignment())
		guard_assignment()
	return TRUE

/mob/living/simple_animal/bot/guardbuddy/proc/set_assignment(new_program, mob/living/carbon/human/target, turf/post)
	program = new_program
	assignment_target = target ? WEAKREF(target) : null
	guard_post = post
	guard_area = post ? get_area(post) : null
	stop_mission("Ready for dispatch.")

/mob/living/simple_animal/bot/guardbuddy/proc/dispatch()
	if(!home_dock?.on_pad(src) || !home_dock.is_operational() || !cell || cell.percent() <= 20 || open)
		return FALSE
	if(program in list("escort", "bodyguard") && !get_escort_target())
		return FALSE
	bot_reset()
	if(!turn_on())
		return FALSE
	stop_reason = program == "standby" ? "Waiting for assignment." : null
	if(program == "bodyguard")
		monitor_ward(get_escort_target())
	return TRUE

/mob/living/simple_animal/bot/guardbuddy/proc/get_escort_target()
	var/mob/living/carbon/human/target = assignment_target?.resolve()
	if(target && target.stat != DEAD && isturf(target.loc) && target.z == z)
		return target
	return null

/mob/living/simple_animal/bot/guardbuddy/proc/escort()
	var/mob/living/carbon/human/target = get_escort_target()
	if(!target)
		stop_mission("Escort lost contact with its crewmember.")
		return
	mode = BOT_MOVING
	if(Adjacent(target))
		if(length(path) || navigation_pending)
			set_path(null)
			navigation_pending = FALSE
			navigation_revision++
		navigation_target = null
		failed_routes = 0
		tries = 0
		return
	navigate_to(get_turf(target), "Could not reach the escorted crewmember.", 1)

/mob/living/simple_animal/bot/guardbuddy/proc/can_contact_escort(mob/user)
	return on && program == "escort" && mode != BOT_GO_HOME && get_escort_target() == user && Adjacent(user) && !user.incapacitated()

/mob/living/simple_animal/bot/guardbuddy/proc/request_help(mob/user)
	if(!istype(tool_module, /obj/item/guardbuddy_module/announcer) || !can_contact_escort(user))
		return FALSE
	if(!COOLDOWN_FINISHED(src, help_call))
		to_chat(user, span_warning("The annunciator is waiting to send another call."))
		return FALSE
	if(!cell?.use(5))
		to_chat(user, span_warning("The annunciator needs more battery charge."))
		return FALSE
	COOLDOWN_START(src, help_call, 30 SECONDS)
	speak("[user] requests assistance in [get_area_name(user)].", radio_channel)
	to_chat(user, span_notice("[src] broadcasts your location on the common channel."))
	return TRUE

/mob/living/simple_animal/bot/guardbuddy/proc/recall(reason)
	if(!home_dock || home_dock.z != z)
		return FALSE
	if(home_dock.on_pad(src))
		stop_reason = reason
		turn_off()
		return TRUE
	if(!home_dock.is_operational() || !turn_on())
		return FALSE
	bot_reset()
	monitor_ward(null)
	mode = BOT_GO_HOME
	stop_reason = reason
	return TRUE

/mob/living/simple_animal/bot/guardbuddy/proc/stop_mission(reason)
	stop_reason = reason
	turn_off()

/mob/living/simple_animal/bot/guardbuddy/bot_reset()
	. = ..()
	current_beacon = null
	navigation_target = null
	navigation_pending = FALSE
	navigation_revision++
	failed_routes = 0
	incident_attacker = null
	incident_until = 0

/mob/living/simple_animal/bot/guardbuddy/proc/patrol_beacons()
	var/list/beacons = GLOB.navbeacons["[z]"]
	if(current_beacon && (!(current_beacon in beacons) || QDELETED(current_beacon)))
		stop_mission("The patrol beacon is missing.")
		return
	if(!current_beacon)
		var/closest_distance = INFINITY
		for(var/obj/machinery/navbeacon/beacon in beacons)
			var/distance = get_dist(src, beacon)
			if(!beacon.codes["next_patrol"] || distance >= closest_distance)
				continue
			current_beacon = beacon
			closest_distance = distance
		if(!current_beacon)
			stop_mission("No patrol beacons found.")
			return

	mode = BOT_PATROL
	if(loc == current_beacon.loc)
		var/next_beacon = current_beacon.codes["next_patrol"]
		current_beacon = null
		for(var/obj/machinery/navbeacon/beacon in beacons)
			if(beacon.location == next_beacon)
				current_beacon = beacon
				break
		if(!current_beacon)
			stop_mission("The next patrol beacon is missing.")
			return
	navigate_to(get_turf(current_beacon), "Could not reach the patrol beacon.")

/mob/living/simple_animal/bot/guardbuddy/proc/navigate_to(turf/target, failure_reason, minimum_distance = 0)
	if(!target || target.z != z)
		stop_mission(failure_reason)
		return
	if(navigation_pending)
		return
	if(target != navigation_target)
		navigation_target = target
		failed_routes = 0
		tries = 0
		set_path(null)
	else if(length(path) && bot_move(path[length(path)]))
		return
	if(++failed_routes > 3)
		stop_mission(failure_reason)
		return
	navigation_pending = TRUE
	tries = 0
	var/revision = ++navigation_revision
	var/list/result = get_path_to(src, target, max_distance = 150, mintargetdist = minimum_distance, access = prev_access, diagonal_handling = DIAGONAL_REMOVE_ALL)
	if(QDELETED(src) || revision != navigation_revision)
		return
	set_path(result)
	navigation_pending = FALSE
	if(length(path))
		bot_move(path[length(path)])

/mob/living/simple_animal/bot/guardbuddy/bot_step()
	if(!on)
		return FALSE
	if(program == "escort" && mode == BOT_MOVING)
		var/mob/living/carbon/human/target = get_escort_target()
		if(!target || Adjacent(target))
			return FALSE
	return ..()

/mob/living/simple_animal/bot/guardbuddy/get_mode()
	if(mode == BOT_GO_HOME)
		return "Returning to dock"
	if(home_dock?.on_pad(src) && !on)
		return "Docked"
	if(on && mode == BOT_MOVING && program == "escort")
		return "Escorting"
	return ..()

/mob/living/simple_animal/bot/guardbuddy/call_bot(requester, turf/waypoint, message = TRUE)
	if(remote_disabled || !waypoint || waypoint.z != z || !cell || cell.percent() <= 20 || open || mode == BOT_GO_HOME)
		if(message)
			to_chat(requester, span_warning("[src] is unavailable for a waypoint call."))
		return FALSE
	if(calling_ai && calling_ai != requester)
		return FALSE
	// The stock call grants temporary AI access. Reserve the command while its path is calculated.
	bot_reset()
	mode = BOT_RESPONDING
	calling_ai = requester
	ai_waypoint = waypoint
	navigation_pending = TRUE
	var/revision = navigation_revision
	if(!all_access)
		all_access = new /obj/item/card/id
		all_access.access = get_all_accesses()
	var/list/result = get_path_to(src, waypoint, max_distance = 200, access = all_access.GetAccess())
	if(QDELETED(src) || navigation_revision != revision)
		return FALSE
	navigation_pending = FALSE
	if(!length(result) || remote_disabled || !turn_on())
		calling_ai = null
		bot_reset()
		if(message)
			to_chat(requester, span_warning("[src] could not reach that waypoint."))
		return FALSE
	access_card.access = all_access.GetAccess()
	set_path(result)
	if(message)
		to_chat(requester, span_notice("[src] is heading to [get_area_name(waypoint)]."))
	return TRUE

/mob/living/simple_animal/bot/guardbuddy/call_mode()
	if(navigation_pending)
		return
	if(loc == ai_waypoint)
		to_chat(calling_ai, span_notice("[src] has arrived at the waypoint."))
		calling_ai = null
		bot_reset()
		return
	return ..()

/mob/living/simple_animal/bot/guardbuddy/proc/pda_call(turf/target, list/user_access, mob/user)
	if(remote_disabled || emagged == 2 || !target || target.z != z || !cell || cell.percent() <= 20 || open || mode == BOT_GO_HOME || mode == BOT_RESPONDING || !turn_on())
		return FALSE
	if(loc == target)
		bot_reset()
		return TRUE
	var/datum/signal/command = new()
	command.data = list("command" = "summon", "active" = src, "target" = target, "useraccess" = user_access, "user" = user)
	receive_signal(command)
	qdel(command)
	return TRUE

/mob/living/simple_animal/bot/guardbuddy/calc_summon_path(turf/avoid)
	if(navigation_pending)
		return
	var/revision = ++navigation_revision
	navigation_pending = TRUE
	var/list/route = get_path_to(src, summon_target, max_distance = 150, access = access_card.GetAccess(), exclude = avoid, diagonal_handling = DIAGONAL_REMOVE_ALL)
	if(QDELETED(src) || revision != navigation_revision)
		return
	navigation_pending = FALSE
	if(!length(route))
		bot_reset()
		stop_reason = "Could not reach the PDA caller."
		return
	set_path(route)

/mob/living/simple_animal/bot/guardbuddy/bot_summon()
	if(navigation_pending)
		return
	if(loc == summon_target)
		bot_reset()
		return
	if(!bot_move(summon_target))
		if(++failed_routes > 3)
			bot_reset()
			stop_reason = "Could not reach the PDA caller."
		else
			tries = 0
			calc_summon_path()

/mob/living/simple_animal/bot/guardbuddy/examine(mob/user)
	. = ..()
	. += span_notice("Cell: [cell ? "[round(cell.percent())]%" : "missing"]. Tool: [tool_module ? tool_module.name : "empty"].")
	if(!locked)
		. += span_notice("Open the service panel with a screwdriver while the unit is off. Use a crowbar to remove fitted parts.")

/mob/living/simple_animal/bot/guardbuddy/proc/can_service(mob/user)
	return open && !on && !locked && bot_core.allowed(user) && user.Adjacent(src) && !user.incapacitated()

/mob/living/simple_animal/bot/guardbuddy/proc/can_use_module(mob/user)
	return on && tool_module?.use_range && !locked && bot_core.allowed(user) && user.Adjacent(src) && !user.incapacitated() && (!tool_module.security_tool || (ACCESS_SECURITY in user.get_access()))

/mob/living/simple_animal/bot/guardbuddy/proc/use_module(atom/target)
	var/obj/item/guardbuddy_module/module = tool_module
	if(!module || !on || mode == BOT_GO_HOME || !module.use_range || QDELETED(target) || target == src || !COOLDOWN_FINISHED(src, tool_cycle))
		return FALSE
	module.tool_error = null
	if(!(target in view(module.use_range, src)) || !module.can_apply(src, target))
		return FALSE
	if(!cell || cell.charge < module.battery_cost)
		module.tool_error = "Insufficient battery charge."
		return FALSE
	if(!module.apply(src, target))
		return FALSE
	cell.use(module.battery_cost)
	COOLDOWN_START(src, tool_cycle, module.use_delay)
	return TRUE

/mob/living/simple_animal/bot/guardbuddy/can_use_guns(obj/item/gun/gun)
	var/obj/item/guardbuddy_module/weapon/mount = tool_module
	if(istype(mount) && mount.weapon == gun)
		return !HAS_TRAIT(src, TRAIT_HANDS_BLOCKED)
	return ..()

/mob/living/simple_animal/bot/guardbuddy/proc/manual_tool_use(mob/user)
	if(!can_use_module(user))
		return
	var/obj/item/guardbuddy_module/module = tool_module
	var/revision = tool_service_revision
	var/list/targets = list()
	for(var/mob/living/target in view(module.use_range, src))
		if(target != src && target.stat != DEAD)
			targets += target
	var/mob/living/selected = tgui_input_list(user, "Choose a visible target within tool range.", module.name, targets)
	if(!selected || QDELETED(src) || tool_service_revision != revision || tool_module != module || !can_use_module(user))
		return
	if(!use_module(selected))
		to_chat(user, span_warning(module.tool_error ? module.tool_error : "The tool cannot apply right now."))
	else if(module.security_tool || istype(module, /obj/item/guardbuddy_module/reagent))
		add_attack_logs(user, selected, "Used [module.name] via [src]")

/mob/living/simple_animal/bot/guardbuddy/screwdriver_act(mob/living/user, obj/item/tool)
	if(user.a_intent == INTENT_HARM)
		return FALSE
	if(on || !bot_core.allowed(user))
		to_chat(user, span_warning("You need robotics access and the unit must be switched off."))
		return TRUE
	return ..()

/mob/living/simple_animal/bot/guardbuddy/attackby(obj/item/part, mob/user, params)
	if(user.a_intent == INTENT_HARM && part.force > 0)
		observe_attack(src, user)
	var/obj/item/guardbuddy_module/reagent/reagent_module = tool_module
	if(user.a_intent != INTENT_HARM && istype(reagent_module) && istype(part, /obj/item/reagent_containers/cup/beaker))
		if(home_dock?.on_pad(src) && can_service(user))
			reagent_module.insert_beaker(part, user)
		else
			to_chat(user, span_warning("Open the service panel on the charging pad before fitting a beaker."))
		return ATTACK_CHAIN_BLOCKED_ALL
	if(user.a_intent == INTENT_HARM || (!istype(part, /obj/item/guardbuddy_module) && !istype(part, /obj/item/stock_parts/cell)))
		return ..()
	if(!can_service(user))
		to_chat(user, span_warning("Unlock and open the service panel before installing a part."))
		return ATTACK_CHAIN_BLOCKED_ALL
	if(istype(part, /obj/item/guardbuddy_module))
		if(!tool_module && user.drop_transfer_item_to_loc(part, src))
			tool_module = part
	else if(!cell && user.drop_transfer_item_to_loc(part, src))
		cell = part
	if(part.loc == src)
		to_chat(user, span_notice("You install [part] in [src]."))
		update_controls()
	else
		to_chat(user, span_warning("Remove the installed part first."))
	return ATTACK_CHAIN_BLOCKED_ALL

/mob/living/simple_animal/bot/guardbuddy/attack_hand(mob/living/carbon/human/user)
	if(user.a_intent == INTENT_HARM)
		observe_attack(src, user)
	return ..()

/mob/living/simple_animal/bot/guardbuddy/bullet_act(obj/projectile/shot)
	if(shot.damage > 0 && shot.damage_type != STAMINA && isliving(shot.firer))
		observe_attack(src, shot.firer)
	return ..()

/mob/living/simple_animal/bot/guardbuddy/crowbar_act(mob/living/user, obj/item/tool)
	if(user.a_intent == INTENT_HARM)
		return FALSE
	if(!can_service(user))
		to_chat(user, span_warning("Unlock and open the service panel before removing a part."))
		return TRUE
	if(!tool.use_tool(src, user, volume = tool.tool_volume))
		return TRUE
	if(tool_module)
		user.put_in_hands(remove_tool())
	else if(cell)
		var/obj/item/stock_parts/cell/old_cell = cell
		cell = null
		old_cell.forceMove(get_turf(src))
		user.put_in_hands(old_cell)
	else if(chassis)
		chassis.forceMove(get_turf(src))
		chassis = null
		qdel(src)
		return TRUE
	update_controls()
	return TRUE

/mob/living/simple_animal/bot/guardbuddy/proc/remove_tool()
	var/obj/item/guardbuddy_module/old_tool = tool_module
	tool_module = null
	old_tool?.forceMove(get_turf(src))
	update_lamp()
	return old_tool

/mob/living/simple_animal/bot/guardbuddy/get_controls(mob/user)
	var/dat = "<b>[name]</b><br>"
	dat += "Power: [on ? "On" : "Off"]<br>"
	dat += "Cell: [cell ? "[round(cell.percent())]%" : "Missing"]<br>"
	dat += "Tool: [tool_module ? tool_module.name : "Empty"]<br>"
	var/obj/item/guardbuddy_module/reagent/reagent_module = tool_module
	if(istype(reagent_module))
		dat += "[reagent_module.mixture_description()]<br>"
		if(reagent_module.beaker && home_dock?.on_pad(src) && can_service(user))
			dat += "<a href='byond://?src=[UID()];guardbuddy=eject_beaker'>Eject beaker</a><br>"
	if(can_use_module(user))
		dat += "<a href='byond://?src=[UID()];guardbuddy=apply'>Use module</a><br>"
	if(can_contact_escort(user))
		if(istype(tool_module, /obj/item/guardbuddy_module/announcer))
			dat += "<a href='byond://?src=[UID()];guardbuddy=help'>Call for help</a><br>"
		dat += "<a href='byond://?src=[UID()];guardbuddy=cancel'>End escort</a><br>"
	if(!topic_denied(user) && bot_core.allowed(user))
		dat += "<a href='byond://?src=[UID()];power=1'>Toggle power</a><br>"
		dat += hack(user)
	return dat

/mob/living/simple_animal/bot/guardbuddy/Topic(href, list/href_list)
	if(href_list["guardbuddy"])
		switch(href_list["guardbuddy"])
			if("apply")
				manual_tool_use(usr)
			if("eject_beaker")
				var/obj/item/guardbuddy_module/reagent/reagent_module = tool_module
				if(istype(reagent_module) && home_dock?.on_pad(src) && can_service(usr))
					reagent_module.eject_beaker(usr)
			if("help")
				request_help(usr)
			if("cancel")
				if(can_contact_escort(usr))
					set_assignment("standby", null)
					stop_reason = "Escort ended by [usr]."
		update_controls()
		return TRUE
	if(!href_list["close"] && !bot_core.allowed(usr))
		return TRUE
	return ..()
