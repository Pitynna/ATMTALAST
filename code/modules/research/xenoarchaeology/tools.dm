/obj/item/xenoarch_tool
	icon = 'icons/obj/xenoarchaeology.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL = 500, MAT_GLASS = 100)
	origin_tech = "materials=1;engineering=1"

/obj/item/xenoarch_tool/pick
	name = "excavation pick (2 cm)"
	desc = "A precise excavation tool. Its label gives the depth removed per stroke. Scan before digging; overshooting destroys finds."
	icon_state = "pick1"
	force = 3
	var/excavation_depth = 2
	var/excavation_time = 2 SECONDS

/obj/item/xenoarch_tool/pick/brush
	name = "excavation brush (1 cm)"
	icon_state = "pick_brush"
	excavation_depth = 1
	force = 0

/obj/item/xenoarch_tool/pick/four
	name = "excavation pick (4 cm)"
	icon_state = "pick2"
	excavation_depth = 4

/obj/item/xenoarch_tool/pick/six
	name = "excavation pick (6 cm)"
	icon_state = "pick3"
	excavation_depth = 6

/obj/item/xenoarch_tool/pick/ten
	name = "excavation pick (10 cm)"
	icon_state = "pick4"
	excavation_depth = 10

/obj/item/xenoarch_tool/pick/thirty
	name = "excavation pick (30 cm)"
	icon_state = "pick5"
	excavation_depth = 30

/obj/item/xenoarch_tool/depth_scanner
	name = "depth analysis scanner"
	desc = "Scans a rock for the depth and clearance of ancient inclusions. Activate it to review the last twenty readings."
	icon = 'icons/obj/device.dmi'
	icon_state = "gem_analyzer"
	var/list/readings = list()

/obj/item/xenoarch_tool/depth_scanner/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	var/report
	if(istype(target, /turf/simulated/mineral))
		var/turf/simulated/mineral/rock = target
		report = rock.archaeology ? rock.archaeology.scan_report() : "No archaeological inclusions detected."
	else if(istype(target, /obj/structure/xenoarch_boulder))
		var/obj/structure/xenoarch_boulder/boulder = target
		report = "Artifact [boulder.artifact_id]: matrix thickness [boulder.matrix_depth] cm; cleaned [boulder.cleaned] cm; clearance [boulder.clearance] cm."
	else
		return
	report = "[target.x]:[target.y]:[target.z] — [report]"
	readings += report
	if(length(readings) > 20)
		readings.Cut(1, 2)
	to_chat(user, span_notice(report))
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)

/obj/item/xenoarch_tool/depth_scanner/attack_self(mob/user)
	for(var/reading in readings)
		to_chat(user, span_notice(reading))
	if(!length(readings))
		to_chat(user, span_notice("No scans recorded."))

/obj/item/xenoarch_tool/core_sampler
	name = "geological core sampler"
	desc = "Extracts labelled samples from rock. Analyse samples in the mass spectrometer to identify digsites and locate large artifacts."
	icon = 'icons/obj/device.dmi'
	icon_state = "robotanalyzer"
	var/busy = FALSE

/obj/item/xenoarch_tool/core_sampler/afterattack(atom/target, mob/living/user, proximity, params)
	if(!proximity || busy || !istype(target, /turf/simulated/mineral))
		return
	busy = TRUE
	if(do_after(user, 2 SECONDS, target, category = DA_CAT_TOOL) && !QDELETED(src) && user.is_in_hands(src) && ismineralturf(target))
		var/obj/item/xenoarch_sample/sample = new(get_turf(user))
		sample.take_sample(target)
		user.put_in_hands(sample)
		to_chat(user, span_notice("You seal and label a sample from [sample.source_coords]."))
	busy = FALSE

/obj/item/xenoarch_tool/anomaly_scanner
	name = "Alden-Saraspova counter"
	desc = "Detects large buried artifacts within sixty tiles. Repeated readings narrow down their location."
	icon_state = "flashgun"

