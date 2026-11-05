/obj/item/organ/external/head/vulpkanin
	species_type = /datum/species/vulpkanin

/obj/item/organ/external/head/vulpkanin/wolpin
	species_type = /datum/species/monkey/vulpkanin

/obj/item/organ/internal/liver/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin liver"
	desc = "An organ with many functions, including filtering harmful substances from the blood, synthesizing essential proteins and enzymes, and removing toxins. This belonged to a vulpkanin."
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	item_state = "vulpkanin_liver"
	alcohol_intensity = 1.4

/obj/item/organ/internal/eyes/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin eyeballs"
	desc = "Paired organs responsible for sight: perceiving light and transforming it into visible images. These belonged to a vulpkanin."
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	item_state = "vulpkanin_eyes"
	colourblind_matrix = MATRIX_VULP_CBLIND //The colour matrix parameter that the mob will receive when they get the disability.
	replace_colours = PROTANOPIA_COLOR_REPLACE
	see_in_dark = 8

/obj/item/organ/internal/ears/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin ears"
	desc = "Paired organs responsible for hearing and providing information about a humanoid's orientation in space. These belonged to a vulpkanin."

/obj/item/organ/internal/heart/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin heart"
	desc = "An organ that pumps blood or a substitute through a humanoid body. This belonged to a vulpkanin."
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	item_state = "vulpkanin_heart-on"
	item_base = "vulpkanin_heart"

/obj/item/organ/internal/brain/vulpkanin
	species_type = /datum/species/vulpkanin
	desc = "The primary organ of a humanoid's central nervous system. The mind itself resides here. This belonged to a vulpkanin."
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	item_state = "vulpkanin_brain"
	mmi_icon = 'icons/obj/species_organs/vulpkanin.dmi'

/obj/item/organ/internal/lungs/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin lungs"
	desc = "Paired organs responsible for gas exchange between the environment and a humanoid's bloodstream. These belonged to a vulpkanin."
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	item_state = "vulpkanin_lungs"

/obj/item/organ/internal/kidneys/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin kidneys"
	desc = "Paired organs that filter the bloodstream and remove toxins and waste from the body. These belonged to a vulpkanin."
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	item_state = "vulpkanin_kidneys"

/obj/item/organ/external/tail/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin tail"
	desc = "A tail. This belonged to a vulpkanin."
	icon_name = "vulptail_s"
	max_damage = 25
