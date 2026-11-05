// Embedded signaller used in anomalies.
/obj/item/assembly/signaler/core
	name = "anomaly core"
	desc = "The neutralized core of an anomaly. It'd probably be valuable for research."
	icon_state = "core_bluespace_t2"
	item_state = "electronic"
	resistance_flags = FIRE_PROOF
	receiving = TRUE
	/// The type of anomaly that leaves nuclei of this type.
	var/anomaly_type = /obj/effect/old_anomaly
	/// The strength of the anomaly at the moment of stabilization. Used to scale some effects of items using anomaly cores.
	var/charge = 50
	/// The level of the anomaly from which the core was collected.
	var/tier = 0
	/// Moment whet this core was created. Used to prevent the core from instantly disintegrating when charging.
	var/born_moment = 0
	COOLDOWN_DECLARE(anomaly_toch_cooldown)

/obj/item/assembly/signaler/core/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] засовыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] себе в рот. Похоже [GEND_HE_SHE(user)] пыта[PLUR_ET_YUT(user)]ся убить себя!"))
	return OXYLOSS | BRUTELOSS

/obj/item/assembly/signaler/core/examine(mob/user)
	. = ..()
	. += span_notice("Текущий заряд: [charge].")
	. += span_notice("Текущая сила: [get_strength()].")

/obj/item/assembly/signaler/core/Initialize(mapload, charge)
	. = ..()
	if(!charge)
		charge = iscoreempty(src) ? 0 : rand(51, 60)

	src.charge = charge
	born_moment = world.time

// Used in old anomalies.
/obj/item/assembly/signaler/core/receive_signal(datum/signal/signal)
	if(!..())
		return

	for(var/obj/effect/old_anomaly/anomaly in get_turf(src))
		anomaly.anomalyNeutralize()

/obj/item/assembly/signaler/core/attack_self()
	return

/*
100 of tier 1 == 50 of tier 2 == 25 of tier 3
100 of tier 3 == 200 of tier 2 == 400 of tier 1
*/
/obj/item/assembly/signaler/core/proc/get_strength()
	return round(charge * (1 << (tier - 1)) * (tier != 4 ? 1 : 1.5))

// ============================ Tier 1 ===================================
/obj/item/assembly/signaler/core/tier1
	name = "empty minor anomaly core"
	desc = "The anomaly apparently lacked enough power during stabilization to give this core any special properties. Perhaps it can be charged somehow."
	icon_state = "core_empty_t1"
	anomaly_type = null
	origin_tech = "materials=3"
	tier = 1

/obj/item/assembly/signaler/core/atmospheric/tier1
	name = "minor atmospheric anomaly core"
	desc = "The stabilized core of a minor atmospheric anomaly. Cool to the touch. Probably useful for research."
	icon_state = "core_atmos_t1"
	anomaly_type = /obj/effect/anomaly/atmospheric/tier1
	origin_tech = "plasmatech=5"
	tier = 1

/obj/item/assembly/signaler/core/gravitational/tier1
	name = "minor gravitational anomaly core"
	desc = "The neutralized core of a minor gravitational anomaly. Slightly lighter than it looks. Probably useful for research."
	icon_state = "core_grav_t1"
	anomaly_type = /obj/effect/anomaly/gravitational/tier1
	origin_tech = "magnets=5"
	tier = 1

/obj/item/assembly/signaler/core/energetic/tier1
	name = "minor energetic anomaly core"
	desc = "The stabilized core of a minor energetic anomaly. Touching it causes a slight tingling sensation. Probably useful for research."
	icon_state = "core_energ_t1"
	anomaly_type = /obj/effect/anomaly/energetic/tier1
	origin_tech = "powerstorage=5"
	tier = 1

/obj/item/assembly/signaler/core/bluespace/tier1
	name = "minor bluespace anomaly core"
	desc = "The stabilized core of a minor bluespace anomaly. Occasionally disappears from sight for a split second. Probably useful for research."
	icon_state = "core_bluespace_t1"
	anomaly_type = /obj/effect/anomaly/bluespace/tier1
	origin_tech = "bluespace=5"
	tier = 1

