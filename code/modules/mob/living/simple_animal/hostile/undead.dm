// This is important
/mob/living/attack_ghost(mob/dead/observer/user)
	if(prob(80)) return ..()
	var/found = 0
	for(var/mob/living/simple_animal/hostile/R in range(4,src))
		if(!R.retaliate_only)
			continue
		if(R.faction != "undead" || R == src || prob(50)) continue
		found = 1
		R.enemies ^= src
		if(src in R.enemies)
			R.visible_message("[R]'s head swivels eerily towards [src].")
		else
			R.visible_message("[R] stares at [src] for a minute before turning away.")
			if(R.target == src)
				R.GiveTarget(null)
	if(!found)
		return ..()

/mob/living/simple_animal/hostile/ghost
	icon = 'icons/mob/mob.dmi'
	name = "ghost"
	icon_state = "ghost2"
	icon_living = "ghost2"
	icon_dead = "ghost"
	density = FALSE // ghost
	invisibility = 60 // no seriously ghost

	response_help = "passes through" // by the way ghost
	response_disarm = "shoves"
	response_harm = "hits"
	turns_per_move = 10
	speed = 0

	emote_taunt = list("воет")
	taunt_chance = 20

	harm_intent_damage = 10
	melee_damage_lower = 2
	melee_damage_upper = 3
	attacktext = "сжимает"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	pressure_resistance = 300
	faction = list("undead") // did I mention ghost
	loot = list(/obj/item/reagent_containers/food/snacks/ectoplasm)
	del_on_death = 1

/mob/living/simple_animal/hostile/ghost/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/ghost/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)

/mob/living/simple_animal/hostile/ghost/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE

/mob/living/simple_animal/hostile/ghost/Life(seconds, times_fired)
	if(target)
		invisibility = pick(0,0,60,invisibility)
	else
		invisibility = pick(0,60,60,invisibility)
	..()

/mob/living/simple_animal/hostile/skeleton
	name = "reanimated skeleton"
	desc = "Настоящий костлявый скелет, не похоже, что он хочет общаться."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "skeleton"
	icon_living = "skeleton"
	turns_per_move = 5
	response_help = "пожимает руку"
	response_harm = "бьёт"
	speak_emote = list("бряцает", "трещит")
	emote_see = list("бряцает", "трещит")
	maxHealth = 40
	health = 40
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	healable = FALSE //they're skeletons how would bruise packs help them??
	attacktext = "бьёт"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	robust_searching = TRUE
	stat_attack = UNCONSCIOUS
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list("undead")
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	deathmessage = "превращается в груду костей!"
	del_on_death = TRUE
	loot = list(/obj/effect/decal/remains/human)

/mob/living/simple_animal/hostile/skeleton/get_ru_names()
	return alist(
		NOMINATIVE = "оживший скелет",
		GENITIVE = "ожившего скелета",
		DATIVE = "ожившему скелету",
		ACCUSATIVE = "ожившего скелета",
		INSTRUMENTAL = "ожившим скелетом",
		PREPOSITIONAL = "ожившем скелете",
	)

/mob/living/simple_animal/hostile/skeleton/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = 1500, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/skeleton/eskimo
	name = "undead eskimo"
	desc = "The reanimated remains of some poor traveler."
	icon_state = "eskimo"
	icon_living = "eskimo"
	maxHealth = 55
	health = 55
	weather_immunities = list(TRAIT_SNOWSTORM_IMMUNE)
	gold_core_spawnable = NO_SPAWN
	melee_damage_lower = 17
	melee_damage_upper = 20
	faction = list("undead", "winter")
	deathmessage = "collapses into a pile of bones, its gear falling to the floor!"
	loot = list(
		/obj/effect/decal/remains/human,
		/obj/item/twohanded/spear,
		/obj/item/clothing/shoes/winterboots,
		/obj/item/clothing/suit/hooded/wintercoat,
	)
