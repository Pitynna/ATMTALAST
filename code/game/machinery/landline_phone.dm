// Landline phones, an idea from Goonstation 13. Sprites and sounds are CC BY-NC-SA 3.0 (docs/GOON_ASSETS.md),
// built by tools/goon_ports/extras.py; the code is our own.
//
// Pick up the handset to get the directory and dial another phone. The other phone rings until someone picks up.
// While connected, whatever the person holding a handset says is heard by whoever holds the other handset.
// Put the handset back on the phone (or walk too far away with it) to hang up.

#define PHONE_CORD_RANGE 2
#define PHONE_RING_TIMEOUT (30 SECONDS)

GLOBAL_LIST_EMPTY(landline_phones)

/obj/machinery/landline_phone
	name = "phone"
	desc = "A landline phone. In space. Where there is no land."
	icon = 'icons/obj/goon_phones.dmi'
	icon_state = "phone"
	anchored = TRUE
	density = FALSE
	max_integrity = 60
	idle_power_usage = 5
	processing_flags = NONE
	/// "phone" for desk phones, "wallphone" for wall-mounted ones.
	var/base_state = "phone"
	/// Name in the directory. Defaults to the area name.
	var/phone_id
	/// Colour of the department stripe. Picked from the area if not set.
	var/stripe_color
	var/obj/item/phone_handset/handset
	/// The phone we are calling or talking to.
	var/obj/machinery/landline_phone/linked
	/// We are being called and nobody has picked up yet.
	var/ringing = FALSE
	/// We called someone and they haven't picked up yet.
	var/calling = FALSE
	/// Someone cut the line with wirecutters.
	var/line_cut = FALSE
	/// Hidden from the directory, but can still dial out.
	var/unlisted = FALSE
	/// When the current unanswered call gives up.
	var/ring_until = 0

/obj/machinery/landline_phone/wall
	icon_state = "wallphone"
	base_state = "wallphone"

/obj/machinery/landline_phone/Initialize(mapload)
	. = ..()
	handset = new(src)
	handset.parent = src
	if(isnull(stripe_color))
		stripe_color = area_stripe_color(get_area(src))
	if(!phone_id)
		var/area/our_area = get_area(src)
		phone_id = our_area ? our_area.name : "phone"
		var/count = 1
		for(var/obj/machinery/landline_phone/other as anything in GLOB.landline_phones)
			if(other.phone_id == phone_id || findtext(other.phone_id, "[phone_id] #") == 1)
				count++
		if(count > 1)
			phone_id = "[phone_id] #[count]"
	GLOB.landline_phones += src
	handset.update_appearance()
	update_appearance()

/obj/machinery/landline_phone/Destroy()
	hang_up(silent = TRUE)
	GLOB.landline_phones -= src
	QDEL_NULL(handset)
	return ..()

/obj/machinery/landline_phone/proc/area_stripe_color(area/our_area)
	if(istype(our_area, /area/station/security))
		return "#ff3030"
	if(istype(our_area, /area/station/command))
		return "#3fd43f"
	if(istype(our_area, /area/station/engineering))
		return "#ffd800"
	if(istype(our_area, /area/station/science))
		return "#9a4cff"
	if(istype(our_area, /area/station/medical))
		return "#4a8cff"
	if(istype(our_area, /area/station/cargo))
		return "#c8862b"
	return "#b65f08"

/obj/machinery/landline_phone/examine(mob/user)
	. = ..()
	. += span_notice("A small label on it reads \"[phone_id]\".")
	if(line_cut)
		. += span_warning("The phone line has been cut.")
	if(ringing)
		. += span_notice("It's ringing!")

/obj/machinery/landline_phone/update_icon_state()
	if(ringing)
		icon_state = "[base_state]_ringing"
	else if(handset && handset.loc != src)
		icon_state = "[base_state]_answered"
	else
		icon_state = base_state

