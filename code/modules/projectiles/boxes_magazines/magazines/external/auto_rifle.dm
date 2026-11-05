// MARK: 5.56x45mm - AR-30
/obj/item/ammo_box/magazine/m556
	gun_name = "AR-30 rifles"
	extra_info = "Compatible with a wide range of AR-30 platform weapons."
	icon_state = "5.56m"
	origin_tech = "combat=5"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = CALIBER_5_DOT_56X45MM
	max_ammo = 30
	multiple_sprites = 2

// MARK: 5.45x39mm - AK-814
/obj/item/ammo_box/magazine/ak814
	gun_name = "AG-814 assault rifles"
	icon_state = "ak814"
	origin_tech = "combat=5;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545
	caliber = CALIBER_5_DOT_45X39MM
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/ak814/fusty
	ammo_type = /obj/item/ammo_casing/a545/fusty

/obj/item/ammo_box/magazine/ak814/fusty/empty
	start_empty = TRUE

// MARK: 5.45x39mm - AGS-74U
/obj/item/ammo_box/magazine/aks74u
	gun_name = "AGS-74U assault rifles"
	icon_state = "ak47mag"
	origin_tech = "combat=4;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545/fusty
	caliber = CALIBER_5_DOT_45X39MM
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/aksu/empty
	start_empty = TRUE

// MARK: 7.62x51mm - SGM-BR52
/obj/item/ammo_box/magazine/m52mag
	gun_name = "SGM-BR52 battle rifles"
	icon_state = "m52_ammo"
	ammo_type = /obj/item/ammo_casing/a762x51
	caliber = CALIBER_7_DOT_62X51MM
	max_ammo = 24
	multiple_sprites = 2

// MARK: Laser - IK-60
/obj/item/ammo_box/magazine/ik60mag
	gun_name = "IK-60 laser rifles"
	icon_state = "laser"
	ammo_type = /obj/item/ammo_casing/laser
	caliber = CALIBER_LASER
	max_ammo = 20

/obj/item/ammo_box/magazine/ik60mag/update_icon_state()
	icon_state = "[initial(icon_state)]-[ceil(ammo_count(FALSE)/20)*20]"

/obj/item/ammo_box/magazine/ik60mag/empty
	start_empty = TRUE

// MARK: Laser - LR-30
/obj/item/ammo_box/magazine/lr30mag
	gun_name = "LR-30 laser rifles"
	icon_state = "lmag"
	ammo_type = /obj/item/ammo_casing/laser
	caliber = CALIBER_LASER
	max_ammo = 12

/obj/item/ammo_box/magazine/lr30mag/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/lr30mag/update_icon_state()
	icon_state = "lmag-[CEILING(ammo_count(), 3)]"
