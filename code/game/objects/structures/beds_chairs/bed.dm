/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 *		Beds
 *		Roller stretchers
 *		Dog Beds
 */

/*
 * Beds
 */

/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	gender = FEMALE
	icon = 'icons/obj/objects.dmi'
	icon_state = "bed"
	can_buckle = TRUE
	anchored = TRUE
	buckle_lying = 90
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 30
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 2
	var/comfort = 2 // default comfort
	/// Directions in which the bed has its headrest on the left side.
	var/left_headrest_dirs = NORTHEAST
	/// Mobs standing on it are nudged up by this amount. Also used to align the person back when buckled to it after init.
	var/elevation = 6
	var/allow_tucking = TRUE

/obj/structure/bed/psych
	name = "psych bed"
	desc = "For prime comfort during psychiatric evaluations."
	icon_state = "psychbed"
	buildstackamount = 5

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from Earth. Could aliens be stealing our technology?"
	icon_state = "abed"
	comfort = 0.3

/obj/structure/bed/sandstone
	name = "sandstone plate"
	desc = "This is used to lie on, feels farm."
	icon_state = "bed_sand"
	resistance_flags = FIRE_PROOF
	max_integrity = 200
	buildstacktype = /obj/item/stack/sheet/mineral/sandstone
	buildstackamount = 15
	comfort = 0.5

/obj/structure/bed/old
	name = "old bed"
	desc = "This is a very old spring bed, it looks extremely UNCOMFORTABLE, you would not lie on it for anything in your life."
	icon_state = "catwalkcouch1"
	comfort = 0

/obj/structure/bed/wicker
	name = "wicker bed"
	desc = "A large bed woven from something resembling cloth. It looks comfortable enough."
	icon_state = "wicker_bed"
	comfort = 1.5
	buildstacktype = /obj/item/stack/sheet/cloth
	buildstackamount = 5

/obj/structure/bed/leather
	name = "leather bed"
	desc = "Pieces of leather crudely stitched together and fastened to a wooden frame. Not the most comfortable place to lie down."
	icon_state = "leather_bed"
	comfort = 1.2
	buildstacktype = /obj/item/stack/sheet/leather

/obj/structure/bed/wooden
	name = "wooden bed"
	desc = "A bed made from quality timber. It looks cozy and inviting."
	icon_state = "wooden_bed"
	comfort = 2.5
	buildstacktype = /obj/item/stack/sheet/wood
	buildstackamount = 5

/obj/structure/bed/cardboard
	name = "cardboard bed"
	desc = "A cardboard bed. Are you homeless?"
	icon_state = "cardboard_bed"
	comfort = 0.1
	buildstacktype = /obj/item/stack/sheet/cardboard

/obj/structure/bed/cardboard/wrench_act(mob/user, obj/item/wrench)
	return FALSE

/obj/structure/bed/cardboard/wirecutter_act(mob/user, obj/item/wirecutter)
	. = TRUE
	if(obj_flags & NODECONSTRUCT)
		balloon_alert(user, "нельзя разобрать!")
		return
	if(!wirecutter.use_tool(src, user, 0, volume = wirecutter.tool_volume))
		return
	deconstruct(TRUE)


/obj/structure/bed/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/soft_landing)
	if(elevation)
		AddElement(/datum/element/elevation, pixel_shift = elevation)
	update_buckle_vars(dir)

/obj/structure/bed/proc/handle_rotation()
	return

/obj/structure/bed/wrench_act(mob/user, obj/item/wrench)
	. = TRUE
	if(obj_flags & NODECONSTRUCT)
		balloon_alert(user, "нельзя разобрать!")
		return
	if(!wrench.use_tool(src, user, 0, volume = wrench.tool_volume))
		return
	deconstruct(TRUE)

/obj/structure/bed/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(buildstacktype)
			new buildstacktype(loc, buildstackamount)
	..()

/obj/structure/bed/setDir(newdir)
	. = ..()
	update_buckle_vars(newdir)

/obj/structure/bed/proc/update_buckle_vars(newdir)
	buckle_lying = newdir & left_headrest_dirs ? 270 : 90

/*
 * Roller stretcher
 */

/obj/structure/bed/roller
	name = "roller stretcher"
	desc = "Used to transport patients."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	resistance_flags = NONE
	anchored = FALSE
	comfort = 1
	pull_push_slowdown = 0	// used for transporting lying mobs
	allow_tucking = FALSE
	var/icon_up = "up"
	var/icon_down = "down"
	var/folded = /obj/item/roller

/obj/structure/bed/roller/wrench_act(mob/user, obj/item/wrench)
	return FALSE

/obj/structure/bed/roller/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(item, /obj/item/roller_holder))
		var/buckled_mobs = has_buckled_mobs()
		if(buckled_mobs)
			add_fingerprint(user)
			if(buckled_mobs > 1)
				unbuckle_all_mobs()
				user.visible_message(
					span_notice("[user] отстёгивает всех от [declent_ru(GENITIVE)]."),
					span_notice("Вы отстегнули всех от [declent_ru(GENITIVE)]."),
				)
			else
				user_unbuckle_mob(buckled_mobs[1], user)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		user.visible_message(
			span_notice("[user] сложил[GEND_A_O_I(user)] [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы сложили [declent_ru(ACCUSATIVE)]."),
		)
		var/obj/item/folded_item = new folded(drop_location())
		transfer_fingerprints_to(folded_item)
		folded_item.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/bed/roller/update_icon_state()
	icon_state = has_buckled_mobs() ? icon_up : icon_down

