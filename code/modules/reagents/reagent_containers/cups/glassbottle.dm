#define BOTTLE_KNOCKDOWN_DEFAULT_DURATION (1.3 SECONDS)

// MARK: Base Bottle
/obj/item/reagent_containers/cup/glass/bottle
	volume = 100
	force = 15 //Smashing bottles over someone's head hurts.
	throwforce = 15
	item_state = "broken_beer"
	custom_price = PAYCHECK_LOWER
	var/broken_inhand_icon_state = "broken_beer"
	/// Directly relates to the `knockdown` duration. Lowered by armor (i.e. helmets).
	var/bottle_knockdown_duration = BOTTLE_KNOCKDOWN_DEFAULT_DURATION

/obj/item/reagent_containers/cup/glass/bottle/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	. = ..()

	if(isliving(target) && user.a_intent == INTENT_HARM && is_glass)
		context[SCREENTIP_CONTEXT_RMB] = "Разбить бутылку о цель"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/reagent_containers/cup/glass/bottle/interact_with_atom_secondary(atom/target, mob/living/user, list/modifiers)
	if(user.a_intent == INTENT_HARM)
		return ..()

/obj/item/reagent_containers/cup/glass/bottle/afterattack(atom/target, mob/user, proximity_flag, list/modifiers)
	if(!LAZYACCESS(modifiers, RIGHT_CLICK) || user.a_intent != INTENT_HARM || !is_glass || !proximity_flag)
		return

	if(HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		to_chat(user, span_warning("Вы не хотите навредить [target.declent_ru(DATIVE)]!"))
		return

	var/head_hitter = user.zone_selected == BODY_ZONE_HEAD && isliving(target)
	if(!QDELETED(target))
		// An attack that targets the head of a living mob will attempt to knock them down
		if(head_hitter)
			var/mob/living/living_target = target
			var/knockdown_effectiveness = bottle_knockdown_duration + ((force / 10) * 1 SECONDS) - living_target.getarmor(BODY_ZONE_HEAD, MELEE)
			if(prob(knockdown_effectiveness))
				living_target.Knockdown(min(knockdown_effectiveness, 20 SECONDS))

	// Displays a custom message which follows the attack
	if(target == user)
		user.visible_message(
			span_warning("[user] разбива[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] [head_hitter ? "о свою голову" : "об себя"]!"),
			span_warning("Вы разбиваете [declent_ru(ACCUSATIVE)] [head_hitter ? "о свою голову" : "об себя"]!"),
		)

	else
		user.visible_message(
			span_warning("[user] разбива[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] [head_hitter ? "о голову [target.declent_ru(GENITIVE)]" : "об [target.declent_ru(ACCUSATIVE)]"]!"),
			span_warning("Вы разбиваете [declent_ru(ACCUSATIVE)] [head_hitter ? "о голову [target.declent_ru(GENITIVE)]" : "об [target.declent_ru(ACCUSATIVE)]"]!"),
		)

	// Finally, smash the bottle. This kills (del) the bottle and also does all the logging for us
	smash(target, user)

/obj/item/reagent_containers/cup/glass/bottle/post_smash(atom/target, atom/thrower, datum/thrownthing/throwingdatum, obj/item/broken_bottle/broken)
	if(!throwingdatum && ismob(thrower))
		astype(thrower, /mob).put_in_hands(broken)
	broken.item_state = broken_inhand_icon_state

/obj/item/reagent_containers/cup/glass/bottle/try_splash(mob/user, atom/target)
	if(!is_glass)
		return ..()
	return FALSE // instead of splashing, hit them with the bottle!

/obj/item/reagent_containers/cup/glass/bottle/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!reagents.total_volume)
		C.stored_comms["glass"] += 3
		qdel(src)
		return TRUE
	return ..()

// MARK: Broken Bottle
/obj/item/broken_bottle
	name = "broken bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	item_state = "beer"
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("уколол", "полоснул", "поранил")
	var/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")
	sharp = 1
	embed_chance = 10
	embedded_ignore_throwspeed_threshold = TRUE

/obj/item/broken_bottle/decompile_act(obj/item/matter_decompiler/C, mob/user)
	C.stored_comms["glass"] += 3
	qdel(src)
	return TRUE

