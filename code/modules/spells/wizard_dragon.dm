// Player-controlled wizard transformation; no mining boss or boss rewards.
#define DRAKE_SWOOP_HEIGHT 270
#define DRAKE_SWOOP_DIRECTION_CHANGE_RANGE 5
#define SWOOP_DAMAGEABLE 1
#define SWOOP_INVULNERABLE 2

/mob/living/simple_animal/hostile/wizard_dragon
	name = "lesser ash drake"
	desc = "A dragon conjured by powerful transformation magic."
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "dragon"
	icon_living = "dragon"
	icon_dead = "dragon_dead"
	health = 200
	maxHealth = 200
	faction = list("neutral")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	weather_immunities = list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE)
	attacktext = "грызёт"
	attack_sound = 'sound/misc/demon_attack1.ogg'
	armour_penetration = 40
	melee_damage_lower = 30
	melee_damage_upper = 30
	obj_damage = 80
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	speed = 5
	move_to_delay = 5
	ranged = TRUE
	pixel_x = -16
	base_pixel_x = -16
	mouse_opacity = MOUSE_OPACITY_ICON
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	var/swooping = NONE
	var/player_cooldown = 0
	var/recovery_time = 0

/mob/living/simple_animal/hostile/wizard_dragon/ComponentInitialize()
	AddComponent(/datum/component/animal_temperature, maxbodytemp = INFINITY, minbodytemp = 0)

/mob/living/simple_animal/hostile/wizard_dragon/OpenFire()
	if(swooping || recovery_time >= world.time || a_intent == INTENT_HELP || intent == INTENT_HELP)
		return
	ranged_cooldown = world.time + ranged_cooldown_time
	fire_cone()

/mob/living/simple_animal/hostile/wizard_dragon/proc/SetRecoveryTime(buffer_time)
	recovery_time = world.time + buffer_time
	ranged_cooldown = world.time + buffer_time

/mob/living/simple_animal/hostile/wizard_dragon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)

/mob/living/simple_animal/hostile/wizard_dragon/proc/lava_pools(amount, delay = 0.8)
	if(!target)
		return
	target.visible_message(span_boldwarning("Вокруг вас начинают образовываться лужи лавы!"))
	while(amount > 0)
		if(QDELETED(target))
			break
		var/turf/T = pick(RANGE_TURFS(1, target))
		new /obj/effect/temp_visual/lava_warning(T, 6 SECONDS) // longer reset time for the lava
		amount--
		SLEEP_CHECK_DEATH(src, delay)

/mob/living/simple_animal/hostile/wizard_dragon/proc/fire_cone(atom/at = target)
	playsound(get_turf(src),'sound/magic/fireball.ogg', 200, TRUE)
	SLEEP_CHECK_DEATH(src, 0)
	var/range = 15
	var/list/turfs = list()
	turfs = line_target(-40, range, at)
	INVOKE_ASYNC(src, PROC_REF(fire_line), turfs)
	turfs = line_target(0, range, at)
	INVOKE_ASYNC(src, PROC_REF(fire_line), turfs)
	turfs = line_target(40, range, at)
	INVOKE_ASYNC(src, PROC_REF(fire_line), turfs)

/mob/living/simple_animal/hostile/wizard_dragon/proc/line_target(offset, range, atom/at = target)
	if(!at)
		return
	var/angle = ATAN2(at.x - src.x, at.y - src.y) + offset
	var/turf/T = get_turf(src)
	for(var/i in 1 to range)
		var/turf/check = locate(src.x + cos(angle) * i, src.y + sin(angle) * i, src.z)
		if(!check)
			break
		T = check
	return (get_line(src, T) - get_turf(src))

/mob/living/simple_animal/hostile/wizard_dragon/proc/fire_line(list/turfs)
	SLEEP_CHECK_DEATH(src, 0)
	dragon_fire_line(src, turfs)

//fire line keeps going even if dragon is deleted
/proc/dragon_fire_line(source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/turf as anything in turfs)
		if(turf.density)
			break

		var/obj/effect/hotspot/hotspot = new /obj/effect/hotspot/fake(turf)
		hotspot.temperature = 1000
		hotspot.recolor()
		turf.hotspot_expose(700, 50)
		for(var/mob/living/mob in turf.contents)
			if((mob in hit_list) || mob == source)
				continue
			hit_list += mob
			mob.adjustFireLoss(20)
			to_chat(mob, span_userdanger("Вас поражает огненное дыхание [source]!"))

		// deals damage to mechs
		for(var/obj/mecha/mecha in turf.contents)
			if(mecha in hit_list)
				continue
			hit_list += mecha
			mecha.take_damage(45, BRUTE, MELEE, 1)
		sleep(1.5)

