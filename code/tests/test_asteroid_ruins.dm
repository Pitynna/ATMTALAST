/// Returns the turfs of a placed asteroid ruin by its area, or null when the mine was not loaded.
/// Ruin landmarks are created before atoms initialize and lose their template, so the area is the reliable handle.
/datum/unit_test/proc/asteroid_ruin_turfs(area_type)
	var/mining_z = get_optional_mining_z()
	if(!mining_z)
		return null // Minimal test maps and SKIP_MINING deliberately omit the mine.
	var/list/turfs = get_area_turfs(area_type, mining_z, TRUE)
	if(!length(turfs))
		TEST_FAIL("[area_type] was not placed on the asteroid")
		return null
	return turfs

/// Both asteroid ruins must be seeded into solid rock and stay buried after the caves are carved.
/datum/unit_test/asteroid_ruins_placement/Run()
	var/mining_z = get_optional_mining_z()
	if(!mining_z)
		return
	TEST_ASSERT(length(GLOB.asteroid_ruins_templates) >= 2, "The asteroid ruin templates were not preloaded")
	for(var/area_type in list(/area/ruin/asteroid/saddam_hideout, /area/ruin/asteroid/schizo_room))
		var/list/turfs = asteroid_ruin_turfs(area_type)
		if(!turfs)
			continue
		var/min_x = world.maxx
		var/min_y = world.maxy
		var/max_x = 1
		var/max_y = 1
		for(var/turf/tile as anything in turfs)
			min_x = min(min_x, tile.x)
			min_y = min(min_y, tile.y)
			max_x = max(max_x, tile.x)
			max_y = max(max_y, tile.y)
		// One copy only, and nothing but rock in the ring around it.
		TEST_ASSERT(max_x - min_x < 12 && max_y - min_y < 12, "[area_type] must be placed exactly once")
		for(var/turf/around as anything in block(min_x - 1, min_y - 1, mining_z, max_x + 1, max_y + 1, mining_z))
			if(around.x >= min_x && around.x <= max_x && around.y >= min_y && around.y <= max_y)
				continue
			TEST_ASSERT(ismineralturf(around), "[area_type] must stay buried, but [around.type] at [around.x],[around.y] touches it")

/// The rune takes a living creature that stays on it, opens the sealed wall, and Saddam drops his briefcase.
/datum/unit_test/asteroid_saddam_hideout/Run()
	var/list/turfs = asteroid_ruin_turfs(/area/ruin/asteroid/saddam_hideout)
	if(!turfs)
		return
	var/obj/effect/saddam_rune/rune
	var/obj/structure/falsewall/saddam/door
	var/mob/living/simple_animal/saddam/saddam
	var/obj/item/toy/desk/fan/saddam/fan
	for(var/turf/tile as anything in turfs)
		rune ||= locate() in tile
		door ||= locate() in tile
		saddam ||= locate() in tile
		fan ||= locate() in tile
		if(tile.density && istype(get_area(tile), /area/ruin/asteroid/saddam_hideout))
			TEST_ASSERT(istype(tile, /turf/simulated/wall/indestructible), "The hideout must be built of indestructible walls, found [tile.type]")
	TEST_ASSERT_NOTNULL(rune, "The hideout has no rune")
	TEST_ASSERT_NOTNULL(door, "The hideout has no sealed wall")
	TEST_ASSERT_NOTNULL(saddam, "Saddam is not home")
	TEST_ASSERT_NOTNULL(fan, "Saddam has no fan")
	TEST_ASSERT(fan.on, "The fan must already be running")
	TEST_ASSERT(HAS_TRAIT(saddam, TRAIT_IMMOBILIZED), "Saddam must not be able to walk")
	TEST_ASSERT_EQUAL(get_dist(rune, door), 1, "The rune must lie right in front of the sealed wall")

	var/turf/rune_turf = get_turf(rune)
	var/turf/aside = get_step(rune_turf, WEST)
	TEST_ASSERT(door.density, "The wall must start sealed")
	door.toggle()
	door.ex_act(EXPLODE_DEVASTATE)
	TEST_ASSERT(door.density && !QDELETED(door), "The sealed wall must not open by hand or by a bomb")

	// A corpse is not a payment.
	var/mob/living/simple_animal/mouse/corpse = allocate(/mob/living/simple_animal/mouse, aside)
	corpse.death()
	corpse.forceMove(rune_turf)
	sleep(rune.charge_time + 0.5 SECONDS)
	TEST_ASSERT(door.density && !rune.spent, "A dead body must not open the hideout")
	corpse.forceMove(aside)

	// Stepping off in time saves the creature and keeps the wall shut.
	// A human, because a mouse wanders off the rune on its own.
	var/mob/living/carbon/human/coward = allocate(/mob/living/carbon/human, aside)
	coward.forceMove(rune_turf)
	sleep(rune.charge_time * 0.5)
	coward.forceMove(aside)
	sleep(rune.charge_time)
	TEST_ASSERT(door.density && !rune.spent, "Leaving the rune in time must not open the hideout")
	TEST_ASSERT(!QDELETED(coward) && coward.stat != DEAD, "Leaving the rune in time must save the creature")

	// Staying pays.
	coward.forceMove(rune_turf)
	sleep(rune.charge_time + 1.5 SECONDS)
	TEST_ASSERT(rune.spent, "A creature that stayed on the rune must be taken")
	TEST_ASSERT(QDELETED(coward), "The creature on the rune must be gibbed")
	TEST_ASSERT(locate(/obj/effect/decal/cleanable/blood/gibs) in range(4, rune_turf), "Guts must fly around the rune")
	TEST_ASSERT(!door.density && !door.opacity, "The paid rune must open the sealed wall")

	saddam.death()
	var/obj/item/storage/briefcase/saddam/briefcase = locate() in get_turf(saddam)
	TEST_ASSERT_NOTNULL(briefcase, "Saddam must drop his briefcase")
	var/obj/item/stack/spacecash/cash = locate() in briefcase
	TEST_ASSERT_NOTNULL(cash, "The briefcase must hold the money")
	TEST_ASSERT_EQUAL(cash.amount, 75000, "The briefcase must hold 75000 credits")
	var/obj/item/gun/projectile/automatic/pistol/stechkin/pistol = locate() in briefcase
	TEST_ASSERT_NOTNULL(pistol, "The briefcase must hold the Stechkin")
	TEST_ASSERT(pistol.magazine?.ammo_count() > 0, "The Stechkin must come with a loaded magazine")

