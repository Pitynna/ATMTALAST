GLOBAL_LIST_INIT(wcBar, pick(list("#0d8395", "#58b5c3", "#58c366", "#90d79a", "#ffffff")))
GLOBAL_LIST_INIT(wcBrig, pick(list("#aa0808", "#7f0606", "#ff0000")))
GLOBAL_LIST_INIT(wcCommon, pick(list("#379963", "#0d8395", "#58b5c3", "#49e46e", "#8fcf44", "#ffffff")))

/obj/proc/color_windows(obj/W)
	var/list/wcBarAreas = list(/area/station/service/bar)
	var/list/wcBrigAreas = list(/area/station/security, /area/shuttle/gamma)

	var/newcolor
	var/turf/T = get_turf(W)
	if(!istype(T))
		return
	var/area/A = T.loc

	if(is_type_in_list(A,wcBarAreas))
		newcolor = GLOB.wcBar
	else if(is_type_in_list(A,wcBrigAreas))
		newcolor = GLOB.wcBrig
	else
		newcolor = GLOB.wcCommon

	return newcolor

/obj/structure/window
	name = "window"
	desc = "A window."
	icon_state = "window"
	density = TRUE
	pass_flags_self = PASSGLASS
	layer = ABOVE_OBJ_LAYER //Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = TRUE
	flags = ON_BORDER | NO_SCREENTIPS
	obj_flags = BLOCKS_CONSTRUCTION_DIR
	can_be_unanchored = TRUE
	set_dir_on_move = FALSE
	max_integrity = 25
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 80, ACID = 100)
	interaction_flags_click = NEED_HANDS | ALLOW_RESTING
	cares_about_temperature = TRUE
	rad_insulation = RAD_VERY_LIGHT_INSULATION
	var/ini_dir = null
	var/state = WINDOW_OUT_OF_FRAME
	var/reinf = FALSE
	/// Minimum singularity stage that can rip this window from its anchors and start dragging it.
	var/singularity_unanchor_stage = STAGE_TWO
	var/heat_resistance = 800
	var/decon_speed = null
	var/fulltile = FALSE
	var/shardtype = /obj/item/shard
	var/glass_type = /obj/item/stack/sheet/glass
	var/glass_amount = 1
	var/cancolor = FALSE
	var/mutable_appearance/crack_overlay
	var/real_explosion_block	//ignore this, just use explosion_block
	var/breaksound = SFX_SHATTER
	var/hitsound = 'sound/effects/glasshit.ogg'
	var/painted = FALSE
	var/mutable_appearance/paint_overlay
	/// If we added a leaning component to ourselves
	var/added_leaning = FALSE
	/// How well this window resists superconductivity.
	var/superconductivity = WINDOW_HEAT_TRANSFER_COEFFICIENT

/obj/structure/window/Initialize(mapload, direct)
	. = ..()
	RegisterSignal(src, COMSIG_OBJ_PAINTED, PROC_REF(on_painted))
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_cleaned))

	if(direct)
		setDir(direct)
	if(reinf && anchored)
		state = WINDOW_SCREWED_TO_FRAME

	ini_dir = dir

	if(!color && cancolor)
		color = color_windows(src)

	if(fulltile)
		obj_flags &= ~BLOCKS_CONSTRUCTION_DIR
		setDir()

	if(decon_speed == null && fulltile)
		decon_speed = 2 SECONDS

	//windows only block while reinforced and fulltile, so we'll use the proc
	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC

	recalculate_atmos_connectivity()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/window/add_debris_element()
	generate_debris_handler(DEBRIS_GLASS, -40, 5)

/obj/structure/window/mouse_drop_receive(atom/dropping, mob/user, params)
	. = ..()
	//Adds the component only once. We do it here & not in Initialize() because there are tons of windows & we don't want to add to their init times
	LoadComponent(/datum/component/leanable, dropping)

/obj/structure/window/Destroy()
	UnregisterSignal(src, COMSIG_OBJ_PAINTED, PROC_REF(on_painted))
	UnregisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_cleaned))
	set_density(FALSE)
	recalculate_atmos_connectivity()
	update_nearby_icons()
	return ..()

