/obj/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 23
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = LASER
	eyeblur = 4 SECONDS
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	reflectability = REFLECTABILITY_ENERGY
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_color = COLOR_SOFT_RED
	ricochets_max = 50	//Honk!
	ricochet_chance = 80

/obj/projectile/beam/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/projectile/beam/laser/light
	damage = 16
	armour_penetration = -50

/obj/projectile/beam/laser/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 50
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser
	hitsound = 'sound/weapons/resonator_blast.ogg'

/obj/projectile/beam/laser/slug
	name = "laser slug beam"
	damage = 50
	stamina = 33

/obj/projectile/beam/laser/shot
	name = "laser shot beam"
	icon_state = "lasershot"
	damage = 15

/obj/projectile/beam/laser/syndrone
	name = "light immolation beam"
	damage = 8
	icon_state = "scatterlaser"
	eyeblur = 2 SECONDS

/obj/projectile/beam/practice
	name = "practice laser"
	damage = 0
	hitsound = 'sound/weapons/tap.ogg'
	nodamage = TRUE
	log_override = TRUE

/obj/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5

/obj/projectile/beam/xray
	name = "x-ray beam"
	icon_state = "xray"
	damage = 10
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	tile_dropoff = 0.75
	forcedodge = -1
	range = 15
	armour_penetration = 100
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/projectile/beam/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	shockbull = TRUE
	damage_type = STAMINA
	flag = ENERGY
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/projectile/beam/specter/laser
	name = "specter laser beam"

/obj/projectile/beam/specter/disabler
	name = "specter paralyzer beam"
	icon_state = "omnilaser"
	damage = 30
	shockbull = TRUE
	damage_type = STAMINA
	flag = ENERGY
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	hitsound_wall = 'sound/weapons/sear.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_LIGHT_CYAN

/obj/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	var/gib_allowed = TRUE
	hitsound = 'sound/weapons/resonator_blast.ogg'
	hitsound_wall = 'sound/weapons/resonator_blast.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse

/obj/projectile/beam/pulse/hitscan
	impact_effect_type = null
	light_color = null
	hitscan = TRUE
	hitscan_light_intensity = 3
	hitscan_light_color_override = LIGHT_COLOR_BLUE
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = LIGHT_COLOR_BLUE
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = LIGHT_COLOR_BLUE

/obj/projectile/beam/pulse/hitscan/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"

/obj/projectile/beam/pulse/on_hit(atom/target, blocked = 0)
	if(isturf(target) || isstructure(target) || ismachinery(target))
		target.ex_act(EXPLODE_HEAVY)
	return ..()

/obj/projectile/beam/pulse/on_hit(atom/target)
	. = ..()
	if(gib_allowed && isliving(target))
		var/mob/living/L = target
		if(L.health <= -200)
			L.visible_message(span_danger("Импульсный заряд превращает [L.declent_ru(ACCUSATIVE)] в облако пепла!"))
			L.dust()

/obj/projectile/beam/pulse/shot
	gib_allowed = FALSE
	damage = 40

/obj/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 33
	hitsound = 'sound/weapons/resonator_blast.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN

/obj/projectile/beam/emitter/hitscan
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/laser/emitter
	tracer_type = /obj/effect/projectile/tracer/laser/emitter
	impact_type = /obj/effect/projectile/impact/laser/emitter
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_color_override = COLOR_LIME
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = COLOR_LIME
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = COLOR_LIME
	// Subtract this from SM damage on hit for lasers
	var/integrity_heal
	// Subtract this from SM energy on hit for lasers
	var/energy_reduction
	// Add this to SM psi coefficient on hit for lasers
	var/psi_change

/obj/projectile/beam/emitter/singularity_pull(atom/singularity, current_size)
	return // don't want the emitters to miss

/obj/projectile/beam/emitter/hitscan/bluelens
	name = "electrodisruptive beam"
	light_color = LIGHT_COLOR_BLUE
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	tracer_type = /obj/effect/projectile/tracer/laser/emitter/bluelens
	impact_type = /obj/effect/projectile/impact/pulse
	hitscan_light_color_override = COLOR_BLUE_LIGHT
	muzzle_flash_color_override = COLOR_BLUE_LIGHT
	impact_light_color_override = COLOR_BLUE_LIGHT
	damage_type = STAMINA
	integrity_heal = 0.25
	energy_reduction = 60