/obj/item/assembly/signaler/core/vortex/tier1
	name = "minor vortex anomaly core"
	desc = "The stabilized core of a minor vortex anomaly. It twitches occasionally. Probably useful for research."
	icon_state = "core_vortex_t1"
	anomaly_type = /obj/effect/anomaly/vortex/tier1
	origin_tech = "engineering=5"
	tier = 1

/obj/item/assembly/signaler/core/tier2
	name = "empty anomaly core"
	desc = "The anomaly apparently lacked enough power during stabilization to give the core any special properties. Perhaps it can be charged somehow."
	icon_state = "core_empty_t2"
	anomaly_type = null
	origin_tech = "materials=5" // not clonable by experimentor
	tier = 2

/obj/item/assembly/signaler/core/atmospheric/tier2
	name = "pyroclastic anomaly core"
	desc = "The neutralized core of a pyroclastic anomaly. It feels warm to the touch. It'd probably be valuable for research."
	icon_state = "core_atmos_t2"
	anomaly_type = /obj/effect/anomaly/atmospheric/tier2
	origin_tech = "plasmatech=7"
	tier = 2

/obj/item/assembly/signaler/core/gravitational/tier2
	name = "gravitational anomaly core"
	desc = "The neutralized core of a gravitational anomaly. It feels much heavier than it looks. It'd probably be valuable for research."
	icon_state = "core_grav_t2"
	anomaly_type = /obj/effect/anomaly/gravitational/tier2
	origin_tech = "magnets=7"
	tier = 2

/obj/item/assembly/signaler/core/energetic/tier2
	name = "flux anomaly core"
	desc = "The neutralized core of a flux anomaly. Touching it makes your skin tingle. It'd probably be valuable for research."
	icon_state = "core_energ_t2"
	anomaly_type = /obj/effect/anomaly/energetic/tier2
	origin_tech = "powerstorage=7"
	tier = 2

/obj/item/assembly/signaler/core/bluespace/tier2
	name = "bluespace anomaly core"
	desc = "The neutralized core of a bluespace anomaly. It keeps phasing in and out of view. It'd probably be valuable for research."
	anomaly_type = /obj/effect/anomaly/bluespace/tier2
	origin_tech = "bluespace=7"
	tier = 2

/obj/item/assembly/signaler/core/vortex/tier2
	name = "vortex anomaly core"
	desc = "The neutralized core of a vortex anomaly. It won't sit still, as if some invisible force is acting on it. It'd probably be valuable for research."
	icon_state = "core_vortex_t2"
	anomaly_type = /obj/effect/anomaly/vortex/tier2
	origin_tech = "engineering=7"
	tier = 2

/obj/item/assembly/signaler/core/tier3
	name = "empty major anomaly core"
	desc = "The anomaly apparently lacked enough power during stabilization to give the core any special properties. Perhaps it can be charged somehow."
	icon_state = "core_empty_t3"
	anomaly_type = null
	origin_tech = "materials=7" // Sorry, not clonable by experimentor
	tier = 3

/obj/item/assembly/signaler/core/atmospheric/tier3
	name = "major atmospheric anomaly core"
	desc = "The stabilized core of a major atmospheric anomaly. Just looking at it makes you feel hot and cold, quite literally."
	icon_state = "core_atmos_t3"
	anomaly_type = /obj/effect/anomaly/atmospheric/tier3
	origin_tech = "plasmatech=8"
	tier = 3

/obj/item/assembly/signaler/core/atmospheric/tier3/suicide_act(mob/living/user)
	..()
	user.adjust_fire_stacks(30)
	user.IgniteMob()
	return FIRELOSS

/obj/item/assembly/signaler/core/atmospheric/tier3/forceMove(atom/destination)
	if(!ishuman(destination))
		STOP_PROCESSING(SSobj, src)
		return ..()

	START_PROCESSING(SSobj, src)
	if(!prob(1))
		return ..()

	var/mob/living/carbon/human/H = destination
	H.adjust_fire_stacks(charge/10)
	H.IgniteMob()
	return ..()