/obj/structure/window/examine(mob/user)
	. = ..()
	if(reinf)
		if(anchored && state == WINDOW_SCREWED_TO_FRAME)
			. += span_notice("Окно <b>прикручено</b> к раме.")
		else if(anchored && state == WINDOW_IN_FRAME)
			. += span_notice("Окно <i>откручено</i>, но <b>вставлено</b> в раму.")
		else if(anchored && state == WINDOW_OUT_OF_FRAME)
			. += span_notice("Окно извлечено из рамы, его можно <i>вставить</i> обратно. Оно <b>прикручено</b> к полу.")
		else if(!anchored)
			. += span_notice("Окно <i>откручено</i> от пола и может быть разобрано <b>гаечным ключом</b>.")
	else
		if(anchored)
			. += span_notice("Окно <b>прикручено</b> к полу.")
		else
			. += span_notice("Окно <i>откручено</i> от пола и может быть разобрано <b>гаечным ключом</b>.")
	if(!anchored && !fulltile)
		. += span_notice("<b>Alt+ЛКМ</b> для поворота.")

/obj/structure/window/rpd_act(mob/user, obj/item/rpd/our_rpd, mode)
	return

/obj/structure/window/singularity_pull(atom/singularity, current_size)
	..()
	if(anchored && current_size >= singularity_unanchor_stage)
		set_anchored(FALSE)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/structure/window/setDir(newdir)
	return ..(fulltile ? FULLTILE_WINDOW_DIR : newdir)

/obj/structure/window/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return TRUE

	if(fulltile || border_dir == dir)
		return FALSE

	if(isobj(mover))
		var/obj/object = mover
		if(object.obj_flags & BLOCKS_CONSTRUCTION_DIR)
			var/obj/structure/window/window = object
			var/fulltile = istype(window) ? window.fulltile : FALSE
			if(!valid_build_direction(loc, object.dir, is_fulltile = fulltile))
				return FALSE

	return TRUE

/obj/structure/window/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return // Let's not block ourselves.

	if(pass_flags_self & leaving.pass_flags)
		return

	if(fulltile || dir == FULLTILE_WINDOW_DIR)
		return

	if(density && dir == direction)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/window/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!density)
		return TRUE
	if(fulltile || (dir == FULLTILE_WINDOW_DIR) || (dir == to_dir))
		return FALSE
	return TRUE

/obj/structure/window/attack_tk(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_notice("Кто-то постучал по [declent_ru(DATIVE)]."))
	add_fingerprint(user)
	playsound(src, 'sound/effects/glassknock.ogg', 50, TRUE)

/obj/structure/window/attack_hand(mob/living/carbon/human/user)
	if(!can_be_reached(user))
		return
	if(user.a_intent == INTENT_HARM)
		user.changeNext_move(CLICK_CD_MELEE)
		if(ishuman(user) && (user.dna.species.obj_damage + user.physiology.punch_obj_damage > 0))
			attack_generic(user, user.dna.species.obj_damage + user.physiology.punch_obj_damage)
		else
			playsound(src, 'sound/effects/glassbang.ogg', 100, TRUE)
			user.visible_message(span_warning("[user] сильно стучит по [declent_ru(DATIVE)]!"),
								span_warning("Вы сильно стучите по [declent_ru(DATIVE)]!"),
								"Слышен громкий стук.")
		add_fingerprint(user)
	else
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src, 'sound/effects/glassknock.ogg', 50, TRUE)
		user.visible_message("[user] стучит по [declent_ru(DATIVE)].",
							"Вы стучите по [declent_ru(DATIVE)].",
							"Слышен стук.")
		add_fingerprint(user)

/obj/structure/window/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)	//used by attack_alien, attack_animal, and attack_slime
	if(!can_be_reached(user))
		return
	..()

