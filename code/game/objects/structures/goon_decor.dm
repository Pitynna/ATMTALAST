// Decor ported from Goonstation 13. Sprites: CC BY-NC-SA 3.0, see docs/GOON_ASSETS.md.
// The sprite sheets are rebuilt by tools/goon_ports/decor.py.

#define GOON_DECOR 'icons/obj/goon_decor.dmi'

// MARK: Vases

/obj/item/goon_vase
	name = "flower vase"
	desc = "Some pretty flowers that really brighten up the room."
	icon = GOON_DECOR
	icon_state = "vase1"
	w_class = WEIGHT_CLASS_SMALL
	force = 3
	throwforce = 5
	resistance_flags = FLAMMABLE

/obj/item/goon_vase/random/Initialize(mapload)
	. = ..()
	icon_state = "vase[rand(1, 8)]"

/obj/item/goon_vase/two
	icon_state = "vase2"

/obj/item/goon_vase/three
	icon_state = "vase3"

/obj/item/goon_vase/four
	icon_state = "vase4"

/obj/item/goon_vase/five
	icon_state = "vase5"

/obj/item/goon_vase/six
	icon_state = "vase6"

/obj/item/goon_vase/seven
	icon_state = "vase7"

/obj/item/goon_vase/eight
	icon_state = "vase8"

/obj/item/goon_vase/daffodil
	name = "daffodil vase"
	desc = "A ribboned vase with a lovely daffodil."
	icon_state = "vase-flowers"

/obj/item/goon_vase/empty
	name = "vase"
	desc = "An empty glass vase, waiting for some flowers."
	icon_state = "vase"

// MARK: Potted plants

/obj/item/twohanded/required/kirbyplants/goon
	icon = GOON_DECOR
	icon_state = "ppot1"
	/// Our kirbyplants pick a random sprite from their own sheet; these keep the one they were mapped with.
	var/fixed_state

/obj/item/twohanded/required/kirbyplants/goon/Initialize(mapload)
	fixed_state = icon_state
	. = ..()
	icon_state = fixed_state
	l_range_init = 0
	l_power_init = 0
	set_light_on(FALSE)

/obj/item/twohanded/required/kirbyplants/goon/pot2
	icon_state = "ppot2"

/obj/item/twohanded/required/kirbyplants/goon/pot3
	icon_state = "ppot3"

/obj/item/twohanded/required/kirbyplants/goon/pot4
	icon_state = "ppot4"

/obj/item/twohanded/required/kirbyplants/goon/pot5
	icon_state = "ppot5"

/obj/item/twohanded/required/kirbyplants/goon/plant1
	icon_state = "plant1"

/obj/item/twohanded/required/kirbyplants/goon/plant2
	icon_state = "plant2"

/obj/item/twohanded/required/kirbyplants/goon/plant3
	icon_state = "plant3"

/obj/item/twohanded/required/kirbyplants/goon/plant4
	icon_state = "plant4"

/obj/item/twohanded/required/kirbyplants/goon/plant5
	icon_state = "plant5"

/obj/item/twohanded/required/kirbyplants/goon/plant6
	icon_state = "plant6"

/obj/item/twohanded/required/kirbyplants/goon/plant7
	icon_state = "plant7"

/obj/item/twohanded/required/kirbyplants/goon/monkey
	name = "monkey plant"
	desc = "A strange flowering plant that sways all on its own. Botany swears it is not a monkey."
	icon_state = "monkeyplant"

// MARK: Candles

/obj/item/candle/goon_small
	name = "tea candle"
	desc = "A tiny candle in a metal cup. Cozy."
	icon = GOON_DECOR
	icon_state = "lil_candle0"
	item_state = "candle1"
	wax = 120

/obj/item/candle/goon_small/update_icon_state()
	icon_state = "lil_candle[lit ? 1 : 0]"

/obj/item/candle/goon_small/lit
	start_lit = TRUE

/obj/structure/goon_candelabra
	name = "wall mounted candelabra"
	desc = "A row of candles on an iron holder. Light them with anything hot, snuff them out by hand."
	icon = GOON_DECOR
	icon_state = "candles-unlit"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	max_integrity = 60
	light_system = OVERLAY_LIGHT
	light_range = 3
	light_power = 0.8
	light_color = "#E09D37"
	light_on = FALSE
	var/lit = FALSE

/obj/structure/goon_candelabra/lit
	lit = TRUE

