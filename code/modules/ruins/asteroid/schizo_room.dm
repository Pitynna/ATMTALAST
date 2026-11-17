// MARK: The schizo room
// A tiny studio lost in the rock: two men at a big table, a camera on a tripod and a poster that should not be hung anywhere.

/// The count of the ancient schizos, in order.
GLOBAL_LIST_INIT(schizo_count, list(
	"Ноль!",
	"Целковый!",
	"Чекушка!",
	"Порнушка!",
	"Засерушка!",
	"Пердушка!",
	"Жучок!",
	"Мудачок!",
	"Хуй на воротничок!",
	"Дурачок!",
	"Так считали наши шизопредки!",
))

/mob/living/simple_animal/schizo
	name = "studio guest"
	icon = 'icons/mob/asteroid_ruins.dmi'
	gender = MALE
	maxHealth = 80
	health = 80
	wander = FALSE
	stop_automated_movement = TRUE
	turns_per_move = 0
	response_help = "тычет"
	response_disarm = "толкает"
	response_harm = "бьёт"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	gold_core_spawnable = NO_SPAWN
	/// Pause between the remarks this guest makes on his own.
	var/speech_cooldown_min = 90 SECONDS
	var/speech_cooldown_max = 180 SECONDS
	COOLDOWN_DECLARE(speech_cooldown)

/mob/living/simple_animal/schizo/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_BREATH, INNATE_TRAIT)
	// The broadcast should not start the very second somebody digs in.
	COOLDOWN_START(src, speech_cooldown, rand(10 SECONDS, 30 SECONDS))

/mob/living/simple_animal/schizo/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/schizo/handle_automated_movement()
	return

/mob/living/simple_animal/schizo/handle_automated_speech(override)
	if(!override && !COOLDOWN_FINISHED(src, speech_cooldown))
		return
	COOLDOWN_START(src, speech_cooldown, rand(speech_cooldown_min, speech_cooldown_max))
	speak_up()

/// What the guest does when his turn to talk comes.
/mob/living/simple_animal/schizo/proc/speak_up()
	return

/// Says a line if the guest is still able to.
/mob/living/simple_animal/schizo/proc/say_line(line)
	if(QDELETED(src) || stat != CONSCIOUS)
		return FALSE
	say(line)
	return TRUE

// MARK: Rybnikov

/mob/living/simple_animal/schizo/rybnikov
	name = "Yuri Rybnikov"
	desc = "A grey-haired man in a charcoal suit. He knows how the ancient schizos counted and will not let you leave without hearing it."
	icon_state = "rybnikov"
	icon_living = "rybnikov"
	icon_dead = "rybnikov_dead"
	speak_emote = list("вещает", "чеканит")
	deathmessage = "роняет голову на стол. Счёт древних шизов оборвался."
	/// Things he shouts between the lectures.
	var/static/list/rants = list(
		"А нам навязывают ложную математику, чтобы грабить нас, шизов!",
		"ШИЗЫ — СВЕРХЛЮДИ!",
		"НАС ОПЯТЬ ОБМАНУЛИ!",
		"Я ДАМ ВСЕМ В РОТ, И НЬЮТОНУ, И ЭНШТЕЙНУ!",
	)
	/// Pause between the numbers of the count.
	var/count_step = 1.5 SECONDS
	/// TRUE while he is in the middle of the count.
	var/lecturing = FALSE

/mob/living/simple_animal/schizo/rybnikov/speak_up()
	if(lecturing)
		return
	if(prob(40))
		if(say_line(pick(rants)))
			ask_for_reaction(2 SECONDS)
		return
	lecturing = TRUE
	say_line("Каждый уважающий себя математик должен знать счёт древних шизов.")
	addtimer(CALLBACK(src, PROC_REF(count_on), 1), count_step * 2)

/// Says the next number of the count and schedules the one after it.
/mob/living/simple_animal/schizo/rybnikov/proc/count_on(index)
	if(!say_line(GLOB.schizo_count[index]))
		lecturing = FALSE
		return
	if(index >= length(GLOB.schizo_count))
		lecturing = FALSE
		if(prob(50))
			addtimer(CALLBACK(src, PROC_REF(say_line), rants[1]), count_step * 2)
			ask_for_reaction(count_step * 4)
		else
			ask_for_reaction(count_step * 2)
		return
	addtimer(CALLBACK(src, PROC_REF(count_on), index + 1), count_step)

/// Lets the host across the table get a word in.
/mob/living/simple_animal/schizo/rybnikov/proc/ask_for_reaction(delay)
	for(var/mob/living/simple_animal/schizo/boyarshinov/host in view(4, src))
		addtimer(CALLBACK(host, TYPE_PROC_REF(/mob/living/simple_animal/schizo/boyarshinov, react)), delay)

