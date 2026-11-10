/// Check the mapped utility circuits, rather than just the APCs' starting batteries.
/datum/unit_test/xenoarch_outpost_utilities/Run()
	var/mining_z = level_name_to_num(MINING)
	if(!mining_z)
		return
	var/obj/machinery/power/smes/upper = locate() in locate(178, 201, mining_z)
	var/obj/machinery/power/smes/lower = locate() in locate(178, 200, mining_z)
	TEST_ASSERT_NOTNULL(upper, "The upper SMES must exist")
	TEST_ASSERT_NOTNULL(lower, "The lower SMES must exist")
	TEST_ASSERT_NOTNULL(upper.terminal, "The upper SMES needs an input terminal")
	TEST_ASSERT_NOTNULL(lower.terminal, "The lower SMES needs an input terminal")
	var/datum/powernet/input_net = upper.terminal.powernet
	var/datum/powernet/output_net = upper.powernet
	TEST_ASSERT_NOTNULL(input_net, "Generators must have a charging circuit")
	TEST_ASSERT_NOTNULL(output_net, "The outpost must have a distribution circuit")
	TEST_ASSERT_NOTEQUAL(input_net, output_net, "SMES input and output must be electrically separate")
	TEST_ASSERT_EQUAL(lower.terminal.powernet, input_net, "Both SMES inputs must reach the generators")
	TEST_ASSERT_EQUAL(lower.powernet, output_net, "Both SMES outputs must feed the outpost")
	for(var/obj/machinery/power/apc/apc in world)
		if(apc.z == mining_z && istype(get_area(apc), /area/research_outpost))
			TEST_ASSERT_NOTNULL(apc.terminal, "Every outpost APC must have a terminal")
			TEST_ASSERT_EQUAL(apc.terminal.powernet, output_net, "[apc.name] at [apc.x]:[apc.y] must reach the SMES distribution circuit")
	for(var/x in 175 to 178)
		for(var/y in 196 to 201)
			var/cable_count = 0
			for(var/obj/structure/cable/cable in locate(x, y, mining_z))
				cable_count++
				TEST_ASSERT(cable.linked_dirs, "Utility cables must have a connected direction")
			TEST_ASSERT(cable_count <= 1, "The power room must not contain stacked legacy cables")
	// Run the actual generators and SMES processors synchronously, then restore all state.
	var/list/input_state = list(input_net.avail, input_net.newavail, input_net.load)
	var/list/output_state = list(output_net.newavail)
	input_net.newavail = 0
	for(var/x in 175 to 176)
		var/obj/machinery/power/port_gen/pacman/generator = locate() in locate(x, 201, mining_z)
		TEST_ASSERT_NOTNULL(generator, "Both mapped generators must exist")
		TEST_ASSERT_EQUAL(generator.powernet, input_net, "Generators must connect to both SMES inputs")
		var/list/state = list(generator.active, generator.sheets, generator.sheet_left, generator.temperature)
		generator.active = TRUE
		generator.sheets = 1
		generator.process()
		generator.active = state[1]
		generator.sheets = state[2]
		generator.sheet_left = state[3]
		generator.temperature = state[4]
		generator.soundloop.stop()
	var/generated = input_net.newavail
	input_net.avail = generated
	input_net.load = 0
	output_net.newavail = 0
	var/list/smes_state = list(upper.charge, upper.inputting, upper.outputting, upper.input_attempt, upper.output_attempt, upper.input_available, upper.output_used)
	upper.charge = 0
	upper.inputting = TRUE
	upper.input_attempt = TRUE
	upper.output_attempt = FALSE
	upper.process()
	var/charged = upper.charge
	upper.input_attempt = FALSE
	upper.outputting = TRUE
	upper.output_attempt = TRUE
	upper.process()
	var/discharged = upper.charge < charged
	var/delivered = output_net.newavail
	upper.charge = smes_state[1]
	upper.inputting = smes_state[2]
	upper.outputting = smes_state[3]
	upper.input_attempt = smes_state[4]
	upper.output_attempt = smes_state[5]
	upper.input_available = smes_state[6]
	upper.output_used = smes_state[7]
	upper.update_icon()
	input_net.avail = input_state[1]
	input_net.newavail = input_state[2]
	input_net.load = input_state[3]
	output_net.newavail = output_state[1]
	TEST_ASSERT(generated > 0, "Fueled mapped generators must actually generate power")
	TEST_ASSERT(charged > 0, "Generator power must actually charge the SMES")
	TEST_ASSERT(discharged && delivered > 0, "Stored power must actually reach the outpost distribution circuit")

