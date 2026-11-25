/obj/machinery/guardbuddy_dock
	name = "Guardbuddy dock"
	desc = "A floor pad that charges and dispatches a paired Guardbuddy. Pull a bot onto the pad to pair it."
	icon = 'icons/obj/guardbuddy/charger.dmi'
	icon_state = "base"
	layer = LOW_OBJ_LAYER
	anchored = TRUE
	density = FALSE
	idle_power_usage = 5
	active_power_usage = 300
	interact_offline = TRUE
	req_access = list(ACCESS_ROBOTICS)
	var/mob/living/simple_animal/bot/guardbuddy/assigned

/obj/machinery/guardbuddy_dock/Destroy()
	if(assigned?.mode == BOT_GO_HOME)
		assigned.stop_mission("Home dock was removed.")
	unbind()
	return ..()

/obj/machinery/guardbuddy_dock/proc/on_pad(mob/living/simple_animal/bot/guardbuddy/bot)
	return bot && bot.loc == loc

/obj/machinery/guardbuddy_dock/proc/pad_blocked(mob/living/simple_animal/bot/guardbuddy/bot)
	for(var/mob/living/simple_animal/bot/guardbuddy/other in loc)
		if(other != bot)
			return TRUE
	return FALSE

/obj/machinery/guardbuddy_dock/proc/connected()
	var/turf/bot_turf = get_turf(assigned)
	return bot_turf && !assigned.remote_disabled && is_valid_z_level(get_turf(src), bot_turf)

/obj/machinery/guardbuddy_dock/proc/bind(mob/living/simple_animal/bot/guardbuddy/bot)
	if(assigned || !on_pad(bot) || pad_blocked(bot) || bot.home_dock)
		return FALSE
	assigned = bot
	bot.home_dock = src
	bot.stop_mission("Paired to home dock.")
	update_icon()
	return TRUE

/obj/machinery/guardbuddy_dock/proc/unbind()
	if(!assigned)
		return
	assigned.home_dock = null
	assigned = null
	update_icon()

/obj/machinery/guardbuddy_dock/process()
	var/charging = is_operational() && on_pad(assigned) && !assigned.on && assigned.cell && assigned.cell.charge < assigned.cell.maxcharge
	if(charging)
		assigned.cell.give(30)
	update_use_power(charging ? ACTIVE_POWER_USE : IDLE_POWER_USE)
	update_icon()

/obj/machinery/guardbuddy_dock/update_overlays()
	. = ..()
	if(is_operational() && on_pad(assigned) && !assigned.on)
		if(assigned.cell && assigned.cell.charge < assigned.cell.maxcharge)
			. += "charging"
		else
			. += "upload"

/obj/machinery/guardbuddy_dock/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)
	return TRUE

/obj/machinery/guardbuddy_dock/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GuardbuddyDock", "Guardbuddy Dock")
		ui.open()

/obj/machinery/guardbuddy_dock/ui_data(mob/user)
	var/docked = on_pad(assigned)
	var/has_link = connected()
	var/list/user_access = user.get_access()
	var/list/candidates = list()
	var/list/zones = list()
	if(docked && (allowed(user) || (ACCESS_SECURITY in user_access)))
		for(var/mob/living/carbon/human/person in view(3, src))
			if(person.stat != DEAD && isturf(person.loc))
				candidates += list(list("value" = person.UID(), "displayText" = person.name))
		if(ACCESS_SECURITY in user_access)
			var/list/seen_zones = list()
			for(var/obj/machinery/navbeacon/beacon in GLOB.navbeacons["[z]"])
				var/area/zone = get_area(beacon)
				if(zone in seen_zones)
					continue
				seen_zones += zone
				zones += list(list("value" = beacon.UID(), "displayText" = get_area_name(beacon)))
	var/mob/living/carbon/human/target = assigned?.get_escort_target()
	var/obj/item/guardbuddy_module/reagent/reagent_module = assigned?.tool_module
	return list(
		"powered" = is_operational(),
		"authorized" = allowed(user),
		"assigned" = !!assigned,
		"docked" = docked,
		"connected" = has_link,
		"blocked" = pad_blocked(assigned),
		"name" = assigned?.name,
		"program" = docked || has_link ? assigned.program : null,
		"charge" = docked || has_link ? (assigned.cell ? round(assigned.cell.percent()) : 0) : null,
		"cell" = (docked || has_link) && !!assigned.cell,
		"tool" = docked || has_link ? assigned.tool_module?.name : null,
		"zone" = docked || has_link ? get_area_name(assigned) : null,
		"mode" = docked || has_link ? dock_status() : null,
		"reason" = docked || has_link ? assigned.stop_reason : null,
		"target" = docked || has_link ? target?.name : null,
		"candidates" = candidates,
		"zones" = zones,
		"security" = (ACCESS_SECURITY in user_access),
		"command" = (ACCESS_HOS in user_access),
		"order_zone" = (docked || has_link) && assigned.guard_post ? get_area_name(assigned.guard_post) : null,
		"last_threat" = docked || has_link ? assigned.last_threat : null,
		"threat_age" = (docked || has_link) && assigned.last_threat ? round((world.time - assigned.last_threat_time) / (1 SECONDS)) : null,
		"mixture" = (docked || has_link) && istype(reagent_module) ? reagent_module.mixture_description() : null,
		"tool_error" = docked || has_link ? assigned.tool_module?.tool_error : null,
	)

