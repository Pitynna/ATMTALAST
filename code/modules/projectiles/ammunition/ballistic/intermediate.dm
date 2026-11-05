// MARK: 5.56x45mm
/obj/item/ammo_casing/a556
	ammo_marking = "5.56x45 mm"
	materials = list(MAT_METAL = 3250)
	caliber = CALIBER_5_DOT_56X45MM
	projectile_type = /obj/projectile/bullet/heavybullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

// MARK: 5.45x39mm
/obj/item/ammo_casing/a545
	ammo_marking = "5.45x39 mm"
	caliber = CALIBER_5_DOT_45X39MM
	projectile_type = /obj/projectile/bullet/midbullet3
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/a545/fusty
	extra_info = "Covered in rust."
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/bullet/f545
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG

// MARK: 4.6x30mm
/obj/item/ammo_casing/c46x30mm
	ammo_marking = "4.6x30 mm"
	materials = list(MAT_METAL = 580)
	caliber = CALIBER_4_DOT_6X30MM
	projectile_type = /obj/projectile/bullet/weakbullet3/foursix
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/c46x30mm/ap
	ammo_marking = "4.6x30 mm AP"
	extra_info = "An armor-piercing bullet with increased penetration at the expense of stopping power."
	materials = list(MAT_METAL = 700, MAT_SILVER = 50)
	projectile_type = /obj/projectile/bullet/weakbullet3/foursix/ap

/obj/item/ammo_casing/c46x30mm/tox
	ammo_marking = "4.6x30 mm \"Toxin\""
	extra_info = "A toxic bullet containing a poisonous substance that poisons the target on impact."
	materials = list(MAT_METAL = 700, MAT_SILVER = 50, MAT_URANIUM = 75)
	projectile_type = /obj/projectile/bullet/weakbullet3/foursix/tox

/obj/item/ammo_casing/c46x30mm/inc
	ammo_marking = "4.6x30 mm Incendiary"
	extra_info = "An incendiary bullet that ignites on impact."
	materials = list(MAT_METAL = 700, MAT_SILVER = 50, MAT_PLASMA = 50)
	projectile_type = /obj/projectile/bullet/incendiary/foursix
	muzzle_flash_color = LIGHT_COLOR_FIRE
