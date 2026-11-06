/datum/unit_test/atmta_loadout_catalogue/Run()
	var/count = 0
	for(var/gear_type in subtypesof(/datum/gear/atmta))
		var/datum/gear/gear = new gear_type
		TEST_ASSERT(gear.index_name in GLOB.gear_datums, "[gear_type] must be in the real loadout catalogue")
		TEST_ASSERT_EQUAL(gear.donator_tier, 0, "Historical karma clothes must not require donations")
		var/obj/item/item = allocate(gear.path, locate(20, 20, 1))
		TEST_ASSERT(item.slot_flags & gear.slot, "[gear.path] must fit its loadout slot")
		TEST_ASSERT(item.icon_state in icon_states(item.icon), "[gear.path] must have a ground sprite")
		var/state = item.icon_state
		if(isclothing(item) && istype(item, /obj/item/clothing/under))
			state += "_s"
		else if(istype(item, /obj/item/clothing/gloves))
			state = item.item_state
		var/worn_icon = item.onmob_sheets[slot_bitfield_to_slot_string(gear.slot)]
		TEST_ASSERT_NOTNULL(worn_icon, "[gear.path] must have a worn sheet for its slot")
		TEST_ASSERT(state in icon_states(worn_icon), "[gear.path] must have a worn sprite: [state]")
		count++
		qdel(gear)
	TEST_ASSERT_EQUAL(count, 38, "The complete historical karma catalogue must be ported")

/datum/unit_test/atmta_loadout_role_access/Run()
	var/datum/gear/atmta/dornan/helmet = new
	TEST_ASSERT(helmet.can_select(null, JOB_TITLE_WARDEN, SPECIES_HUMAN, TRUE), "The warden must be able to select Dornan's helmet")
	TEST_ASSERT_NOT(helmet.can_select(null, JOB_TITLE_CIVILIAN, SPECIES_HUMAN, TRUE), "Dornan's helmet must not become unrestricted armor")
	qdel(helmet)
	var/datum/gear/atmta/hev/hev = new
	TEST_ASSERT(hev.can_select(null, JOB_TITLE_ENGINEER, SPECIES_HUMAN, TRUE), "Engineers must retain HEV access")
	TEST_ASSERT_NOT(hev.can_select(null, JOB_TITLE_CIVILIAN, SPECIES_HUMAN, TRUE), "HEV must keep its profession restriction")
	qdel(hev)
	for(var/gear_type in subtypesof(/datum/gear/atmta))
		var/datum/gear/gear = new gear_type
		TEST_ASSERT_NOT(findtext("[gear.path]", "doom") || findtext("[gear.path]", "hunter") || findtext("[gear.path]", "invisible") || findtext("[gear.path]", "bane"), "Admin-only equipment must not enter the loadout")
		qdel(gear)

/datum/unit_test/atmta_parasha_scavenging/Run()
	var/turf/ground = locate(20, 20, 1)
	var/obj/structure/toilet/parasha/toilet = allocate(/obj/structure/toilet/parasha, ground)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, ground)
	var/obj/item/kitchen/utensil/fork/fork = allocate(/obj/item/kitchen/utensil/fork, ground)
	user.put_in_hands(fork)
	toilet.open = FALSE
	toilet.attackby(fork, user)
	TEST_ASSERT_EQUAL(toilet.next_scavenge, 0, "A closed toilet must not dispense loot")
	toilet.open = TRUE
	toilet.attackby(fork, user)
	TEST_ASSERT(toilet.next_scavenge > world.time, "A real fork search must start the shared cooldown")
	TEST_ASSERT_NOT(toilet.scavenging, "The search must release its busy flag")
	TEST_ASSERT_NULL(toilet.spawn_loot(user), "The toilet must not dispense twice during the cooldown")
	toilet.next_scavenge = 0
	var/obj/item/treasure = toilet.spawn_loot(user)
	TEST_ASSERT_NOTNULL(treasure, "The toilet must dispense again after its cooldown")
	TEST_ASSERT_NOT(is_legacy_blocked_type(treasure.type), "The loot must respect removed-content restrictions")
	qdel(treasure)
	for(var/state in list("toilet00", "toilet01", "toilet10", "toilet11"))
		TEST_ASSERT(state in icon_states(toilet.icon), "The historical toilet must retain every lid/cistern sprite")

