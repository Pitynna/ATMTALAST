/obj/item/storage/pill_bottle/dice
	name = "dice pack"
	desc = "Contains all the luck you'll ever need."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"
	can_hold = list(/obj/item/dice)
	allow_wrap = FALSE

/obj/item/storage/pill_bottle/dice/populate_contents()
	var/special_die = pick("1", "2", "fudge", "00", "100")
	if(special_die == "1")
		new /obj/item/dice/d1(src)
	if(special_die == "2")
		new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d6(src)
	if(special_die == "fudge")
		new /obj/item/dice/fudge(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	if(special_die == "00")
		new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)
	if(special_die == "100")
		new /obj/item/dice/d100(src)

/obj/item/storage/box/dice
	name = "Box of dice"
	desc = "ANOTHER ONE!? FUCK!"

/obj/item/storage/box/dice/populate_contents()
	new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)

/obj/item/storage/pill_bottle/dice/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] игра[PLUR_ET_YUT(user)] со смертью! Похоже, он[GEND_A_O_I(user)] пыта[PLUR_ET_YUT(user)]ся покончить жизнь самоубийством!"))
	return (OXYLOSS)

/obj/item/dice //depreciated d6, use /obj/item/dice/d6 if you actually want a d6
	name = "dice"
	desc = "A die with six sides. Basic and serviceable."
	gender = FEMALE
	icon = 'icons/obj/dice.dmi'
	icon_state = "d6"
	w_class = WEIGHT_CLASS_TINY

	var/sides = 6
	var/result = null
	var/list/special_faces = list() //entries should match up to sides var if used

	var/rigged = DICE_NOT_RIGGED
	var/rigged_value

/obj/item/dice/Initialize(mapload)
	. = ..()
	if(!result)
		result = roll(sides)
	update_icon(UPDATE_OVERLAYS)

/obj/item/dice/update_overlays()
	. = ..()
	. += "[icon_state][result]"

/obj/item/dice/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] играет со смертью! Похоже [user.p_theyre()] пытается покончить жизнь самоубийством!"))
	return (OXYLOSS)

/obj/item/dice/d1
	name = "d1"
	desc = "A die with one side. Deterministic!"
	icon_state = "d1"
	sides = 1

/obj/item/dice/d2
	name = "d2"
	desc = "A die with two sides. Coins are undignified!"
	icon_state = "d2"
	sides = 2

/obj/item/dice/d4
	name = "d4"
	desc = "A die with four sides. The nerd's caltrop."
	icon_state = "d4"
	sides = 4

/obj/item/dice/d4/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 1, 4) //1d4 damage

/obj/item/dice/d6
	name = "d6"

/obj/item/dice/fudge
	name = "fudge die"
	desc = "A die with six sides but only three results. Is this a plus or a minus? Your mind is drawing a blank..."
	sides = 3
	icon_state = "fudge"
	special_faces = list("minus","blank","plus")

/obj/item/dice/d8
	name = "d8"
	desc = "A die with eight sides. It feels... lucky."
	icon_state = "d8"
	sides = 8

/obj/item/dice/d10
	name = "d10"
	desc = "A die with ten sides. Useful for percentages."
	icon_state = "d10"
	sides = 10

/obj/item/dice/d00
	name = "d00"
	desc = "A die with ten sides. Works better for d100 rolls than a golf ball."
	icon_state = "d00"
	sides = 10

/obj/item/dice/d12
	name = "d12"
	desc = "A die with twelve sides. There's an air of neglect about it."
	icon_state = "d12"
	sides = 12

/obj/item/dice/d20
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."
	icon_state = "d20"
	sides = 20

/obj/item/dice/d100
	name = "d100"
	desc = "A die with one hundred sides! Probably not fairly weighted..."
	icon_state = "d100"
	sides = 100

/obj/item/dice/d100/update_overlays()
	return list()

/obj/item/dice/d20/e20
	var/triggered = FALSE

/obj/item/dice/attack_self(mob/user)
	diceroll(user)

/obj/item/dice/throw_impact(atom/target, datum/thrownthing/throwingdatum)
	diceroll(locateUID(thrownby))
	. = ..()