/// Mimics the appearance and properties of the passed in bottle.
/// Takes the broken bottle to mimic, and the thing the bottle was broken agaisnt as args
/obj/item/broken_bottle/proc/mimic_broken(obj/item/reagent_containers/cup/glass/to_mimic, atom/target)
	icon_state = to_mimic.icon_state
	var/icon/drink_icon = new('icons/obj/drinks.dmi', icon_state)
	drink_icon.Blend(broken_outline, ICON_OVERLAY, rand(5), 1)
	drink_icon.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	icon = drink_icon

	if(istype(to_mimic, /obj/item/reagent_containers/cup/glass/bottle/juice))
		force = 0
		throwforce = 0
		set_ru_names_suffix(" (разорван[GEND_A_O_Y(to_mimic)])")
		desc = "A carton with its bottom torn open. Watch out for paper cuts."
	else
		if(prob(33))
			var/obj/item/shard/stab_with = new(to_mimic.drop_location())
			target.Bumped(stab_with)
		playsound(src, SFX_SHATTER, 70, TRUE)
	name = "broken [to_mimic.name]"
	set_ru_names_suffix(" (разбит[GEND_A_O_Y(to_mimic)])")
	to_mimic.transfer_fingerprints_to(src)

// MARK: Alcohole Bottles
/obj/item/reagent_containers/cup/glass/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	list_reagents = list("gin" = 100)

/obj/item/reagent_containers/cup/glass/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	list_reagents = list("whiskey" = 100)

/obj/item/reagent_containers/cup/glass/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians galaxy-wide."
	icon_state = "vodkabottle"
	list_reagents = list("vodka" = 100)

/obj/item/reagent_containers/cup/glass/bottle/vodka/badminka
	name = "Badminka Vodka"
	desc = "The label's written in Cyrillic. All you can make out is the name and a word that looks vaguely like 'Vodka'."
	icon_state = "badminka"
	list_reagents = list("vodka" = 100)

/obj/item/reagent_containers/cup/glass/bottle/tequila
	name = "Caccavo Guaranteed Quality Tequila"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequilabottle"
	list_reagents = list("tequila" = 100)

/obj/item/reagent_containers/cup/glass/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing."
	icon_state = "bottleofnothing"
	list_reagents = list("nothing" = 100)

/obj/item/reagent_containers/cup/glass/bottle/bottleofbanana
	name = "Jolly Jug"
	desc = "A jug filled with banana juice."
	icon_state = "bottleofjolly"
	list_reagents = list("banana" = 100)

/obj/item/reagent_containers/cup/glass/bottle/patron
	name = "Roca Patron Silver"
	desc = "Silver laced tequila, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	list_reagents = list("patron" = 100)

/obj/item/reagent_containers/cup/glass/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	list_reagents = list("rum" = 100)

/obj/item/reagent_containers/cup/glass/bottle/holywater
	name = "flask of holy water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"
	list_reagents = list("holywater" = 100)

/obj/item/reagent_containers/cup/glass/bottle/holywater/hell
	desc = "A flask of holy water...it's been sitting in the Necropolis a while though."
	list_reagents = list("hell_water" = 100)

/obj/item/reagent_containers/cup/glass/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	list_reagents = list("vermouth" = 100)

/obj/item/reagent_containers/cup/glass/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK."
	icon_state = "kahluabottle"
	list_reagents = list("kahlua" = 100)

/obj/item/reagent_containers/cup/glass/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	list_reagents = list("goldschlager" = 100)

/obj/item/reagent_containers/cup/glass/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alcoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	list_reagents = list("cognac" = 100)

/obj/item/reagent_containers/cup/glass/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	list_reagents = list("wine" = 100)

/obj/item/reagent_containers/cup/glass/bottle/absinthe
	name = "Yellow Marquee Absinthe"
	desc = "A strong alcoholic drink brewed and distributed by Yellow Marquee."
	icon_state = "absinthebottle"
	list_reagents = list("absinthe" = 100)

/obj/item/reagent_containers/cup/glass/bottle/absinthe/premium
	name = "Gwyn's Premium Absinthe"
	desc = "A potent alcoholic beverage, almost makes you forget the ash in your lungs."
	icon_state = "absinthepremium"

