////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food/pill
	name = "pill"
	desc = "a pill."
	gender = FEMALE
	icon_state = "pill"
	item_state = "pill"
	volume = 100
	consume_sound = null
	can_taste = FALSE
	antable = FALSE
	pickup_sound = 'sound/items/handling/pickup/generic_small_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/generic_small_drop.ogg'
	custom_price = PAYCHECK_MIN * 0.3

/obj/item/reagent_containers/food/pill/Initialize(mapload)
	if(icon_state == "pill")
		icon_state = "pill[rand(1,20)]"
	. = ..()

/obj/item/reagent_containers/food/pill/attack_self(mob/user)
	return

/obj/item/reagent_containers/food/pill/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!iscarbon(target))
		return .
	if(!get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		if(target == user)
			balloon_alert(user, "ваш рот закрыт!")
		else
			balloon_alert(user, "рот цели закрыт!")
		return .
	if(!user.can_unEquip(src))
		return .
	bitesize = reagents.total_volume
	if(!target.eat(src, user) || !user.can_unEquip(src))
		return .
	user.drop_transfer_item_to_loc(src, target)
	qdel(src)
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/item/reagent_containers/food/pill/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return

	if(target.is_open_container() != 0 && target.reagents)
		if(!target.reagents.total_volume)
			balloon_alert(user, "не в чем растворять!")
			return
		balloon_alert(user, "таблетка растворена")
		reagents.trans_to(target, reagents.total_volume)
		for(var/mob/O in viewers(2, user))
			O.show_message(span_warning("[user] броса[PLUR_ET_YUT(user)] что-то в [target.declent_ru(ACCUSATIVE)]."), 1)
		spawn(5)
			qdel(src)

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

//Pills
/obj/item/reagent_containers/food/pill/tox
	name = "Toxins pill"
	desc = "Highly toxic."
	icon_state = "pill21"
	list_reagents = list("toxin" = 50)

/obj/item/reagent_containers/food/pill/initropidril
	name = "initropidril pill"
	desc = "Don't swallow this."
	icon_state = "pill21"
	list_reagents = list("initropidril" = 50)

/obj/item/reagent_containers/food/pill/fakedeath
	name = "fake death pill"
	desc = "Swallow then rest to appear dead, stand up to wake up. Also mutes the user's voice."
	icon_state = "pill4"
	list_reagents = list("capulettium_plus" = 50)

/obj/item/reagent_containers/food/pill/morphine
	name = "Morphine pill"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill8"
	list_reagents = list("morphine" = 30)

/obj/item/reagent_containers/food/pill/methamphetamine
	name = "Methamphetamine pill"
	desc = "Helps improve the ability to concentrate."
	icon_state = "pill8"
	list_reagents = list("methamphetamine" = 5)

/obj/item/reagent_containers/food/pill/pervitin
	name = "Pervitin pill"
	desc = "Увеличивает концентрацию и ускоряет работу руками. Вызывает сильное привыкание."
	icon_state = "pill8"
	list_reagents = list("pervitin" = 5)

/obj/item/reagent_containers/food/pill/lsd
	name = "LSD pill"
	desc = "Commonly used to get high."
	icon_state = "pill4"
	list_reagents = list("lsd" = 5)

/obj/item/reagent_containers/food/pill/rum
	name = "rum pill"
	desc = "Commonly used to... Wait a second, what the f.."
	icon_state = "pill8"
	list_reagents = list("rum" = 25)

/obj/item/reagent_containers/food/pill/stimulative_agent
	name = "combat stimulant pill"
	desc = "Used by elite soldiers to increase speed and battle performance."
	icon_state = "pill15"
	list_reagents = list("stimulative_agent" = 5)

/obj/item/reagent_containers/food/pill/haloperidol
	name = "Haloperidol pill"
	desc = "Haloperidol is an anti-psychotic use to treat psychiatric problems."
	icon_state = "pill8"
	list_reagents = list("haloperidol" = 15)

/obj/item/reagent_containers/food/pill/happy
	name = "Happy pill"
	desc = "Happy happy joy joy!"
	icon_state = "pill18"
	list_reagents = list("space_drugs" = 15, "sugar" = 15)

/obj/item/reagent_containers/food/pill/zoom
	name = "Zoom pill"
	desc = "Zoooom!"
	icon_state = "pill18"
	list_reagents = list("synaptizine" = 5, "methamphetamine" = 5)

/obj/item/reagent_containers/food/pill/charcoal
	name = "Charcoal pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"
	list_reagents = list("charcoal" = 50)

/obj/item/reagent_containers/food/pill/epinephrine
	name = "Epinephrine pill"
	desc = "Used to provide shots of adrenaline."
	icon_state = "pill6"
	list_reagents = list("epinephrine" = 50)

/obj/item/reagent_containers/food/pill/salicylic
	name = "Salicylic Acid pill"
	desc = "Commonly used to treat moderate pain and fevers."
	icon_state = "pill4"
	list_reagents = list("sal_acid" = 20)

/obj/item/reagent_containers/food/pill/salbutamol
	name = "Salbutamol pill"
	desc = "Used to treat respiratory distress."
	icon_state = "pill8"
	list_reagents = list("salbutamol" = 20)

/obj/item/reagent_containers/food/pill/hydrocodone
	name = "Hydrocodone pill"
	desc = "Used to treat extreme pain."
	icon_state = "pill6"
	list_reagents = list("hydrocodone" = 15)

/obj/item/reagent_containers/food/pill/calomel
	name = "calomel pill"
	desc = "Can be used to purge impurities, but is highly toxic itself."
	icon_state = "pill3"
	list_reagents = list("calomel" = 15)

/obj/item/reagent_containers/food/pill/mutadone
	name = "mutadone pill"
	desc = "Used to cure genetic abnormalities."
	icon_state = "pill18"
	list_reagents = list("mutadone" = 20)

/obj/item/reagent_containers/food/pill/mannitol
	name = "mannitol pill"
	desc = "Used to treat cranial swelling."
	icon_state = "pill19"
	list_reagents = list("mannitol" = 20)

/obj/item/reagent_containers/food/pill/bicaridine
	name = "bicaridine pill"
	desc = "Используется для лечения травм."
	icon_state = "pill5"
	list_reagents = list("bicaridine" = 10)

/obj/item/reagent_containers/food/pill/kelotane
	name = "kelotane pill"
	desc = "Используется для лечения ожогов."
	icon_state = "pill6"
	list_reagents = list("kelotane" = 10)
