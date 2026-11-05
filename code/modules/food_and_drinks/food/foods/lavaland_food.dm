/obj/item/reagent_containers/food/snacks/lavaland
	gender = MALE
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	lefthand_file = 'icons/mob/inhands/lavaland/fish_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_items_righthand.dmi'
	item_state = "food"
	var/overlay_sprite
	list_reagents = list("nutriment" = 2, "vitamin" = 4, "protein" = 2)

/obj/item/reagent_containers/food/snacks/lavaland/soft_meat
	name = "soft meat cut"
	desc = "A tender lava fish fillet. Currently raw, but the right ingredients could turn it into a wonderful dish."
	gender = FEMALE
	icon_state = "soft_meat_cut"
	item_state = "soft_meat_cut"
	list_reagents = list("nutriment" = 1, "vitamin" = 3, "protein" = 3)
	filling_color = "#D49284"
	tastes = list("сырого мяса" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/lavaland/eel_filet
	name = "eel filet"
	desc = "A raw bottom-dwelling eel fillet. Edible as it is, but the right ingredients could turn it into a wonderful dish."
	gender = NEUTER
	icon_state = "eel_filet"
	item_state = "eel_filet"
	list_reagents = list("nutriment" = 2, "menthol" = 3, "protein" = 4)
	filling_color = "#414F71"
	tastes = list("сырого мяса" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/lavaland/predator_meat
	name = "predatory fish slice"
	desc = "A fairly large cut of predatory fish meat. Not recommended raw."
	icon_state = "predatory_fish_slice"
	item_state = "predatory_fish_slice"
	list_reagents = list("nutriment" = 2, "toxin" = 2, "protein" = 4)
	bitesize = 3
	filling_color = "#BE7C64"
	tastes = list("очень горького мяса" = 1)
	foodtype = MEAT | TOXIC | RAW

/obj/item/reagent_containers/food/snacks/lavaland/soft_meat_cubes
	name = "soft meat cubes"
	desc = "Fish fillet cut into small cubes and oven-roasted. Looks appetizing."
	gender = PLURAL
	icon = 'icons/obj/lavaland/lavaland_food.dmi'
	icon_state = "soft_meat_cubes"
	list_reagents = list("nutriment" = 2, "vitamin" = 3, "protein" = 3)
	bitesize = 3
	filling_color = "#BE7C64"
	tastes = list("нежного мяса" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/predatory_fish_slab
	name = "cooked predatory fish slab"
	desc = "A cut of predatory fish meat roasted in an oven. Ready to eat."
	icon = 'icons/obj/lavaland/lavaland_food.dmi'
	icon_state = "predatory_fish_slab"
	list_reagents = list("nutriment" = 4, "protein" = 6)
	bitesize = 3
	filling_color = "#BE7C64"
	tastes = list("мяса" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/eel_ringlets
	name = "eel ringlets"
	desc = "Oven-roasted bottom-dwelling eel fillet. Incredibly tasty."
	gender = PLURAL
	icon = 'icons/obj/lavaland/lavaland_food.dmi'
	icon_state = "eel_ringlets"
	list_reagents = list("nutriment" = 4, "protein" = 6)
	bitesize = 3
	filling_color = "#BE7C64"
	tastes = list("нежного мяса" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bacon
	name = "thali lazis bacon part"
	desc = "A small serving of bacon from a Thali Lazis platter."
	icon = 'icons/obj/lavaland/lavaland_food.dmi'
	icon_state = "thali_lazis_bacon"
	overlay_sprite = "thali_lazis_bacon_overlay"
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_cacti
	name = "thali lazis cacti part"
	desc = "A small cactus from a Thali Lazis platter."
	icon = 'icons/obj/lavaland/lavaland_food.dmi'
	icon_state = "thali_lazis_cacti"
	overlay_sprite = "thali_lazis_cacti_overlay"
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_wing
	name = "thali lazis wing part"
	desc = "A small wing from a Thali Lazis platter."
	icon = 'icons/obj/lavaland/lavaland_food.dmi'
	icon_state = "thali_lazis_wing"
	overlay_sprite = "thali_lazis_wing_overlay"
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_fish
	name = "thali lazis fish part"
	desc = "A small serving of fish from a Thali Lazis platter."
	icon = 'icons/obj/lavaland/lavaland_food.dmi'
	icon_state = "thali_lazis_fish"
	overlay_sprite = "thali_lazis_fish_overlay"
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_crunchie
	name = "thali lazis crunchie part"
	desc = "A small crunchy portion from a Thali Lazis platter."
	icon = 'icons/obj/lavaland/lavaland_food.dmi'
	icon_state = "thali_lazis_crunchie"
	overlay_sprite = "thali_lazis_crunchie_overlay"
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bungus
	name = "thali lazis bungus part"
	desc = "A small serving of mushrooms from a Thali Lazis platter."
	icon = 'icons/obj/lavaland/lavaland_food.dmi'
	icon_state = "thali_lazis_bungus"
	overlay_sprite = "thali_lazis_bungus_overlay"
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/lavaland_food
	name = "generic lavaland food"
	desc = "An entirely ordinary dish. If you can see this, Zyuzya messed up."
	icon = 'icons/obj/lavaland/lavaland_food.dmi'
	icon_state = "fine_meal"
	lefthand_file = 'icons/mob/inhands/lavaland/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/food_righthand.dmi'
	item_state = "food"
	bitesize = 100 //eat whole thing down
	list_reagents = list("nutriment" = 6, "protein" = 6)
	tastes = list("вкусной еды" = 1)
	has_special_eating_effects = TRUE
	eat_time = 5 SECONDS
	foodtype = MEAT
/obj/item/reagent_containers/food/snacks/lavaland_food/fine_meal
	name = "fine meal"
	desc = "Goliath meat roasted in cactus fruit juice. Incredibly tasty and nutritious."
	gender = FEMALE
	list_reagents = list("vitfro" = 6, "protein" = 7, "vitamin" = 3)
	tastes = list("сбалансированной еды" = 1)
	foodtype = MEAT|FRUIT

/obj/item/reagent_containers/food/snacks/lavaland_food/fine_meal/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_FORCED_RUMBLE)

/obj/item/reagent_containers/food/snacks/lavaland_food/freaky_leg
	name = "freaky leg"
	desc = "Many peoples of the galaxy consider eating their own kind a terrible crime. These feet are awfully nutritious, though..."
	icon_state = "freaky_leg"
	tastes = list("тяжёлых времён" = 1)

/obj/item/reagent_containers/food/snacks/lavaland_food/freaky_leg/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_NO_PAIN)

/obj/item/reagent_containers/food/snacks/lavaland_food/veggie_meal
	name = "veggie meal"
	desc = "Ash walkers usually eat local wildlife, but mixing the right ingredients produces a very healthy vegetable dish. It does not taste particularly good."
	icon_state = "veggie_meal"
	list_reagents = list("spaceacillin" = 10, "lavaland_extract" = 2, "vitfro" = 20, "sal_acid" = 15)
	tastes = list("трав" = 1)
	foodtype = FRUIT|VEGETABLES

/obj/item/reagent_containers/food/snacks/lavaland_food/veggie_meal/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_FORCED_SNEEZE)

/obj/item/reagent_containers/food/snacks/lavaland_food/hunters_treat
	name = "hunter's treat"
	desc = "A human heart roasted in Goliath meat juices. Legend says eating a defeated enemy's heart grants incredible strength."
	icon_state = "hunters_treat"

/obj/item/reagent_containers/food/snacks/lavaland_food/hunters_treat/on_mob_eating_effect(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		human.force_gene_block(GLOB.strongblock, TRUE)

/obj/item/reagent_containers/food/snacks/lavaland_food/yum_grub
	name = "yum-grub"
	desc = "Goldgrub meat roasted with mushrooms. Said to benefit the nervous system and sensory organs."
	icon_state = "yum_grub"
	list_reagents = list("oculine" = 12, "mannitol" = 12, "vitamin" = 3)
/obj/item/reagent_containers/food/snacks/lavaland_food/ashie_kebab
	name = "ashie-kebab"
	desc = "Several vital organs crudely removed and skewered on an iron rod. As primitive as it is delicious!"
	icon_state = "ashie_kebab"
	item_state = "ashie_kebab"
	list_reagents = list("nutriment" = 6, "protein" = 6, "ephedrine" = 10)

/obj/item/reagent_containers/food/snacks/lavaland_food/ashie_kebab/on_mob_eating_effect(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		human.add_blood()

/obj/item/reagent_containers/food/snacks/lavaland_food/tail_o_dead
	name = "tail'o'dead"
	desc = "A massive unathi tail baked in cactus fruit juice. Looks appetizing!"
	icon_state = "tail_o_dead"

/obj/item/reagent_containers/food/snacks/lavaland_food/tail_o_dead/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_VISION)

/obj/item/reagent_containers/food/snacks/lavaland_food/cure_curse
	name = "cure curse"
	desc = "Two pierced hearts, one of them cursed. What could go wrong?"
	icon_state = "cure_curse"
	var/active = FALSE

/obj/item/reagent_containers/food/snacks/lavaland_food/cure_curse/examine(mob/user)
	. = ..()
	if(active)
		. += span_notice("Проклятое сердце бьётся.")
	else
		. += span_danger("Проклятое сердце неподвижно.")

/obj/item/reagent_containers/food/snacks/lavaland_food/cure_curse/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][active ? "_active" : ""]"

/obj/item/reagent_containers/food/snacks/lavaland_food/cure_curse/on_mob_eating_effect(mob/user)
	if(!active)
		return
	if(isliving(user))
		var/mob/living/living_user = user
		if(!living_user.get_int_organ(/obj/item/organ/internal/regenerative_core/legion))
			new /obj/item/organ/internal/regenerative_core/legion/pre_preserved(living_user)

/obj/item/reagent_containers/food/snacks/lavaland_food/wings_n_fangs_n_tentacles
	name = "wings'n'fangs'n'tentacles"
	desc = "A Goliath tentacle, a watcher wing and a weaver mandible baked together. Tastes just as awful as it looks."
	icon_state = "wings_n_fangs_n_tentacles"

/obj/item/reagent_containers/food/snacks/lavaland_food/wings_n_fangs_n_tentacles/on_mob_eating_effect(mob/user)
	if(isunathi(user))
		var/mob/living/carbon/human/human_unathi = user
		var/obj/item/organ/internal/cyberimp/tail/blade/organic_upgrade/tumour = human_unathi.get_organ_slot(INTERNAL_ORGAN_TAIL_DEVICE)
		if(!tumour)
			tumour = new
			to_chat(human_unathi, span_warning("Вы чувствуете сильное покалывание в вашем хвосте."))
			tumour.insert(human_unathi)

/obj/item/reagent_containers/food/snacks/lavaland_food/goli_kernels
	name = "goli-kernels"
	desc = "A small meatball served on a mushroom-cap platter. Delicious!"
	icon_state = "goli_kernels"
	list_reagents = list("nutriment" = 2, "protein" = 2)
	eat_time = 0 SECONDS

/obj/item/reagent_containers/food/snacks/lavaland_food/goli_kernels/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()

	if(..() || !ishuman(hit_atom))//if it gets caught or the target aren't human
		return TRUE	//abort

	var/mob/living/carbon/human/target = hit_atom
	target.eat(src, target)
	qdel(src)

/obj/item/reagent_containers/food/snacks/lavaland_food/grace_of_lazis
	name = "grace of lazis portion"
	desc = "A cut of meat carved from a massive monument to a glorious hunt. Incredibly tasty."
	gender = FEMALE
	icon_state = "grace_of_lazis"
	list_reagents = list("protein" = 4, "vitamin" = 2)
	eat_time = 0 SECONDS

/obj/item/reagent_containers/food/snacks/lavaland_food/beer_grub_stew
	name = "beer grub stew"
	desc = "An alcoholic stew made with goldgrub meat. Nutritious!"
	icon_state = "beer_grub_stew"
	list_reagents = list("nutriment" = 4, "protein" = 6, "beer" = 7)

/obj/item/reagent_containers/food/snacks/lavaland_food/beer_grub_stew/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_TEMPERATURE_STABILIZE)

/obj/item/reagent_containers/food/snacks/lavaland_food/thick_red_paste
	name = "thick red paste"
	desc = "A disgusting, viscous red paste made from scraps of bodies. Tastes utterly revolting."
	gender = FEMALE
	icon_state = "thick_red_paste"
	list_reagents = list("protein" = 2)

/obj/item/reagent_containers/food/snacks/lavaland_food/thick_red_paste/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_ETERNAL_BLEEDING_FIX)