/obj/item/reagent_containers/cup/glass/bottle/hcider
	name = "Jian Hard Cider"
	desc = "Apple juice for adults."
	icon_state = "hcider"
	volume = 50
	list_reagents = list("suicider" = 50)

/obj/item/reagent_containers/cup/glass/bottle/fernet
	name = "Fernet Bronca"
	desc = "A bottle of pure Fernet Bronca, produced in Cordoba Space Station."
	icon_state = "fernetbottle"
	list_reagents = list("fernet" = 100)

/obj/item/reagent_containers/cup/glass/bottle/champagne
	name = "Sparkling Sunny Champagne"
	desc = "A bottle of pure sizzling sun, ready to hit your brain."
	icon_state = "champagnebottle"
	list_reagents = list("champagne" = 100)

/obj/item/reagent_containers/cup/glass/bottle/aperol
	name = "Jungle Aperol Aperitivo"
	desc = "A true aperitif experienced in the most remote jungle."
	icon_state = "aperolbottle"
	list_reagents = list("aperol" = 100)

/obj/item/reagent_containers/cup/glass/bottle/jagermeister
	name = "Infused Space Jaegermeister"
	desc = "Das ist des Jägers Ehrenschild, daß er beschützt und hegt sein Wild, weidmännisch jagt, wie sich gehört, den Schöpfer im Geschöpfe ehrt."
	icon_state = "jagermeisterbottle"
	list_reagents = list("jagermeister" = 100)

/obj/item/reagent_containers/cup/glass/bottle/schnaps
	name = "Grainy Mint Schnapps"
	desc = "A real horror for a true connoisseur, high-quality mint schnapps."
	icon_state = "schnapsbottle"
	list_reagents = list("schnaps" = 100)

/obj/item/reagent_containers/cup/glass/bottle/sheridan
	name = "Sheridan's Coffee Layered"
	desc = "A double miracle with a new innovative neck, much better than yours."
	icon_state = "sheridanbottle"
	list_reagents = list("sheridan" = 100)

/obj/item/reagent_containers/cup/glass/bottle/bitter
	name = "Vacuum Cherry Bitter"
	desc = "Try not to suffocate after drinking such wonderful bitterness."
	icon_state = "bitterbottle"
	list_reagents = list("bitter" = 50)

/obj/item/reagent_containers/cup/glass/bottle/bluecuracao
	name = "Grenadier Blue Curacao"
	desc = "The explosion is an art, but the blue explosion is much better."
	icon_state = "bluecuracao"
	list_reagents = list("bluecuracao" = 100)

/obj/item/reagent_containers/cup/glass/bottle/sambuka
	name = "The Headless Horseman's Sambuka"
	desc = "I haven't drunk sambuca since I was twenty."
	icon_state = "sambukabottle"
	list_reagents = list("sambuka" = 100)

/obj/item/reagent_containers/cup/glass/bottle/arrogant_green_rat
	name = "Arrogant Green Rat"
	desc = "Finest wine from the Paradise City, where the grass is green and the girls are pretty."
	icon_state = "arrogant_green_rat"
	list_reagents = list("wine" = 100)

/**
 * Subtype of glass that don't break, and share a common carton hand state.
 * Meant to be a subtype for use in Molotovs.
 */
/obj/item/reagent_containers/cup/glass/bottle/juice
	item_state = "carton"
	throwforce = 0
	is_glass = FALSE

/obj/item/reagent_containers/cup/glass/bottle/juice/orangejuice
	name = "orange juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	list_reagents = list("orangejuice" = 100)

/obj/item/reagent_containers/cup/glass/bottle/juice/cream
	name = "milk cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	list_reagents = list("cream" = 100)

/obj/item/reagent_containers/cup/glass/bottle/juice/tomatojuice
	name = "tomato juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	list_reagents = list("tomatojuice" = 100)

/obj/item/reagent_containers/cup/glass/bottle/juice/limejuice
	name = "lime juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	list_reagents = list("limejuice" = 100)

/obj/item/reagent_containers/cup/glass/bottle/juice/milk
	name = "milk"
	desc = "Soothing milk."
	icon_state = "milk"
	list_reagents = list("milk" = 100)

