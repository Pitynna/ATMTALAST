/obj/item/organ/internal/liver/unathi
	species_type = /datum/species/unathi
	name = "unathi liver"
	desc = "A large looking liver."
	icon = 'icons/obj/species_organs/unathi.dmi'
	item_state = "unathi_liver"
	alcohol_intensity = 0.8

/obj/item/organ/internal/eyes/unathi
	species_type = /datum/species/unathi
	name = "unathi eyeballs"
	desc = "A large looking heart."
	icon = 'icons/obj/species_organs/unathi.dmi'
	item_state = "unathi_eyes"
	see_in_dark = 3

/obj/item/organ/internal/ears/unathi
	species_type = /datum/species/unathi
	name = "unathi ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали унатху."

/obj/item/organ/internal/heart/unathi
	species_type = /datum/species/unathi
	name = "unathi heart"
	desc = "A large looking heart."
	icon = 'icons/obj/species_organs/unathi.dmi'
	item_state = "unathi_heart-on"
	item_base = "unathi_heart"

/obj/item/organ/internal/brain/unathi
	species_type = /datum/species/unathi
	desc = "A smallish looking brain."
	icon = 'icons/obj/species_organs/unathi.dmi'
	item_state = "unathi_brain"
	mmi_icon = 'icons/obj/species_organs/unathi.dmi'

/obj/item/organ/internal/lungs/unathi
	species_type = /datum/species/unathi
	name = "unathi lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали унатху."
	icon = 'icons/obj/species_organs/unathi.dmi'
	item_state = "unathi_lungs"

/obj/item/organ/internal/kidneys/unathi
	species_type = /datum/species/unathi
	name = "unathi kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали унатху."
	icon = 'icons/obj/species_organs/unathi.dmi'
	item_state = "unathi_kidneys"

/obj/item/organ/external/tail/unathi
	species_type = /datum/species/unathi
	name = "unathi tail"
	desc = "Хвост. Этот принадлежал унатху."
	icon_name = "sogtail_s"
	min_broken_damage = 20

/obj/item/organ/internal/lungs/unathi/ash_walker
	name = "ash walker lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали пеплоходцу."
	safe_oxygen_min = 8 // can breathe on lavaland
	safe_co2_max = 30
	safe_toxins_max = 1

/obj/item/organ/internal/eyes/unathi/ash_walker
	name = "ash walker eyes"
	desc = "Парный орган, отвечающий за зрение — восприятие света и его трансформацию в видимое изображение. Эти принадлежали пеплоходцу."
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/organ/internal/eyes/unathi/ash_walker_shaman
	name = "ash walker shaman eyes"
	desc = "Парный орган, отвечающий за зрение — восприятие света и его трансформацию в видимое изображение. Эти принадлежали шаману пеплоходцев."
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/organ/internal/eyes/unathi/ash_walker_shaman/insert(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.show_to(target)

/obj/item/organ/internal/eyes/unathi/ash_walker_shaman/remove(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.hide_from(target)
