/obj/item/clothing/suit/space/hardsuit/vox
	name = "vox raider hardsuit"
	desc = "A specialized protective spacesuit for vox raiders. Its synthetic material allows operation in hostile environments, making it highly versatile. Its different construction offers less protection than mercenary armor."
	icon_state = "vox-raider"
	item_color = "vox-raider"
	item_state = "rig_suit"
	species_restricted = list(SPECIES_VOX)
	icon = 'icons/obj/clothing/species/vox/suits.dmi'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
	)
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/gun,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/restraints/handcuffs,
	)
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 75, BULLET = 50, LASER = 30, ENERGY = 20, BOMB = 25, FIRE = 80, ACID = 200)
	put_on_delay = 6 SECONDS
	slowdown = 0
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/vox

/obj/item/clothing/suit/space/hardsuit/vox/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/head/helmet/space/hardsuit/vox
	name = "vox raider helmet"
	desc = "A specialized vox raider space helmet."
	icon_state = "vox-raider"
	item_color = "vox-raider"
	species_restricted = list(SPECIES_VOX)
	icon = 'icons/obj/clothing/species/vox/hats.dmi'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
	)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 75, BULLET = 50, LASER = 30, ENERGY = 20, BOMB = 25, FIRE = 80, ACID = 200)

/obj/item/clothing/head/helmet/space/hardsuit/vox/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/head/helmet/space/hardsuit/vox/update_icon_state()
	icon_state = "[initial(icon_state)][light_on ? "_light" : ""]"

/obj/item/clothing/suit/space/hardsuit/vox/trooper
	name = "vox raider trooper hardsuit"
	desc = "A specialized protective spacesuit for vox raiders. Its synthetic material allows operation in hostile environments, making it highly versatile. Its different construction offers less protection than mercenary armor.\nA raider assault spacesuit offering protection against firearms, piercing and slashing attacks."
	icon_state = "vox-raider-trooper"
	item_color = "vox-raider-trooper"
	armor = list(MELEE = 75, BULLET = 50, LASER = 30, ENERGY = 20, BOMB = 25, FIRE = 80, ACID = 200)
	strip_delay = 12 SECONDS
	put_on_delay = 8 SECONDS
	slowdown = 1
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/vox/trooper

/obj/item/clothing/head/helmet/space/hardsuit/vox/trooper
	name = "vox raider trooper helmet"
	icon_state = "vox-raider-trooper"
	item_color = "vox-raider-trooper"
	armor = list(MELEE = 75, BULLET = 50, LASER = 30, ENERGY = 20, BOMB = 25, FIRE = 80, ACID = 200)

/obj/item/clothing/suit/space/hardsuit/vox/scout
	name = "vox raider scout hardsuit"
	desc = "A specialized protective spacesuit for vox raiders. Its synthetic material allows operation in hostile environments, making it highly versatile. Its different construction offers less protection than mercenary armor.\nThis scout suit leaves movement unrestricted and helps its wearer maneuver comfortably in zero gravity."
	icon_state = "vox-raider-scout"
	item_color = "vox-raider-scout"
	armor = list(MELEE = 10, BULLET = 20, LASER = 30, ENERGY = 30, BOMB = 15, FIRE = 80, ACID = 200)
	strip_delay = 6 SECONDS
	put_on_delay = 4 SECONDS
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/vox/scout
	slowdown = -0.25

/obj/item/clothing/head/helmet/space/hardsuit/vox/scout
	name = "vox raider scout helmet"
	icon_state = "vox-raider-scout"
	item_color = "vox-raider-scout"
	armor = list(MELEE = 10, BULLET = 20, LASER = 30, ENERGY = 30, BOMB = 15, FIRE = 80, ACID = 200)

