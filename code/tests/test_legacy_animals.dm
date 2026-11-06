/// Reclassified old pets must survive, while new named pets must disappear even on direct spawn.
/datum/unit_test/legacy_animal_roster/Run()
	var/turf/test_turf = locate(4, 4, 1)
	for(var/animal_type in list(/mob/living/simple_animal/cow/Betsy, /mob/living/simple_animal/cock/Commandor, /mob/living/simple_animal/pet/dog/corgi/Ian, /mob/living/simple_animal/pet/dog/corgi/Lisa, /mob/living/simple_animal/pet/cat/Runtime, /mob/living/simple_animal/pet/cat/Proc, /mob/living/simple_animal/pet/dog/fox/Renault, /mob/living/simple_animal/pet/dog/pug, /mob/living/simple_animal/frog/toxic, /mob/living/simple_animal/hostile/retaliate/poison/snake, /mob/living/basic/cockroach))
		var/mob/living/animal = allocate(animal_type, test_turf)
		if(animal_type == /mob/living/simple_animal/pet/dog/corgi/Ian && QDELETED(animal))
			// Persistent Ian becomes a puppy at age zero on a fresh server.
			var/mob/living/simple_animal/pet/dog/corgi/puppy/ian_puppy = locate() in test_turf
			TEST_ASSERT(ian_puppy && ian_puppy.name == "Ian", "Fresh persistent Ian must survive as his old puppy form")
			qdel(ian_puppy)
		else
			TEST_ASSERT_NOT(QDELETED(animal), "Old animal [animal_type] must remain usable after reclassification")
	for(var/animal_type in list(/mob/living/simple_animal/pig/Sanya, /mob/living/simple_animal/chicken/Wife, /mob/living/simple_animal/goose/Scientist, /mob/living/simple_animal/pet/cat/fat/Iriska, /mob/living/simple_animal/pet/cat/white/Penny, /mob/living/simple_animal/pet/cat/birman/Crusher, /mob/living/simple_animal/mouse/wooly/rep, /mob/living/simple_animal/pet/library_owl, /mob/living/simple_animal/mouse/rat/white/Brain, /mob/living/simple_animal/mouse/rat/Ratatui, /mob/living/simple_animal/mouse/rat/irish/Remi, /mob/living/simple_animal/pet/dog/fox/fennec/Fenya, /mob/living/simple_animal/pet/dog/brittany/Psycho, /mob/living/simple_animal/pet/dog/pug/Frank, /mob/living/basic/mothroach))
		var/mob/living/animal = allocate(animal_type, test_turf)
		TEST_ASSERT(QDELETED(animal), "New animal [animal_type] must not survive a direct spawn")

/// Filtering only a pack's loose contents misses crates that spawn their animal when opened.
/datum/unit_test/legacy_animal_cargo/Run()
	for(var/key in SSshuttle.supply_packs)
		var/datum/supply_packs/pack = SSshuttle.supply_packs[key]
		TEST_ASSERT_NOT(is_legacy_blocked_type(pack.containertype), "Cargo must not offer an empty retired animal crate: [pack.name]")
	for(var/crate_type in list(/obj/structure/closet/crate/critter/cat, /obj/structure/closet/crate/critter/fox, /obj/structure/closet/crate/critter/goat, /obj/structure/closet/crate/critter/corgi))
		for(var/attempt in 1 to 20)
			var/obj/structure/closet/crate/critter/crate = allocate(crate_type, locate(4, 4, 1))
			TEST_ASSERT_NOT(QDELETED(crate), "Old animal crate must remain available")
			TEST_ASSERT_NOT(is_legacy_blocked_type(crate.content_mob), "Crate randomization must not substitute a retired animal")
			qdel(crate)
	TEST_ASSERT(is_legacy_blocked_type(/obj/structure/closet/crate/critter/gorilla), "Delayed gorilla spawner must be blocked")
	TEST_ASSERT(is_legacy_blocked_type(/obj/structure/closet/crate/critter/dog_brittany), "Delayed new dog spawner must be blocked")

/// A rejected random roll must not silently waste a slime extract or dimensional-tear spawn.
/datum/unit_test/legacy_animal_random_spawns/Run()
	for(var/mob_class in list(FRIENDLY_SPAWN, HOSTILE_SPAWN))
		for(var/attempt in 1 to 80)
			var/mob/living/animal = create_random_mob(locate(4, 4, 1), mob_class)
			TEST_ASSERT_NOT(QDELETED(animal), "Random animals must produce a live, available result")
			TEST_ASSERT_NOT(is_legacy_blocked_type(animal.type), "Random spawning must honor the old roster")
			qdel(animal)

/// Growing a chick must never transfer a mind into the deleted new rooster type.
/datum/unit_test/legacy_animal_growth/Run()
	for(var/attempt in 1 to 40)
		var/mob/living/simple_animal/chick/chick = allocate(/mob/living/simple_animal/chick, locate(4, 4, 1))
		chick.amount_grown = 100
		var/datum/mind/mind = new
		mind.transfer_to(chick)
		chick.Life(1, 1)
		TEST_ASSERT(istype(mind.current, /mob/living/simple_animal/chicken), "Every chick must grow into an available old chicken")
		qdel(mind.current)
		qdel(mind)
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/queen = allocate(/mob/living/simple_animal/hostile/poison/terror_spider/queen, locate(4, 4, 1))
	var/list/egg_types = queen.ListAvailableEggTypes()
	TEST_ASSERT_NOT(TS_DESC_REAPER in egg_types, "Queen must not offer reaper eggs")
	TEST_ASSERT_NOT(TS_DESC_BUILDER in egg_types, "Queen must not offer drone eggs")
	TEST_ASSERT_NOT(TS_DESC_PRINCESS in egg_types, "Queen must not offer princess eggs")

/// Both admin spawn interfaces must omit the removed animals and their delayed cargo crates.
/datum/unit_test/legacy_animal_admin_catalogs/Run()
	var/datum/asset/json/spawn_menu/search_asset = new
	var/list/search_data = search_asset.generate()
	var/list/search_types = search_data["types"]
	var/datum/asset/json/spawnpanel/panel_asset = new
	var/list/panel_data = panel_asset.generate()
	var/list/panel_types = panel_data["atoms"]
	for(var/animal_type in list(/mob/living/simple_animal/pet/dog/corgi/Ian, /mob/living/simple_animal/pet/cat/Runtime))
		TEST_ASSERT(animal_type in search_types, "Old pet must remain in Spawn search")
		TEST_ASSERT(animal_type in panel_types, "Old pet must remain in SpawnPanel")
	for(var/removed_type in list(/mob/living/simple_animal/pig/Sanya, /mob/living/simple_animal/pet/dog/brittany, /mob/living/simple_animal/pet/library_owl, /obj/structure/closet/crate/critter/gorilla))
		TEST_ASSERT_NOT(removed_type in search_types, "Retired type must not appear in Spawn search")
		TEST_ASSERT_NOT(removed_type in panel_types, "Retired type must not appear in SpawnPanel")
	qdel(search_asset)
	qdel(panel_asset)
