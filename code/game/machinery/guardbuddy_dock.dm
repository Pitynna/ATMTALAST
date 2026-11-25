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
	return assigned && !assigned.remote_disabled && is_valid_z_level(get_turf(src), get_turf(assigned))

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
	return "Standing by"

/obj/machinery/guardbuddy_dock/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	if(!user.Adjacent(src) || !allowed(user) || user.incapacitated() || !is_operational())
		return FALSE
	if(!assigned)
		if(action != "pair")
			return FALSE
		var/mob/living/simple_animal/bot/guardbuddy/bot = locate(/mob/living/simple_animal/bot/guardbuddy) in loc
		if(!bind(bot))
			to_chat(user, span_warning("Bring one unpaired Guardbuddy onto the pad."))
		return TRUE

	if(action == "recall" && (on_pad(assigned) || connected()))
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
			if(!(selection in list("standby", "patrol")))
				return FALSE
			assigned.program = selection
			assigned.stop_mission("Ready for dispatch.")
		if("dispatch")
			if(!assigned.dispatch())
				to_chat(user, span_warning("Close the service panel and charge the cell above 20% before dispatch."))
		if("unpair")
			assigned.stop_mission("Home dock unpaired.")
			unbind()
		else
			return FALSE
	return TRUE
