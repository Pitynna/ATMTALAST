/obj/structure/statue
	abstract_type = /obj/structure/statue
	name = "statue"
	desc = "Placeholder. Yell at Firecage if you SOMEHOW see this."
	icon = 'icons/obj/statue.dmi'
	icon_state = ""
	density = TRUE
	max_integrity = 100
	cares_about_temperature = TRUE
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	var/oreAmount = 5
	var/material_drop_type = /obj/item/stack/sheet/metal

/obj/structure/statue/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/gun/energy/plasmacutter))
		if(obj_flags & NODECONSTRUCT)
			return ..()
		user.visible_message(
			span_notice("[user] start slicing apart [src] with [I]."),
			span_notice("You start slicing apart [src]..."),
		)
		I.play_tool_sound(src, 100)
		if(!do_after(user, 4 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL))
			add_fingerprint(user)
			return ATTACK_CHAIN_PROCEED
		I.play_tool_sound(src, 100)
		user.visible_message(
			span_notice("[user] slices apart [src] with [I]."),
			span_notice("You have sliced apart [src]."),
		)
		deconstruct(TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/statue/wrench_act(mob/living/user, obj/item/I)
	if(obj_flags & NODECONSTRUCT)
		return FALSE
	return default_unfasten_wrench(user, I)

/obj/structure/statue/welder_act(mob/user, obj/item/I)
	if(anchored)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		WELDER_SLICING_SUCCESS_MESSAGE
		deconstruct(TRUE)

/obj/structure/statue/attack_hand(mob/living/user)
	. = ..()
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(
		"[user] rubs some dust off from the [name]'s surface.",
		span_notice("You rub some dust off from the [name]'s surface.")
	)

/obj/structure/statue/CanAtmosPass(direction)
	return !density

/obj/structure/statue/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(material_drop_type)
			var/drop_amt = oreAmount
			if(!disassembled)
				drop_amt -= 2
			if(drop_amt > 0)
				new material_drop_type(get_turf(src), drop_amt)
	qdel(src)

/obj/structure/statue/uranium
	max_integrity = 300
	light_range = 3
	light_power = 0.7
	light_color = LIGHT_COLOR_NUCLEAR
	material_drop_type = /obj/item/stack/sheet/mineral/uranium
	abstract_type = /obj/structure/statue/uranium
	/// Mutex to prevent infinite recursion when propagating radiation pulses
	var/active = null
	/// Cooldown for radiation pulses
	COOLDOWN_DECLARE(radiation_cooldown)

/obj/structure/statue/uranium/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_PROPAGATE_RAD_PULSE, PROC_REF(radiate))

/obj/structure/statue/uranium/proc/radiate()
	SIGNAL_HANDLER

	if(active)
		return

	if(!COOLDOWN_FINISHED(src, radiation_cooldown))
		return

	active = TRUE
	COOLDOWN_START(src, radiation_cooldown, 1.5 SECONDS)
	radiation_pulse(
		src,
		max_range = 3,
		threshold = RAD_LIGHT_INSULATION,
		chance = URANIUM_IRRADIATION_CHANCE,
		minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME,
	)
	propagate_radiation_pulse()
	active = FALSE

/obj/structure/statue/uranium/attack_hand(mob/user, list/modifiers)
	radiate()
	return ..()

/obj/structure/statue/uranium/attackby(obj/item/item, mob/user, list/modifiers)
	radiate()
	return ..()

/obj/structure/statue/uranium/Bumped(atom/movable/movable_atom)
	radiate()
	return ..()

/obj/structure/statue/uranium/nuke
	name = "statue of a nuclear fission explosive"
	desc = "This is a grand statue of a Nuclear Explosive. It has a sickening green colour."
	icon_state = "nuke"

/obj/structure/statue/uranium/eng
	name = "statue of an engineer"
	desc = "This statue has a sickening green colour."
	icon_state = "eng"

/obj/structure/statue/plasma
	max_integrity = 200
	material_drop_type = /obj/item/stack/sheet/mineral/plasma
	desc = "This statue is suitably made from plasma."
	abstract_type = /obj/structure/statue/plasma