/datum/unit_test/xenoarch_outpost_atmos/Run()
	var/mining_z = level_name_to_num(MINING)
	if(!mining_z)
		return
	for(var/x in 175 to 176)
		var/obj/machinery/atmospherics/trinary/filter/filter = locate() in locate(x, 207, mining_z)
		TEST_ASSERT_NOTNULL(filter, "Both recycling filters must exist")
		TEST_ASSERT_EQUAL(filter.filter_type, x == 175 ? TLV_N2 : TLV_O2, "The filters must recover nitrogen and oxygen")
		TEST_ASSERT(filter.node1 && filter.node2 && filter.node3, "Every filter port must have a pipe connection")
		TEST_ASSERT(filter.powered(), "Recycling filters must have power")
		TEST_ASSERT(filter.on, "Recycling filters must start enabled")
		var/area/filter_area = get_area(filter)
		TEST_ASSERT(length(filter_area.apc), "Atmospherics must have a real APC")
		TEST_ASSERT_NOTEQUAL(filter.parent2, filter.parent1, "Clean gas must be separated from the inlet")
		TEST_ASSERT_NOTEQUAL(filter.parent2, filter.parent3, "Clean gas must be separated from the exhaust")
		var/list/original_air = list(filter.air1, filter.air2, filter.air3, filter.on)
		filter.air1 = new
		filter.air2 = new
		filter.air3 = new
		filter.air1.set_temperature(T20C)
		filter.air1.set_oxygen(10)
		filter.air1.set_nitrogen(30)
		filter.air1.set_carbon_dioxide(5)
		filter.air1.set_toxins(5)
		filter.air2.set_temperature(T20C)
		filter.air3.set_temperature(T20C)
		filter.on = TRUE
		filter.process_atmos(1)
		var/recovered = x == 175 ? filter.air2.nitrogen() : filter.air2.oxygen()
		var/contaminants = filter.air2.carbon_dioxide() + filter.air2.toxins()
		var/remaining = x == 175 ? filter.air3.nitrogen() : filter.air3.oxygen()
		qdel(filter.air1)
		qdel(filter.air2)
		qdel(filter.air3)
		filter.air1 = original_air[1]
		filter.air2 = original_air[2]
		filter.air3 = original_air[3]
		filter.on = original_air[4]
		TEST_ASSERT(recovered > 0 && contaminants == 0 && remaining == 0, "Filters must actually separate the configured breathing gas from waste")
	for(var/y in 204 to 205)
		var/obj/machinery/atmospherics/unary/thermomachine/thermo = locate() in locate(175, y, mining_z)
		TEST_ASSERT_NOTNULL(thermo, "The room needs a functional cooler and heater")
		TEST_ASSERT_EQUAL(thermo.cooling, y == 204, "The cooler and heater must retain their original functions")
		TEST_ASSERT(thermo.node && thermo.parent && thermo.powered(), "Temperature controls must connect to a powered supply pipe")
		var/datum/gas_mixture/original_air = thermo.air_contents
		var/original_on = thermo.on
		var/original_consumption = thermo.active_power_usage
		thermo.air_contents = new
		thermo.air_contents.set_oxygen(10)
		var/start_temperature = thermo.target_temperature + (thermo.cooling ? 50 : -50)
		thermo.air_contents.set_temperature(start_temperature)
		thermo.on = TRUE
		thermo.process_atmos(1)
		var/moved_towards_target = abs(thermo.air_contents.temperature() - thermo.target_temperature) < 50
		qdel(thermo.air_contents)
		thermo.air_contents = original_air
		thermo.on = original_on
		thermo.active_power_usage = original_consumption
		TEST_ASSERT(moved_towards_target, "The mapped heater/cooler must actually change gas temperature")
	var/obj/machinery/atmospherics/unary/portables_connector/connector = locate() in locate(178, 204, mining_z)
	TEST_ASSERT_NOTNULL(connector, "Waste gas needs a portable connector")
	TEST_ASSERT(connector.node && connector.parent, "The canister connector must actually connect to the scrubber return")
	TEST_ASSERT_NOTNULL(connector.connected_device, "The mapped waste canister must be attached to the connector")