/// The studio guests talk without errors and the hung poster makes people who see it count out loud.
/datum/unit_test/asteroid_schizo_room/Run()
	var/list/turfs = asteroid_ruin_turfs(/area/ruin/asteroid/schizo_room)
	if(!turfs)
		return
	var/mob/living/simple_animal/schizo/rybnikov/rybnikov
	var/mob/living/simple_animal/schizo/boyarshinov/boyarshinov
	var/obj/structure/tripod/schizo_studio/tripod
	var/obj/item/poster/schizo_count/rolled
	var/turf/free_floor
	for(var/turf/tile as anything in turfs)
		rybnikov ||= locate() in tile
		boyarshinov ||= locate() in tile
		tripod ||= locate() in tile
		rolled ||= locate() in tile
		if(!free_floor && !tile.density && !length(tile.contents))
			free_floor = tile
	TEST_ASSERT_NOTNULL(rybnikov, "Rybnikov is not in the studio")
	TEST_ASSERT_NOTNULL(boyarshinov, "Boyarshinov is not in the studio")
	TEST_ASSERT_NOTNULL(tripod, "The studio has no tripod")
	TEST_ASSERT_NOTNULL(tripod.tripod_item.camera, "The tripod must carry a camera")
	TEST_ASSERT_NOTNULL(rolled, "The poster is not on the table")
	TEST_ASSERT_NOTNULL(free_floor, "The studio has no free floor")
	TEST_ASSERT(icon_exists(rolled.icon, rolled.icon_state), "The rolled poster has no icon")

	// The whole count, sped up.
	rybnikov.count_step = 0.1 SECONDS
	rybnikov.lecturing = TRUE
	rybnikov.count_on(1)
	sleep(rybnikov.count_step * (length(GLOB.schizo_count) + 8))
	TEST_ASSERT(!rybnikov.lecturing, "Rybnikov must finish the count")
	rybnikov.handle_automated_speech(TRUE)
	boyarshinov.handle_automated_speech(TRUE)
	boyarshinov.react()

	var/obj/structure/sign/poster/contraband/schizo_count/poster = rolled.poster_structure
	TEST_ASSERT_NOTNULL(poster, "The rolled poster must contain the schizo poster")
	TEST_ASSERT(icon_exists(poster.icon, poster.icon_state), "The poster has no icon")
	TEST_ASSERT(icon_exists(poster.icon, "poster_being_set"), "The poster has no hanging animation")
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human, free_floor)
	poster.process()
	TEST_ASSERT_EQUAL(poster.count_index, 1, "A rolled-up poster must be harmless")

	poster.forceMove(free_floor)
	poster.process()
	TEST_ASSERT_EQUAL(poster.count_index, 2, "A hung poster must make the viewer shout the first number")
	COOLDOWN_RESET(poster, shout_cooldown)
	poster.process()
	TEST_ASSERT_EQUAL(poster.count_index, 3, "The count must go on in order")
	viewer.death()
	COOLDOWN_RESET(poster, shout_cooldown)
	poster.process()
	TEST_ASSERT_EQUAL(poster.count_index, 1, "With nobody to see it the poster starts over")
	var/obj/item/poster/rerolled = poster.roll_and_drop(free_floor)
	TEST_ASSERT(icon_exists(rerolled.icon, rerolled.icon_state), "A poster taken off the wall must keep its rolled icon")
	qdel(rerolled)
