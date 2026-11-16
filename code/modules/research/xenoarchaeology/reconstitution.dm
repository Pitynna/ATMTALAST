/// Fossil reconstitution: recovering extinct alien species from excavated fossils.
/// Reimagined from the pre-2017 ATMTA "Garland Corp genetic reconstitutor".
/// Design notes and balance numbers live in docs/XENOARCHAEOLOGY.md.

#define FOSSIL_GENOME_LENGTH 7
/// Bases per fragment. The first two repeat the previous fragment's last two.
#define FOSSIL_FRAGMENT_BASES 6
#define FOSSIL_KIND_FAUNA "fauna"
#define FOSSIL_KIND_FLORA "flora"

#define FOSSIL_FEEDBACK_MATCH "match"
#define FOSSIL_FEEDBACK_SHIFT "shift"
#define FOSSIL_FEEDBACK_FOREIGN "foreign"
#define FOSSIL_FEEDBACK_EMPTY "empty"

#define FOSSIL_FIDELITY_PRISTINE 80
#define FOSSIL_FIDELITY_STABLE 50
#define FOSSIL_FIDELITY_FLOOR 25
#define FOSSIL_FIDELITY_PER_FAILED_RUN 8

#define FOSSIL_SCAN_TIME (3 SECONDS)
#define FOSSIL_VERIFY_TIME (4 SECONDS)
#define FOSSIL_SEED_COOLDOWN (30 SECONDS)

#define FOSSIL_INCUBATOR_MAX_BIOMASS 300
#define FOSSIL_INCUBATOR_COST 100
#define FOSSIL_INCUBATOR_BASE_TIME (120 SECONDS)

GLOBAL_LIST_EMPTY(fossil_genebanks)

/// Genebanks are shared by every console of a kind, so rebuilding a console keeps progress.
/proc/get_fossil_genebank(kind)
	var/datum/fossil_genebank/bank = GLOB.fossil_genebanks[kind]
	if(!bank)
		bank = new(kind)
		GLOB.fossil_genebanks[kind] = bank
	return bank

/proc/fossil_grade(fidelity)
	if(fidelity >= FOSSIL_FIDELITY_PRISTINE)
		return "pristine"
	if(fidelity >= FOSSIL_FIDELITY_STABLE)
		return "stable"
	return "unstable"

/proc/random_fossil_bases(count)
	. = ""
	for(var/i in 1 to count)
		. += pick("A", "C", "G", "T")

/datum/fossil_genome
	/// Real species name, revealed once the sequence is assembled.
	var/species_name
	/// Mob or seed packet path produced from the completed sequence.
	var/result_type
	/// Sequential label shown while the species is unknown, e.g. "Sequence F-2".
	var/codename
	var/discovered = FALSE
	var/completed = FALSE
	/// Correct fragments in order.
	var/list/fragments = list()
	/// Fragments recovered from fossils so far.
	var/list/known = list()
	/// Player assembly: one fragment code or null per locus.
	var/list/slots
	/// Result of the latest verification run for each locus.
	var/list/feedback
	var/fidelity = 100
	var/runs = 0

/datum/fossil_genome/New(species_name, result_type)
	..()
	src.species_name = species_name
	src.result_type = result_type
	slots = new /list(FOSSIL_GENOME_LENGTH)
	feedback = new /list(FOSSIL_GENOME_LENGTH)

/// Builds overlapping fragments: each one starts with the last two bases of the previous one.
/datum/fossil_genome/proc/generate(list/taken)
	var/overlap = FOSSIL_FRAGMENT_BASES / 3
	var/core = FOSSIL_FRAGMENT_BASES - overlap
	for(var/attempt in 1 to 50)
		var/sequence = "ATG" + random_fossil_bases(FOSSIL_GENOME_LENGTH * core + overlap - 6) + "TAA"
		var/list/candidate = list()
		var/clash = FALSE
		for(var/i in 0 to FOSSIL_GENOME_LENGTH - 1)
			var/fragment = copytext(sequence, i * core + 1, i * core + FOSSIL_FRAGMENT_BASES + 1)
			if(taken[fragment] || (fragment in candidate))
				clash = TRUE
				break
			candidate += fragment
		if(clash)
			continue
		fragments = candidate
		for(var/fragment in fragments)
			taken[fragment] = src
		return TRUE
	CRASH("Could not generate unique fossil fragments")

