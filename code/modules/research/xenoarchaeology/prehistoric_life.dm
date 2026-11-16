/// Extinct species recovered by fossil reconstitution (see reconstitution.dm).
/// Creature and produce sprites come from the historical ATMTA xenoarchaeology assets.

// Fauna

/mob/living/simple_animal/hostile/prehistoric
	abstract_type = /mob/living/simple_animal/hostile/prehistoric
	icon = 'icons/mob/animal.dmi'
	speak_chance = 5
	turns_per_move = 4
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 2)
	gold_core_spawnable = NO_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/hostile/prehistoric/samak
	name = "samak"
	desc = "A fast, armoured predator that once ambushed prey in frozen terrain. Its plated hide shrugs off light blows."
	icon_state = "samak"
	icon_living = "samak"
	icon_dead = "samak_dead"
	faction = list("samak")
	move_to_delay = 2
	maxHealth = 125
	health = 125
	melee_damage_lower = 5
	melee_damage_upper = 15
	obj_damage = 30
	attacktext = "mauls"
	speak = list("Hruuugh!", "Hrunnph")
	emote_see = list("paws the ground", "shakes its mane", "stomps")
	emote_hear = list("snuffles")
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 4)

/mob/living/simple_animal/hostile/prehistoric/diyaab
	name = "diyaab"
	desc = "A small pack animal. Although omnivorous, it hunts for meat on occasion."
	icon_state = "diyaab"
	icon_living = "diyaab"
	icon_dead = "diyaab_dead"
	faction = list("diyaab")
	move_to_delay = 1
	maxHealth = 25
	health = 25
	melee_damage_lower = 1
	melee_damage_upper = 8
	attacktext = "gouges"
	speak = list("Awrr?", "Aowrl!", "Worrl")
	emote_see = list("sniffs the air cautiously", "looks around")
	emote_hear = list("snuffles")
	mob_size = MOB_SIZE_SMALL
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 1)

/mob/living/simple_animal/hostile/prehistoric/shantak
	name = "shantak"
	desc = "A piglike creature with a bright iridescent mane that sparkles as though lit from within. Do not let its beauty fool you."
	icon_state = "shantak"
	icon_living = "shantak"
	icon_dead = "shantak_dead"
	faction = list("shantak")
	move_to_delay = 1
	maxHealth = 75
	health = 75
	melee_damage_lower = 3
	melee_damage_upper = 12
	attacktext = "gouges"
	speak = list("Shuhn", "Shrunnph?", "Shunpf")
	emote_see = list("scratches the ground", "shakes out its mane", "tinkles gently")
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_CYAN

/mob/living/simple_animal/prehistoric
	abstract_type = /mob/living/simple_animal/prehistoric
	icon = 'icons/mob/animal.dmi'
	speak_chance = 3
	turns_per_move = 5
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 2)
	gold_core_spawnable = NO_SPAWN
	can_collar = TRUE

/mob/living/simple_animal/prehistoric/yithian
	name = "yithian"
	desc = "A friendly creature vaguely resembling an oversized snail without a shell."
	icon_state = "yithian"
	icon_living = "yithian"
	icon_dead = "yithian_dead"
	maxHealth = 40
	health = 40
	turns_per_move = 9
	speak_emote = list("burbles")
	emote_see = list("waves its eyestalks", "leaves a glistening trail")
	emote_hear = list("burbles softly")

/mob/living/simple_animal/prehistoric/tindalos
	name = "tindalos"
	desc = "It looks like a large, flightless grasshopper."
	icon_state = "tindalos"
	icon_living = "tindalos"
	icon_dead = "tindalos_dead"
	maxHealth = 30
	health = 30
	turns_per_move = 2
	speak_emote = list("chirps")
	emote_see = list("rubs its hind legs together", "hops in place")
	emote_hear = list("chirps")
	mob_size = MOB_SIZE_SMALL

