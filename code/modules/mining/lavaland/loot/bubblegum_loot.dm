/obj/structure/closet/crate/necropolis/bubblegum
	name = "bubblegum chest"

/obj/structure/closet/crate/necropolis/bubblegum/populate_contents()
	new /obj/item/clothing/suit/space/hostile_environment(src)
	new /obj/item/clothing/head/helmet/space/hostile_environment(src)
	new /obj/item/gem/bloodstone(src)

/obj/structure/closet/crate/necropolis/bubblegum/crusher
	name = "bloody bubblegum chest"

/obj/structure/closet/crate/necropolis/bubblegum/crusher/populate_contents()
	. = ..()
	new /obj/item/crusher_trophy/demon_claws(src)

// Mayhem

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

/obj/structure/closet/crate/necropolis/bubblegum/bait/populate_contents()
	return

/obj/effect/bubblegum_trigger
	var/list/targets_to_fuck_up = list()

/obj/effect/bubblegum_trigger/Initialize(mapload, target_list)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(activate)), 15 SECONDS) //We try to auto engage the fun 15 seconds after death.
	targets_to_fuck_up = target_list

/obj/effect/bubblegum_trigger/proc/activate()
	if(!length(targets_to_fuck_up))
		return
	var/spawn_locs = list()
	for(var/obj/effect/landmark/spawner/bubblegum_arena/R in GLOB.landmarks_list)
		spawn_locs += get_turf(R)
	for(var/mob/living/M in targets_to_fuck_up)
		var/turf/T = get_turf(M)
		M.Immobilize(1 SECONDS)
		to_chat(M, span_colossus("<b>НЕТ! Я НЕ ПОЗВОЛЮ ТЕБЕ ДУМАТЬ, ЧТО ТЫ ПОБЕДИЛ! Я ПОЛОЖУ КОНЕЦ ТВОЕЙ ЖАЛКОЙ ЖИЗНИ!</b>"))
		new /obj/effect/temp_visual/bubblegum_hands/leftpaw(T)
		new /obj/effect/temp_visual/bubblegum_hands/leftthumb(T)
		sleep(8)
		playsound(T, 'sound/misc/enter_blood.ogg', 100, TRUE, -1)
		var/turf/target_turf = pick(spawn_locs)
		M.forceMove(target_turf)
		playsound(target_turf, 'sound/misc/exit_blood.ogg', 100, TRUE, -1)
	for(var/obj/effect/landmark/spawner/bubblegum/B in GLOB.landmarks_list)
		new /mob/living/simple_animal/hostile/megafauna/bubblegum/round_2(get_turf(B))

/obj/effect/bubblegum_exit/Initialize(mapload, target_list)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(activate)), 10 SECONDS)

/obj/effect/bubblegum_exit/proc/activate()
	var/spawn_exit = list()
	for(var/obj/effect/landmark/spawner/bubblegum_exit/E in GLOB.landmarks_list)
		for(var/turf/T in range(4, E))
			if(T.density)
				continue
			spawn_exit += get_turf(T)
	var/area/probably_bubblearena = get_area(src)
	for(var/mob/living/M in probably_bubblearena)
		var/turf/T = get_turf(M)
		M.Immobilize(1 SECONDS)
		to_chat(M, span_colossus("<b>А теперь... убирайся из моего дома.</b>"))
		new /obj/effect/temp_visual/bubblegum_hands/leftpaw(T)
		new /obj/effect/temp_visual/bubblegum_hands/leftthumb(T)
		sleep(8)
		playsound(T, 'sound/misc/enter_blood.ogg', 100, TRUE, -1)
		var/turf/target_turf = pick(spawn_exit)
		M.forceMove(target_turf)
		playsound(target_turf, 'sound/misc/exit_blood.ogg', 100, TRUE, -1)
	for(var/obj/O in probably_bubblearena) //Mobs are out, lets get items / limbs / brains. Lets also exclude blood..
		if(iseffect(O))
			continue
		if(istype(O, /obj/structure/stone_tile)) //Taking the tiles from the arena is funny, but a bit stupid
			continue
		var/turf/target_turf = pick(spawn_exit)
		O.forceMove(target_turf)