/obj/item/assembly/signaler/core/atmospheric/tier3/process()
	var/mob/living/carbon/human/H = loc
	if(!istype(H))
		return

	if(prob(90))
		return

	if(H.bodytemperature < T0C - 50)
		visible_message("[DECLENT_RU_CAP(src, NOMINATIVE)] реагирует на контакт с холодным объектом, испуская языки пламени!")
		H.adjust_fire_stacks(round(get_strength() / 30 + 0.5))
		H.IgniteMob()
		return

	if(H.bodytemperature <= T0C + 100)
		return

	visible_message("[DECLENT_RU_CAP(src, NOMINATIVE)] реагирует на контакт с горячим объектом, значительно охлаждая окружающую среду!")
	H.apply_status_effect(/datum/status_effect/freon)
	H.ExtinguishMob()
	H.adjust_bodytemperature(-get_strength())

/obj/item/assembly/signaler/core/gravitational/tier3
	name = "major gravitational anomaly core"
	desc = "The neutralized core of a major gravitational anomaly. The weights of many nearby objects feel strangely at odds with their appearance."
	icon_state = "core_grav_t3"
	anomaly_type = /obj/effect/anomaly/gravitational/tier3
	origin_tech = "magnets=8"
	var/atom/old_owner = null
	tier = 3

/obj/item/assembly/signaler/core/gravitational/tier3/suicide_act(mob/user)
	..()
	user.visible_message(span_suicide("[user] взрыва[PLUR_ET_YUT(user)]ся из-за возникшего гравитационного колодца!"), \
						span_suicide("Вы взрываетесь из-за возникшего гравитационного колодца!"),
						span_suicide("Вы слышите громкий хлопок!"))
	user.gib()
	return OBLITERATION

/obj/item/assembly/signaler/core/gravitational/tier3/Initialize(mapload)
	. = ..()
	old_owner = get_external_loc()
	update_gravity(TRUE)

/obj/item/assembly/signaler/core/gravitational/tier3/Destroy()
	old_owner?.remove_gravity_source("core_grav")
	old_owner = null
	return ..()

// Mobs will be in reversed gravity. Items will be without gravity.
/obj/item/assembly/signaler/core/gravitational/tier3/proc/update_gravity(restart = FALSE)
	if(restart)
		addtimer(CALLBACK(src, PROC_REF(update_gravity), TRUE), 5 SECONDS)

	var/atom/new_owner = get_external_loc()
	if(!new_owner)
		return

	if(old_owner == new_owner && old_owner.has_gravity() == -1)
		return

	old_owner.remove_gravity_source("core_grav")
	if(ismob(new_owner))
		new_owner.add_gravity("core_grav", -(new_owner.has_gravity() + 2))

	if(isitem(new_owner))
		new_owner.add_gravity("core_grav", -(new_owner.has_gravity() + 1))

	old_owner = new_owner

/obj/item/assembly/signaler/core/gravitational/tier3/forceMove(atom/destination)
	. = ..()
	update_gravity()

/obj/item/assembly/signaler/core/energetic/tier3
	name = "major energetic anomaly core"
	desc = "The stabilized core of a major energetic anomaly. Electrical discharges periodically surround it, and nearby electronics hum tensely."
	icon_state = "core_energ_t3"
	anomaly_type = /obj/effect/anomaly/energetic/tier3
	origin_tech = "powerstorage=8"
	tier = 3

/obj/item/assembly/signaler/core/energetic/tier3/Bump(atom/bumped_atom)
	. = ..()
	try_shock(bumped_atom)

/obj/item/assembly/signaler/core/energetic/tier3/suicide_act(mob/living/user)
	..()
	user.electrocute_act(600, src)
	return FIRELOSS

/obj/item/assembly/signaler/core/energetic/tier3/proc/try_shock(atom/target)
	if(!iscarbon(target))
		return FALSE

	visible_message(span_warning("[declent_ru(NOMINATIVE)] внезапно испустил[GEND_A_O_I(src)] электрический разряд!"))
	var/mob/living/carbon/human/H = target
	if(H.electrocute_act(charge, src))
		do_sparks(max(1, charge / 20), FALSE, src)
		return TRUE

	return FALSE

