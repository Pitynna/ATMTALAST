/// Shared species must remain usable after retiring the planetary mining content.
/datum/unit_test/mining_shared_species/Run()
	var/turf/test_turf = locate(1, 1, 1)
	var/mob/living/carbon/human/pod_diona/podman = allocate(/mob/living/carbon/human/pod_diona, test_turf)
	TEST_ASSERT(isdiona(podman), "Replicapod revival must retain its plant species")
	var/mob/living/simple_animal/hostile/hellhound/hound = allocate(/mob/living/simple_animal/hostile/hellhound, test_turf)
	TEST_ASSERT_NOTNULL(hound.whisper_action, "Hellhounds must retain their independent whisper ability")

/// The actual loaded mining map must be an ore-bearing asteroid with a safe outpost.
/datum/unit_test/mining_asteroid_layout/Run()
	var/mining_z = level_name_to_num(MINING)
	if(!mining_z)
		return // Minimal test maps and SKIP_MINING deliberately omit the mine.
	TEST_ASSERT_NOT(is_station_level(mining_z), "Mining must use a separate Z-level")
	TEST_ASSERT(check_level_trait(mining_z, ORE_LEVEL), "Mining ore must count towards mining progression")
	TEST_ASSERT(check_level_trait(mining_z, STATION_CONTACT), "Mining must retain radio and station contact")
	TEST_ASSERT_NOT(check_level_trait(mining_z, ZTRAIT_ASHSTORM), "An asteroid must not have ash storms")
	TEST_ASSERT_EQUAL(check_level_trait(mining_z, ZTRAIT_BASETURF), /turf/space, "Broken asteroid terrain must reveal space")
	var/datum/space_level/level = GLOB.space_manager.get_zlev(mining_z)
	TEST_ASSERT_EQUAL(level.linkage, CROSSLINKED, "The asteroid must be reachable through space")
	var/rock_count = 0
	var/cave_floor_count = 0
	var/space_count = 0
	var/frontier_caves = 0
	var/frontier_ores = 0
	var/list/ore_types = list()
	for(var/turf/tile as anything in Z_TURFS(mining_z))
		if(isspaceturf(tile))
			space_count++
		if(tile.x <= 8 || tile.y <= 8 || tile.x > world.maxx - 8 || tile.y > world.maxy - 8)
			TEST_ASSERT(isspaceturf(tile), "The expanded asteroid must retain an eight-tile space border")
		if(istype(tile, /turf/simulated/mineral))
			rock_count++
			var/turf/simulated/mineral/rock = tile
			if(rock.mineralType)
				ore_types |= rock.mineralType
				if(tile.x <= 60 || tile.x >= 220 || tile.y <= 35 || tile.y >= 225)
					frontier_ores++
		if(istype(tile, /turf/simulated/floor/plating/asteroid/airless))
			cave_floor_count++
			if(tile.x <= 60 || tile.x >= 220 || tile.y <= 35 || tile.y >= 225)
				frontier_caves++
		TEST_ASSERT_NOT(istype(tile, /turf/simulated/floor/lava), "No lava may spawn on the asteroid")
		TEST_ASSERT_NOT(istype(tile, /turf/simulated/floor/chasm), "No planetary chasms may spawn on the asteroid")
		TEST_ASSERT_NOT(istype(tile, /turf/simulated/floor/plating/asteroid/airless/cave_seed), "All cave seeds must be generated")
	TEST_ASSERT(world.maxx * world.maxy - space_count >= 50000, "The expanded asteroid must occupy at least fifty thousand tiles")
	TEST_ASSERT(rock_count > 30000, "The expanded asteroid must contain substantial new mineable rock")
	TEST_ASSERT(frontier_ores > 100, "The outer mining regions must generate ordinary ore")
	TEST_ASSERT(frontier_caves > 200, "Caves must also generate in the expanded outer regions")
	TEST_ASSERT(cave_floor_count > 100, "The asteroid must have airless paths and caves")
	TEST_ASSERT(length(ore_types) >= 7, "The asteroid must supply the ordinary station ores")
	var/obj/structure/closet/secure_closet/miner/locker
	for(var/obj/structure/closet/secure_closet/miner/candidate in world)
		if(candidate.z == mining_z)
			locker = candidate
			break
	TEST_ASSERT_NOTNULL(locker, "The mining outpost must contain an equipment locker")
	var/turf/outpost = get_turf(locker)
	var/datum/gas_mixture/outpost_air = outpost.get_readonly_air()
	TEST_ASSERT(outpost_air.return_pressure() > 70, "The mining outpost must be pressurized")
	var/turf/exterior = locate(123, 151, mining_z)
	var/datum/gas_mixture/exterior_air = exterior.get_readonly_air()
	TEST_ASSERT(exterior_air.return_pressure() < 1, "The asteroid exterior must be vacuum")
	var/obj/bfl_crack/deposit = locate() in exterior
	TEST_ASSERT_NOTNULL(deposit, "The existing industrial mining goal must retain its deposit")
	log_world("Asteroid inventory: [rock_count] rocks, [cave_floor_count] cave floors, [length(ore_types)] ore types")
	log_world("Asteroid expansion: [world.maxx * world.maxy - space_count] terrain tiles, [space_count] space tiles, [frontier_caves] outer cave floors, [frontier_ores] outer ore deposits")
	for(var/dock_id in list("mining_away", "laborcamp_away", "skipjack_z5", "syndicate_z5"))
		var/obj/docking_port/stationary/dock = SSshuttle.getDock(dock_id)
		TEST_ASSERT_NOTNULL(dock, "The asteroid must retain [dock_id]")
		for(var/turf/pad as anything in dock.return_turfs())
			TEST_ASSERT_NOT(ismineralturf(pad), "The expanded rock must not obstruct [dock_id]")

