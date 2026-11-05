// Basic lighters
/obj/item/lighter
	name = "cheap lighter"
	desc = "A cheap cigarette lighter. It gets the job done, barely."
	gender = FEMALE
	icon = 'icons/obj/lighters.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 4
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	attack_verb = null
	resistance_flags = FIRE_PROOF
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_on = FALSE
	custom_price = PAYCHECK_MIN
	///The amount of heat a lighter has while it's on. We're using the define to ensure lighters can't do things we don't want them to.
	var/heat_while_on = HIGH_TEMPERATURE_REQUIRED - 100
	var/lit = FALSE
	var/icon_on = "lighter-g-on"
	var/icon_off = "lighter-g"
	/// Cooldown until the next turned on message/sound can be activated
	var/next_on_message
	/// Cooldown until the next turned off message/sound can be activated
	var/next_off_message
	/// Lighting middleman, lets us do a flicker effect
	var/datum/light_middleman/middleman

/obj/item/lighter/random/Initialize(mapload)
	. = ..()
	var/color = pick("r","c","y","g")
	icon_on = "lighter-[color]-on"
	icon_off = "lighter-[color]"
	icon_state = icon_off

	if(IS_OVERLAY_LIGHT_SYSTEM(light_system))
		middleman = new(src, "flashlight")
		RegisterSignal(middleman, COMSIG_LIGHT_MIDDLEMAN_UPDATED, PROC_REF(light_updated))
		middleman.being_overriding_light()

	update_appearance()

/obj/item/lighter/Destroy(force)
	if(!isnull(middleman))
		QDEL_NULL(middleman)
	return ..()

/obj/item/lighter/attack_self(mob/living/user)
	. = ..()
	if(!lit)
		turn_on_lighter(user)
	else
		turn_off_lighter(user)

/obj/item/lighter/get_temperature()
	return lit * heat

/obj/item/lighter/proc/turn_on_lighter(mob/living/user)
	lit = TRUE
	w_class = WEIGHT_CLASS_BULKY
	icon_state = icon_on
	force = 5
	damtype = BURN
	hitsound = 'sound/items/welder.ogg'
	attack_verb = list("подпалил", "опалил")
	heat = heat_while_on

	attempt_light(user)
	set_light_on(TRUE)
	START_PROCESSING(SSobj, src)

/obj/item/lighter/proc/light_updated(datum/source)
	SIGNAL_HANDLER
	fire_flicker_middleman(middleman)

/obj/item/lighter/proc/attempt_light(mob/living/user)
	if(prob(75) || issilicon(user)) // Robots can never burn themselves trying to light it.
		user.balloon_alert(user, "включено")
	else if(HAS_TRAIT(user, TRAIT_BADASS))
		user.balloon_alert(user, "включено")
		to_chat(user, span_notice("Как только вы зажгли [declent_ru(ACCUSATIVE)], [GEND_HIS_HER(user)] пламя окутывает вашу руку, но вы даже не дёрнулись."))
	else
		user.balloon_alert(user, "включено")
		user.apply_damage(5, BURN, def_zone = user.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)	//INFERNO
		to_chat(user, span_notice("Вы зажгли [declent_ru(ACCUSATIVE)], но в процессе обожгли себе руку."))
	if(world.time > next_on_message)
		user.balloon_alert(user, "включено")
		playsound(src, 'sound/items/lighter/plastic_strike.ogg', 25, TRUE)
		next_on_message = world.time + 5 SECONDS

/obj/item/lighter/proc/turn_off_lighter(mob/living/user)
	lit = FALSE
	w_class = WEIGHT_CLASS_TINY
	icon_state = icon_off
	damtype = BRUTE
	hitsound = SFX_SWING_HIT
	force = 0
	attack_verb = null //human_defense.dm takes care of it
	heat = 0

	show_off_message(user)
	set_light_on(FALSE)
	STOP_PROCESSING(SSobj, src)