// Flora

/obj/item/seeds/prehistoric
	abstract_type = /obj/item/seeds/prehistoric
	growing_icon = 'icons/obj/hydroponics/prehistoric.dmi'
	rarity = 30
	/// Grade of the genome this packet was synthesised from.
	var/reconstitution_grade

/// Sample quality shifts the starting stats of the synthesised seeds.
/obj/item/seeds/prehistoric/proc/apply_fidelity(fidelity)
	reconstitution_grade = fossil_grade(fidelity)
	switch(reconstitution_grade)
		if("pristine")
			set_potency(potency + 15)
			set_yield(yield + 1)
			set_endurance(endurance + 10)
		if("unstable")
			set_potency(potency - 5)
			set_yield(yield - 1)
			set_lifespan(lifespan - 10)
	desc += " The label reads: [reconstitution_grade] genome."

/obj/item/reagent_containers/food/snacks/grown/prehistoric
	abstract_type = /obj/item/reagent_containers/food/snacks/grown/prehistoric
	icon = 'icons/obj/xenoarchaeology.dmi'
	bitesize_mod = 2

/obj/item/seeds/prehistoric/telriis
	name = "pack of telriis seeds"
	desc = "Reconstituted seeds of an extinct grass. They grow into tough, wine-scented tufts."
	species = "telriis"
	icon = 'icons/obj/hydroponics/prehistoric.dmi'
	icon_state = "seed-telriis"
	plantname = "Telriis Grass"
	product = /obj/item/reagent_containers/food/snacks/grown/prehistoric/telriis
	lifespan = 50
	endurance = 50
	maturation = 5
	production = 5
	yield = 4
	growthstages = 2
	reagents_add = list("wine" = 0.2, "plantmatter" = 0.04)

/obj/item/reagent_containers/food/snacks/grown/prehistoric/telriis
	seed = /obj/item/seeds/prehistoric/telriis
	name = "telriis grass"
	desc = "A clump of telriis grass, not recommended for consumption by sentients. It smells faintly of fermented fruit."
	icon_state = "telriisclump"
	filling_color = "#3C6B4F"
	tastes = list("sour grass" = 1)
	distill_reagent = "wine"