/obj/structure/window/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !isliving(grabbed_thing) || !can_be_reached(grabber) || !Adjacent(grabbed_thing))
		return .
	var/mob/living/victim = grabbed_thing
	add_fingerprint(grabber)
	playsound(loc, 'sound/effects/glasshit.ogg', 150, TRUE)
	switch(grabber.grab_state)
		if(GRAB_AGGRESSIVE)
			victim.visible_message(
				span_warning("[grabber] стука[PLUR_ET_YUT(grabber)] [victim] в [declent_ru(ACCUSATIVE)]!"),
				span_warning("[grabber] стука[PLUR_ET_YUT(grabber)] вас в [declent_ru(ACCUSATIVE)]!")
			)
			if(prob(25))
				victim.Knockdown(2 SECONDS)
			victim.apply_damage(7)
			take_damage(10)
		if(GRAB_NECK)
			victim.visible_message(
				span_warning("[grabber] бь[PLUR_YOT_YUT(grabber)] [victim] о [declent_ru(ACCUSATIVE)]!"),
				span_warning("[grabber] бь[PLUR_ET_YUT(grabber)] вас о [declent_ru(ACCUSATIVE)]!")
			)
			victim.Knockdown(4 SECONDS)
			victim.apply_damage(10)
			take_damage(25)
		if(GRAB_KILL)
			victim.visible_message(
				span_warning("[grabber] с размаху бь[PLUR_YOT_YUT(grabber)] [victim] к [declent_ru(DATIVE)]!"),
				span_warning("[grabber] с размаху бь[PLUR_YOT_YUT(grabber)] вас к [declent_ru(DATIVE)]!")
			)
			victim.Knockdown(6 SECONDS)
			victim.apply_damage(20)
			take_damage(50)

/obj/structure/window/attackby(obj/item/I, mob/living/user, params)
	if(!can_be_reached(user))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/structure/window/crowbar_act(mob/user, obj/item/I)
	if(!reinf)
		return
	if(state != WINDOW_OUT_OF_FRAME && state != WINDOW_IN_FRAME)
		return
	if(obj_flags & NODECONSTRUCT)
		return
	. = TRUE
	if(!can_be_reached(user))
		return
	if(decon_speed) // Only show this if it actually takes time
		to_chat(user, span_notice("Вы начинаете [state == WINDOW_OUT_OF_FRAME ? "приподнимать окно для установки в раму" : "выводить окно из рамы"]..."))
	if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
		return
	state = (state == WINDOW_OUT_OF_FRAME ? WINDOW_IN_FRAME : WINDOW_OUT_OF_FRAME)
	to_chat(user, span_notice("Вы [state == WINDOW_IN_FRAME ? "устанавливаете окно в раму" : "извлекаете окно из рамы"]."))

/obj/structure/window/screwdriver_act(mob/user, obj/item/I)
	if(obj_flags & NODECONSTRUCT)
		return
	. = TRUE
	if(!can_be_reached(user))
		return
	if(reinf)
		if(state == WINDOW_SCREWED_TO_FRAME || state == WINDOW_IN_FRAME)
			if(decon_speed)
				to_chat(user, span_notice("Вы начинаете [state == WINDOW_SCREWED_TO_FRAME ? "откручивать окно от рамы" : "прикручивать окно к раме"]."))
			if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				return
			state = (state == WINDOW_IN_FRAME ? WINDOW_SCREWED_TO_FRAME : WINDOW_IN_FRAME)
			to_chat(user, span_notice("Вы [state == WINDOW_IN_FRAME ? "открутили окно от рамы" : "закрутили окно в раме"]."))

		else if(state == WINDOW_OUT_OF_FRAME)
			if(decon_speed)
				to_chat(user, span_notice("Вы начинаете [anchored ? "откручивать раму от пола" : "прикручивать раму к полу"]..."))
			if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				return
			set_anchored(!anchored)
			recalculate_atmos_connectivity()
			update_nearby_icons()
			to_chat(user, span_notice("Вы [anchored ? "закрепляете раму к ": "открепляете раму от"] пола."))

	else //if we're not reinforced, we don't need to check or update state
		if(decon_speed)
			to_chat(user, span_notice("Вы начинаете [anchored ? "откручивать окно от пола":"прикручивать окно к полу"]..."))
		if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
			return
		set_anchored(!anchored)
		recalculate_atmos_connectivity()
		update_nearby_icons()
		to_chat(user, span_notice("Вы [anchored ? "закрепляете окно на полу":"открепляете окно от пола"]."))

