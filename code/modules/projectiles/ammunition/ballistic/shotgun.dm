// MARK: Slug
/obj/item/ammo_casing/shotgun
	ammo_marking = "12g \"Slug\""
	extra_info = "A brass slug for a smoothbore shotgun."
	icon_state = "slugshell"
	materials = list(MAT_METAL = 4000)
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	caliber = CALIBER_12G
	projectile_type = /obj/projectile/bullet/slug
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

// MARK: Buckshot
/obj/item/ammo_casing/shotgun/buckshot
	ammo_marking = "12g \"Buckshot\""
	extra_info = "Scatters numerous pellets when fired."
	icon_state = "buckshotshell"
	projectile_type = /obj/projectile/bullet/pellet
	pellets = 6
	variance = 17

/obj/item/ammo_casing/shotgun/buckshot/magnum
	ammo_marking = "12g \"Magnum\""
	extra_info = "High-powered buckshot. Scatters numerous pellets when fired."
	projectile_type = /obj/projectile/bullet/pellet/magnum

// MARK: Assasination slug
/obj/item/ammo_casing/shotgun/assassination
	ammo_marking = "12g \"Silencer\""
	extra_info = "Specialized buckshot treated with a muting toxin."
	materials = list(MAT_METAL = 1500, MAT_GLASS = 200)
	projectile_type = /obj/projectile/bullet/pellet/assassination
	muzzle_flash_effect = null
	icon_state = "buckshotshell"
	pellets = 6
	variance = 15

// MARK: Rubbershot
/obj/item/ammo_casing/shotgun/rubbershot
	ammo_marking = "12g \"Rubber Buckshot\""
	extra_info = "Filled with rubber pellets. Has high stopping power without inflicting lethal wounds on impact."
	icon_state = "rubbershotshell"
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/bullet/pellet/rubber
	pellets = 6
	variance = 17

// MARK: Chemical dart
/obj/item/ammo_casing/shotgun/dart
	ammo_marking = "12g \"Dart\""
	extra_info = "A dart-like slug with a chemical reservoir. Holds up to 30 units of reagent."
	icon_state = "rubbershotshell"
	container_type = OPENCONTAINER
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	projectile_type = /obj/projectile/bullet/dart
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	can_be_box_inserted = FALSE

/obj/item/ammo_casing/shotgun/dart/Initialize(mapload)
	. = ..()
	create_reagents(30)

// MARK: Beanbag
/obj/item/ammo_casing/shotgun/beanbag
	ammo_marking = "12g \"Beanbag\""
	extra_info = "A solid rubber slug. Has high stopping power without inflicting lethal wounds on impact."
	icon_state = "beanbagshell"
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/bullet/weakbullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/shotgun/beanbag/fake
	projectile_type = /obj/projectile/bullet/weakbullet/booze

// MARK: Taser slug
/obj/item/ammo_casing/shotgun/stunslug
	ammo_marking = "12g \"Taser\""
	extra_info = "Stuns the target with an electric shock on impact."
	icon_state = "stunslugshell"
	materials = list(MAT_METAL = 250)
	projectile_type = /obj/projectile/bullet/stunshot
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = "#FFFF00"

// MARK: Meteorshot
/obj/item/ammo_casing/shotgun/meteorshot
	ammo_marking = "12g \"Meteor\""
	extra_info = "Launches a meteor using bluespace technology."
	icon_state = "meteorshotshell"
	projectile_type = /obj/projectile/bullet/meteorshot

// MARK: Breaching
/obj/item/ammo_casing/shotgun/breaching
	ammo_marking = "12g \"Penetrator\""
	extra_info = "Launches a meteor using bluespace technology. A specialized version with reduced momentum."
	icon_state = "meteorshotshell"
	projectile_type = /obj/projectile/bullet/meteorshot/weak

// MARK: Pulse slug
/obj/item/ammo_casing/shotgun/pulseslug
	ammo_marking = "12g \"Pulse\""
	extra_info = "A specialized slug that launches a pulse charge when fired."
	icon_state = "pulseslugshell"
	projectile_type = /obj/projectile/beam/pulse/shot
	muzzle_flash_color = LIGHT_COLOR_DARK_BLUE