/datum/fossil_genome/proc/missing_fragments()
	. = list()
	for(var/fragment in fragments)
		if(!known[fragment])
			. += fragment

/datum/fossil_genome/proc/grade()
	return fossil_grade(fidelity)

/datum/fossil_genome/proc/display_name()
	return completed ? species_name : codename

/// Puts a fragment on a locus. A fragment can only occupy one locus of a genome.
/datum/fossil_genome/proc/place(locus, fragment)
	if(completed || locus < 1 || locus > FOSSIL_GENOME_LENGTH)
		return FALSE
	var/previous = slots.Find(fragment)
	if(previous)
		slots[previous] = null
		feedback[previous] = null
	slots[locus] = fragment
	feedback[locus] = null
	return TRUE

/datum/fossil_genome/proc/clear_locus(locus)
	if(completed || locus < 1 || locus > FOSSIL_GENOME_LENGTH)
		return FALSE
	slots[locus] = null
	feedback[locus] = null
	return TRUE

/datum/fossil_genome/proc/clear_all()
	if(completed)
		return FALSE
	slots = new /list(FOSSIL_GENOME_LENGTH)
	feedback = new /list(FOSSIL_GENOME_LENGTH)
	return TRUE

/// A sequencing run: reports match/shift/foreign per locus. Failed runs degrade the sample.
/datum/fossil_genome/proc/verify()
	if(completed)
		return TRUE
	runs++
	var/correct = 0
	for(var/locus in 1 to FOSSIL_GENOME_LENGTH)
		var/fragment = slots[locus]
		if(!fragment)
			feedback[locus] = FOSSIL_FEEDBACK_EMPTY
		else if(fragments[locus] == fragment)
			feedback[locus] = FOSSIL_FEEDBACK_MATCH
			correct++
		else if(fragment in fragments)
			feedback[locus] = FOSSIL_FEEDBACK_SHIFT
		else
			feedback[locus] = FOSSIL_FEEDBACK_FOREIGN
	if(correct == FOSSIL_GENOME_LENGTH)
		completed = TRUE
		return TRUE
	fidelity = max(FOSSIL_FIDELITY_FLOOR, fidelity - FOSSIL_FIDELITY_PER_FAILED_RUN)
	return FALSE

/datum/fossil_genebank
	var/kind
	/// All species of this kind, discovered or not.
	var/list/genomes = list()
	/// Recovered fragment codes in discovery order. Degraded noise fragments are mixed in.
	var/list/pool = list()
	/// fragment code -> owning genome; noise fragments map to FALSE.
	var/list/owners = list()
	var/fossils_processed = 0
	var/next_codename = 1

/datum/fossil_genebank/New(kind)
	..()
	src.kind = kind
	var/list/species = (kind == FOSSIL_KIND_FAUNA) ? list(
		"samak" = /mob/living/simple_animal/hostile/prehistoric/samak,
		"diyaab" = /mob/living/simple_animal/hostile/prehistoric/diyaab,
		"shantak" = /mob/living/simple_animal/hostile/prehistoric/shantak,
		"yithian" = /mob/living/simple_animal/prehistoric/yithian,
		"tindalos" = /mob/living/simple_animal/prehistoric/tindalos,
	) : list(
		"telriis grass" = /obj/item/seeds/prehistoric/telriis,
		"thaa'dra lichen" = /obj/item/seeds/prehistoric/thaadra,
		"jurl'mah reeds" = /obj/item/seeds/prehistoric/jurlmah,
		"amauri plant" = /obj/item/seeds/prehistoric/amauri,
		"gelthi plant" = /obj/item/seeds/prehistoric/gelthi,
		"vale bush" = /obj/item/seeds/prehistoric/vale,
		"surik vine" = /obj/item/seeds/prehistoric/surik,
	)
	var/list/taken = list()
	for(var/name in species)
		var/datum/fossil_genome/genome = new(name, species[name])
		genome.generate(taken)
		genomes += genome

