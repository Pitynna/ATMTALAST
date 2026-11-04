/obj/item/wrench
	name = "wrench"
	desc = "A standard adjustable wrench made of forged steel. Can be used to fasten or remove bolts, and deconstruct objects."
	gender = MALE
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	belt_icon = "wrench"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	usesound = 'sound/items/ratchet.ogg'
	drop_sound = 'sound/items/handling/drop/wrench_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/wrench_pickup.ogg'
	materials = list(MAT_METAL=150)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("ударил", "огрел")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 30)
	tool_behaviour = TOOL_WRENCH
	toolbox_radial_menu_compatibility = TRUE

/obj/item/wrench/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = force, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)
	register_item_context()

/obj/item/wrench/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] избива[PLUR_ET_YUT(user)] себя до смерти [declent_ru(INSTRUMENTAL)]! Это похоже на попытку самоубийства!"))
	playsound(loc, 'sound/weapons/genhit.ogg', 50, TRUE, -1)
	return BRUTELOSS

/obj/item/wrench/brass
	name = "brass wrench"
	desc = "A brass adjustable wrench. It's faintly warm to the touch."
	icon_state = "wrench_brass"
	toolspeed = 0.5
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/wrench/abductor
	name = "alien wrench"
	desc = "A polarized wrench. It causes anything placed between the jaws to turn."
	icon = 'icons/obj/abductor.dmi'
	item_state = "wrench_alien"
	belt_icon = "alien_wrench"
	usesound = 'sound/effects/empulse.ogg'
	toolspeed = 0.1
	origin_tech = "materials=5;engineering=5;abductor=3"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/wrench/cyborg
	name = "automatic wrench"
	desc = "A powered industrial wrench commonly found in construction and engineering robots. More efficient than most manual wrenches."
	toolspeed = 0.5

/obj/item/wrench/power
	name = "hand drill"
	desc = "A powerful, hand-held drill fitted with a long-lasting battery. It has a bolt driver head attached."
	icon_state = "drill_bolt"
	item_state = "drill"
	belt_icon = "hand_drill"
	usesound = 'sound/items/impactwrench.ogg' // Sourced from freesfx.co.uk
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2" // done for balance reasons, making them high value for research, but harder to get
	force = 8 // might or might not be too high, subject to change
	throwforce = 8
	attack_verb = list("продырявил", "уколол")
	toolspeed = 0.25

/obj/item/wrench/power/examine(mob/user)
	. = ..()
	. += span_notice("Установлена <b>гаечная</b> бита.")

/obj/item/wrench/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, TRUE)
	var/obj/item/screwdriver/power/s_drill = new /obj/item/screwdriver/power
	balloon_alert(user, "установлена винтовая бита")
	qdel(src)
	user.put_in_active_hand(s_drill)

/obj/item/wrench/power/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] прижима[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] к своей голове! Это похоже на попытку самоубийства!"))
	return BRUTELOSS

/obj/item/wrench/medical
	name = "medical wrench"
	desc = "A standard adjustable wrench covered in medical iconography. Its outer surface is mostly covered in rubber, and it seems to be more efficient than a normal wrench."
	icon_state = "wrench_medical"
	force = 2 //MEDICAL
	throwforce = 4
	origin_tech = "materials=1;engineering=1;biotech=3"

/obj/item/wrench/medical/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] мол[PLUR_IT_YAT(user)]ся [declent_ru(DATIVE)], чтобы тот забрал [GEND_HIS_HER(user)] душу. Это похоже на попытку самоубийства!"))

	// Stun stops them from wandering off
	user.Stun(10 SECONDS)
	playsound(loc, 'sound/effects/pray.ogg', 50, TRUE, -1)

	// Let the sound effect finish playing
	sleep(20)

	if(!user)
		return

	for(var/obj/item/wrench in user)
		user.drop_item_ground(wrench)

	var/obj/item/wrench/medical/wrench = new /obj/item/wrench/medical(loc)
	wrench.add_fingerprint(user)
	wrench.desc += " По какой-то причине он напоминает вам [user.declent_ru(ACCUSATIVE)]."

	if(!user)
		return

	user.dust()
	return OBLITERATION

/obj/item/wrench/industrial
	name = "industrial wrench"
	desc = "Инструмент, используемый для закручивания и откручивания гаек и болтов. \
			Использует храповой механизм \"трещотку\", что повышает скорость работы."
	icon_state = "wrench_industrial"
	toolspeed = 0.6
	resistance_flags = FIRE_PROOF | ACID_PROOF
	usesound = 'sound/items/ratchet2.ogg'
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null
