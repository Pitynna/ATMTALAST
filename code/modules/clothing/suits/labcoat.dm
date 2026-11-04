/obj/item/clothing/suit/storage/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat_open"
	item_state = "labcoat_open"
	ignore_suitadjust = FALSE
	permeability_coefficient = 0.5
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(
		/obj/item/analyzer,
		/obj/item/autopsy_scanner,
		/obj/item/bodyanalyzer,
		/obj/item/dnainjector,
		/obj/item/dna_notepad,
		/obj/item/flashlight/pen,
		/obj/item/gun/syringe,
		/obj/item/handheld_defibrillator,
		/obj/item/healthanalyzer,
		/obj/item/paper,
		/obj/item/pinpointer/crew,
		/obj/item/rad_laser,
		/obj/item/reagent_containers/applicator,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/food/pill,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/iv_bag,
		/obj/item/reagent_containers/spray/cleaner,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_scanner,
		/obj/item/roller/holo,
		/obj/item/sensor_device,
		/obj/item/soap,
		/obj/item/stack/medical,
		/obj/item/storage/bag/bio,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/pill_bottle,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tourniquet,
	)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 50, FIRE = 50, ACID = 50)
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
	)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/storage/labcoat/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/right_click_mapper/attack_self, "Застегнуть/Расстегнуть [declent_ru(ACCUSATIVE)]")

/obj/item/clothing/suit/storage/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Fancier than the standard model. Has blue medical markings."
	icon_state = "labcoat_cmo_open"
	item_state = "labcoat_cmo_open"

/obj/item/clothing/suit/storage/labcoat/mad
	name = "mad scientist's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labcoat_green_open"
	item_state = "labcoat_green_open"

/obj/item/clothing/suit/storage/labcoat/genetics
	name = "geneticist labcoat"
	desc = "A suit that protects against minor chemical spills. Has wine research markings."
	icon_state = "labcoat_gen_open"
	item_state = "labcoat_gen_open"

/obj/item/clothing/suit/storage/labcoat/chemist
	name = "chemist labcoat"
	desc = "A suit that protects against minor chemical spills. Has orange medical markings."
	icon_state = "labcoat_chem_open"
	item_state = "labcoat_chem_open"

/obj/item/clothing/suit/storage/labcoat/virologist
	name = "virologist labcoat"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has green medical markings."
	icon_state = "labcoat_vir_open"

/obj/item/clothing/suit/storage/labcoat/science
	name = "scientist labcoat"
	desc = "A suit that protects against minor chemical spills. Has purple research markings."
	icon_state = "labcoat_tox_open"
	item_state = "labcoat_tox_open"

/obj/item/clothing/suit/storage/labcoat/mortician
	name = "coroner labcoat"
	desc = "A suit that protects against minor chemical spills. Has black medical markings."
	icon_state = "labcoat_mort_open"
	item_state = "labcoat_mort_open"

/obj/item/clothing/suit/storage/labcoat/emt
	name = "EMT labcoat"
	desc = "A comfortable suit for paramedics. Has dark colours and white medical markings."
	icon_state = "labcoat_emt_open"
	item_state = "labcoat_emt_open"

/obj/item/clothing/suit/storage/labcoat/mining_medic
	name = "mining medic's labcoat"
	desc = "Стерильный белый халат с коричневыми нашивками на плечах. От него исходит тонкий запах пепла."
	icon_state = "mining_labcoat_open"
	item_state = "mining_labcoat_open"
