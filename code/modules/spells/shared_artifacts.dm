// Shared magic items, furniture and visuals used independently of mining.
/obj/item/melee/ghost_sword
	name = "spectral blade"
	desc = "A rusted and dulled blade. It doesn't look like it'd do much damage."
	icon_state = "spectral"
	item_state = "spectral"
	flags = CONDUCT
	sharp = 1
	w_class = WEIGHT_CLASS_BULKY
	force = 1
	throwforce = 1
	embed_chance = 25
	embedded_ignore_throwspeed_threshold = TRUE
	hitsound = 'sound/effects/ghost2.ogg'
	attack_verb = list("атаковал", "полоснул", "уколол", "поранил")
	var/summon_cooldown = 0
	var/list/mob/dead/observer/spirits

/obj/item/melee/ghost_sword/Initialize(mapload)
	. = ..()
	spirits = list()
	START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src

/obj/item/melee/ghost_sword/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		swing_sound = SFX_BLADE_SWING_LIGHT \
	)

/obj/item/melee/ghost_sword/Destroy()
	for(var/mob/dead/observer/G in spirits)
		G.invisibility = initial(G.invisibility)
	spirits.Cut()
	STOP_PROCESSING(SSobj, src)
	GLOB.poi_list -= src
	. = ..()

/obj/item/melee/ghost_sword/attack_self(mob/user)
	if(summon_cooldown > world.time)
		to_chat(user, "Вы недавно уже призывали помощь. Не стоит раздражать духов.")
		return
	to_chat(user, "Вы взываете о помощи, пытаясь призвать духов на свою сторону.")

	notify_ghosts("[user] поднима[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)], взывая о вашей помощи!", enter_link="<a href='byond://?src=[UID()];follow=1'>(Нажмите, чтобы помочь)</a>", source = user, action = NOTIFY_FOLLOW)

	summon_cooldown = world.time + 600

/obj/item/melee/ghost_sword/Topic(href, href_list)
	if(href_list["follow"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/item/melee/ghost_sword/process()
	ghost_check()

/obj/item/melee/ghost_sword/proc/ghost_check()
	var/ghost_counter = 0
	var/turf/T = get_turf(src)
	var/list/contents = T.get_all_contents()
	var/mob/dead/observer/current_spirits = list()

	for(var/mob/dead/observer/O in GLOB.player_list)
		if(O.orbiting in contents)
			ghost_counter++
			O.invisibility = 0
			current_spirits |= O

	for(var/mob/dead/observer/G in spirits - current_spirits)
		G.invisibility = initial(G.invisibility)

	spirits = current_spirits

	return ghost_counter

/obj/item/melee/ghost_sword/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	force = 0
	var/ghost_counter = ghost_check()
	force = clamp((ghost_counter * 4), 0, 75)
	user.visible_message(
		span_danger("[user] нанос[PLUR_IT_YAT(user)] удар с силой [ghost_counter] мстительн[DECL_OGO_YH_YH(ghost_counter)] дух[DECL_A_OV_OV(ghost_counter)]!"),
		span_notice("Вы бьёте с силой [ghost_counter] мстительн[DECL_OGO_YH_YH(ghost_counter)] дух[DECL_A_OV_OV(ghost_counter)]!"),
	)
	return ..()

/obj/item/melee/ghost_sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	var/ghost_counter = ghost_check()
	final_block_chance += clamp((ghost_counter * 5), 0, 75)
	owner.visible_message(span_danger("[owner] защищён кольцом из [ghost_counter] призрак[DECL_A_OV_OV(ghost_counter)]!"))
	return ..()

// Blood


/obj/item/mayhem
	name = "mayhem in a bottle"
	desc = "A magically infused bottle of blood, the scent of which will drive anyone nearby into a murderous frenzy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/mayhem/attack_self(mob/user)
	for(var/mob/living/carbon/human/H in range(7,user))
		spawn()
			var/obj/effect/mine/pickup/bloodbath/B = new(H)
			B.mineEffect(H)
	to_chat(user, span_notice("Вы разбиваете бутылку!"))
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, TRUE)
	qdel(src)

// Blood Contract

/obj/item/blood_contract
	name = "blood contract"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	color = "#FF0000"
	desc = "Mark your target for death."
	var/used = FALSE

/obj/item/blood_contract/attack_self(mob/user)
	if(used)
		return

	used = TRUE
	var/choice = tgui_input_list(user, "Кого вы желаете уничтожить?", "Выбор жертвы", GLOB.player_list)

	if(!choice)
		used = FALSE
		return
	else if(!isliving(choice))
		to_chat(user, "[choice] уже мертв!")
		used = FALSE
		return
	else if(choice == user)
		to_chat(user, "Писать собственное имя в проклятый смертный приказ было бы неразумно.")
		used = FALSE
		return
	else
		var/mob/living/L = choice

		message_admins("[key_name_admin(L)] has been marked for death by [key_name_admin(user)].")
		log_admin("[key_name(L)] has been marked for death by [key_name(user)].")

		var/datum/objective/survive/survive = new
		survive.owner = L.mind
		L.mind.objectives += survive
		to_chat(L, span_userdanger("Вы обречены на смерть! Не дайте демонам добраться до вас!"))
		L.color = "#FF0000"
		spawn()
			var/obj/effect/mine/pickup/bloodbath/B = new(L)
			B.mineEffect(L)

		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H.stat == DEAD || H == L)
				continue
			to_chat(H, span_userdanger("Вы испытываете непреодолимое желание убить [L]. [GEND_HE_SHE_CAP(L)] помечен[GEND_A_O_Y(L)] красным! УБЕЙТЕ [uppertext(GEND_HIS_HER(L))]!"))
			H.put_in_hands(new /obj/item/kitchen/knife/butcher(H))

	qdel(src)