/obj/structure/goon_candelabra/Initialize(mapload)
	. = ..()
	set_lit(lit)

/obj/structure/goon_candelabra/proc/set_lit(new_lit)
	lit = new_lit
	set_light_on(lit)
	update_icon(UPDATE_ICON_STATE)

/obj/structure/goon_candelabra/update_icon_state()
	icon_state = lit ? "candles" : "candles-unlit"

/obj/structure/goon_candelabra/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!lit && tool.get_temperature())
		user.visible_message(span_notice("[user] lights [src] with [tool]."), span_notice("You light [src]."))
		set_lit(TRUE)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/structure/goon_candelabra/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !lit)
		return
	user.visible_message(span_notice("[user] snuffs out [src]."), span_notice("You snuff out [src]."))
	set_lit(FALSE)
	return TRUE

/obj/structure/goon_candelabra/extinguish_light(force = FALSE)
	set_lit(FALSE)

// MARK: Wall clock

/obj/structure/goon_clock
	name = "clock"
	desc = "A plain wall clock."
	icon = GOON_DECOR
	icon_state = "clock"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	max_integrity = 50
	/// A stopped clock never shows the time.
	var/frozen = FALSE

/obj/structure/goon_clock/examine(mob/user)
	. = ..()
	if(!frozen)
		. += span_notice("It reads [station_time_timestamp("hh:mm")].")

/obj/structure/goon_clock/frozen
	desc = "The clock seems to be completely unmoving, frozen at exactly 3 AM."
	frozen = TRUE

// MARK: Tabletop curios

/obj/item/goon_curio
	icon = GOON_DECOR
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throwforce = 6

/obj/item/goon_curio/bottleship
	name = "ship in a bottle"
	desc = "A tiny sailing ship somehow built inside a glass bottle. Someone spent a lot of evenings on this."
	icon_state = "bottleship"

/obj/item/goon_curio/bottleship/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(icon_state == "bottleship_broken")
		return
	playsound(src, 'sound/effects/glassbr1.ogg', 50, TRUE)
	visible_message(span_warning("[src] shatters!"))
	new /obj/item/shard(get_turf(src))
	icon_state = "bottleship_broken"
	name = "broken ship in a bottle"
	desc = "All that work, ruined."

/obj/item/goon_curio/gold_bee
	name = "golden bee statuette"
	desc = "A polished golden bee on a little stand. Buzz buzz."
	icon_state = "gold_bee"

/obj/item/goon_curio/trophy
	name = "trophy"
	desc = "A large golden cup for whoever won whatever it was."
	icon_state = "trophy"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/goon_curio/trophy/battered
	name = "battered trophy"
	desc = "A golden cup that has clearly been used as a weapon at least once."
	icon_state = "trophyfucked"

/obj/structure/goon_skeleton_stand
	name = "anatomical skeleton"
	desc = "A teaching skeleton on a stand. Hopefully it's plastic."
	icon = GOON_DECOR
	icon_state = "skeleton_stand"
	density = TRUE
	anchored = FALSE
	max_integrity = 80

/obj/structure/goon_skeleton_stand/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

// MARK: Singing wall fish

/obj/structure/goon_wallfish
	name = "singing bass"
	desc = "A mounted fish with a button under it. It looks like it wants to sing."
	icon = GOON_DECOR
	icon_state = "wallfish"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	max_integrity = 50
	COOLDOWN_DECLARE(sing_cooldown)

/obj/structure/goon_wallfish/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!COOLDOWN_FINISHED(src, sing_cooldown))
		return TRUE
	COOLDOWN_START(src, sing_cooldown, 5 SECONDS)
	flick("wallfish_move", src)
	audible_message(span_notice("[src] wiggles and sings a few bars, badly."))
	return TRUE

// MARK: Neon OPEN sign

/obj/structure/sign/goon
	icon = GOON_DECOR

/obj/structure/sign/goon/open_neon
	name = "open sign"
	desc = "A neon sign used to welcome customers to a place of business. Touch it to switch it."
	icon_state = "opensign-0"
	var/on = FALSE

/obj/structure/sign/goon/open_neon/on
	icon_state = "opensign-1"
	on = TRUE

/obj/structure/sign/goon/open_neon/Initialize(mapload)
	. = ..()
	if(on)
		set_light(1.5, 0.6, "#FF5ACD")
	update_appearance()