/datum/fossil_genebank/Destroy(force)
	QDEL_LIST(genomes)
	return ..()

/datum/fossil_genebank/proc/accepts_category(category)
	return category == ((kind == FOSSIL_KIND_FAUNA) ? "fossil" : "botanical")

/datum/fossil_genebank/proc/discovered_genomes()
	. = list()
	for(var/datum/fossil_genome/genome as anything in genomes)
		if(genome.discovered)
			. += genome

/datum/fossil_genebank/proc/has_unknown_data()
	for(var/datum/fossil_genome/genome as anything in genomes)
		if(!genome.discovered || length(genome.missing_fragments()))
			return TRUE
	return FALSE

/datum/fossil_genebank/proc/reveal(datum/fossil_genome/genome, fragment)
	genome.known[fragment] = TRUE
	pool += fragment
	owners[fragment] = genome

/datum/fossil_genebank/proc/add_noise()
	for(var/attempt in 1 to 20)
		var/fragment = random_fossil_bases(FOSSIL_FRAGMENT_BASES)
		if(isnull(owners[fragment]))
			pool += fragment
			owners[fragment] = FALSE
			return fragment

/// Extracts genetic data from one fossil. Returns a list of human readable results, or null if nothing new remains.
/datum/fossil_genebank/proc/process_fossil()
	if(!has_unknown_data())
		return null
	fossils_processed++
	. = list()
	var/list/undiscovered = list()
	var/list/incomplete = list()
	for(var/datum/fossil_genome/genome as anything in genomes)
		if(!genome.discovered)
			undiscovered += genome
		else if(length(genome.missing_fragments()))
			incomplete += genome
	var/discover_chance = length(incomplete) ? max(20, 60 - 15 * length(incomplete)) : 100
	if(length(undiscovered) && prob(discover_chance))
		var/datum/fossil_genome/genome = pick(undiscovered)
		genome.discovered = TRUE
		genome.codename = "Sequence [kind == FOSSIL_KIND_FAUNA ? "F" : "B"]-[next_codename++]"
		incomplete += genome
		. += "New gene sequence identified: [genome.codename]."
	var/fragments_found = prob(40) ? 2 : 1
	for(var/i in 1 to fragments_found)
		if(!length(incomplete))
			break
		var/datum/fossil_genome/genome = pick(incomplete)
		var/list/missing = genome.missing_fragments()
		var/fragment = pick(missing)
		reveal(genome, fragment)
		if(length(missing) == 1)
			incomplete -= genome
		. += "Fragment [fragment] recovered."
	if(prob(25))
		var/noise = add_noise()
		if(noise)
			. += "Fragment [noise] recovered (low confidence)."

/datum/fossil_genebank/proc/genome_by_index(index)
	var/list/known = discovered_genomes()
	if(index < 1 || index > length(known))
		return null
	return known[index]

/// Shared UI payload for both console kinds.
/datum/fossil_genebank/proc/ui_payload()
	var/list/genome_data = list()
	var/list/usage = list()
	var/index = 0
	for(var/datum/fossil_genome/genome as anything in discovered_genomes())
		index++
		var/list/slot_data = list()
		for(var/locus in 1 to FOSSIL_GENOME_LENGTH)
			var/fragment = genome.slots[locus]
			slot_data += list(list("fragment" = fragment, "feedback" = genome.feedback[locus]))
			if(fragment)
				LAZYADD(usage[fragment], genome.codename)
		genome_data += list(list(
			"index" = index,
			"codename" = genome.codename,
			"name" = genome.display_name(),
			"completed" = genome.completed,
			"recovered" = length(genome.known),
			"slots" = slot_data,
			"fidelity" = genome.fidelity,
			"grade" = genome.grade(),
			"runs" = genome.runs,
		))
	var/list/pool_data = list()
	for(var/fragment in pool)
		pool_data += list(list("code" = fragment, "used_by" = usage[fragment] || list()))
	return list(
		"genomes" = genome_data,
		"pool" = pool_data,
		"fossils_processed" = fossils_processed,
		"species_total" = length(genomes),
		"genome_length" = FOSSIL_GENOME_LENGTH,
		"exhausted" = !has_unknown_data(),
	)

