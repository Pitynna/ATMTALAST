/obj/item/screwdriver
	name = "screwdriver"
	desc = "A common screwdriver made of plastic and steel, fitted with a Sector-standard Phillips head."
	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/screwdriver"
	post_init_icon_state = "screwdriver"
	item_state = "screwdriver"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	belt_icon = "screwdriver"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	drop_sound = 'sound/items/handling/drop/screwdriver_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/screwdriver_pickup.ogg'
	materials = list(MAT_METAL=75)
	attack_verb = list("уколол", "тыкнул")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = 'sound/items/screwdriver.ogg'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 30)
	tool_behaviour = TOOL_SCREWDRIVER
	toolbox_radial_menu_compatibility = TRUE
	greyscale_config = /datum/greyscale_config/screwdriver
	greyscale_config_inhand_left = /datum/greyscale_config/screwdriver_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/screwdriver_inhand_right
	greyscale_config_belt = /datum/greyscale_config/screwdriver_belt
	greyscale_colors = COLOR_TOOL_RED
	/// If the item should be assigned a random color
	var/random_color = TRUE
	/// List of possible random colors
	var/static/list/screwdriver_colors = list(
		"blue" = "#1861d5",
		"red" = "#ff0000",
		"pink" = "#d5188d",
		"brown" = "#a05212",
		"green" = "#0e7f1b",
		"cyan" = "#18a2d5",
		"yellow" = "#ffa500"
	)

/obj/item/screwdriver/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] вонза[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] себе в [pick("висок", "сердце")]! Это похоже на попытку самоубийства!"))
	return BRUTELOSS

/obj/item/screwdriver/Initialize(mapload, param_color = null)
	if(random_color)
		var/our_color = param_color || pick(screwdriver_colors)
		set_greyscale_colors(list(screwdriver_colors[our_color]))
	. = ..()
	if(prob(75))
		pixel_y = rand(0, 16)


	AddComponent(/datum/component/surgery_initiator/robo)
	AddElement(/datum/element/falling_hazard, damage = force, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/obj/item/screwdriver/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(user.a_intent == INTENT_HELP)
		return ..()
	if(user.zone_selected != BODY_ZONE_PRECISE_EYES && user.zone_selected != BODY_ZONE_HEAD)
		return ..()
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		target = user
	return eyestab(target, user)

/obj/item/screwdriver/nuke
	desc = "A specialized screwdriver with an ultra-thin flathead tip, meant for accessing very specific machinery."
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver_nuke"
	belt_icon = "screwdriver_nuke"
	post_init_icon_state = null
	toolspeed = 0.5
	random_color = FALSE
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_belt = null
	greyscale_colors = null

/obj/item/screwdriver/brass
	name = "brass screwdriver"
	desc = "A screwdriver made of brass. The handle feels freezing cold."
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver_brass"
	belt_icon = "screwdriver_brass"
	toolspeed = 0.5
	random_color = FALSE
	post_init_icon_state = null
	resistance_flags = FIRE_PROOF | ACID_PROOF
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_belt = null
	greyscale_colors = null

/obj/item/screwdriver/abductor
	name = "alien screwdriver"
	desc = "An ultrasonic screwdriver."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "screwdriver"
	belt_icon = "alien_screwdriver"
	usesound = 'sound/items/pshoom.ogg'
	toolspeed = 0.1
	random_color = FALSE
	w_class = WEIGHT_CLASS_TINY
	post_init_icon_state = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_belt = null
	greyscale_colors = null

/obj/item/screwdriver/cyborg
	name = "powered screwdriver"
	desc = "A powered screwdriver typically found in construction and engineering robots."
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.5
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/item/screwdriver/power
	name = "hand drill"
	desc = "A powerful, hand-held drill fitted with a long-lasting battery. It has a screwdriver head attached."
	icon = 'icons/obj/tools.dmi'
	icon_state = "drill_screw"
	item_state = "drill"
	belt_icon = "hand_drill"
	post_init_icon_state = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_belt = null
	greyscale_colors = null
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2" // done for balance reasons, making them high value for research, but harder to get
	force = 8
	throwforce = 8
	throw_speed = 2
	throw_range = 3// it's heavier than a screw driver/wrench, so it does more damage, but can't be thrown as far
	attack_verb = list("продырявил", "уколол", "огрел")
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.25
	random_color = FALSE
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/crowbar/power/examine(mob/user)
	. = ..()
	. += span_notice("Установлена <b>винтовая</b> бита.")

/obj/item/screwdriver/power/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/screwdriver/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, TRUE)
	var/obj/item/wrench/power/b_drill = new /obj/item/wrench/power
	balloon_alert(user, "установлена гаечная бита")
	qdel(src)
	user.put_in_active_hand(b_drill)

/obj/item/screwdriver/power/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] приставля[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] к своему виску. Это похоже на попытку самоубийства!"))
	return BRUTELOSS

/obj/item/screwdriver/industrial
	name = "industrial screwdriver"
	desc = "Инструмент, предназначенный для завинчивания и отвинчивания изделий с резьбой. \
			Нескользящие накладки улучшают хват, облегчая работу."
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver_industrial"
	post_init_icon_state = null
	toolspeed = 0.6
	resistance_flags = FIRE_PROOF | ACID_PROOF
	random_color = FALSE
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null