/obj/machinery/landline_phone/update_overlays()
	. = ..()
	var/mutable_appearance/stripe = mutable_appearance(icon, "[icon_state]-stripe")
	stripe.color = stripe_color
	stripe.appearance_flags = RESET_COLOR
	. += stripe
	if(icon_state == base_state)
		. += mutable_appearance(icon, "[base_state]_dial")

/obj/machinery/landline_phone/proc/can_work()
	return !line_cut && !(stat & (NOPOWER|BROKEN))

/// The handset is out of its cradle.
/obj/machinery/landline_phone/proc/off_hook()
	return handset && handset.loc != src

/obj/machinery/landline_phone/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !handset || off_hook())
		return
	if(!user.put_in_hands(handset))
		return TRUE
	playsound(src, 'sound/goonstation/phones/pick_up.ogg', 50, FALSE)
	begin_processing()
	update_appearance()
	if(ringing)
		answer()
		return TRUE
	dial(user)
	return TRUE

/obj/machinery/landline_phone/proc/dial(mob/living/user)
	if(!can_work())
		to_chat(user, span_warning("There's no dial tone."))
		return
	var/list/directory = list()
	for(var/obj/machinery/landline_phone/other as anything in GLOB.landline_phones)
		if(other == src || other.unlisted || !is_station_level(other.z) && other.z != z)
			continue
		directory[other.phone_id] = other
	if(!length(directory))
		to_chat(user, span_warning("The directory is empty."))
		return
	var/picked = tgui_input_list(user, "Who do you want to call?", "Phone directory", sort_list(directory))
	var/obj/machinery/landline_phone/target = directory[picked]
	if(!target || QDELETED(target) || !off_hook() || handset.loc != user || linked)
		return
	playsound(src, 'sound/goonstation/phones/dial.ogg', 40, FALSE)
	if(!target.can_work() || target.off_hook() || target.linked)
		to_chat(user, span_notice("The line is busy."))
		user.playsound_local(get_turf(user), 'sound/goonstation/phones/phone_busy.ogg', 50, FALSE)
		return
	linked = target
	calling = TRUE
	target.linked = src
	target.ringing = TRUE
	target.ring_until = world.time + PHONE_RING_TIMEOUT
	target.begin_processing()
	target.update_appearance()
	target.ring()
	to_chat(user, span_notice("You dial [target.phone_id]. It's ringing..."))

/obj/machinery/landline_phone/proc/ring()
	playsound(src, 'sound/goonstation/phones/ring_incoming.ogg', 50, FALSE)
	visible_message(span_notice("[src] rings!"), vision_distance = 3)
	if(linked?.handset)
		var/mob/caller_holder = linked.handset.loc
		if(ismob(caller_holder))
			caller_holder.playsound_local(get_turf(caller_holder), 'sound/goonstation/phones/ring_outgoing.ogg', 40, FALSE)

/// Someone picked up our ringing phone.
/obj/machinery/landline_phone/proc/answer()
	ringing = FALSE
	update_appearance()
	if(!linked)
		return
	linked.calling = FALSE
	var/mob/caller_holder = linked.handset?.loc
	if(ismob(caller_holder))
		caller_holder.playsound_local(get_turf(caller_holder), 'sound/goonstation/phones/remote_answer.ogg', 50, FALSE)
		to_chat(caller_holder, span_notice("Someone picks up at [phone_id]."))
	var/mob/our_holder = handset.loc
	if(ismob(our_holder))
		to_chat(our_holder, span_notice("You're talking to [linked.phone_id]."))

