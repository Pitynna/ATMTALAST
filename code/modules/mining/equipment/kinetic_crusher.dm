/*********************Mining Hammer****************/
/obj/item/twohanded/kinetic_crusher
	icon = 'icons/obj/mining.dmi'
	icon_state = "crusher"
	item_state = "crusher0"
	name = "proto-kinetic crusher"
	desc = "An early design of the proto-kinetic accelerator, it is little more than a combination of various mining tools cobbled together, forming a high-tech club. \
	While it is an effective mining tool, it did little to aid any but the most skilled and/or suicidal miners against local fauna."
	gender = MALE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_wielded = 20
	throwforce = 5
	throw_speed = 4
	armour_penetration = 10
	materials = list(MAT_METAL = 1150, MAT_GLASS = 2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("сокрушил", "рубанул", "ударил")
	sharp = TRUE
	actions_types = list(/datum/action/item_action/toggle_light)
	var/list/trophies = list()
	var/charged = TRUE
	var/charge_time = 15
	var/detonation_damage = 50
	var/backstab_bonus = 30
	light_system = OVERLAY_LIGHT
	light_range = 5
	light_on = FALSE
	var/adaptive_damage_bonus = 0
	var/charge_timer
	var/upgraded = FALSE //whether is our crusher is magmite-upgraded
	var/obj/projectile/destabilizer/destab = /obj/projectile/destabilizer

/obj/item/kinetic_crusher/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!held_item)
		context[SCREENTIP_CONTEXT_RMB] = "Detach trophy"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item) && held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Detach all trophies"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/kinetic_crusher/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/twohanded/kinetic_crusher/Destroy()
	QDEL_LIST(trophies)
	return ..()

/obj/item/twohanded/kinetic_crusher/examine(mob/living/user)
	. = ..()
	. += span_notice("Требуется две руки. Выстрел разрушает породу и накладывает на фауну дестабилизирующее поле.")
	. += span_notice("Удары по отмеченной фауне наносят <b>[force + detonation_damage]</b> единиц[DECL_U_Y_0(force + detonation_damage)] урона.")
	. += span_notice("Наносит <b>[force + detonation_damage + backstab_bonus]</b> единиц[DECL_U_Y_0(force + detonation_damage + backstab_bonus)] урона при ударе в спину.\n")
	if(length(trophies) != 0)
		. += span_notice("<b>К Крушителю прикреплены следующие трофеи</b>:")
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			. += span_notice("[icon2html(t, user)] <b>[DECLENT_RU_CAP(T, NOMINATIVE)]</b>: [T.effect_desc()].")

/obj/item/twohanded/kinetic_crusher/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/crusher_trophy))
		var/obj/item/crusher_trophy/trophy = I
		add_fingerprint(user)
		if(trophy.add_to(src, user))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/twohanded/kinetic_crusher/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(LAZYLEN(trophies))
		balloon_alert(user, "трофеи сняты")
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.remove_from(src, user)
	else
		balloon_alert(user, "нет трофеев!")

/obj/item/twohanded/kinetic_crusher/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		var/warn_message = "[DECLENT_RU_CAP(src, NOMINATIVE)] слишком тяжёлый, чтобы использовать его одной рукой."
		if(user.drop_item_ground(src))
			warn_message += " Вы роняете [declent_ru(ACCUSATIVE)] на землю."
		to_chat(user, span_warning(warn_message))
		return ATTACK_CHAIN_BLOCKED_ALL
	var/datum/status_effect/crusher_damage/damage_track = target.has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
	if(!damage_track)
		damage_track = target.apply_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
	var/target_health = target.health
	var/temp_force_bonus = 0
	var/datum/status_effect/adaptive_learning/learning = target.has_status_effect(STATUS_EFFECT_ADAPTIVELEARNING)
	if(!learning && adaptive_damage_bonus)
		learning = target.apply_status_effect(STATUS_EFFECT_ADAPTIVELEARNING)
	if(learning)
		temp_force_bonus = learning.bonus_damage
		learning.bonus_damage = min((learning.bonus_damage + adaptive_damage_bonus), 20)
	force += temp_force_bonus
	. = ..()
	force -= temp_force_bonus
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || QDELETED(target))
		return .
	for(var/obj/item/crusher_trophy/trophy as anything in trophies)
		if(!QDELETED(target))
			trophy.on_melee_hit(target, user)
	if(!QDELETED(damage_track) && !QDELETED(target))
		damage_track.total_damage += target_health - target.health //we did some damage, but let's not assume how much we did