/// Validate the live asteroid and the complete excavation -> laboratory -> R&D loop.
/datum/unit_test/xenoarch_outpost/Run()
	var/mining_z = level_name_to_num(MINING)
	if(!mining_z)
		return
	TEST_ASSERT(length(GLOB.xenoarch_sites) >= 80, "The asteroid must generate archaeological digsites")
	var/large_count = 0
	for(var/turf/simulated/mineral/rock as anything in GLOB.xenoarch_sites)
		TEST_ASSERT_EQUAL(rock.z, mining_z, "Sites may only appear on the asteroid")
		TEST_ASSERT_NOTNULL(rock.archaeology, "Registered sites must own excavation data")
		var/datum/xenoarch_find/find = rock.archaeology.next_find()
		TEST_ASSERT_NOTNULL(find.carrier, "Every find must have a chemical carrier")
		if(find.large)
			large_count++
	TEST_ASSERT_EQUAL(large_count, 10, "The asteroid must contain ten large buried artifacts")
	sleep(10 SECONDS) // Let real power and atmosphere processing expose leaks or dead circuits.
	var/chamber_count = 0
	for(var/obj/structure/xenoarch_chamber/chamber in world)
		if(chamber.z != mining_z)
			continue
		var/turf/base = get_turf(chamber)
		TEST_ASSERT(isfloorturf(base), "Sealed instrument chambers must stand on a solid floor, not open space")
		TEST_ASSERT(base.get_readonly_air().return_pressure() < 1, "Sealed instrument chambers must retain their vacuum")
		chamber_count++
	TEST_ASSERT_EQUAL(chamber_count, 6, "All six spectrometer chambers must have safe foundations")
	var/list/counts = list()
	var/pressurized_floors = 0
	for(var/obj/machinery/xenoarch/instrument in world)
		if(instrument.z != mining_z || !istype(get_area(instrument), /area/research_outpost))
			continue
		counts[instrument.type]++
		TEST_ASSERT_NOT(instrument.stat & NOPOWER, "Mapped laboratory instruments must have power")
		var/turf/floor = get_turf(instrument)
		var/datum/gas_mixture/air = floor.get_readonly_air()
		TEST_ASSERT(air.return_pressure() > 70, "[instrument.type] at [floor.x]:[floor.y] must be pressurized; got [air.return_pressure()] kPa")
		pressurized_floors++
	for(var/type in list(/obj/machinery/xenoarch/spectrometer, /obj/machinery/xenoarch/analyser, /obj/machinery/xenoarch/harvester, /obj/machinery/xenoarch/suspension))
		TEST_ASSERT(counts[type] >= 1, "The outpost must contain [type]")
	var/obj/structure/closet/secure_closet/xenoarchaeologist/locker
	for(var/obj/structure/closet/secure_closet/xenoarchaeologist/candidate in world)
		if(candidate.z == mining_z)
			locker = candidate
			break
	TEST_ASSERT_NOTNULL(locker, "The outpost must contain expedition equipment")
	TEST_ASSERT_NOTNULL(locate(/obj/item/clothing/suit/space/hardsuit/mining) in locker, "Expeditions need pressure-safe suits")
	TEST_ASSERT_NOTNULL(locate(/obj/item/xenoarch_tool/depth_scanner) in locker, "Expeditions need scanners")
	TEST_ASSERT_NOTNULL(locate(/obj/item/book/manual/xenoarchaeology) in locker, "The outpost must teach its gameplay loop")
	log_world("XENOARCH: [length(GLOB.xenoarch_sites)] digsites, [large_count] large artifacts, [pressurized_floors] powered lab instruments")