/obj/projectile/beam/emitter/hitscan/bioregen
	name = "bioregenerative beam"
	light_color = LIGHT_COLOR_BRIGHT_YELLOW
	muzzle_type = /obj/effect/projectile/muzzle/solar
	tracer_type = /obj/effect/projectile/tracer/laser/emitter/bioregen
	impact_type = /obj/effect/projectile/impact/solar
	hitscan_light_color_override = COLOR_LIGHT_YELLOW
	muzzle_flash_color_override = COLOR_LIGHT_YELLOW
	impact_light_color_override = COLOR_LIGHT_YELLOW
	damage_type = STAMINA
	damage = 0
	var/healing_done = 5

/obj/projectile/beam/emitter/hitscan/bioregen/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/healed_guy = target
	healed_guy.heal_organ_damage(brute = healing_done, burn = healing_done, updating_health = FALSE)

/obj/projectile/beam/emitter/hitscan/incend
	name = "conflagratory beam"
	light_color = LIGHT_COLOR_ORANGE
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	tracer_type = /obj/effect/projectile/tracer/laser/emitter/redlens
	impact_type = /obj/effect/projectile/impact/heavy_laser
	hitscan_light_color_override = COLOR_ORANGE
	muzzle_flash_color_override = COLOR_ORANGE
	impact_light_color_override = COLOR_ORANGE
	damage = 20
	integrity_heal = -0.15
	energy_reduction = -150
	psi_change = -0.1

/obj/projectile/beam/emitter/hitscan/incend/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/burnt_guy = target
	burnt_guy.adjust_fire_stacks(5)
	burnt_guy.IgniteMob()

/obj/projectile/beam/emitter/hitscan/psy
	name = "psychosiphoning beam"
	light_color = LIGHT_COLOR_PINK
	muzzle_type = /obj/effect/projectile/muzzle/laser/emitter/psy
	tracer_type = /obj/effect/projectile/tracer/laser/emitter/psy
	impact_type = /obj/effect/projectile/impact/laser/emitter/psy
	hitscan_light_color_override = COLOR_BLUSH_PINK
	muzzle_flash_color_override = COLOR_BLUSH_PINK
	impact_light_color_override = COLOR_BLUSH_PINK
	damage = 0
	energy_reduction = -25
	psi_change = 0.25

/obj/projectile/beam/emitter/hitscan/psy/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/siphoned = target
	//siphoned.mob_mood.adjust_sanity(-25)
	to_chat(siphoned, span_warning("Suddenly, everything feels just a little bit worse!"))

/obj/projectile/beam/emitter/hitscan/magnetic
	name = "magnetogenerative beam"
	light_color = COLOR_SILVER
	muzzle_type = /obj/effect/projectile/muzzle/laser/emitter/magnetic
	tracer_type = /obj/effect/projectile/tracer/laser/emitter/magnetic
	impact_type = /obj/effect/projectile/impact/laser/emitter/magnetic
	hitscan_light_color_override = COLOR_SILVER
	muzzle_flash_color_override = COLOR_SILVER
	impact_light_color_override = COLOR_SILVER
	damage = 0

/obj/projectile/beam/emitter/hitscan/magnetic/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	var/turf/turf_to_magnet = get_turf(target)
	goonchem_vortex(turf_to_magnet, FALSE, 4)

/obj/projectile/beam/emitter/hitscan/blast
	name = "hyperconcussive beam"
	light_color = LIGHT_COLOR_ORANGE
	muzzle_type = /obj/effect/projectile/muzzle/laser/emitter/magnetic
	tracer_type = /obj/effect/projectile/tracer/laser/emitter/magnetic
	impact_type = /obj/effect/projectile/impact/laser/emitter/magnetic
	hitscan_light_color_override = COLOR_ORANGE
	muzzle_flash_color_override = COLOR_ORANGE
	impact_light_color_override = COLOR_ORANGE
	damage = 0
	integrity_heal = -2
	energy_reduction = -500