/obj/item/xenoarch_tool/anomaly_scanner/attack_self(mob/user)
	var/turf/location = get_turf(user)
	var/nearest = INFINITY
	var/datum/xenoarch_find/result
	for(var/turf/simulated/mineral/rock as anything in GLOB.xenoarch_sites)
		if(rock.z != location.z || QDELETED(rock))
			continue
		var/datum/xenoarch_find/find = rock.archaeology?.next_find()
		if(!find?.large)
			continue
		var/distance = get_dist(location, rock)
		if(distance < nearest && distance <= 60)
			nearest = distance
			result = find
	if(result)
		to_chat(user, span_notice("[result.id]: exotic particle source approximately [nearest] tiles away."))
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	else
		to_chat(user, span_notice("No buried exotic particle sources detected within sixty tiles."))

/obj/item/storage/box/excavation
	name = "excavation pick set"
	desc = "Six labelled tools for removing 1, 2, 4, 6, 10 or 30 centimetres of rock."
	storage_slots = 7

/obj/item/storage/box/excavation/populate_contents()
	new /obj/item/xenoarch_tool/pick/brush(src)
	new /obj/item/xenoarch_tool/pick(src)
	new /obj/item/xenoarch_tool/pick/four(src)
	new /obj/item/xenoarch_tool/pick/six(src)
	new /obj/item/xenoarch_tool/pick/ten(src)
	new /obj/item/xenoarch_tool/pick/thirty(src)

/obj/item/storage/belt/archaeology
	name = "excavation belt"
	desc = "A belt for an archaeologist's instruments and samples."
	icon_state = "utilitybelt"
	item_state = "utility"

/obj/item/storage/belt/archaeology/Initialize(mapload)
	. = ..()
	can_hold = list(/obj/item/xenoarch_tool, /obj/item/xenoarch_sample, /obj/item/xenoarch_relic, /obj/item/flashlight, /obj/item/gps)

/obj/structure/closet/secure_closet/xenoarchaeologist
	name = "xenoarchaeology equipment locker"
	req_access = list(ACCESS_XENOARCH)

/obj/structure/closet/secure_closet/xenoarchaeologist/populate_contents()
	new /obj/item/storage/box/excavation(src)
	new /obj/item/xenoarch_tool/depth_scanner(src)
	new /obj/item/xenoarch_tool/core_sampler(src)
	new /obj/item/xenoarch_tool/anomaly_scanner(src)
	new /obj/item/storage/belt/archaeology(src)
	new /obj/item/gps(src)
	new /obj/item/flashlight/lantern(src)
	new /obj/item/clothing/suit/space/hardsuit/mining(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/oxygen(src)
	new /obj/item/book/manual/xenoarchaeology(src)

/obj/item/book/manual/xenoarchaeology
	name = "Practical Xenoarchaeology"
	title = "Practical Xenoarchaeology"
	author = "Nanotrasen Expeditionary Science"
	icon_state = "book4"
	dat = {"<h2>Field work</h2><p>Take a mining shuttle to the asteroid, then follow the marked surface route north to the Research Outpost. Scientists and the Research Director have Xenoarchaeology access. Wear a hardsuit, helmet and internals outside.</p><p>Search rocks using the depth scanner. The Alden-Saraspova counter locates large buried artifacts. Core samples analysed in the mass spectrometer reveal chemical carriers and nearby artifact signatures.</p><h2>Excavation</h2><p>Depth and clearance are in centimetres. Choose the labelled 30, 10, 6, 4, 2 or 1 cm tool to reach the inclusion without passing its clearance. Scan again as needed. Ordinary mining and explosives destroy buried finds. Mine the opened rock to collect small relics; pull exposed boulders away and clean their 20 cm mineral matrix with fine tools. Overshooting destroys the artifact.</p><h2>Laboratory</h2><p>Insert small relics into the artifact analyser. Identified relics can then advance station R&amp;D through a destructive analyser. Pull large artifacts onto a blue scan pad beside an analyser. An analysis prints its effect, trigger and range, and yields one research sample per artifact.</p><h2>Containment and harvesting</h2><p>Artifacts may activate from bare-hand contact, impact, energy, chemicals, temperature or gases. Touch, aura and pulse effects can be helpful or harmful. Use isolation rooms and a powered suspension field to suppress them. Switch the field off to test activation. Insert an empty anomaly battery into a harvester beside the artifact's pad, then start extraction. Removing power interrupts the cycle. Fit a charged battery to an anomaly utilizer to reproduce its effect in a smaller area; every use consumes a charge.</p>"}
