// TODO: отрефакторить портом с TG

// MARK: Base Can
/obj/item/reagent_containers/cup/soda_cans
	icon = 'icons/obj/drinks.dmi'
	var/canopened = FALSE
	container_type = NONE
	var/is_plastic = 0
	var/times_shaken = 0
	var/can_shake = TRUE
	var/can_burst = FALSE
	var/burst_chance = 0
	drink_type = SUGAR
	gender = FEMALE

/obj/item/reagent_containers/cup/soda_cans/get_short_name() // Override if `list_reagents` has more than 1 element.
	if(!length(reagents.reagent_list))
		return declent_ru(NOMINATIVE)
	var/datum/reagent/reagent = reagents.reagent_list[1]
	return reagent.name

/obj/item/reagent_containers/cup/soda_cans/examine(mob/user)
	. = ..()
	. += span_notice("<b>[canopened ? "Открыто" : "Закрыто"]</b>")
	if(!canopened)
		. += span_notice("Используйте <b>Ctrl+ЛКМ</b>, чтобы встряхнуть!")

/obj/item/reagent_containers/cup/soda_cans/attack_self(mob/user)
	if(canopened)
		return ..()
	if(times_shaken)
		fizzy_open(user)
		return ..()
	if(!canopened)
		canopened = TRUE
		container_type |= OPENCONTAINER
		playsound(loc, 'sound/effects/canopen.ogg', rand(10, 50), TRUE)
		to_chat(user, span_notice("Вы открываете [declent_ru(ACCUSATIVE)] с громким хлопком!"))
		return

	return ..()

/obj/item/reagent_containers/cup/soda_cans/proc/crush(mob/user)
	var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(user.loc)
	crushed_can.icon_state = icon_state
	//inherit material vars for recycling purposes
	crushed_can.is_glass = is_glass
	crushed_can.is_plastic = is_plastic
	if(is_glass)
		playsound(user.loc, 'sound/effects/glassbr3.ogg', rand(10, 50), TRUE)
		crushed_can.name = "broken bottle"
	else
		playsound(user.loc, 'sound/weapons/pierce.ogg', rand(10, 50), TRUE)
	qdel(src)
	return crushed_can

/obj/item/reagent_containers/cup/soda_cans/CtrlClick(mob/living/user)
	if(!can_shake || !ishuman(user))
		return ..()
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		balloon_alert(user, "невозможно в данный момент!")
		return ..()
	var/mob/living/carbon/human/H = user
	if(canopened)
		balloon_alert(H, "нельзя встряхнуть после открытия!")
		return
	if(src == H.l_hand || src == H.r_hand)
		can_shake = FALSE
		addtimer(CALLBACK(src, PROC_REF(reset_shakable)), 1 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
		to_chat(H, span_notice("Вы начинаете встряхивать [declent_ru(ACCUSATIVE)]."))
		if(do_after(H, 1 SECONDS, H))
			visible_message(span_warning("[user] встряхнул[GEND_A_O_I(user)] [declent_ru(ACCUSATIVE)]!"))
			if(times_shaken == 0)
				times_shaken++
				addtimer(CALLBACK(src, PROC_REF(reset_shaken)), 1 MINUTES, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)
			else if(times_shaken < 5)
				times_shaken++
				addtimer(CALLBACK(src, PROC_REF(reset_shaken)), (70 - (times_shaken * 10)) SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)
			else
				addtimer(CALLBACK(src, PROC_REF(reset_shaken)), 20 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)
				handle_bursting(user)
	else
		balloon_alert(H, "нужно держать в руке!")

/obj/item/reagent_containers/cup/soda_cans/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!canopened)
		balloon_alert(user, "сначала откройте!")
		return ATTACK_CHAIN_PROCEED
	if(target == user && !reagents.total_volume && user.a_intent == INTENT_HARM && user.zone_selected == BODY_ZONE_HEAD)
		user.visible_message(
			span_warning("[user] смина[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] своим лбом!"),
			span_warning("Вы сминаете [declent_ru(ACCUSATIVE)] своим лбом!"),
		)
		crush(user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/item/reagent_containers/cup/soda_cans/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/bag/trash/cyborg))
		user.visible_message(
			span_notice("[user] засовыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] в свой уплотнитель мусора."),
			span_notice("Вы засовываете [declent_ru(ACCUSATIVE)] в свой уплотнитель мусора."),
		)
		var/obj/can = crush(user)
		can.attackby(I, user, params)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/item/reagent_containers/cup/soda_cans/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return
	if(is_reagent_dispenser(target) && !canopened)
		balloon_alert(user, "сначала откройте!")
		return
	else if(target.is_open_container() && !canopened)
		balloon_alert(user, "сначала откройте!")
		return
	else
		return ..()

