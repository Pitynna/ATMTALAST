//WRYN ORGAN
/obj/item/organ/internal/wryn/hivenode
	species_type = /datum/species/wryn
	name = "antennae"
	desc = "An organ that allows a Wryn to communicate telepathically with others of its species."
	icon = 'icons/obj/species_organs/wryn.dmi'
	icon_state = "antennae"
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_HIVENODE
	species_restrictions = list(SPECIES_WRYN)
	/// Stored hair style, defines only on creation and changes original h_style when inserted
	var/hair_style = "Normal antennae"

/obj/item/organ/internal/wryn/hivenode/Initialize(mapload)
	if(iscarbon(loc))
		var/mob/living/carbon/carbon = loc
		var/obj/item/organ/external/head/head_organ = carbon.get_organ(BODY_ZONE_HEAD)
		hair_style = head_organ.h_style
	. = ..()

/obj/item/organ/internal/wryn/hivenode/insert(mob/living/carbon/human/human, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	human.add_language(LANGUAGE_WRYN)
	var/obj/item/organ/external/head/head_organ = human.get_organ(BODY_ZONE_HEAD)

	head_organ.h_style = hair_style
	human.update_hair()

/obj/item/organ/internal/wryn/hivenode/remove(mob/living/carbon/human/human, special = ORGAN_MANIPULATION_DEFAULT)
	human.remove_language(LANGUAGE_WRYN)
	var/obj/item/organ/external/head/head_organ = human.get_organ(BODY_ZONE_HEAD)

	head_organ.h_style = "Bald"
	human.update_hair()

	return ..()

/obj/item/organ/internal/wryn/glands
	species_type = /datum/species/wryn
	name = "wryn wax glands"
	desc = "Paired glands that produce wax, which Wryn can use as a building material."
	gender = PLURAL
	icon = 'icons/obj/species_organs/wryn.dmi'
	icon_state = "waxsac"
	item_state = "waxsac"
	parent_organ_zone = BODY_ZONE_PRECISE_MOUTH
	slot = INTERNAL_ORGAN_WAX_GLANDS
	var/datum/action/innate/wryn/build_wax/build_wax = new
	var/datum/action/innate/wryn/toggle_producing/toggle_producing = new
	var/wax = 25
	var/producing = FALSE

/obj/item/organ/internal/wryn/glands/on_life()
	if(!producing)
		return
	if(owner.nutrition > NUTRITION_LEVEL_STARVING && owner.getWax() < 75)
		owner.adjustWax(10)
		owner.set_nutrition(owner.nutrition - 25)
		if(prob(10))
			to_chat(owner, span_notice("Вы чувствуете лёгкое бурление в восковых железах."))

/obj/item/organ/internal/wryn/glands/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	..()
	build_wax.Grant(M)
	toggle_producing.Grant(M)

/obj/item/organ/internal/wryn/glands/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	build_wax.Remove(M)
	toggle_producing.Remove(M)
	. = ..()

/datum/action/innate/wryn/build_wax
	name = "Строительство из воска"
	desc = "Выделите воск для строительства"
	button_icon_state = "build"
	var/static/list/actions = list()

/datum/action/innate/wryn/build_wax/New(Target)
	. = ..()
	if(LAZYLEN(actions))
		return .
	for(var/name in GLOB.wryn_structures)
		var/datum/wryn_building/datum = GLOB.wryn_structures[name]
		actions[name] = image(datum.icon_file, datum.icon_state)

/datum/action/innate/wryn/build_wax/Activate()
	var/mob/living/carbon/human/wryn/host = owner

	var/choosen_type = show_radial_menu(host, host, actions, radius = 40)
	if(!choosen_type)
		return
	var/datum/wryn_building/structure = GLOB.wryn_structures[choosen_type]
	structure.wax_build(host, structure.wax_amount, structure.structure)

/datum/action/innate/wryn/toggle_producing
	name = "Переключить секрецию воска"
	button_icon_state = "glands"

/datum/action/innate/wryn/toggle_producing/Activate()
	var/mob/living/carbon/human/host = owner
	host.toggle_producing()

/obj/item/organ/internal/brain/wryn
	desc = "The primary organ of a humanoid's central nervous system. The mind itself resides here. This belonged to a wryn."
	icon = 'icons/obj/species_organs/wryn.dmi'
	item_state = "wryn_brain"
	mmi_icon = 'icons/obj/species_organs/wryn.dmi'

/obj/item/organ/internal/heart/wryn
	species_type = /datum/species/wryn
	name = "wryn heart"
	desc = "An organ that pumps blood or a substitute through a humanoid body. This belonged to a wryn."
	icon = 'icons/obj/species_organs/wryn.dmi'
	item_state = "wryn_heart-on"
	item_base = "wryn_heart"

/obj/item/organ/internal/eyes/wryn
	species_type = /datum/species/wryn
	name = "wryn eyes"
	desc = "Paired organs responsible for sight: perceiving light and transforming it into visible images. These belonged to a wryn."
	icon = 'icons/obj/species_organs/wryn.dmi'
	item_state = "wryn_eyes"
	see_in_dark = 3

/obj/item/organ/internal/ears/wryn
	species_type = /datum/species/wryn
	name = "wryn ears"
	desc = "Paired organs responsible for hearing and providing information about a humanoid's orientation in space. These belonged to a wryn."

/obj/item/organ/external/tail/wryn
	species_type = /datum/species/wryn
	name = "wryn tail"
	desc = "A tail. This belonged to a wryn."
	icon_name = "wryntail_s"
	max_damage = 35
	min_broken_damage = 25

/obj/item/organ/external/chest/wryn
	encased = "хитиновую оболочку на груди"
	convertable_children = list(/obj/item/organ/external/groin/wryn)

/obj/item/organ/external/groin/wryn
	encased = "хитиновую оболочку на животе"

/obj/item/organ/external/head/wryn
	species_type = /datum/species/wryn
	encased = "хитиновую оболочку на голове"