/datum/unit_test/mining_asteroid_equipment/Run()
	var/turf/test_turf = locate(1, 1, 1)
	var/list/locker_types = list(/obj/structure/closet/secure_closet/miner)
	for(var/locker_type in locker_types)
		var/obj/structure/closet/locker = allocate(locker_type, test_turf)
		var/obj/item/clothing/suit/space/hardsuit/mining/suit = locate() in locker
		TEST_ASSERT_NOTNULL(suit, "[locker_type] must supply an EVA hardsuit")
		TEST_ASSERT_NOTNULL(suit.helmet, "The mining hardsuit must create its integrated helmet")
		TEST_ASSERT(suit.clothing_flags & STOPSPRESSUREDAMAGE, "The mining suit must protect against vacuum")
		TEST_ASSERT_NOTNULL(locate(/obj/item/clothing/mask/breath) in locker, "[locker_type] must supply a breathing mask")
		TEST_ASSERT_NOTNULL(locate(/obj/item/tank/internals/oxygen) in locker, "[locker_type] must supply oxygen")
	var/mob/living/carbon/human/miner = allocate(/mob/living/carbon/human, test_turf)
	miner.equipOutfit(/datum/outfit/job/mining/equipped)
	TEST_ASSERT(istype(miner.wear_suit, /obj/item/clothing/suit/space/hardsuit/mining), "The equipped miner must receive an EVA suit")
	TEST_ASSERT_NOTNULL(miner.head, "The equipped miner's helmet must deploy")
	TEST_ASSERT(miner.head.clothing_flags & STOPSPRESSUREDAMAGE, "The equipped miner's helmet must protect against vacuum")
	for(var/unit_type in list(/obj/machinery/suit_storage_unit/mining, /obj/machinery/suit_storage_unit/lavaland))
		var/obj/machinery/suit_storage_unit/unit = allocate(unit_type, test_turf)
		TEST_ASSERT(istype(unit.suit, /obj/item/clothing/suit/space/hardsuit/mining), "[unit_type] must supply a pressure-safe mining suit")