/obj/item/lighter/extinguish_light(force = FALSE)
	if(!force)
		return
	turn_off_lighter()

/obj/item/lighter/proc/show_off_message(mob/living/user)
	user.balloon_alert(user, "выключено")
	if(world.time > next_off_message)
		playsound(src, 'sound/items/lighter/plastic_close.ogg', 25, TRUE)
		next_off_message = world.time + 5 SECONDS

/obj/item/lighter/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!lit)
		return ..()

	var/return_flags = ATTACK_CHAIN_PROCEED

	if(target.IgniteMob())
		return_flags |= ATTACK_CHAIN_SUCCESS
		add_attack_logs(user, target, "set on fire", ATKLOG_FEW)

	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH || !istype(target.wear_mask, /obj/item/clothing/mask/cigarette))
		return ..() | return_flags

	var/obj/item/clothing/mask/cigarette/cig = target.wear_mask
	if(cig.lit)
		user.balloon_alert(user, "сигарета уже горит!")
		return return_flags

	if(target == user)
		return cig.attackby(src, user, params) | return_flags

	return_flags |= ATTACK_CHAIN_SUCCESS
	. = return_flags

	if(istype(src, /obj/item/lighter/zippo))
		cig.light(span_rose("[user] доста[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] и держ[PLUR_IT_AT(user)] [declent_ru(gender, "его", "её", "его", "их")] у [target.declent_ru(GENITIVE)]. Рука [user] тверда, как немигающее пламя, которым [GEND_HE_SHE(user)] прикурива[PLUR_ET_YUT(user)] [cig.declent_ru(ACCUSATIVE)]."))
	else
		cig.light(span_notice("[user] держ[PLUR_IT_AT(user)] [declent_ru(ACCUSATIVE)] у [target.declent_ru(GENITIVE)], зажигая [cig.declent_ru(GENITIVE)]."))

	playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)
	target.update_worn_mask()

/obj/item/lighter/process()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 1)
	return

// Zippo lighters
/obj/item/lighter/zippo
	name = "zippo lighter"
	desc = "A premium cigarette lighter, for cool and distinguished individuals."
	icon_state = "zippo"
	item_state = "zippo"
	icon_on = "zippo_on"
	icon_off = "zippo"
	lefthand_file = 'icons/mob/inhands/zippo_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/zippo_righthand.dmi'
	custom_price = PAYCHECK_LOWER

/obj/item/lighter/zippo/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_emote_observer, emote_key = "twirl")

/obj/item/lighter/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		user.balloon_alert(user, "потушите зажигалку!")
		return FALSE
	else
		return TRUE

/obj/item/lighter/zippo/turn_on_lighter(mob/living/user)
	. = ..()
	user.balloon_alert(user, "включено")
	if(world.time > next_on_message)
		user.visible_message(span_rose("Не отвлекаясь от дела, [user] одним плавным движением открыва[PLUR_ET_YUT(user)] и зажига[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)]."))
		playsound(src.loc, 'sound/items/zippolight.ogg', 25, TRUE)
		next_on_message = world.time + 5 SECONDS

/obj/item/lighter/zippo/turn_off_lighter(mob/living/user)
	. = ..()
	if(!user)
		return
	user.balloon_alert(user, "выключено")
	if(world.time > next_off_message)
		user.visible_message(span_rose("Вы слышите тихий щелчок, когда [user] закрыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)], даже не смотря в её сторону. Во даёт!"))
		playsound(src.loc, 'sound/items/zippoclose.ogg', 25, TRUE)
		next_off_message = world.time + 5 SECONDS

/obj/item/lighter/zippo/show_off_message(mob/living/user)
	return

/obj/item/lighter/zippo/attempt_light(mob/living/user)
	return

