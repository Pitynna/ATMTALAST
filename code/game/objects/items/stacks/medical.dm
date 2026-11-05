/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/medicine/packs.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	resistance_flags = FLAMMABLE
	max_integrity = 40
	var/heal_brute = 0
	var/heal_burn = 0
	var/self_delay = 2 SECONDS
	/// Some things give a special prompt, do we want to bypass some checks in parent?
	var/unique_handling = FALSE
	var/stop_bleeding = 0
	var/bleedsuppress = 0
	var/use_duration = 1 SECONDS
	var/use_flags = DA_IGNORE_USER_LOC_CHANGE | DA_IGNORE_LYING
	merge_type = null // do not merge if not defined in subtype

/obj/item/stack/medical/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!iscarbon(target) && !isanimal(target))
		target.balloon_alert(user, "неподходящая цель!")
		return .

	if(!user.IsAdvancedToolUser())
		target.balloon_alert(user, "вы слишком неуклюжи для этого!")
		return .

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/selected_zone = get_priority_targeting(target, user, def_zone)
		var/obj/item/organ/external/affecting = human_target.get_organ(selected_zone)

		if(isgolem(human_target))
			target.balloon_alert(user, "неподходящая цель!")
			return .

		if(human_target.covered_with_thick_material(selected_zone))
			target.balloon_alert(user, "часть тела чем-то перекрыта!")
			return .

		if(!affecting)
			target.balloon_alert(user, "часть тела отсутствует!")
			return .

		if(affecting.is_robotic())
			target.balloon_alert(user, "часть тела неорганическая!")
			return .

		if(human_target == user && !unique_handling)
			user.visible_message(
				span_notice("[user] применя[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [affecting.declent_ru(PREPOSITIONAL)]."),
				ignored_mobs = user,
			)
			target.balloon_alert(user, "применение на [GLOB.body_zone[affecting.limb_zone][PREPOSITIONAL]]...")

			if(!do_after(human_target, self_delay, human_target, use_flags, max_interact_count = 1))
				return .

			var/obj/item/organ/external/affecting_rechecked = human_target.get_organ(selected_zone)
			if(!affecting_rechecked)
				target.balloon_alert(user, "часть тела отсутствует!")
				return .

			if(human_target.covered_with_thick_material(selected_zone))
				target.balloon_alert(user, "часть тела чем-то перекрыта!")
				return .

			if(affecting_rechecked.is_robotic())
				target.balloon_alert(user, "часть тела неорганическая!")
				return .
		else
			user.visible_message(
				span_notice("[user] применя[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [affecting.declent_ru(PREPOSITIONAL)] [human_target.declent_ru(PREPOSITIONAL)]."),
				ignored_mobs = user,
			)
			target.balloon_alert(user, "применение на [GLOB.body_zone[affecting.limb_zone][PREPOSITIONAL]] цели...")

			if(use_duration && !do_after(user, use_duration, human_target))
				return .
		return .|ATTACK_CHAIN_SUCCESS

	if(isanimal(target))
		var/mob/living/simple_animal/critter = target
		if(!(critter.healable))
			target.balloon_alert(user, "неподходящая цель!")
			return .
		if(critter.health == critter.maxHealth)
			target.balloon_alert(user, "цель не нуждается в лечении!")
			return .
		if(heal_brute < 1)
			target.balloon_alert(user, "применение бессмысленно!")
			return .
		if(!use(1))
			return .
		critter.heal_organ_damage(heal_brute, heal_burn)
		user.visible_message(
			span_notice("[user] применя[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [critter.declent_ru(PREPOSITIONAL)]."),
			ignored_mobs = user,
		)
		target.balloon_alert(user, "применение на цели...")

		return .|ATTACK_CHAIN_SUCCESS

	if(!use(1))
		return .

	target.heal_organ_damage(heal_brute, heal_burn)

	user.visible_message(
		span_notice("[user] применя[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [target.declent_ru(PREPOSITIONAL)]."),
		ignored_mobs = user,
	)
	target.balloon_alert(user, "применено")

	return .|ATTACK_CHAIN_SUCCESS

