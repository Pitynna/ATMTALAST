/obj/item/organ/internal/liver/vox
	species_type = /datum/species/vox
	name = "vox liver"
	desc = "An organ with many functions, including filtering harmful substances from the blood, synthesizing essential proteins and enzymes, and removing toxins. This belonged to a vox."
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_liver"
	alcohol_intensity = 1.6
	sterile = TRUE

/obj/item/organ/internal/eyes/vox
	species_type = /datum/species/vox
	name = "vox eyeballs"
	desc = "Paired organs responsible for sight: perceiving light and transforming it into visible images. These belonged to a vox."
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_eyes"
	sterile = TRUE

/obj/item/organ/internal/ears/vox
	species_type = /datum/species/vox
	name = "vox ears"
	desc = "Paired organs responsible for hearing and providing information about a humanoid's orientation in space. These belonged to a vox."

/obj/item/organ/internal/heart/vox
	species_type = /datum/species/vox
	name = "vox heart"
	desc = "An organ that pumps blood or a substitute through a humanoid body. This belonged to a vox."
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_heart-on"
	item_base = "vox_heart"
	sterile = TRUE

/obj/item/organ/internal/brain/vox
	species_type = /datum/species/vox
	name = "cortical stack"
	desc = "A peculiarly advanced bio-electronic device that seems to hold the memories and identity of a Vox."
	icon = 'icons/obj/species_organs/vox.dmi'
	icon_state = "cortical-stack"
	item_state = "vox_cortical-stack"
	mmi_icon = 'icons/obj/species_organs/vox.dmi'
	sterile = TRUE

/obj/item/organ/internal/kidneys/vox
	species_type = /datum/species/vox
	name = "vox kidneys"
	desc = "Paired organs that filter the bloodstream and remove toxins and waste from the body. These belonged to a vox."
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_kidneys"
	sterile = TRUE

/obj/item/organ/internal/lungs/vox
	name = "vox lungs"
	desc = "They're filled with dust....wow."
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_lungs"

	safe_oxygen_min = 0 //We don't breathe this
	safe_oxygen_max = 0.05 //This is toxic to us
	safe_nitro_min = 16 //We breathe THIS!
	oxy_damage_type = TOX //And it poisons us

/obj/item/organ/external/tail/vox
	species_type = /datum/species/vox
	name = "vox tail"
	desc = "A tail. This belonged to a vox."
	icon_name = "voxtail_s"
	max_damage = 25
	min_broken_damage = 20