/datum/unit_test/xenoarch_excavation_precision/Run()
	var/turf/location = locate(1, 1, 1)
	var/datum/xenoarch_site/site = new(FALSE, "technical")
	var/datum/xenoarch_find/find = site.finds[1]
	find.depth = 60
	find.clearance = 2
	site.advance(30, location)
	TEST_ASSERT_NOT(find.recovered, "A buried find must not spawn before its depth is reached")
	site.advance(30, location)
	TEST_ASSERT(find.recovered, "Exact excavation must recover the find")
	TEST_ASSERT_NOT(find.destroyed, "Precise excavation must preserve the find")
	var/obj/item/xenoarch_relic/relic = locate() in location
	TEST_ASSERT_NOTNULL(relic, "Recovery must produce a usable relic")
	TEST_ASSERT_EQUAL(relic.category, "technical", "Recovered finds must retain their type")
	TEST_ASSERT_NULL(relic.origin_tech, "Unidentified finds cannot bypass laboratory analysis")
	relic.tech_level = 6
	relic.analyse()
	TEST_ASSERT_SUBSTRING(relic.origin_tech, "engineering=")
	var/datum/research/research = new
	var/list/tech = params2list(relic.origin_tech)
	research.UpdateTech(RESEARCH_TREE_ENGINEERING, text2num(tech[RESEARCH_TREE_ENGINEERING]))
	var/datum/tech/engineering = research.known_tech[RESEARCH_TREE_ENGINEERING]
	TEST_ASSERT_EQUAL(engineering.level, 6, "An identified level-six find must actually advance existing R&D to six")
	qdel(research)
	qdel(relic)
	qdel(site)
	var/datum/xenoarch_site/damaged = new(FALSE, "fossil")
	var/datum/xenoarch_find/fragile = damaged.finds[1]
	fragile.depth = 45
	fragile.clearance = 2
	damaged.advance(60, location)
	TEST_ASSERT(fragile.destroyed, "Coarse tools must destroy an overshot inclusion")
	TEST_ASSERT_NOT(fragile.recovered, "Destroyed inclusions cannot grant rewards")
	TEST_ASSERT_NULL(damaged.next_find(), "Destroyed inclusions must disappear from scanner readings")
	qdel(damaged)

/datum/unit_test/xenoarch_boulder/Run()
	var/turf/location = locate(1, 1, 1)
	var/obj/structure/xenoarch_boulder/boulder = allocate(/obj/structure/xenoarch_boulder, location)
	boulder.artifact_id = "XA-TEST-BOULDER"
	boulder.advance(10)
	TEST_ASSERT_NOT(QDELETED(boulder), "Partially cleaned boulders must remain")
	boulder.advance(10)
	var/obj/machinery/xenoarch_artifact/artifact = locate() in location
	TEST_ASSERT_NOTNULL(artifact, "Fine cleaning must expose a large artifact")
	TEST_ASSERT_EQUAL(artifact.artifact_id, "XA-TEST-BOULDER", "The recovered artifact must retain its scanner signature")
	qdel(artifact)
	var/obj/structure/xenoarch_boulder/fragile = allocate(/obj/structure/xenoarch_boulder, location)
	fragile.advance(30)
	TEST_ASSERT(QDELETED(fragile), "Overshooting the matrix must destroy the boulder")
	TEST_ASSERT_NULL(locate(/obj/machinery/xenoarch_artifact) in location, "Broken matrix cannot produce an artifact")

