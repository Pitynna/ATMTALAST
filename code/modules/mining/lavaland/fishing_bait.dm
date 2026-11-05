/obj/item/reagent_containers/food/snacks/bait
	name = "worm"
	desc = "Test bait. If you see this, ping Zyuzya."
	gender = MALE
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "ash_eater"
	lefthand_file = 'icons/mob/inhands/lavaland/bait_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/bait_righthand.dmi'
	item_state = "ash_eater"
	list_reagents = list("protein" = 1) //mmmm tasty
	tastes = list("пепла" = 5, "безнадёжности" = 1)
	bitesize = 1
	foodtype = MEAT
	antable = FALSE
	/// This will be visually shown on fishing rod.
	var/rod_overlay  = "ash_eater_rod"

/obj/item/reagent_containers/food/snacks/bait/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете использовать [declent_ru(ACCUSATIVE)] в качестве наживки.")

/obj/item/reagent_containers/food/snacks/bait/random/Initialize(mapload)
	. = ..()
	if(prob(40)) //60pc chance to nothing
		var/bait = pick(subtypesof(/obj/item/reagent_containers/food/snacks/bait))
		new bait(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/reagent_containers/food/snacks/bait/ash_eater
	name = "ash eater"
	desc = "A little worm with a mouth full of incredibly sharp teeth. Rumor says these tiny creatures can grow as large as a city. The ash must flow."

/obj/item/reagent_containers/food/snacks/bait/bloody_leach
	name = "bloody leach"
	desc = "A parasitic life-form from Lazis Ardax that attaches to exposed skin and feeds on its victim. Its abdomen turns red from all the blood it drinks."
	gender = FEMALE
	icon_state = "bloody_leach"
	item_state = "bloody_leach"
	rod_overlay = "bloody_leach_rod"

/obj/item/reagent_containers/food/snacks/bait/goldgrub_larva
	name = "goldgrub larva"
	desc = "A small worm that feeds on minerals buried in ash. Just as timid as its older relatives."
	gender = FEMALE
	icon_state = "goldgrub_larva"
	item_state = "goldgrub_larva"
	rod_overlay = "goldgrub_larva_rod"

/obj/item/reagent_containers/food/snacks/charred_krill
	name = "charred krill"
	desc = "One of Lazis Ardax's rarest inhabitants, long believed extinct. This shrimp is a favorite treat of the local underwater fauna."
	gender = FEMALE
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "charred_krill"
	item_state = "charred_krill"
	list_reagents = list("protein" = 1)
	bitesize = 1
	antable = FALSE
	tastes = list("пепла" = 5, "упущенных возможностей" = 1)
	var/in_lava = FALSE

/obj/item/reagent_containers/food/snacks/charred_krill/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете бросить [declent_ru(ACCUSATIVE)] в лаву, чтобы привлечь рыбу к поверхности.")

/obj/item/reagent_containers/food/snacks/charred_krill/can_be_pulled(atom/movable/user, force, show_message)
	if(in_lava)
		if(show_message)
			to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] почти утонула в лаве!"))
			return

/obj/item/reagent_containers/food/snacks/charred_krill/attack_hand(mob/user, pickupfireoverride)
	if(in_lava)
		return
	else
		return ..()

//Zuza blyat
/obj/item/reagent_containers/food/snacks/charred_krill/suicide_act(mob/user) //I forbid you to translate it.
	user.visible_message(span_suicide("[user] is going to krill himself! Oh god..."))
	user.say("goodbye krill world...")
	sleep(20)
	var/obj/item/reagent_containers/food/snacks/charred_krill/krill = new /obj/item/reagent_containers/food/snacks/charred_krill(drop_location())
	krill.desc += " Look's like someone KRILLED himself."
	qdel(user)
	return OBLITERATION
