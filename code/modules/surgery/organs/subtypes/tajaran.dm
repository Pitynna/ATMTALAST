/obj/item/organ/internal/liver/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran liver"
	desc = "An organ with many functions, including filtering harmful substances from the blood, synthesizing essential proteins and enzymes, and removing toxins. This belonged to a tajaran."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_liver"
	alcohol_intensity = 1.4

/obj/item/organ/internal/eyes/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran eyeballs"
	desc = "Paired organs responsible for sight: perceiving light and transforming it into visible images. These belonged to a tajaran."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_eyes"
	colourblind_matrix = MATRIX_TAJ_CBLIND //The colour matrix parameter that the mob will receive when they get the disability.
	replace_colours = TRITANOPIA_COLOR_REPLACE
	see_in_dark = 8

/obj/item/organ/internal/ears/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran ears"
	desc = "Paired organs responsible for hearing and providing information about a humanoid's orientation in space. These belonged to a tajaran."

/obj/item/organ/internal/heart/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran heart"
	desc = "An organ that pumps blood or a substitute through a humanoid body. This belonged to a tajaran."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_heart-on"
	item_base = "tajaran_heart"

/obj/item/organ/internal/brain/tajaran
	species_type = /datum/species/tajaran
	desc = "The primary organ of a humanoid's central nervous system. The mind itself resides here. This belonged to a tajaran."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_brain"
	mmi_icon = 'icons/obj/species_organs/tajaran.dmi'

/obj/item/organ/internal/lungs/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran lungs"
	desc = "Paired organs responsible for gas exchange between the environment and a humanoid's bloodstream. These belonged to a tajaran."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_lungs"

/obj/item/organ/internal/kidneys/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran kidneys"
	desc = "Paired organs that filter the bloodstream and remove toxins and waste from the body. These belonged to a tajaran."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_kidneys"

/obj/item/organ/external/tail/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran tail"
	desc = "A tail. This belonged to a tajaran."
	icon_name = "tajtail_s"
	max_damage = 20