// adapted from kinetic accelerator attack_hand_secodary
/obj/item/twohanded/kinetic_crusher/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!LAZYLEN(trophies))
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	var/list/display_names = list()
	var/list/items = list()
	for(var/trophies_length in 1 to length(trophies))
		var/obj/item/crusher_trophy/trophy = trophies[trophies_length]
		display_names[trophy.name] = trophy.UID()
		var/image/item_image = image(icon = trophy.icon, icon_state = trophy.icon_state)
		if(length(trophy.overlays))
			item_image.copy_overlays(trophy)
		items["[trophy.name]"] = item_image

	var/pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE)
	if(!pick)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/trophy_reference = display_names[pick]
	var/obj/item/crusher_trophy/trophy_to_remove = locate(trophy_reference) in trophies
	if(!istype(trophy_to_remove))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	trophy_to_remove.remove_from(src, user)
	if(!user.put_in_hands(trophy_to_remove))
		trophy_to_remove.forceMove(drop_location())

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/twohanded/kinetic_crusher/proc/check_menu(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/item/twohanded/kinetic_crusher/afterattack(atom/target, mob/living/user, proximity_flag, list/modifiers, status)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return
	if(user.has_status_effect(STATUS_EFFECT_DASH) && user.a_intent == INTENT_HELP)
		if(user.throw_at(target, range = 3, speed = 3, spin = FALSE, diagonals_first = TRUE))
			playsound(src, 'sound/effects/stealthoff.ogg', 50, TRUE, 1)
			user.visible_message(span_warning("[user] соверша[PLUR_ET_YUT(user)] рывок!"))
		else
			to_chat(user, span_warning("Что-то не даёт вам совершить рывок!"))
		user.remove_status_effect(STATUS_EFFECT_DASH)
		return
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/CM = L.has_status_effect(STATUS_EFFECT_CRUSHERMARK)
		if(!CM || CM.hammer_synced != src || !L.remove_status_effect(STATUS_EFFECT_CRUSHERMARK))
			return
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		if(!C)
			C = L.apply_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		var/target_health = L.health
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_mark_detonation(target, user)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health //we did some damage, but let's not assume how much we did
			new /obj/effect/temp_visual/kinetic_blast(get_turf(L))
			var/backstab_dir = get_dir(user, L)
			var/def_check = L.getarmor(attack_flag = BOMB)
			if((user.dir & backstab_dir) && (L.dir & backstab_dir))
				if(!QDELETED(C))
					C.total_damage += detonation_damage + backstab_bonus //cheat a little and add the total before killing it, so certain mobs don't have much lower chances of giving an item
				L.apply_damage(detonation_damage + backstab_bonus, BRUTE, blocked = def_check)
				playsound(user, 'sound/weapons/crusher_backstab.ogg', 130) //Seriously who spelled it wrong
			else
				if(!QDELETED(C))
					C.total_damage += detonation_damage
				L.apply_damage(detonation_damage, BRUTE, blocked = def_check)

/obj/item/twohanded/kinetic_crusher/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		balloon_alert(user, "wield it first!")
		return ITEM_INTERACT_BLOCKING
	if(interacting_with == user)
		balloon_alert(user, "can't aim at yourself!")
		return ITEM_INTERACT_BLOCKING
	fire_kinetic_blast(interacting_with, user, modifiers)
	user.changeNext_move(CLICK_CD_MELEE)
	return ITEM_INTERACT_SUCCESS

/obj/item/twohanded/kinetic_crusher/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom_secondary(interacting_with, user, modifiers)

/obj/item/twohanded/kinetic_crusher/proc/fire_kinetic_blast(atom/target, mob/living/user, list/modifiers)
	if(!charged)//Mark a target, or mine a tile.
		return

	var/turf/proj_turf = user.loc

	if(!isturf(proj_turf))
		return

	var/obj/projectile/destabilizer/destabilizer = new destab(proj_turf)
	SEND_SIGNAL(src, COMSIG_CRUSHER_FIRED_BLAST, target, user, destabilizer)
	for(var/obj/item/crusher_trophy/attached_trophy as anything in trophies)
		attached_trophy.on_projectile_fire(destabilizer, user)
	destabilizer.preparePixelProjectile(target, user, modifiers)
	destabilizer.firer = user
	destabilizer.firer_source_atom = src
	destabilizer.hammer_synced = src
	playsound(user, 'sound/weapons/crusher_shot.ogg', 160, TRUE)
	destabilizer.fire()
	charged = FALSE
	update_appearance()
	attempt_recharge_projectile()

/// Handles the timer for reloading the projectile
/obj/item/twohanded/kinetic_crusher/proc/attempt_recharge_projectile(set_recharge_time)
	if(!set_recharge_time)
		set_recharge_time = charge_time
	deltimer(charge_timer)
	charge_timer = addtimer(CALLBACK(src, PROC_REF(recharge)), set_recharge_time, TIMER_STOPPABLE)

/obj/item/twohanded/kinetic_crusher/proc/recharge()
	if(charged)
		return

	charged = TRUE
	update_appearance()
	playsound(src.loc, 'sound/weapons/crusher_reload.ogg', 135)

/obj/item/twohanded/kinetic_crusher/ui_action_click(mob/user, datum/action/action, leftclick)
	set_light_on(!light_on)
	playsound(user, 'sound/weapons/empty.ogg', 100, TRUE)
	update_icon()

/obj/item/twohanded/kinetic_crusher/update_icon(updates = ALL)
	. = ..()
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()

/obj/item/twohanded/kinetic_crusher/update_icon_state()
	if(upgraded)
		item_state = "magmite_crusher[HAS_TRAIT(src, TRAIT_WIELDED)]"
	else
		item_state = "crusher[HAS_TRAIT(src, TRAIT_WIELDED)]"

/obj/item/twohanded/kinetic_crusher/update_overlays()
	. = ..()
	if(!charged)
		. += "[icon_state]_uncharged"
	if(light_on)
		. += "[icon_state]_lit"

//trophies
/obj/item/crusher_trophy
	name = "tail spike"
	desc = "A strange spike with no usage."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "tail_spike"
	var/bonus_value = 10 //if it has a bonus effect, this is how much that effect is
	var/denied_type = /obj/item/crusher_trophy

/obj/item/crusher_trophy/Destroy()
	if(istype(loc, /obj/item/twohanded/kinetic_crusher))
		var/obj/item/twohanded/kinetic_crusher/crusher = loc
		crusher.trophies -= src
	return ..()

/obj/item/crusher_trophy/examine(mob/living/user)
	. = ..()
	. += span_notice("Вызывает следующий эффект, если используется как трофей крушителя: [effect_desc()].")

/obj/item/crusher_trophy/proc/effect_desc()
	return "errors"

/obj/item/crusher_trophy/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/twohanded/kinetic_crusher))
		add_fingerprint(user)
		if(add_to(I, user))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/crusher_trophy/proc/add_to(obj/item/twohanded/kinetic_crusher/crusher, mob/living/user)
	for(var/obj/item/crusher_trophy/crusher_trophy as anything in crusher.trophies)
		if(istype(crusher_trophy, denied_type) || istype(src, crusher_trophy.denied_type))
			balloon_alert(user, "нет места!")
			return FALSE
	if(loc == user)
		if(!user.drop_transfer_item_to_loc(src, crusher))
			return FALSE
	else
		forceMove(crusher)
	crusher.trophies += src
	balloon_alert(user, "прикреплено")
	return TRUE

