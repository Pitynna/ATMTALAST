//Ancient cryogenic sleepers. Players become NT crewmen from a hundred year old space station, now on the verge of collapse.

/obj/effect/mob_spawn/human/oldstation
	name = "old cryogenics pod"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper"
	description = "Работайте в команде с другими выжившими на борту древней разрушенной космической станции."
	roundstart = FALSE
	death = FALSE
	allow_species_pick = TRUE
	allow_prefs_prompt = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list(SPECIES_HUMAN)
	mob_species = /datum/species/human
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldstation/oldsec
	desc = "A humming cryo pod. You can barely recognise a security uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a security officer"
	outfit = /datum/outfit/oldstation/officer
	flavour_text = "Вы — офицер службы безопасности, работающий на \"Нанотрейзен\", и находитесь на борту передовой исследовательской станции.\nВы смутно помните, \
	как бросились в криогенную капсулу из-за надвигающейся радиационной бури. Последнее, что вы помните, – это слова Искусственного Интеллекта станции о том, что вы \
	проспите всего восемь часов.\nКогда вы открываете глаза, всё вокруг кажется ржавым и разрушенным, а в животе нарастает тёмное предчувствие, пока вы выбираетесь из капсулы."

/obj/effect/mob_spawn/human/oldstation/oldmed
	desc = "A humming cryo pod. You can barely recognise a medical uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a medical doctor"
	outfit = /datum/outfit/oldstation/medic
	flavour_text = "Вы — врач, работающий на \"Нанотрейзен\", и находитесь на борту передовой исследовательской станции.\nВы смутно помните, \
	как бросились в криогенную капсулу из-за надвигающейся радиационной бури. Последнее, что вы помните, – это слова Искусственного Интеллекта станции о том, что вы \
	проспите всего восемь часов.\nКогда вы открываете глаза, всё вокруг кажется ржавым и разрушенным, а в животе нарастает тёмное предчувствие, пока вы выбираетесь из капсулы."

/obj/effect/mob_spawn/human/oldstation/oldeng
	desc = "A humming cryo pod. You can barely recognise an engineering uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "an engineer"
	outfit = /datum/outfit/oldstation/engineer
	flavour_text = "Вы — инженер, работающий на \"Нанотрейзен\", и находитесь на борту передовой исследовательской станции.\nВы смутно помните, \
	как бросились в криогенную капсулу из-за надвигающейся радиационной бури. Последнее, что вы помните, – это слова Искусственного Интеллекта станции о том, что вы \
	проспите всего восемь часов.\nКогда вы открываете глаза, всё вокруг кажется ржавым и разрушенным, а в животе нарастает тёмное предчувствие, пока вы выбираетесь из капсулы."

/obj/effect/mob_spawn/human/oldstation/oldsci
	desc = "A humming cryo pod. You can barely recognise a science uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a scientist"
	outfit = /datum/outfit/oldstation/scientist
	flavour_text = "Вы — учёный, работающий на \"Нанотрейзен\", и находитесь на борту передовой исследовательской станции.\nВы смутно помните, \
	как бросились в криогенную капсулу из-за надвигающейся радиационной бури. Последнее, что вы помните, – это слова Искусственного Интеллекта станции о том, что вы \
	проспите всего восемь часов.\nКогда вы открываете глаза, всё вокруг кажется ржавым и разрушенным, а в животе нарастает тёмное предчувствие, пока вы выбираетесь из капсулы."

/obj/structure/showcase/machinery/oldpod
	name = "damaged cryogenic pod"
	desc = "A damaged cryogenic pod long since lost to time, including its former occupant..."
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper-open"

/obj/structure/showcase/machinery/oldpod/used
	name = "opened cryogenic pod"
	desc = "A cryogenic pod that has recently discharged its occupant. The pod appears non-functional."

/datum/outfit/oldstation/post_equip(mob/living/carbon/human/H)
	. = ..()
	H.remove_language(LANGUAGE_GALACTIC_COMMON)
	H.set_default_language(GLOB.all_languages[LANGUAGE_SOL_COMMON])
	H.dna.species.default_language = LANGUAGE_SOL_COMMON

/datum/outfit/oldstation/officer
	name = "Old station officer"
	uniform = /obj/item/clothing/under/retro/security
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/away/old/sec
	r_pocket = /obj/item/restraints/handcuffs
	l_pocket = /obj/item/flash

/datum/outfit/oldstation/medic
	name = "Old station medic"
	uniform = /obj/item/clothing/under/retro/medical
	shoes = /obj/item/clothing/shoes/color/black
	id = /obj/item/card/id/away/old/med
	l_pocket = /obj/item/stack/medical/ointment
	r_pocket = /obj/item/stack/medical/ointment

/datum/outfit/oldstation/engineer
	name = "Old station engineer"
	uniform = /obj/item/clothing/under/retro/engineering
	shoes = /obj/item/clothing/shoes/workboots
	id = /obj/item/card/id/away/old/eng
	gloves = /obj/item/clothing/gloves/color/fyellow/old
	l_pocket = /obj/item/tank/internals/emergency_oxygen

/datum/outfit/oldstation/scientist
	name = "Old station scientist"
	uniform = /obj/item/clothing/under/retro/science
	shoes = /obj/item/clothing/shoes/laceup
	id = /obj/item/card/id/away/old/sci
	l_pocket = /obj/item/stack/medical/bruise_pack

/obj/effect/mob_spawn/human/oldstation/special(mob/living/carbon/human/H)
	GLOB.human_names_list += H.real_name
	return ..()

/obj/effect/mob_spawn/human/oldstation/Destroy()
	new /obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()
