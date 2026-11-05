//DRASK ORGAN
/obj/item/organ/internal/drask
	species_type = /datum/species/drask
	name = "drask organ"
	desc = "A greenish, slightly translucent organ. It is extremely cold."
	icon = 'icons/obj/species_organs/drask.dmi'
	icon_state = "innards"
	item_state = "drask_innards"

/obj/item/organ/internal/heart/drask
	species_type = /datum/species/drask
	name = "drask heart"
	desc = "An organ that pumps cryoxadone through a drask's body."
	icon = 'icons/obj/species_organs/drask.dmi'
	item_state = "drask_heart-on"
	item_base = "drask_heart"
	parent_organ_zone = BODY_ZONE_HEAD

/obj/item/organ/internal/liver/drask
	species_type = /datum/species/drask
	name = "metabolic strainer"
	desc = "An organ of a drask's excretory system. Secretes a specialized enzyme that removes toxins from the bloodstream and stimulates cell division."
	gender = MALE
	icon = 'icons/obj/species_organs/drask.dmi'
	icon_state = "kidneys"
	item_state = "drask_liver"
	alcohol_intensity = 0.8

/obj/item/organ/internal/brain/drask
	species_type = /datum/species/drask
	desc = "The primary organ of a humanoid's central nervous system. The mind itself resides here. This belonged to a drask."
	icon = 'icons/obj/species_organs/drask.dmi'
	item_state = "drask_brain"
	mmi_icon = 'icons/obj/species_organs/drask.dmi'

/obj/item/organ/internal/eyes/drask
	species_type = /datum/species/drask
	name = "drask eyeballs"
	desc = "Drask eyes. They look even stranger disembodied."
	icon = 'icons/obj/species_organs/drask.dmi'
	item_state = "drask_eyes"
	see_in_dark = 5

/obj/item/organ/internal/ears/drask
	species_type = /datum/species/drask
	name = "drask ears"
	desc = "Paired organs responsible for hearing and providing information about a humanoid's orientation in space. These belonged to a drask."

/obj/item/organ/internal/lungs/drask
	name = "drask lungs"
	desc = "Paired organs responsible for gas exchange between the environment and a drask's bloodstream."
	icon = 'icons/obj/species_organs/drask.dmi'
	item_state = "drask_lungs"
	cold_message = " освежающий холод"
	cold_level_1_damage = -COLD_GAS_DAMAGE_LEVEL_1 //They heal when the air is cold
	cold_level_2_damage = -COLD_GAS_DAMAGE_LEVEL_2
	cold_level_3_damage = -COLD_GAS_DAMAGE_LEVEL_3
	cold_damage_types = list(BRUTE = 0.5, BURN = 0.25)

	var/cooling_start_temp = DRASK_LUNGS_COOLING_START_TEMP
	var/cooling_stop_temp = DRASK_LUNGS_COOLING_STOP_TEMP

/obj/item/organ/internal/lungs/drask/insert(mob/living/carbon/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()

	if(!.)
		return FALSE

	RegisterSignal(owner, COMSIG_HUMAN_EARLY_HANDLE_ENVIRONMENT, PROC_REF(regulate_temperature))

/obj/item/organ/internal/lungs/drask/proc/regulate_temperature(mob/living/source, datum/gas_mixture/environment)
	SIGNAL_HANDLER

	if(source.stat == DEAD)
		return

	if(owner.bodytemperature > cooling_start_temp && environment.temperature() <= cooling_stop_temp)
		owner.adjust_bodytemperature(-5)

/obj/item/organ/internal/lungs/drask/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT)
	UnregisterSignal(owner, COMSIG_HUMAN_EARLY_HANDLE_ENVIRONMENT)
	return ..()