/obj/item/dice/proc/diceroll(mob/user)
	result = roll(sides)
	if(rigged != DICE_NOT_RIGGED && result != rigged_value)
		if(rigged == DICE_BASICALLY_RIGGED && prob(clamp(1 / (sides - 1) * 100, 25, 80)))
			result = rigged_value
		else if(rigged == DICE_TOTALLY_RIGGED)
			result = rigged_value

	. = result

	var/fake_result = roll(sides)//Daredevil isn't as good as he used to be
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "ДВАДЦАТКА!"
	else if(sides == 20 && result == 1)
		comment = "М-да, невезуха."
	update_icon(UPDATE_OVERLAYS)
	if(initial(icon_state) == "d00")
		result = (result - 1) * 10
	if(length(special_faces) == sides)
		result = special_faces[result]
	if(user != null) //Dice was rolled in someone's hand
		user.visible_message(
			"[user] броса[PLUR_ET_YUT(user)] [src.name]. На [src.name] выпадает [result]. [comment]",
			span_notice("Вы бросили [src.name] и выпало [result]. [comment]"),
			span_italics("Вы слышите как катится [src.name], звучит как [fake_result].")
		)
	else if(!throwing) //Dice was thrown and is coming to rest
		visible_message(span_notice("[src.name] прекращает катиться, остановившись на [result]. [comment]"))

/obj/item/dice/d20/e20/diceroll(mob/user, thrown)
	if(triggered)
		return

	. = ..()

	if(result == 1)
		to_chat(user, span_danger("На вас упали камни и вы умерли."))
		user.gib()
		add_attack_logs(src, user, "detonated with a roll of [result], gibbing them!", ATKLOG_FEW)
	else
		triggered = TRUE
		visible_message(span_notice("Вы слышите тихий щелчок."))
		addtimer(CALLBACK(src, PROC_REF(boom), user, result), 4 SECONDS)

/obj/item/dice/d20/e20/proc/boom(mob/user, result)
	var/capped = FALSE
	var/actual_result = result
	if(result != 20)
		capped = TRUE
		result = min(result, GLOB.max_ex_light_range) // Apply the bombcap
	else // Rolled a nat 20, screw the bombcap
		result = 24

	var/turf/epicenter = get_turf(src)
	investigate_log("E20 detonated with a roll of [actual_result]. Triggered by: [key_name_log(user)]", INVESTIGATE_BOMB)
	add_game_logs("threw E20, detonating at [AREACOORD(epicenter)] with a roll of [actual_result].", user)
	add_attack_logs(user, src, "detonated with a roll of [actual_result]", ATKLOG_FEW)
	explosion(epicenter, devastation_range = round(result * 0.25), heavy_impact_range = round(result * 0.5), light_impact_range = round(result), flash_range = round(result * 1.5), adminlog = TRUE, ignorecap = capped, cause = (key_name(user)+" E20"))

// Die of Fate
/obj/item/dice/d20/fate
	name = "Die of Fate"
	desc = "A die with twenty sides. You can feel unearthly energies radiating from it. Using this might be VERY risky."
	var/reusable = TRUE
	var/used = FALSE

/obj/item/dice/d20/fate/stealth
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."

/obj/item/dice/d20/fate/one_use
	reusable = FALSE

/obj/item/dice/d20/fate/one_use/stealth
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."

/obj/item/dice/d20/fate/cursed
	name = "cursed Die of Fate"
	desc = "A die with twenty sides. You feel that rolling this is a REALLY bad idea."
	color = "#00BB00"

	rigged = DICE_TOTALLY_RIGGED
	rigged_value = 1

/obj/item/dice/d20/fate/diceroll(mob/user)
	. = ..()
	if(!used)
		if(!ishuman(user) || !user.mind || (user.mind in SSticker.mode.wizards))
			to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] отказывается вам подчиняться!"))
			return

		if(!reusable)
			used = TRUE

		var/turf/T = get_turf(src)
		T.visible_message(span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] ярко вспыхива[PLUR_ET_YUT(src)]!"))

		addtimer(CALLBACK(src, PROC_REF(effect), user, .), 1 SECONDS)

/obj/item/dice/d20/fate/equipped(mob/user, slot, initial)
	. = ..()

	if(!ishuman(user) || !user.mind || (user.mind in SSticker.mode.wizards))
		to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] отказывается вам подчиняться!"))
		user.drop_item_ground(src)

/obj/item/dice/d20/fate/proc/effect(mob/living/carbon/human/user, roll)
	var/datum/dice_roll/d_action = GLOB.dice_rolls[roll]
	d_action.activate(user, src)
