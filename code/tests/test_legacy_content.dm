/// The removed professions must be absent from both hiring and ID-console lists.
/datum/unit_test/legacy_profession_catalogs/Run()
	for(var/datum/job/job in SSjobs.occupations)
		TEST_ASSERT_NOT(is_legacy_blocked_type(job.type), "[job.title] must not appear in hiring")
	var/list/jobs = get_job_datums()
	for(var/datum/job/job in jobs)
		TEST_ASSERT_NOT(is_legacy_blocked_type(job.type), "[job.title] must not appear in ID-console job lists")
	QDEL_LIST(jobs)
	TEST_ASSERT_NOT(SPECIES_MOTH in GLOB.all_species, "Nians must not be selectable")
	TEST_ASSERT_NOT(SPECIES_DRACONOID in GLOB.all_species, "Draconids must not be selectable")

/// Ordinary research and cargo must never advertise a retired item or its board.
/datum/unit_test/legacy_equipment_catalogs/Run()
	var/datum/research/research = new
	for(var/design_path in subtypesof(/datum/design))
		var/datum/design/design = new design_path
		if(!design.id)
			qdel(design)
			continue
		research.AddDesign2Known(design)
		if(is_legacy_blocked_type(design.build_path))
			TEST_ASSERT_NOT(design.id in research.known_designs, "Retired design [design.id] must not be researchable")
			qdel(design)
		else if(research.known_designs[design.id] != design)
			qdel(design)
	qdel(research)
	for(var/key in SSshuttle.supply_packs)
		var/datum/supply_packs/pack = SSshuttle.supply_packs[key]
		for(var/item_type in pack.contains)
			TEST_ASSERT_NOT(is_legacy_blocked_type(item_type), "Cargo pack [pack.name] must not sell retired content")
	for(var/datum/crafting_recipe/recipe in GLOB.crafting_recipes)
		TEST_ASSERT_NOT(is_legacy_blocked_type(recipe.result), "Crafting must not offer [recipe.name]")

/// Legacy guns remain usable without attachments or accumulating shot spread.
/datum/unit_test/legacy_weapon_handling/Run()
	var/turf/test_turf = locate(1, 1, 1)
	for(var/weapon in list(/obj/item/gun/energy/laser, /obj/item/gun/energy/gun/advtaser, /obj/item/gun/projectile/shotgun, /obj/item/gun/projectile/automatic/arg, /obj/item/gun/projectile/automatic/smg/c20r))
		var/obj/item/gun/gun = allocate(weapon, test_turf)
		TEST_ASSERT_NOT(QDELETED(gun), "[weapon] must remain usable")
		TEST_ASSERT_NOT(gun.attachable_allowed, "[weapon] must not accept attachments")
		TEST_ASSERT_NULL(gun.starting_attachment_types, "[weapon] must not spawn attachments")
		TEST_ASSERT_EQUAL(gun.accuracy.randomize_spread(null, 50, 100), 0, "[weapon] must not accumulate burst spread")
		if(istype(gun, /obj/item/gun/projectile))
			var/obj/item/gun/projectile/ballistic = gun
			TEST_ASSERT_NOT(QDELETED(ballistic.magazine), "[weapon] must retain its magazine")
			TEST_ASSERT(ballistic.magazine.ammo_count() > 0, "[weapon] must remain loaded")