/mob/living/simple_animal/hostile/wizard_dragon/proc/swoop_attack(lava_arena = FALSE, atom/movable/manual_target, swoop_cooldown = 30)
	if(stat || swooping)
		return
	if(manual_target)
		target = manual_target
	if(!target)
		return
	stop_automated_movement = TRUE
	swooping |= SWOOP_DAMAGEABLE
	ADD_TRAIT(src, TRAIT_UNDENSE, DRAGON_SWOOP_TRAIT)
	icon_state = "shadow"
	visible_message(span_boldwarning("[DECLENT_RU_CAP(src, NOMINATIVE)] взмывает высоко вверх!"))

	var/negative
	var/initial_x = x
	if(target.x < initial_x) //if the target's x is lower than ours, swoop to the left
		negative = TRUE
	else if(target.x > initial_x)
		negative = FALSE
	else if(target.x == initial_x) //if their x is the same, pick a direction
		negative = prob(50)
	var/obj/effect/temp_visual/dragon_flight/F = new /obj/effect/temp_visual/dragon_flight(loc, negative)

	negative = !negative //invert it for the swoop down later

	var/oldtransform = transform
	alpha = 255
	animate(src, alpha = 204, transform = matrix()*0.9, time = 3, easing = BOUNCE_EASING)
	for(var/i in 1 to 3)
		sleep(1)
		if(QDELETED(src) || stat == DEAD) //we got hit and died, rip us
			qdel(F)
			if(stat == DEAD)
				swooping &= ~SWOOP_DAMAGEABLE
				animate(src, alpha = 255, transform = oldtransform, time = 0, flags = ANIMATION_END_NOW) //reset immediately
			return
	animate(src, alpha = 100, transform = matrix()*0.7, time = 7)
	swooping |= SWOOP_INVULNERABLE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	SLEEP_CHECK_DEATH(src, 7)

	while(target && loc != get_turf(target))
		forceMove(get_step(src, get_dir(src, target)))
		SLEEP_CHECK_DEATH(src, 0.5)

	// Ash drake flies onto its target and rains fire down upon them
	var/descentTime = 10

	//ensure swoop direction continuity.
	if(negative)
		if(ISINRANGE(x, initial_x + 1, initial_x + DRAKE_SWOOP_DIRECTION_CHANGE_RANGE))
			negative = FALSE
	else
		if(ISINRANGE(x, initial_x - DRAKE_SWOOP_DIRECTION_CHANGE_RANGE, initial_x - 1))
			negative = TRUE
	new /obj/effect/temp_visual/dragon_flight/end(loc, negative)
	new /obj/effect/temp_visual/dragon_swoop(loc)
	animate(src, alpha = 255, transform = oldtransform, descentTime)
	SLEEP_CHECK_DEATH(src, descentTime)
	swooping &= ~SWOOP_INVULNERABLE
	mouse_opacity = initial(mouse_opacity)
	icon_state = "dragon"
	playsound(loc, 'sound/effects/meteorimpact.ogg', 200, TRUE)
	for(var/mob/living/L in orange(1, src))
		if(L.stat)
			visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] обрушивается на [L.declent_ru(NOMINATIVE)], раздавливая [GEND_HIS_HER(L)]!"))
			L.gib()
		else
			L.adjustBruteLoss(75)
			if(L && !QDELETED(L)) // Some mobs are deleted on death
				var/throw_dir = get_dir(src, L)
				if(L.loc == loc)
					throw_dir = pick(GLOB.alldirs)
				var/throwtarget = get_edge_target_turf(src, throw_dir)
				L.throw_at(throwtarget, 3)
				visible_message(span_warning("[DECLENT_RU_CAP(L, NOMINATIVE)] отбрасывается в сторону от [declent_ru(ACCUSATIVE)]!"))
	for(var/obj/mecha/M in orange(1, src))
		M.take_damage(75, BRUTE, MELEE, 1)

	for(var/mob/M in range(7, src))
		shake_camera(M, 15, 1)

	REMOVE_TRAIT(src, TRAIT_UNDENSE, DRAGON_SWOOP_TRAIT)
	SLEEP_CHECK_DEATH(src, 1)
	swooping &= ~SWOOP_DAMAGEABLE
	SetRecoveryTime(swoop_cooldown)

/mob/living/simple_animal/hostile/wizard_dragon/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	if(swooping & SWOOP_INVULNERABLE)
		return STATUS_UPDATE_NONE
	return ..()

/mob/living/simple_animal/hostile/wizard_dragon/visible_message(message, self_message, blind_message, list/ignored_mobs, chat_message_type)
	if(swooping & SWOOP_INVULNERABLE) //to suppress attack messages without overriding every single proc that could send a message saying we got hit
		return
	return ..()

/mob/living/simple_animal/hostile/wizard_dragon/AttackingTarget()
	if(!swooping)
		return ..()

/mob/living/simple_animal/hostile/wizard_dragon/DestroySurroundings()
	if(!swooping)
		..()