/obj/projectile/beam/emitter/hitscan/blast/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	var/turf/turf_to_explode = get_turf(target)
	explosion(turf_to_explode, 0, 1, 2)

/obj/projectile/beam/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = 'sound/weapons/tap.ogg'
	nodamage = TRUE
	damage = 0
	damage_type = STAMINA
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	log_override = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_DARK_BLUE

/obj/projectile/beam/lasertag/on_hit(atom/target, blocked = 0)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.apply_damage(34, STAMINA)
	return 1

/obj/projectile/beam/lasertag/redtag
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = COLOR_SOFT_RED
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/projectile/beam/lasertag/redtag/hitscan
	hitscan = TRUE

/obj/projectile/beam/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

/obj/projectile/beam/lasertag/bluetag/hitscan
	hitscan = TRUE

/obj/projectile/beam/sniper
	name = "sniper beam"
	icon_state = "sniperlaser"
	//speed = 0.75
	//range = 100
	damage = 60
	hitsound = 'sound/weapons/resonator_blast.ogg'
	weaken = 4 SECONDS
	stutter = 4 SECONDS
	stamina = 40
	forced_accuracy = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_PINK

/obj/projectile/beam/podsniper/disabler
	name = "sniper disabler beam"
	icon_state = "LSR_disabler"
	damage = 40
	damage_type = STAMINA
	hitsound = 'sound/weapons/resonator_blast.ogg'
	flag = ENERGY
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_CYAN

/obj/projectile/beam/podsniper/laser
	name = "sniper laser beam"
	icon_state = "LSR_kill"
	damage = 45
	hitsound = 'sound/weapons/resonator_blast.ogg'

/obj/projectile/beam/immolator
	name = "immolation beam"
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	immolate = 2

/obj/projectile/beam/immolator/strong
	name = "heavy immolation beam"
	damage = 45
	icon_state = "heavylaser"
	immolate = 3

/obj/projectile/beam/immolator/weak
	name = "light immolation beam"
	damage = 8
	icon_state = "scatterlaser"
	immolate = 1

/obj/projectile/beam/immolator/weak/hitscan
	color = LIGHT_COLOR_FIRE
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	impact_type = /obj/effect/projectile/impact/laser
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_color_override = LIGHT_COLOR_FIRE
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = LIGHT_COLOR_FIRE
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = LIGHT_COLOR_FIRE

/obj/projectile/beam/immolator/mech
	name = "mecha immolation beam"
	damage = 15

/obj/projectile/beam/immolator/on_hit(atom/target, blocked = 0)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(1)
		M.IgniteMob()

/obj/projectile/beam/instakill
	name = "instagib laser"
	icon_state = "purple_laser"
	damage = 200
	hitsound = 'sound/weapons/resonator_blast.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_PURPLE

/obj/projectile/beam/instakill/blue
	icon_state = "blue_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_DARK_BLUE

/obj/projectile/beam/instakill/red
	icon_state = "red_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = COLOR_SOFT_RED

/obj/projectile/beam/instakill/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.visible_message(span_danger("[DECLENT_RU_CAP(L, NOMINATIVE)] взрывается!"))
		L.gib()

/obj/projectile/beam/dominator/eliminator
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	icon_state = "blue_laser"
	light_color = LIGHT_COLOR_LIGHT_CYAN
	damage = 20

/obj/projectile/beam/dominator/slaughter
	name = "execution slaughter beam"
	icon_state = "blue_laser"
	damage = 50
	stamina = 33
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_LIGHT_CYAN
	hitsound = 'sound/weapons/resonator_blast.ogg'
	hitsound_wall = 'sound/weapons/sear.ogg'

/obj/projectile/beam/dominator/paralyzer
	name = "paralyzer beam"
	icon_state = "omnilaser"
	shockbull = TRUE
	damage_type = STAMINA
	flag = ENERGY
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	hitsound_wall = 'sound/weapons/sear.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_LIGHT_CYAN

