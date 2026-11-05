// Holds the reflector clothing set //

/obj/item/clothing/gloves/reflector
	name = "reflector gloves"
	desc = "Advanced gloves made from reflective material to deflect energy beams. Wearing them is a real workout for your hands!"
	icon_state = "reflector"
	item_state = "reflector"
	armor = list(MELEE = 0, BULLET = 0, LASER = 50, ENERGY = 50, BOMB = 0, BIO = 0, FIRE = 50, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
	)
	var/list/reflect_zones = list(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
	var/hit_reflect_chance = 50

/obj/item/clothing/gloves/reflector/IsReflect(def_zone)
	if(!(def_zone in reflect_zones))
		return REFLECT_NOTHING

	return prob(hit_reflect_chance)

/obj/item/clothing/head/helmet/reflector
	name = "reflector hat"
	desc = "An advanced hat made from reflective material to deflect energy beams. Includes a protective visor with improved acid resistance."
	icon_state = "reflector"
	item_state = "reflectorhat"
	flags_inv = HIDEHEADSETS
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	dog_fashion = null
	armor = list(MELEE = 10, BULLET = 10, LASER = 60, ENERGY = 60, BOMB = 0, BIO = 0, FIRE = 90, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/helmet.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/helmet.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/helmet.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/helmet.dmi',
	)
	var/list/reflect_zones = list(BODY_ZONE_HEAD)
	var/hit_reflect_chance = 50

/obj/item/clothing/head/helmet/reflector/IsReflect(def_zone)
	if(!(def_zone in reflect_zones))
		return REFLECT_NOTHING

	return prob(hit_reflect_chance)

/obj/item/clothing/shoes/reflector
	name = "reflector boots"
	desc = "Advanced boots made from reflective material to deflect energy beams. Fairly lightweight, but not very comfortable."
	icon_state = "reflector"
	item_state = "reflectorboots"
	armor = list(MELEE = 0, BULLET = 0, LASER = 50, ENERGY = 50, BOMB = 0, BIO = 0, FIRE = 50, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/shoes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/shoes.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/shoes.dmi',
	)
	var/list/reflect_zones = list(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	var/hit_reflect_chance = 50

/obj/item/clothing/shoes/reflector/IsReflect(def_zone)
	if(!(def_zone in reflect_zones))
		return REFLECT_NOTHING

	return prob(hit_reflect_chance)

/obj/item/clothing/suit/armor/reflector
	name = "reflector coat"
	desc = "An innovative advanced coat made from reflective material to deflect energy beams. Combines style with cutting-edge technology."
	icon_state = "reflector"
	item_state = "reflector"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list(MELEE = 10, BULLET = 10, LASER = 60, ENERGY = 60, BOMB = 0, BIO = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
	)
	var/static/list/reflect_zones = list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	var/hit_reflect_chance = 50

/obj/item/clothing/suit/armor/reflector/IsReflect(def_zone)
	if(!(def_zone in reflect_zones))
		return REFLECT_NOTHING

	return prob(hit_reflect_chance)
