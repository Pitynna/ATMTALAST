/obj/item/antag_spawner
	abstract_type = /obj/item/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/used = FALSE

/obj/item/antag_spawner/proc/spawn_antag(client/C, turf/T, type = "")
	return

/obj/item/antag_spawner/proc/equip_antag(mob/target)
	return

///////////BORGS AND OPERATIVES
/obj/item/antag_spawner/nuke_ops
	name = "syndicate operative teleporter"
	desc = "A single-use teleporter designed to quickly reinforce operatives in the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/borg_to_spawn
	var/checking = FALSE
	var/rolename = "Syndicate Operative"
	var/image/poll_icon
	var/poll_icon_file = 'icons/mob/simple_human.dmi'
	var/poll_icon_state = "syndicate_space_sword"

/obj/item/antag_spawner/nuke_ops/Initialize(mapload)
	. = ..()
	poll_icon = image(icon = poll_icon_file, icon_state = poll_icon_state)

/obj/item/antag_spawner/nuke_ops/proc/before_candidate_search(user)
	return TRUE

/obj/item/antag_spawner/nuke_ops/proc/check_usability(mob/user)
	if(used)
		to_chat(user, span_warning("[src] is out of power!"))
		return FALSE
	if(!(user.mind.has_antag_datum(/datum/antagonist/nuclear_operative)))
		to_chat(user, span_danger("AUTHENTICATION FAILURE. ACCESS DENIED."))
		return FALSE
	if(checking)
		to_chat(user, span_danger("The device is already connecting to Syndicate command. Please wait."))
		return FALSE
	return TRUE

/obj/item/antag_spawner/nuke_ops/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	var/continue_proc = before_candidate_search(user)
	if(!continue_proc)
		return

	checking = TRUE

	to_chat(user, span_notice("You activate [src] and wait for confirmation."))
	var/list/nuke_candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за [rolename]?", ROLE_OPERATIVE, TRUE, 15 SECONDS, source = poll_icon)
	if(LAZYLEN(nuke_candidates))
		checking = FALSE
		if(QDELETED(src) || !check_usability(user))
			return
		used = TRUE
		var/mob/dead/observer/G = pick(nuke_candidates)
		spawn_antag(G.client, get_turf(src), user.mind)
		do_sparks(4, TRUE, src)
		qdel(src)
	else
		checking = FALSE
		to_chat(user, span_warning("Unable to connect to Syndicate command. Please wait and try again later or use the teleporter on your uplink to get your points refunded."))

/obj/item/antag_spawner/nuke_ops/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)

	M.possess_by_player(C.key)
	create_syndicate(M.mind)
	var/datum/antagonist/nuclear_operative/datum = M.mind.add_antag_datum(/datum/antagonist/nuclear_operative/reinf, /datum/team/nuclear_team)
	datum.equip()

//////SYNDICATE BORG
/obj/item/antag_spawner/nuke_ops/borg_tele
	name = "syndicate cyborg teleporter"
	var/switch_roles = FALSE

/obj/item/antag_spawner/nuke_ops/borg_tele/assault
	name = "syndicate assault cyborg teleporter"
	borg_to_spawn = "Assault"
	rolename = "Syndicate Assault Cyborg"
	poll_icon_file = 'icons/mob/robots.dmi'
	poll_icon_state = "syndie-bloodhound-preview"

/obj/item/antag_spawner/nuke_ops/borg_tele/medical
	name = "syndicate medical teleporter"
	borg_to_spawn = "Medical"
	rolename = "Syndicate Medical Cyborg"
	poll_icon_file = 'icons/mob/robots.dmi'
	poll_icon_state = "syndi-medi"

/obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	name = "syndicate saboteur teleporter"
	borg_to_spawn = "Saboteur"
	rolename = "Syndicate Saboteur Cyborg"
	poll_icon_file = 'icons/mob/robots.dmi'
	poll_icon_state = "syndi-engi-preview"

#define SYNDICATE_CYBORG "Борг \"Синдиката\""
#define NUCLEAR_OPERATIVE "Ядерный Оперативник"
#define CANCER_SWITCH_ROLES_CHOICE "Не активировать этот робот-телепортатор"

/obj/item/antag_spawner/nuke_ops/borg_tele/before_candidate_search(mob/user)
	var/switch_roles_choice = tgui_input_list(usr, "Вы хотите продолжить играть за оперативника или стать боргом? Если вы выберете борга, другой игрок займет ваше старое тело.", "Играть за", list(NUCLEAR_OPERATIVE, SYNDICATE_CYBORG, CANCER_SWITCH_ROLES_CHOICE))
	if(!switch_roles_choice || !(check_usability(user)) || switch_roles_choice == CANCER_SWITCH_ROLES_CHOICE)
		return FALSE

	if(switch_roles_choice == SYNDICATE_CYBORG)
		switch_roles = TRUE
		rolename = "Syndicate Operative"
	else
		switch_roles = FALSE

	return TRUE