//EXTRA LIGHTERS
/obj/item/lighter/zippo/nt_rep
	name = "gold engraved zippo"
	desc = "A golden Zippo lighter with the letter \"N\" engraved on the front."
	icon_state = "zippo_nt"
	item_state = "ntzippo"
	icon_on = "zippo_nt_on"
	icon_off = "zippo_nt"

/obj/item/lighter/zippo/blue
	name = "blue zippo lighter"
	desc = "A zippo lighter made of some blue metal."
	icon_state = "blue_zippo"
	item_state = "bluezippo"
	icon_on = "blue_zippo_on"
	icon_off = "blue_zippo"

/obj/item/lighter/zippo/black
	name = "black zippo lighter"
	desc = "A black zippo lighter."
	icon_state = "black_zippo"
	item_state = "chapzippo"
	icon_on = "black_zippo_on"
	icon_off = "black_zippo"

/obj/item/lighter/zippo/engraved
	name = "engraved zippo lighter"
	desc = "A intricately engraved zippo lighter."
	icon_state = "engraved_zippo"
	item_state = "engravedzippo"
	icon_on = "engraved_zippo_on"
	icon_off = "engraved_zippo"

/obj/item/lighter/zippo/gonzofist
	name = "Gonzo Fist zippo"
	desc = "A Zippo lighter with the iconic Gonzo Fist on a matte black finish."
	icon_state = "gonzo_zippo"
	item_state = "gonzozippo"
	icon_on = "gonzo_zippo_on"
	icon_off = "gonzo_zippo"

/obj/item/lighter/zippo/cap
	name = "Captain's zippo"
	desc = "A limited edition gold Zippo espesially for NT Captains. Looks extremely expensive."
	icon_state = "zippo_cap"
	item_state = "capzippo"
	icon_on = "zippo_cap_on"
	icon_off = "zippo_cap"

/obj/item/lighter/zippo/hop
	name = "Head of Personnel zippo"
	desc = "A limited edition Zippo for NT Heads. Tries it best to look like captain's."
	icon_state = "zippo_hop"
	item_state = "hopzippo"
	icon_on = "zippo_hop_on"
	icon_off = "zippo_hop"

/obj/item/lighter/zippo/hos
	name = "Head of Security zippo"
	desc = "A limited edition Zippo for NT Heads. Fuel it with clown's tears."
	icon_state = "zippo_hos"
	item_state = "hoszippo"
	icon_on = "zippo_hos_on"
	icon_off = "zippo_hos"

/obj/item/lighter/zippo/cmo
	name = "Chief Medical Officer zippo"
	desc = "A limited edition Zippo for NT Heads. Made of hypoallergenic steel."
	icon_state = "zippo_cmo"
	item_state = "bluezippo"
	icon_on = "zippo_cmo_on"
	icon_off = "zippo_cmo"

/obj/item/lighter/zippo/ce
	name = "Chief Engineer zippo"
	desc = "A limited edition Zippo for NT Heads. Somebody've tried to repair cover with blue tape."
	icon_state = "zippo_ce"
	item_state = "cezippo"
	icon_on = "zippo_ce_on"
	icon_off = "zippo_ce"

/obj/item/lighter/zippo/rd
	name = "Research Director zippo"
	desc = "A limited edition Zippo for NT Heads. Uses advanced tech to make fire from plasma."
	icon_state = "zippo_rd"
	item_state = "rdzippo"
	icon_on = "zippo_rd_on"
	icon_off = "zippo_rd"

/obj/item/lighter/zippo/qm
	name = "Quartermaster Lighter"
	desc = "It costs 400.000 credits to fire this lighter for 12 seconds."
	icon_state = "zippo_qm"
	item_state = "qmzippo"
	icon_on = "zippo_qm_on"
	icon_off = "zippo_qm"

/obj/item/lighter/zippo/detective
	name = "Detective zippo"
	desc = "A limited-edition detective's Zippo lighter. It looks as if it came straight out of a film noir."
	icon_state = "zippo_dec"
	item_state = "deczippo"
	icon_on = "zippo_dec_on"
	icon_off = "zippo_dec"

