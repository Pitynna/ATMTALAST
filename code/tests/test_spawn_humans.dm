/datum/unit_test/room_test/spawn_humans/Run()
	for(var/I in 1 to 5)
		allocate(/mob/living/carbon/human, pick(available_turfs))

	// There is a 5 second delay here so that all the items on the humans have time to initialize and spawn
	sleep(5 SECONDS)

/// Tests [/mob/living/carbon/human/proc/setup_organless_effects], specifically that they aren't applied when init is done
/datum/unit_test/room_test/human_default_traits

/datum/unit_test/room_test/human_default_traits/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human)
	TEST_ASSERT(!HAS_TRAIT_FROM(dummy, TRAIT_DEAF, NO_EARS), "Dummy is deaf on init, when it should've been removed by its default ears.")

/datum/unit_test/room_test/starting_backpack/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human)
	wearer.equipOutfit(/datum/outfit/job/clown)
	var/obj/item/instrument/bikehorn/horn = locate() in wearer.back
	TEST_ASSERT_NOTNULL(horn, "The clown's instrument must stay in the starting backpack")
	TEST_ASSERT(horn.item_flags & IN_STORAGE, "Backpack contents must be marked as stored")

/datum/unit_test/room_test/silicon_outfit_preview/Run()
	var/mob/living/carbon/human/dummy/model = allocate(/mob/living/carbon/human/dummy)
	for(var/job_type in list(/datum/job/ai, /datum/job/cyborg))
		var/datum/job/job = allocate(job_type)
		job.equip(model, visualsOnly = TRUE, announce = FALSE)
		TEST_ASSERT(!QDELETED(model) && !HAS_TRAIT(model, TRAIT_NO_TRANSFORM), "Preview must preserve the human mannequin")
