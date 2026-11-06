/obj/projectile/energy/electrode
	name = "electrode"
	color = COLOR_YELLOW
	shockbull = TRUE
	nodamage = TRUE
	confused = 2.5 SECONDS
	stun = 5 SECONDS
	weaken = 5 SECONDS
	stutter = 8 SECONDS
	jitter = 30 SECONDS
	hitsound = 'sound/weapons/tase.ogg'
	range = 6
	tracer_type = /obj/effect/projectile/tracer/stun
	muzzle_type = /obj/effect/projectile/muzzle/stun
	impact_type = /obj/effect/projectile/impact/stun

/obj/projectile/energy/electrode/on_hit(atom/target, blocked = 0)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, TRUE, src)
		return
	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon = target
	if(HAS_TRAIT(carbon, TRAIT_HULK))
		return
	if(carbon.status_flags & CANWEAKEN)
		if(carbon.buckled && istype(carbon.buckled, /obj/vehicle/ridden))
			carbon.buckled.unbuckle_mob(carbon, TRUE)
		addtimer(CALLBACK(carbon, TYPE_PROC_REF(/mob/living/carbon, Jitter), jitter), 0.5 SECONDS)

/obj/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	do_sparks(1, TRUE, src)
	return ..()

/obj/projectile/energy/electrode/dominator
	color = LIGHT_COLOR_LIGHT_CYAN

/obj/projectile/energy/electrode/advanced
	stun = 10 SECONDS
	weaken =  10 SECONDS
