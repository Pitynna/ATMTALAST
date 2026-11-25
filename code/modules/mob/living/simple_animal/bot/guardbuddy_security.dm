/mob/living/simple_animal/bot/guardbuddy
	var/turf/guard_post
	var/area/guard_area
	var/datum/weakref/guarded_person
	var/datum/weakref/incident_attacker
	var/incident_until = 0
	var/last_threat
	var/last_threat_time
	COOLDOWN_DECLARE(threat_report)

/mob/living/simple_animal/bot/guardbuddy/proc/is_security_assignment()
	return program in list("secure", "areaguard", "bodyguard", "purge")

/mob/living/simple_animal/bot/guardbuddy/proc/monitor_ward(mob/living/carbon/human/person)
	var/mob/living/carbon/human/previous = guarded_person?.resolve()
	if(previous == person)
		return
	if(previous)
		UnregisterSignal(previous, list(COMSIG_HUMAN_ATTACKED, COMSIG_ATOM_BULLET_ACT))
	guarded_person = person ? WEAKREF(person) : null
	if(person)
		RegisterSignal(person, COMSIG_HUMAN_ATTACKED, PROC_REF(on_ward_melee))
		RegisterSignal(person, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_ward_projectile))

/mob/living/simple_animal/bot/guardbuddy/proc/on_ward_melee(mob/living/carbon/human/ward, mob/living/attacker)
	SIGNAL_HANDLER
	if(attacker.a_intent == INTENT_HARM)
		observe_attack(ward, attacker)

/mob/living/simple_animal/bot/guardbuddy/proc/on_ward_projectile(mob/living/carbon/human/ward, obj/projectile/shot)
	SIGNAL_HANDLER
	if(shot.damage > 0 && shot.damage_type != STAMINA && isliving(shot.firer))
		observe_attack(ward, shot.firer)

/mob/living/simple_animal/bot/guardbuddy/proc/observe_attack(mob/living/victim, mob/living/attacker)
	if(!on || !is_security_assignment() || mode == BOT_GO_HOME || mode == BOT_RESPONDING || mode == BOT_SUMMON)
		return
	if(attacker == victim || attacker == src || attacker.stat == DEAD)
		return
	var/list/witnessed = view(DEFAULT_SCAN_RANGE, src)
	if(!(victim in witnessed) || !(attacker in witnessed))
		return
	incident_attacker = WEAKREF(attacker)
	incident_until = world.time + 20 SECONDS

/mob/living/simple_animal/bot/guardbuddy/proc/scan_threats()
	for(var/mob/living/carbon/human/person in view(DEFAULT_SCAN_RANGE, src))
		if(person.stat == DEAD || person.handcuffed || !isturf(person.loc) || !within_guard_limits(person))
			continue
		var/datum/data/record/record = find_record("name", person.get_visible_name(add_id_name = FALSE), GLOB.data_core.security)
		var/status = record?.fields["criminal"]
		if(status == SEC_RECORD_STATUS_EXECUTE || (program != "purge" && status == SEC_RECORD_STATUS_ARREST))
			return person
	if(program == "purge")
		for(var/mob/living/simple_animal/hostile/creature in view(DEFAULT_SCAN_RANGE, src))
			if(creature.stat != DEAD && creature.melee_damage_upper > 0 && !faction_check_mob(creature) && within_guard_limits(creature))
				return creature
	return null

/mob/living/simple_animal/bot/guardbuddy/proc/within_guard_limits(mob/living/target)
	if(program == "secure")
		return get_dist(guard_post, target) <= DEFAULT_SCAN_RANGE
	if(program == "areaguard" || program == "purge")
		return guard_area == get_area(target)
	return TRUE

/mob/living/simple_animal/bot/guardbuddy/proc/record_threat(mob/living/target)
	last_threat = target.name
	last_threat_time = world.time
	if(is_security_assignment() && COOLDOWN_FINISHED(src, threat_report))
		COOLDOWN_START(src, threat_report, 20 SECONDS)
		speak("Security alert: [target] in [get_area_name(target)].", SEC_FREQ_NAME)

/mob/living/simple_animal/bot/guardbuddy/proc/guard_assignment()
	if(program == "bodyguard")
		var/mob/living/carbon/human/ward = get_escort_target()
		if(!ward)
			monitor_ward(null)
			stop_mission("Lost contact with the protected crewmember.")
			return
		monitor_ward(ward)
		if(!(ward in view(DEFAULT_SCAN_RANGE, src)))
			incident_attacker = null
	else if(!guard_post || guard_post.z != z)
		stop_mission("The assigned post is unavailable.")
		return

	if(mode == BOT_ARREST)
		return
	var/mob/living/threat = world.time < incident_until ? incident_attacker?.resolve() : null
	if(threat && (threat.stat == DEAD || !within_guard_limits(threat) || !(threat in view(DEFAULT_SCAN_RANGE, src))))
		incident_attacker = null
		threat = null
	if(!threat && program != "bodyguard")
		threat = scan_threats()
	var/mob/living/carbon/suspect = threat
	if(threat && (!istype(suspect) || !suspect.handcuffed))
		record_threat(threat)
		handle_threat(threat)
		return

	if(program == "bodyguard")
		escort()
	else if(loc != guard_post)
		mode = BOT_MOVING
		navigate_to(guard_post, "Could not reach the assigned security post.")
	else
		mode = BOT_IDLE
		set_path(null)

/mob/living/simple_animal/bot/guardbuddy/proc/handle_threat(mob/living/threat)
	mode = BOT_HUNT
	var/obj/item/guardbuddy_module/module = tool_module
	if(!module?.security_tool)
		return
	// Ordinary assignments use disabling tools. The purge authorization also permits mounted weapons and area effects.
	if(program != "purge" && !istype(module, /obj/item/guardbuddy_module/flash) && !istype(module, /obj/item/guardbuddy_module/taser))
		return
	var/mob/living/carbon/suspect = threat
	if(Adjacent(threat) && istype(suspect) && !suspect.handcuffed && suspect.IsWeakened() && suspect.has_organ_for_slot(ITEM_SLOT_HANDCUFFED))
		mode = BOT_ARREST
		set_path(null)
		playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE)
		suspect.visible_message(span_warning("[src] begins fastening restraints around [suspect]."))
		addtimer(CALLBACK(src, PROC_REF(finish_arrest), WEAKREF(suspect), navigation_revision), 3 SECONDS)
		return
	if(get_dist(src, threat) <= module.use_range)
		set_path(null)
		navigation_pending = FALSE
		navigation_revision++
		use_module(threat)
	else
		navigate_to(get_turf(threat), "Could not approach the security target.", 1)

/mob/living/simple_animal/bot/guardbuddy/proc/finish_arrest(datum/weakref/suspect_ref, revision)
	if(!on || mode != BOT_ARREST || navigation_revision != revision)
		return
	var/mob/living/carbon/suspect = suspect_ref.resolve()
	var/mob/living/carbon/human/ward = get_escort_target()
	if(suspect && suspect.stat != DEAD && isturf(suspect.loc) && Adjacent(suspect) && !suspect.handcuffed && within_guard_limits(suspect) && (program != "bodyguard" || (ward in view(DEFAULT_SCAN_RANGE, src))))
		suspect.apply_restraints(new /obj/item/restraints/handcuffs/cable/zipties/used(null), ITEM_SLOT_HANDCUFFED, TRUE)
		suspect.visible_message(span_warning("[src] restrains [suspect]."))
		add_attack_logs(src, suspect, "Restrained on Guardbuddy assignment")
	incident_attacker = null
	bot_reset()
