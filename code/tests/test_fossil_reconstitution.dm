/// Fossil reconstitution: genome generation, fossil extraction, the assembly minigame,
/// both consoles, the growth tank and the reconstituted species' assets.

/datum/unit_test/fossil_genome_generation/Run()
	for(var/kind in list(FOSSIL_KIND_FAUNA, FOSSIL_KIND_FLORA))
		var/datum/fossil_genebank/bank = new(kind)
		var/list/seen = list()
		for(var/datum/fossil_genome/genome as anything in bank.genomes)
			TEST_ASSERT_EQUAL(length(genome.fragments), FOSSIL_GENOME_LENGTH, "Every genome must have [FOSSIL_GENOME_LENGTH] loci")
			TEST_ASSERT(findtext(genome.fragments[1], "ATG") == 1, "Genomes must open with the start motif")
			TEST_ASSERT(findtext(genome.fragments[FOSSIL_GENOME_LENGTH], "TAA", -3), "Genomes must close with the stop motif")
			for(var/i in 1 to FOSSIL_GENOME_LENGTH)
				var/fragment = genome.fragments[i]
				TEST_ASSERT_EQUAL(length(fragment), FOSSIL_FRAGMENT_BASES, "Fragments must have six bases")
				TEST_ASSERT_NULL(seen[fragment], "Fragment [fragment] must be unique within a genebank")
				seen[fragment] = TRUE
				if(i > 1)
					TEST_ASSERT_EQUAL(copytext(genome.fragments[i - 1], -2), copytext(fragment, 1, 3), "Neighbouring fragments must overlap by two bases")
			TEST_ASSERT(ispath(genome.result_type), "[genome.species_name] must produce something")
		TEST_ASSERT_EQUAL(length(bank.genomes), kind == FOSSIL_KIND_FAUNA ? 5 : 7, "Every historical species must be recoverable")
		qdel(bank)

/datum/unit_test/fossil_extraction/Run()
	var/datum/fossil_genebank/bank = new(FOSSIL_KIND_FAUNA)
	TEST_ASSERT(bank.accepts_category("fossil"), "Fauna consoles take animal fossils")
	TEST_ASSERT_NOT(bank.accepts_category("botanical"), "Fauna consoles reject plant fossils")
	var/list/first = bank.process_fossil()
	TEST_ASSERT(length(bank.discovered_genomes()) == 1, "The first fossil must reveal a gene sequence")
	TEST_ASSERT(length(first) >= 2, "The first fossil must report a sequence and a fragment")
	var/fossils = 1
	while(bank.has_unknown_data() && fossils < 400)
		bank.process_fossil()
		fossils++
	TEST_ASSERT_NOT(bank.has_unknown_data(), "Enough fossils must recover every fragment")
	TEST_ASSERT(fossils <= 60, "Recovering a whole genebank must not need more than 60 fossils; took [fossils]")
	for(var/datum/fossil_genome/genome as anything in bank.genomes)
		TEST_ASSERT(genome.discovered, "[genome.species_name] must be discovered")
		for(var/fragment in genome.fragments)
			TEST_ASSERT(fragment in bank.pool, "Fragment [fragment] must reach the pool")
	TEST_ASSERT_NULL(bank.process_fossil(), "An exhausted genebank must refuse further fossils")
	TEST_ASSERT_EQUAL(bank.fossils_processed, fossils, "Refused fossils must not count as processed")
	qdel(bank)

