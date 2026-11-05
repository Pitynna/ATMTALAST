/**
 * MARK: Base cartridge
 */

/obj/item/coffee_cartridge
	name = "coffeemaker cartridge – Caffè Generico"
	desc = "A cartridge containing ground coffee beans. Compatible with the Modello 3 coffee machine. Manufactured by Piccionaia Home Appliances."
	gender = MALE
	icon = 'icons/obj/food/cartridges.dmi'
	icon_state = "cartridge_basic"
	w_class = WEIGHT_CLASS_SMALL
	var/charges = 4
	var/list/drink_type = list("coffee" = 150)

/obj/item/coffee_cartridge/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader)

/obj/item/coffee_cartridge/examine(mob/user)
	. = ..()
	if(charges)
		. += span_notice("Хватит ещё на <b>[charges]</b> использовани[DECL_E_YA_J(charges)].")
	else
		. += span_notice("<b>Пусто</b>.")

/**
 * MARK: Fancy cartridge
 */

/obj/item/coffee_cartridge/fancy
	name = "coffeemaker cartridge – Caffè Fantasioso"
	desc = "A premium cartridge containing ground coffee beans. Compatible with the Modello 3 coffee machine. Manufactured by Piccionaia Home Appliances."
	icon_state = "cartridge_blend"
	/// Associated cartridge datum
	var/datum/coffee_cartridge_type/cartridge_type

/obj/item/coffee_cartridge/fancy/Initialize(mapload)
	. = ..()

	// Picking a random type
	var/list/types = list(
		/datum/coffee_cartridge_type/blend,
		/datum/coffee_cartridge_type/blue_mountain,
		/datum/coffee_cartridge_type/kilimanjaro,
		/datum/coffee_cartridge_type/mocha,
	)
	var/chosen_type = pick(types)
	cartridge_type = new chosen_type()

	// Applying parameters from the datum
	name = "coffeemaker cartridge – [cartridge_type.name_en]"
	var/type_name = cartridge_type.ru_name_base
	ru_names = alist(
		NOMINATIVE = "кофейный картридж \"[type_name]\"",
		GENITIVE = "кофейного картриджа \"[type_name]\"",
		DATIVE = "кофейному картриджу \"[type_name]\"",
		ACCUSATIVE = "кофейный картридж \"[type_name]\"",
		INSTRUMENTAL = "кофейным картриджем \"[type_name]\"",
		PREPOSITIONAL = "кофейном картридже \"[type_name]\"",
	)
	icon_state = cartridge_type.icon_state

/**
 * MARK: Decaf cartridge
 */

//TODO: make it actually decaf, maybe by adding a reagent that reduces caffeine's effects or sum?
/obj/item/coffee_cartridge/decaf
	name = "coffeemaker cartridge – Caffè Decaffeinato"
	desc = "A cartridge containing ground coffee beans with the caffeine artificially removed. Compatible with the Modello 3 coffee machine. Manufactured by Piccionaia Home Appliances."
	icon_state = "cartridge_decaf"

/**
 * MARK: Bootleg cartridge
 */

// no you can't just squeeze the juice bag into a glass!
/obj/item/coffee_cartridge/bootleg
	name = "coffeemaker cartridge – Botany Blend"
	desc = "A homemade cartridge containing ground coffee beans. Theoretically compatible with the Modello 3 coffee machine, but there are no guarantees."
	icon_state = "cartridge_bootleg"

/**
 * MARK: Blank cartridge
 */

/obj/item/blank_coffee_cartridge
	name = "blank coffee cartridge"
	desc = "An empty cartridge for ground coffee beans. Compatible with the Modello 3 coffee machine."
	gender = MALE
	icon = 'icons/obj/food/cartridges.dmi'
	icon_state = "cartridge_blank"
	w_class = WEIGHT_CLASS_SMALL
