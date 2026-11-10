/// Artifact triggers retain the original environmental/chemical experimentation loop.
/obj/machinery/xenoarch_artifact
	name = "alien artifact"
	desc = "A large device of unknown origin. Its controls and purpose are mysterious."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "ano00"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	var/artifact_id
	var/effect_type
	var/trigger_type
	var/effect_mode
	var/effect_range
	var/activated = FALSE
	var/research_sample_taken = FALSE
	var/appearance_number
	var/next_effect = 0
	var/static/list/effects = list("healing", "injury", "charging", "draining", "EMP", "warming", "cooling", "oxygen", "nitrogen", "carbon dioxide", "plasma", "stunning")
	var/static/list/triggers = list("touch", "water", "acid", "volatile chemicals", "toxin", "force", "energy", "heat", "cold", "plasma", "oxygen", "carbon dioxide", "nitrogen")

/obj/machinery/xenoarch_artifact/Initialize(mapload)
	. = ..()
	artifact_id = "XA-[UID()]"
	effect_type = pick(effects)
	trigger_type = pick(triggers)
	effect_mode = pick("touch", "aura", "pulse")
	effect_range = rand(1, 4)
	appearance_number = rand(0, 11)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/xenoarch_artifact/update_icon_state()
	icon_state = "ano[appearance_number][activated ? 1 : 0]"

/proc/xenoarch_suppressed(atom/target)
	for(var/obj/machinery/xenoarch/suspension/generator as anything in GLOB.xenoarch_containment)
		if(generator.enabled && !(generator.stat & (NOPOWER|BROKEN)) && generator.z == target.z && get_dist(generator, target) <= 3)
			return TRUE
	return FALSE

/obj/machinery/xenoarch_artifact/proc/toggle_activation(mob/user)
	if(xenoarch_suppressed(src))
		if(user)
			to_chat(user, span_notice("The suspension field suppresses [src]."))
		return FALSE
	activated = !activated
	update_icon(UPDATE_ICON_STATE)
	visible_message(span_notice("[src] [activated ? "begins to hum" : "falls silent"]."))
	if(user)
		add_attack_logs(user, src, "[activated ? "Activated" : "Deactivated"] archaeological artifact ([effect_type], [trigger_type])")
	return TRUE

/obj/machinery/xenoarch_artifact/attack_hand(mob/living/user)
	if(!user.Adjacent(src))
		return
	add_fingerprint(user)
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		if(human.gloves)
			to_chat(user, span_notice("Your gloves prevent direct contact with the artifact."))
			return
	if(trigger_type == "touch")
		toggle_activation(user)
	if(activated && effect_mode == "touch" && !xenoarch_suppressed(src))
		apply_xenoarch_effect(effect_type, src, user, 0)