/obj/structure/bed/roller/post_buckle_mob(mob/living/target)
	set_density(TRUE)
	update_icon(UPDATE_ICON_STATE)
	target.add_offsets(UID(), y_add = 10)

/obj/structure/bed/roller/post_unbuckle_mob(mob/living/target)
	set_density(FALSE)
	update_icon(UPDATE_ICON_STATE)
	target.remove_offsets(UID())

/obj/structure/bed/roller/holo
	name = "holo stretcher"
	desc = "A retracted hardlight stretcher that can be carried around."
	icon_state = "holo_down"
	icon_up = "holo_up"
	icon_down = "holo_down"
	folded = /obj/item/roller/holo

/obj/item/roller
	name = "roller stretcher"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	interaction_flags_mouse_drop = NEED_DEXTERITY | NEED_HANDS
	/// Whether it can be picked up by roller holder
	var/collectable = TRUE
	var/extended = /obj/structure/bed/roller
	w_class = WEIGHT_CLASS_BULKY // Can't be put in backpacks.

/obj/item/roller/attack_self(mob/user)
	var/obj/structure/bed/roller/roller = new extended(drop_location())
	roller.add_fingerprint(user)
	user.visible_message(
			span_notice("[user] разложил[GEND_A_O_I(user)] [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы разложили [declent_ru(ACCUSATIVE)]."),
		)
	qdel(src)

/obj/item/roller/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(item, /obj/item/roller_holder))
		var/obj/item/roller_holder/roller = item
		if(roller.held)
			balloon_alert(user, "уже есть каталка!")
			return ATTACK_CHAIN_PROCEED
		if(!collectable)
			balloon_alert(user, "неверный тип каталки!")
			return ATTACK_CHAIN_PROCEED
		if(loc == user && !user.can_unEquip(src))
			return ..()
		user.visible_message(
			span_notice("[user] собрал[GEND_A_O_I(user)] [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы собрали [declent_ru(ACCUSATIVE)]."),
		)
		if(loc == user)
			user.transfer_item_to_loc(src, roller)
		else
			forceMove(roller)
		roller.held = src
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/bed/roller/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(has_buckled_mobs() || over_object != user || !ishuman(user))
		return

	user.visible_message(
		span_notice("[user] собрал[GEND_A_O_I(user)] [declent_ru(NOMINATIVE)]."),
		span_notice("Вы собрали [declent_ru(NOMINATIVE)]."),
	)
	var/obj/item/folded_item = new folded(drop_location())
	folded_item.add_fingerprint(user)
	qdel(src)

/obj/item/roller/holo
	name = "holo stretcher"
	desc = "A retracted hardlight stretcher that can be carried around."
	icon_state = "holo_retracted"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "magnets=3;biotech=4;powerstorage=3"
	extended = /obj/structure/bed/roller/holo
	collectable = FALSE

/obj/item/roller_holder
	name = "roller stretcher rack"
	desc = "A rack for carrying a collapsed roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	var/obj/item/roller/held = /obj/item/roller

/obj/item/roller_holder/Initialize(mapload)
	. = ..()
	if(ispath(held, /obj/item/roller))
		held = new held(src)

/obj/item/roller_holder/Destroy()
	QDEL_NULL(held)
	return ..()

/obj/item/roller_holder/attack_self(mob/user)
	if(!held)
		balloon_alert(user, "пуст!")
		return

	to_chat(user, span_notice("Вы разложили каталку."))
	var/obj/structure/bed/roller/roller = new held.extended(drop_location())
	roller.add_fingerprint(user)
	QDEL_NULL(held)

/*
 * Dog beds
 */

/obj/structure/bed/dogbed
	name = "dog bed"
	icon_state = "dogbed"
	desc = "A comfy-looking dog bed. You can even strap your pet in, just in case the gravity turns off."
	anchored = FALSE
	buildstackamount = 10
	buildstacktype = /obj/item/stack/sheet/wood
	comfort = 0.5
	elevation = 0

/obj/structure/bed/dogbed/ian
	name = "Ian's bed"
	desc = "Ian's bed! Looks comfy."
	anchored = TRUE

/obj/structure/bed/dogbed/renault
	name = "Renault's bed"
	desc = "Renault's bed! Looks comfy. A foxy person needs a foxy pet."
	anchored = TRUE

/obj/structure/bed/dogbed/runtime
	name = "Runtime's bed"
	desc = "A comfy-looking cat bed. You can even strap your pet in, in case the gravity turns off."
	anchored = TRUE

/obj/structure/bed/dogbed/pet
	name = "cozy pet bed"
	desc = "A comfortable bed for the department's favorite pet."
	anchored = TRUE