/// Ends the call on both ends. Puts our handset back if it's out.
/obj/machinery/landline_phone/proc/hang_up(silent = FALSE)
	if(linked)
		var/obj/machinery/landline_phone/other = linked
		linked = null
		other.linked = null
		other.calling = FALSE
		if(other.ringing)
			other.ringing = FALSE
			other.update_appearance()
		else if(other.off_hook())
			var/mob/other_holder = other.handset.loc
			if(ismob(other_holder))
				other_holder.playsound_local(get_turf(other_holder), 'sound/goonstation/phones/remote_hangup.ogg', 50, FALSE)
				to_chat(other_holder, span_notice("The line goes dead."))
		if(!other.off_hook())
			other.end_processing()
	ringing = FALSE
	calling = FALSE
	if(handset && handset.loc != src)
		if(ismob(handset.loc))
			var/mob/holder = handset.loc
			holder.temporarily_remove_item_from_inventory(handset, force = TRUE)
		handset.forceMove(src)
		if(!silent)
			playsound(src, 'sound/goonstation/phones/hang_up.ogg', 50, FALSE)
	end_processing()
	if(!QDELETED(src))
		update_appearance()

/obj/machinery/landline_phone/process()
	if(ringing)
		if(world.time > ring_until || !linked)
			hang_up(silent = TRUE)
			return
		ring()
		return
	if(!off_hook())
		end_processing()
		return
	if(get_dist(get_turf(handset), get_turf(src)) > PHONE_CORD_RANGE)
		var/mob/holder = handset.loc
		if(ismob(holder))
			to_chat(holder, span_warning("The cord yanks [handset] out of your hand and it snaps back onto [src]."))
		hang_up()

/obj/machinery/landline_phone/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool == handset)
		hang_up()
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/machinery/landline_phone/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	var/new_id = tgui_input_text(user, "What should this phone be listed as?", "Phone label", phone_id, 40)
	if(!new_id || QDELETED(src) || !Adjacent(user))
		return
	phone_id = new_id
	to_chat(user, span_notice("You relabel the phone as \"[phone_id]\"."))

/obj/machinery/landline_phone/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume))
		return
	line_cut = !line_cut
	to_chat(user, span_notice("You [line_cut ? "cut" : "splice back"] the phone line."))
	if(line_cut)
		hang_up(silent = TRUE)

/obj/machinery/landline_phone/power_change(forced = FALSE)
	. = ..()
	if(stat & NOPOWER)
		hang_up(silent = TRUE)

// MARK: Handset

/obj/item/phone_handset
	name = "phone handset"
	desc = "I wonder if the last person to use this washed their hands."
	icon = 'icons/obj/goon_phones.dmi'
	icon_state = "handset"
	w_class = WEIGHT_CLASS_NORMAL
	force = 2
	/// The phone this handset belongs to.
	var/obj/machinery/landline_phone/parent

/obj/item/phone_handset/Destroy()
	if(parent?.handset == src)
		parent.handset = null
	parent = null
	return ..()

/obj/item/phone_handset/update_overlays()
	. = ..()
	if(!parent)
		return
	var/mutable_appearance/stripe = mutable_appearance(icon, "handset-stripe")
	stripe.color = parent.stripe_color
	stripe.appearance_flags = RESET_COLOR
	. += stripe

/obj/item/phone_handset/examine(mob/user)
	. = ..()
	if(parent)
		. += span_notice("It's attached to the phone at [parent.phone_id].")

/obj/item/phone_handset/hear_talk(mob/speaker, list/message_pieces)
	. = ..()
	if(speaker != loc || !parent?.linked || parent.calling || parent.ringing || !parent.can_work())
		return
	var/obj/machinery/landline_phone/other = parent.linked
	var/mob/listener = other.handset?.loc
	if(!ismob(listener) || !listener.client)
		return
	var/heard = listener.combine_message(message_pieces, speaker)
	to_chat(listener, "[icon2html(other.handset, listener)] <b>[speaker.GetVoice()]</b> ([parent.phone_id]): [heard]")

/obj/item/phone_handset/dropped(mob/user, slot, silent)
	. = ..()
	// left lying around, it still counts as off the hook until the cord pulls it back
	if(parent && isturf(loc))
		parent.begin_processing()

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/landline_phone/wall, 28, 28)

#undef PHONE_CORD_RANGE
#undef PHONE_RING_TIMEOUT