/datum/unit_test/atmta_gallows_rescue/Run()
	var/turf/ground = locate(20, 20, 1)
	var/obj/structure/gallows/gallows = allocate(/obj/structure/gallows, ground)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, ground)
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human, ground)
	var/old_pixel_y = victim.pixel_y
	TEST_ASSERT(gallows.buckle_mob(victim), "The noose must hold an occupant")
	TEST_ASSERT(gallows.start_hanging(helper), "The lever must start the gallows")
	TEST_ASSERT_NOT(gallows.start_hanging(helper), "Repeated lever activation must not stack processing")
	var/oxy_before = victim.getOxyLoss()
	gallows.process()
	TEST_ASSERT(victim.getOxyLoss() > oxy_before, "An active gallows must affect the occupant")
	helper.a_intent = INTENT_HELP
	gallows.attack_hand(helper)
	TEST_ASSERT_NULL(victim.buckled, "Help intent must release the occupant")
	TEST_ASSERT_NOT(gallows.hanging, "Rescue must stop hanging")
	TEST_ASSERT_EQUAL(victim.pixel_y, old_pixel_y, "Rescue must restore the sprite offset")
	TEST_ASSERT_EQUAL(gallows.process(), PROCESS_KILL, "An empty gallows must stop processing")
	TEST_ASSERT(gallows.buckle_mob(victim), "The gallows must be reusable after a rescue")
	gallows.start_hanging(helper)
	qdel(gallows)
	TEST_ASSERT_NULL(victim.buckled, "Deleting the gallows must release its occupant")
	TEST_ASSERT_EQUAL(victim.pixel_y, old_pixel_y, "Deletion must restore the sprite offset")

/datum/unit_test/atmta_gallows_crafting_and_cutting/Run()
	var/datum/crafting_recipe/atmta_gallows/recipe = new
	var/turf/ground = locate(20, 20, 1)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, ground)
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human, ground)
	var/obj/item/stack/sheet/wood/wood = allocate(/obj/item/stack/sheet/wood, ground, 10)
	var/obj/item/stack/cable_coil/cable = allocate(/obj/item/stack/cable_coil, ground, 5)
	var/datum/personal_crafting/crafting = new
	TEST_ASSERT(crafting.construct_item(helper, recipe), "Crafting must require its tool")
	var/obj/item/screwdriver/screwdriver = allocate(/obj/item/screwdriver, ground)
	helper.put_in_hands(screwdriver)
	TEST_ASSERT_NOT(crafting.construct_item(helper, recipe), "The normal crafting system must build the gallows")
	TEST_ASSERT(QDELETED(wood) && QDELETED(cable), "Crafting must consume its ingredients")
	var/obj/structure/gallows/gallows = locate() in ground
	TEST_ASSERT_NOTNULL(gallows, "Crafting must place the functional gallows on the floor")
	LAZYADD(allocated, gallows)
	qdel(recipe)
	qdel(crafting)
	var/obj/item/wirecutters/cutters = allocate(/obj/item/wirecutters, ground)
	helper.put_in_hands(cutters)
	TEST_ASSERT(gallows.buckle_mob(victim), "The rescue test needs an occupied gallows")
	gallows.start_hanging(helper)
	gallows.wirecutter_act(helper, cutters)
	TEST_ASSERT_NULL(victim.buckled, "Cutting the noose must rescue the occupant")
	TEST_ASSERT(QDELETED(gallows), "Cutting the noose must dismantle the gallows")