/obj/machinery/guardbuddy_dock/proc/dock_status()
	if(assigned.mode == BOT_GO_HOME)
		return "Returning to dock"
	if(on_pad(assigned) && !assigned.on)
		return "Docked"
	if(!assigned.on)
		return "Powered down"
	switch(assigned.mode)
		if(BOT_PATROL)
			return "On patrol"
		if(BOT_RESPONDING)
			return "Responding to AI waypoint"
		if(BOT_SUMMON)
			return "Responding to PDA"
		if(BOT_MOVING)
			return assigned.is_security_assignment() ? "Moving to security assignment" : "Escorting"
		if(BOT_HUNT)
			return "Responding to a threat"
		if(BOT_ARREST)
			return "Restraint in progress"
	return "Standing by"

/obj/machinery/guardbuddy_dock/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	if(!user.Adjacent(src) || user.incapacitated() || !is_operational())
		return FALSE
	if(!assigned)
		if(action != "pair" || !allowed(user))
			return FALSE
		var/mob/living/simple_animal/bot/guardbuddy/bot = locate(/mob/living/simple_animal/bot/guardbuddy) in loc
		if(!bind(bot))
			to_chat(user, span_warning("Bring one unpaired Guardbuddy onto the pad."))
		return TRUE

	if(action == "recall" && (allowed(user) || can_order(user, assigned.program)) && (on_pad(assigned) || connected()))
		if(!assigned.recall("Recalled by [user]."))
			to_chat(user, span_warning("The bot cannot return under its own power."))
		return TRUE

	if(!on_pad(assigned))
		return FALSE
	if(pad_blocked(assigned))
		return FALSE
	switch(action)
		if("program")
			var/selection = params["program"]
			return select_assignment(user, selection, params["target"])
		if("dispatch")
			if(!can_order(user, assigned.program))
				return FALSE
			if(!assigned.dispatch())
				to_chat(user, span_warning("Close the service panel, check the assignment and charge the cell above 20% before dispatch."))
		if("unpair")
			if(!allowed(user))
				return FALSE
			assigned.stop_mission("Home dock unpaired.")
			unbind()
		else
			return FALSE
	return TRUE

/obj/machinery/guardbuddy_dock/proc/can_order(mob/user, selection)
	switch(selection)
		if("purge")
			return ACCESS_HOS in user.get_access()
		if("secure", "areaguard", "bodyguard")
			return ACCESS_SECURITY in user.get_access()
		if("standby", "patrol", "escort")
			return allowed(user)
	return FALSE

/obj/machinery/guardbuddy_dock/proc/select_assignment(mob/user, selection, target_uid)
	if(!istext(selection) || !can_order(user, selection))
		return FALSE
	var/mob/living/carbon/human/target
	var/turf/post
	switch(selection)
		if("escort", "bodyguard")
			target = locateUID(target_uid)
			if(!istype(target) || target.stat == DEAD || !isturf(target.loc) || !(target in view(3, src)))
				to_chat(user, span_warning("Select a nearby crewmember."))
				return TRUE
		if("secure")
			post = get_turf(user)
		if("areaguard", "purge")
			var/obj/machinery/navbeacon/beacon = locateUID(target_uid)
			if(!istype(beacon) || !(beacon in GLOB.navbeacons["[z]"]))
				to_chat(user, span_warning("Select a station area with a patrol beacon."))
				return TRUE
			post = get_turf(beacon)
	assigned.set_assignment(selection, target, post)
	return TRUE