/obj/structure/sign/goon/open_neon/update_icon_state()
	icon_state = "opensign-[on ? 1 : 0]"

/obj/structure/sign/goon/open_neon/update_overlays()
	. = ..()
	if(on)
		underlays += emissive_appearance(icon, "opensign-glow", src)

/obj/structure/sign/goon/open_neon/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	on = !on
	set_light(on ? 1.5 : 0, 0.6, "#FF5ACD")
	update_appearance()
	to_chat(user, span_notice("You switch [src] [on ? "on" : "off"]."))
	return TRUE

// MARK: Window blinds

/obj/structure/goon_blinds
	name = "blinds"
	desc = "Window blinds. Touch them to open or close."
	icon = GOON_DECOR
	icon_state = "blindsH-o"
	anchored = TRUE
	layer = ABOVE_WINDOW_LAYER
	max_integrity = 30
	resistance_flags = FLAMMABLE
	/// "H" for blinds on north/south windows, "V" for east/west ones.
	var/axis = "H"
	/// "" for a single window, "-L", "-M" or "-R" for a run of windows.
	var/segment = ""
	var/closed = FALSE

/obj/structure/goon_blinds/Initialize(mapload)
	. = ..()
	update_blinds()

/obj/structure/goon_blinds/proc/update_blinds()
	set_opacity(closed)
	icon_state = "blinds[axis][segment]-[closed ? "c" : "o"]"

/obj/structure/goon_blinds/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	closed = !closed
	update_blinds()
	playsound(src, 'sound/effects/rustle1.ogg', 30, TRUE)
	return TRUE

/obj/structure/goon_blinds/closed
	closed = TRUE

/obj/structure/goon_blinds/left
	segment = "-L"

/obj/structure/goon_blinds/middle
	segment = "-M"

/obj/structure/goon_blinds/right
	segment = "-R"

/obj/structure/goon_blinds/vertical
	icon_state = "blindsV-o"
	axis = "V"

/obj/structure/goon_blinds/vertical/left
	segment = "-L"

/obj/structure/goon_blinds/vertical/middle
	segment = "-M"

/obj/structure/goon_blinds/vertical/right
	segment = "-R"

// MARK: Wall bits

/obj/structure/goon_wall_decor
	icon = GOON_DECOR
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	max_integrity = 50

/obj/structure/goon_wall_decor/toilet_paper
	name = "toilet paper holder"
	desc = "A roll of toilet paper on a holder. Precious."
	icon_state = "toiletholder"

/obj/structure/goon_wall_decor/junction_box
	name = "junction box"
	desc = "A box full of wires. Touch it to open or close the cover."
	icon_state = "junctionbox"
	var/base_state = "junctionbox"
	var/open = FALSE

/obj/structure/goon_wall_decor/junction_box/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	open = !open
	icon_state = open ? "[base_state]_open" : base_state
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	return TRUE

/obj/structure/goon_wall_decor/junction_box/tall
	icon_state = "junctionbox2"
	base_state = "junctionbox2"

/obj/structure/goon_wall_decor/junction_box/panel
	icon_state = "junctionbox3"
	base_state = "junctionbox3"

/obj/structure/goon_wall_decor/vent
	name = "vent"
	desc = "Better not to stick your hand in there, those blades look sharp."
	icon_state = "vent1"

/obj/structure/goon_wall_decor/vent/two
	icon_state = "vent2"

/obj/structure/goon_wall_decor/vent/three
	icon_state = "vent3"

/obj/structure/goon_wall_decor/lever
	name = "wall lever"
	desc = "A big lever on the wall. It doesn't seem to be connected to anything. Probably."
	icon_state = "wall-lever-up"
	var/down = FALSE
	COOLDOWN_DECLARE(pull_cooldown)

/obj/structure/goon_wall_decor/lever/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!COOLDOWN_FINISHED(src, pull_cooldown))
		return TRUE
	COOLDOWN_START(src, pull_cooldown, 1 SECONDS)
	down = !down
	flick(down ? "wall-lever-down-anim" : "wall-lever-up-anim", src)
	icon_state = down ? "wall-lever-down" : "wall-lever-up"
	playsound(src, 'sound/machines/click.ogg', 40, TRUE)
	user.visible_message(span_notice("[user] pulls [src]."), span_notice("You pull [src]. Nothing obvious happens."))
	return TRUE

// MARK: Ring ropes