/obj/structure/statue/plasma/scientist
	name = "statue of a scientist"
	icon_state = "sci"

/obj/structure/statue/plasma/xeno
	name = "statue of a xenomorph"
	icon_state = "xeno"

/obj/structure/statue/plasma/temperature_expose(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/structure/statue/plasma/bullet_act(obj/projectile/P)
	if(!QDELETED(src)) //wasn't deleted by the projectile's effects.
		if(!P.nodamage && ((P.damage_type == BURN) || (P.damage_type == BRUTE)))
			if(P.firer)
				add_attack_logs(P.firer, src, "Ignited by firing with [P.name]", ATKLOG_FEW)
				investigate_log("was [span_warning("ignited")] by [key_name_log(P.firer)] with [P.name]",INVESTIGATE_ATMOS)
			else
				message_admins("A plasma statue was ignited with [P.name] at [ADMIN_COORDJMP(loc)]. No known firer.")
				add_game_logs("A plasma statue was ignited with [P.name] at [COORD(loc)]. No known firer.")
			PlasmaBurn()
	..()

/obj/structure/statue/plasma/attackby(obj/item/I, mob/user, params)
	if(I.get_temperature() > 300)//If the temperature of the object is over 300, then ignite
		add_attack_logs(user, src, "Ignited using [I]", ATKLOG_FEW)
		investigate_log("was [span_warning("ignited")] by [key_name_log(user)]",INVESTIGATE_ATMOS)
		ignite(I.get_temperature())
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/structure/statue/plasma/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	user.visible_message(
		span_danger("[user] sets [src] on fire!"),
		span_danger("[src] disintegrates into a cloud of plasma!"),
		span_warning("You hear a 'whoompf' and a roar.")
	)
	add_attack_logs(user, src, "ignited using [I]", ATKLOG_FEW)
	investigate_log("was [span_warning("ignited")] by [key_name_log(user)]",INVESTIGATE_ATMOS)
	ignite(2500)

/obj/structure/statue/plasma/proc/PlasmaBurn()
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 160)
	deconstruct(FALSE)

/obj/structure/statue/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn()

/obj/structure/statue/gold
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/gold
	desc = "This is a highly valuable statue made from gold."
	abstract_type = /obj/structure/statue/gold

/obj/structure/statue/gold/hos
	name = "statue of the head of security"
	icon_state = "hos"

/obj/structure/statue/gold/hop
	name = "statue of the head of personnel"
	icon_state = "hop"

/obj/structure/statue/gold/cmo
	name = "statue of the chief medical officer"
	icon_state = "cmo"

/obj/structure/statue/gold/ce
	name = "statue of the chief engineer"
	icon_state = "ce"

/obj/structure/statue/gold/rd
	name = "statue of the research director"
	icon_state = "rd"

/obj/structure/statue/gold/unathi
	name = "statue of the unati"
	icon_state = "unathi"

/obj/structure/statue/gold/tajaran
	name = "statue of the tajaran"
	icon_state = "tajaran"

/obj/structure/statue/silver
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/silver
	desc = "This is a valuable statue made from silver."
	abstract_type = /obj/structure/statue/silver

/obj/structure/statue/silver/md
	name = "statue of a medical doctor"
	icon_state = "md"

/obj/structure/statue/silver/janitor
	name = "statue of a janitor"
	icon_state = "jani"

/obj/structure/statue/silver/sec
	name = "statue of a security officer"
	icon_state = "sec"

/obj/structure/statue/silver/secborg
	name = "statue of a security cyborg"
	icon_state = "secborg"

/obj/structure/statue/silver/secborg/piano
	name = "piano robot"
	desc = "A statue of a robot in a tailcoat playing a piano in open space. It seems to have been here a long time. It also has an excellent, shiny metal backside."
	icon = 'icons/mob/robots.dmi'
	icon_state = "Robot-MAN"

/obj/structure/statue/silver/medborg
	name = "statue of a medical cyborg"
	icon_state = "medborg"

/obj/structure/statue/diamond
	max_integrity = 1000
	material_drop_type = /obj/item/stack/sheet/mineral/diamond
	desc = "This is a very expensive diamond statue."
	abstract_type = /obj/structure/statue/diamond