/obj/item/crusher_trophy/proc/remove_from(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	forceMove(get_turf(H))
	H.trophies -= src
	return TRUE

/obj/item/crusher_trophy/proc/on_melee_hit(mob/living/target, mob/living/user) //the target and the user
	return

/obj/item/crusher_trophy/proc/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user) //the projectile fired and the user
	return

/obj/item/crusher_trophy/proc/on_mark_application(mob/living/target, datum/status_effect/crusher_mark/mark, had_mark) //the target, the mark applied, and if the target had a mark before
	return

/obj/item/crusher_trophy/proc/on_mark_detonation(mob/living/target, mob/living/user) //the target and the user
	return

//goliath
/obj/item/crusher_trophy/goliath_tentacle
	name = "goliath tentacle"
	desc = "A sliced-off goliath tentacle. Suitable as a trophy for a kinetic crusher."
	icon_state = "goliath_tentacle"
	denied_type = /obj/item/crusher_trophy/goliath_tentacle
	bonus_value = 2
	var/missing_health_ratio = 0.1
	var/missing_health_desc = 10

/obj/item/crusher_trophy/goliath_tentacle/effect_desc()
	return "Взрыв метки наносит <b>[bonus_value]</b> едениц[DECL_U_Y_0(bonus_value)] дополнительного урона за каждые <b>[missing_health_desc]</b> единиц[DECL_U_Y_0(missing_health_desc)] недостающего у вас здоровья"