/obj/item/stack/medical/proc/human_heal(mob/living/carbon/human/target, mob/user)
	var/selected_zone = get_priority_targeting(target, user)
	var/obj/item/organ/external/affecting = target.get_organ(selected_zone)

	target.balloon_alert(user, "применено")

	var/rembrute = max(0, heal_brute - affecting.brute_dam) // Maxed with 0 since heal_damage let you pass in a negative value
	var/remburn = max(0, heal_burn - affecting.burn_dam) // And deduct it from their health (aka deal damage)
	var/nrembrute = rembrute
	var/nremburn = remburn
	var/should_update_health = FALSE
	var/update_damage_icon = NONE
	var/affecting_brute_was = affecting.brute_dam
	var/affecting_burn_was = affecting.burn_dam
	update_damage_icon |= affecting.heal_damage(heal_brute, heal_burn, updating_health = FALSE)
	if(affecting.brute_dam != affecting_brute_was || affecting.burn_dam != affecting_burn_was)
		should_update_health = TRUE
	var/list/achildlist
	if(LAZYLEN(affecting.children))
		achildlist = affecting.children.Copy()
	var/parenthealed = FALSE
	while(rembrute + remburn > 0) // Don't bother if there's not enough leftover heal
		var/obj/item/organ/external/organ
		if(LAZYLEN(achildlist))
			organ = pick_n_take(achildlist) // Pick a random children and then remove it from the list
		else if(affecting.parent && !parenthealed) // If there's a parent and no healing attempt was made on it
			organ = affecting.parent
			parenthealed = TRUE
		else
			break // If the organ have no child left and no parent / parent healed, break
		if(organ.is_robotic() || organ.open) // Ignore robotic or open limb
			continue
		else if(!organ.brute_dam && !organ.burn_dam) // Ignore undamaged limb
			continue
		nrembrute = max(0, rembrute - organ.brute_dam) // Deduct the healed damage from the remain
		nremburn = max(0, remburn - organ.burn_dam)
		var/brute_was = organ.brute_dam
		var/burn_was = organ.burn_dam
		update_damage_icon |= organ.heal_damage(rembrute, remburn, updating_health = FALSE)
		if(organ.brute_dam != brute_was || organ.burn_dam != burn_was)
			should_update_health = TRUE
		rembrute = nrembrute
		remburn = nremburn
		user.visible_message(
			span_notice("[user] применя[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [affecting.declent_ru(PREPOSITIONAL)] [target.declent_ru(GENITIVE)]."),
			ignored_mobs = user,
		)
		target.balloon_alert(user, "применение на [GLOB.body_zone[affecting.limb_zone][PREPOSITIONAL]] цели")
	if(should_update_health)
		target.updatehealth("[name] heal")
	if(update_damage_icon)
		target.UpdateDamageIcon()

/obj/item/stack/medical/can_merge(obj/item/stack/check, inhand)
	if(check.type != merge_type)
		return FALSE
	. = ..()

/obj/item/stack/medical/attack_self(mob/user)
	attack(user, user, null, user.zone_selected)

// MARK: Targeting filter

/obj/item/stack/medical/proc/get_priority_targeting(mob/living/target, mob/living/user)
	return user.zone_selected

/obj/item/stack/medical/proc/get_priority_targeting_by_filter(mob/living/target, mob/living/user, filter_proc)
	. = user.zone_selected
	if(!ishuman(target))
		return

	if(user.client && !(user.client.prefs.toggles2 & PREFTOGGLE_2_AUTO_AIM_MEDICINE))
		return //disabled from preferences

	var/mob/living/carbon/human/human_target = target
	var/obj/item/organ/external/target_bodypart = target.get_organ(user.zone_selected)
	var/accept = call(src, filter_proc)(arglist(list(current = target_bodypart, max = null)))
	if(accept) //selected zone are accepted, no auto priority
		return

	for(var/obj/item/organ/external/affecting as anything in human_target.bodyparts)
		accept = call(src, filter_proc)(arglist(list(current = affecting, max = target_bodypart)))
		if(accept)
			target_bodypart = affecting

	if(!target_bodypart)
		return

	return target_bodypart.limb_zone

/obj/item/stack/medical/proc/filter_max_bleeding_bodypart(obj/item/organ/external/current, obj/item/organ/external/max)
	if(!current)
		return FALSE
	if(current.is_robotic() || current.bleeding_amount <= 0 || current.bleeding_amount <= current.bleedsuppress)
		return FALSE
	if(!max)
		return TRUE
	if(current.bleeding_amount > max.bleeding_amount)
		return TRUE
	return FALSE

/obj/item/stack/medical/proc/filter_max_brute_damage_bodypart(obj/item/organ/external/current, obj/item/organ/external/max)
	if(!current)
		return FALSE
	if(current.is_robotic() || current.brute_dam <= 0)
		return FALSE
	if(!max)
		return TRUE
	if(current.brute_dam > max.brute_dam)
		return TRUE
	return FALSE

