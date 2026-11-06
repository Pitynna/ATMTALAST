/// Reconstructed from ATMTA's surviving noose sprites and sounds.
/obj/structure/gallows
	name = "gallows"
	desc = "A wooden frame with a cable noose. Drag someone onto it, then use harm intent to pull the lever. Wirecutters can cut the noose."
	icon = 'icons/obj/atmta_gallows.dmi'
	icon_state = "noose"
	pixel_y = 16
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 0
	buckle_prevents_pull = TRUE
	max_integrity = 150
	resistance_flags = FLAMMABLE
	var/hanging = FALSE
	var/lever_busy = FALSE

/obj/structure/gallows/Destroy()
	STOP_PROCESSING(SSobj, src)
	unbuckle_all_mobs(force = TRUE)
	return ..()

/obj/structure/gallows/is_user_buckle_possible(mob/living/target, mob/user, check_loc = TRUE)
	if(!anchored || !ishuman(target) || hanging)
		return FALSE
	var/mob/living/carbon/human/human = target
	if(!human.get_organ(BODY_ZONE_HEAD))
		return FALSE
	return ..(target, user, FALSE)

/obj/structure/gallows/post_buckle_mob(mob/living/target)
	add_overlay("noose_overlay")

/obj/structure/gallows/post_unbuckle_mob(mob/living/target)
	hanging = FALSE
	STOP_PROCESSING(SSobj, src)
	target.remove_offsets(UID())
	cut_overlays()

/obj/structure/gallows/attack_hand(mob/living/user)
	if(!has_buckled_mobs() || lever_busy)
		return
	var/mob/living/victim = buckled_mobs[1]
	if(user.a_intent != INTENT_HARM)
		return user_unbuckle_mob(victim, user)
	if(hanging)
		return
	lever_busy = TRUE
	user.visible_message(span_warning("[user] reaches for the lever of [src]!"), span_warning("You reach for the lever."))
	if(do_after(user, 3 SECONDS, src) && victim.buckled == src && !hanging)
		start_hanging(user)
	lever_busy = FALSE

/obj/structure/gallows/proc/start_hanging(mob/living/user)
	if(hanging || !anchored || !has_buckled_mobs())
		return FALSE
	var/mob/living/victim = buckled_mobs[1]
	hanging = TRUE
	victim.add_offsets(UID(), y_add = 4)
	playsound(src, 'sound/effects/atmta_noosed.ogg', 50, TRUE)
	add_attack_logs(user, victim, "Pulled the gallows lever")
	victim.visible_message(span_danger("The noose tightens around [victim]'s neck!"), span_userdanger("The noose tightens around your neck!"))
	START_PROCESSING(SSobj, src)
	return TRUE

/obj/structure/gallows/process()
	if(!hanging || !has_buckled_mobs())
		return PROCESS_KILL
	var/mob/living/carbon/human/victim = buckled_mobs[1]
	if(!victim.get_organ(BODY_ZONE_HEAD))
		unbuckle_all_mobs(force = TRUE)
		return PROCESS_KILL
	if(victim.stat == DEAD)
		return PROCESS_KILL
	victim.adjustOxyLoss(5)
	victim.AdjustLoseBreath(2 SECONDS)
	if(prob(10))
		playsound(src, 'sound/effects/atmta_noose_idle.ogg', 25, TRUE)

/obj/structure/gallows/user_unbuckle_mob(mob/living/target, mob/living/user)
	if(target != user || !hanging)
		return ..()
	to_chat(user, span_warning("You struggle to loosen the noose..."))
	if(do_after(user, 20 SECONDS, src) && target.buckled == src)
		return ..()

/obj/structure/gallows/wirecutter_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(!tool.use_tool(src, user, 2 SECONDS, volume = tool.tool_volume))
		return
	unbuckle_all_mobs(force = TRUE)
	new /obj/item/stack/sheet/wood(drop_location(), 10)
	qdel(src)

/obj/structure/gallows/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(has_buckled_mobs())
		to_chat(user, span_warning("Free the occupant first."))
		return
	if(tool.use_tool(src, user, 2 SECONDS, volume = tool.tool_volume) && !has_buckled_mobs())
		set_anchored(!anchored)

/datum/crafting_recipe/atmta_gallows
	name = "Gallows"
	result = /obj/structure/gallows
	reqs = list(/obj/item/stack/sheet/wood = 10, /obj/item/stack/cable_coil = 5)
	tools = list(TOOL_SCREWDRIVER)
	time = 5 SECONDS
	category = CAT_MISC
