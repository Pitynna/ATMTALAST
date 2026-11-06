/// Laboratory devices use a shared, access-checked browser interface.
/obj/machinery/xenoarch
	name = "xenoarchaeology laboratory instrument"
	icon = 'icons/obj/xenoarch_machines.dmi'
	icon_state = "analyser"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 50
	active_power_usage = 500
	req_access = list(ACCESS_XENOARCH)
	var/report = "No analysis performed."
	var/finish_at = 0
	var/atom/movable/specimen
	var/board_type

/obj/machinery/xenoarch/Initialize(mapload)
	. = ..()
	if(!board_type)
		return
	component_parts = list(new board_type(null))
	var/obj/item/circuitboard/board = component_parts[1]
	for(var/component_type in board.req_components)
		for(var/i in 1 to board.req_components[component_type])
			component_parts += new component_type(null)
	RefreshParts()

/obj/machinery/xenoarch/screwdriver_act(mob/living/user, obj/item/tool)
	if(finish_at || specimen?.loc == src)
		return FALSE
	return default_deconstruction_screwdriver(user, icon_state, icon_state, tool)

/obj/machinery/xenoarch/crowbar_act(mob/living/user, obj/item/tool)
	if(finish_at || specimen?.loc == src)
		return FALSE
	return default_deconstruction_crowbar(user, tool)

/obj/machinery/xenoarch/Destroy()
	if(specimen?.loc == src)
		specimen.forceMove(get_turf(src))
	specimen = null
	return ..()

/obj/machinery/xenoarch/proc/available(mob/user)
	return user && user.Adjacent(src) && !user.incapacitated() && allowed(user) && !panel_open && !(stat & (NOPOWER|BROKEN))

/obj/machinery/xenoarch/attack_hand(mob/user)
	if(!available(user))
		to_chat(user, span_warning("The instrument requires power and Xenoarchaeology access."))
		return
	show_interface(user)

