// Theft objectives.
//
// Separated into datums so we can prevent roles from getting certain objectives.

GLOBAL_LIST_INIT(potential_theft_objectives, subtypesof(/datum/theft_objective/highrisk))

GLOBAL_LIST_INIT(ungibbable_items_types, get_ungibbable_items_types())

/proc/get_ungibbable_items_types()
	var/types = list()

	// Highrisk items
	for(var/highrisk_objective_type in subtypesof(/datum/theft_objective/highrisk))
		var/datum/theft_objective/highrisk_objective = highrisk_objective_type
		types += initial(highrisk_objective.typepath)

	return types

/proc/get_theft_targets_station(typepath, subtypes = TRUE, list/blacklist)
	var/list/typecache = list()
	typecache[typepath] = TRUE
	if(subtypes)
		typecache = typecacheof(typecache)
	. = list()

	var/list/stations_z = levels_by_trait(STATION_LEVEL)
	var/list/station_turfs = block(1, 1, stations_z[1], world.maxx, world.maxy, stations_z[length(stations_z)])

	for(var/turf/turf_check in station_turfs)
		if(ispath(typepath, /mob/living))
			var/list/turf_contents = turf_check.collect_all_atoms_of_type(/mob/living, blacklist)
			for(var/mob/living/mob_check in turf_contents)
				if(typecache[mob_check.type])
					. |= mob_check
				CHECK_TICK

		else if(ispath(typepath, /obj))
			var/list/turf_contents = turf_check.collect_all_atoms_of_type(/obj, blacklist)
			for(var/obj/obj_check in turf_contents)
				if(typecache[obj_check.type])
					. |= obj_check
				CHECK_TICK

/datum/theft_objective
	var/id
	var/name = "this objective is impossible, yell at a coder"
	var/atom/typepath = /obj/effect/debugging
	var/list/protected_jobs = list()
	var/list/altitems = list()
	var/flags = NONE
	var/location_override
	/// Do we have a special item we give to somewhen when they get this objective?
	var/special_equipment = null
	/// If a steal objective has forbidden jobs, and the forbidden jobs would not be in the possession of this item, set this to false
	var/job_possession = TRUE
	/// Range to a steal target if its not an item.
	var/range_distance = 2

/datum/theft_objective/proc/get_antag_menu_name()
	return name

/datum/theft_objective/proc/check_completion(list/owners)
	for(var/datum/mind/player in owners)
		if(!player.current)
			continue

		for(var/obj/item/item in player.current.get_all_contents())
			if((istype(item, typepath) || (item.type in altitems)) && check_special_completion(item))
				return TRUE

	return FALSE

/datum/theft_objective/proc/generate_explanation_text(datum/objective/steal/steal_objective)
	steal_objective.explanation_text = "Украсть [name]. Последнее местоположение было в [generate_location_text()]. "
	if(length(protected_jobs) && job_possession)
		steal_objective.explanation_text += "Также стоит проверить у [jointext(protected_jobs, ", ")]."

/datum/theft_objective/proc/generate_location_text()
	if(location_override)
		return location_override
	var/list/checks = get_theft_targets_station(typepath, subtypes = TRUE)
	for(var/atom/check in checks)
		return "[get_area(check)]"
	return "неизвестной зоне"

/**
 * This proc is to be used for not granting objectives if a special requirement other than job is not met.
 */
/datum/theft_objective/proc/check_objective_conditions()
	return TRUE

/**
 * For objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
 */
/datum/proc/check_special_completion(obj/item/I)
	return TRUE

//==========================
//========Highrisk========
//==========================
/datum/theft_objective/highrisk
	flags = THEFT_FLAG_HIGHRISK

/datum/theft_objective/highrisk/antique_laser_gun
	id = "cap_laser"
	name = "the captain's antique laser gun"
	typepath = /obj/item/gun/energy/laser/captain
	protected_jobs = list(JOB_TITLE_CAPTAIN)

/datum/theft_objective/highrisk/secgl_x4
	id = "secgl_x4"
	name = "the security grenade launcher GL-08-4"
	typepath = /obj/item/gun/projectile/bombarda/secgl/x4
	protected_jobs = list(JOB_TITLE_HOS)

/datum/theft_objective/highrisk/captains_rapier
	id = "cap_rapier"
	name = "the captain's rapier"
	typepath = /obj/item/melee/rapier/captain
	protected_jobs = list(JOB_TITLE_CAPTAIN)

/datum/theft_objective/highrisk/hoslaser
	id = "hos_laser"
	name = "the head of security's X-01 multiphase energy gun"
	typepath = /obj/item/gun/energy/gun/hos
	protected_jobs = list(JOB_TITLE_HOS)

/datum/theft_objective/highrisk/hand_tele
	id = "hand_tele"
	name = "a hand teleporter"
	typepath = /obj/item/hand_tele
	protected_jobs = list(JOB_TITLE_CAPTAIN, JOB_TITLE_RD, JOB_TITLE_CHIEF_ENGINEER)

/datum/theft_objective/highrisk/ai
	id = "func_AI"
	name = "a functional AI"
	typepath = /obj/item/aicard
	location_override = "AI Satellite. An intellicard for transportation can be found in Tech Storage, Science Department or manufactured"

