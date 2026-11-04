/obj/item/crowbar
	name = "crowbar"
	desc = "A basic crowbar made of forged steel. Handy for opening unpowered airlocks, prying out objects, and being an improvised melee weapon."
	gender = FEMALE
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	item_state = "crowbar"
	belt_icon = "pocket_crowbar"
	usesound = 'sound/items/crowbar.ogg'
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 10
	materials = list(MAT_METAL=50)
	drop_sound = 'sound/items/handling/drop/crowbar_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/crowbar_pickup.ogg'
	origin_tech = "engineering=1;combat=1"
	attack_verb = list("атаковал", "ударил", "огрел")
	toolbox_radial_menu_compatibility = TRUE

	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 30)
	tool_behaviour = TOOL_CROWBAR

/obj/item/crowbar/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = force, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/obj/item/crowbar/small
	name = "miniature titanium crowbar"
	desc = "A tiny, lightweight titanium crowbar. It fits handily in your pocket."
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 7.5
	materials = list(MAT_TITANIUM = 250)
	icon_state = "crowbar_titanium"
	item_state = "crowbar_titanium"
	origin_tech = "materials=2"
	toolspeed = 3

/obj/item/crowbar/red
	icon_state = "crowbar_red"
	item_state = "crowbar_red"

/obj/item/crowbar/red/sec
	icon_state = "crowbar_sec"
	item_state = "crowbar_sec"

/obj/item/crowbar/brass
	name = "brass crowbar"
	desc = "A brass crowbar. It feels faintly warm to the touch."
	icon_state = "crowbar_brass"
	item_state = "crowbar_brass"
	toolspeed = 0.5
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/crowbar/abductor
	name = "alien crowbar"
	desc = "A hard-light crowbar. It appears to pry by itself, without any effort required."
	icon = 'icons/obj/abductor.dmi'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	item_state = "crowbar_alien"
	belt_icon = "alien_crowbar"
	toolspeed = 0.1
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=4;engineering=4;abductor=3"

/obj/item/crowbar/large
	name = "large crowbar"
	desc = "A very large, quite heavy crowbar. It's got some real oomph behind it."
	force = 15
	throwforce = 18
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 3
	throw_range = 3
	materials = list(MAT_METAL=70)
	icon_state = "crowbar_large"
	item_state = "crowbar_large"
	toolspeed = 0.5

/obj/item/crowbar/cyborg
	name = "hydraulic crowbar"
	desc = "A powerful and compact hydraulic crowbar typically found in construction and engineering robots."
	usesound = 'sound/items/jaws_pry.ogg'
	toolspeed = 0.5

/obj/item/crowbar/power
	name = "jaws of life"
	desc = "A compact and powerful industrial tool with a modular head. This one has a set of prying jaws attached, which are strong enough to pry open powered airlocks."
	icon_state = "jaws_pry"
	item_state = "jawsoflife"
	belt_icon = "jaws_of_life"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2"
	usesound = 'sound/items/jaws_pry.ogg'
	toolspeed = 0.25
	/// Time required to open powered airlocks
	var/airlock_open_time = 100

/obj/item/crowbar/power/examine(mob/user)
	. = ..()
	. += span_notice("Установлена <b>поддевающая</b> насадка.")

/obj/item/crowbar/power/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/crowbar/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, TRUE)
	var/obj/item/wirecutters/power/cutjaws = new /obj/item/wirecutters/power
	balloon_alert(user, "установлена перерезающая насадка")
	qdel(src)
	user.put_in_active_hand(cutjaws)

/obj/item/crowbar/power/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] помеща[PLUR_ET_YUT(user)] свою голову между лезвиями [declent_ru(GENITIVE)]. Это похоже на попытку самоубийства!"))
	playsound(loc, 'sound/items/jaws_pry.ogg', 50, TRUE, -1)
	return BRUTELOSS

/obj/item/crowbar/industrial
	name = "industrial crowbar"
	desc = "Инструмент, предназначенный для использования в качестве рычага. \
			Дополнительные прорезиненные накладки на рукояти облегчают хват."
	icon_state = "crowbar_industrial"
	toolspeed = 0.6
	resistance_flags = FIRE_PROOF | ACID_PROOF
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null