/obj/item/reagent_containers/cup/glass/bottle/molotov
	name = "molotov cocktail"
	desc = "A throwing weapon used to ignite things, typically filled with an accelerant. Recommended highly by rioters and revolutionaries. Light and toss."
	icon_state = "vodkabottle"
	list_reagents = list()
	var/static/list/accelerants = list(
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fuel,
		/datum/reagent/clf3,
		/datum/reagent/phlogiston,
		/datum/reagent/napalm,
		/datum/reagent/hellwater,
		/datum/reagent/plasma,
		/datum/reagent/plasma_dust
	)
	var/active = FALSE

/obj/item/reagent_containers/cup/glass/bottle/molotov/update_desc(updates = ALL)
	. = ..()
	desc = initial(desc)
	if(!is_glass)
		desc += " You're not sure making this out of a carton was the best idea."

/obj/item/reagent_containers/cup/glass/bottle/molotov/update_icon_state()
	var/obj/item/reagent_containers/cup/glass/bottle/bottle = locate() in contents
	if(bottle)
		icon_state = bottle.icon_state

/obj/item/reagent_containers/cup/glass/bottle/molotov/update_overlays()
	. = ..()
	if(active)
		. += GLOB.fire_overlay

/obj/item/reagent_containers/cup/glass/bottle/molotov/CheckParts(list/parts_list)
	..()
	var/obj/item/reagent_containers/cup/glass/bottle/bottle = locate() in contents
	if(bottle)
		bottle.reagents.copy_to(src, 100)
		if(!bottle.is_glass)
			is_glass = FALSE
		update_appearance(UPDATE_DESC|UPDATE_ICON)

/obj/item/reagent_containers/cup/glass/bottle/molotov/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum, do_splash = FALSE)
	..(hit_atom, throwingdatum, do_splash = FALSE)

/obj/item/reagent_containers/cup/glass/bottle/molotov/smash(atom/target, mob/thrower, datum/thrownthing/throwingdatum, break_top)
	var/firestarter = FALSE
	for(var/datum/reagent/contained_reagent in reagents.reagent_list)
		for(var/accelerant_type in accelerants)
			if(istype(contained_reagent, accelerant_type))
				firestarter = TRUE
				break
	..()
	if(firestarter && active)
		if(!QDELETED(target))
			target.fire_act()
		new /obj/effect/hotspot/fake(get_turf(target))

/obj/item/reagent_containers/cup/glass/bottle/molotov/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !I.get_temperature())
		return .

	add_fingerprint(user)
	if(active)
		to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] уже горит."))
		return .
	. |= ATTACK_CHAIN_SUCCESS
	active = TRUE
	var/turf/bombturf = get_turf(src)
	message_admins("[ADMIN_LOOKUP(user)] has primed a [name] for detonation at [ADMIN_COORDJMP(bombturf)].")
	add_game_logs("has primed a [name] for detonation at [AREACOORD(bombturf)].", user)
	user.visible_message(
		span_danger("[user] поджигает [declent_ru(ACCUSATIVE)]!"),
		span_notice("Вы поджигаете [declent_ru(ACCUSATIVE)]."),
	)
	add_overlay(GLOB.fire_overlay)
	if(!is_glass)
		addtimer(CALLBACK(src, PROC_REF(explode), 5 SECONDS))

/obj/item/reagent_containers/cup/glass/bottle/molotov/proc/explode()
	if(!active)
		return
	if(get_turf(src))
		var/atom/target = loc
		for(var/i in 1 to 2)
			if(isstorage(target))
				target = target.loc
		splash_reagents(target, allow_closed_splash = TRUE)
		target.fire_act()
	qdel(src)

/obj/item/reagent_containers/cup/glass/bottle/molotov/attack_self(mob/user)
	if(active)
		if(!is_glass)
			to_chat(user, span_danger("Пламя распространилось уже слишком далеко!"))
			return
		to_chat(user, span_notice("Вы гасите пламя у [declent_ru(GENITIVE)]."))
		active = FALSE
		update_icon(UPDATE_OVERLAYS)

#undef BOTTLE_KNOCKDOWN_DEFAULT_DURATION