/obj/item/stack/medical/proc/filter_max_burn_damage_bodypart(obj/item/organ/external/current, obj/item/organ/external/max)
	if(!current)
		return FALSE
	if(current.is_robotic() || current.burn_dam <= 0)
		return FALSE
	if(!max)
		return TRUE
	if(current.burn_dam > max.burn_dam)
		return TRUE
	return FALSE

/obj/item/stack/medical/proc/filter_max_damage_bodypart(obj/item/organ/external/current, obj/item/organ/external/max)
	if(!current)
		return FALSE
	if(current.is_robotic() || current.burn_dam <= 0 && current.brute_dam <= 0)
		return FALSE
	if(!max)
		return TRUE
	if(current.burn_dam + current.brute_dam > max.burn_dam + max.brute_dam)
		return TRUE
	return FALSE

// MARK: Bruise Packs

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "gauze_3"
	item_state = "gauze"
	origin_tech = "biotech=2"
	heal_brute = 10
	bleedsuppress = 2
	stop_bleeding = 180 SECONDS
	energy_type = /datum/robot_energy_storage/medical
	merge_type = /obj/item/stack/medical/bruise_pack
	custom_price = PAYCHECK_MIN * 0.4

/obj/item/stack/medical/bruise_pack/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/bruise_pack/attackby(obj/item/item, mob/user, params)
	if(item.sharp)
		add_fingerprint(user)
		var/atom/drop_loc = drop_location()
		if(!use(2))
			balloon_alert(user, "слишком мало для разрезания!")
			return ATTACK_CHAIN_PROCEED
		var/obj/item/stack/sheet/cloth/cloth = new(drop_loc)
		cloth.add_fingerprint(user)
		user.visible_message(
			span_notice("[user] разреза[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на куски ткани, используя [item.declent_ru(ACCUSATIVE)]."),
			blind_message = span_hear("Вы слышите звук рвущейся ткани."),
			ignored_mobs = user,
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

/obj/item/stack/medical/bruise_pack/update_icon_state()
	icon_state = "gauze_[amount >= 5 ? 3 : (amount >= 3 ? 2 : 1)]"

/obj/item/stack/medical/bruise_pack/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !ishuman(target))
		return .
	if(!get_amount())
		target.balloon_alert(user, "недостаточно!")
		return ATTACK_CHAIN_PROCEED
	var/selected_zone = get_priority_targeting(target, user, def_zone)
	var/obj/item/organ/external/affecting = target.get_organ(selected_zone)
	if(affecting.open != ORGAN_CLOSED)
		target.balloon_alert(user, "неэффективно для такой раны!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .
	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .
	playsound(user, 'sound/items/bandage.ogg', 30, TRUE)
	affecting.germ_level = 0
	if(stop_bleeding && affecting.bleeding_amount > affecting.bleedsuppress)	//so you can't stack bleed suppression
		affecting.suppress_bloodloss(user, target, bleedsuppress, stop_bleeding)
		var/obj/item/organ/external/addition_affecting = target.get_affecting_limb_bodypart(affecting)
		if(addition_affecting)
			addition_affecting.suppress_bloodloss(user, target, bleedsuppress, stop_bleeding)
	human_heal(target, user)
	target.UpdateDamageIcon()
	update_icon()

/obj/item/stack/medical/bruise_pack/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_bleeding_bodypart))

/obj/item/stack/medical/bruise_pack/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	desc = "A roll of cloth roughly cut from something that can stop bleeding, but does not heal wounds."
	stop_bleeding = 90 SECONDS
	icon_state = "gauze_imp_3"
	merge_type = /obj/item/stack/medical/bruise_pack/improvised

/obj/item/stack/medical/bruise_pack/improvised/update_icon_state()
	icon_state = "gauze_imp_[amount >= 5 ? 3 : (amount >= 3 ? 2 : 1)]"

/obj/item/stack/medical/bruise_pack/military
	name = "military emergency bandage"
	singular_name = "emergency bandage"
	desc = "A specialized kit for quickly stopping bleeding across the body. Used by security and law enforcement personnel."
	icon_state = "bandage"
	origin_tech = "biotech=2;combat=1"
	amount = 1
	max_amount = 1
	heal_brute = 0
	stop_bleeding = 300 SECONDS
	merge_type = /obj/item/stack/medical/bruise_pack/military
	custom_premium_price = PAYCHECK_CREW