/obj/item/seeds/prehistoric/thaadra
	name = "pack of thaa'dra spores"
	desc = "Reconstituted spores of an extinct lichen that thrived on frozen rock."
	species = "thaadra"
	icon = 'icons/obj/hydroponics/prehistoric.dmi'
	icon_state = "seed-thaadra"
	plantname = "Thaa'dra Lichen"
	product = /obj/item/reagent_containers/food/snacks/grown/prehistoric/thaadra
	lifespan = 20
	endurance = 10
	maturation = 5
	production = 9
	yield = 2
	growthstages = 4
	reagents_add = list("frostoil" = 0.2, "plantmatter" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/prehistoric/thaadra
	seed = /obj/item/seeds/prehistoric/thaadra
	name = "thaa'dra bloom"
	desc = "Looks chewy and is cold to the touch."
	icon_state = "thaadrabloom"
	filling_color = "#E8C8F0"
	tastes = list("frost" = 1)

/obj/item/seeds/prehistoric/jurlmah
	name = "pack of jurl'mah seeds"
	desc = "Reconstituted seeds of an extinct reed with strange, pulsing pods."
	species = "jurlmah"
	icon = 'icons/obj/hydroponics/prehistoric.dmi'
	icon_state = "seed-jurlmah"
	plantname = "Jurl'mah Reeds"
	product = /obj/item/reagent_containers/food/snacks/grown/prehistoric/jurlmah
	lifespan = 20
	endurance = 12
	maturation = 8
	production = 9
	yield = 3
	growthstages = 3
	reagents_add = list("space_drugs" = 0.15, "plantmatter" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/prehistoric/jurlmah
	seed = /obj/item/seeds/prehistoric/jurlmah
	name = "jurl'mah pod"
	desc = "Bulbous and veiny, it appears to pulse slightly as you look at it."
	icon_state = "jurlmahpod"
	filling_color = "#3FC9D8"
	tastes = list("something alive" = 1)

/obj/item/seeds/prehistoric/amauri
	name = "pack of amauri seeds"
	desc = "Reconstituted seeds of an extinct plant with fiercely hot fruit."
	species = "amauri"
	icon = 'icons/obj/hydroponics/prehistoric.dmi'
	icon_state = "seed-amauri"
	plantname = "Amauri Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/prehistoric/amauri
	lifespan = 30
	endurance = 10
	maturation = 8
	production = 9
	yield = 4
	growthstages = 6
	reagents_add = list("condensedcapsaicin" = 0.15, "plantmatter" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/prehistoric/amauri
	seed = /obj/item/seeds/prehistoric/amauri
	name = "amauri fruit"
	desc = "It is small, round and hard. Its skin is a thick dark purple."
	icon_state = "amaurifruit"
	filling_color = "#3B1C5A"
	tastes = list("fire" = 1)

/obj/item/seeds/prehistoric/gelthi
	name = "pack of gelthi seeds"
	desc = "Reconstituted seeds of an extinct berry plant with numbing, fiery fruit."
	species = "gelthi"
	icon = 'icons/obj/hydroponics/prehistoric.dmi'
	icon_state = "seed-gelthi"
	plantname = "Gelthi Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/prehistoric/gelthi
	lifespan = 20
	endurance = 15
	maturation = 6
	production = 6
	yield = 2
	growthstages = 6
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("morphine" = 0.08, "capsaicin" = 0.1, "plantmatter" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/prehistoric/gelthi
	seed = /obj/item/seeds/prehistoric/gelthi
	name = "gelthi berries"
	desc = "They feel fluffy and slightly warm to the touch."
	icon_state = "gelthiberries"
	gender = PLURAL
	filling_color = "#E0603C"
	tastes = list("warm fuzz" = 1)

/obj/item/seeds/prehistoric/vale
	name = "pack of vale seeds"
	desc = "Reconstituted seeds of an extinct medicinal shrub."
	species = "vale"
	icon = 'icons/obj/hydroponics/prehistoric.dmi'
	icon_state = "seed-vale"
	plantname = "Vale Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/prehistoric/vale
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 10
	yield = 3
	growthstages = 5
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("sal_acid" = 0.1, "salbutamol" = 0.08, "plantmatter" = 0.04)

/obj/item/reagent_containers/food/snacks/grown/prehistoric/vale
	seed = /obj/item/seeds/prehistoric/vale
	name = "vale leaves"
	desc = "Small, curly leaves covered in a soft pale fur."
	icon_state = "valeleaves"
	gender = PLURAL
	filling_color = "#F0B8D8"
	tastes = list("fuzzy herbs" = 1)

/obj/item/seeds/prehistoric/surik
	name = "pack of surik seeds"
	desc = "Reconstituted seeds of an extinct vine whose fruit calms the mind."
	species = "surik"
	icon = 'icons/obj/hydroponics/prehistoric.dmi'
	icon_state = "seed-surik"
	plantname = "Surik Vine"
	product = /obj/item/reagent_containers/food/snacks/grown/prehistoric/surik
	lifespan = 30
	endurance = 20
	maturation = 7
	production = 8
	yield = 3
	growthstages = 1
	reagents_add = list("haloperidol" = 0.1, "synaptizine" = 0.06, "plantmatter" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/prehistoric/surik
	seed = /obj/item/seeds/prehistoric/surik
	name = "surik fruit"
	desc = "Multiple layers of blue skin peel away to reveal a spongy core that vaguely resembles an ear."
	icon_state = "surikfruit"
	filling_color = "#3C5AD8"
	tastes = list("cold sponge" = 1)