/// Exercise both real transport routes, including cargo retention and vacated docking pads.
/datum/unit_test/mining_asteroid_shuttles/Run()
	var/mining_z = level_name_to_num(MINING)
	if(!mining_z)
		return
	for(var/shuttle_id in list("mining", "laborcamp"))
		var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(shuttle_id)
		var/obj/docking_port/stationary/home = SSshuttle.getDock("[shuttle_id]_home")
		var/obj/docking_port/stationary/away = SSshuttle.getDock("[shuttle_id]_away")
		TEST_ASSERT_NOTNULL(shuttle, "[shuttle_id] must exist")
		TEST_ASSERT_NOTNULL(home, "[shuttle_id] must have a station dock")
		TEST_ASSERT_NOTNULL(away, "[shuttle_id] must have an asteroid dock")
		TEST_ASSERT_EQUAL(away.z, mining_z, "[shuttle_id] must dock on the asteroid")
		TEST_ASSERT_EQUAL(away.turf_type, /turf/space, "The vacated docking pad must restore space")
		TEST_ASSERT(shuttle.check_dock(away), "[shuttle_id] must fit its asteroid dock")
		var/obj/item/stack/ore/iron/cargo = allocate(/obj/item/stack/ore/iron, get_turf(shuttle), 5)
		shuttle.dock(away)
		var/deadline = world.time + 10 SECONDS
		while(shuttle.get_docked() != away && world.time < deadline)
			sleep(1)
		TEST_ASSERT_EQUAL(shuttle.get_docked(), away, "[shuttle_id] must arrive at the asteroid")
		TEST_ASSERT_EQUAL(cargo.z, mining_z, "[shuttle_id] must carry ore to the asteroid")
		shuttle.dock(home)
		deadline = world.time + 10 SECONDS
		while(shuttle.get_docked() != home && world.time < deadline)
			sleep(1)
		TEST_ASSERT_EQUAL(shuttle.get_docked(), home, "[shuttle_id] must return to the station")
		TEST_ASSERT_EQUAL(cargo.z, home.z, "[shuttle_id] must bring ore back to the station")
		TEST_ASSERT(isspaceturf(get_turf(away)), "The vacated asteroid dock must be space")

/datum/unit_test/mining_retired_planet/Run()
	for(var/retired_path in list(
		"/area/lavaland",
		"/datum/lavaland_theme",
		"/datum/map_template/ruin/lavaland",
		"/datum/weather/ash_storm",
		"/mob/living/simple_animal/hostile/megafauna",
		"/obj/structure/spawner/lavaland",
		"/obj/structure/world_anvil",
		"/obj/item/twohanded/fishing_rod",
		"/obj/item/magmite_parts",
	))
		TEST_ASSERT_NULL(text2path(retired_path), "[retired_path] must not remain spawnable")

/datum/unit_test/mining_asteroid_ore_processing/Run()
	var/mining_z = level_name_to_num(MINING)
	if(!mining_z)
		return
	var/turf/simulated/mineral/iron/deposit
	for(var/turf/simulated/mineral/iron/candidate as anything in Z_TURFS(mining_z))
		if(istype(candidate))
			deposit = candidate
			break
	TEST_ASSERT_NOTNULL(deposit, "The asteroid must provide mineable iron")
	var/deposit_x = deposit.x
	var/deposit_y = deposit.y
	deposit.gets_drilled()
	var/turf/mined_floor = locate(deposit_x, deposit_y, mining_z)
	TEST_ASSERT(istype(mined_floor, /turf/simulated/floor/plating/asteroid/airless), "Mining rock must expose airless asteroid floor")
	var/obj/item/stack/ore/iron/ore = locate() in mined_floor
	TEST_ASSERT_NOTNULL(ore, "Mining iron must drop usable ore")
	TEST_ASSERT(ore.amount > 0, "The mined ore stack must not be empty")
	var/obj/machinery/mineral/ore_redemption/processor = allocate(/obj/machinery/mineral/ore_redemption, locate(1, 1, 1))
	processor.smelt_ore(ore)
	TEST_ASSERT(processor.points > 0, "Asteroid ore must award mining equipment points")
	var/datum/component/material_container/materials = processor.GetComponent(/datum/component/material_container)
	var/datum/material/metal = materials.materials[MAT_METAL]
	TEST_ASSERT(metal.amount > 0, "Asteroid ore must produce metal for the station")