/obj/item/stack/medical/bruise_pack/military/attackby(obj/item/I, mob/user, params)
	if(I.sharp)
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/stack/medical/bruise_pack/military/update_icon_state()
	return

/obj/item/stack/medical/bruise_pack/military/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !ishuman(target))
		return .
	var/list/all_zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
	for(var/select_def_zone in all_zones)
		var/obj/item/organ/external/affecting = target.get_organ(select_def_zone)
		if(affecting.open != ORGAN_CLOSED)
			continue
		if(affecting.bleeding_amount <= affecting.bleedsuppress)
			continue
		affecting.germ_level = 0
		if(affecting.bleeding_amount > affecting.bleedsuppress)
			affecting.suppress_bloodloss(user, target, bleedsuppress, stop_bleeding)
	use(1)
	if(!QDELETED(src))
		update_icon()
	return ATTACK_CHAIN_PROCEED

/obj/item/stack/medical/bruise_pack/advanced
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit_4"
	item_state = "traumakit"
	belt_icon = "advanced_trauma_kit"
	heal_brute = 20
	amount = 8
	max_amount = 8
	stop_bleeding = 0
	merge_type = /obj/item/stack/medical/bruise_pack/advanced
	use_flags = DA_IGNORE_LYING
	custom_price = PAYCHECK_MIN * 1.5

/obj/item/stack/medical/bruise_pack/advanced/update_icon_state()
	icon_state = "traumakit_[round_down((amount + 1) / 2, 1)]"

/obj/item/stack/medical/bruise_pack/advanced/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/bruise_pack/advanced/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_brute_damage_bodypart))

/obj/item/stack/medical/bruise_pack/extended
	name = "extended trauma kit"
	singular_name = "extended trauma kit"
	desc = "An extended trauma kit for severe injuries."
	icon_state = "extended_trauma_kit_5"
	item_state = "extended_trauma_kit"
	belt_icon = "advanced_trauma_kit"
	heal_brute = 20
	amount = 10
	max_amount = 10
	stop_bleeding = 0
	use_flags = DA_IGNORE_LYING
	merge_type = /obj/item/stack/medical/bruise_pack/extended
	custom_premium_price = PAYCHECK_LOWER

/obj/item/stack/medical/bruise_pack/extended/update_icon_state()
	icon_state = "extended_trauma_kit_[round_down((amount+1) / 2, 1)]"

/obj/item/stack/medical/bruise_pack/extended/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_brute_damage_bodypart))

// MARK: Ointment

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = FEMALE
	singular_name = "ointment"
	icon_state = "ointment_3"
	origin_tech = "biotech=2"
	heal_burn = 10
	energy_type = /datum/robot_energy_storage/medical
	use_flags = DA_IGNORE_LYING
	merge_type = /obj/item/stack/medical/ointment
	custom_price = PAYCHECK_MIN * 0.4

/obj/item/stack/medical/ointment/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_burn_damage_bodypart))