/obj/structure/window/wrench_act(mob/user, obj/item/I)
	if(obj_flags & NODECONSTRUCT)
		return
	if(anchored)
		return
	. = TRUE
	if(!can_be_reached(user))
		return
	if(decon_speed)
		TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
		return
	var/obj/item/stack/sheet/G = new glass_type(user.loc, glass_amount)
	G.add_fingerprint(user)
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	to_chat(user, span_notice("Вы успешно разбираете [declent_ru(ACCUSATIVE)]."))
	qdel(src)

/obj/structure/window/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(!can_be_reached(user))
		return
	if(obj_integrity >= max_integrity)
		to_chat(user, span_warning("[declent_ru(NOMINATIVE)] уже в хорошем состоянии!"))
		return
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		update_integrity(max_integrity)
		WELDER_REPAIR_SUCCESS_MESSAGE
		update_icon(UPDATE_OVERLAYS)

/obj/structure/window/proc/check_state(checked_state)
	return state == checked_state

/obj/structure/window/proc/check_anchored(checked_anchored)
	return anchored == checked_anchored

/obj/structure/window/proc/check_state_and_anchored(checked_state, checked_anchored)
	return check_state(checked_state) && check_anchored(checked_anchored)

/obj/structure/window/mech_melee_attack(obj/mecha/mech, obj/item/mecha_parts/mecha_equipment/selected_module = null)
	if(!can_be_reached())
		return
	..()

/obj/structure/window/proc/can_be_reached(mob/user)
	if(fulltile || dir == FULLTILE_WINDOW_DIR)
		return TRUE
	var/checking_dir = get_dir(user, src)
	if(!(checking_dir & dir))
		return TRUE // Only windows on the other side may be blocked by other things.
	checking_dir = REVERSE_DIR(checking_dir)
	for(var/obj/blocker in loc)
		if(!blocker.CanPass(user, checking_dir))
			return FALSE
	return TRUE

/obj/structure/window/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(.) //received damage
		update_nearby_icons()

/obj/structure/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, hitsound, 75, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/Welder.ogg', 100, TRUE)

/obj/structure/window/deconstruct(disassembled = TRUE)
	if(QDELETED(src))
		return
	if(!disassembled)
		playsound(src, breaksound, 70, TRUE)
		if(!(obj_flags & NODECONSTRUCT))
			for(var/obj/item/shard/debris in spawn_debris(drop_location()))
				debris.color = color
				transfer_fingerprints_to(debris) // transfer fingerprints to shards only
	qdel(src)
	update_nearby_icons()

/obj/structure/window/proc/spawn_debris(location)
	var/list/dropped_debris = list()
	if(shardtype)
		dropped_debris += new shardtype(location)
		if(fulltile)
			dropped_debris += new shardtype(location)
	if(reinf)
		dropped_debris += new /obj/item/stack/rods(location)
		if(fulltile)
			dropped_debris += new /obj/item/stack/rods(location)

	return dropped_debris

/obj/structure/window/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	. = ..()
	var/obj/structure/grille/our_grille = locate(/obj/structure/grille) in get_turf(src)
	if(our_grille)
		return our_grille.rcd_deconstruct_act(user, our_rcd)
	else
		return RCD_ACT_FAILED

/obj/structure/window/click_alt(mob/user)
	if(anchored)
		to_chat(user, span_warning("[declent_ru(NOMINATIVE)] нельзя повернуть, пока он закреплён!"))
		return CLICK_ACTION_BLOCKING

	var/target_dir = turn(dir, 90)

	if(!valid_build_direction(loc, target_dir, fulltile))
		to_chat(user, span_warning("Нет места, чтобы повернуть [declent_ru(ACCUSATIVE)]!"))
		return CLICK_ACTION_BLOCKING

	setDir(target_dir)
	ini_dir = dir
	add_fingerprint(user)
	return CLICK_ACTION_SUCCESS

/obj/structure/window/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/window/CanAtmosPass(direction)
	if(!anchored || !density)
		return TRUE
	return !(FULLTILE_WINDOW_DIR == dir || (dir & direction))