// Consoles

/obj/machinery/computer/fossil_reconstitutor
	name = "fossil reconstitution console"
	desc = "Extracts degraded genetic material from fossils and assembles it into viable genomes."
	icon_keyboard = "rd_key"
	icon_screen = "dna"
	light_color = LIGHT_COLOR_CYAN
	req_access = list(ACCESS_XENOARCH, ACCESS_RESEARCH)
	check_one_access = TRUE
	abstract_type = /obj/machinery/computer/fossil_reconstitutor
	var/kind
	/// Text describing the running job, or null when idle.
	var/busy
	var/busy_until = 0
	/// Last scanner messages, newest first.
	var/list/scan_log = list()

/obj/machinery/computer/fossil_reconstitutor/proc/genebank()
	return get_fossil_genebank(kind)

/obj/machinery/computer/fossil_reconstitutor/proc/add_log(text)
	scan_log.Insert(1, "[station_time_timestamp()] [text]")
	if(length(scan_log) > 12)
		scan_log.Cut(13)

/obj/machinery/computer/fossil_reconstitutor/proc/is_fossil(obj/item/item)
	var/obj/item/xenoarch_relic/relic = item
	return istype(relic) && genebank().accepts_category(relic.category)

/obj/machinery/computer/fossil_reconstitutor/attackby(obj/item/item, mob/living/user, params)
	if(is_fossil(item))
		if(!allowed(user))
			to_chat(user, span_warning("Access denied."))
			return ATTACK_CHAIN_BLOCKED_ALL
		start_scan(item, user)
		return ATTACK_CHAIN_BLOCKED_ALL
	if(istype(item, /obj/item/xenoarch_relic))
		to_chat(user, span_warning("[src] cannot extract genetic material from [item]."))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/machinery/computer/fossil_reconstitutor/proc/start_scan(obj/item/xenoarch_relic/relic, mob/user)
	if(busy)
		to_chat(user, span_warning("[src] is busy: [busy]."))
		return FALSE
	if(stat & (NOPOWER|BROKEN))
		return FALSE
	if(!genebank().has_unknown_data())
		to_chat(user, span_notice("[src] already holds every genome it can recover. The fossil is better suited for research."))
		return FALSE
	if(!user.drop_transfer_item_to_loc(relic, src))
		return FALSE
	busy = "extracting genetic material"
	busy_until = world.time + FOSSIL_SCAN_TIME
	playsound(src, 'sound/machines/terminal_processing.ogg', 30, TRUE)
	visible_message(span_notice("[src] draws [relic] into its sample drawer and begins grinding it down."))
	addtimer(CALLBACK(src, PROC_REF(finish_scan), relic), FOSSIL_SCAN_TIME)
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/fossil_reconstitutor/proc/finish_scan(obj/item/xenoarch_relic/relic)
	busy = null
	if(QDELETED(src))
		return
	if(QDELETED(relic) || relic.loc != src)
		SStgui.update_uis(src)
		return
	var/list/results = genebank().process_fossil()
	if(isnull(results))
		relic.forceMove(get_turf(src))
		add_log("No new genetic data. Sample returned.")
	else
		qdel(relic)
		for(var/line in results)
			add_log(line)
		if(!length(results))
			add_log("The fossil was too degraded to yield usable fragments.")
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	SStgui.update_uis(src)