/obj/structure/railing/goon_ringrope
	name = "ring ropes"
	desc = "Ropes around a boxing ring. Nobody leaves until the bell."
	icon = GOON_DECOR
	icon_state = "ringrope"

/obj/structure/railing/goon_ringrope/update_icon_state()
	icon_state = "ringrope"

// MARK: Bookcase

/obj/structure/bookcase/goon
	icon = GOON_DECOR
	icon_state = "bookcase"

/obj/structure/bookcase/goon/update_icon_state()
	icon_state = "bookcase"

// MARK: Frames, plaques and signs

/obj/structure/sign/goon/medal
	name = "framed medal"
	desc = "A medal in a frame, proudly hung for all to see."
	icon_state = "sign_medal1"

/obj/structure/sign/goon/medal/plain
	icon_state = "sign_medal"

/obj/structure/sign/goon/diploma
	name = "framed diploma"
	desc = "A research diploma in a frame. It looks very official."
	icon_state = "sign_rddiploma1"

/obj/structure/sign/goon/diploma/plain
	icon_state = "sign_rddiploma"

/obj/structure/sign/goon/medical_license
	name = "framed medical license"
	desc = "A license to practice medicine. Supposedly."
	icon_state = "sign_mdlicense1"

/obj/structure/sign/goon/medical_license/plain
	icon_state = "sign_mdlicense"

/obj/structure/sign/goon/certificate
	name = "framed certificate"
	desc = "A certificate of merit from personnel."
	icon_state = "sign_hopcredit1"

/obj/structure/sign/goon/certificate/plain
	icon_state = "sign_hopcredit"

/obj/structure/sign/goon/frame
	name = "empty frame"
	desc = "An empty picture frame."
	icon_state = "sign_frame"

/obj/structure/sign/goon/portrait
	name = "portrait"
	desc = "A portrait of someone important, or someone who thought they were."
	icon_state = "sign_portrait"

/obj/structure/sign/goon/portrait/scientist
	desc = "A portrait of a distinguished scientist."
	icon_state = "sign_portrait_scientist"

/obj/structure/sign/goon/accidents
	name = "days without accidents"
	desc = "A board counting the days since the last workplace accident. The number has been scratched out many times."
	icon_state = "sign_accidents_sign"
	random_number = FALSE

/obj/structure/sign/goon/periodic_table
	name = "periodic table"
	desc = "A periodic table of the elements. Someone added plasma to it in marker."
	icon_state = "sign_ptoe"

/obj/structure/sign/goon/gym
	name = "\improper GYM"
	desc = "A sign for the gym."
	icon_state = "sign_gym"

/obj/structure/sign/goon/pool
	name = "\improper POOL"
	desc = "A sign for the pool."
	icon_state = "sign_pool"

/obj/structure/sign/goon/arcade
	name = "\improper ARCADE"
	desc = "A sign for the arcade."
	icon_state = "sign_arcade"

/obj/structure/sign/goon/garden
	name = "\improper GARDEN"
	desc = "A sign for the garden."
	icon_state = "sign_garden"

/obj/structure/sign/goon/office_plaque
	name = "office plaque"
	desc = "A small brass plaque for an office door."
	icon_state = "sign_office_plaque"

/obj/structure/sign/goon/read_me
	name = "\improper READ ME"
	desc = "A sign that just says READ ME. You did."
	icon_state = "sign_read_me"

// MARK: ISO safety signs

/obj/structure/sign/goon/iso
	name = "safety sign"
	desc = "An international safety sign."
	icon_state = "iso_warning_action"

/obj/structure/sign/goon/iso/no_entry
	name = "\improper PROHIBITED sign"
	icon_state = "iso_prohibited_general"

/obj/structure/sign/goon/iso/no_smoking
	name = "\improper NO SMOKING sign"
	icon_state = "iso_prohibited_smoking"

/obj/structure/sign/goon/iso/no_touching
	name = "\improper DO NOT TOUCH sign"
	icon_state = "iso_prohibited_touch"

/obj/structure/sign/goon/iso/no_food
	name = "\improper NO FOOD OR DRINK sign"
	icon_state = "iso_prohibited_food"

/obj/structure/sign/goon/iso/no_fire
	name = "\improper NO OPEN FLAMES sign"
	icon_state = "iso_prohibited_fire"

