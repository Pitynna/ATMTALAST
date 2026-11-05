//NUCLEATION ORGAN
/obj/item/organ/internal/nucleation
	species_type = /datum/species/nucleation
	name = "nucleation organ"

/obj/item/organ/internal/nucleation/resonant_crystal
	name = "resonant crystal"
	desc = "A strange yellow crystal. It appears to have belonged to a Nucleation."
	icon_state = "resonant-crystal"
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_RESONANT_CRYSTAL

/obj/item/organ/internal/nucleation/strange_crystal
	name = "strange crystal"
	desc = "A strange yellow crystal. It appears to have belonged to a Nucleation."
	icon_state = "strange-crystal"
	slot = INTERNAL_ORGAN_STRANGE_CRYSTAL

/obj/item/organ/internal/eyes/luminescent_crystal
	species_type = /datum/species/nucleation
	name = "luminescent eyes"
	desc = "Unusual eyes that emit light. These belonged to a Nucleation."
	icon_state = "crystal-eyes"
	light_color = "#f7f792"
	light_range = 2

/obj/item/organ/internal/brain/crystal
	species_type = /datum/species/nucleation
	name = "crystallized brain"
	desc = "The main organ of a humanoid's central nervous system. This is where the mind resides. Its crystallized structure suggests that it belonged to a Nucleation."
	icon_state = "crystal-brain"

/obj/item/organ/internal/brain/crystal/insert(mob/living/target, special = ORGAN_MANIPULATION_DEFAULT)
	..(target, special)
	if(isnucleation(target))
		return //no need to apply disease to nucleation
	var/datum/disease/virus/nuclefication/D = new()
	D.Contract(target, need_protection_check = FALSE)