/obj/structure/statue/diamond/captain
	name = "statue of THE captain"
	icon_state = "cap"

/obj/structure/statue/diamond/ai1
	name = "statue of the AI hologram"
	icon_state = "ai1"

/obj/structure/statue/diamond/ai2
	name = "statue of the AI core"
	icon_state = "ai2"

/obj/structure/statue/bananium
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/bananium
	desc = "A bananium statue with a small engraving:'HOOOOOOONK'."
	abstract_type = /obj/structure/statue/bananium
	var/spam_flag = 0

/obj/structure/statue/bananium/clown
	name = "statue of a clown"
	icon_state = "clown"

/obj/structure/statue/bananium/Bumped(atom/movable/moving_atom)
	honk()
	. = ..()

/obj/structure/statue/bananium/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!ATTACK_CHAIN_CANCEL_CHECK(.))
		honk()

/obj/structure/statue/bananium/attack_hand(mob/user)
	honk()
	..()

/obj/structure/statue/bananium/proc/honk()
	if(!spam_flag)
		spam_flag = 1
		playsound(loc, 'sound/items/bikehorn.ogg', 50, TRUE)
		spawn(20)
			spam_flag = 0

/obj/structure/statue/bananium/clown/unique
	name = "statue of the Great Honker"
	desc = "An expertly sculpted statue made from bananium, banana juice and an unidentified white material. Its remarkable smile, two golden horns and outfit suggest that it depicts the station's finest comedian. The full name is unfortunately worn and illegible; someone clearly envied his talent."
	icon_state = "clown_unique"

/obj/structure/statue/sandstone
	max_integrity = 50
	material_drop_type = /obj/item/stack/sheet/mineral/sandstone
	abstract_type = /obj/structure/statue/sandstone

/obj/structure/statue/sandstone/assistant
	name = "statue of an assistant"
	desc = "A cheap statue of sandstone for a greyshirt."
	icon_state = "assist"

/obj/structure/statue/sandstone/venus //call me when we add marble i guess
	name = "statue of a pure maiden"
	desc = "An ancient marble statue. The subject is depicted with a floor-length braid and is wielding a toolbox. By Jove, it's easily the most gorgeous depiction of a woman you've ever seen. The artist must truly be a master of his craft. Shame about the broken arm, though."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "venus"

/obj/structure/statue/tranquillite
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/tranquillite
	desc = "..."
	abstract_type = /obj/structure/statue/tranquillite

/obj/structure/statue/tranquillite/mime
	name = "statue of a mime"
	icon_state = "mime"
	interaction_flags_click = NEED_HANDS | ALLOW_RESTING

/obj/structure/statue/tranquillite/mime/click_alt(mob/user)//has 4 dirs
	if(anchored)
		to_chat(user, span_warning("It is fastened to the floor!"))
		return CLICK_ACTION_BLOCKING
	setDir(turn(dir, 90))
	return CLICK_ACTION_SUCCESS

/obj/structure/statue/tranquillite/mime/unique
	name = "statue of the Pride of Pantomime"
	desc = "An expertly sculpted tranquillite statue. On closer inspection, it wears an old mime uniform painted to resemble tranquillite, and its mouth is taped shut. Someone clearly devoted themselves entirely to pantomime. A medal on its chest bears a barely legible painted-over inscription, For Bravery, with For War Crimes written on top."
	icon_state = "mime_unique"

/obj/structure/statue/kidanstatue
	name = "Obsidian Kidan warrior statue"
	desc = "A beautifully carved and menacing statue of a Kidan warrior made out of obsidian. It looks very heavy."
	icon_state = "kidan"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/chickenstatue
	name = "Bronze Chickenman Statue"
	desc = "An antique and oriental-looking statue of a Chickenman made of bronze."
	icon_state = "chicken"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/angel
	name = "Stone Angel Statue"
	desc = "An antique statue of a human angel made of stone."
	icon_state = "angel"
	anchored = TRUE
	obj_flags = NODECONSTRUCT