/obj/item/stack/medical/ointment/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/ointment/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !ishuman(target))
		return .

	if(!get_amount())
		target.balloon_alert(user, "недостаточно!")
		return ATTACK_CHAIN_PROCEED

	var/selected_zone = get_priority_targeting(target, user, def_zone)
	var/obj/item/organ/external/affecting = target.get_organ(selected_zone)
	if(affecting.open != ORGAN_CLOSED)
		target.balloon_alert(user, "неэффективно для такой раны!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	playsound(user, 'sound/items/ointment_spreading.ogg', 30, TRUE)

	affecting.germ_level = 0
	human_heal(target, user)
	target.UpdateDamageIcon()
	update_icon()

/obj/item/stack/medical/ointment/update_icon_state()
	icon_state = "ointment_[amount >= 5 ? 3 : (amount >= 3 ? 2 : 1)]"

/obj/item/stack/medical/ointment/advanced
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	gender = MALE
	icon_state = "burnkit_4"
	item_state = "burnkit"
	belt_icon = "advanced_burn_kit"
	heal_burn = 20
	amount = 8
	max_amount = 8
	merge_type = /obj/item/stack/medical/ointment/advanced
	custom_price = PAYCHECK_MIN * 1.5

/obj/item/stack/medical/ointment/advanced/update_icon_state()
	icon_state = "burnkit_[round_down((amount + 1) / 2, 1)]"

/obj/item/stack/medical/ointment/advanced/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/ointment/extended
	name = "extended burn kit"
	singular_name = "extended burn kit"
	desc = "An extended treatment kit for severe burns."
	gender = MALE
	icon_state = "extended_burn_kit_5"
	item_state = "extended_burn_kit"
	belt_icon = "advanced_burn_kit"
	heal_burn = 20
	amount = 10
	max_amount = 10
	merge_type = /obj/item/stack/medical/ointment/extended
	custom_premium_price = PAYCHECK_LOWER

/obj/item/stack/medical/ointment/extended/update_icon_state()
	icon_state = "extended_burn_kit_[round_down((amount+1) / 2, 1)]"

// MARK: Synthflesh kit

/obj/item/stack/medical/bruise_pack/synthflesh_kit
	name = "synthflesh trauma kit"
	singular_name = "synthflesh trauma kit"
	desc = "A first-aid kit for treating physical injuries and burns. Contains gels, antiseptics, healing membranes and synthflesh-based medical patches."
	icon_state = "synthkit_4"
	item_state = "traumakit"
	belt_icon = "advanced_trauma_kit"
	heal_brute = 12
	heal_burn = 12
	amount = 8
	max_amount = 8
	stop_bleeding = 0
	use_flags = DA_IGNORE_LYING
	merge_type = /obj/item/stack/medical/bruise_pack/synthflesh_kit
	custom_price = PAYCHECK_LOWER

/obj/item/stack/medical/bruise_pack/synthflesh_kit/update_icon_state()
	icon_state = "synthkit_[round_down((amount+1) / 2, 1)]"

/obj/item/stack/medical/bruise_pack/synthflesh_kit/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_damage_bodypart))

// MARK: Medical Herbs

/obj/item/stack/medical/bruise_pack/comfrey
	name = "Comfrey leaf"
	singular_name = "Comfrey leaf"
	desc = "A medical poultice for treating brute injuries, made from crushed comfrey leaves. The effectiveness of the poultice depends on the potency of the comfrey it was made from."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "tea_aspera_leaves"
	color = "#378C61"
	stop_bleeding = 0
	heal_brute = 12
	drop_sound = 'sound/misc/moist_impact.ogg'
	mob_throw_hit_sound = 'sound/misc/moist_impact.ogg'
	hitsound = 'sound/misc/moist_impact.ogg'
	use_flags = DA_IGNORE_LYING
	merge_type = /obj/item/stack/medical/bruise_pack/comfrey
	var/max_heal = 30

/obj/item/stack/medical/bruise_pack/comfrey/update_icon_state()
	return

/obj/item/stack/medical/bruise_pack/comfrey/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_brute_damage_bodypart))

/obj/item/stack/medical/ointment/aloe
	name = "Aloe Vera leaf"
	singular_name = "Aloe Vera leaf"
	desc = "A medical poultice for treating burns, made from crushed aloe vera leaves. The effectiveness of the poultice depends on the potency of the aloe it was made from."
	gender = MALE
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "aloe"
	color = "#4CC5C7"
	heal_burn = 12
	merge_type = /obj/item/stack/medical/ointment/aloe
	var/max_heal = 30

/obj/item/stack/medical/ointment/aloe/update_icon_state()
	return

// MARK: Splints

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	desc = "A standard medical splint for immobilizing broken limbs until proper medical care is available."
	gender = FEMALE
	icon_state = "splint"
	item_state = "splint"
	unique_handling = TRUE
	self_delay = 5 SECONDS
	use_duration = 3 SECONDS
	energy_type = /datum/robot_energy_storage/splint
	var/static/list/available_splint_zones = list(
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_R_FOOT,
	)
	use_flags = DA_IGNORE_LYING
	merge_type = /obj/item/stack/medical/splint
	custom_price = PAYCHECK_MIN

