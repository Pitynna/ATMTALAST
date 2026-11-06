/// A fresh, healthy human must fall and lose the use of their hands on the first hit.
/datum/unit_test/legacy_baton_one_hit/Run()
	var/turf/test_turf = locate(1, 1, 1)
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human, test_turf)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, test_turf)
	var/obj/item/melee/baton/security/loaded/baton = allocate(/obj/item/melee/baton/security/loaded, test_turf)
	baton.attack_self(attacker)
	var/charge_before = baton.cell.charge
	baton.attack(target, attacker)
	TEST_ASSERT(target.IsStunned(), "The first charged baton hit must stun immediately")
	TEST_ASSERT(target.IsWeakened(), "The first charged baton hit must immediately incapacitate and floor the target")
	TEST_ASSERT(HAS_TRAIT(target, TRAIT_HANDS_BLOCKED), "A batoned target must not keep using weapons")
	TEST_ASSERT_EQUAL(target.getStaminaLoss(), 0, "Baton stun must not use stamina")
	TEST_ASSERT_EQUAL(baton.cell.charge, charge_before - baton.cell_hit_cost, "A successful hit must consume exactly one charge")
	TEST_ASSERT(target.AmountWeakened() >= 6 SECONDS, "The legacy baton stun must last about seven seconds")
	// Clearing the stun must not leave a delayed second fall behind.
	target.SetStunned(0)
	target.SetWeakened(0)
	target.SetKnockdown(0)
	sleep(4.5 SECONDS)
	TEST_ASSERT_NOT(target.IsKnockdown() || target.IsWeakened(), "No delayed stamina-era knockdown may survive the hit")

/datum/unit_test/legacy_baton_requires_charge/Run()
	var/turf/test_turf = locate(1, 1, 1)
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human, test_turf)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, test_turf)
	var/obj/item/melee/baton/security/loaded/baton = allocate(/obj/item/melee/baton/security/loaded, test_turf)
	baton.attack(target, attacker)
	TEST_ASSERT_NOT(target.IsStunned() || target.IsWeakened(), "A switched-off baton must not electrically stun")
	baton.active = TRUE
	baton.cell.charge = 0
	baton.attack(target, attacker)
	TEST_ASSERT_NOT(target.IsStunned() || target.IsWeakened(), "An empty cell must not electrically stun")

/datum/unit_test/legacy_taser_one_hit/Run()
	var/turf/test_turf = locate(1, 1, 1)
	var/list/projectile_types = list(
		/obj/projectile/energy/electrode,
		/obj/projectile/energy/electrode/dominator,
		/obj/projectile/energy/electrode/advanced,
		/obj/projectile/beam/disabler,
		/obj/projectile/beam/specter/disabler,
		/obj/projectile/beam/podsniper/disabler,
		/obj/projectile/beam/dominator/paralyzer,
	)
	for(var/projectile_type in projectile_types)
		var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, test_turf)
		var/obj/projectile/projectile = allocate(projectile_type, test_turf)
		projectile.on_hit(target)
		TEST_ASSERT(target.IsStunned() && target.IsWeakened(), "[projectile_type] must incapacitate on the first hit")
		TEST_ASSERT_EQUAL(target.getStaminaLoss(), 0, "Taser stun must not use stamina")
		TEST_ASSERT_EQUAL(target.health, target.maxHealth, "A taser must remain nonlethal")
		var/mob/living/carbon/human/protected_target = allocate(/mob/living/carbon/human, test_turf)
		var/obj/projectile/blocked_projectile = allocate(projectile_type, test_turf)
		blocked_projectile.on_hit(protected_target, 100)
		TEST_ASSERT_NOT(protected_target.IsStunned() || protected_target.IsWeakened(), "A fully blocked shot must not stun")

/datum/unit_test/legacy_no_player_stamina/Run()
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, locate(1, 1, 1))
	target.apply_damage(150, STAMINA)
	target.adjustStaminaLoss(150, forced = TRUE)
	target.setStaminaLoss(150)
	target.update_stamina()
	TEST_ASSERT_EQUAL(target.getStaminaLoss(), 0, "Combat, movement and forced stamina costs must not exhaust a player")
	TEST_ASSERT_NOT(target.IsStamcrited(), "Stamina must not incapacitate a player")
	TEST_ASSERT_NOT(target.incapacitated(), "Stamina must not block player actions")

/datum/unit_test/legacy_passive_defense/Run()
	var/turf/test_turf = locate(1, 1, 1)
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, test_turf)
	var/obj/item/shield/riot/shield = allocate(/obj/item/shield/riot, test_turf)
	owner.put_in_hands(shield)
	var/datum/component/parry/protection = shield.GetComponent(/datum/component/parry)
	TEST_ASSERT_NOTNULL(protection, "Riot shields must retain passive protection")
	TEST_ASSERT_EQUAL(protection.stamina_coefficient, 0.5, "Riot shields must retain their legacy 50% protection")
	TEST_ASSERT_NOT(HAS_TRAIT(owner, TRAIT_PUSHIMMUNE), "Holding a shield must not grant the old parry push immunity")
	// Make the roll deterministic; check that no input or parry timer is required.
	protection.stamina_coefficient = 0
	var/obj/item/weapon = allocate(/obj/item, test_turf)
	TEST_ASSERT_EQUAL(protection.attempt_parry(shield, owner, weapon, 50, ITEM_ATTACK), COMPONENT_BLOCK_SUCCESSFUL, "Passive protection must work without pressing a key and must never perfect-parry")
	TEST_ASSERT_EQUAL(owner.getStaminaLoss(), 0, "Blocking must not exhaust the defender")
	weapon.shields_penetration = 100
	TEST_ASSERT_NOT(protection.attempt_parry(shield, owner, weapon, 50, ITEM_ATTACK), "Shield penetration must bypass passive defense")
	var/obj/item/melee/energy/sword/sword = allocate(/obj/item/melee/energy/sword, test_turf)
	var/datum/component/parry/sword_protection = sword.GetComponent(/datum/component/parry)
	sword_protection.stamina_coefficient = 0
	weapon.shields_penetration = 0
	TEST_ASSERT_NOT(sword_protection.attempt_parry(sword, owner, weapon, 50, ITEM_ATTACK), "An inactive energy sword must not block")
	ADD_TRAIT(sword, TRAIT_ITEM_ACTIVE, GENERIC_TRAIT)
	TEST_ASSERT_EQUAL(sword_protection.attempt_parry(sword, owner, weapon, 50, ITEM_ATTACK), COMPONENT_BLOCK_SUCCESSFUL, "An active energy sword must block passively")
