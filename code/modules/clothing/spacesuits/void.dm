//Voidsuits

/obj/item/clothing/head/helmet/space/nasavoid
	name = "CAGI 10 helmet"
	desc = "A high tech, NASA Centcom branch designed space suit helmet. Used for AI satellite maintenance."
	icon_state = "void_red"
	item_state = "void_red_helmet"
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME
	armor = list(MELEE = 30, BULLET = 15, LASER = 15, ENERGY = 30, BOMB = 30, BIO = 100, FIRE = 75, ACID = 75)
	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/head.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi')

/obj/item/clothing/suit/space/nasavoid
	name = "CAGI 10 spacesuit"
	desc = "A high tech, NASA Centcom branch designed space suit. Used for AI satellite maintenance."
	icon_state = "void_red"
	item_state = "void_red"
	armor = list(MELEE = 30, BULLET = 15, LASER = 15, ENERGY = 30, BOMB = 30, BIO = 100, FIRE = 75, ACID = 75)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool, /obj/item/radio)
	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/head.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi')

/obj/item/clothing/head/helmet/space/nasavoid/old
	name = "NASA engineering helmet"
	desc = "A CentCom engineering dark red space suit helmet. While old and dusty, it still gets the job done."
	flash_protect = FLASH_PROTECTION_FLASH
	armor = list(MELEE = 50, BULLET = 25, LASER = 25, ENERGY = 50, BOMB = 75, BIO = 100, FIRE = 100, ACID = 75)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/nasavoid/old
	name = "NASA engineering spacesuit"
	desc = "A CentCom engineering dark red space suit. Age has degraded the suit making is difficult to move around in."
	slowdown = 4
	allowed = list(/obj/item/storage/toolbox, /obj/item/t_scanner, /obj/item/rcd, /obj/item/crowbar, /obj/item/screwdriver, /obj/item/weldingtool, /obj/item/wirecutters, /obj/item/wrench, /obj/item/multitool, /obj/item/analyzer, /obj/item/pipe_painter, /obj/item/rpd, /obj/item/storage/part_replacer, /obj/item/storage/bag/construction, /obj/item/storage/bag/sheetsnatcher, /obj/item/extinguisher, /obj/item/stack/cable_coil)
	armor = list(MELEE = 50, BULLET = 25, LASER = 25, ENERGY = 50, BOMB = 75, BIO = 100, FIRE = 100, ACID = 75)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/helmet/space/nasavoid/green
	name = "SC CAGI 9 Helmet"
	desc = "An assault pressure helmet for a combat spacesuit. A titanium sphere with multilayer ballistic glazing and a composite-reinforced articulated neck seal. Manufactured by the TSF."
	icon_state = "void_green"
	armor = list(MELEE = 40, BULLET = 60, LASER = 40, ENERGY = 15, BOMB = 50, BIO = 100, FIRE = 30, ACID = 15)
	item_state = "void_green_helmet"

/obj/item/clothing/suit/space/nasavoid/green
	name = "SC CAGI 9 spacesuit"
	desc = "A heavily armored assault pressure suit with integrated titanium segments and composite-reinforced joints. Manufactured by the TSF."
	icon_state = "void_green"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/shield, /obj/item/grenade)
	armor = list(MELEE = 40, BULLET = 60, LASER = 40, ENERGY = 15, BOMB = 50, BIO = 100, FIRE = 30, ACID = 15)
	slowdown = 4
	item_state = "void_green"

/obj/item/clothing/head/helmet/space/nasavoid/ntblue
	name = "NASA helmet for VIPs"
	desc = "A standard premium-class helmet for command personnel and VIPs. Combines corporate style with practicality and comfort. Lightweight and easy on the neck. Developed by NASA."
	icon_state = "void_ntblue"
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 20, BIO = 100, FIRE = 50, ACID = 50)
	item_state = "void_ntblue_helmet"

/obj/item/clothing/suit/space/nasavoid/ntblue
	name = "NASA spacesuit for VIPs"
	desc = "A standard premium-class spacesuit for command personnel and VIPs. Combines corporate style with practicality and comfort. Lightweight, unrestricted and compact when folded. Developed by NASA."
	icon_state = "void_ntblue"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/storage/briefcase, /obj/item/pda, /obj/item/paicard, /obj/item/aicard, /obj/item/ai_module, /obj/item/reagent_containers/cup/glass/flask, /obj/item/storage/lockbox, /obj/item/megaphone, /obj/item/folder, /obj/item/card, /obj/item/camera, /obj/item/melee/baton)
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 20, BIO = 100, FIRE = 50, ACID = 50)
	item_state = "void_ntblue"

/obj/item/clothing/head/helmet/space/nasavoid/purple
	name = "NASA RnD helmet"
	desc = "A specialized exploration helmet for extreme conditions. A modified bomb-disposal helmet optimized for space operations. Developed by NASA."
	icon_state = "void_purple"
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 30, BOMB = 95, BIO = 100, FIRE = 85, ACID = 85)
	item_state = "void_purple_helmet"