/obj/structure/window/get_superconductivity(direction)
	if(dir == FULLTILE_WINDOW_DIR || dir & direction)
		return superconductivity
	return ..()

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_icon(UPDATE_OVERLAYS)
	if(smooth)
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/window/update_overlays()
	. = ..()
	if(QDELETED(src) || !fulltile)
		return

	var/ratio = obj_integrity / max_integrity
	ratio = ceil(ratio * 4) * 25
	if(smooth)
		QUEUE_SMOOTH(src)
	if(ratio > 75)
		return

	crack_overlay = mutable_appearance('icons/obj/structures.dmi', "damage[ratio]", -(layer + 0.01), appearance_flags = RESET_COLOR)
	. += crack_overlay

/obj/structure/window/temperature_expose(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > (T0C + heat_resistance))
		take_damage(round(exposed_temperature / 100), BURN, 0, 0)

/obj/structure/window/hit_by_thrown_mob(mob/living/throwned_mob, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	var/shattered = FALSE
	if(damage * 2 >= obj_integrity && shardtype && !mob_hurt)
		shattered = TRUE
		var/obj/item/item = new shardtype(loc)
		item.color = color
		item.embedded_ignore_throwspeed_threshold = TRUE
		item.throw_impact(throwned_mob)
		item.embedded_ignore_throwspeed_threshold = FALSE
		damage *= (4/3) //Inverts damage loss from being a structure, since glass breaking on you hurts
		var/turf/turf = get_turf(src)
		for(var/obj/structure/grille/grille in turf.contents)
			var/obj/structure/cable/cable = turf.get_cable_node()
			if(cable)
				playsound(grille, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
				tesla_zap(grille, 3, cable.newavail() * 0.01) //Zap for 1/100 of the amount of power. At a million watts in the grid, it will be as powerful as a tesla revolver shot.
				tesla_zap(source = src, zap_range = 3, power = cable.newavail() * 0.01, cutoff = 1e3, zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN | ZAP_ALLOW_DUPLICATES) //Zap for 1/100 of the amount of power. At a million watts in the grid, it will be as powerful as a tesla revolver shot.
			qdel(grille) //We don't want the grille to block the way, we want rule of cool of throwing people into space!

	if(!self_hurt)
		take_damage(damage * 2, BRUTE) //Makes windows more vunerable to being thrown so they'll actually shatter in a reasonable ammount of time.
		self_hurt = TRUE
	..()
	if(shattered)
		throwned_mob.throw_at(throwingdatum.initial_target, throwingdatum.maxrange - 1, throwingdatum.speed - 1) //Annnnnnnd yeet them into space, but slower, now that everything is dealt with

/obj/structure/window/get_explosion_block()
	return reinf && fulltile ? real_explosion_block : 0

/obj/structure/window/wash_tg(clean_types)
	. = ..()
	if(!(clean_types & CLEAN_SCRUB))
		return
	var/initial_opacity = initial(opacity)
	if(opacity != initial_opacity)
		set_opacity(initial_opacity)
		. |= COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP
	for(var/atom/movable/cleanables as anything in src)
		if(cleanables == src)
			continue
		var/cleanable_washed = cleanables.wash_tg(clean_types)
		if(!cleanable_washed)
			continue
		. |= cleanable_washed
		vis_contents -= cleanables

/obj/structure/window/proc/on_painted(datum/source, new_color)
	SIGNAL_HANDLER
	if(painted)
		return
	painted = TRUE

	paint_overlay = mutable_appearance(icon, icon_state, layer + 0.01)
	paint_overlay.color = new_color
	paint_overlay.alpha = 200
	add_overlay(paint_overlay)

	if(new_color == COLOR_BLACK)
		set_opacity(TRUE)

/obj/structure/window/proc/on_cleaned(datum/source, clean_strength)
	SIGNAL_HANDLER
	if(!painted)
		return

	painted = FALSE
	if(paint_overlay)
		cut_overlay(paint_overlay)
		paint_overlay = null

	set_opacity(initial(opacity))
	return COMPONENT_CLEANED

/obj/structure/window/basic
	desc = "It looks thin and flimsy. A few knocks with... anything, really should shatter it. Lacks protection from radiation."

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it. Lacks protection from radiation."
	icon_state = "rwindow"
	reinf = TRUE
	cancolor = TRUE
	heat_resistance = 1600
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 25, BIO = 100, FIRE = 80, ACID = 100)
	max_integrity = 50
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/rglass
	rad_insulation = RAD_LIGHT_INSULATION
	singularity_unanchor_stage = STAGE_THREE

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon_state = "twindow"
	opacity = TRUE

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	desc = "It looks rather strong and frosted over. Looks like it might take a few less hits then a normal reinforced window."
	icon_state = "fwindow"
	max_integrity = 30

/obj/structure/window/reinforced/polarized
	name = "electrochromic window"
	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."
	var/id
	var/original_color
	var/ispolzovano

/obj/structure/window/reinforced/polarized/proc/toggle()
	if(!ispolzovano)
		ispolzovano++
		original_color = color
	if(opacity)
		animate(src, color="[original_color]", time=5)
		set_opacity(FALSE)
	else
		animate(src, color="#222222", time=5)
		set_opacity(TRUE)

/obj/machinery/button
	name = "button"
	mouse_over_pointer = MOUSE_HAND_POINTER

/obj/machinery/button/windowtint
	name = "window tint control"
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "light-off"
	desc = "A remote control switch for polarized windows."
	anchored = TRUE
	var/range = 7
	var/id = 0
	var/active = 0

/obj/machinery/button/windowtint/attack_hand(mob/user)
	if(..())
		return 1

	toggle_tint()

/obj/machinery/button/windowtint/proc/toggle_tint()
	use_power(5)

	active = !active
	update_icon(UPDATE_ICON_STATE)

	for(var/obj/structure/window/reinforced/polarized/window in range(src,range))
		if(window.id == id || !window.id)
			INVOKE_ASYNC(window, TYPE_PROC_REF(/obj/structure/window/reinforced/polarized, toggle))

	for(var/obj/structure/window/full/reinforced/polarized/window in range(src,range))
		if(window.id == id || !window.id)
			INVOKE_ASYNC(window, TYPE_PROC_REF(/obj/structure/window/full/reinforced/polarized, toggle))

	for(var/obj/machinery/door/airlock/airlock in range(src,range))
		if(airlock.id == id)
			INVOKE_ASYNC(src, PROC_REF(async_update), airlock)

/obj/machinery/button/windowtint/proc/async_update(obj/machinery/door/airlock/airlock)
	if(airlock.glass)
		airlock.airlock_material = null
		airlock.glass = FALSE
		airlock.update_icon()
		if(airlock.density)
			airlock.set_opacity(TRUE)
	else
		airlock.airlock_material = "glass"
		airlock.glass = TRUE
		airlock.update_icon()
		airlock.set_opacity(FALSE)

/obj/machinery/button/windowtint/power_change(forced = FALSE)
	if(!..())
		return
	if(active && !powered(power_channel))
		toggle_tint()

/obj/machinery/button/windowtint/update_icon_state()
	icon_state = "light[active ? "-on" : "-off"]"

/obj/structure/window/plasmabasic
	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through. When hit with Gamma particles it will become charged and start emitting Beta particles"
	icon_state = "plasmawindow"
	shardtype = /obj/item/shard/plasma
	glass_type = /obj/item/stack/sheet/plasmaglass
	heat_resistance = 32000
	max_integrity = 150
	explosion_block = 1
	armor = list(MELEE = 75, BULLET = 5, LASER = 0, ENERGY = 0, BOMB = 45, BIO = 100, FIRE = 99, ACID = 100)
	superconductivity = ZERO_HEAT_TRANSFER_COEFFICIENT
	rad_insulation = RAD_MEDIUM_INSULATION
	singularity_unanchor_stage = STAGE_THREE

/obj/structure/window/plasmareinforced
	name = "reinforced plasma window"
	desc = "A plasma-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic plasma windows are insanely fireproof. When hit with Gamma particles it will become charged and start emitting Beta particles"
	icon_state = "plasmarwindow"
	shardtype = /obj/item/shard/plasma
	glass_type = /obj/item/stack/sheet/plasmarglass
	reinf = TRUE
	heat_resistance = 32000
	max_integrity = 500
	explosion_block = 2
	armor = list(MELEE = 85, BULLET = 20, LASER = 0, ENERGY = 0, BOMB = 60, BIO = 100, FIRE = 99, ACID = 100)
	damage_deflection = 21
	superconductivity = ZERO_HEAT_TRANSFER_COEFFICIENT
	rad_insulation = RAD_HEAVY_INSULATION
	cares_about_temperature = FALSE
	singularity_unanchor_stage = STAGE_FOUR

/obj/structure/window/plasmareinforced/temperature_expose(exposed_temperature, exposed_volume, base_structure_expose)
	return

/obj/structure/window/abductor
	name = "alien window"
	desc = "A window made out of a alien alloy. Looks like it can regenerate all damage."
	icon_state = "alwindow"
	glass_type = /obj/item/stack/sheet/abductorglass
	heat_resistance = 1600
	max_integrity = 150
	explosion_block = 1
	armor = list(MELEE = 75, BULLET = 5, LASER = 0, ENERGY = 0, BOMB = 45, BIO = 100, FIRE = 80, ACID = 100)

/obj/structure/window/abductor/Initialize(mapload, direct)
	. = ..()
	AddComponent(/datum/component/obj_regenerate)

/obj/structure/window/full
	glass_amount = 2
	dir = FULLTILE_WINDOW_DIR
	level = 3
	fulltile = TRUE
	flags = PREVENT_CLICK_UNDER | NO_SCREENTIPS
	obj_flags = BLOCK_Z_IN_DOWN | BLOCK_Z_IN_UP

/obj/structure/window/full/CanAtmosPass(direction)
	if(!anchored || !density)
		return TRUE
	return FALSE

/obj/structure/window/full/basic
	desc = "It looks thin and flimsy. A few knocks with... anything, really should shatter it."
	icon = 'icons/obj/smooth_structures/window.dmi'
	base_icon_state = "window"
	max_integrity = 50
	smooth = SMOOTH_BITMASK
	cancolor = TRUE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE

/obj/structure/window/full/plasmabasic
	name = "plasma window"
	desc = "A plasma-glass alloy window. It looks insanely tough to break. It appears it's also insanely tough to burn through."
	icon = 'icons/obj/smooth_structures/plasma_window.dmi'
	icon_state = "plasma_window-0"
	base_icon_state = "plasma_window"
	shardtype = /obj/item/shard/plasma
	glass_type = /obj/item/stack/sheet/plasmaglass
	heat_resistance = 32000
	max_integrity = 300
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	explosion_block = 1
	armor = list(MELEE = 75, BULLET = 5, LASER = 0, ENERGY = 0, BOMB = 45, BIO = 100, FIRE = 99, ACID = 100)
	superconductivity = ZERO_HEAT_TRANSFER_COEFFICIENT
	rad_insulation = RAD_MEDIUM_INSULATION
	singularity_unanchor_stage = STAGE_THREE

/obj/structure/window/full/paperframe
	name = "Paperframe Window"
	desc = "Just looking at it's clean and simple design makes you at piece with your demons"
	icon = 'icons/obj/smooth_structures/paperframe.dmi'
	icon_state = "paperframe-0"
	base_icon_state = "paperframe"
	max_integrity = 50
	smooth = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_PAPERFRAME
	canSmoothWith = SMOOTH_GROUP_PAPERFRAME

/obj/structure/window/full/plasmareinforced
	name = "reinforced plasma window"
	desc = "A plasma-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic plasma windows are insanely fireproof."
	icon = 'icons/obj/smooth_structures/rplasma_window.dmi'
	icon_state = "rplasma_window-0"
	base_icon_state = "rplasma_window"
	shardtype = /obj/item/shard/plasma
	glass_type = /obj/item/stack/sheet/plasmarglass
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	reinf = TRUE
	max_integrity = 1000
	explosion_block = 2
	armor = list(MELEE = 85, BULLET = 20, LASER = 0, ENERGY = 0, BOMB = 60, BIO = 100, FIRE = 99, ACID = 100)
	superconductivity = ZERO_HEAT_TRANSFER_COEFFICIENT
	rad_insulation = RAD_HEAVY_INSULATION
	cares_about_temperature = FALSE
	singularity_unanchor_stage = STAGE_FOUR

/obj/structure/window/full/plasmareinforced/temperature_expose(exposed_temperature, exposed_volume, base_structure_expose)
	return

/obj/structure/window/full/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon = 'icons/obj/smooth_structures/reinforced_window.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	max_integrity = 100
	reinf = TRUE
	heat_resistance = 1600
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 25, BIO = 100, FIRE = 80, ACID = 100)
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/rglass
	cancolor = TRUE
	rad_insulation = RAD_LIGHT_INSULATION
	singularity_unanchor_stage = STAGE_THREE