/obj/machinery/xenoarch/proc/show_interface(mob/user)
	var/dat = "<h2>[name]</h2><p>[report]</p><p>[finish_at ? "Analysis in progress." : "Ready."]</p>"
	dat += "<p><a href='byond://?src=[UID()];start=1'>Start analysis</a> | <a href='byond://?src=[UID()];eject=1'>Eject specimen</a> | <a href='byond://?src=[UID()];print=1'>Print last report</a> | <a href='byond://?src=[UID()];refresh=1'>Refresh</a></p>"
	var/datum/browser/popup = new(user, "xenoarch_[UID()]", name, 560, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/xenoarch/Topic(href, href_list)
	if(..() || !available(usr))
		return
	if(href_list["eject"])
		if(!finish_at && specimen?.loc == src)
			specimen.forceMove(get_turf(src))
			specimen = null
	if(href_list["start"] && !finish_at)
		start_analysis(usr)
	if(href_list["print"] && report != initial(report))
		print_report()
	show_interface(usr)

/obj/machinery/xenoarch/proc/start_analysis(mob/user)
	if(QDELETED(specimen))
		to_chat(user, span_warning("Insert a specimen first."))
		return FALSE
	finish_at = world.time + 10 SECONDS
	update_use_power(ACTIVE_POWER_USE)
	return TRUE

/obj/machinery/xenoarch/proc/print_report()
	var/obj/item/paper/paper = new(get_turf(src))
	paper.name = "[name] report"
	paper.info = "<h2>[name]</h2>[report]"
	paper.update_icon()

/obj/machinery/xenoarch/process()
	if(!finish_at)
		return
	if(stat & (NOPOWER|BROKEN))
		finish_at = 0
		update_use_power(IDLE_POWER_USE)
		return
	if(world.time < finish_at)
		return
	finish_at = 0
	update_use_power(IDLE_POWER_USE)
	complete_analysis()

/obj/machinery/xenoarch/proc/complete_analysis()
	return

/obj/machinery/xenoarch/spectrometer
	board_type = /obj/item/circuitboard/xenoarch_spectrometer
	name = "geological mass spectrometer"
	desc = "Identifies chemical carriers, geological age and exotic particle signatures in sealed core samples."
	icon_state = "analyser"

/obj/machinery/xenoarch/spectrometer/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/xenoarch_sample) && !specimen && available(user) && !finish_at)
		if(user.drop_transfer_item_to_loc(item, src))
			specimen = item
			show_interface(user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/machinery/xenoarch/spectrometer/complete_analysis()
	if(!istype(specimen, /obj/item/xenoarch_sample) || specimen.loc != src)
		return
	var/obj/item/xenoarch_sample/sample = specimen
	report = "Sample location: [sample.source_coords].<br>Estimated age: [sample.age] million years.<br>Dominant responsive carrier: [sample.carrier].<br>Artifact signature: [sample.anomaly_id]."
	if(sample.anomaly_id != "none")
		report += "<br>Estimated distance from sample: [sample.anomaly_distance] tiles."
	print_report()

/obj/structure/xenoarch_scanpad
	name = "artifact scanning pad"
	desc = "Pull an excavated artifact onto this pad for analysis or particle extraction."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "tele0"
	anchored = TRUE
	density = FALSE
	layer = BELOW_OBJ_LAYER

/obj/structure/xenoarch_chamber
	name = "evacuated spectrometer chamber"
	desc = "A sealed instrument cell belonging to the adjacent geological mass spectrometer. Samples are loaded at the laboratory's analyser console."
	icon = 'icons/obj/xenoarch_machines.dmi'
	icon_state = "analyser"
	density = TRUE
	anchored = TRUE
	max_integrity = 200

/obj/structure/xenoarch_chamber/Initialize(mapload)
	. = ..()
	recalculate_atmos_connectivity()

/obj/structure/xenoarch_chamber/CanAtmosPass(direction)
	return !density

/obj/structure/xenoarch_chamber/Destroy()
	var/turf/location = get_turf(src)
	. = ..()
	location?.recalculate_atmos_connectivity()

/obj/machinery/xenoarch/proc/find_artifact()
	for(var/obj/structure/xenoarch_scanpad/pad in range(1, src))
		var/obj/machinery/xenoarch_artifact/artifact = locate() in get_turf(pad)
		if(artifact && !QDELETED(artifact))
			return artifact

/obj/machinery/xenoarch/analyser
	board_type = /obj/item/circuitboard/xenoarch_analyser
	name = "artifact analyser"
	desc = "Identifies small excavated relics or a large alien device on an adjacent scanning pad."
	icon_state = "isolator"

/obj/machinery/xenoarch/analyser/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/xenoarch_relic) && !specimen && available(user) && !finish_at)
		if(user.drop_transfer_item_to_loc(item, src))
			specimen = item
			show_interface(user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/machinery/xenoarch/analyser/start_analysis(mob/user)
	if(!specimen || specimen.loc != src)
		specimen = find_artifact()
	return ..()

/obj/machinery/xenoarch/analyser/complete_analysis()
	if(istype(specimen, /obj/item/xenoarch_relic) && specimen.loc == src)
		var/obj/item/xenoarch_relic/relic = specimen
		relic.analyse()
		report = "Find [relic.artifact_id]: [relic.name].<br>Classification: [relic.category].<br>Research potential: [relic.origin_tech].<br>Eject the relic and use a destructive analyser to advance R&amp;D."
	else if(istype(specimen, /obj/machinery/xenoarch_artifact) && specimen == find_artifact())
		var/obj/machinery/xenoarch_artifact/artifact = specimen
		report = "Artifact [artifact.artifact_id].<br>Primary effect: [artifact.effect_type].<br>Activation trigger: [artifact.trigger_type].<br>Effect delivery: [artifact.effect_mode].<br>Effective range: [artifact.effect_range] tiles.<br>Status: [artifact.activated ? "active" : "dormant"]."
		if(!artifact.research_sample_taken)
			artifact.research_sample_taken = TRUE
			var/obj/item/xenoarch_relic/sample = new(get_turf(src))
			sample.name = "alien artifact research sample"
			sample.artifact_id = artifact.artifact_id
			sample.category = "temple"
			sample.tech_level = 6
			sample.analyse()
	else
		report = "Analysis aborted: specimen removed from the scanning pad."
	print_report()

/obj/machinery/xenoarch/harvester
	board_type = /obj/item/circuitboard/xenoarch_harvester
	name = "exotic particle harvester"
	desc = "Extracts a limited supply of exotic particles from an artifact on an adjacent pad into an anomaly battery."
	icon_state = "incubator"
	var/datum/weakref/source_artifact

/obj/machinery/xenoarch/harvester/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/xenoarch_battery) && !specimen && available(user) && !finish_at)
		if(user.drop_transfer_item_to_loc(item, src))
			specimen = item
			show_interface(user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/machinery/xenoarch/harvester/start_analysis(mob/user)
	var/obj/machinery/xenoarch_artifact/artifact = find_artifact()
	if(!artifact || !istype(specimen, /obj/item/xenoarch_battery))
		to_chat(user, span_warning("Insert a battery and place an artifact on an adjacent scanning pad."))
		return FALSE
	var/obj/item/xenoarch_battery/battery = specimen
	if(battery.charges)
		to_chat(user, span_warning("The battery must be empty."))
		return FALSE
	source_artifact = WEAKREF(artifact)
	. = ..()
	if(.)
		finish_at = world.time + 30 SECONDS

/obj/machinery/xenoarch/harvester/complete_analysis()
	var/obj/machinery/xenoarch_artifact/artifact = source_artifact?.resolve()
	if(!artifact || artifact != find_artifact() || !istype(specimen, /obj/item/xenoarch_battery) || specimen.loc != src)
		report = "Extraction aborted: artifact or battery removed."
		return
	var/obj/item/xenoarch_battery/battery = specimen
	battery.effect_type = artifact.effect_type
	battery.charges = 10
	battery.update_icon(UPDATE_ICON_STATE)
	report = "Artifact [artifact.artifact_id]: extracted [battery.charges] charges of [battery.effect_type]. Eject the battery and insert it into an anomaly utilizer."
	print_report()

/obj/machinery/xenoarch/suspension
	board_type = /obj/item/circuitboard/xenoarch_suspension
	name = "anomaly suspension generator"
	desc = "While powered and enabled, suppresses artifacts and anomaly utilizers within three tiles. Activate to toggle the field."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "suspension2"
	active_power_usage = 1000
	var/enabled = FALSE

/obj/machinery/xenoarch/suspension/Initialize(mapload)
	. = ..()
	GLOB.xenoarch_containment |= src

/obj/machinery/xenoarch/suspension/Destroy()
	GLOB.xenoarch_containment -= src
	return ..()

/obj/machinery/xenoarch/suspension/attack_hand(mob/user)
	if(!available(user))
		return
	enabled = !enabled
	update_use_power(enabled ? ACTIVE_POWER_USE : IDLE_POWER_USE)
	to_chat(user, span_notice("Suspension field [enabled ? "enabled" : "disabled"]."))
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/xenoarch/suspension/examine(mob/user)
	. = ..()
	. += span_notice("The field is [enabled && !(stat & (NOPOWER|BROKEN)) ? "active" : "inactive"].")

/obj/machinery/xenoarch/suspension/update_icon_state()
	icon_state = enabled && !(stat & (NOPOWER|BROKEN)) ? "suspension1" : "suspension2"