//hard-mode


/obj/item/book_of_babel
	name = "Book of Babel"
	desc = "An ancient tome written in countless tongues. The text on the pages is so small and dense that it appears to be a solid black mass until viewed up close."
	icon = 'icons/obj/library.dmi'
	icon_state = "book1"
	w_class = 2

/obj/item/book_of_babel/attack_self(mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_NO_BABEL))
		user.visible_message(
			span_notice("[user] внезапно останавлива[PLUR_ET_YUT(user)]ся, недоумённо глядя на [declent_ru(GENITIVE)]."),
			span_warning("Вы понятия не имеете, что это такое и что с этим делать.")
		)

		return

	to_chat(user, "Вы упоённо пролистываете страницы книги, впитывая в себя знания всех существующих языков во Вселенной. К сожалению, [declent_ru(NOMINATIVE)] не выдерживает такого напора и рассыпается в прах. Ой...")
	user.grant_all_babel_languages()
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	user.temporarily_remove_item_from_inventory(src)
	qdel(src)

//Potion of Flight: as we do not have the "Angel" species this currently does not work.

/obj/item/immortality_talisman
	name = "Immortality Talisman"
	desc = "A dread talisman that can render you completely invulnerable."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "talisman"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	actions_types = list(/datum/action/item_action/immortality)
	COOLDOWN_DECLARE(last_used_immortality_talisman)

/obj/item/immortality_talisman/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, ALL_MAGIC_RESISTANCE)

/datum/action/item_action/immortality
	name = "Бессмертие"

/obj/item/immortality_talisman/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/item/immortality_talisman/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, last_used_immortality_talisman))
		balloon_alert(user, "ещё не готово!")
		return

	var/turf/source_turf = get_turf(src)
	if(!source_turf)
		return

	COOLDOWN_START(src, last_used_immortality_talisman, 60 SECONDS)
	SSblackbox.record_feedback("amount", "immortality_talisman_uses", 1)
	user.visible_message(span_danger("[user] исчеза[PLUR_ET_YUT(user)] из реальности, оставляя после себя дыру в пространстве!"))

	var/obj/effect/immortality_talisman/effect = new(source_turf)
	effect.name = "hole in space"
	effect.desc = "It looks suspiciously like [user.name]'s silhouette."
	effect.setDir(user.dir)
	user.forceMove(effect)
	user.add_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), UNIQUE_TRAIT_SOURCE(src))

	addtimer(CALLBACK(src, PROC_REF(reappear), user, effect), 10 SECONDS)

/obj/item/immortality_talisman/proc/reappear(mob/user, obj/effect/immortality_talisman/effect)
	if(QDELETED(src) || QDELETED(user) || QDELETED(effect))
		return

	var/turf/effect_turf = get_turf(effect)
	if(!effect_turf)
		stack_trace("[effect] is outside of the turf contents")
		return

	user.remove_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), UNIQUE_TRAIT_SOURCE(src))
	user.forceMove(effect_turf)
	user.visible_message(span_danger("[user] материализу[PLUR_ET_YUT(user)]ся в пространстве, вновь возвращаясь в нашу реальность!"))
	effect.can_destroy = TRUE

	if(length(effect.contents))
		for(var/obj/atom as anything in effect.contents)	// Since we are using `as anything` this loop will pickup every atom in contents
			if(QDELETED(atom))
				continue
			atom.loc = effect_turf

	qdel(effect)

/obj/effect/immortality_talisman
	icon_state = "blank"
	var/can_destroy = FALSE

/obj/effect/immortality_talisman/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_PROCEED

/obj/effect/immortality_talisman/ex_act()
	return

/obj/effect/immortality_talisman/singularity_act()
	return

/obj/effect/immortality_talisman/singularity_pull(atom/singularity, current_size)
	return

/obj/effect/immortality_talisman/Destroy(force)
	if(!can_destroy && !force)
		return QDEL_HINT_LETMELIVE
	else
		. = ..()

/obj/structure/chair/stool/wooden
	name = "wooden stool"
	desc = "A wooden stool, comfortable enough to sit on."
	gender = FEMALE
	icon_state = "wooden_stool"
	item_chair = /obj/item/chair/stool/wooden

/obj/item/chair/stool/wooden
	name = "wooden stool"
	desc = "A wooden stool, comfortable enough to hold in your hands."
	gender = FEMALE
	icon_state = "wooden_stool_toppled"
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	item_state = "wooden_stool"
	force = 8
	origin_type = /obj/structure/chair/stool/wooden
	break_chance = 10

/obj/effect/temp_visual/at_shield
	name = "anti-toolbox field"
	desc = "A shimmering forcefield protecting the colossus."
	icon_state = "at_shield2"
	layer = FLY_LAYER
	light_range = 2
	duration = 8
	var/target

/obj/effect/temp_visual/at_shield/Initialize(mapload, new_target)
	. = ..()
	target = new_target
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, orbit), target, 0, FALSE, 0, 0, FALSE, TRUE)


/mob/living/simple_animal/hostile/asteroid/hivelordbrood/magic_skull
	name = "summoned skull"
	desc = "An animated skull conjured by a wizard."
	icon_state = "legion_head"
	icon_living = "legion_head"
	icon_aggro = "legion_head"
	icon_dead = "legion_head"
	health = 5
	maxHealth = 5
	melee_damage_lower = 12
	melee_damage_upper = 12
	life_time = 30 SECONDS
