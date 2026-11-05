/// Шипомет перезаряжаемый через "вокс батарейки"
/obj/item/gun/energy/spike
	name = "Vox spike gun"
	desc = "An oddly shaped weapon with bright purple energy lights. Its grip is designed for a clawed hand. Fires energy crystals."
	icon = 'icons/obj/weapons/vox_guns.dmi'
	icon_state = "spike"
	item_state = "spike"
	fire_sound_text = "air gap"
	burst_amount = 3
	shaded_charge = TRUE
	can_charge = FALSE
	cell_type = /obj/item/stock_parts/cell/vox_spike
	ammo_type = list(/obj/item/ammo_casing/energy/vox_spike)
	restricted_species = (/datum/species/vox)
	var/can_reload = TRUE
	var/is_vox_private = FALSE

/obj/item/gun/energy/spike/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

/obj/item/gun/energy/spike/attackby(obj/item/item, mob/living/user, list/modifiers)
	if(can_reload && istype(item, cell_type) && user && user.temporarily_remove_item_from_inventory(item))
		to_chat(user, span_notice("Вы заменили [item.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]!"))
		if(cell)
			user.put_in_hands(cell)
		item.forceMove(src)
		cell = item
		on_recharge()
		update_appearance(UPDATE_ICON)
		playsound(src, 'sound/weapons/m79_break_open.ogg', 50, 1)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/item/gun/energy/spike/update_icon_state()
	. = ..()
	var/inhand_ratio = ceil((cell.charge / cell.maxcharge) * charge_sections)
	var/new_item_state = "[initial(item_state)][inhand_ratio]"
	item_state = new_item_state

/obj/item/gun/energy/spike/long
	name = "Vox spike longgun"
	desc = "An oddly shaped weapon with bright purple energy lights. Its grip is designed for a clawed hand. Fires long, self-regenerating energy crystals with improved penetration."
	icon_state = "spike_long"
	item_state = "spike_long"
	charge_sections = 6
	selfcharge = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/vox_spike/long)

/obj/item/gun/energy/spike/long/process()
	if(selfcharge)
		if(charge_tick < charge_delay)
			return ..()
		playsound(src, 'sound/weapons/m79_reload.ogg', 25, 1)
	return ..()

/obj/item/gun/energy/spike/bio
	name = "Vox spike biogun"
	desc = "An oddly shaped weapon with tubular spikes for mounting on an arm. Its grip fits a clawed hand and bears sharp hollow spikes. Fires large, sharp, fragmenting energy crystals that exhaust targets and ricochet off surfaces."
	icon_state = "spike_bio"
	item_state = "spike_bio"
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = list(/obj/item/ammo_casing/energy/vox_spike/big)
	selfcharge = TRUE
	can_reload = FALSE
	charge_delay = 8
	/// How many nutrients are spent per 1 tick
	var/nutrition_cost = 20
	/// The price for not being a vox in brute
	var/brute_cost = 5
	/// The price for not being a vox in stamina
	var/stamina_cost = 20

/obj/item/gun/energy/spike/bio/process()
	if(selfcharge)
		if(!ishuman(loc))
			return FALSE
		if(charge_tick < charge_delay)
			return ..()
		var/mob/living/carbon/human/user = loc
		if(user.nutrition <= NUTRITION_LEVEL_HYPOGLYCEMIA)
			return ..()
		user.adjust_nutrition(-nutrition_cost)
		if(!isvox(user))
			user.adjustBruteLoss(brute_cost)
			user.adjustStaminaLoss(stamina_cost)
		playsound(src, 'sound/weapons/m79_reload.ogg', 25, 1)

	return ..()