/obj/structure/statue/russian_mulebot
	desc = "Like a MULEbot, but more Russian and less functional.";
	icon = 'icons/obj/aibots.dmi';
	icon_state = "mulebot0";
	name = "OXENbot"
	anchored = TRUE
	oreAmount = 10

/obj/structure/statue/armor
	name = "Knight's armor"
	desc = "Shiny metallic armor."
	icon_state = "posarmor"
	anchored = TRUE
/obj/structure/statue/elwycco
	name = "Unknown Hero"
	desc = "This appears to be a very important person, or someone important to many people. He holds an enormous axe engraved with the number 220. Everyone interprets the number differently, but rumor says it is his victim count.\nThe plaque reads: We stand with you, Shustrila! Ave, Legion!"
	icon_state = "elwycco"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/thaumicnik
	name = "Unknown Hero"
	desc = "An intriguing young man holds station blueprints that closely resemble Kerberos. Perhaps he helped design or build it. In his other hand is a clipboard covered in dates and notes; all you can make out is the heading event-times.\nThe plaque reads: One of the chief engineers involved in developing the advanced Kerberos research station."
	icon_state = "thaumicnik"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/hooker
	name = "Unknown Hero"
	desc = "You may never have met this hero, who always wears a mask and a white technical coat. Perhaps he still hides among the crew under another identity.\nThe plaque reads: A hero who sacrificed himself to destroy a threat to the station. Awarded posthumously."
	icon_state = "hooker"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/artchair
	name = "Unknown Hero"
	desc = "Another Nanotrasen hero. The chair's back resembles a prison window, and blood has accumulated on it in layers for about a year. It apparently represents someone who contributed greatly to developing and maintaining our galactic system.\nThe plaque reads: Thank you for everything. You have always been, and will always be, welcome here."
	icon_state = "artchair"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/furukai
	name = "Sophia White"
	desc = "A mysterious woman, now one of the Syndicate's many officers. She earned her position through ability rather than connections. Driven by revenge after losing her sister to Nanotrasen's corrupt leadership, she joined the Syndicate and became known as both a skilled agent and an excellent engineer. Despite her furry-sounding callsign, she hated them deep down..."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "furukai"
	pixel_y = 7
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/ell_good
	name = "Mr. Boom"
	desc = "A mysterious yellow-skinned clown with striking green eyes. The Syndicate's finest double agent, he managed to seize control of numerous facilities. His name is often mispronounced, leaving his achievements credited to several different Booms. Also famous for convincing Nanotrasen management to spend time, effort and money on a golden toilet."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "ell_good"
	pixel_y = 7
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/mooniverse
	name = "Unknown Agent"
	desc = "The plaque beneath the statue is scratched and illegible..."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "mooniverse"
	pixel_y = 7
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/carp_mini
	name = "Carp Statue"
	desc = "A great inhabitant of space.."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "carp_mini"
	max_integrity = 200
	anchored = TRUE

/obj/structure/statue/noble
	name = "Noble person"
	desc = "Giant person, not like us... May be a hero from an ancient fairy tale?"
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "frank"
	max_integrity = 2000
	anchored = TRUE
	layer = EDGED_TURF_LAYER

/obj/structure/statue/dude
	name = "Unknown monk"
	desc = "Seems to be one of thinkers from ancient times."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "dude"
	max_integrity = 2000
	anchored = TRUE
	layer = EDGED_TURF_LAYER

/obj/structure/statue/death
	name = "Death"
	desc = "One day It will come and take you and your dreams."
	icon = 'icons/obj/statuebig.dmi'
	icon_state = "death"
	max_integrity = 2000
	anchored = TRUE
	bound_width = 64
	layer = EDGED_TURF_LAYER

/obj/structure/statue/unknown
	name = "Unknown hero"
	desc = "A pedestal for an unknown soldier, perhaps he was somehow connected with the solar system."
	icon = 'icons/obj/statuebig.dmi'
	icon_state = "unknown"
	max_integrity = 2000
	anchored = TRUE
	bound_width = 64
	var/lit = 0
	layer = EDGED_TURF_LAYER
	anchored = TRUE
	obj_flags = NODECONSTRUCT