/obj/machinery/computer/fossil_reconstitutor/proc/finish_verify(datum/fossil_genome/genome)
	busy = null
	if(QDELETED(src))
		return
	if(genome.verify())
		add_log("[genome.codename] assembled: [genome.species_name], [genome.grade()] ([genome.fidelity]% fidelity).")
		playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
		visible_message(span_notice("[src] chimes: the genome of \a [genome.species_name] has been reconstructed!"))
	else
		var/matches = 0
		for(var/result in genome.feedback)
			if(result == FOSSIL_FEEDBACK_MATCH)
				matches++
		add_log("[genome.codename] sequencing run: [matches]/[FOSSIL_GENOME_LENGTH] loci confirmed. Sample fidelity [genome.fidelity]%.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
	SStgui.update_uis(src)

/obj/machinery/computer/fossil_reconstitutor/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/computer/fossil_reconstitutor/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/computer/fossil_reconstitutor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FossilReconstitutor", name)
		ui.open()

/obj/machinery/computer/fossil_reconstitutor/ui_data(mob/user)
	var/list/data = genebank().ui_payload()
	data["kind"] = kind
	data["busy"] = busy
	data["busy_left"] = busy ? max(0, round((busy_until - world.time) / 10, 0.1)) : 0
	data["log"] = scan_log
	data["authorized"] = allowed(user)
	return data

/obj/machinery/computer/fossil_reconstitutor/ui_act(action, params)
	if(..())
		return
	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		return
	var/datum/fossil_genebank/bank = genebank()
	var/datum/fossil_genome/genome = bank.genome_by_index(text2num(params["genome"]))
	var/locus = text2num(params["locus"])
	switch(action)
		if("place")
			var/fragment = params["fragment"]
			if(!genome || !(fragment in bank.pool))
				return
			return genome.place(locus, fragment)
		if("clear_locus")
			return genome?.clear_locus(locus)
		if("clear_all")
			return genome?.clear_all()
		if("verify")
			if(!genome || genome.completed || busy)
				return
			busy = "sequencing [genome.codename]"
			busy_until = world.time + FOSSIL_VERIFY_TIME
			playsound(src, 'sound/machines/terminal_processing.ogg', 30, TRUE)
			addtimer(CALLBACK(src, PROC_REF(finish_verify), genome), FOSSIL_VERIFY_TIME)
			return TRUE
	return handle_product_action(action, genome)

/// Kind-specific actions for completed genomes.
/obj/machinery/computer/fossil_reconstitutor/proc/handle_product_action(action, datum/fossil_genome/genome)
	return FALSE

/obj/machinery/computer/fossil_reconstitutor/fauna
	name = "fauna reconstitution console"
	desc = "Extracts degraded genetic material from fossilised bones, skulls and shells. A linked growth tank can bring the reconstructed species back to life."
	circuit = /obj/item/circuitboard/fossil_reconstitutor
	kind = FOSSIL_KIND_FAUNA

/obj/machinery/computer/fossil_reconstitutor/fauna/proc/find_incubator()
	for(var/obj/machinery/fossil_incubator/tank in range(3, src))
		if(!(tank.stat & BROKEN))
			return tank

/obj/machinery/computer/fossil_reconstitutor/fauna/ui_data(mob/user)
	var/list/data = ..()
	var/obj/machinery/fossil_incubator/tank = find_incubator()
	if(tank)
		data["incubator"] = list(
			"biomass" = tank.biomass,
			"max_biomass" = FOSSIL_INCUBATOR_MAX_BIOMASS,
			"cost" = FOSSIL_INCUBATOR_COST,
			"growing" = tank.growing?.species_name,
			"progress" = tank.growth_progress(),
			"powered" = !(tank.stat & NOPOWER),
		)
	return data

/obj/machinery/computer/fossil_reconstitutor/fauna/handle_product_action(action, datum/fossil_genome/genome)
	if(action != "grow" || !genome?.completed)
		return FALSE
	var/obj/machinery/fossil_incubator/tank = find_incubator()
	if(!tank)
		to_chat(usr, span_warning("No growth tank is linked. Build one within three metres of the console."))
		return FALSE
	var/problem = tank.start_growth(genome)
	if(problem)
		to_chat(usr, span_warning(problem))
		return FALSE
	add_log("Growth of \a [genome.species_name] started.")
	return TRUE

/obj/machinery/computer/fossil_reconstitutor/flora
	name = "flora reconstitution console"
	desc = "Extracts degraded genetic material from fossilised plants and synthesises viable seeds of the reconstructed species."
	circuit = /obj/item/circuitboard/fossil_reconstitutor/flora
	kind = FOSSIL_KIND_FLORA
	light_color = LIGHT_COLOR_GREEN
	COOLDOWN_DECLARE(seed_cooldown)

/obj/machinery/computer/fossil_reconstitutor/flora/ui_data(mob/user)
	var/list/data = ..()
	data["seed_cooldown"] = round(COOLDOWN_TIMELEFT(src, seed_cooldown) / 10)
	return data

/obj/machinery/computer/fossil_reconstitutor/flora/handle_product_action(action, datum/fossil_genome/genome)
	if(action != "synthesize" || !genome?.completed || busy)
		return FALSE
	if(!COOLDOWN_FINISHED(src, seed_cooldown))
		return FALSE
	COOLDOWN_START(src, seed_cooldown, FOSSIL_SEED_COOLDOWN)
	synthesize_seeds(genome)
	return TRUE

/obj/machinery/computer/fossil_reconstitutor/flora/proc/synthesize_seeds(datum/fossil_genome/genome)
	var/obj/item/seeds/prehistoric/packet = new genome.result_type(get_turf(src))
	packet.apply_fidelity(genome.fidelity)
	add_log("Seed packet synthesised: [genome.species_name], [genome.grade()].")
	playsound(src, 'sound/machines/click.ogg', 40, TRUE)
	visible_message(span_notice("[src] dispenses [packet]."))
	return packet

// Growth tank

/obj/machinery/fossil_incubator
	name = "reconstitution growth tank"
	desc = "A tall vat of nutrient gel. Feed it raw meat or monkey cubes and a fauna reconstitution console can grow a reconstructed creature inside."
	// The cryo cell's tall glass pod: the growing creature floats inside like a cryo patient.
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "pod0"
	layer = ABOVE_WINDOW_LAYER
	density = TRUE
	anchored = TRUE
	idle_power_usage = 200
	active_power_usage = 2000
	var/biomass = 0
	var/datum/fossil_genome/growing
	var/growth_time = FOSSIL_INCUBATOR_BASE_TIME
	/// Deciseconds of growth already done; paused without power.
	var/growth_done = 0
	var/last_process = 0
	/// The silhouette of the creature floating in the gel, animated like a cryo cell occupant.
	var/obj/effect/occupant_overlay

/obj/machinery/fossil_incubator/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/fossil_incubator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/sheet/glass(null, 2)
	RefreshParts()
	update_icon()

/obj/machinery/fossil_incubator/Destroy()
	growing = null
	QDEL_NULL(occupant_overlay)
	return ..()

/obj/machinery/fossil_incubator/RefreshParts()
	var/manipulators = 0
	for(var/obj/item/stock_parts/manipulator/part in component_parts)
		manipulators += part.rating
	// Two tier-1 manipulators: 120 s. Two tier-4: 48 s.
	growth_time = round(FOSSIL_INCUBATOR_BASE_TIME * 2 / max(2, manipulators / 2 + 1), 1)

/obj/machinery/fossil_incubator/power_change(forced = FALSE)
	. = ..()
	update_icon()

/obj/machinery/fossil_incubator/update_icon_state()
	icon_state = (growing && !(stat & NOPOWER)) ? "pod1" : "pod0"

/obj/machinery/fossil_incubator/update_overlays()
	. = ..()
	var/running = growing && !(stat & NOPOWER)
	update_occupant()
	. += "lid[running ? 1 : 0]"

/// The forming creature: a dark silhouette that gains colour as it grows, bobbing in the gel.
/obj/machinery/fossil_incubator/proc/update_occupant()
	if(!growing)
		QDEL_NULL(occupant_overlay)
		return
	var/mob/living/simple_animal/creature_type = growing.result_type
	if(!occupant_overlay)
		occupant_overlay = new(get_turf(src))
		occupant_overlay.icon = initial(creature_type.icon)
		occupant_overlay.icon_state = initial(creature_type.icon_living) || initial(creature_type.icon_state)
		occupant_overlay.layer = layer + 0.01
		occupant_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		occupant_overlay.pixel_z = 22
		occupant_overlay.transform = matrix() * 0.7
		animate(occupant_overlay, time = 3 SECONDS, loop = -1, easing = QUAD_EASING, pixel_z = 28)
		animate(time = 3 SECONDS, loop = -1, easing = QUAD_EASING, pixel_z = 22)
	var/progress = growth_progress()
	occupant_overlay.alpha = 90 + round(progress * 1.4)
	occupant_overlay.color = progress >= 50 ? null : "#202830"

/obj/machinery/fossil_incubator/examine(mob/user)
	. = ..()
	. += span_notice("Biomass: [biomass]/[FOSSIL_INCUBATOR_MAX_BIOMASS]. A creature needs [FOSSIL_INCUBATOR_COST].")
	if(growing)
		. += span_notice("A dark shape is forming inside. Growth: [growth_progress()]%.")

/obj/machinery/fossil_incubator/proc/biomass_value(obj/item/item)
	if(istype(item, /obj/item/reagent_containers/food/snacks/monkeycube))
		return 40
	if(istype(item, /obj/item/reagent_containers/food/snacks/meat))
		return 25
	return 0

/obj/machinery/fossil_incubator/attackby(obj/item/item, mob/living/user, params)
	var/value = biomass_value(item)
	if(value)
		if(biomass + value > FOSSIL_INCUBATOR_MAX_BIOMASS)
			to_chat(user, span_warning("[src] is full of biomass."))
			return ATTACK_CHAIN_BLOCKED_ALL
		if(!user.drop_transfer_item_to_loc(item, src))
			return ATTACK_CHAIN_BLOCKED_ALL
		biomass += value
		qdel(item)
		to_chat(user, span_notice("[src] dissolves the biomass. It now holds [biomass]/[FOSSIL_INCUBATOR_MAX_BIOMASS]."))
		playsound(src, 'sound/effects/bubbles.ogg', 30, TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/machinery/fossil_incubator/screwdriver_act(mob/living/user, obj/item/tool)
	if(growing)
		return FALSE
	return default_deconstruction_screwdriver(user, icon_state, icon_state, tool)

/obj/machinery/fossil_incubator/crowbar_act(mob/living/user, obj/item/tool)
	if(growing)
		return FALSE
	return default_deconstruction_crowbar(user, tool)

/obj/machinery/fossil_incubator/proc/growth_progress()
	if(!growing)
		return 0
	return clamp(round(growth_done / growth_time * 100), 0, 100)

/// Returns an error message, or null on success.
/obj/machinery/fossil_incubator/proc/start_growth(datum/fossil_genome/genome)
	if(stat & (NOPOWER|BROKEN))
		return "The growth tank has no power."
	if(panel_open)
		return "Close the growth tank's maintenance panel first."
	if(growing)
		return "The growth tank is already occupied."
	if(biomass < FOSSIL_INCUBATOR_COST)
		return "The growth tank needs [FOSSIL_INCUBATOR_COST] biomass; it has [biomass]."
	biomass -= FOSSIL_INCUBATOR_COST
	growing = genome
	growth_done = 0
	last_process = world.time
	update_use_power(ACTIVE_POWER_USE)
	visible_message(span_notice("[src] bubbles as a cluster of cells begins to divide."))
	update_icon()
	return null

/obj/machinery/fossil_incubator/process()
	if(!growing)
		return
	var/elapsed = world.time - last_process
	last_process = world.time
	if(stat & (NOPOWER|BROKEN))
		return
	var/before = growth_progress()
	growth_done += elapsed
	if(prob(4))
		visible_message(span_notice("[src] [pick("gurgles", "bubbles", "hums", "hisses softly")]."))
	if(growth_done >= growth_time)
		finish_growth()
	else if(round(before / 10) != round(growth_progress() / 10))
		update_icon()

/obj/machinery/fossil_incubator/proc/finish_growth()
	var/datum/fossil_genome/genome = growing
	growing = null
	growth_done = 0
	update_use_power(IDLE_POWER_USE)
	update_icon()
	// Born in front of the pod (south), or on the pod's own cell if that is blocked.
	var/turf/exit = get_step(src, SOUTH)
	if(!exit || exit.density || (locate(/obj/machinery) in exit))
		exit = get_turf(src)
	var/mob/living/creature = new genome.result_type(exit)
	apply_fossil_fidelity(creature, genome.fidelity)
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
	visible_message(span_notice("[src] drains with a gush and \a [creature] stumbles out!"))
	SStgui.update_uis(src)
	return creature

/// Sample quality decides temperament: careful assembly yields docile animals, sloppy work yields malformed ones.
/proc/apply_fossil_fidelity(mob/living/creature, fidelity)
	switch(fossil_grade(fidelity))
		if("pristine")
			creature.faction = list("neutral")
			creature.name = "reconstituted [creature.name]"
			creature.desc += " This specimen was reconstituted from a pristine genome and appears calm around people."
		if("unstable")
			creature.name = "malformed [creature.name]"
			creature.desc += " Its body is lopsided and riddled with growths: the genome it was grown from was badly damaged."
			creature.maxHealth = round(creature.maxHealth * 0.6)
			creature.health = creature.maxHealth
			if(istype(creature, /mob/living/simple_animal/hostile))
				var/mob/living/simple_animal/hostile/beast = creature
				beast.melee_damage_upper = round(beast.melee_damage_upper * 1.3)

// Circuit boards and designs

/obj/item/circuitboard/fossil_reconstitutor
	board_name = "Fauna Reconstitution Console"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/fossil_reconstitutor/fauna
	origin_tech = "programming=2;biotech=3"

/obj/item/circuitboard/fossil_reconstitutor/flora
	board_name = "Flora Reconstitution Console"
	build_path = /obj/machinery/computer/fossil_reconstitutor/flora

/obj/item/circuitboard/fossil_incubator
	board_name = "Reconstitution Growth Tank"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/fossil_incubator
	board_type = "machine"
	origin_tech = "programming=2;biotech=3"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/sheet/glass = 2,
	)

/datum/design/fossil_reconstitutor_fauna
	name = "Console Board (Fauna Reconstitution Console)"
	desc = "Allows for the construction of circuit boards used to build a fauna reconstitution console."
	id = "fossil_reconstitutor_fauna"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 2, RESEARCH_TREE_BIOTECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_SILVER = 500)
	build_path = /obj/item/circuitboard/fossil_reconstitutor
	category = list(CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/fossil_reconstitutor_fauna/flora
	name = "Console Board (Flora Reconstitution Console)"
	desc = "Allows for the construction of circuit boards used to build a flora reconstitution console."
	id = "fossil_reconstitutor_flora"
	build_path = /obj/item/circuitboard/fossil_reconstitutor/flora

/datum/design/fossil_reconstitutor_fauna/incubator
	name = "Machine Board (Reconstitution Growth Tank)"
	desc = "Allows for the construction of circuit boards used to build a reconstitution growth tank."
	id = "fossil_incubator"
	build_path = /obj/item/circuitboard/fossil_incubator
