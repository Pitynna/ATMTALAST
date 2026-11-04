/obj/item/organ/internal/liver/grey
	species_type = /datum/species/grey
	name = "grey liver"
	desc = "A small, odd looking liver."
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_liver"
	alcohol_intensity = 1.4

/obj/item/organ/internal/brain/grey
	species_type = /datum/species/grey
	desc = "A large brain."
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_brain"
	mmi_icon = 'icons/obj/species_organs/grey.dmi'
	smart_mind = TRUE // nerd brains show us sci-hud and research scanner

/obj/item/organ/internal/brain/grey/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	M.add_language(LANGUAGE_GREY)

/obj/item/organ/internal/brain/grey/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	M.remove_language(LANGUAGE_GREY)
	. = ..()

/obj/item/organ/internal/eyes/grey
	species_type = /datum/species/grey
	name = "grey eyeballs"
	desc = "They still look creepy and emotionless."
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_eyes"
	see_in_dark = 3

/obj/item/organ/internal/ears/grey
	species_type = /datum/species/grey
	name = "grey ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали серому."

/obj/item/organ/internal/heart/grey
	species_type = /datum/species/grey
	name = "grey heart"
	desc = "Орган, качающий кровь или её заменяющую субстанцию по организму гуманоида. Это принадлежало серому."
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_heart-on"
	item_base = "grey_heart"

/obj/item/organ/internal/lungs/grey
	species_type = /datum/species/grey
	name = "grey lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали серому."
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_lungs"

/obj/item/organ/internal/kidneys/grey
	species_type = /datum/species/grey
	name = "grey kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали серому."
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_kidneys"