// MARK: Incendiary slug
/obj/item/ammo_casing/shotgun/incendiary
	ammo_marking = "12g \"Incendiary\""
	extra_info = "The slug ignites on impact."
	icon_state = "incendiaryshell"
	projectile_type = /obj/projectile/bullet/incendiary/shell
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath
	ammo_marking = "12g \"Dragon's Breath\""
	extra_info = "Filled with pyrotechnic pellets that ignite when fired."
	icon_state = "dragonsbreathshell"
	projectile_type = /obj/projectile/bullet/incendiary/shell/dragonsbreath
	pellets = 4
	variance = 25

/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/napalm
	ammo_marking = "12g \"Napalm\""
	extra_info = "Filled with napalm pellets that ignite when fired."
	projectile_type = /obj/projectile/bullet/incendiary/shell/dragonsbreath/napalm
	pellets = 6
	variance = 20

// MARK: Frag-12
/obj/item/ammo_casing/shotgun/frag12
	ammo_marking = "12g \"FRAG-12\""
	extra_info = "A specialized round filled with explosives. Explodes on impact."
	icon_state = "frag12shell"
	projectile_type = /obj/projectile/bullet/frag12

// MARK: Ion
/obj/item/ammo_casing/shotgun/ion
	ammo_marking = "12g \"Ion\""
	extra_info = "A specialized round that creates an EMP on impact."
	icon_state = "ionshell"
	projectile_type = /obj/projectile/ion/weak
	pellets = 4
	variance = 35
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = LIGHT_COLOR_BLUE

// MARK: Laser slug
/obj/item/ammo_casing/shotgun/laserslug
	ammo_marking = "12g \"Laser\""
	extra_info = "A specialized round with a microlaser that simulates a laser weapon."
	icon_state = "laserslugshell"
	projectile_type = /obj/projectile/beam/laser/slug
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = COLOR_SOFT_RED

// MARK: Laser buckshot
/obj/item/ammo_casing/shotgun/lasershot
	ammo_marking = "12g \"Laser Buckshot\""
	extra_info = "A specialized round with an array of microlasers that simulates buckshot using lasers."
	icon_state = "lasershotshell"
	projectile_type = /obj/projectile/beam/laser/shot
	pellets = 6
	variance = 17
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = COLOR_SOFT_RED

// MARK: Bioterror
/obj/item/ammo_casing/shotgun/bioterror
	ammo_marking = "12g \"Bioterror\""
	extra_info = "Filled with pellets containing lethal toxins that poison the target on impact."
	icon_state = "bioterrorshell"
	projectile_type = /obj/projectile/bullet/pellet/bioterror
	pellets = 4
	variance = 17

// MARK: Tranquilizer
/obj/item/ammo_casing/shotgun/tranquilizer
	ammo_marking = "12g \"Tranquilizer\""
	extra_info = "A specialized dart round containing a sedative."
	icon_state = "tranquilizershell"
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	projectile_type = /obj/projectile/bullet/dart/syringe/tranquilizer
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

// MARK: Flechette
/obj/item/ammo_casing/shotgun/flechette
	ammo_marking = "12g \"Flechette\""
	extra_info = "A shotgun shell filled with tiny steel darts for piercing armor."
	icon_state = "flechetteshell"
	projectile_type = /obj/projectile/bullet/pellet/flechette
	pellets = 4
	variance = 13

// MARK: Improvised buckshot
/obj/item/ammo_casing/shotgun/improvised
	ammo_marking = "12g \"Improvised\""
	extra_info = "An improvised shell filled with numerous metal pellets and a small amount of gunpowder."
	icon_state = "improvisedshell"
	materials = list(MAT_METAL = 250)
	projectile_type = /obj/projectile/bullet/pellet/weak
	pellets = 10
	variance = 20
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/shotgun/improvised/overload
	ammo_marking = "12g \"Improvised+\""
	extra_info = "An improvised shell filled with large metal pellets and too much gunpowder. Extremely unstable."
	projectile_type = /obj/projectile/bullet/pellet/overload
	pellets = 4
	variance = 40
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

// MARK: Empty tech shell
/obj/item/ammo_casing/shotgun/techshell
	name = "unloaded technological shell"
	desc = "An empty 12 gauge shell, ready to be loaded with all manner of projectiles."
	ammo_marking = null
	extra_info = null
	icon_state = "techshell"
	materials = list(MAT_METAL = 1000, MAT_GLASS = 200)
	projectile_type = null
	no_update_names = TRUE
	no_update_desc = TRUE