/obj/structure/window/full/reinforced/tinted
	name = "tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon = 'icons/obj/smooth_structures/tinted_window.dmi'
	icon_state = "tinted_window-0"
	base_icon_state = "tinted_window"
	opacity = TRUE

/obj/structure/window/full/reinforced/polarized
	name = "electrochromic window"
	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."
	var/id
	var/original_color
	var/ispolzovano

/obj/structure/window/full/reinforced/polarized/proc/toggle()
	if(!ispolzovano)
		ispolzovano++
		original_color = color
	if(opacity)
		animate(src, color="[original_color]", time=5)
		set_opacity(FALSE)
	else
		animate(src, color="#222222", time=5)
		set_opacity(TRUE)

/obj/structure/window/full/reinforced/ice
	icon = 'icons/obj/smooth_structures/rice_window.dmi'
	icon_state = "ice_window"
	base_icon_state = "rice_window"
	max_integrity = 150
	cancolor = FALSE

/obj/structure/window/full/abductor
	name = "alien window"
	desc = "A alien alloy window. Looks like it regenerate all damage."
	icon = 'icons/obj/smooth_structures/alien_window.dmi'
	icon_state = "alien_window-0"
	base_icon_state = "alien_window"
	glass_type = /obj/item/stack/sheet/abductorglass
	heat_resistance = 1600
	max_integrity = 300
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	explosion_block = 1
	armor = list(MELEE = 75, BULLET = 5, LASER = 0, ENERGY = 0, BOMB = 45, BIO = 100, FIRE = 80, ACID = 100)