/obj/item/reagent_containers/cup/soda_cans/throw_impact(atom/A, datum/thrownthing/throwingdatum)
	. = ..()
	if(times_shaken < 5)
		times_shaken++
	else
		handle_bursting()

/obj/item/reagent_containers/cup/soda_cans/proc/fizzy_open(mob/user, burstopen = FALSE)
	playsound(loc, 'sound/effects/canopenfizz.ogg', rand(10, 50), TRUE)
	canopened = TRUE
	container_type |= OPENCONTAINER

	if(!burstopen && user)
		to_chat(user, span_notice("Вы открываете [declent_ru(ACCUSATIVE)] с громким хлопком!"))
	else
		visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] оглушительно открывается!"))

	if(times_shaken < 5)
		visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] громко шипит!"))
	else
		visible_message(span_boldwarning("[DECLENT_RU_CAP(src, NOMINATIVE)] оглушительно лопается, разливая своё содержимое!"))
		if(reagents.total_volume)
			var/datum/effect_system/fluid_spread/foam/sodafizz = new
			sodafizz.set_up(amount = 1, location = get_turf(src), carry = reagents)
			sodafizz.start()

	for(var/mob/living/carbon/C in range(1, get_turf(src)))
		to_chat(C, span_warning("Вас облило содержимым [declent_ru(ACCUSATIVE)]!"))
		reagents.reaction(C, REAGENT_TOUCH)
		C.adjust_wet_stacks(max(1, times_shaken))

	reagents.remove_any(times_shaken / 5 * reagents.total_volume)

/obj/item/reagent_containers/cup/soda_cans/proc/handle_bursting(mob/user)
	if(times_shaken != 5 || canopened)
		return

	if(!can_burst)
		can_burst = TRUE
		burst_chance = 5
		return

	if(burst_chance < 50)
		burst_chance += 5

	if(prob((burst_chance)))
		if(user)
			fizzy_open(user, burstopen = TRUE)
		else
			fizzy_open(burstopen = TRUE)

/obj/item/reagent_containers/cup/soda_cans/proc/reset_shakable()
	can_shake = TRUE

/obj/item/reagent_containers/cup/soda_cans/proc/reset_shaken()
	times_shaken--
	if(can_burst)
		can_burst = FALSE
		burst_chance = 0
	if(times_shaken)
		addtimer(CALLBACK(src, PROC_REF(reset_shaken)), (70 - (times_shaken * 10)) SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)


// MARK: Can Types
/obj/item/reagent_containers/cup/soda_cans/cola
	name = "space cola"
	desc = "Cola. In space."
	icon_state = "cola"
	list_reagents = list("cola" = 30)

/obj/item/reagent_containers/cup/soda_cans/energy
	name = "heart attack"
	desc = "The heart will say: - My stop."
	icon_state = "heart_attack"
	item_state = "heart_attack"
	list_reagents = list("energetik" = 30)

/obj/item/reagent_containers/cup/soda_cans/energy/trop
	name = "tropical spasm"
	desc = "Get a taste of hunting down USSP soldiers."
	icon_state = "tropical_spasm"
	item_state = "tropical_spasm"
	list_reagents = list("trop_eng" = 30)

/obj/item/reagent_containers/cup/soda_cans/energy/milk
	name = "milk flow"
	desc = "For pro gamers."
	icon_state = "milk_flow"
	item_state = "milk_flow"
	list_reagents = list("milk_eng" = 30)

/obj/item/reagent_containers/cup/soda_cans/energy/grey
	name = "GreyPower"
	desc = "Your hands will burn from GreyPower."
	icon_state = "GreyPower"
	item_state = "GreyPower"
	list_reagents = list("grey_eng" = 30)

/obj/item/reagent_containers/cup/soda_cans/beer
	name = "space beer"
	desc = "Contains only water, malt and hops."
	icon_state = "beer"
	is_glass = 1
	list_reagents = list("beer" = 30)

/obj/item/reagent_containers/cup/soda_cans/beer/almost_empty
	list_reagents = list("beer" = 1)

/obj/item/reagent_containers/cup/soda_cans/non_alcoholic_beer
	name = "non-alcoholic beer"
	desc = "A favorite thing of all students and those who drive."
	icon_state = "alcoholfreebeercan"
	list_reagents = list("noalco_beer" = 30)