/obj/item/lighter/zippo/contractor
	name = "contractor zippo lighter"
	desc = "An unique black and gold zippo commonly carried by elite Syndicate agents."
	icon_state = "contractor_zippo"
	item_state = "contractorzippo"
	icon_on = "contractor_zippo_on"
	icon_off = "contractor_zippo"

/obj/item/lighter/zippo/ninja
	name = "\"Shinobi on a rice field\" zippo"
	desc = "A custom made Zippo. It looks almost like a bag of noodles. There is a blood stain on it, and it smells like burnt rice..."
	icon_state = "zippo_ninja"
	item_state = "zippo_ninja"
	icon_on = "zippo_ninja_on"
	icon_off = "zippo_ninja"

/obj/item/lighter/zippo/purple
	name = "purple engraved zippo"
	desc = "All craftsspacemanship is of the highest quality. It is encrusted with refined plasma sheets. On the item is an image of a dwarf and the words 'Strike the Earth!' etched onto the side."
	icon_state = "purple_zippo"
	item_state = "purplezippo"
	icon_on = "purple_zippo_on"
	icon_off = "purple_zippo"

/obj/item/lighter/zippo/gold
	name = "gold lighter"
	desc = "An intricately engraved Zippo lighter made from real gold."
	icon_state = "gold_zippo"
	item_state = "goldzippo"
	icon_on = "gold_zippo_on"
	icon_off = "gold_zippo"

/obj/item/lighter/zippo/grenade
	name = "grenade lighter"
	desc = "A grenade-shaped lighter."
	icon_state = "grenade_lighter"
	item_state = "zippo_grenade"
	icon_on = "grenade_lighter_on"
	icon_off = "grenade_lighter"

/obj/item/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	gender = FEMALE
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	item_state = "match_unlit"
	heat = T1000K
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1"
	attack_verb = null
	pickup_sound = 'sound/items/handling/pickup/generic_small_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/generic_small_drop.ogg'
	var/lit = FALSE
	var/burnt = FALSE
	var/smoketime = 5

/obj/item/match/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		matchburnout()
	if(location)
		location.hotspot_expose(700, 1)

/obj/item/match/fire_act(exposed_temperature, exposed_volume)
	..()
	matchignite()

/obj/item/match/extinguish_light(force = FALSE)
	if(!force)
		return
	matchburnout()

/obj/item/match/update_icon_state()
	icon_state = lit ? "match_lit" : "match_burnt"
	item_state = lit ? "match_lit" : "match_burnt"

/obj/item/match/update_name(updates = ALL)
	. = ..()
	var/init_name = initial(name)
	name = lit ? "lit [init_name]" : burnt ? "burnt [init_name]" : initial(name)
	if(ru_names)
		if(lit)
			ru_names[NOMINATIVE] = "горящая спичка"
			ru_names[GENITIVE] = "горящей спички"
			ru_names[DATIVE] = "горящей спичке"
			ru_names[ACCUSATIVE] = "горящую спичку"
			ru_names[INSTRUMENTAL] = "горящей спичкой"
			ru_names[PREPOSITIONAL] = "горящей спичке"
		if(burnt)
			ru_names[NOMINATIVE] = "сгоревшая спичка"
			ru_names[GENITIVE] = "сгоревшей спички"
			ru_names[DATIVE] = "сгоревшей спичке"
			ru_names[ACCUSATIVE] = "сгоревшую спичку"
			ru_names[INSTRUMENTAL] = "сгоревшей спичкой"
			ru_names[PREPOSITIONAL] = "сгоревшей спичке"
		if(!lit && !burnt)
			ru_names = get_ru_names_cached()

