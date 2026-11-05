/// Mining loot and shared tools must remain usable after retiring Lavaland roles.
/datum/unit_test/mining_fishing_loot/Run()
	var/turf/test_turf = locate(1, 1, 1)
	var/mob/living/carbon/human/miner = allocate(/mob/living/carbon/human, test_turf)
	var/list/fish_types = GLOB.deep_fish + GLOB.shore_fish
	TEST_ASSERT(length(fish_types), "Lava fishing must retain its catch pool")
	for(var/fish_type in fish_types)
		var/obj/item/lavaland_fish/fish = allocate(fish_type, test_turf)
		TEST_ASSERT(length(fish.butcher_loot), "[fish_type] must yield loot")
		fish.harvest(miner)
		TEST_ASSERT(QDELETED(fish), "Harvesting [fish_type] must finish")

/datum/unit_test/mining_boss_chests/Run()
	var/turf/test_turf = locate(1, 1, 1)
	var/list/chest_types = list(
		/obj/structure/closet/crate/necropolis/bubblegum,
		/obj/structure/closet/crate/necropolis/bubblegum/crusher,
		/obj/structure/closet/crate/necropolis/colossus,
		/obj/structure/closet/crate/necropolis/colossus/crusher,
	)
	for(var/chest_type in chest_types)
		var/obj/structure/closet/crate/chest = allocate(chest_type, test_turf)
		TEST_ASSERT(length(chest.contents), "[chest_type] must retain its mining rewards")

/datum/unit_test/mining_shared_species/Run()
	var/turf/test_turf = locate(1, 1, 1)
	var/mob/living/carbon/human/pod_diona/podman = allocate(/mob/living/carbon/human/pod_diona, test_turf)
	TEST_ASSERT(isdiona(podman), "Replicapod revival must retain its plant species")
	var/mob/living/simple_animal/hostile/hellhound/hound = allocate(/mob/living/simple_animal/hostile/hellhound, test_turf)
	TEST_ASSERT_NOTNULL(hound.whisper_action, "Hellhounds must retain their independent whisper ability")