/obj/item/stack/medical/splint/attack(mob/living/carbon/human/target, mob/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!ishuman(target))
		return .

	var/selected_zone = get_priority_targeting(target, user, def_zone)
	var/obj/item/organ/external/affecting = target.get_organ(selected_zone)

	if(!affecting.has_fracture())
		target.balloon_alert(user, "нечего фиксировать!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	. = ..()

	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .

	if(!get_amount())
		target.balloon_alert(user, "недостаточно!")
		return ATTACK_CHAIN_PROCEED

	if(!(affecting.limb_zone in available_splint_zones))
		target.balloon_alert(user, "не является конечностью!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	if(affecting.is_splinted())
		target.balloon_alert(user, "здесь уже есть шина!")
		if(tgui_alert(user, "Вы хотите снять шину с [affecting.declent_ru(GENITIVE)] [target.declent_ru(GENITIVE)]?", "Снятие шины", list("Да", "Нет")) != "Да" || !target.Adjacent(user))
			return ATTACK_CHAIN_BLOCKED_ALL
		affecting.remove_splint()
		target.balloon_alert(user, "шина снята")
		return .

	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	user.visible_message(
		span_notice("[user] накладыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [affecting.declent_ru(ACCUSATIVE)][target == user ? "" : " [target.declent_ru(GENITIVE)]"]."),
		ignored_mobs = user,
	)
	target.balloon_alert(user, "шина наложена")

	affecting.apply_splint()

/obj/item/stack/medical/splint/tribal
	name = "tribal splints"
	desc = "A primitive medical splint made from two bones bound with watcher sinew. Used to immobilize broken limbs until proper care becomes available, if such care is even possible in the harsh conditions of Lazis."
	icon_state = "tribal_splint"
	self_delay = 10 SECONDS
	use_duration = 5 SECONDS
	merge_type = /obj/item/stack/medical/splint/tribal

/obj/item/stack/medical/splint/makeshift
	name = "makeshift splints"
	desc = "Makeshift splint for fixing bones. Better than nothing and more based than others."
	icon_state = "makeshift_splint"
	self_delay = 10 SECONDS
	use_duration = 5 SECONDS
	merge_type = /obj/item/stack/medical/splint/makeshift


/obj/item/stack/medical/suture
	name = "suture kit"
	singular_name = "suture thread"
	desc = "A kit containing a surgical needle and specialized thread for stitching wounds in the field. Use without anesthetic is not recommended."
	icon_state = "suture_3"
	item_state = "suture"
	origin_tech = "biotech=3"
	var/bleeding_heal = 5
	var/damage = 5
	use_flags = DA_IGNORE_LYING
	energy_type = /datum/robot_energy_storage/medical
	merge_type = /obj/item/stack/medical/suture
	custom_price = PAYCHECK_MIN

/obj/item/stack/medical/suture/update_icon_state()
	icon_state = "suture_[round_down((amount+1) / 2, 1)]"

/obj/item/stack/medical/suture/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!ishuman(target))
		return .

	var/selected_zone = get_priority_targeting(target, user, def_zone)
	var/obj/item/organ/external/affecting = target.get_organ(selected_zone)

	if(!affecting)
		target.balloon_alert(user, "нет конечности!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	if(affecting.bleeding_amount <= 0)
		target.balloon_alert(user, "нечего зашивать!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	. = ..()

	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .

	if(!get_amount())
		target.balloon_alert(user, "недостаточно!")
		return ATTACK_CHAIN_PROCEED

	if(affecting.open != ORGAN_CLOSED)
		target.balloon_alert(user, "неэффективно для такой раны!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	affecting.germ_level = 0
	if(affecting.bleeding_amount > 0)	//so you can't stack bleed suppression
		affecting.heal_bleeding(user, target, bleeding_heal, damage)
		var/obj/item/organ/external/addition_affecting = target.get_affecting_limb_bodypart(affecting)
		if(addition_affecting)
			addition_affecting.heal_bleeding(user, target, bleeding_heal, 0)
		target.updatehealth("[name] heal")
	target.balloon_alert(user, "рана зашита")
	target.UpdateDamageIcon()
	update_icon()

/obj/item/stack/medical/suture/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_bleeding_bodypart))

/obj/item/stack/medical/suture/advanced
	name = "advanced suture kit"
	singular_name = "advanced suture thread"
	desc = "A kit containing a surgical needle and specialized thread for stitching wounds. Effectively treats open bleeding wounds and physical injuries."
	icon_state = "advanced_suture"
	item_state = "advanced_suture"
	origin_tech = "biotech=5"
	amount = 10
	max_amount = 10
	heal_brute = 10
	bleeding_heal = 10
	damage = 0
	merge_type = /obj/item/stack/medical/suture/advanced
	custom_premium_price = PAYCHECK_LOWER

/obj/item/stack/medical/suture/advanced/update_icon_state()
	icon_state = "advanced_suture[amount < max_amount ? "_open" : ""]"

// MARK: Tourniquet
/obj/item/tourniquet
	name = "tourniquet"
	desc = "A medical tourniquet for emergency control of arterial and venous bleeding in limbs. Not intended for other body parts. Prolonged use without follow-up medical care causes tissue necrosis."
	icon = 'icons/obj/medicine/packs.dmi'
	icon_state = "tourniquet"
	item_state = "tourniquet"
	origin_tech = "biotech=3"
	w_class = WEIGHT_CLASS_TINY
	custom_price = PAYCHECK_MIN * 0.6
	/// Duration to apply self
	var/self_duration = 3 SECONDS
	/// Duration to apply other mobs
	var/other_duration = 1 SECONDS
	/// Removing duration
	var/remove_duration = 1 SECONDS
	/// Bodypart where applied tourniquet
	var/obj/item/organ/external/applied_bodypart = null
	/// Addition bodypart on which tourniquet is applied  (hand for arm, foot for leg)
	var/obj/item/organ/external/applied_addition_bodypart = null
	/// Duration of limb necrotize if apply tourniquet
	var/tourniquet_duration = 3 MINUTES
	/// Limb necrotize timer identifier if apply tourniquet
	var/tourniquet_timer_id = null

/obj/item/tourniquet/Destroy()
	. = ..()
	applied_bodypart = null
	applied_addition_bodypart = null
	stop_apply_timers()

/obj/item/tourniquet/proc/stop_apply_timers()
	if(!tourniquet_timer_id)
		return

	deltimer(tourniquet_timer_id)
	tourniquet_timer_id = null

/obj/item/tourniquet/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!ishuman(target))
		return .

	if(!acceptable_zone(user.zone_selected))
		target.balloon_alert(user, "не является конечностью!")
		return .

	var/mob/living/carbon/human/human_target = target
	var/obj/item/organ/external/affecting = human_target.get_organ(user.zone_selected)
	var/obj/item/organ/external/addition_affecting = human_target.get_affecting_limb_bodypart(affecting)
	if(affecting.tourniquet)
		target.balloon_alert(user, "уже наложено!")
		return .

	if(human_target == user)
		if(!apply_to_self(human_target, affecting, addition_affecting))
			return .
	else if(!apply_to_other(user, human_target, affecting, addition_affecting))
		return .

	affecting.tourniquet = src
	applied_bodypart = affecting
	if(addition_affecting)
		addition_affecting.tourniquet = src
		applied_addition_bodypart = addition_affecting

	user.drop_item_ground(src)
	src.forceMove(affecting)
	target.balloon_alert_to_viewers("турникет наложен", "вы наложили турникет")
	target.UpdateDamageIcon()
	update_icon()
	tourniquet_timer_id = addtimer(CALLBACK(src, PROC_REF(tourniquet_duration_end), target), tourniquet_duration, TIMER_STOPPABLE)

/obj/item/tourniquet/attack_self(mob/user)
	attack(user, user, null, user.zone_selected)

/obj/item/tourniquet/proc/apply_to_self(mob/living/carbon/human/user, obj/item/organ/external/affecting, obj/item/organ/external/addition_affecting)
	var/selected_zone = user.zone_selected

	user.visible_message(
		span_notice("[user] накладыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [affecting.declent_ru(ACCUSATIVE)]."),
		blind_message = span_hear("Вы слышите звук стягивания чего-то."),
		ignored_mobs = user,
	)
	balloon_alert(user, "наложение на [GLOB.body_zone[affecting.limb_zone][ACCUSATIVE]]...")

	if(!do_after(user, self_duration, user, DA_IGNORE_USER_LOC_CHANGE | DA_IGNORE_LYING) || applied_bodypart)
		return

	var/obj/item/organ/external/affecting_rechecked = user.get_organ(selected_zone)
	if(!affecting_rechecked)
		balloon_alert(user, "конечность отсутствует!")
		return

	if(affecting_rechecked.tourniquet)
		balloon_alert(user, "турникет уже наложен!")
		return

	if(affecting_rechecked.is_robotic())
		balloon_alert(user, "неорганическая конечность!")
		return

	return TRUE

/obj/item/tourniquet/proc/apply_to_other(mob/living/user, mob/living/carbon/human/human_target, obj/item/organ/external/affecting, obj/item/organ/external/addition_affecting)
	var/selected_zone = user.zone_selected

	user.visible_message(
		span_notice("[user] накладыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [affecting.declent_ru(ACCUSATIVE)] [human_target.declent_ru(GENITIVE)]."),
		blind_message = span_hear("Вы слышите звук стягивания чего-то."),
		ignored_mobs = user,
	)
	human_target.balloon_alert(user, "наложение на [GLOB.body_zone[affecting.limb_zone][ACCUSATIVE]]...")

	if(!do_after(user, other_duration, human_target) || applied_bodypart)
		return

	var/obj/item/organ/external/affecting_rechecked = human_target.get_organ(selected_zone)
	if(!affecting_rechecked)
		human_target.balloon_alert(user, "конечность отсутствует!")
		return

	if(affecting_rechecked.tourniquet)
		human_target.balloon_alert(user, "турникет уже наложен!")
		return

	if(affecting_rechecked.is_robotic())
		human_target.balloon_alert(user, "неорганическая конечность!")
		return

	return TRUE

/obj/item/tourniquet/proc/tourniquet_duration_end(mob/living/user)
	if(!applied_bodypart)
		return

	user.balloon_alert_to_viewers("турникет упал!")
	user.visible_message(
		span_notice("С [applied_bodypart.declent_ru(GENITIVE)] [user] упал турникет."),
		blind_message = span_hear("Вы слышите звук падения чего-то."),
		ignored_mobs = user,
	)

	applied_bodypart.tourniquet = null
	applied_bodypart = null

	if(applied_addition_bodypart)
		applied_addition_bodypart.tourniquet = null
		applied_addition_bodypart = null

	stop_apply_timers()
	qdel(src)

/obj/item/tourniquet/proc/remove_from_bodypart(mob/living/user)
	if(!applied_bodypart)
		return FALSE

	applied_bodypart.owner.balloon_alert(user, "снятие турникета...")
	if(!do_after(user, remove_duration, applied_bodypart.owner) || !applied_bodypart)
		return FALSE

	var/drop_loc = applied_bodypart.drop_location()
	src.forceMove(drop_loc)
	applied_bodypart.owner.balloon_alert(user, "турникет снят")
	applied_bodypart.tourniquet = null
	applied_bodypart = null

	if(applied_addition_bodypart)
		applied_addition_bodypart.tourniquet = null
		applied_addition_bodypart = null

	stop_apply_timers()
	user.put_in_any_hand_if_possible(src)
	return TRUE

/obj/item/tourniquet/proc/acceptable_zone(zone_selected)
	// allow arms
	if(zone_selected == BODY_ZONE_L_ARM || zone_selected == BODY_ZONE_R_ARM)
		return TRUE
	// allow legs
	if(zone_selected == BODY_ZONE_L_LEG || zone_selected == BODY_ZONE_R_LEG)
		return TRUE
	// not accept for chest, groin, head
	return FALSE

/mob/living/carbon/human/proc/exists_tourniquet()
	for(var/obj/item/organ/external/affecting as anything in bodyparts)
		if(affecting.tourniquet)
			return TRUE

	return FALSE

/mob/living/carbon/human/proc/cut_all_tourniquets(mob/living/user)
	for(var/obj/item/organ/external/affecting as anything in bodyparts)
		if(!affecting.tourniquet)
			continue
		var/obj/item/tourniquet/tourniquet = affecting.tourniquet

		affecting.tourniquet = null
		tourniquet.applied_bodypart = null

		if(tourniquet.applied_addition_bodypart)
			tourniquet.applied_addition_bodypart.tourniquet = null
			tourniquet.applied_addition_bodypart = null

		tourniquet.stop_apply_timers()
		qdel(tourniquet)

/obj/item/tourniquet/makeshift
	name = "makeshift tourniquet"
	desc = "An improvised tourniquet for temporarily stopping bleeding in a limb. Extremely uncomfortable, but it gets the job done. Not intended for prolonged use."
	icon_state = "makeshift_tourniquet"
	item_state = "makeshift_tourniquet"
	self_duration = 5 SECONDS
	other_duration = 3 SECONDS

/obj/item/tourniquet/makeshift/remove_from_bodypart(mob/living/user)
	if(..())
		QDEL_NULL(src)

/obj/item/tourniquet/advanced
	name = "advanced tourniquet"
	desc = "A next-generation medical tourniquet for emergency control of arterial and venous bleeding in limbs. A pressure-control mechanism improves comfort and effectiveness over conventional models. Prolonged use without follow-up medical care causes tissue necrosis."
	icon_state = "advanced_tourniquet"
	item_state = "advanced_tourniquet"
	tourniquet_duration = 5 MINUTES
	self_duration = 1 SECONDS
	custom_price = PAYCHECK_MIN * 1.2