/obj/item/clothing/suit/space/hardsuit/vox/medic
	name = "vox raider medic hardsuit"
	desc = "A specialized protective spacesuit for vox raiders. Its synthetic material allows operation in hostile environments, making it highly versatile. Its different construction offers less protection than mercenary armor.\nA mobile suit for working away from direct danger, with reasonable protection against various projectiles. Its construction can injure the wearer during explosions or piercing attacks. Highly resistant to radiation, acids and biological hazards. Includes storage for medical kits and chemical containers."
	icon_state = "vox-raider-medic"
	item_color = "vox-raider-medic"
	armor = list(MELEE = -30, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = -30, FIRE = 120, ACID = INFINITY)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/vox/medic
	allowed = list(
		/obj/item/flashlight,
		/obj/item/storage/firstaid,
		/obj/item/gun,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/restraints/handcuffs,
		/obj/item/tank/internals,
		/obj/item/analyzer,
		/obj/item/stack/medical,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/applicator,
		/obj/item/healthanalyzer,
		/obj/item/flashlight/pen,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/food/pill,
		/obj/item/storage/pill_bottle,
		/obj/item/paper,
		/obj/item/robotanalyzer,
	)

/obj/item/clothing/head/helmet/space/hardsuit/vox/medic
	name = "vox raider medic helmet"
	icon_state = "vox-raider-medic"
	item_color = "vox-raider-medic"
	armor = list(MELEE = -30, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = -30, FIRE = 120, ACID = INFINITY)

/obj/item/clothing/suit/space/hardsuit/vox/mechanic
	name = "vox raider mechanic hardsuit"
	desc = "A specialized protective spacesuit for vox raiders. Its synthetic material allows operation in hostile environments, making it highly versatile. Its different construction offers less protection than mercenary armor.\nDesigned for extremely dangerous atmospheres. Its construction and heat-dissipation technology provide good protection against energy weapons."
	icon_state = "vox-raider-mechanic"
	item_color = "vox-raider-mechanic"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	armor = list(MELEE = 20, BULLET = 20, LASER = 75, ENERGY = 50, BOMB = 150, FIRE = INFINITY, ACID = INFINITY)
	slowdown = 2
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/vox/mechanic
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/t_scanner,
		/obj/item/rcd,
		/obj/item/rpd,
		/obj/item/gun,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/restraints/handcuffs,
		/obj/item/tank/internals,
	)

/obj/item/clothing/head/helmet/space/hardsuit/vox/mechanic
	name = "vox raider mechanic helmet"
	icon_state = "vox-raider-mechanic"
	item_color = "vox-raider-mechanic"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	armor = list(MELEE = 20, BULLET = 20, LASER = 75, ENERGY = 50, BOMB = 150, FIRE = INFINITY, ACID = INFINITY)

/obj/item/clothing/suit/space/hardsuit/vox/heavy
	name = "vox raider heavy hardsuit"
	desc = "A specialized protective spacesuit for vox raiders. Its synthetic material allows operation in hostile environments, making it highly versatile. Its different construction offers less protection than mercenary armor.\nHeavy, fireproof and blast-resistant armor with excellent protection against energy weapons, piercing and slashing attacks, and reasonable protection against firearms. Designed to confront mechanized forces in space. Its weight and imperfect actuators reduce movement speed."
	icon_state = "vox-raider-heavy"
	item_color = "vox-raider-heavy"
	w_class = WEIGHT_CLASS_HUGE
	armor = list(MELEE = 115, BULLET = 80, LASER = 150, ENERGY = 80, BOMB = 200, FIRE = INFINITY, ACID = INFINITY)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slowdown = 3	// Даже черепаха быстрее чем это ведро.
	strip_delay = 20 SECONDS
	put_on_delay = 10 SECONDS
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/vox/heavy

/obj/item/clothing/head/helmet/space/hardsuit/vox/heavy
	name = "vox raider heavy helmet"
	icon_state = "vox-raider-heavy"
	item_color = "vox-raider-heavy"
	armor = list(MELEE = 115, BULLET = 80, LASER = 115, ENERGY = 80, BOMB = 200, FIRE = INFINITY, ACID = INFINITY)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