/mob/living/simple_animal/hostile/wizard_dragon/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(!swooping)
		. = ..()

/mob/living/simple_animal/hostile/wizard_dragon/Goto(target, delay, minimum_distance)
	if(!swooping)
		..()

/mob/living/simple_animal/hostile/wizard_dragon/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE

/obj/effect/temp_visual/lava_warning
	icon_state = "lavastaff_warn"
	layer = BELOW_MOB_LAYER
	light_range = 2
	duration = 13

/obj/effect/temp_visual/lava_warning/ex_act()
	return

/obj/effect/temp_visual/lava_warning/Initialize(mapload, reset_time = 10)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(fall), reset_time)
	src.alpha = 63.75
	animate(src, alpha = 255, time = duration)

/obj/effect/temp_visual/lava_warning/proc/fall(reset_time)
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/fleshtostone.ogg', 80, TRUE)
	sleep(duration)
	playsound(T,'sound/magic/fireball.ogg', 200, TRUE)

	for(var/mob/living/L in T.contents)
		if(istype(L, /mob/living/simple_animal/hostile/wizard_dragon))
			continue
		L.adjustFireLoss(10)
		to_chat(L, span_userdanger("Вы рухнули в лаву!"))

	// deals damage to mechs
	for(var/obj/mecha/M in T.contents)
		M.take_damage(45, BRUTE, MELEE, 1)

	// changes turf to lava temporarily
	if(!T.density && !islava(T))
		var/lava_turf = /turf/simulated/floor/lava
		var/reset_turf = T.type
		T.ChangeTurf(lava_turf)
		sleep(reset_time)
		T.ChangeTurf(reset_turf)

/obj/effect/temp_visual/dragon_swoop
	name = "certain death"
	desc = "Don't just stand there, move!"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "landing"
	layer = BELOW_MOB_LAYER
	pixel_x = -32
	pixel_y = -32
	color = "#FF0000"

/obj/effect/temp_visual/dragon_flight
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "dragon"
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -16
	randomdir = FALSE

/obj/effect/temp_visual/dragon_flight/Initialize(mapload, negative)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(flight), negative)

/obj/effect/temp_visual/dragon_flight/proc/flight(negative)
	if(negative)
		animate(src, pixel_x = -DRAKE_SWOOP_HEIGHT*0.1, pixel_z = DRAKE_SWOOP_HEIGHT*0.15, time = 3, easing = BOUNCE_EASING)
	else
		animate(src, pixel_x = DRAKE_SWOOP_HEIGHT*0.1, pixel_z = DRAKE_SWOOP_HEIGHT*0.15, time = 3, easing = BOUNCE_EASING)
	sleep(3)
	icon_state = "swoop"
	if(negative)
		animate(src, pixel_x = -DRAKE_SWOOP_HEIGHT, pixel_z = DRAKE_SWOOP_HEIGHT, time = 7)
	else
		animate(src, pixel_x = DRAKE_SWOOP_HEIGHT, pixel_z = DRAKE_SWOOP_HEIGHT, time = 7)

/obj/effect/temp_visual/dragon_flight/end
	pixel_x = DRAKE_SWOOP_HEIGHT
	pixel_z = DRAKE_SWOOP_HEIGHT

/obj/effect/temp_visual/dragon_flight/end/flight(negative)
	if(negative)
		pixel_x = -DRAKE_SWOOP_HEIGHT
		animate(src, pixel_x = -16, pixel_z = 0, time = 5)
	else
		animate(src, pixel_x = -16, pixel_z = 0, time = 5)

/mob/living/simple_animal/hostile/wizard_dragon/get_ru_names()
	return alist(
		NOMINATIVE = "младший пепельный дрейк",
		GENITIVE = "младшего пепельного дрейка",
		DATIVE = "младшему пепельному дрейку",
		ACCUSATIVE = "младший пепельный дрейк",
		INSTRUMENTAL = "младшим пепельным дрейком",
		PREPOSITIONAL = "младшем пепельном дрейке",
	)

/mob/living/simple_animal/hostile/wizard_dragon/AltClickOn(atom/movable/A)
	if(a_intent == INTENT_HELP || intent == INTENT_HELP)
		return
	if(!istype(A))
		return
	if(player_cooldown >= world.time)
		to_chat(src, span_warning("Вам нужно подождать [(player_cooldown - world.time) / 10] секунд[DECL_U_Y_0((player_cooldown - world.time) / 10)] перед следующим пикированием!"))
		return
	swoop_attack(FALSE, A)
	lava_pools(10, 2) // less pools but longer delay before spawns
	player_cooldown = world.time + 200 // needs seperate cooldown or cant use fire attacks


#undef DRAKE_SWOOP_HEIGHT
#undef DRAKE_SWOOP_DIRECTION_CHANGE_RANGE
#undef SWOOP_DAMAGEABLE
#undef SWOOP_INVULNERABLE