/obj/structure/sign/goon/iso/no_shoes
	name = "\improper NO SHOES sign"
	icon_state = "iso_prohibited_shoes"

/obj/structure/sign/goon/iso/mandatory
	name = "\improper MANDATORY ACTION sign"
	icon_state = "iso_mandatory_action"

/obj/structure/sign/goon/iso/eye_protection
	name = "\improper WEAR EYE PROTECTION sign"
	icon_state = "iso_mandatory_eyepro"

/obj/structure/sign/goon/iso/ear_protection
	name = "\improper WEAR EAR PROTECTION sign"
	icon_state = "iso_mandatory_earpro"

/obj/structure/sign/goon/iso/mask
	name = "\improper WEAR A MASK sign"
	icon_state = "iso_mandatory_mask"

/obj/structure/sign/goon/iso/welding
	name = "\improper WEAR WELDING PROTECTION sign"
	icon_state = "iso_mandatory_welding"

/obj/structure/sign/goon/iso/ppe
	name = "\improper WEAR PROTECTIVE EQUIPMENT sign"
	icon_state = "iso_mandatory_ppe"

/obj/structure/sign/goon/iso/grounding
	name = "\improper GROUND EQUIPMENT sign"
	icon_state = "iso_mandatory_ground"

/obj/structure/sign/goon/iso/magboots
	name = "\improper WEAR MAGBOOTS sign"
	icon_state = "iso_mandatory_mag"

/obj/structure/sign/goon/iso/horn
	name = "\improper SOUND HORN sign"
	icon_state = "iso_mandatory_horn"

/obj/structure/sign/goon/iso/harness
	name = "\improper WEAR A HARNESS sign"
	icon_state = "iso_mandatory_belt"

/obj/structure/sign/goon/iso/catears
	name = "\improper WEAR CAT EARS sign"
	desc = "An international safety sign. Someone clearly made this one themselves."
	icon_state = "iso_mandatory_catears"

/obj/structure/sign/goon/iso/caution
	name = "\improper CAUTION sign"
	icon_state = "iso_warning_action"

/obj/structure/sign/goon/iso/radiation
	name = "\improper RADIATION sign"
	icon_state = "iso_warning_radiation"

/obj/structure/sign/goon/iso/biohazard
	name = "\improper BIOHAZARD sign"
	icon_state = "iso_warning_biological"

/obj/structure/sign/goon/iso/laser
	name = "\improper LASER HAZARD sign"
	icon_state = "iso_warning_laser"

/obj/structure/sign/goon/iso/electric
	name = "\improper ELECTRICAL HAZARD sign"
	icon_state = "iso_warning_electric"

/obj/structure/sign/goon/iso/explosive
	name = "\improper EXPLOSIVES sign"
	icon_state = "iso_warning_explosion"

/obj/structure/sign/goon/iso/toxic
	name = "\improper TOXIC sign"
	icon_state = "iso_warning_toxic"

/obj/structure/sign/goon/iso/flammable
	name = "\improper FLAMMABLE sign"
	icon_state = "iso_warning_flammable"

/obj/structure/sign/goon/iso/corrosive
	name = "\improper CORROSIVE sign"
	icon_state = "iso_warning_corrosive"

/obj/structure/sign/goon/iso/first_aid
	name = "\improper FIRST AID sign"
	icon_state = "iso_safe_medical"

/obj/structure/sign/goon/iso/exit_left
	name = "\improper EXIT sign"
	icon_state = "iso_safe_exit-l"

/obj/structure/sign/goon/iso/exit_right
	name = "\improper EXIT sign"
	icon_state = "iso_safe_exit-r"

/obj/structure/sign/goon/iso/defibrillator
	name = "\improper DEFIBRILLATOR sign"
	icon_state = "iso_safe_defib"

/obj/structure/sign/goon/iso/respirator
	name = "\improper RESPIRATOR sign"
	icon_state = "iso_safe_respirator"

/obj/structure/sign/goon/iso/oxygen
	name = "\improper OXYGEN sign"
	icon_state = "iso_safe_oxygen"

/obj/structure/sign/goon/iso/shower
	name = "\improper SAFETY SHOWER sign"
	icon_state = "iso_safe_shower"

/obj/structure/sign/goon/iso/eyewash
	name = "\improper EYEWASH sign"
	icon_state = "iso_safe_eyewash"

/obj/structure/sign/goon/iso/alarm
	name = "\improper GENERAL ALARM sign"
	icon_state = "iso_safe_shipboard_general_alarm"