/datum/unit_test/fossil_assembly_minigame/Run()
	var/datum/fossil_genome/genome = new("test beast", /mob/living/simple_animal/prehistoric/yithian)
	genome.generate(list())
	var/list/correct = genome.fragments.Copy()
	genome.place(1, correct[2])
	genome.place(2, "GGGGGG")
	genome.place(3, correct[3])
	TEST_ASSERT_NOT(genome.verify(), "An incomplete assembly cannot pass")
	TEST_ASSERT_EQUAL(genome.feedback[1], FOSSIL_FEEDBACK_SHIFT, "A fragment of this genome at the wrong locus is misplaced")
	TEST_ASSERT_EQUAL(genome.feedback[2], FOSSIL_FEEDBACK_FOREIGN, "A fragment from elsewhere is foreign")
	TEST_ASSERT_EQUAL(genome.feedback[3], FOSSIL_FEEDBACK_MATCH, "A correct fragment is confirmed")
	TEST_ASSERT_EQUAL(genome.feedback[4], FOSSIL_FEEDBACK_EMPTY, "Unfilled loci are reported as empty")
	TEST_ASSERT_EQUAL(genome.fidelity, 100 - FOSSIL_FIDELITY_PER_FAILED_RUN, "A failed run must degrade the sample")
	genome.place(4, correct[2])
	TEST_ASSERT_NULL(genome.slots[1], "A fragment moves rather than duplicating within a genome")
	for(var/i in 1 to 20)
		genome.verify()
	TEST_ASSERT_EQUAL(genome.fidelity, FOSSIL_FIDELITY_FLOOR, "Fidelity must not fall below its floor")
	for(var/i in 1 to FOSSIL_GENOME_LENGTH)
		genome.place(i, correct[i])
	TEST_ASSERT(genome.verify(), "The correct order must complete the genome")
	TEST_ASSERT(genome.completed, "A verified genome is complete")
	TEST_ASSERT_EQUAL(genome.grade(), "unstable", "A heavily retried genome is unstable")
	TEST_ASSERT_NOT(genome.place(1, "GGGGGG"), "Completed genomes are locked")
	qdel(genome)