/datum/unit_test/xenoarch_lab_cycle/Run()
	var/mining_z = level_name_to_num(MINING)
	if(!mining_z)
		return
	var/turf/location = locate(163, 194, mining_z)
	var/turf/pad_turf = get_step(location, EAST)
	var/obj/machinery/xenoarch/analyser/analyser = allocate(/obj/machinery/xenoarch/analyser, location)
	var/obj/structure/xenoarch_scanpad/pad = allocate(/obj/structure/xenoarch_scanpad, pad_turf)
	TEST_ASSERT_NOTNULL(pad, "The test must have a scanning pad")
	var/obj/machinery/xenoarch_artifact/artifact = allocate(/obj/machinery/xenoarch_artifact, pad_turf)
	artifact.effect_type = "healing"
	artifact.trigger_type = "force"
	artifact.effect_mode = "touch"
	analyser.specimen = artifact
	analyser.complete_analysis()
	TEST_ASSERT_SUBSTRING(analyser.report, "healing")
	TEST_ASSERT_SUBSTRING(analyser.report, "force")
	var/obj/item/xenoarch_relic/reward = locate() in location
	TEST_ASSERT_NOTNULL(reward, "Large artifact analysis must yield a research sample")
	TEST_ASSERT_NOTNULL(reward.origin_tech, "The artifact research sample must work in station R&D")
	TEST_ASSERT_SUBSTRING(reward.origin_tech, "bluespace=6")
	TEST_ASSERT_SUBSTRING(reward.origin_tech, "materials=6")
	qdel(reward)
	analyser.complete_analysis()
	TEST_ASSERT_NULL(locate(/obj/item/xenoarch_relic) in location, "Repeated scans cannot duplicate research rewards")
	artifact.forceMove(get_step(pad_turf, EAST))
	analyser.complete_analysis()
	TEST_ASSERT_SUBSTRING(analyser.report, "aborted")
	artifact.forceMove(pad_turf)
	var/obj/machinery/xenoarch/harvester/harvester = allocate(/obj/machinery/xenoarch/harvester, location)
	var/obj/item/xenoarch_battery/battery = allocate(/obj/item/xenoarch_battery, harvester)
	harvester.specimen = battery
	harvester.source_artifact = WEAKREF(artifact)
	harvester.complete_analysis()
	TEST_ASSERT_EQUAL(battery.effect_type, "healing", "Harvesting must preserve the artifact effect")
	TEST_ASSERT_EQUAL(battery.charges, 10, "Harvested batteries must have finite charges")
	var/obj/item/xenoarch_utilizer/device = allocate(/obj/item/xenoarch_utilizer, location)
	battery.forceMove(device)
	device.battery = battery
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, location)
	user.adjustBruteLoss(10)
	device.attack_self(user)
	TEST_ASSERT_EQUAL(battery.charges, 9, "Using harvested effects must consume charge")
	TEST_ASSERT(user.getBruteLoss() < 10, "A harvested healing effect must actually heal its user")
	device.attack_self(user)
	TEST_ASSERT_EQUAL(battery.charges, 9, "Cooldown must prevent rapid-fire use")

/datum/unit_test/xenoarch_power_access_containment/Run()
	var/turf/location = locate(1, 1, 1)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, location)
	var/obj/item/card/id/id = allocate(/obj/item/card/id, user)
	user.equip_to_slot_if_possible(new /obj/item/clothing/under/rank/scientist(user), ITEM_SLOT_CLOTH_INNER)
	TEST_ASSERT(user.equip_to_slot_if_possible(id, ITEM_SLOT_ID), "The test scientist must wear an ID")
	var/obj/machinery/xenoarch/spectrometer/machine = allocate(/obj/machinery/xenoarch/spectrometer, location)
	machine.stat = NONE
	TEST_ASSERT_NOT(machine.available(user), "Unauthorized users must not operate laboratory devices")
	id.access = list(ACCESS_XENOARCH)
	TEST_ASSERT(machine.available(user), "Xenoarchaeology access must authorize the instruments")
	machine.stat |= NOPOWER
	TEST_ASSERT_NOT(machine.available(user), "Unpowered instruments must reject operation")
	var/obj/item/xenoarch_sample/sample = allocate(/obj/item/xenoarch_sample, machine)
	machine.specimen = sample
	machine.finish_at = world.time + 10 SECONDS
	machine.process()
	TEST_ASSERT_EQUAL(machine.finish_at, 0, "Power loss must cancel an active cycle")
	TEST_ASSERT_EQUAL(sample.loc, machine, "Power failure must preserve the specimen")
	var/obj/machinery/xenoarch/suspension/generator = allocate(/obj/machinery/xenoarch/suspension, location)
	generator.stat = NONE
	generator.enabled = TRUE
	var/obj/machinery/xenoarch_artifact/artifact = allocate(/obj/machinery/xenoarch_artifact, location)
	TEST_ASSERT(xenoarch_suppressed(artifact), "Powered fields must suppress nearby artifacts")
	TEST_ASSERT_NOT(artifact.toggle_activation(user), "Suppressed artifacts cannot be activated")
	generator.stat |= NOPOWER
	TEST_ASSERT_NOT(xenoarch_suppressed(artifact), "Power loss must disable containment")
	TEST_ASSERT(artifact.toggle_activation(user), "Artifacts must respond after containment is disabled")
	artifact.effect_mode = "touch"
	artifact.trigger_type = "force"

