//A beast that fire freezing blasts.
/mob/living/simple_animal/hostile/asteroid/basilisk
	name = "basilisk"
	desc = "Территориальный зверь, покрытый толстой энергопоглощающей бронёй. Его взгляд заставляет жертв замерзать изнутри."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_aggro = "Basilisk_alert"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 20
	projectiletype = /obj/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "смотрит"
	speed = 3
	maxHealth = 200
	health = 200
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "вгрызается в"
	speak_emote = list("стрекочет")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	turns_per_move = 5
	gold_core_spawnable = HOSTILE_SPAWN
	loot = list(/obj/item/stack/ore/diamond{layer = ABOVE_MOB_LAYER},
				/obj/item/stack/ore/diamond{layer = ABOVE_MOB_LAYER})

/mob/living/simple_animal/hostile/asteroid/basilisk/get_ru_names()
	return alist(
		NOMINATIVE = "базилиск",
		GENITIVE = "базилиска",
		DATIVE = "базилиску",
		ACCUSATIVE = "базилиска",
		INSTRUMENTAL = "базилиском",
		PREPOSITIONAL = "базилиске",
	)

/mob/living/simple_animal/hostile/asteroid/basilisk/GiveTarget(new_target)
	if(..()) //we have a target
		if(isliving(target) && !target.Adjacent(targets_from) && ranged_cooldown <= world.time)//No more being shot at point blank or spammed with RNG beams
			OpenFire(target)

/mob/living/simple_animal/hostile/asteroid/basilisk/ex_act(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()
		if(EXPLODE_HEAVY)
			adjustBruteLoss(140)
		if(EXPLODE_LIGHT)
			adjustBruteLoss(110)

//Watcher