/datum/unit_test/room_test/fossil_fauna_console/Run()
	var/obj/machinery/computer/fossil_reconstitutor/fauna/console = allocate(/obj/machinery/computer/fossil_reconstitutor/fauna)
	var/obj/machinery/fossil_incubator/tank = allocate(/obj/machinery/fossil_incubator, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/fossil_genebank/bank = console.genebank()
	TEST_ASSERT_EQUAL(bank, get_fossil_genebank(FOSSIL_KIND_FAUNA), "Consoles share one genebank per kind")
	var/obj/item/xenoarch_relic/fossil = allocate(/obj/item/xenoarch_relic, console)
	fossil.category = "fossil"
	var/before = bank.fossils_processed
	console.finish_scan(fossil)
	TEST_ASSERT(QDELETED(fossil), "Processed fossils are consumed")
	TEST_ASSERT_EQUAL(bank.fossils_processed, before + 1, "The console must feed the shared genebank")
	TEST_ASSERT(length(console.scan_log), "Scan results are logged")
	var/obj/item/xenoarch_relic/pottery = allocate(/obj/item/xenoarch_relic)
	pottery.category = "domestic"
	TEST_ASSERT_NOT(console.is_fossil(pottery), "Pottery holds no genetic material")
	var/datum/fossil_genome/genome = bank.genomes[1]
	genome.discovered = TRUE
	genome.completed = TRUE
	genome.fidelity = 100
	TEST_ASSERT_EQUAL(console.find_incubator(), tank, "The console must find a nearby growth tank")
	tank.stat &= ~NOPOWER
	TEST_ASSERT_NOTNULL(tank.start_growth(genome), "Growth needs biomass")
	var/obj/item/reagent_containers/food/snacks/monkeycube/cube = allocate(/obj/item/reagent_containers/food/snacks/monkeycube)
	TEST_ASSERT_EQUAL(tank.biomass_value(cube), 40, "Monkey cubes are biomass")
	tank.biomass = FOSSIL_INCUBATOR_COST
	TEST_ASSERT_NULL(tank.start_growth(genome), "A fed, powered tank starts growing")
	TEST_ASSERT_EQUAL(tank.biomass, 0, "Growth consumes biomass")
	TEST_ASSERT_NOTNULL(tank.start_growth(genome), "An occupied tank refuses a second specimen")
	var/mob/living/creature = tank.finish_growth()
	TEST_ASSERT(istype(creature, genome.result_type), "The tank grows the reconstructed species")
	TEST_ASSERT(("neutral" in creature.faction) && length(creature.faction) == 1, "Pristine genomes give docile animals")
	TEST_ASSERT_NULL(tank.growing, "The tank empties after growth")
	qdel(creature)
	var/mob/living/simple_animal/hostile/prehistoric/samak/malformed = allocate(/mob/living/simple_animal/hostile/prehistoric/samak)
	var/full_health = malformed.maxHealth
	apply_fossil_fidelity(malformed, FOSSIL_FIDELITY_FLOOR)
	TEST_ASSERT(malformed.maxHealth < full_health, "Unstable genomes give weakened creatures")
	TEST_ASSERT_SUBSTRING(malformed.name, "malformed")
	TEST_ASSERT("samak" in malformed.faction, "Malformed predators stay wild")
	genome.completed = FALSE
	genome.discovered = FALSE

/datum/unit_test/fossil_flora_console/Run()
	var/obj/machinery/computer/fossil_reconstitutor/flora/console = allocate(/obj/machinery/computer/fossil_reconstitutor/flora)
	var/obj/item/xenoarch_relic/fern = allocate(/obj/item/xenoarch_relic)
	fern.category = "botanical"
	TEST_ASSERT(console.is_fossil(fern), "Flora consoles take plant fossils")
	fern.category = "fossil"
	TEST_ASSERT_NOT(console.is_fossil(fern), "Flora consoles reject animal fossils")
	var/datum/fossil_genome/genome = new("telriis grass", /obj/item/seeds/prehistoric/telriis)
	genome.fidelity = 100
	var/obj/item/seeds/prehistoric/pristine = console.synthesize_seeds(genome)
	var/obj/item/seeds/prehistoric/telriis/reference = allocate(/obj/item/seeds/prehistoric/telriis)
	TEST_ASSERT(pristine.potency > reference.potency, "Pristine genomes give more potent seeds")
	TEST_ASSERT_EQUAL(pristine.reconstitution_grade, "pristine", "Seed packets record their genome grade")
	genome.fidelity = FOSSIL_FIDELITY_FLOOR
	var/obj/item/seeds/prehistoric/poor = console.synthesize_seeds(genome)
	TEST_ASSERT(poor.yield < reference.yield, "Unstable genomes give weaker seeds")
	qdel(pristine)
	qdel(poor)
	qdel(genome)

/datum/unit_test/fossil_species_assets/Run()
	for(var/seed_type in subtypesof(/obj/item/seeds/prehistoric))
		var/obj/item/seeds/prehistoric/seed = allocate(seed_type)
		var/list/states = icon_states(seed.growing_icon)
		for(var/stage in 1 to seed.growthstages)
			TEST_ASSERT("[seed.icon_grow][stage]" in states, "[seed_type] lacks growth stage [stage]")
		TEST_ASSERT(seed.icon_harvest in states, "[seed_type] lacks a harvest sprite")
		TEST_ASSERT(seed.icon_dead in states, "[seed_type] lacks a dead sprite")
		TEST_ASSERT(seed.icon_state in icon_states(seed.icon), "[seed_type] lacks a seed packet sprite")
		var/obj/item/reagent_containers/food/snacks/grown/product = seed.product
		TEST_ASSERT(initial(product.icon_state) in icon_states(initial(product.icon)), "[product] lacks a sprite")
	for(var/mob_type in subtypesof(/mob/living/simple_animal/hostile/prehistoric) + subtypesof(/mob/living/simple_animal/prehistoric))
		var/mob/living/simple_animal/beast = mob_type
		var/list/states = icon_states(initial(beast.icon))
		TEST_ASSERT(initial(beast.icon_living) in states, "[mob_type] lacks a living sprite")
		TEST_ASSERT(initial(beast.icon_dead) in states, "[mob_type] lacks a dead sprite")
	var/list/tank_states = icon_states('icons/obj/machines/cryogenics.dmi')
	for(var/state in list("pod0", "pod1", "lid0", "lid1"))
		TEST_ASSERT(state in tank_states, "The growth tank lacks [state]")

/// Every transit tube on the asteroid joins its neighbours, and a pod can ride from the mining station to the outpost.
/datum/unit_test/outpost_transit_line/Run()
	var/z = level_name_to_num(MINING)
	if(!z)
		return
	var/count = 0
	for(var/obj/structure/transit_tube/tube in world)
		if(tube.z != z || istype(tube, /obj/structure/transit_tube/cap))
			continue
		count++
		for(var/direction in tube.directions())
			var/turf/next = get_step(tube, direction)
			var/joined = FALSE
			for(var/obj/structure/transit_tube/other in next)
				if(other.has_entrance(direction))
					joined = TRUE
					break
			TEST_ASSERT(joined, "[tube.type] at [tube.x],[tube.y] leads [dir2text(direction)] into nothing")
	TEST_ASSERT(count > 100, "The outpost must have its transit network")
	var/obj/structure/transit_tube/station/lobby = locate() in locate(164, 76, z)
	var/obj/structure/transit_tube/station/reception = locate() in locate(144, 193, z)
	TEST_ASSERT_NOTNULL(lobby, "The mining station needs a tube terminus")
	TEST_ASSERT_NOTNULL(reception, "The outpost reception needs a tube station")
	TEST_ASSERT_EQUAL(ride(lobby, NORTH), reception, "A pod from the mining station must arrive at the outpost reception")
	TEST_ASSERT_EQUAL(ride(reception, SOUTH), lobby, "A pod from the outpost reception must arrive at the mining station")

/// Follows the tubes exactly as a pod does and returns the station it stops at.
/datum/unit_test/outpost_transit_line/proc/ride(obj/structure/transit_tube/start, direction)
	var/obj/structure/transit_tube/current = start
	for(var/i in 1 to 600)
		var/next_dir = current.get_exit(direction)
		if(!next_dir)
			return null
		var/obj/structure/transit_tube/next
		for(var/obj/structure/transit_tube/candidate in get_step(current, next_dir))
			if(candidate.has_entrance(next_dir))
				next = candidate
				break
		if(!next)
			return null
		direction = next_dir
		current = next
		if(istype(current, /obj/structure/transit_tube/station))
			return current
	return null

/// The reconstitution lab is a real, powered room with both consoles and a penned tank.
/datum/unit_test/reconstitution_lab/Run()
	var/z = level_name_to_num(MINING)
	if(!z)
		return
	var/obj/machinery/computer/fossil_reconstitutor/fauna/fauna = locate() in locate(148, 198, z)
	var/obj/machinery/computer/fossil_reconstitutor/flora/flora = locate() in locate(148, 201, z)
	var/obj/machinery/fossil_incubator/tank = locate() in locate(150, 199, z)
	TEST_ASSERT_NOTNULL(fauna, "The lab needs a fauna console")
	TEST_ASSERT_NOTNULL(flora, "The lab needs a flora console")
	TEST_ASSERT_NOTNULL(tank, "The lab needs a growth tank")
	TEST_ASSERT(istype(get_area(tank), /area/research_outpost/reconstitution), "The tank belongs to the reconstitution lab")
	TEST_ASSERT_EQUAL(fauna.find_incubator(), tank, "The fauna console must reach the tank")
	TEST_ASSERT_NOT(tank.stat & NOPOWER, "The lab must be powered")
	TEST_ASSERT_NOT(fauna.stat & NOPOWER, "The fauna console must be powered")
	var/turf/floor = get_turf(tank)
	TEST_ASSERT(floor.get_readonly_air().return_pressure() > 70, "The lab must hold air")