/obj/projectile/beam/anomaly
	name = "anomaly stabilizer beam"
	icon_state = "xray" // Looks mostly like "blue/red_laser" in green colour.
	damage = 0
	hitsound = 'sound/weapons/resonator_blast.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	/// The amount by which the stability of the anomaly changes upon impact.
	var/stability_delta = 0
	/// The distance the anomaly is pulled towards the shooter upon impact.
	var/pull_strength = 0
	/// The amount of time that beam increase the blocking of the anomaly's normal movement.
	var/move_block = 0
	/// The amount of time that beam increase the blocking of the anomaly's impulsive movement.
	var/move_impulces_block = 0
	/// The amount by which the strength of the anomaly's effects is temporarily reduced.
	var/anom_weaken = 0
	/// The moment at which the reduction in the effects of the anomaly will be reset.
	var/weaken_time = 0

/obj/projectile/beam/anomaly/on_hit(atom/target, blocked, hit_zone)
	if(!isanomaly(target))
		return ..()

	do_sparks(clamp(abs(stability_delta) * 2, TRUE, 10))
	var/obj/effect/anomaly/anomaly = target
	if(anomaly.tier != 4 || prob(50))
		anomaly.stability = clamp(anomaly.stability + stability_delta, 0, 100)

	anomaly.move_moment = max(world.time + move_block, anomaly.move_moment)
	anomaly.move_impulse_moment = max(world.time + move_impulces_block, anomaly.move_impulse_moment)
	if(anom_weaken)
		anomaly.weaken = anom_weaken
		anomaly.weaken_moment = world.time + weaken_time

	INVOKE_ASYNC(anomaly, TYPE_PROC_REF(/obj/effect/anomaly, go_to), get_turf(firer_source_atom), pull_strength)
	return TRUE

/obj/projectile/beam/anomaly/stabilizer
	name = "stabilizing beam"
	icon_state = "bluelaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/projectile/beam/anomaly/destabilizer
	name = "destabilizing beam"
	icon_state = "laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = COLOR_SOFT_RED

/obj/projectile/beam/laser/light/rat
	name = "clockwork energy laser"
	icon_state = "brasslaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/orange_laser

/obj/projectile/beam/laser/light/rat/prehit(atom/target)
	return ..()

/obj/projectile/beam/laser/accelerator
	name = "accelerator laser"
	icon_state = "scatterlaser"
	range = 255
	damage = 8
	armour_penetration = -35
	speed = 1
	tile_dropoff_penetration = -5
	var/size_per_tile = 0.1
	var/max_scale = 4

/obj/projectile/beam/laser/accelerator/Range()
	..()
	// Damage
	damage = min(damage + 4, 75)
	armour_penetration = min(armour_penetration, 25)

	// Transform
	transform = matrix()
	transform *= min(1 + (maximum_range - range) * size_per_tile, max_scale)

/**
 * This projectile deals burn damage to silicons and
 * applies a stamina regeneration block on hit.
 */
/**
 * Deals burn damage instead of stamina if the target is not human.
 * Applies stamina regenerate block on hit.
 */
/// Used in small swarmer turrets, is shooted three times
/// Used in big swarmer turrets
/// Used in mega-swarmer minigun
/// Basic projectile
/// Used in double shots
/// Applies knockdown on hit
/// How much of current charge is drained for energy guns.
#define ENERGYGUN_DRAIN_PERCENTAGE 0.25
/// How much of current charge is drained for ion carbines.
#define ION_ENERGYGUN_DRAIN_PERCENTAGE 0.5

/// Resets sybils, switches modes, unloads guns
/**
 * If target has a projectile gun, it either unloads the magazine,
 * or empties it fully.
 *
 * If it has an ion ammo type,
 */
/**
 * Proc used to handle energy gun sabotaging.
 *
 * Resets shooting mode to disabler, resets sibyls,
 * and discharges the battery.
 */
/**
 * Proc used to handle projectile gun sabotaging.
 *
 * If the gun has an internal magazine, it unloads the magazine fully.
 * Otherwise, unload the magazine instead.
 */
#undef ENERGYGUN_DRAIN_PERCENTAGE
#undef ION_ENERGYGUN_DRAIN_PERCENTAGE
