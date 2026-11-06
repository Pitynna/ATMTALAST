//Recoil for mob hit
GLOBAL_DATUM_INIT(mob_hit_recoil, /datum/gun_recoil, GUN_RECOIL_LOW)

/datum/gun_recoil
	/// Recoil strength in tile size (32 pixels)
	var/strength
	/// Camera move to recoil point duration
	var/in_duration
	/// Camera move back duration
	var/back_duration
	/// Recoil angle randomization value
	var/angle = 45
	/// recoil throw dwarf users back
	var/knockback_dwrfs = FALSE

/datum/gun_recoil/minimal
	strength = 0.1
	in_duration = 0.5
	back_duration = 0.8

/datum/gun_recoil/low
	strength = 0.25
	in_duration = 0.6
	back_duration = 1

/datum/gun_recoil/medium
	strength = 0.45
	in_duration = 0.8
	back_duration = 1.2

/datum/gun_recoil/high
	strength = 1
	in_duration = 0.8
	back_duration = 1.5
	knockback_dwrfs = TRUE

/datum/gun_recoil/mega
	strength = 2
	in_duration = 0.9
	back_duration = 1.8
	knockback_dwrfs = TRUE

/// animate recoil for gun
/obj/item/gun/proc/do_recoil(mob/living/user, atom/target)
	return

/obj/item/gun/proc/do_knockback_dworfs(mob/living/user, atom/target)
	var/knockback_dir = get_dir(target, user)
	if(!knockback_dir)
		knockback_dir = REVERSE_DIR(user.dir)
	var/turf/knockback_turf = get_ranged_target_turf(user, knockback_dir, 2)
	if(!knockback_turf)
		return

	user.visible_message(
		span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)] не удержива[PLUR_ET_UT(user)]ся на ногах от отдачи!"),
		span_userdanger("Мощная отдача отбрасывает вас назад!"),
	)

	if(user.is_in_hands(src))
		user.drop_item_ground(src)
	else if(get_turf(src) != get_turf(user))
		forceMove(get_turf(user)) // force move to ground

	user.throw_at(knockback_turf, 2, 2, spin = TRUE)
	user.Knockdown(1 SECONDS)

/proc/recoil_camera(mob/user, strength, duration, backtime_duration, angle)
	return

