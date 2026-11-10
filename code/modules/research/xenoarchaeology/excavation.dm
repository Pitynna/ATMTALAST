/// Modern adaptation of the pre-2017 ATMTA/Paradise xenoarchaeology system.
/// Source and differences are documented in docs/XENOARCHAEOLOGY.md.
GLOBAL_LIST_EMPTY(xenoarch_sites)
GLOBAL_LIST_EMPTY(xenoarch_containment)

/datum/xenoarch_find
	var/id
	var/depth
	var/clearance
	var/category
	var/carrier
	var/large = FALSE
	var/destroyed = FALSE
	var/recovered = FALSE

/datum/xenoarch_find/New(is_large = FALSE, site_category)
	..()
	id = "XA-[UID()]"
	depth = rand(40, 180)
	clearance = pick(2, 4, 6, 8)
	large = is_large
	category = site_category ? site_category : pick("domestic", "technical", "temple", "fossil", "botanical")
	switch(category)
		if("domestic")
			carrier = "mercury"
		if("technical")
			carrier = "iron"
		if("temple")
			carrier = "potassium"
		if("fossil", "botanical")
			carrier = "carbon"

/// Only selected asteroid rocks own this datum. It is never seeded on station walls.
/datum/xenoarch_site
	var/list/finds = list()
	var/excavated = 0
	var/busy = FALSE
	var/age

/datum/xenoarch_site/New(is_large = FALSE, site_category)
	..()
	age = rand(50, 9000)
	finds += new /datum/xenoarch_find(is_large, site_category)

/datum/xenoarch_site/Destroy()
	QDEL_LIST(finds)
	return ..()

/datum/xenoarch_site/proc/next_find()
	for(var/datum/xenoarch_find/find as anything in finds)
		if(!find.destroyed && !find.recovered)
			return find

/datum/xenoarch_site/proc/scan_report()
	var/datum/xenoarch_find/find = next_find()
	if(!find)
		return "No intact inclusions remain. Excavated depth: [excavated] cm."
	return "Inclusion [find.id]: depth [find.depth] cm; clearance [find.clearance] cm; excavated [excavated] cm. Remaining overburden: [max(0, find.depth - excavated)] cm. [find.large ? "A large hollow structure is present." : "A small inclusion is present."]"

/// Snapshot of geological information; it survives mining or deleting its source turf.
/obj/item/xenoarch_sample
	name = "sealed geological sample"
	desc = "A labelled core sample for the outpost's spectrometer."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "sliver1"
	w_class = WEIGHT_CLASS_TINY
	var/source_coords
	var/age
	var/carrier = "chlorine"
	var/anomaly_id = "none"
	var/anomaly_distance

/obj/item/xenoarch_sample/proc/take_sample(turf/simulated/mineral/rock)
	source_coords = "[rock.x]:[rock.y]:[rock.z]"
	age = rock.archaeology ? rock.archaeology.age : rand(50, 9000)
	var/datum/xenoarch_find/find = rock.archaeology?.next_find()
	if(find)
		carrier = find.carrier
		anomaly_id = find.id
		anomaly_distance = 0
	else
		var/nearest = INFINITY
		for(var/turf/simulated/mineral/candidate as anything in GLOB.xenoarch_sites)
			if(candidate.z != rock.z || QDELETED(candidate))
				continue
			var/datum/xenoarch_find/nearby = candidate.archaeology?.next_find()
			if(!nearby?.large)
				continue
			var/distance = get_dist(rock, candidate)
			if(distance < nearest && distance <= 60)
				nearest = distance
				anomaly_distance = distance
				anomaly_id = nearby.id

/turf/simulated/mineral
	var/datum/xenoarch_site/archaeology

/turf/simulated/mineral/Destroy()
	GLOB.xenoarch_sites -= src
	QDEL_NULL(archaeology)
	return ..()

/turf/simulated/mineral/proc/excavate(obj/item/xenoarch_tool/pick/tool, mob/living/user)
	if(!user || !user.IsAdvancedToolUser() || !user.Adjacent(src) || !user.is_in_hands(tool))
		return
	if(!archaeology)
		to_chat(user, span_notice("The scanner would be useful here: no archaeological site has been identified in this rock."))
		return
	if(archaeology.busy)
		return
	archaeology.busy = TRUE
	to_chat(user, span_notice("You begin carefully excavating [src] with [tool]."))
	if(!do_after(user, tool.excavation_time, src, category = DA_CAT_TOOL))
		if(ismineralturf(src) && !QDELETED(src) && archaeology)
			archaeology.busy = FALSE
		return
	if(!ismineralturf(src) || QDELETED(src) || !archaeology)
		return
	archaeology.busy = FALSE
	if(!user.is_in_hands(tool))
		return
	var/result = archaeology.advance(tool.excavation_depth, src)
	to_chat(user, span_notice(result))
	playsound(src, 'sound/items/Screwdriver.ogg', 30, TRUE)

/// Depths are centimetres. Crossing an inclusion by more than its clearance destroys it.
/datum/xenoarch_site/proc/advance(amount, turf/location)
	excavated = min(200, excavated + amount)
	var/message = "Excavated to [excavated] cm."
	for(var/datum/xenoarch_find/find as anything in finds)
		if(find.destroyed || find.recovered || excavated < find.depth)
			continue
		if(excavated > find.depth + find.clearance)
			find.destroyed = TRUE
			message += " An inclusion crumbles into worthless fragments: the tool cut too deeply."
			continue
		find.recovered = TRUE
		if(find.large)
			var/obj/structure/xenoarch_boulder/boulder = new(location)
			boulder.artifact_id = find.id
			message += " A large encrusted artifact has been exposed. Remove the remaining matrix with fine tools."
		else
			var/obj/item/xenoarch_relic/relic = new(location)
			relic.configure(find)
			message += " You carefully free [relic]."
	return message

