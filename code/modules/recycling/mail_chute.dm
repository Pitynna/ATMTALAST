/// A Goonstation mail terminal using Paradise's existing numeric disposal tags.
/obj/machinery/disposal/mail
	name = "pneumatic mail chute"
	desc = "Sends items through the disposal pipes to a selected department. Use a destination tagger to label this terminal's receiving address. Sorting junctions must be configured for the destination."
	icon = 'icons/goonstation/objects/mail_chute.dmi'
	icon_state = "mailchute"
	base_icon_state = "mailchute"
	can_contain_mobs = FALSE
	/// Department selected for outgoing mail. Zero means no destination selected.
	var/destination_tag = NONE
	/// Optional receiving label, set with an ordinary destination tagger.
	var/delivery_tag = NONE
	var/deliveries_received = 0

/obj/machinery/disposal/mail/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/destTagger) && user.a_intent != INTENT_HARM)
		var/obj/item/destTagger/tagger = item
		delivery_tag = tagger.currTag
		update_appearance(UPDATE_NAME)
		add_fingerprint(user)
		to_chat(user, span_notice("Receiving address set to [GLOB.TAGGERLOCATIONS[delivery_tag]]. Configure the pipe junction to use the same address."))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

/obj/machinery/disposal/mail/update_name(updates = ALL)
	. = ..()
	name = delivery_tag ? "mail chute ([GLOB.TAGGERLOCATIONS[delivery_tag]])" : initial(name)

/obj/machinery/disposal/mail/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PneumaticMail", name)
		ui.open()

/obj/machinery/disposal/mail/ui_data(mob/user)
	. = ..()
	.["destination"] = destination_tag
	.["address"] = delivery_tag ? GLOB.TAGGERLOCATIONS[delivery_tag] : "Unlabelled"
	.["connected"] = !QDELETED(trunk)
	.["busy"] = flushing
	.["item_count"] = length(contents)
	.["received"] = deliveries_received
	.["panel_open"] = mode == -1
	var/list/destinations = list()
	for(var/index in 1 to length(GLOB.TAGGERLOCATIONS))
		destinations += list(list("id" = index, "name" = GLOB.TAGGERLOCATIONS[index]))
	.["destinations"] = destinations

/obj/machinery/disposal/mail/ui_act(action, params)
	if(action == "destination")
		// The parent checks access, the maintenance state, damage and an active flush.
		if(!..())
			return
		return select_destination(text2num(params["id"]))
	return ..()

/obj/machinery/disposal/mail/proc/select_destination(value)
	if(!isnum(value) || value != round(value) || value < 1 || value > length(GLOB.TAGGERLOCATIONS) || flushing)
		return FALSE
	destination_tag = value
	return TRUE

/obj/machinery/disposal/mail/flush()
	if(!destination_tag || QDELETED(trunk) || flushing || mode <= 0 || (stat & BROKEN))
		return
	return ..()

/obj/machinery/disposal/mail/configure_holder(obj/structure/disposalholder/holder)
	holder.destinationTag = destination_tag
	holder.tomail = TRUE

/obj/machinery/disposal/mail/expel(obj/structure/disposalholder/holder)
	if(length(holder.contents))
		deliveries_received++
		audible_message(span_notice("[src] chimes: Mail delivery!"))
		playsound(src, 'sound/machines/twobeep.ogg', 40, FALSE)
	// Received mail lands beside the terminal and cannot be automatically re-sent.
	holder.active = FALSE
	pipe_eject(holder, NONE, FALSE)
	holder.vent_gas(loc)
	qdel(holder)
	update()

/obj/machinery/disposal/mail/update_icon_state()
	icon_state = initial(icon_state)

/obj/machinery/disposal/mail/update_overlays()
	. = list()
	underlays.Cut()
	if(flush)
		. += "mail-fhandle"
	if((stat & (NOPOWER|BROKEN)) || mode == -1)
		return
	if(length(contents))
		. += "disposal-full"
	switch(mode)
		if(1)
			. += "disposal-charge"
		if(2)
			. += "disposal-ready"
