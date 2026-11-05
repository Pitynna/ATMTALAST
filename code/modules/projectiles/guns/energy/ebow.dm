// MARK: Basic (Mini)
/obj/item/gun/energy/kinetic_accelerator/crossbow
	name = "mini energy crossbow"
	desc = "A weapon favored by syndicate stealth specialists. Knocks down and injects toxins."
	icon_state = "crossbow"
	item_state = "crossbow"
	w_class = WEIGHT_CLASS_SMALL
	weapon_weight = WEAPON_LIGHT
	materials = list(MAT_METAL=2000)
	origin_tech = "combat=4;magnets=4;syndicate=4"
	suppressed = 1
	ammo_type = list(/obj/item/ammo_casing/energy/bolt)
	unique_rename = 0
	overheat_time = 20
	holds_charge = TRUE
	unique_frequency = TRUE
	max_mod_capacity = 0
	empty_state = null
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/energy/kinetic_accelerator/crossbow/old
	name = "old mini energy crossbow"
	desc = "A weapon favored by syndicate stealth specialists. It looks very old."
	accuracy = new /datum/gun_accuracy/minimal/old()

// MARK: Large
/obj/item/gun/energy/kinetic_accelerator/crossbow/large
	name = "energy crossbow"
	desc = "A reverse engineered weapon using syndicate technology."
	icon_state = "crossbowlarge"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=4000)
	origin_tech = "combat=4;magnets=4;syndicate=3"
	suppressed = 0
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/large)
	accuracy = GUN_ACCURACY_RIFLE

/obj/item/gun/energy/kinetic_accelerator/crossbow/large/cyborg
	desc = "One and done!"
	origin_tech = null
	materials = list()
	accuracy = GUN_ACCURACY_RIFLE

// MARK: Toy
/obj/item/gun/energy/kinetic_accelerator/crossbow/toy
	name = "toy energy crossbow"
	desc = "A toy weapon made from a laser tag pistol, styled after a contraband crossbow."
	icon_state = "crossbowtoy"
	materials = list(MAT_METAL=4000)
	origin_tech = "combat=4;magnets=4"
	suppressed = 0
	overheat_time = 8 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/bolttoy)
	accuracy = GUN_ACCURACY_DEFAULT