// MARK: Boyarshinov

/mob/living/simple_animal/schizo/boyarshinov
	name = "Boris Boyarshinov"
	desc = "A bearded host in a black suit and a red tie. He listens very, very attentively."
	icon_state = "boyarshinov"
	icon_living = "boyarshinov"
	icon_dead = "boyarshinov_dead"
	speak_emote = list("кивает и говорит", "задумчиво произносит")
	deathmessage = "сползает под стол. Спасибо ему огромное."
	speech_cooldown_min = 150 SECONDS
	speech_cooldown_max = 300 SECONDS
	var/static/list/remarks = list(
		"Это сильно.",
		"Так.",
		"Так-так.",
		"Ага.",
		"Спасибо вам огромное.",
		"Вы-то раскройте мне, кто такие шизы-то?",
	)

/mob/living/simple_animal/schizo/boyarshinov/speak_up()
	react()

/// A remark, now and then with the roof-over-the-head gesture.
/mob/living/simple_animal/schizo/boyarshinov/proc/react()
	if(QDELETED(src) || stat != CONSCIOUS)
		return
	if(prob(30))
		flick("boyarshinov_roof", src)
		custom_emote(EMOTE_VISIBLE, "складывает руки домиком над головой")
		return
	say_line(pick(remarks))

// MARK: The poster

/obj/item/poster/schizo_count
	name = "rolled-up poster"
	poster_type = /obj/structure/sign/poster/contraband/schizo_count
	icon = 'icons/obj/asteroid_ruins.dmi'
	icon_state = "rolled_schizo_poster"

/obj/structure/sign/poster/contraband/schizo_count
	name = "Ancient Periodic System of the Schizos"
	desc = "RUSSIAN ORTHODOX ELEMENTARY SYSTEM OF THE UNITY OF PERIODICITY OF THE ELECTRO-ATOMS OF THE UNIVERSE, volumetric edition. \
		Beads on a string inside a bubble inside a bigger bubble, two to the power of n, one divided by two to the power of n, and the author's portrait so you know whom to thank. \
		Official science has been hiding it since 1997. You feel a strong urge to start counting out loud."
	icon = 'icons/obj/asteroid_ruins.dmi'
	icon_state = "schizo_poster"
	never_random = TRUE
	poster_item_name = "strange poster"
	poster_item_desc = "A rolled-up poster on lilac paper. Something inside it is quietly counting. It is probably a bad idea to hang it where people can see it."
	poster_item_icon_state = "rolled_schizo_poster"
	/// How often everybody who sees the poster shouts the next number.
	var/shout_delay = 10 SECONDS
	/// How far the poster reaches.
	var/shout_range = 7
	/// The number the next shout will be.
	var/count_index = 1
	COOLDOWN_DECLARE(shout_cooldown)

/obj/structure/sign/poster/contraband/schizo_count/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/sign/poster/contraband/schizo_count/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/sign/poster/contraband/schizo_count/roll_and_drop(loc, mob/user)
	var/obj/item/poster/rolled = ..()
	if(rolled)
		rolled.icon = icon
	return rolled

/obj/structure/sign/poster/contraband/schizo_count/process()
	// Rolled up inside the item it is harmless; it only works while it hangs.
	if(ruined || !isturf(loc))
		count_index = 1
		return
	if(!COOLDOWN_FINISHED(src, shout_cooldown))
		return
	COOLDOWN_START(src, shout_cooldown, shout_delay)
	var/line = GLOB.schizo_count[count_index]
	var/explain = (count_index == 1)
	var/anyone = FALSE
	for(var/mob/living/carbon/human/viewer in viewers(shout_range, src))
		if(viewer.stat != CONSCIOUS || HAS_TRAIT(viewer, TRAIT_BLIND))
			continue
		anyone = TRUE
		INVOKE_ASYNC(src, PROC_REF(make_shout), viewer, line, explain)
	if(!anyone)
		count_index = 1
		return
	count_index = (count_index % length(GLOB.schizo_count)) + 1

/obj/structure/sign/poster/contraband/schizo_count/proc/make_shout(mob/living/carbon/human/viewer, line, explain)
	if(explain)
		to_chat(viewer, span_warning("Вы не можете оторвать взгляд от постера. Губы сами складывают слова..."))
	viewer.say(line, ignore_speech_problems = TRUE)

// MARK: The camera

/// The studio camera: a set up tripod with a broadcast camera already mounted.
/obj/structure/tripod/schizo_studio

/obj/structure/tripod/schizo_studio/Initialize(mapload)
	. = ..()
	tripod_item.attach_camera(new /obj/item/broadcast_camera(tripod_item))
