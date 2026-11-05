// MARK: Base Pistol
/obj/item/gun/projectile/automatic/pistol
	abstract_type = /obj/item/gun/projectile/automatic/pistol
	gender = MALE
	icon = 'icons/obj/weapons/pistols.dmi'
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	weapon_weight = WEAPON_LIGHT
	origin_tech = "combat=3;materials=2;syndicate=3"
	can_holster = TRUE
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_LOW
	origin_tech = "combat=3;materials=2"
	magin_sound = 'sound/weapons/gun_interactions/pistol_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/pistol_magout.ogg'
	burst_amount = 1
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_PISTOL_UNDER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	fire_delay = 0.4 SECONDS
	/// Magazine icon (if exists on pistol, null for disable this feature)
	var/magazine_icon = "pistol_mag"

/obj/item/gun/projectile/automatic/pistol/update_icon_state()
	if(current_skin)
		icon_state = "[current_skin][chambered ? "" : "-e"]"
	else
		icon_state = "[base_icon_state][chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/pistol/update_overlays()
	. = ..()
	if(!magazine_icon || !magazine)
		return
	. += mutable_appearance(initial(icon), magazine_icon, layer = FLOAT_LAYER - 0.01)

// MARK: DCA-P9 Enforcer
/obj/item/gun/projectile/automatic/pistol/enforcer
	name = "DCA-P9 \"Enforcer\" pistol"
	desc = "A 9mm sidearm commonly used by Nanotrasen Asset Protection."
	icon_state = "enforcer_grey"
	force = 10
	mag_type = /obj/item/ammo_box/magazine/enforcer
	fire_sound = 'sound/weapons/gunshots/1colt.ogg'
	accuracy = GUN_ACCURACY_PISTOL_ENFORCER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 18, ATTACHMENT_OFFSET_Y = 4),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = -2, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -3),
	)
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=4;materials=2"
	magazine_icon = "enforcer_mag"

/obj/item/gun/projectile/automatic/pistol/enforcer/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Лёгкий пистолет под стандартный калибр 9x19 мм. Разработан компанией \"Donk Co. Arms\" в рамках \
		открытого тендера на оснащение корпоративных служб безопасности. <br>\
		<br>\
		Конструкция сочетает в себе проверенные технологические решения с современными материалами: полимерная рамка \
		со стальными вкладышами, укороченный ход затвора для снижения отдачи, модульные направляющие для использования \
		тактических приспособлений.<br>\
		<br>\
		В 2556 году \"Нанотрейзен\" заключила долгосрочный контракт с \"Donk Co. Arms\" на массовую поставку \
		DCA-P9 в целях замены разрозненных моделей пистолетов, использовавшихся силами корпорации. \
		В настоящее время \"Блюстители\" остаются основным штатным оружием сотрудников службы безопасности \"Нанотрейзен\", \
		повсеместно встречаясь даже на самых удалённых объектах корпорации."\
	)

/obj/item/gun/projectile/automatic/pistol/enforcer/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins, item_path = /obj/item/gun/projectile/automatic/pistol/enforcer)

/obj/item/gun/projectile/automatic/pistol/enforcer/lethal
	mag_type = /obj/item/ammo_box/magazine/enforcer/lethal

// MARK: P-40 Acer
/obj/item/gun/projectile/automatic/pistol/sp8
	name = "P-40 \"Acer\" pistol"
	desc = "A .40 N&R assault pistol manufactured by Mars Special. Highly accurate, with low recoil and a reinforced barrel for high-power ammunition. Used by elite Nanotrasen Asset Protection units."
	greyscale_config = /datum/greyscale_config/sp8
	greyscale_colors = COLOR_ALMOST_BLACK
	icon_state = "/obj/item/gun/projectile/automatic/pistol/sp8"
	base_icon_state = "sp8"
	post_init_icon_state = "sp8" // thanks split
	force = 10
	mag_type = /obj/item/ammo_box/magazine/sp8
	magazine_icon = "sp8_mag"
	fire_sound = 'sound/weapons/gunshots/sp8.ogg'
	origin_tech = "combat=5;materials=2"
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 18, ATTACHMENT_OFFSET_Y = 4),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = -4),
	)

/obj/item/gun/projectile/automatic/pistol/sp8/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins)

// MARK: Stechkin
/obj/item/gun/projectile/automatic/pistol/stechkin
	name = "Stechkin pistol"
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	origin_tech = "combat=3;materials=2;syndicate=3"
	fire_sound = 'sound/weapons/gunshots/1stechkin.ogg'
	accuracy = GUN_ACCURACY_PISTOL_STECHKIN
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_PISTOL_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 16, ATTACHMENT_OFFSET_Y = 3),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 1, ATTACHMENT_OFFSET_Y = 7),
	)

/obj/item/gun/projectile/automatic/pistol/deagle
	name = "SGM-P50 \"Colossus\""
	desc = "A robust .50 AE handgun."
	icon_state = "deagle"
	force = 14.0
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m50
	magazine_icon = "deagle_mag"
	fire_sound = 'sound/weapons/gunshots/1deagle.ogg'
	magin_sound = 'sound/weapons/gun_interactions/hpistol_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/hpistol_magout.ogg'
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 20, ATTACHMENT_OFFSET_Y = 4),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = -2),
	)
	accuracy = GUN_ACCURACY_PISTOL_UPLINK
	recoil = GUN_RECOIL_HIGH

/obj/item/gun/projectile/automatic/pistol/deagle/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins)

// MARK: APS Pistol
/obj/item/gun/projectile/automatic/pistol/aps
	name = "APS pistol"
	desc = "The original russian version of a widely used Syndicate sidearm. Uses 9mm ammo."
	icon_state = "aps"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/pistolm9mm
	burst_amount = 3
	accuracy = GUN_ACCURACY_PISTOL_UPLINK
	recoil = GUN_RECOIL_MEDIUM
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_PISTOL_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 18, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 3, ATTACHMENT_OFFSET_Y = 8),
	)
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC)
	magazine_icon = "aps_mag"

/obj/item/gun/projectile/automatic/pistol/aps/scarecrow
	name = "\"Scarecrow\" pistol"
	desc = "A 10x25mm automatic pistol nicknamed Scarecrow for its loud, rapid crowd-dispersing gunfire. In reality, a cheap product made from poor components: grouping worsens with every shot, and stopping power is unimpressive. Uses Stechkin pistol magazines."
	icon_state = "scarecrow"
	fire_sound = 'sound/weapons/gunshots/1scarecrow.ogg'
	magin_sound = 'sound/weapons/gun_interactions/scarecrowmagin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/scarecrowmagout.ogg'
	origin_tech = "combat=3;materials=2;syndicate=1"
	magazine_icon = "pistol_mag"
	damage_mod = 0.5
	mag_type = /obj/item/ammo_box/magazine/m10mm
	accuracy = GUN_ACCURACY_PISTOL_UPLINK_SCARECROW
	burst_amount = 4
	fire_delay = 0.15 SECONDS
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 15, ATTACHMENT_OFFSET_Y = 3),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 3, ATTACHMENT_OFFSET_Y = 7),
	)

/obj/item/gun/projectile/automatic/pistol/m1911
	name = "M1911"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "m1911"
	mag_type = /obj/item/ammo_box/magazine/m45
	magazine_icon = "m1911_mag"
	fire_sound = 'sound/weapons/gunshots/1colt.ogg'
	accuracy = GUN_ACCURACY_PISTOL_UPLINK
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_PISTOL_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 21, ATTACHMENT_OFFSET_Y = 6),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 9),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -1),
	)