/obj/item/crusher_trophy/goliath_tentacle/on_mark_detonation(mob/living/target, mob/living/user)
	var/missing_health = user.health - user.maxHealth
	missing_health *= missing_health_ratio //bonus is active at all times, even if you're above 90 health
	missing_health *= bonus_value //multiply the remaining amount by bonus_value
	if(missing_health > 0)
		target.adjustBruteLoss(missing_health) //and do that much damage

//watcher
/obj/item/crusher_trophy/watcher_wing
	name = "watcher wing"
	desc = "A wing ripped from a watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "watcher_wing"
	denied_type = /obj/item/crusher_trophy/watcher_wing
	bonus_value = 5

/obj/item/crusher_trophy/watcher_wing/effect_desc()
	return "Взрыв метки не позволяет фауне использовать дальние атаки в течении <b>[bonus_value * 0.1]</b> секунд[DECL_Y_0_0(bonus_value * 0.1)]"

/obj/item/crusher_trophy/watcher_wing/on_mark_detonation(mob/living/target, mob/living/user)
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/H = target
		if(H.ranged) //briefly delay ranged attacks
			if(H.ranged_cooldown >= world.time)
				H.ranged_cooldown += bonus_value
			else
				H.ranged_cooldown = bonus_value + world.time

//magmawing watcher
/obj/item/crusher_trophy/blaster_tubes/magma_wing
	name = "magmawing watcher wing"
	desc = "A still-searing wing from a magmawing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "magma_wing"
	gender = NEUTER
	bonus_value = 5

/obj/item/crusher_trophy/blaster_tubes/magma_wing/effect_desc()
	return "Следующий за взрывом метки заряд дестабилизатора наносит <b>[bonus_value]</b> единиц[DECL_U_Y_0(bonus_value)] урона"

/obj/item/crusher_trophy/blaster_tubes/magma_wing/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "heated [marker.name]"
		marker.icon_state = "lava"
		marker.damage = bonus_value
		marker.nodamage = FALSE
		deadly_shot = FALSE