/obj/structure/xenoarch_boulder
	name = "encrusted alien artifact"
	desc = "An ancient device trapped in a thin mineral matrix. Use the depth scanner and fine excavation tools."
	icon = 'icons/obj/mining.dmi'
	icon_state = "boulder1"
	density = TRUE
	anchored = FALSE
	var/artifact_id
	var/matrix_depth = 20
	var/cleaned = 0
	var/clearance = 2
	var/busy = FALSE

/obj/structure/xenoarch_boulder/proc/advance(amount)
	cleaned += amount
	if(cleaned > matrix_depth + clearance)
		visible_message(span_warning("[src] shatters, destroying the device inside!"))
		qdel(src)
		return FALSE
	if(cleaned >= matrix_depth)
		var/obj/machinery/xenoarch_artifact/artifact = new(get_turf(src))
		artifact.artifact_id = artifact_id
		visible_message(span_notice("The last mineral flakes fall away from [artifact]."))
		qdel(src)
	return TRUE

/obj/structure/xenoarch_boulder/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/xenoarch_tool/pick))
		if(busy || !user.is_in_hands(item))
			return ATTACK_CHAIN_BLOCKED_ALL
		var/obj/item/xenoarch_tool/pick/tool = item
		busy = TRUE
		if(do_after(user, tool.excavation_time, src, category = DA_CAT_TOOL) && !QDELETED(src) && user.is_in_hands(tool))
			advance(tool.excavation_depth)
		if(!QDELETED(src))
			busy = FALSE
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/item/xenoarch_relic
	name = "ancient alien relic"
	desc = "An excavated object from a long-dead civilisation. A laboratory analyser can identify its research value."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "unknown1"
	w_class = WEIGHT_CLASS_SMALL
	var/artifact_id
	var/category
	var/analysed = FALSE
	var/tech_level = 3

/obj/item/xenoarch_relic/proc/configure(datum/xenoarch_find/find)
	artifact_id = find.id
	category = find.category
	tech_level = rand(3, 6)
	switch(category)
		if("domestic")
			name = pick("ancient bowl", "ancient urn", "alien statuette", "ancient coin")
		if("technical")
			name = pick("ancient circuit fragment", "alien machine component", "ancient tool")
		if("temple")
			name = pick("alien ceremonial crystal", "carved alien tablet", "alien ritual instrument")
		if("fossil")
			name = pick("fossilised alien skull", "fossilised alien shell", "fossilised alien bone")
		if("botanical")
			name = "fossilised alien plant"
	switch(category)
		if("domestic")
			icon_state = pick("bowl", "urn", "statuette", "instrument")
		if("fossil")
			icon_state = pick("bone", "skull", "shell")
		if("botanical")
			icon_state = "plant[rand(1, 4)]"
		if("temple")
			icon_state = pick("changerock", "Green lump", "statuette")
		else
			icon_state = "unknown[rand(1, 4)]"

/obj/item/xenoarch_relic/proc/analyse()
	analysed = TRUE
	var/tree = RESEARCH_TREE_MATERIALS
	switch(category)
		if("technical")
			tree = RESEARCH_TREE_ENGINEERING
		if("temple")
			tree = RESEARCH_TREE_BLUESPACE
		if("fossil", "botanical")
			tree = RESEARCH_TREE_BIOTECH
	origin_tech = "[tree]=[tech_level];[RESEARCH_TREE_MATERIALS]=[tech_level]"
	desc = "An identified [category] find, catalogued as [artifact_id]. Its structure can advance research in a destructive analyser."


/// Ore turfs may replace themselves during Initialize. Seed after that replacement,

/// as well as after cave generation, so both small and large finds survive startup.

/obj/effect/landmark/xenoarch_initializer

	name = "archaeology initialization"



/obj/effect/landmark/xenoarch_initializer/Initialize(mapload)

	. = ..()

	return INITIALIZE_HINT_LATELOAD



/obj/effect/landmark/xenoarch_initializer/LateInitialize()

	seed_xenoarchaeology(z)

	qdel(src)



/proc/seed_xenoarchaeology(mining_z)

	var/list/candidates = list()
	for(var/turf/simulated/mineral/rock as anything in Z_TURFS(mining_z))
		if(istype(rock) && istype(get_area(rock), /area/mine/unexplored) && !istype(rock, /turf/simulated/mineral/gibtonite))
			candidates += rock
	if(!length(candidates))
		return
	for(var/i in 1 to min(80, length(candidates)))
		var/turf/simulated/mineral/centre = pick_n_take(candidates)
		var/category = pick("domestic", "technical", "temple", "fossil", "botanical")
		var/list/cluster = list(centre)
		for(var/turf/simulated/mineral/nearby in range(2, centre))
			if((nearby in candidates) && prob(35))
				cluster |= nearby
		for(var/turf/simulated/mineral/rock as anything in cluster)
			if(rock.archaeology)
				continue
			rock.archaeology = new(FALSE, category)
			GLOB.xenoarch_sites |= rock
			candidates -= rock
		CHECK_TICK
	for(var/i in 1 to min(10, length(candidates)))
		var/turf/simulated/mineral/rock = pick_n_take(candidates)
		rock.archaeology = new(TRUE, "temple")
		GLOB.xenoarch_sites |= rock
	log_world("Seeded [length(GLOB.xenoarch_sites)] xenoarchaeology sites on the mining asteroid.")
