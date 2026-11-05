/obj/item/organ/external/chest/diona
	species_type = /datum/species/diona
	name = "core trunk"
	desc = "The main trunk: the core."
	gender = MALE
	max_damage = 200
	min_broken_damage = 50
	amputation_point = "ствол"
	encased = null
	gendered_icon = FALSE
	cannot_break = TRUE
	encased = null
	convertable_children = list(/obj/item/organ/external/groin/diona)

/obj/item/organ/external/groin/diona
	species_type = /datum/species/diona
	name = "fork"
	desc = "A multi-pronged eating utensil. Sure is pointy. Keep away from outlets."
	gender = NEUTER
	min_broken_damage = 50
	amputation_point = "нижний ствол"
	gendered_icon = FALSE

/obj/item/organ/external/arm/diona
	species_type = /datum/species/diona
	name = "left upper tendril"
	desc = "The upper-left branch of the trunk."
	gender = MALE
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "левый верхний отросток"
	convertable_children = list(/obj/item/organ/external/hand/diona)

/obj/item/organ/external/arm/right/diona
	species_type = /datum/species/diona
	name = "right upper tendril"
	desc = "The upper-right branch of the trunk."
	gender = MALE
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "правый верхний отросток"
	convertable_children = list(/obj/item/organ/external/hand/right/diona)

/obj/item/organ/external/leg/diona
	species_type = /datum/species/diona
	name = "left lower tendril"
	desc = "The lower-left branch of the trunk."
	gender = MALE
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "левый нижний отросток"
	convertable_children = list(/obj/item/organ/external/foot/diona)

/obj/item/organ/external/leg/right/diona
	species_type = /datum/species/diona
	name = "right lower tendril"
	desc = "The lower-right branch of the trunk."
	gender = MALE
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "правый нижний отросток"
	convertable_children = list(/obj/item/organ/external/foot/right/diona)

/obj/item/organ/external/foot/diona
	species_type = /datum/species/diona
	max_damage = 20
	min_broken_damage = 10
	amputation_point = "левую нижнюю ветку"

/obj/item/organ/external/foot/right/diona
	species_type = /datum/species/diona
	max_damage = 20
	min_broken_damage = 10
	amputation_point = "правую нижнюю ветку"

/obj/item/organ/external/hand/diona
	species_type = /datum/species/diona
	name = "left grasper"
	desc = "The upper-left grasping branch."
	gender = MALE
	amputation_point = "левую верхнюю ветку"

/obj/item/organ/external/hand/right/diona
	species_type = /datum/species/diona
	name = "right grasper"
	desc = "The upper-right grasping branch."
	gender = MALE
	amputation_point = "правую верхнюю ветку"

/obj/item/organ/external/head/diona
	species_type = /datum/species/diona
	name = "upper trunk"
	desc = "The upper branch of the trunk."
	gender = NEUTER
	max_damage = 50
	min_broken_damage = 25
	encased = null
	amputation_point = "верхний ствол"
	gendered_icon = FALSE
	cannot_break = TRUE
	encased = null

/obj/item/organ/diona/process()
	return

/obj/item/organ/internal/brain/diona
	species_type = /datum/species/diona
	name = "neural strata"
	desc = "A layer of neural tissue, the central organ of a gestalt's nervous system. This belonged to a diona."
	gender = FEMALE
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	dead_icon = null
	parent_organ_zone = BODY_ZONE_CHEST
	actions_types = list(/datum/action/item_action/organ_action/diona_brain_evacuation)

/obj/item/organ/internal/brain/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/datum/action/item_action/organ_action/diona_brain_evacuation
	name = "Эвакуации"
	check_flags = 0
	desc = "Покинуть тело в форме нимфы."

/datum/action/item_action/organ_action/diona_brain_evacuation/IsAvailable(feedback = FALSE)
	. = ..()
	if((!owner.mind) || owner.mind.suicided)
		return FALSE

/datum/action/item_action/organ_action/diona_brain_evacuation/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(tgui_alert(usr, "Вы уверены, что хотите покинуть своё тело как нимфа? (Если использовать, пока вы живы, вас лишит роли антагониста!)", "Подтверждение эвакуации", list("Да", "Нет")) == "Нет")
		return

	if(. && istype(target, /obj/item/organ/internal/brain/diona))
		var/is_dead = owner.is_dead()
		if(is_dead || do_after(owner, 1 MINUTES, owner))
			var/obj/item/organ/internal/brain/diona/brain = target
			var/loc = owner.loc
			var/datum/mind/mind = owner.mind
			if(!is_dead)
				mind.remove_all_antag_roles(FALSE)
				log_and_message_admins("diona-evacuated into nymph and lost all possible antag roles.")
			brain.remove(owner)

			for(var/mob/living/simple_animal/diona/nymph in get_turf(loc))
				var/throw_dir = pick(GLOB.alldirs)
				var/throwtarget = get_edge_target_turf(nymph, throw_dir)
				nymph.throw_at(throwtarget, 3, 1, owner)

/obj/item/organ/internal/kidneys/diona
	species_type = /datum/species/diona
	name = "filtrating vacuoles"
	desc = "Paired organs that remove toxins and harmful substances from a gestalt's biomass. These belonged to a diona."
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/kidneys/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/obj/item/organ/internal/lungs/diona
	species_type = /datum/species/diona
	name = "gas bladder"
	desc = "Paired organs responsible for gas exchange between the environment and a gestalt's biomass. These belonged to a diona."
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/lungs/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/obj/item/organ/internal/appendix/diona
	species_type = /datum/species/diona
	name = "polyp segment"
	desc = "A layer of biomass. A vestigial organ with no useful function for the gestalt. This belonged to a diona."
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/appendix/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/obj/item/organ/internal/heart/diona
	species_type = /datum/species/diona
	name = "anchoring ligament"
	desc = "An organ binding the parts of a gestalt together. This belonged to a diona."
	gender = FEMALE
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN

/obj/item/organ/internal/heart/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/obj/item/organ/internal/heart/diona/update_icon_state()
	return

/obj/item/organ/internal/eyes/diona
	species_type = /datum/species/diona
	name = "receptor node"
	desc = "Light-sensitive membranes responsible for vision. This belonged to a diona."
	gender = MALE
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	parent_organ_zone = BODY_ZONE_CHEST

/obj/item/organ/internal/eyes/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/obj/item/organ/internal/liver/diona
	species_type = /datum/species/diona
	name = "nutrient vessel"
	desc = "A gland responsible for metabolizing substances absorbed by the gestalt. This belonged to a diona."
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	alcohol_intensity = 0.5

/obj/item/organ/internal/liver/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/obj/item/organ/internal/ears/diona
	species_type = /datum/species/diona
	name = "oscillatory catcher"
	desc = "A strange organic object used by a Gestalt for orientation in a three-dimensional projection."
	gender = MALE
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN

/obj/item/organ/internal/ears/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)