/obj/structure/statue/unknown/update_icon_state()
	icon_state = "unknown[lit ? "_lit" : ""]"

/obj/structure/statue/unknown/attackby(obj/item/I, mob/user, params)
	if(I.get_temperature() && light(span_notice("[user] lights [src] with [I].")))
		add_fingerprint(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

/obj/structure/statue/unknown/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(I.tool_use_check(user, 0))
		light(span_notice("[user] casually lights the [name] with [I], what a badass."))

/obj/structure/statue/unknown/fire_act(exposed_temperature, exposed_volume)
	if(!lit)
		light()
	return ..()

/obj/structure/statue/unknown/proc/light(show_message)
	if(lit)
		return FALSE
	. = TRUE
	lit = TRUE
	if(show_message)
		usr.visible_message(show_message)
	set_light(3, l_on = TRUE)
	update_icon(UPDATE_ICON_STATE)

/obj/structure/statue/unknown/attack_hand(mob/user)
	if(lit)
		user.visible_message(span_notice("[user] snuffs out [src]."))
		lit = FALSE
		update_icon(UPDATE_ICON_STATE)
		set_light_on(FALSE)

////////////////////////////////

/obj/structure/snowman
	name = "snowman"
	desc = "Seems someone made a snowman here."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "snowman"
	anchored = TRUE
	density = TRUE
	max_integrity = 50

/obj/structure/snowman/built
	desc = "Just like the ones you remember from childhood!"

/obj/structure/snowman/built/Destroy()
	new /obj/item/reagent_containers/food/snacks/grown/carrot(drop_location())
	new /obj/item/grown/log(drop_location())
	new /obj/item/grown/log(drop_location())
	return ..()

/obj/structure/snowman/built/has_prints()
	return FALSE

/obj/structure/snowman/built/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/snowball))
		if(obj_integrity >= max_integrity)
			to_chat(user, span_warning("The [name] is completely intact."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You patch some of the damage on [src] with [I]."))
		update_integrity(max_integrity)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/snowman/built/fire_act(exposed_temperature, exposed_volume)
	..()
	qdel(src)

/obj/structure/snowman/high
	icon_state = "snowman_high"

/obj/structure/snowman/medium
	icon_state = "snowman_medium"

/obj/structure/snowman/short
	name = "snowboy"
	icon_state = "snowman_short"

///////// Cheese
/obj/structure/statue/cheese
	material_drop_type = /obj/item/stack/sheet/cheese
	abstract_type = /obj/structure/statue/cheese

/obj/structure/statue/cheese/cheesus
	name = "statue of cheesus"
	desc = "Cheese expertly crafted into a representation of our mighty lord and saviour."
	icon_state = "cheesus1"

/obj/structure/statue/cheese/cheesus/update_icon_state()
	switch(obj_integrity)
		if(-INFINITY to 20)
			icon_state = "cheesus4"
		if(21 to 40)
			icon_state = "cheesus3"
		if(41 to 60)
			icon_state = "cheesus2"
		else
			icon_state = "cheesus1"

/obj/structure/statue/cheese/cheesus/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && !QDELETED(src))
		update_icon(UPDATE_ICON_STATE)

//////BONES
/obj/structure/bones
	name = "large bone"
	desc = "a large bone that belong to the unknown creature"
	icon = 'icons/obj/bones_64x64.dmi'
	icon_state = "l_bone"
	anchored = TRUE
	density = TRUE
	max_integrity = 1000

/obj/structure/bones/right
	icon_state = "r_bone"

/obj/structure/bones/skull
	name = "large skull"
	desc = "a large skull that belong to the unknown creature"
	icon_state = "skull"

/obj/structure/bones/ribs_left
	name = "large ribs"
	desc = "a large ribs that belong to the unknown creature"
	icon_state = "l_ribs"

/obj/structure/bones/ribs_right
	name = "large ribs"
	desc = "a large ribs that belong to the unknown creature"
	icon_state = "r_ribs"

/obj/structure/statue/bone/rib
	name = "colossal rib"
	desc = "It's staggering to think that something this big could have lived, let alone died."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "rib"
	anchored = TRUE
	obj_flags = NODECONSTRUCT