/obj/item/reagent_containers/food/snacks/lavaland_food/black_blood_sausage
	name = "black blood sausage"
	desc = "A small blood sausage made from Goliath meat and... actual blood. Extremely useful when you are in critical condition."
	gender = FEMALE
	icon_state = "black_blood_sausage"
	item_state = "black_blood_sausage"
	list_reagents = list("nutriment" = 10, "protein" = 3)

/obj/item/reagent_containers/food/snacks/lavaland_food/xeno_sticks
	name = "xeno sticks"
	desc = "Xenomorph meat on sticks, garnished with reishi mushrooms. Surprisingly tasty!"
	gender = PLURAL
	icon_state = "xeno_sticks"
	item_state = "xeno_sticks"

/obj/item/reagent_containers/food/snacks/lavaland_food/xeno_sticks/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_NIGHT_VISION)

/obj/item/reagent_containers/food/snacks/lavaland_food/filet_madras
	name = "filet madras"
	desc = "Tender fish fillet roasted with mushrooms. Incredibly tasty."
	icon_state = "filet_madras"
	list_reagents = list("nutriment" = 3, "protein" = 2, "pen_acid" = 4)

/obj/item/reagent_containers/food/snacks/lavaland_food/eel_katigo
	name = "eel katigo"
	desc = "Bottom-dwelling eel fillet with herbal seasoning and a sauce made from assorted meat scraps. Nutritious!"
	icon_state = "eel_katigo"
	list_reagents = list("nutriment" = 3, "protein" = 2, "nicotine" = 6, "menthol" = 15)