/obj/machinery/xenoarch_artifact/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/reagent_containers) && item.reagents)
		var/list/reagent_triggers = list("water" = "water", "sacid" = "acid", "facid" = "acid", "fuel" = "volatile chemicals", "plasma" = "volatile chemicals", "toxin" = "toxin", "cyanide" = "toxin")
		for(var/reagent_id in reagent_triggers)
			if(reagent_triggers[reagent_id] == trigger_type && item.reagents.has_reagent(reagent_id, 1))
				item.reagents.remove_reagent(reagent_id, 1)
				toggle_activation(user)
				return ATTACK_CHAIN_BLOCKED_ALL
	var/hot_tool = FALSE
	if(istype(item, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = item
		hot_tool = welder.tool_enabled
	if(istype(item, /obj/item/lighter))
		var/obj/item/lighter/lighter = item
		hot_tool = lighter.heat > 0
	if((trigger_type == "force" && item.force >= 10) || (trigger_type == "energy" && item.tool_behaviour == TOOL_MULTITOOL) || (trigger_type == "heat" && hot_tool))
		toggle_activation(user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/machinery/xenoarch_artifact/bullet_act(obj/projectile/projectile, def_zone, piercing_hit = FALSE)
	if(trigger_type == "energy" && (projectile.damage_type == BURN || projectile.damage_type == STAMINA))
		toggle_activation(projectile.firer)
	return ..()

/obj/machinery/xenoarch_artifact/process()
	if(xenoarch_suppressed(src))
		return
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location?.get_readonly_air()
	var/environment_trigger = FALSE
	if(environment)
		switch(trigger_type)
			if("heat")
				environment_trigger = environment.temperature() > 375
			if("cold")
				environment_trigger = environment.temperature() < 225
			if("oxygen")
				environment_trigger = environment.oxygen() >= 10
			if("nitrogen")
				environment_trigger = environment.nitrogen() >= 10
			if("carbon dioxide")
				environment_trigger = environment.carbon_dioxide() >= 10
			if("plasma")
				environment_trigger = environment.toxins() >= 10
	if(trigger_type in list("heat", "cold", "oxygen", "nitrogen", "carbon dioxide", "plasma"))
		if(environment_trigger != activated)
			activated = environment_trigger
			update_icon(UPDATE_ICON_STATE)
	if(!activated || effect_mode == "touch" || world.time < next_effect)
		return
	next_effect = world.time + (effect_mode == "pulse" ? 10 SECONDS : 2 SECONDS)
	apply_xenoarch_effect(effect_type, src, null, effect_range)

/// Used by both intact artifacts and finite-charge harvested anomaly devices.
/proc/apply_xenoarch_effect(effect_type, atom/source, mob/living/touched, radius)
	var/turf/location = get_turf(source)
	if(!location)
		return
	var/list/targets = touched ? list(touched) : list()
	if(!touched)
		for(var/mob/living/target in view(radius, source))
			targets += target
	for(var/mob/living/target as anything in targets)
		switch(effect_type)
			if("healing")
				target.adjustBruteLoss(-3)
				target.adjustFireLoss(-3)
			if("injury")
				target.adjustBruteLoss(3)
			if("stunning")
				target.Stun(1 SECONDS)
			if("warming")
				target.bodytemperature += 10
			if("cooling")
				target.bodytemperature -= 10
	if(effect_type == "charging" || effect_type == "draining")
		for(var/obj/item/stock_parts/cell/cell in range(max(1, radius), source))
			if(effect_type == "charging")
				cell.give(100)
			else
				cell.use(min(100, cell.charge))
	if(effect_type == "EMP")
		empulse(location, 0, max(1, radius))
	var/gas_id
	switch(effect_type)
		if("oxygen")
			gas_id = GAS_O2
		if("nitrogen")
			gas_id = GAS_N2
		if("carbon dioxide")
			gas_id = GAS_CO2
		if("plasma")
			gas_id = GAS_PL
	if(gas_id)
		var/datum/gas_mixture/gas = new
		gas.set_temperature(T20C)
		gas.adjust_gas(gas_id, 2)
		location.blind_release_air(gas)

/obj/item/xenoarch_battery
	name = "anomaly battery"
	desc = "An empty exotic particle trap. A harvester can fill it from an excavated artifact."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "anobattery0"
	w_class = WEIGHT_CLASS_SMALL
	var/effect_type
	var/charges = 0

/obj/item/xenoarch_battery/examine(mob/user)
	. = ..()
	. += span_notice("Stored effect: [effect_type ? effect_type : "none"]. Charges: [charges].")

/obj/item/xenoarch_battery/update_icon_state()
	icon_state = "anobattery[clamp(round(charges * 10, 25), 0, 100)]"

/obj/item/xenoarch_utilizer
	name = "anomaly utilizer"
	desc = "Insert a harvested anomaly battery and activate to reproduce its effect within one tile."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "anodev"
	w_class = WEIGHT_CLASS_NORMAL
	var/obj/item/xenoarch_battery/battery
	var/next_use = 0

/obj/item/xenoarch_utilizer/Destroy()
	QDEL_NULL(battery)
	return ..()

/obj/item/xenoarch_utilizer/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/xenoarch_battery) && !battery)
		if(user.drop_transfer_item_to_loc(item, src))
			battery = item
			update_icon(UPDATE_ICON_STATE)
			to_chat(user, span_notice("You fit [item] into [src]."))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/item/xenoarch_utilizer/attack_self(mob/user)
	if(!battery?.charges || world.time < next_use)
		to_chat(user, span_warning("The battery is empty or the device is cooling down."))
		return
	if(xenoarch_suppressed(src))
		to_chat(user, span_warning("A suspension field blocks the device."))
		return
	next_use = world.time + 5 SECONDS
	battery.charges--
	battery.update_icon(UPDATE_ICON_STATE)
	update_icon(UPDATE_ICON_STATE)
	add_attack_logs(user, src, "Used anomaly utilizer ([battery.effect_type])")
	apply_xenoarch_effect(battery.effect_type, user, null, 1)

/obj/item/xenoarch_utilizer/screwdriver_act(mob/user, obj/item/tool)
	if(!battery)
		return FALSE
	battery.forceMove(get_turf(src))
	battery = null
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/item/xenoarch_utilizer/update_icon_state()
	icon_state = battery ? "anodev[clamp(round(battery.charges * 10, 25), 0, 100)]" : "anodev"
