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
	desc = "Paired organs responsible for hearing and providing information about a humanoid's orientation in space. These belonged to a grey."

/obj/item/organ/internal/heart/grey
	species_type = /datum/species/grey
	name = "grey heart"
	desc = "An organ that pumps blood or a substitute through a humanoid body. This belonged to a grey."
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_heart-on"
	item_base = "grey_heart"

/obj/item/organ/internal/lungs/grey
	species_type = /datum/species/grey
	name = "grey lungs"
	desc = "Paired organs responsible for gas exchange between the environment and a humanoid's bloodstream. These belonged to a grey."
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_lungs"

/obj/item/organ/internal/kidneys/grey
	species_type = /datum/species/grey
	name = "grey kidneys"
	desc = "Paired organs that filter the bloodstream and remove toxins and waste from the body. These belonged to a grey."
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_kidneys"
