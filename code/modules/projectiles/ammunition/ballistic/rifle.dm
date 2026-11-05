// MARK: 7.62x54mm
/obj/item/ammo_casing/a762x54
	ammo_marking = "7.62x54 mm"
	icon_state = "762-casing"
	materials = list(MAT_METAL = 4000)
	caliber = CALIBER_7_DOT_62X54MM
	projectile_type = /obj/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/a762x54/enchanted
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/bullet/weakbullet3

// MARK: 7.62x51mm
/obj/item/ammo_casing/a762x51
	ammo_marking = "7.62x51 mm"
	icon_state = "762-casing"
	caliber = CALIBER_7_DOT_62X51MM
	projectile_type = /obj/projectile/bullet/saw
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

// TODO: replace it with /obj/item/ammo_casing/a762x51
/obj/item/ammo_casing/a762x51/weak
	projectile_type = /obj/projectile/bullet/saw/weak

/obj/item/ammo_casing/a762x51/bleeding
	ammo_marking = "7.62x51 mm \"Bleeder\""
	extra_info = "A specialized round that releases tiny fragments on impact to cause internal bleeding."
	projectile_type = /obj/projectile/bullet/saw/bleeding

/obj/item/ammo_casing/a762x51/hollow
	ammo_marking = "7.62x51 mm HP"
	extra_info = "A hollow-point bullet with increased wounding potential at the expense of penetration."
	projectile_type = /obj/projectile/bullet/saw/hollow

/obj/item/ammo_casing/a762x51/ap
	ammo_marking = "7.62x51 mm AP"
	extra_info = "An armor-piercing bullet with increased penetration at the expense of stopping power."
	projectile_type = /obj/projectile/bullet/saw/ap

/obj/item/ammo_casing/a762x51/incen
	ammo_marking = "7.62x51 mm Incendiary"
	extra_info = "An incendiary bullet that ignites on impact."
	projectile_type = /obj/projectile/bullet/saw/incen
	muzzle_flash_color = LIGHT_COLOR_FIRE

// MARK: .50
// MAKE IT /point50 TYPE PLEASE
/obj/item/ammo_casing/point50
	ammo_marking = ".50"
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	icon_state = ".50"

/obj/item/ammo_casing/soporific
	ammo_marking = ".50 \"Soporific\""
	extra_info = "A specialized round filled with a sedative. Puts the target to sleep on impact without inflicting damage."
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper/soporific
	icon_state = ".50sop"
	harmful = FALSE

/obj/item/ammo_casing/explosive
	ammo_marking = ".50 \"Explosive\""
	extra_info = "A specialized round filled with explosives. Explodes on impact."
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper/explosive
	icon_state = ".50exp"

/obj/item/ammo_casing/haemorrhage
	ammo_marking = ".50 \"Bleeder\""
	extra_info = "A specialized round that releases tiny fragments on impact to cause internal bleeding."
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper/haemorrhage
	icon_state = ".50exp"

/obj/item/ammo_casing/penetrator
	ammo_marking = ".50 AP"
	extra_info = "An armor-piercing bullet with increased penetration at the expense of stopping power."
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper/penetrator
	icon_state = ".50pen"

// MARK: .50L
/obj/item/ammo_casing/compact
	ammo_marking = ".50 L"
	extra_info = "A lighter version of the .50 round."
	caliber = CALIBER_DOT_50L
	projectile_type = /obj/projectile/bullet/sniper/compact
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	icon_state = ".50"

/obj/item/ammo_casing/compact/penetrator
	ammo_marking = ".50 L AP"
	extra_info = "A lighter version of the .50 AP round. Its armor-piercing bullet has increased penetration at the expense of stopping power."
	projectile_type = /obj/projectile/bullet/sniper/penetrator
	icon_state = ".50pen"

/obj/item/ammo_casing/compact/soporific
	ammo_marking = ".50 L \"Soporific\""
	extra_info = "A lighter version of the .50 Soporific round. Filled with a sedative that puts the target to sleep on impact without inflicting damage."
	projectile_type = /obj/projectile/bullet/sniper/soporific
	icon_state = ".50sop"
	harmful = FALSE

// MARK: .338
/obj/item/ammo_casing/a338
	ammo_marking = ".338"
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/a338
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	icon_state = ".50"

/obj/item/ammo_casing/a338_soporific
	ammo_marking = ".338 \"Soporific\""
	extra_info = "A specialized round filled with a sedative. Puts the target to sleep on impact without inflicting damage."
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/soporific/a338
	icon_state = ".50sop"
	harmful = FALSE

/obj/item/ammo_casing/a338_explosive
	ammo_marking = ".338 \"Explosive\""
	extra_info = "A specialized round filled with explosives. Explodes on impact."
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/explosive/a338
	icon_state = ".50exp"

/obj/item/ammo_casing/a338_haemorrhage
	ammo_marking = ".338 \"Bleeder\""
	extra_info = "A specialized round that releases tiny fragments on impact to cause internal bleeding."
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/haemorrhage/a338
	icon_state = ".50exp"

/obj/item/ammo_casing/a338_penetrator
	ammo_marking = ".338 AP"
	extra_info = "An armor-piercing bullet with increased penetration at the expense of stopping power."
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/penetrator/a338
	icon_state = ".50pen"