/datum/unit_test/xenoarch_icon_states/Run()
	for(var/type in typesof(/obj/item/xenoarch_tool) + typesof(/obj/machinery/xenoarch) + list(/obj/item/xenoarch_battery, /obj/item/xenoarch_utilizer, /obj/structure/xenoarch_scanpad, /obj/structure/xenoarch_boulder))
		var/atom/atom = type
		var/icon_file = initial(atom.icon)
		var/state = initial(atom.icon_state)
		if(state)
			TEST_ASSERT(state in icon_states(icon_file), "[type] must use an existing sprite: [state]")

/// Exercise the actual item/rock attack chain, including timed tool use and sampling.
/datum/unit_test/xenoarch_field_work/Run()
	if(!level_name_to_num(MINING))
		return
	var/turf/simulated/mineral/rock
	var/turf/standing
	for(var/turf/simulated/mineral/candidate as anything in GLOB.xenoarch_sites)
		var/datum/xenoarch_find/find = candidate.archaeology?.next_find()
		if(!find || find.large)
			continue
		for(var/direction in GLOB.cardinal)
			var/turf/adjacent = get_step(candidate, direction)
			if(isfloorturf(adjacent) && !adjacent.density)
				rock = candidate
				standing = adjacent
				break
		if(rock)
			break
	TEST_ASSERT_NOTNULL(rock, "Digsites must be reachable from the asteroid's surface and caves")
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, standing)
	var/obj/item/xenoarch_tool/core_sampler/sampler = allocate(/obj/item/xenoarch_tool/core_sampler, standing)
	user.put_in_hands(sampler)
	sampler.afterattack(rock, user, TRUE)
	var/obj/item/xenoarch_sample/sample = locate() in user
	TEST_ASSERT_NOTNULL(sample, "Using the sampler must produce a portable geological sample")
	var/datum/xenoarch_find/find = rock.archaeology.next_find()
	TEST_ASSERT_EQUAL(sample.anomaly_id, find.id, "The sample must record the scanned inclusion")
	user.drop_transfer_item_to_loc(sample, standing)
	user.drop_transfer_item_to_loc(sampler, standing)
	var/obj/machinery/xenoarch/spectrometer/spectrometer = allocate(/obj/machinery/xenoarch/spectrometer, standing)
	sample.forceMove(spectrometer)
	spectrometer.specimen = sample
	spectrometer.complete_analysis()
	TEST_ASSERT_SUBSTRING(spectrometer.report, find.carrier)
	var/obj/item/xenoarch_tool/depth_scanner/scanner = allocate(/obj/item/xenoarch_tool/depth_scanner, standing)
	user.put_in_hands(scanner)
	scanner.afterattack(rock, user, TRUE)
	TEST_ASSERT_EQUAL(length(scanner.readings), 1, "Using the depth scanner must record a field reading")
	find.depth = 2
	find.clearance = 2
	var/obj/item/xenoarch_tool/pick/tool = allocate(/obj/item/xenoarch_tool/pick, standing)
	user.put_in_hands(tool)
	tool.excavation_time = 1
	var/result = rock.attackby(tool, user)
	TEST_ASSERT_EQUAL(result, ATTACK_CHAIN_BLOCKED_ALL, "Excavation must consume the attack instead of ordinary drilling")
	TEST_ASSERT(find.recovered, "The actual pick attack must recover the inclusion after its delay")
	var/turf/dig_turf = get_turf(rock)
	var/obj/item/xenoarch_relic/relic = locate() in dig_turf
	TEST_ASSERT_NOTNULL(relic, "Field excavation must spawn a tangible relic")
	var/source_coords = sample.source_coords
	rock.gets_drilled(user)
	TEST_ASSERT_EQUAL(sample.source_coords, source_coords, "Mining the source rock must not invalidate its sealed sample")
	TEST_ASSERT_EQUAL(get_turf(relic), dig_turf, "Recovered relics must remain collectible after mining the rock")
	qdel(relic)
