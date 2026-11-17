// MARK: Saddam's hideout
// An indestructible bunker buried in the asteroid. The only way in is the sealed wall,
// and the only key to it is a life fed to the rune in front of it.

/// How far the rune looks for the sealed walls it opens.
#define SADDAM_RUNE_DOOR_RANGE 3

/obj/effect/saddam_rune
	name = "blood-red rune"
	desc = "A circle drawn in something that dried a long time ago. A line is scratched beside it: \"A life for the passage\"."
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	color = "#c80000"
	anchored = TRUE
	layer = SIGIL_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 2
	light_power = 0.6
	light_color = "#ff2020"
	/// How long a creature has to stay on the rune before it is taken.
	var/charge_time = 2 SECONDS
	/// TRUE once the rune took its payment. It never works twice.
	var/spent = FALSE
	/// Creatures the rune is currently counting down for.
	var/list/mob/living/pending

/obj/effect/saddam_rune/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/saddam_rune/Destroy()
	pending = null
	return ..()

/obj/effect/saddam_rune/ex_act(severity, target)
	return

/obj/effect/saddam_rune/singularity_act()
	return

/obj/effect/saddam_rune/examine(mob/user)
	. = ..()
	if(spent)
		. += span_notice("Руна потускнела: плату она уже получила.")
	else
		. += span_warning("Руна едва заметно пульсирует, будто ждёт кого-то живого.")

/obj/effect/saddam_rune/proc/on_entered(datum/source, mob/living/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(spent || !isliving(arrived) || arrived.stat == DEAD)
		return
	if(arrived in pending)
		return
	LAZYADD(pending, arrived)
	visible_message(span_danger("Руна вспыхивает под [arrived]!"))
	to_chat(arrived, span_userdanger("Руна под вами наливается жаром. Что-то подсказывает: стоять здесь не стоит!"))
	playsound(src, 'sound/magic/blind.ogg', 50, TRUE)
	animate(src, color = "#ff5a3c", time = charge_time)
	addtimer(CALLBACK(src, PROC_REF(take_payment), arrived), charge_time)

/obj/effect/saddam_rune/proc/take_payment(mob/living/victim)
	LAZYREMOVE(pending, victim)
	if(spent)
		return
	if(QDELETED(victim) || victim.stat == DEAD || victim.loc != loc)
		if(!LAZYLEN(pending))
			animate(src, color = initial(color), time = 0.5 SECONDS)
		return

	spent = TRUE
	pending = null
	var/turf/our_turf = get_turf(src)
	visible_message(span_userdanger("Руна забирает плату: [victim] разлетается на куски! Где-то рядом скрежещет камень."))
	add_attack_logs(victim, victim, "Gibbed by the rune of Saddam's hideout")
	victim.gib()
	for(var/i in 1 to 4)
		var/obj/effect/decal/cleanable/blood/gibs/guts = new(our_turf)
		guts.streak(GLOB.alldirs)
	for(var/obj/structure/falsewall/saddam/sealed_wall in range(SADDAM_RUNE_DOOR_RANGE, src))
		sealed_wall.unseal()

	name = "spent rune"
	animate(src, color = "#3a0a0a", time = 2 SECONDS)
	set_light(0)

/// The sealed entrance. Looks and behaves exactly like the indestructible walls around it until the rune is paid.
/obj/structure/falsewall/saddam
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "r_wall-0"
	base_icon_state = "r_wall"
	walltype = /turf/simulated/wall/indestructible/reinforced
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	obj_flags = BLOCK_Z_IN_DOWN | BLOCK_Z_IN_UP | NODECONSTRUCT
	explosion_block = 50
	/// TRUE once the rune opened it. It stays open for good.
	var/unsealed = FALSE

/obj/structure/falsewall/saddam/examine_status(mob/user)
	return

/obj/structure/falsewall/saddam/toggle(mob/user)
	return

/obj/structure/falsewall/saddam/attack_hand(mob/user)
	return

/obj/structure/falsewall/saddam/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		unseal()

/obj/structure/falsewall/saddam/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/structure/falsewall/saddam/screwdriver_act(mob/living/user, obj/item/I)
	return TRUE

/obj/structure/falsewall/saddam/welder_act(mob/user, obj/item/I)
	return TRUE

/obj/structure/falsewall/saddam/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	balloon_alert(user, "нельзя деконструировать!")
	return RCD_NO_ACT

/obj/structure/falsewall/saddam/dismantle(mob/user, disassembled = TRUE)
	return

/obj/structure/falsewall/saddam/deconstruct(disassembled = TRUE)
	return

/obj/structure/falsewall/saddam/ex_act(severity, target)
	return

/obj/structure/falsewall/saddam/singularity_act()
	return

/obj/structure/falsewall/saddam/acid_act(acidpwr, acid_volume)
	return

/// Slides the wall aside for good.
/obj/structure/falsewall/saddam/proc/unseal()
	if(unsealed)
		return
	unsealed = TRUE
	opening = TRUE
	visible_message(span_warning("Участок стены со скрежетом уходит в сторону!"))
	playsound(src, 'sound/effects/stonedoor_openclose.ogg', 100, TRUE)
	do_the_flick()
	addtimer(CALLBACK(src, PROC_REF(finish_unsealing)), 0.4 SECONDS)

/obj/structure/falsewall/saddam/proc/finish_unsealing()
	set_density(FALSE)
	obj_flags &= ~BLOCK_Z_IN_DOWN
	set_opacity(FALSE)
	recalculate_atmos_connectivity()
	opening = FALSE
	update_icon(UPDATE_ICON_STATE)

#undef SADDAM_RUNE_DOOR_RANGE

// MARK: The man himself

/mob/living/simple_animal/saddam
	name = "Saddam Hussein"
	desc = "A solid red shape of a man, exactly as the diagram shows him. He lies at the bottom of his hole and has no intention of going anywhere."
	icon = 'icons/mob/asteroid_ruins.dmi'
	icon_state = "saddam"
	icon_living = "saddam"
	icon_dead = "saddam_dead"
	gender = MALE
	maxHealth = 120
	health = 120
	wander = FALSE
	stop_automated_movement = TRUE
	turns_per_move = 0
	response_help = "тычет"
	response_disarm = "толкает"
	response_harm = "бьёт"
	speak_emote = list("хрипит", "бормочет")
	emote_see = list("лежит строго по схеме", "поворачивается к вентилятору", "ворочается в яме")
	speak = list(
		"السلام عليكم.",
		"أنا صدام حسين، رئيس جمهورية العراق!",
		"أنا مستعد للتفاوض.",
		"لا تطلقوا النار!",
		"الله أكبر!",
		"عاش العراق!",
		"أين المروحة؟ الجو حار هنا.",
		"هذه الحفرة ملكي.",
		"من أنتم؟ اخرجوا من حفرتي!",
		"أم المعارك لم تنتهِ بعد.",
	)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	gold_core_spawnable = NO_SPAWN
	deathmessage = "хрипит что-то напоследок и затихает. Из него выпадает чемодан."
	loot = list(/obj/item/storage/briefcase/saddam)
	/// Pause between his remarks.
	var/speech_cooldown_min = 25 SECONDS
	var/speech_cooldown_max = 60 SECONDS
	COOLDOWN_DECLARE(speech_cooldown)

/mob/living/simple_animal/saddam/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_BREATH, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, INNATE_TRAIT)