#undef SYNDICATE_CYBORG
#undef NUCLEAR_OPERATIVE
#undef CANCER_SWITCH_ROLES_CHOICE

/obj/item/antag_spawner/nuke_ops/borg_tele/spawn_antag(client/C, turf/T, datum/mind/user)
	if(!(user.has_antag_datum(/datum/antagonist/nuclear_operative)))
		used = FALSE
		return

	var/mob/living/silicon/robot/R
	switch(borg_to_spawn)
		if("Medical")
			R = new /mob/living/silicon/robot/syndicate/medical(T)
		if("Saboteur")
			R = new /mob/living/silicon/robot/syndicate/saboteur(T)
		else
			R = new /mob/living/silicon/robot/syndicate(T) //Assault borg by default

	var/brainfirstname = pick(GLOB.first_names_male)
	var/brainopslastname = pick(GLOB.last_names_male)
	if(prob(50))
		brainfirstname = pick(GLOB.first_names_female)
		brainopslastname = pick(GLOB.last_names_female)

	var/datum/team/nuclear_team/team = GLOB.antagonist_teams[/datum/team/nuclear_team]
	if(team?.syndicate_name)  //the brain inside the syndiborg has the same last name as the other ops.
		brainopslastname = team.syndicate_name
	var/brainopsname = "[brainfirstname] [brainopslastname]"

	R.mmi.name = "[initial(R.mmi.name)]: [brainopsname]"
	R.mmi.brainmob.real_name = brainopsname
	R.mmi.brainmob.name = brainopsname

	if(!switch_roles)
		R.possess_by_player(C.key)
	else
		var/mob/living/L = user.current
		R.possess_by_player(user.current.client.key)
		L.possess_by_player(C.key)
	R.mind.add_antag_datum(/datum/antagonist/nuclear_operative/cyborg, /datum/team/nuclear_team)


///////////MORPH

/obj/item/antag_spawner/morph
	name = "vial of ooze"
	desc = "A magically infused bottle of ooze, distilled by methods rather not be spoken of. Used to awaken an all-consuming monstrosity."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vialooze"
	var/shatter_msg = span_notice_alt("You shatter the bottle, no \
		turning back now!")
	var/veil_msg = span_warning_alt("The sludge is awake and seeps \
		away...")
	var/objective_verb = "Eat"
	var/mob/living/morph_type = /mob/living/simple_animal/hostile/morph

/obj/item/antag_spawner/morph/attack_self(mob/user)
	if(level_blocks_magic(user.z))//this is to make sure the wizard does NOT summon a morph from the Den..
		to_chat(user, span_notice("You should probably wait until you reach the station."))
		return

	if(used)
		to_chat(user, span_notice("This bottle already has a broken seal."))
		return
	used = TRUE
	to_chat(user, span_notice("You break the seal on the bottle, calling upon the dire sludge to awaken..."))

	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a magical morph awakened by [user.real_name]?", ROLE_MORPH, 1, 10 SECONDS, source = morph_type)

	if(QDELETED(src) || QDELETED(loc))
		return

	if(length(candidates) > 0)
		var/mob/C = pick(candidates)
		spawn_antag(C, get_turf(src.loc), initial(morph_type.name), user)
		to_chat(user, "[shatter_msg]")
		to_chat(user, "[veil_msg]")
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, TRUE)
		qdel(src)
	else
		used = FALSE
		to_chat(user, span_notice("The sludge does not respond to your attempt to awake it. Perhaps you should try again later."))

/obj/item/antag_spawner/morph/spawn_antag(client/C, turf/T, type = "", mob/user)
	var/mob/living/simple_animal/hostile/morph/wizard/M = new /mob/living/simple_animal/hostile/morph/wizard(pick(GLOB.xeno_spawn))
	M.possess_by_player(C.key)
	M.mind.assigned_role = SPECIAL_ROLE_MORPH
	M.mind.special_role = SPECIAL_ROLE_MORPH
	to_chat(M, M.playstyle_string)
	SSticker.mode.traitors += M.mind
	var/datum/objective/assassinate/KillDaWiz = new /datum/objective/assassinate
	KillDaWiz.owner = M.mind
	KillDaWiz.target = user.mind
	KillDaWiz.explanation_text = "[objective_verb] [user.real_name], the one who was foolish enough to awake you."
	M.mind.objectives += KillDaWiz
	var/datum/objective/KillDaCrew = new /datum/objective
	KillDaCrew.owner = M.mind
	KillDaCrew.explanation_text = "[objective_verb] everyone and everything else while you're at it."
	KillDaCrew.completed = TRUE
	M.mind.objectives += KillDaCrew
	var/list/messages = M.mind.prepare_announce_objectives()
	to_chat(M, custom_boxed_message("red_box center", messages.Join("<br>")))
	SEND_SOUND(src, sound('sound/magic/mutate.ogg'))