/obj/item/reagent_containers/cup/soda_cans/adminbooze
	name = "admin booze"
	desc = "Bottled Griffon tears. Drink with caution."
	icon_state = "adminbooze"
	is_glass = 1
	list_reagents = list("adminordrazine" = 5, "capsaicin" = 5, "methamphetamine"= 20, "thirteenloko" = 20)

/obj/item/reagent_containers/cup/soda_cans/madminmalt
	name = "madmin malt"
	desc = "Bottled essence of angry admins. Drink with <i>EXTREME</i> caution."
	icon_state = "madminmalt"
	is_glass = 1
	list_reagents = list("hell_water" = 20, "neurotoxin" = 15, "thirteenloko" = 15)

/obj/item/reagent_containers/cup/soda_cans/badminbrew
	name = "badmin brew"
	desc = "Bottled trickery and terrible admin work. Probably shouldn't drink this one at all."
	icon_state = "badminbrew"
	is_glass = 1
	list_reagents = list("mutagen" = 25, "charcoal" = 10, "thirteenloko" = 15)

/obj/item/reagent_containers/cup/soda_cans/ale
	name = "Tail Tells Tales Ale"
	desc = "The label has a tail drawn on it that extends the entire length of the bottle. If you rip it off, you can read some short tale or legend on the back of the label."
	icon_state = "alebottle"
	item_state = "beer"
	is_glass = 1
	list_reagents = list("ale" = 30)

/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
	list_reagents = list("spacemountainwind" = 30)

/obj/item/reagent_containers/cup/soda_cans/thirteenloko
	name = "Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkenness, or even death. Please Drink Responsibly."
	icon_state = "thirteen_loko"
	list_reagents = list("thirteenloko" = 25, "psilocybin" = 5)

/obj/item/reagent_containers/cup/soda_cans/dr_gibb
	name = "Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb"
	list_reagents = list("dr_gibb" = 30)

/obj/item/reagent_containers/cup/soda_cans/starkist
	name = "Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
	list_reagents = list("brownstar" = 30)

/obj/item/reagent_containers/cup/soda_cans/space_up
	name = "Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
	list_reagents = list("space_up" = 30)

/obj/item/reagent_containers/cup/soda_cans/lemon_lime
	name = "Lemon-Lime"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
	list_reagents = list("lemon_lime" = 30)

/obj/item/reagent_containers/cup/soda_cans/iced_tea
	name = "Vrisk Serket Iced Tea"
	desc = "That sweet, refreshing southern earthy flavor. That's where it's from, right? South Earth?"
	icon_state = "ice_tea_can"
	list_reagents = list("icetea" = 30)

/obj/item/reagent_containers/cup/soda_cans/grape_juice
	name = "Refreshing Purple Grapel Juice"
	desc = "500 pages of rules of how to appropriately enter into a combat with this juice!"
	icon_state = "purple_can"
	list_reagents = list("grapejuice" = 30)
/obj/item/reagent_containers/cup/soda_cans/tonic
	name = "T-Borg's Tonic Water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
	list_reagents = list("tonic" = 50)

/obj/item/reagent_containers/cup/soda_cans/sodawater
	name = "soda water"
	desc = "A can of soda water. Still water's more refreshing cousin."
	icon_state = "sodawater"
	list_reagents = list("sodawater" = 50)

/obj/item/reagent_containers/cup/soda_cans/synthanol
	name = "Beep's Classic Synthanol"
	desc = "A can of IPC booze, however that works."
	icon_state = "synthanolcan"
	list_reagents = list("synthanol" = 50)

/obj/item/reagent_containers/cup/soda_cans/bottler
	name = "generic beverage container"
	desc = "this shouldn't ever be spawned. shame on you"
	icon_state = "glass_bottle"
	fill_icon_thresholds = list(1, 10, 20, 30, 40, 50)

/obj/item/reagent_containers/cup/soda_cans/bottler/glass_bottle
	name = "glass bottle"
	desc = "A glass bottle suitable for beverages."
	is_glass = 1

/obj/item/reagent_containers/cup/soda_cans/bottler/plastic_bottle
	name = "plastic bottle"
	desc = "A plastic bottle suitable for beverages."
	icon_state = "plastic_bottle"
	is_plastic = 1

/obj/item/reagent_containers/cup/soda_cans/bottler/metal_can
	name = "metal can"
	desc = "A metal can suitable for beverages."
	icon_state = "metal_can"