/obj/structure/sign/goon/iso/coffee
	name = "\improper COFFEE sign"
	icon_state = "iso_safe_coffee"

/obj/structure/sign/goon/iso/water
	name = "\improper DRINKING WATER sign"
	icon_state = "iso_safe_water"

/obj/structure/sign/goon/iso/evacuation
	name = "\improper EVACUATION POINT sign"
	icon_state = "iso_safe_evac"

/obj/structure/sign/goon/iso/extinguisher
	name = "\improper FIRE EXTINGUISHER sign"
	icon_state = "iso_fire_extinguisher"

/obj/structure/sign/goon/iso/fire_gear
	name = "\improper FIREFIGHTING GEAR sign"
	icon_state = "iso_fire_helmet"

// MARK: Posters

/obj/structure/sign/goon/poster
	name = "poster"
	desc = "A poster stuck to the wall."
	icon_state = "poster_explore_the_trench"
	resistance_flags = FLAMMABLE

/obj/structure/sign/goon/poster/explore
	name = "\improper Explore the Trench poster"
	icon_state = "poster_explore_the_trench"

/obj/structure/sign/goon/poster/bird_up
	name = "\improper Bird Up poster"
	icon_state = "poster_bird_up"

/obj/structure/sign/goon/poster/new_you
	name = "\improper A New You poster"
	desc = "A poster advertising genetic self-improvement."
	icon_state = "poster_a_new_you"

/obj/structure/sign/goon/poster/grow_food
	name = "\improper Grow Food Not Weed poster"
	desc = "A poster from the botany department's more responsible days."
	icon_state = "poster_grow_food_not_weed"

/obj/structure/sign/goon/poster/laser_power
	name = "\improper More Laser Power poster"
	icon_state = "poster_more_laser_power"

/obj/structure/sign/goon/poster/pack_smart
	name = "\improper Pack Smart poster"
	desc = "A poster reminding you to pack your internals."
	icon_state = "poster_pack_smart"

/obj/structure/sign/goon/poster/capy_king
	name = "\improper Capy King poster"
	icon_state = "poster_capy_king"

/obj/structure/sign/goon/poster/biodome
	name = "\improper Biodome poster"
	icon_state = "poster_biodome"

/obj/structure/sign/goon/poster/rat
	name = "\improper Rat poster"
	icon_state = "poster_rat"

/obj/structure/sign/goon/poster/believe
	name = "\improper I Want to Believe poster"
	icon_state = "poster_mandarin_belief"

/obj/structure/sign/goon/poster/keep_it
	name = "\improper Keep It or Melt poster"
	icon_state = "poster_keep_it_or_melt"

// MARK: Floor guides and drain

/obj/effect/turf_decal/goon_guide
	name = "floor guide"
	icon = GOON_DECOR
	icon_state = "guide_qm"

/obj/effect/turf_decal/goon_guide/cargo
	icon_state = "guide_qm"

/obj/effect/turf_decal/goon_guide/security
	icon_state = "guide_sec"

/obj/effect/turf_decal/goon_guide/science
	icon_state = "guide_sci"

/obj/effect/turf_decal/goon_guide/mining
	icon_state = "guide_mining"

/obj/effect/turf_decal/goon_guide/medbay
	icon_state = "guide_medbay"

/obj/effect/turf_decal/goon_guide/evac
	icon_state = "guide_evac"

/obj/effect/turf_decal/goon_guide/engineering
	icon_state = "guide_engi"

/obj/effect/turf_decal/goon_guide/command
	icon_state = "guide_command"

/obj/effect/turf_decal/goon_guide/botany
	icon_state = "guide_botany"

/obj/effect/turf_decal/goon_guide/hop
	icon_state = "guide_hop"

/obj/effect/turf_decal/goon_guide/ai
	icon_state = "guide_ai"

/obj/effect/turf_decal/goon_guide/catering
	icon_state = "guide_catering"

/obj/effect/turf_decal/goon_guide/chapel
	icon_state = "guide_chapel"

/obj/effect/turf_decal/goon_guide/bank
	icon_state = "guide_credit"

/obj/effect/turf_decal/goon_guide/hazard
	icon_state = "guide_hazard"

/obj/effect/turf_decal/goon_guide/no_entry
	icon_state = "guide_no"