/obj/item/clothing/suit/space/nasavoid/purple
	name = "NASA RnD spacesuit"
	desc = "A specialized exploration spacesuit for extreme conditions. A modified bomb-disposal suit optimized for space operations. Developed by NASA."
	icon_state = "void_purple"
	allowed = list(/obj/item/storage/part_replacer, /obj/item/robot_module, /obj/item/robotanalyzer, /obj/item/storage/toolbox, /obj/item/circuitboard, /obj/item/assembly/signaler, /obj/item/gps)
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 30, BOMB = 95, BIO = 100, FIRE = 85, ACID = 85)
	slowdown = 2
	item_state = "void_purple"

/obj/item/clothing/head/helmet/space/nasavoid/yellow
	name = "NASA mining helmet"
	desc = "A rugged pressure helmet for a mining exosuit, reinforced for hostile environments. Developed by NASA."
	icon_state = "void_yellow"
	armor = list(MELEE = 60, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 75, BIO = 100, FIRE = 75, ACID = 75)
	item_state = "void_yellow_helmet"

/obj/item/clothing/suit/space/nasavoid/yellow
	name = "NASA mining spacesuit"
	desc = "A hybrid spacesuit for mining in space. Reinforced for hostile environments and fitted with a medium-class industrial exoskeleton. Developed by NASA."
	icon_state = "void_yellow"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe, /obj/item/shovel)
	armor = list(MELEE = 60, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 75, BIO = 100, FIRE = 75, ACID = 75)
	slowdown = 4
	item_state = "void_yellow"

/obj/item/clothing/head/helmet/space/nasavoid/ltblue
	name = "NASA medical helmet"
	desc = "A specialized lightweight pressure helmet for medical personnel, protecting against biological and chemical contamination. Developed by the Red Cross Foundation and NASA."
	icon_state = "void_light_blue"
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 100, FIRE = 50, ACID = 100)
	item_state = "void_light_blue_helmet"

/obj/item/clothing/suit/space/nasavoid/ltblue
	name = "NASA medical spacesuit"
	desc = "A specialized lightweight spacesuit for medical personnel, protecting against biological and chemical contamination. Can accommodate a defibrillator. Developed by the Red Cross Foundation and NASA."
	icon_state = "void_light_blue"
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals,/obj/item/storage/firstaid,/obj/item/healthanalyzer,/obj/item/stack/medical,/obj/item/rad_laser)
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 100, FIRE = 50, ACID = 100)
	item_state = "void_light_blue"

/obj/item/clothing/head/helmet/space/nasavoid/captain
	name = "Captain's Hardsuit Helmet"
	icon_state = "void_captian"
	desc = "A high tech, NASA Centcom branch designed space suit helmet. Used for AI satellite maintenance. This one is fit for a captain."
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 20, BOMB = 75, BIO = 100, FIRE = 75, ACID = 75)
	flash_protect = FLASH_PROTECTION_FLASH
	item_state = "void_captian_helmet"

/obj/item/clothing/suit/space/nasavoid/captain
	name = "Captain's Hardsuit"
	desc = "A high tech, NASA Centcom branch designed space suit. Used for AI satellite maintenance. This one is fit for a captain."
	icon_state = "void_captian"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 20, BOMB = 75, BIO = 100, FIRE = 75, ACID = 75)
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "void_captian"

/obj/item/clothing/head/helmet/space/nasavoid/syndi
	name = "Blood red infantry helmet"
	icon_state = "void_syndi"
	desc = "A high tech, NASA Centcom branch designed space suit helmet. This one looks rather suspicious."
	armor = list(MELEE = 50, BULLET = 50, LASER = 30, ENERGY = 30, BOMB = 15, BIO = 100, FIRE = 50, ACID = 15)
	item_flags = BANGPROTECT_TOTAL|HEALS_EARS
	flash_protect = FLASH_PROTECTION_FLASH
	item_state = "void_syndi_helmet"

/obj/item/clothing/suit/space/nasavoid/syndi
	name = "Blood red infantry spacesuit"
	icon_state = "void_syndi"
	desc = "A high tech, NASA Centcom branch designed space suit. This one looks rather suspicious."
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 50, BULLET = 50, LASER = 30, ENERGY = 30, BOMB = 15, BIO = 100, FIRE = 50, ACID = 15)
	item_state = "void_syndi"

/obj/effect/nasavoidsuitspawner
	name = "NASA Void Suit Spawner"
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "void_red"
	desc = "You shouldn't see this, a spawner for NASA Void Suits."
	var/suits = list("red", "green", "ntblue", "purple", "yellow", "ltblue")

/obj/effect/nasavoidsuitspawner/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/head/helmet/space/nasavoid/H
	var/obj/item/clothing/suit/space/nasavoid/S
	switch(pick(suits))
		if("red")
			H = new /obj/item/clothing/head/helmet/space/nasavoid
			S = new /obj/item/clothing/suit/space/nasavoid
		if("green")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/green
			S = new /obj/item/clothing/suit/space/nasavoid/green
		if("ntblue")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/ntblue
			S = new /obj/item/clothing/suit/space/nasavoid/ntblue
		if("purple")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/purple
			S = new /obj/item/clothing/suit/space/nasavoid/purple
		if("yellow")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/yellow
			S = new /obj/item/clothing/suit/space/nasavoid/yellow
		if("ltblue")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/ltblue
			S = new /obj/item/clothing/suit/space/nasavoid/ltblue
	var/turf/T = get_turf(src)
	if(H)
		H.forceMove(T)
	if(S)
		S.forceMove(T)
	qdel(src)
