// MARK: Coffee cups
/obj/item/reagent_containers/cup/glass/coffee_cup
	name = ""
	desc = ""
	max_integrity = 20
	is_glass = FALSE

/obj/item/reagent_containers/cup/glass/coffee_cup/examine(mob/user)
	. = ..()
	. += span_notice("Вмещает до <b>[volume]</b> единиц[DECL_Y_0_0(volume)] вещества.")

/obj/item/reagent_containers/cup/glass/coffee_cup/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/cup/glass/coffee_cup/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader, "cups")

// MARK: Coffee cup
/obj/item/reagent_containers/cup/glass/coffee_cup/normal
	name = "coffee cup"
	desc = "A convenient paper cup with a removable lid, intended for coffee."
	icon_state = "coffeecup"
	base_icon_state = "coffeecup"
	possible_transfer_amounts = list(10,25,50)
	can_lid = TRUE
	fill_icon_thresholds = list(55, 70, 85, 100)

/obj/item/reagent_containers/cup/glass/coffee_cup/small
	name = "small coffee cup"
	desc = "A small paper cup commonly used to serve coffee. Not especially convenient."
	icon_state = "coffeecup_small"
	base_icon_state = "coffeecup_small"
	possible_transfer_amounts = list(10,30)
	volume = 30
	fill_icon_thresholds = list(40, 60, 80, 100)

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee
	list_reagents = list("coffee" = 30)

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee/experimentor
	name = "cup of suspicious liquid"
	desc = "A large, barely visible chemical hazard symbol is printed on its side."
	var/selected_reagent

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee/experimentor/Initialize(mapload)
	. = ..()
	spawn_reagent()

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee/experimentor/proc/spawn_reagent()
	var/chosenchem = pick_reagent()
	selected_reagent = chosenchem
	reagents.remove_all(25)
	reagents.add_reagent(chosenchem, 50)

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee/experimentor/proc/pick_reagent()
	return /datum/reagent/consumable/drink/coffee

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee/experimentor/heat/pick_reagent()
	return pick(
		/datum/reagent/plasma,
		/datum/reagent/consumable/capsaicin,
		/datum/reagent/consumable/ethanol,
	)

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee/experimentor/cold/pick_reagent()
	return pick(
		/datum/reagent/uranium,
		/datum/reagent/consumable/frostoil,
		/datum/reagent/medicine/ephedrine,
	)
