/obj/item/organ/internal/liver/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman liver"
	desc = "An organ with many functions, including filtering harmful substances from the blood, synthesizing essential proteins and enzymes, and removing toxins. This belonged to a plasmaman."
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_liver"

/obj/item/organ/internal/eyes/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman eyeballs"
	desc = "Paired organs responsible for sight: perceiving light and transforming it into visible images. These belonged to a plasmaman."
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_eyes"

/obj/item/organ/internal/ears/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman ears"
	desc = "Paired organs responsible for hearing and providing information about a humanoid's orientation in space. These belonged to a plasmaman."

/obj/item/organ/internal/heart/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman heart"
	desc = "An organ that catalyzes the extraction of plasma from gases entering the body. This belonged to a plasmaman."
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_heart-on"
	item_base = "plasmaman_heart"

/obj/item/organ/internal/brain/plasmaman
	species_type = /datum/species/plasmaman
	desc = "The primary organ of a humanoid's central nervous system. The mind itself resides here. This belonged to a plasmaman."
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_brain"
	mmi_icon = 'icons/obj/species_organs/plasmaman.dmi'

/obj/item/organ/internal/kidneys/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman kidneys"
	desc = "Paired organs that filter the bloodstream and remove toxins and waste from the body. These belonged to a plasmaman."
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_kidneys"

/obj/item/organ/internal/lungs/plasmaman
	name = "plasma filter"
	desc = "A spongy rib-shaped mass for filtering plasma from the air."
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_lungs"
	safe_oxygen_min = 0 //We don't breath this
	safe_toxins_min = 16 //We breathe THIS!
	safe_toxins_max = 0
