/// The MOD removal must leave space equipment usable, including the integrated helmet.
/datum/unit_test/legacy_spacesuits/Run()
	var/turf/test_turf = locate(1, 1, 1)
	var/list/suit_types = list(
		/obj/item/clothing/suit/space/hardsuit/engine,
		/obj/item/clothing/suit/space/hardsuit/engine/atmos,
		/obj/item/clothing/suit/space/hardsuit/security,
		/obj/item/clothing/suit/space/hardsuit/medical,
		/obj/item/clothing/suit/space/hardsuit/rd,
		/obj/item/clothing/suit/space/hardsuit/mining,
		/obj/item/clothing/suit/space/hardsuit/syndi,
		/obj/item/clothing/suit/space/hardsuit/ert/commander,
		/obj/item/clothing/suit/space/hardsuit/ert/security,
		/obj/item/clothing/suit/space/hardsuit/ert/engineer,
		/obj/item/clothing/suit/space/hardsuit/ert/medical,
		/obj/item/clothing/suit/space/hardsuit/ert/janitor,
		/obj/item/clothing/suit/space/hardsuit/ert/paranormal,
		/obj/item/clothing/suit/space/hardsuit/ert/commander,
		/obj/item/clothing/suit/space/hardsuit/ert/security,
		/obj/item/clothing/suit/space/hardsuit/ert/engineer,
		/obj/item/clothing/suit/space/hardsuit/ert/medical,
		/obj/item/clothing/suit/space/hardsuit/ert/janitor,
		/obj/item/clothing/suit/space/hardsuit/ert/paranormal,
	)
	for(var/suit_type in suit_types)
		var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human, test_turf)
		var/obj/item/clothing/suit/space/hardsuit/suit = allocate(suit_type, test_turf)
		TEST_ASSERT_NOTNULL(suit.helmet, "[suit_type] must create its helmet")
		if(istype(suit, /obj/item/clothing/suit/space/hardsuit/syndi))
			var/obj/item/clothing/head/helmet/space/hardsuit/syndi/syndi_helmet = suit.helmet
			syndi_helmet.adjust_headgear(toggle = TRUE)
		TEST_ASSERT(suit.clothing_flags & STOPSPRESSUREDAMAGE, "[suit_type] must protect against pressure")
		wearer.equip_to_slot_or_del(suit, ITEM_SLOT_CLOTH_OUTER)
		TEST_ASSERT_EQUAL(wearer.wear_suit, suit, "[suit_type] must be wearable")
		TEST_ASSERT(suit.EngageHelmet(), "[suit_type] helmet must deploy")
		TEST_ASSERT_EQUAL(wearer.head, suit.helmet, "The helmet must occupy the head slot")
		TEST_ASSERT(wearer.head.clothing_flags & STOPSPRESSUREDAMAGE, "The deployed helmet must protect against pressure")
		suit.RemoveHelmet()
		TEST_ASSERT_NULL(wearer.head, "Retracting the helmet must free the head slot")
		TEST_ASSERT_EQUAL(suit.helmet.loc, suit, "The retracted helmet must stay with its suit")

/// New characters must start with the original right-click context menu.
/datum/unit_test/legacy_context_menu/Run()
	TEST_ASSERT_NOT(initial(/mob::shift_to_open_context_menu), "Context menus must not require Shift")

/datum/unit_test/operative_spacesuit/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human, locate(1, 1, 1))
	wearer.equipOutfit(/datum/outfit/admin/syndicate/operative/nuclear)
	TEST_ASSERT_NOTNULL(wearer.wear_suit, "The operative must receive a suit")
	TEST_ASSERT_NOTNULL(wearer.head, "The operative's helmet must start deployed")
	TEST_ASSERT(wearer.wear_suit.clothing_flags & STOPSPRESSUREDAMAGE, "The operative must start in EVA mode")
	TEST_ASSERT(wearer.head.clothing_flags & STOPSPRESSUREDAMAGE, "The operative's helmet must start in EVA mode")