/obj/item/reagent_containers/food/snacks/lavaland_food/predatory_chowder
	name = "predatory chowder"
	desc = "A soup made with fish, seasonings and human organs. Tasty!"
	icon_state = "predatory_chowder"
	list_reagents = list("nutriment" = 3, "protein" = 2, "godblood" = 20)

/obj/item/reagent_containers/food/snacks/lavaland_food/abu_ghosh
	name = "abu ghosh"
	desc = "A soup made with gathlatch milk and local ingredients. Delicious!"
	icon_state = "abu_ghosh"

/obj/item/reagent_containers/food/snacks/lavaland_food/abu_ghosh/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_BLOOD_REGEN)

/obj/item/storage/lava_tray
	name = "thali lazis plate"
	desc = "A large wooden tray for holding enormous quantities of food."
	gender = MALE
	icon = 'icons/obj/lavaland/lavaland_food.dmi'
	icon_state = "thali_lazis_plate"
	flags = NONE
	materials = null
	can_hold = list(
		/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bacon,
		/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_cacti,
		/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_wing,
		/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_fish,
		/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_crunchie,
		/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bungus,
	)
	display_contents_with_number = TRUE
	storage_slots = 12
	max_combined_w_class = 30

/obj/item/storage/lava_tray/update_overlays()
	. = ..()
	for(var/obj/item/reagent_containers/food/snacks/lavaland/snack in contents)
		. += mutable_appearance(icon = snack.icon, icon_state = snack.overlay_sprite)

/obj/item/storage/lava_tray/full/populate_contents()
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bacon(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_cacti(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_wing(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_fish(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_crunchie(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bungus(src)
	update_icon(UPDATE_OVERLAYS)