/obj/item/assembly/signaler/core/energetic/tier3/forceMove(atom/destination)
	if(!try_shock(destination))
		return ..()
	else
		return FALSE

/obj/item/assembly/signaler/core/bluespace/tier3
	name = "major bluespace anomaly core"
	desc = "The neutralized core of a bluespace anomaly. It keeps phasing in and out of view. It'd probably be valuable for research."
	icon_state = "core_bluespace_t3"
	anomaly_type = /obj/effect/anomaly/bluespace/tier3
	origin_tech = "bluespace=8"
	tier = 3

/obj/item/assembly/signaler/core/bluespace/tier3/suicide_act(mob/user)
	..()
	user.gib()
	for(var/obj/item/organ/internal/O in range(2))
		if(!isturf(O.loc))
			continue

		do_teleport(O, O, 2, asoundin = 'sound/effects/phasein.ogg')

	return OBLITERATION

/obj/item/assembly/signaler/core/bluespace/tier3/Bump(atom/bumped_atom)
	. = ..()
	try_teleport()

/obj/item/assembly/signaler/core/bluespace/tier3/proc/try_teleport()
	if(prob(80) || !ismob(loc))
		return FALSE

	visible_message(span_warning("[declent_ru(NOMINATIVE)] внезапно телепортируется!"))
	return do_teleport(src, src, 2, asoundin = 'sound/effects/phasein.ogg')

/obj/item/assembly/signaler/core/bluespace/tier3/forceMove(atom/destination)
	if(!try_teleport())
		return ..()
	else
		return FALSE

/obj/item/assembly/signaler/core/vortex/tier3
	name = "major vortex anomaly core"
	desc = "The stabilized core of a major vortex anomaly. Nearby objects tremble alarmingly."
	icon_state = "core_vortex_t3"
	anomaly_type = /obj/effect/anomaly/vortex/tier3
	origin_tech = "engineering=8"
	tier = 3

/obj/item/assembly/signaler/core/tier3/tier4
	name = "empty colossal anomaly core"
	desc = "The anomaly apparently lacked enough power during stabilization to give the core any special properties. Perhaps it can be charged somehow. You have a persistent feeling that it should not be here."
	anomaly_type = null
	origin_tech = "materials=10" // Sorry, not clonable by experimentor
	tier = 4

/obj/item/assembly/signaler/core/atmospheric/tier3/tier4
	name = "colossal atmospheric anomaly core"
	desc = "The stabilized core of a colossal atmospheric anomaly. You have a persistent feeling that it should not be here."
	anomaly_type = /obj/effect/anomaly/atmospheric/tier4
	origin_tech = "plasmatech=11"
	tier = 4

/obj/item/assembly/signaler/core/gravitational/tier3/tier4
	name = "colossal gravitational anomaly core"
	desc = "The neutralized core of a colossal gravitational anomaly. You have a persistent feeling that it should not be here."
	anomaly_type = /obj/effect/anomaly/gravitational/tier4
	origin_tech = "magnets=11"
	tier = 4

/obj/item/assembly/signaler/core/energetic/tier3/tier4
	name = "colossal energetic anomaly core"
	desc = "The stabilized core of a colossal energetic anomaly. You have a persistent feeling that it should not be here."
	anomaly_type = /obj/effect/anomaly/energetic/tier4
	origin_tech = "powerstorage=11"
	tier = 4

/obj/item/assembly/signaler/core/bluespace/tier3/tier4
	name = "colossal bluespace anomaly core"
	desc = "The stabilized core of a major bluespace anomaly. You have a persistent feeling that it should not be here."
	anomaly_type = /obj/effect/anomaly/bluespace/tier4
	origin_tech = "bluespace=11"
	tier = 4

/obj/item/assembly/signaler/core/vortex/tier3/tier4
	name = "colossal vortex anomaly core"
	desc = "The stabilized core of a colossal vortex anomaly. You have a persistent feeling that it should not be here."
	anomaly_type = /obj/effect/anomaly/vortex/tier4
	origin_tech = "engineering=11"
	tier = 4