/obj/item/match/update_desc(updates = ALL)
	. = ..()
	desc = lit ? "[capitalize(name)], engulfed in flame." : burnt ? "[capitalize(name)]. It has seen better days." : initial(desc)

/obj/item/match/get_temperature()
	return lit * heat

/obj/item/match/proc/matchignite()
	if(!lit && !burnt)
		lit = TRUE
		damtype = FIRE
		force = 3
		hitsound = 'sound/weapons/tap.ogg'
		attack_verb = list("подпалил","опалил")
		START_PROCESSING(SSobj, src)
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
		return TRUE

/obj/item/match/proc/matchburnout()
	if(lit)
		lit = FALSE
		burnt = TRUE
		damtype = BRUTE
		force = initial(force)
		attack_verb = list("чиркнул")
		STOP_PROCESSING(SSobj, src)
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
		return TRUE

/obj/item/match/dropped(mob/user, slot, silent = FALSE)
	matchburnout()
	. = ..()

/obj/item/match/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!lit)
		return ..()

	var/return_flags = ATTACK_CHAIN_PROCEED

	if(target.IgniteMob())
		return_flags |= ATTACK_CHAIN_SUCCESS
		add_attack_logs(user, target, "set on fire", ATKLOG_FEW)

	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(target)
	if(!cig || user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		return ..() | return_flags

	if(cig.lit)
		user.balloon_alert(user, "сигарета уже горит!")
		return return_flags

	if(target == user)
		return cig.attackby(src, user, params) | return_flags

	return_flags |= ATTACK_CHAIN_SUCCESS
	. = return_flags

	if(istype(src, /obj/item/match/unathi))
		if(prob(50))
			cig.light(span_rose("[user] изверга[PLUR_ET_YUT(user)] пламя на [target.declent_ru(ACCUSATIVE)] и зажига[PLUR_ET_YUT(user)] [cig.declent_ru(ACCUSATIVE)], чуть не опалив [GEND_HIS_HER(target)] лицо!"))
			matchburnout()
		else
			cig.light(span_rose("[user] изверга[PLUR_ET_YUT(user)] пламя на [target.declent_ru(ACCUSATIVE)] , опаливая [GEND_HIS_HER(target)] лицо и зажигая [cig.declent_ru(ACCUSATIVE)]."))
			target.apply_damage(5, BURN, def_zone = BODY_ZONE_HEAD)
			playsound(src, 'sound/effects/unathiignite.ogg', 40, FALSE)
	else
		cig.light(span_notice("[user] держ[PLUR_IT_AT(user)] [declent_ru(ACCUSATIVE)] у [target.declent_ru(GENITIVE)], и зажига[PLUR_ET_YUT(user)] [cig.declent_ru(ACCUSATIVE)]."))
		playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)

/obj/item/match/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(burnt)
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/proc/help_light_cig(mob/living/M)
	var/mask_item = M.get_item_by_slot(ITEM_SLOT_MASK)
	if(istype(mask_item, /obj/item/clothing/mask/cigarette))
		return mask_item

/obj/item/match/firebrand
	name = "firebrand"
	desc = "An unlit firebrand. It makes you wonder why it's not just called a stick."
	smoketime = 20 //40 seconds

/obj/item/match/firebrand/Initialize(mapload)
	. = ..()
	matchignite()

/obj/item/match/unathi
	name = "small blaze"
	desc = "A little flame of your own, currently located dangerously in your mouth."
	icon_state = "match_unathi"
	attack_verb = null
	item_flags = DROPDEL|ABSTRACT
	origin_tech = null
	lit = TRUE
	w_class = WEIGHT_CLASS_BULKY //to prevent it going to pockets

/obj/item/match/unathi/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/match/unathi/fire_act(exposed_temperature, exposed_volume)
	return	// we are already burning

/obj/item/match/unathi/matchburnout()
	if(!lit)
		return
	lit = FALSE //to avoid a qdel loop
	qdel(src)

/obj/item/match/unathi/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

