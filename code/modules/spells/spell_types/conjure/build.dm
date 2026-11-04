/datum/action/cooldown/spell/conjure/floor
	name = "Summon Floor"
	desc = "This spell constructs a metal floor"
	button_icon_state = "floorconstruct"
	background_icon_state = "bg_cult"
	background_icon_state_active = "bg_cult"
	cooldown_time = 2 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	summon_type = list(/turf/simulated/floor/plasteel)
	summon_radius = 0

/datum/action/cooldown/spell/conjure/floor/can_cast_spell(feedback)
	var/turf/caster_t = get_turf(owner)
	if(is_admin_level(caster_t.z)) //Stop crashing the server by spawning turfs on transit tiles
		return FALSE
	return ..()

/datum/action/cooldown/spell/conjure/floor/holy
	name = "Summon Holy Floor"
	desc = "Это заклинание создаст святой пол."
	button_icon_state = "holyfloorconstruct"
	background_icon_state = "bg_spell"
	background_icon_state_active = "bg_spell"
	summon_type = list(/turf/simulated/floor/plasteel)

/datum/action/cooldown/spell/conjure/wall
	name = "Summon Wall"
	desc = "This spell constructs a metal wall"
	button_icon_state = "cultforcewall"
	background_icon_state = "bg_cult"
	background_icon_state_active = "bg_cult"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_type = list(/turf/simulated/wall) //we don't want artificer-based runed metal farms
	summon_radius = 0
	cooldown_time = 10 SECONDS

/datum/action/cooldown/spell/conjure/wall/holy
	name = "Summon Holy Wall"
	desc = "Это заклинание создаст святую стену, способную сдержать врагов. Впрочем, вы можете легко её разрушить."
	button_icon_state = "holyforcewall"
	background_icon_state = "bg_spell"
	background_icon_state_active = "bg_spell"
	summon_type = list(/turf/simulated/wall)

/datum/action/cooldown/spell/conjure/wall/reinforced
	name = "Greater Construction"
	desc = "This spell constructs a reinforced metal wall"
	cooldown_time = 30 SECONDS
	create_summon_timer = 5 SECONDS
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_type = list(/turf/simulated/wall/r_wall)

/datum/action/cooldown/spell/conjure/pylon
	name = "Healing Pylon"
	desc = "This spell conjures a fragile crystal from Redspace. Makes for a convenient light source."
	button_icon_state = "pylon"
	background_icon_state = "bg_cult"
	background_icon_state_active = "bg_cult"
	cooldown_time = 20 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_type = list(/obj/structure/construct_pylon)
	summon_radius = 0

/datum/action/cooldown/spell/conjure/pylon/holy
	name = "Holy Pylon"
	desc = "Это заклинание создаст уязвимый к повреждениям кристалл, что будет немного лечить иных коснтруктов"
	button_icon_state = "holy_pylon"
	background_icon_state = "bg_spell"
	background_icon_state_active = "bg_spell"
	summon_type = list(/obj/structure/construct_pylon/holy)

/datum/action/cooldown/spell/conjure/lesserforcewall
	name = "Shield"
	desc = "This spell creates a temporary forcefield to shield yourself and allies from incoming fire"
	button_icon_state = "cultforcewall"
	background_icon_state = "bg_cult"
	background_icon_state_active = "bg_cult"
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_lifespan = 20 SECONDS
	summon_type = list(/obj/effect/forcefield/construct_shield)
	summon_radius = 0

/datum/action/cooldown/spell/conjure/lesserforcewall/holy
	button_icon_state = "holyforcewall"
	background_icon_state = "bg_spell"
	background_icon_state_active = "bg_spell"
	summon_type = list(/obj/effect/forcefield/holy)

/obj/effect/forcefield/holy
	desc = "Этот щит так и светится! Не похоже что его можно будет убрать так просто."
	name = "holy field"
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "holy_field"
	light_color = LIGHT_COLOR_DARK_BLUE

/obj/effect/forcefield/construct_shield
	name = "eldritch wall"
	desc = "A shimmering magical barrier."
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "m_shield_cult"
	light_color = LIGHT_COLOR_INTENSE_RED

/obj/structure/construct_pylon
	name = "healing pylon"
	desc = "A floating crystal that slowly repairs nearby constructs."
	icon = 'icons/obj/cult.dmi'
	icon_state = "pylon"
	density = TRUE
	anchored = TRUE
	light_range = 1.5
	light_power = 2
	light_color = LIGHT_COLOR_FLARE
	max_integrity = 50
	var/holy = FALSE

/obj/structure/construct_pylon/Initialize(mapload)
	. = ..()
	if(holy)
		AddComponent( \
			/datum/component/aura_healing, \
			range = 5, \
			brute_heal = 0.4, \
			burn_heal = 0.4, \
			blood_heal = 0.4, \
			simple_heal = 1.2, \
			requires_visibility = FALSE, \
			limit_to_trait = TRAIT_HEALS_FROM_HOLY_PYLONS, \
			healing_color = COLOR_CULT_RED, \
			robot_heal = TRUE, \
		)
	else
		AddComponent( \
			/datum/component/aura_healing, \
			range = 5, \
			brute_heal = 0.8, \
			burn_heal = 0.8, \
			suffocation_heal = 0.5, \
			stamina_heal = 0.5, \
			blood_heal = 0.8, \
			simple_heal = 1.6, \
			requires_visibility = FALSE, \
			limit_to_trait = TRAIT_HEALS_FROM_CULT_PYLONS, \
			healing_color = COLOR_CULT_RED, \
			robot_heal = TRUE, \
		)

/obj/structure/construct_pylon/obj_destruction(damage_flag)
	visible_message(span_danger("The pylon's crystal vibrates fiercely before shattering!"))
	playsound(src, 'sound/effects/pylon_shatter.ogg', 50, TRUE)
	return ..()

/obj/structure/construct_pylon/holy
	light_color = LIGHT_COLOR_BLUE
	icon_state = "holy"
	holy = TRUE
