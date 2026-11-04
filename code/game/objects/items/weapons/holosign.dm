/obj/item/holosign_creator
	name = "holographic sign projector"
	desc = "This shouldnt exist, if it does, tell a coder."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker"
	item_state = "signmaker"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	origin_tech = "magnets=1;programming=3"
	item_flags = NOBLUDGEON
	toolbox_radial_menu_compatibility = TRUE
	var/list/signs = list()
	var/max_signs = 10
	var/creation_time = 0 //time to create a holosign in deciseconds.
	var/holosign_type = /obj/structure/holosign/wetsign // because runtime if type == null
	var/holocreator_busy = FALSE //to prevent placing multiple holo barriers at once

/obj/item/holosign_creator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/openspace_item_click_handler)

/obj/item/holosign_creator/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(proximity_flag)
		if(!check_allowed_items(target, 1))
			return
		var/turf/T = get_turf(target)
		var/obj/structure/holosign/H = locate(holosign_type) in T
		if(H)
			to_chat(user, span_notice("Вы используете [declent_ru(ACCUSATIVE)] для деактивации [H.declent_ru(GENITIVE)]."))
			qdel(H)
		else
			if(!T.is_blocked_turf(exclude_mobs = TRUE)) //can't put holograms on a tile that has dense stuff
				if(holocreator_busy)
					balloon_alert(user, "уже в работе!")
					return
				if(length(signs) < max_signs)
					playsound(src.loc, 'sound/machines/click.ogg', 20, TRUE)
					if(creation_time)
						holocreator_busy = TRUE
						if(!do_after(user, creation_time, target))
							holocreator_busy = FALSE
							return
						holocreator_busy = FALSE
						if(length(signs) >= max_signs)
							return
						if(T.is_blocked_turf(exclude_mobs = TRUE)) //don't try to sneak dense stuff on our tile during the wait.
							return
					H = new holosign_type(get_turf(target), src)
					to_chat(user, span_notice("Вы создаёте [H.declent_ru(ACCUSATIVE)] с помощью [declent_ru(GENITIVE)]."))
					return H
				else
					to_chat(user, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] работает на максимальной мощности!"))

/obj/item/holosign_creator/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

/obj/item/holosign_creator/attack_self(mob/user)
	if(length(signs))
		for(var/H in signs)
			qdel(H)
		balloon_alert(user, "голограммы удалены")

/obj/item/holosign_creator/handle_openspace_click(turf/target, mob/user, list/modifiers)
	afterattack(target, user, TRUE, modifiers)

/obj/item/holosign_creator/janitor
	name = "Janitorial Holosign projector"
	desc = "A handy-dandy holographic projector that displays a janitorial sign."
	belt_icon = "sign_projector"
	var/wet_enabled = TRUE

/obj/item/holosign_creator/janitor/click_alt(mob/living/user)
	wet_enabled = !wet_enabled
	playsound(loc, 'sound/weapons/empty.ogg', 20)
	if(wet_enabled)
		to_chat(user, span_notice("Вы активируете таймер влажного испарения.\nНовые голо-знаки исчезнут, когда вымытая плитка полностью высохнет."))
	else
		to_chat(user, span_notice("Вы деактивируете таймер влажного испарения.\nНовые голо-знаки будут оставаться на месте без ограничений по времени."))

/obj/item/holosign_creator/janitor/examine(mob/user)
	. = ..()
	. += span_notice("Используйте <b>Alt+ЛКМ</b>, чтобы [wet_enabled ? "деактивировать" : "активировать"] таймер влажного испарения.")

/obj/item/holosign_creator/janitor/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	var/obj/structure/holosign/wetsign/WS = ..()
	if(WS && wet_enabled)
		WS.wet_timer_start(src)

/obj/item/holosign_creator/janitor/syndie
	holosign_type = /obj/structure/holosign/wetsign/mine
	creation_time = 5
	max_signs = 5
	wet_enabled = FALSE

/obj/item/holosign_creator/security
	name = "security holobarrier projector"
	desc = "A holographic projector that creates holographic security barriers."
	icon_state = "signmaker_sec"
	item_state = "signmaker_sec"
	belt_icon = "security_sign_projector"
	holosign_type = /obj/structure/holosign/barrier
	creation_time = 30
	max_signs = 6

/obj/item/holosign_creator/engineering
	name = "engineering holobarrier projector"
	desc = "A holographic projector that creates holographic engineering barriers."
	icon_state = "signmaker_engi"
	item_state = "signmaker_engi"
	holosign_type = /obj/structure/holosign/barrier/engineering
	creation_time = 30
	max_signs = 6

/obj/item/holosign_creator/atmos
	name = "ATMOS holofan projector"
	desc = "A holographic projector that creates holographic barriers that prevent changes in atmosphere conditions."
	icon_state = "signmaker_engi"
	item_state = "signmaker_engi"
	holosign_type = /obj/structure/holosign/barrier/atmos
	max_signs = 6

/obj/item/holosign_creator/cyborg
	name = "Energy Barrier Projector"
	desc = "A holographic projector that creates fragile energy fields."
	creation_time = 15
	max_signs = 9
	holosign_type = /obj/structure/holosign/barrier/cyborg
	var/shock = 0

/obj/item/holosign_creator/cyborg/attack_self(mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user

		if(shock)
			balloon_alert(user, "голограммы удалены")
			holosign_type = /obj/structure/holosign/barrier/cyborg
			creation_time = 5
			if(length(signs))
				for(var/H in signs)
					qdel(H)
			shock = 0
			return
		else if(R.emagged && !shock)
			balloon_alert(user, "голограммы удалены")
			holosign_type = /obj/structure/holosign/barrier/cyborg/hacked
			creation_time = 30
			if(length(signs))
				for(var/H in signs)
					qdel(H)
			shock = 1
			return
		else
			if(length(signs))
				for(var/H in signs)
					qdel(H)
				balloon_alert(user, "голограммы удалены")
	if(length(signs))
		for(var/H in signs)
			qdel(H)
		balloon_alert(user, "голограммы удалены")