//icewing watcher
/obj/item/crusher_trophy/watcher_wing/ice_wing
	name = "icewing watcher wing"
	desc = "A carefully preserved frozen wing from an icewing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "ice_wing"
	bonus_value = 8

/obj/item/crusher_trophy/legion_skull
	name = "legion skull"
	desc = "A dead and lifeless legion skull. Suitable as a trophy for a kinetic crusher."
	gender = MALE
	icon_state = "legion_skull"
	denied_type = /obj/item/crusher_trophy/legion_skull
	bonus_value = 3

/obj/item/crusher_trophy/legion_skull/effect_desc()
	return "Перезарядка дестабилизатора ускорена на <b>[bonus_value * 0.1]</b> секунд[DECL_U_Y_0(bonus_value * 0.1)]"

/obj/item/crusher_trophy/legion_skull/add_to(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.charge_time -= bonus_value

/obj/item/crusher_trophy/legion_skull/remove_from(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.charge_time += bonus_value

/// Massive eyed tentacle
/obj/item/crusher_trophy/eyed_tentacle
	name = "Massive eyed tentacle"
	desc = "A large, many-eyed tentacle from an ancient Goliath. Can be mounted on a crusher as a trophy."
	icon_state = "ancient_goliath_tentacle"
	denied_type = /obj/item/crusher_trophy/eyed_tentacle
	bonus_value = 1

/obj/item/crusher_trophy/eyed_tentacle/effect_desc()
	return "Крушитель наносит на <b>50%</b> больше урона, если у цели больше <b>90%</b> здоровья"

/obj/item/crusher_trophy/eyed_tentacle/on_melee_hit(mob/living/target, mob/living/user)
	var/procent = (target.health / target.maxHealth) * 100
	if(procent < 90)
		return

	var/obj/item/twohanded/kinetic_crusher/crusher = user.get_active_hand()
	if(!crusher)
		return

	target.apply_damage(crusher.force * bonus_value, crusher.damtype, user.zone_selected)

/// Poison fang
/obj/item/crusher_trophy/fang
	name = "Poison fang"
	desc = "An ugly, venomous marrow weaver fang. Can be mounted on a crusher as a trophy."
	gender = MALE
	icon_state = "ob_gniga"
	denied_type = /obj/item/crusher_trophy/fang
	bonus_value = 1.1

/obj/item/crusher_trophy/fang/effect_desc()
	return "Фауна получает на <b>10%</b> больше урона в течении <b>2</b> секунд после взрыва метки"

/obj/item/crusher_trophy/fang/on_mark_detonation(mob/living/target, mob/living/user)
	target.apply_status_effect(STATUS_EFFECT_FANG_EXHAUSTION, bonus_value)

/// Frost gland
/obj/item/crusher_trophy/gland
	name = "Frost gland"
	desc = "A frost marrow weaver gland. Can be mounted on a crusher as a trophy."
	gender = FEMALE
	icon_state = "ice_gniga"
	denied_type = /obj/item/crusher_trophy/gland
	bonus_value = 0.9

/obj/item/crusher_trophy/gland/effect_desc()
	return "Отмеченная дестабилизатором фауна наносит на <b>10%</b> меньше урона"

/obj/item/crusher_trophy/gland/on_mark_application(mob/living/simple_animal/target, datum/status_effect/crusher_mark/mark, had_mark)
	if(had_mark)
		return

	if(!istype(target))
		return

	target.melee_damage_lower *= bonus_value
	target.melee_damage_upper *= bonus_value

/obj/item/crusher_trophy/gland/on_mark_detonation(mob/living/simple_animal/target, mob/living/user)
	if(!istype(target)) // double check
		return

	target.melee_damage_lower /= bonus_value
	target.melee_damage_upper /= bonus_value

//blood-drunk hunter
/obj/item/crusher_trophy/miner_eye
	name = "eye of a blood-drunk hunter"
	desc = "Its pupil is collapsed and turned to mush. Suitable as a trophy for a kinetic crusher."
	gender = MALE
	icon_state = "hunter_eye"
	denied_type = /obj/item/crusher_trophy/miner_eye

/obj/item/crusher_trophy/miner_eye/effect_desc()
	return "Даёт иммунитет к оглушению и снижает получаемый урона на <b>90%</b> на <b>1</b> секунду после взрыва метки"

/obj/item/crusher_trophy/miner_eye/on_mark_detonation(mob/living/target, mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_BLOODDRUNK)

//ash drake
/obj/item/crusher_trophy/tail_spike
	desc = "A spike taken from an ash drake's tail. Suitable as a trophy for a kinetic crusher."
	gender = MALE
	denied_type = /obj/item/crusher_trophy/tail_spike
	bonus_value = 5

/obj/item/crusher_trophy/tail_spike/effect_desc()
	return "Взрыв метки отталкивает врага и наносит близлежащим существам <b>[bonus_value]</b> единиц[DECL_U_Y_0(bonus_value)] урона"

/obj/item/crusher_trophy/tail_spike/on_mark_detonation(mob/living/target, mob/living/user)
	for(var/mob/living/L in oview(2, user))
		if(L.stat == DEAD)
			continue
		playsound(L, 'sound/magic/fireball.ogg', 20, TRUE)
		new /obj/effect/temp_visual/fire(L.loc)
		addtimer(CALLBACK(src, PROC_REF(pushback), L, user), 1) //no free backstabs, we push AFTER module stuff is done
		L.adjustFireLoss(bonus_value)

/obj/item/crusher_trophy/tail_spike/proc/pushback(mob/living/target, mob/living/user)
	if(!QDELETED(target) && !QDELETED(user) && (!target.anchored || ismegafauna(target))) //megafauna will always be pushed
		step(target, get_dir(user, target))

//bubblegum
/obj/item/crusher_trophy/demon_claws
	name = "demon claws"
	desc = "A set of blood-drenched claws from a massive demon's hand. Suitable as a trophy for a kinetic crusher."
	icon_state = "demon_claws"
	gender = PLURAL
	denied_type = /obj/item/crusher_trophy/demon_claws
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/crusher_trophy/demon_claws/effect_desc()
	return "Ваши удары наносят <b>[bonus_value * 0.2]</b> бонусного урона и восстанавливают вам <b>[bonus_value * 0.1]</b> единиц[DECL_U_Y_0(bonus_value * 0.1)] здоровья. При взрыве метки сила эффекта увеличена в 5 раз"

/obj/item/crusher_trophy/demon_claws/add_to(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.force += bonus_value * 0.2
		H.force_unwielded += bonus_value * 0.2
		// don't update force since KCs have 0 force by default
		H.AddComponent(/datum/component/two_handed, force_wielded = H.force_wielded, force_unwielded = H.force)
		H.detonation_damage += bonus_value * 0.8

/obj/item/crusher_trophy/demon_claws/remove_from(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.force -= bonus_value * 0.2
		H.force_unwielded -= bonus_value * 0.2
		H.AddComponent(/datum/component/two_handed, force_wielded = H.force_wielded, force_unwielded = H.force)
		H.detonation_damage -= bonus_value * 0.8

/obj/item/crusher_trophy/demon_claws/on_melee_hit(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.1, damage_heal_order)

/obj/item/crusher_trophy/demon_claws/on_mark_detonation(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.4, damage_heal_order)

//colossus
/obj/item/crusher_trophy/blaster_tubes
	name = "blaster tubes"
	desc = "The blaster tubes from a colossus's arm. Suitable as a trophy for a kinetic crusher."
	icon_state = "blaster_tubes"
	gender = PLURAL
	denied_type = /obj/item/crusher_trophy/blaster_tubes
	bonus_value = 15
	var/deadly_shot = FALSE

/obj/item/crusher_trophy/blaster_tubes/effect_desc()
	return "После взрыва метки, заменяет дестабилизатор медленным снарядом, наносящим <b>[bonus_value]</b> единиц[DECL_U_Y_0(bonus_value)] урона"

/obj/item/crusher_trophy/blaster_tubes/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "deadly [marker.name]"
		marker.icon_state = "chronobolt"
		marker.damage = bonus_value
		marker.nodamage = FALSE
		marker.speed = 2
		deadly_shot = FALSE

/obj/item/crusher_trophy/blaster_tubes/on_mark_detonation(mob/living/target, mob/living/user)
	deadly_shot = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_deadly_shot)), 300, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/crusher_trophy/blaster_tubes/proc/reset_deadly_shot()
	deadly_shot = FALSE

//hierophant
/obj/item/crusher_trophy/vortex_talisman
	name = "vortex talisman"
	desc = "A glowing trinket that was originally the Hierophant's beacon. Suitable as a trophy for a kinetic crusher."
	gender = MALE
	icon_state = "vortex_talisman"
	denied_type = /obj/item/crusher_trophy/vortex_talisman

/obj/item/crusher_trophy/vortex_talisman/effect_desc()
	return "Взрыв метки призывает трёх самонаводящихся гончих Иерофанта" //Wall was way too cheesy and allowed miners to be nearly invincible while dumb mob AI just rubbed its face on the wall.

/obj/item/crusher_trophy/vortex_talisman/on_mark_detonation(mob/living/target, mob/living/user)
	if(isliving(target))
		var/obj/effect/temp_visual/hierophant/chaser/C = new(get_turf(user), user, target, 3, TRUE)
		C.damage = 10 // Weaker because there is no cooldown
		C.monster_damage_boost = FALSE
		add_attack_logs(user, target, "выстрелил гончей в")

//vetus
/obj/item/crusher_trophy/adaptive_intelligence_core
	name = "adaptive intelligence core"
	desc = "Seems to be one of the cores from a massive robot. Suitable as a trophy for a kinetic crusher."
	icon_state = "adaptive_core"
	denied_type = /obj/item/crusher_trophy/adaptive_intelligence_core
	bonus_value = 2

/obj/item/crusher_trophy/adaptive_intelligence_core/effect_desc()
	return "Увеличивает ваш урон на <b>[bonus_value]</b> единиц[DECL_U_Y_0(bonus_value)] с каждой атакой, до максимума в <b>[bonus_value * 10]</b> единиц[DECL_U_Y_0(bonus_value)]"

/obj/item/crusher_trophy/adaptive_intelligence_core/add_to(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.adaptive_damage_bonus += bonus_value

/obj/item/crusher_trophy/adaptive_intelligence_core/remove_from(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.adaptive_damage_bonus -= bonus_value

//legion

/obj/item/crusher_trophy/empowered_legion_skull
	name = "empowered legion skull"
	desc = "A powerful looking skull with glowing red eyes."
	gender = MALE
	icon_state = "ashen_skull"
	denied_type = /obj/item/crusher_trophy/empowered_legion_skull

/obj/item/crusher_trophy/empowered_legion_skull/effect_desc()
	return "После взрыва метки позволяет вам совершить рывок на <b>3</b> клетки, если вы находитесь в намерении помощи"

/obj/item/crusher_trophy/empowered_legion_skull/on_mark_detonation(mob/living/target, mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_DASH)

//Magmite Crusher

/obj/item/twohanded/kinetic_crusher/mega
	icon_state = "magmite_crusher"
	item_state = "magmite_crusher0"
	name = "magmite proto-kinetic crusher"
	desc = "An early design of the proto-kinetic accelerator, it is now a combination of various mining tools infused with magmite, forming a high-tech club, increasing its capacity as a mining tool."
	destab = /obj/projectile/destabilizer/mega
	upgraded = TRUE
