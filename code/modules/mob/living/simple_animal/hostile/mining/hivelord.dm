/mob/living/simple_animal/hostile/asteroid/hivelord
	name = "hivelord"
	desc = "Поистине чуждое создание — бесформенная масса неизвестной органики, постоянно пульсирующая. При атаке от него отделяются фрагменты, атакующие вместе с основным телом."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Hivelord"
	icon_living = "Hivelord"
	icon_aggro = "Hivelord_alert"
	icon_dead = "Hivelord_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	move_to_delay = 14
	ranged = 1
	vision_range = 5
	speed = 3
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	attacktext = "хлещет"
	speak_emote = list("телепатически вопит")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_message = "проходит сквозь странное тело"
	ranged_cooldown_time = 20
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	retreat_distance = 3
	minimum_distance = 3
	pass_flags = PASSTABLE
	butcher_results = list(/obj/item/organ/internal/regenerative_core = 1)
	var/brood_type = /mob/living/simple_animal/hostile/asteroid/hivelordbrood

/mob/living/simple_animal/hostile/asteroid/hivelord/get_ru_names()
	return alist(
		NOMINATIVE = "рой",
		GENITIVE = "роя",
		DATIVE = "рою",
		ACCUSATIVE = "рой",
		INSTRUMENTAL = "роем",
		PREPOSITIONAL = "рое",
	)

/mob/living/simple_animal/hostile/asteroid/hivelord/drop_loot(drop_loc)
	if(is_station_level(z))
		return

	return ..()

/mob/living/simple_animal/hostile/asteroid/hivelord/OpenFire(the_target)
	if(world.time >= ranged_cooldown)
		var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/A = new brood_type(loc)
		if(flags & ADMIN_SPAWNED)
			A.flags |= ADMIN_SPAWNED
		A.GiveTarget(target)
		A.friends = friends
		A.faction = faction.Copy()
		ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/asteroid/hivelord/AttackingTarget()
	OpenFire()
	return TRUE

/mob/living/simple_animal/hostile/asteroid/hivelord/spawn_crusher_loot()
	loot = loot.Copy()
	loot += crusher_loot //we don't butcher

/mob/living/simple_animal/hostile/asteroid/hivelord/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	mouse_opacity = MOUSE_OPACITY_ICON

//A fragile but rapidly produced creature
/mob/living/simple_animal/hostile/asteroid/hivelordbrood
	name = "hivelord brood"
	desc = "Фрагмент оригинала, действующий в унисон с ним. Один не опасен, но..."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Hivelordbrood"
	icon_living = "Hivelordbrood"
	icon_aggro = "Hivelordbrood"
	icon_dead = "Hivelordbrood"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	move_to_delay = 1
	friendly = "жужжит рядом"
	vision_range = 10
	speed = 3
	maxHealth = 1
	health = 1
	harm_intent_damage = 5
	melee_damage_lower = 2
	melee_damage_upper = 2
	attacktext = "кромсает"
	speak_emote = list("телепатически вопит")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_message = "проходит сквозь странное тело"
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	del_on_death = 1
	var/life_time = 10 SECONDS

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/get_ru_names()
	return alist(
		NOMINATIVE = "фрагмент роя",
		GENITIVE = "фрагмента роя",
		DATIVE = "фрагменту роя",
		ACCUSATIVE = "фрагмент роя",
		INSTRUMENTAL = "фрагментом роя",
		PREPOSITIONAL = "фрагменте роя",
	)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(death)), life_time)
	AddComponent(/datum/component/swarming)
	AddElement(/datum/element/simple_flying)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood
	name = "blood brood"
	desc = "Живая нить из крови и чужеродных материалов."
	icon_state = "bloodbrood"
	icon_living = "bloodbrood"
	icon_aggro = "bloodbrood"
	attacktext = "пронзает"
	color = BLOOD_COLOR_RED

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/get_ru_names()
	return alist(
		NOMINATIVE = "кровавый рой",
		GENITIVE = "кровавого роя",
		DATIVE = "кровавому рою",
		ACCUSATIVE = "кровавый рой",
		INSTRUMENTAL = "кровавым роем",
		PREPOSITIONAL = "кровавом рое",
	)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/death(gibbed)
	if(can_die() && loc)
		// Splash the turf we are on with blood
		reagents.reaction(get_turf(src))
	return ..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/Initialize(mapload)
	. = ..()
	create_reagents(30)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/AttackingTarget()
	..()
	if(iscarbon(target))
		transfer_reagents(target, 1)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/attack_hand(mob/living/carbon/human/M)
	if(PERSONAL_FACTION(M) in faction)
		reabsorb_host(M)
	else
		return ..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(PERSONAL_FACTION(M) in faction)
		reabsorb_host(M)
	else
		return ..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/proc/reabsorb_host(mob/living/carbon/C)
	C.visible_message(
		span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] поглощается телом [C.declent_ru(GENITIVE)]."), \
		span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] поглощается вашим телом.")
	)
	transfer_reagents(C)
	death()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/proc/transfer_reagents(mob/living/carbon/C, volume = 30)
	if(!reagents.total_volume)
		return

	volume = min(volume, reagents.total_volume)

	var/fraction = min(volume/reagents.total_volume, 1)
	reagents.reaction(C, REAGENT_INGEST, fraction)
	reagents.trans_to(C, volume)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/proc/link_host(mob/living/carbon/C)
	faction = list(PERSONAL_FACTION(src), PERSONAL_FACTION(C)) // Hostile to everyone except the host.
	C.transfer_blood_to(src, 30)
	color = mix_color_from_reagents(reagents.reagent_list)

//Legion