/obj/effect/turf_decal/goon_guide/plasma
	icon_state = "guide_plasma"

/obj/effect/turf_decal/goon_guide/tools
	icon_state = "guide_tools"

/obj/effect/turf_decal/goon_guide/arrow_east
	icon_state = "endpiece_e"

/obj/effect/turf_decal/goon_guide/arrow_west
	icon_state = "endpiece_w"

/obj/effect/turf_decal/goon_guide/arrow_north
	icon_state = "endpiece_n"

/obj/effect/turf_decal/goon_guide/arrow_south
	icon_state = "endpiece_s"

/obj/effect/turf_decal/goon_drain
	name = "floor drain"
	icon = GOON_DECOR
	icon_state = "drain"

// MARK: Display cabinet

#define GOON_CABINET_SLOTS 6

/obj/structure/goon_cabinet
	name = "display cabinet"
	desc = "A tall glass-fronted cabinet with six shelves for small things."
	icon = 'icons/obj/goon_cabinet.dmi'
	icon_state = "cabinet"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	max_integrity = 150
	/// Bottom-left corner of each 12x10 shelf slot on the sprite, bottom to top, left to right (from Goon).
	var/static/list/slot_offsets = list(list(3, 5), list(17, 5), list(3, 16), list(17, 16), list(3, 27), list(17, 27))

/obj/structure/goon_cabinet/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/goon_cabinet/update_overlays()
	. = ..()
	// shelf contents sit behind the glass, so they go into underlays like on Goon
	underlays.Cut()
	var/index = 0
	for(var/obj/item/stored in contents)
		index++
		if(index > GOON_CABINET_SLOTS)
			break
		var/list/offset = slot_offsets[index]
		var/mutable_appearance/shown = mutable_appearance(stored.icon, stored.icon_state)
		var/matrix/shrink = matrix()
		shrink.Scale(0.35, 0.35)
		shown.transform = shrink
		// the item is scaled around its own centre (16,16); move that centre to the middle of the slot
		shown.pixel_x = offset[1] + 6 - 16
		shown.pixel_y = offset[2] + 5 - 16
		underlays += shown
	for(var/i in (index + 1) to GOON_CABINET_SLOTS)
		var/list/offset = slot_offsets[i]
		var/mutable_appearance/empty = mutable_appearance(icon, "slot_empty")
		empty.pixel_x = offset[1]
		empty.pixel_y = offset[2]
		underlays += empty

/obj/structure/goon_cabinet/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool.w_class > WEIGHT_CLASS_NORMAL || (tool.flags & ABSTRACT))
		return NONE
	if(length(contents) >= GOON_CABINET_SLOTS)
		balloon_alert(user, "нет места!")
		return ITEM_INTERACT_BLOCKING
	if(!user.drop_transfer_item_to_loc(tool, src))
		return ITEM_INTERACT_BLOCKING
	user.visible_message(span_notice("[user] puts [tool] into [src]."), span_notice("You put [tool] into [src]."))
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/structure/goon_cabinet/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !length(contents))
		return
	var/list/choices = list()
	for(var/obj/item/stored in contents)
		choices[stored] = image(stored.icon, stored.icon_state)
	var/obj/item/picked = show_radial_menu(user, src, choices, require_near = TRUE)
	if(!picked || picked.loc != src || !Adjacent(user))
		return TRUE
	user.put_in_hands(picked)
	update_appearance()
	return TRUE

/obj/structure/goon_cabinet/Exited(atom/movable/gone, direction)
	. = ..()
	if(!QDELETED(src))
		update_appearance()

/obj/structure/goon_cabinet/deconstruct(disassembled = TRUE)
	for(var/atom/movable/stored as anything in contents)
		stored.forceMove(loc)
	new /obj/item/stack/sheet/glass(loc, 2)
	new /obj/item/stack/sheet/wood(loc, 5)
	qdel(src)

#undef GOON_CABINET_SLOTS

// MARK: Mapping helpers for wall-mounted decor

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/goon_candelabra, 28, 28)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/goon_candelabra/lit, 28, 28)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/goon_clock, 28, 28)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/goon_wallfish, 28, 28)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/goon_wall_decor/toilet_paper, 28, 28)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/goon_wall_decor/junction_box, 28, 28)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/goon_wall_decor/lever, 28, 28)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/goon/open_neon, 32, 32)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/goon/open_neon/on, 32, 32)

#undef GOON_DECOR