/datum/theft_objective/highrisk/ai/check_special_completion(obj/item/aicard/card)
	if(!istype(card))
		return FALSE
	for(var/mob/living/silicon/ai/ai in card)
		if(isAI(ai) && ai.stat != DEAD) //See if any AI's are alive inside that card.
			return TRUE
	return FALSE

/datum/theft_objective/highrisk/defib
	id = "chief_defib"
	name = "an advanced compact defibrillator"
	typepath = /obj/item/defibrillator/compact/advanced
	protected_jobs = list(JOB_TITLE_CMO, JOB_TITLE_PARAMEDIC)

/datum/theft_objective/highrisk/magboots
	id = "chief_magboots"
	name = "the chief engineer's advanced magnetic boots"
	typepath = /obj/item/clothing/shoes/magboots/advance
	protected_jobs = list(JOB_TITLE_CHIEF_ENGINEER)

/datum/theft_objective/highrisk/combatrcd
	id = "chief_crcd"
	name = "the chief engineer's combat RCD"
	typepath = /obj/item/rcd/combat
	protected_jobs = list(JOB_TITLE_CHIEF_ENGINEER)

/datum/theft_objective/highrisk/blueprints
	id = "chief_blueprints"
	name = "the station blueprints"
	typepath = /obj/item/areaeditor/blueprints/ce
	protected_jobs = list(JOB_TITLE_CHIEF_ENGINEER)
	altitems = list(/obj/item/photo)

/datum/theft_objective/highrisk/blueprints/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/areaeditor/blueprints/ce))
		return TRUE
	if(istype(I, /obj/item/photo))
		var/obj/item/photo/P = I
		if(P.blueprints)
			return TRUE
	return FALSE

/datum/theft_objective/highrisk/capmedal
	id = "captain_medal"
	name = "the medal of captaincy"
	typepath = /obj/item/clothing/accessory/medal/gold/captain
	protected_jobs = list(JOB_TITLE_CAPTAIN)

/datum/theft_objective/highrisk/nukedisc
	id = "nuke_disc"
	name = "the nuclear authentication disk"
	typepath = /obj/item/disk/nuclear
	protected_jobs = list(JOB_TITLE_CAPTAIN)

/datum/theft_objective/highrisk/reactive
	id = "reactive_armor"
	name = "the reactive teleport armor"
	typepath = /obj/item/clothing/suit/armor/reactive/teleport
	protected_jobs = list(JOB_TITLE_RD)

/datum/theft_objective/highrisk/documents
	id = "secret_documents"
	name = "any set of secret documents of any organization"
	typepath = /obj/item/documents //Any set of secret documents. Doesn't have to be NT's
	altitems = list(/obj/item/folder/documents)

/datum/theft_objective/highrisk/documents/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/documents))
		return TRUE
	if(istype(I, /obj/item/folder/documents))
		if(!I.contents)
			return FALSE
		for(var/obj/item/content_item in I.contents)
			if(istype(content_item, /obj/item/documents))
				return TRUE
	return FALSE

/datum/theft_objective/highrisk/hypospray
	id = "chief_hypospray"
	name = "the Chief Medical Officer's hypospray"
	typepath = /obj/item/reagent_containers/hypospray/CMO
	protected_jobs = list(JOB_TITLE_CMO)

/datum/theft_objective/highrisk/reflector
	id = "reflector_armor"
	name = "a reflector coat"
	typepath = /obj/item/clothing/suit/armor/reflector
	protected_jobs = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN)

/datum/theft_objective/highrisk/krav
	id = "krav_maga"
	name = "the warden's krav maga martial arts gloves"
	typepath = /obj/item/clothing/gloves/color/black/krav_maga/sec
	protected_jobs = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN)

/datum/theft_objective/highrisk/supermatter_sliver
	id = "supermatter_sliver"
	name = "a supermatter sliver"
	typepath = /obj/item/nuke_core/supermatter_sliver
	protected_jobs = list(JOB_TITLE_CHIEF_ENGINEER, JOB_TITLE_ENGINEER, JOB_TITLE_ATMOSTECH) //Unlike other steal objectives, all jobs in the department have easy access, and would not be noticed at all stealing this
	location_override = "Engineering. You can use the box and instructions provided to harvest the sliver"
	special_equipment = /obj/item/storage/box/syndie_kit/supermatter
	job_possession = FALSE //The CE / engineers / atmos techs do not carry around supermater slivers.

/datum/theft_objective/highrisk/plutonium_core
	id = "plutonium_core"
	name = "the plutonium core from the stations nuclear device"
	typepath = /obj/item/nuke_core/plutonium
	location_override = "the Vault. You can use the box and instructions provided to remove the core, with some extra tools"
	special_equipment = /obj/item/storage/box/syndie_kit/nuke

//==========================
//==========Unique==========
//==========================
/datum/theft_objective/unique
	flags = THEFT_FLAG_UNIQUE

/datum/theft_objective/unique/docs_red
	id = "docs_red"
	name = "the \"Red\" secret documents"
	typepath = /obj/item/documents/syndicate/red

/datum/theft_objective/unique/docs_blue
	id = "docs_blue"
	name = "the \"Blue\" secret documents"
	typepath = /obj/item/documents/syndicate/blue

//==========================
//========Hard Thief========
//==========================
//==========================
//=======Medium Thief=======
//==========================
//==========================
//========Structures========
//==========================
//==========================
//==========Animals=========
//==========================
//==========================
//========Collection========
//==========================
//=======Collect Types=======
//=====Collection Number=====