/mob/living/simple_animal/saddam/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/saddam/handle_automated_movement()
	return

/mob/living/simple_animal/saddam/handle_automated_speech(override)
	if(!override && !COOLDOWN_FINISHED(src, speech_cooldown))
		return
	COOLDOWN_START(src, speech_cooldown, rand(speech_cooldown_min, speech_cooldown_max))
	if(prob(25))
		custom_emote(EMOTE_VISIBLE, pick(emote_see))
		return
	say(pick(speak), sanitize = FALSE)

/obj/item/storage/briefcase/saddam
	name = "dusty briefcase"
	desc = "A worn leather briefcase that spent years in a hole next to its owner. It is heavier than it looks."

/obj/item/storage/briefcase/saddam/populate_contents()
	new /obj/item/stack/spacecash(src, 75000)
	new /obj/item/gun/projectile/automatic/pistol/stechkin(src)

/// The fan from the hole. Already running.
/obj/item/toy/desk/fan/saddam
	name = "hideout fan"
	desc = "An ordinary office fan. It has been blowing stale air around a hole in the ground for a very long time."

/obj/item/toy/desk/fan/saddam/Initialize(mapload)
	. = ..()
	on = TRUE
	update_icon(UPDATE_ICON_STATE)
	soundloop.start()

/obj/item/paper/fluff/ruins/saddam_hideout
	name = "crumpled note"
	info = "<i>Wall sealed from the inside. Nobody is coming in unless they are willing to pay the rune. The air comes through the pipe, the fan works, the money is with me. I can wait as long as it takes.</i>"