/obj/structure/window/full/abductor/Initialize(mapload, direct)
	. = ..()
	AddComponent(/datum/component/obj_regenerate)

/obj/structure/window/full/shuttle
	name = "shuttle window"
	desc = "A reinforced, air-locked pod window."
	icon = 'icons/obj/smooth_structures/shuttle_window.dmi'
	icon_state = "shuttle_window-0"
	base_icon_state = "shuttle_window"
	max_integrity = 100
	reinf = TRUE
	heat_resistance = 1600
	explosion_block = 3
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 100, FIRE = 80, ACID = 100)
	smooth = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE //+ SMOOTH_GROUP_SHUTTLE_PARTS
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE
	glass_type = /obj/item/stack/sheet/titaniumglass
	rad_insulation = RAD_MEDIUM_INSULATION

/obj/structure/window/full/shuttle/tinted
	opacity = TRUE

/obj/structure/window/full/shuttle/gray
	icon = 'icons/obj/smooth_structures/shuttle_window_gray.dmi'
	icon_state = "shuttle_window_gray"
	base_icon_state = "shuttle_window_gray"

/obj/structure/window/full/shuttle/gray/tinted
	opacity = TRUE

/obj/structure/window/plastitanium
	name = "plastitanium window"
	desc = "An evil looking window of plasma and titanium. When hit with Gamma particles it will become charged and start emitting Beta particles"
	icon = 'icons/obj/smooth_structures/plastitanium_window.dmi'
	icon_state = "plastitanium_window"
	base_icon_state = "plastitanium_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 100
	fulltile = TRUE
	flags = PREVENT_CLICK_UNDER | NO_SCREENTIPS
	reinf = TRUE
	heat_resistance = 1600
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 100, FIRE = 80, ACID = 100)
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM
	explosion_block = 3
	level = 3
	glass_type = /obj/item/stack/sheet/plastitaniumglass
	glass_amount = 2
	superconductivity = ZERO_HEAT_TRANSFER_COEFFICIENT
	rad_insulation = RAD_EXTREME_INSULATION
