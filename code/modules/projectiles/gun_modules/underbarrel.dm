/obj/item/gun_module/under
	slot = ATTACHMENT_SLOT_UNDER

/**
 * MARK: Flashlight
 */

/obj/item/gun_module/under/flashlight
	var/obj/item/flashlight/seclite/internal
	var/buffered_overlay_on

/obj/item/gun_module/under/flashlight/Destroy()
	. = ..()
	if(buffered_overlay_on)
		QDEL_NULL(buffered_overlay_on)
	if(QDELETED(internal))
		QDEL_NULL(internal)

/obj/item/gun_module/under/flashlight/Initialize(mapload)
	. = ..()
	internal = new()
	internal.forceMove(src)
	internal.set_light_flags(internal.light_flags | LIGHT_ATTACHED)

/obj/item/gun_module/under/flashlight/attack_self(mob/user)
	. = ..()
	internal.attack_self(user)
	update_icon()

/obj/item/gun_module/under/flashlight/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.set_gun_light(internal)
	RegisterSignal(target_gun, COMSIG_GUN_LIGHT_TOGGLE, PROC_REF(udate_icon_and_overlay))

/obj/item/gun_module/under/flashlight/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.set_gun_light(null)
	internal.forceMove(src)
	internal.set_light_flags(internal.light_flags | LIGHT_ATTACHED)
	UnregisterSignal(target_gun, COMSIG_GUN_LIGHT_TOGGLE)

/obj/item/gun_module/under/flashlight/proc/udate_icon_and_overlay()
	SIGNAL_HANDLER
	if(!gun)
		return
	gun.add_attachment_overlay(src)

/obj/item/gun_module/under/flashlight/update_icon_state()
	if(internal.on)
		icon_state = "[initial(icon_state)]_on"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun_module/under/flashlight/create_overlay()
	if(!internal.on)
		return ..()
	if(!buffered_overlay_on)
		buffered_overlay_on = mutable_appearance(icon, overlay_state + "_on", layer = FLOAT_LAYER - 1)
	return buffered_overlay_on

/obj/item/gun_module/under/flashlight/pistol
	name = "pistol underbarrel light"
	desc = "A flashlight designed for pistol mounting rails. Incompatible with other weapon classes."
	icon_state = "light"
	item_state = "light"
	overlay_state = "light_o"
	class = GUN_MODULE_CLASS_PISTOL_UNDER
	overlay_offset = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 0)
	custom_price = PAYCHECK_LOWER

/obj/item/gun_module/under/flashlight/rifle
	name = "rifle underbarrel light"
	desc = "A rail-mounted flashlight. Incompatible with pistols."
	icon_state = "light_s"
	item_state = "light_s"
	overlay_state = "light_s_o"
	class = GUN_MODULE_CLASS_SHOTGUN_UNDER | GUN_MODULE_CLASS_RIFLE_UNDER
	overlay_offset = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 0)
	custom_price = 1.5 * PAYCHECK_LOWER

/**
 * MARK: Handguard
 */

/obj/item/gun_module/under/hand
	var/bonus_accuracy = 15
	var/spread_reduction = 0.30
	var/spread_decrease = 0

/obj/item/gun_module/under/hand/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.accuracy.add_accuracy(bonus_accuracy)
	if(!target_gun.accuracy.max_spread)
		return
	spread_decrease = initial(target_gun.accuracy.max_spread) * spread_reduction
	target_gun.accuracy.max_spread = target_gun.accuracy.max_spread - spread_decrease

/obj/item/gun_module/under/hand/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.accuracy.add_accuracy(-bonus_accuracy)
	target_gun.accuracy.max_spread += spread_decrease
	spread_decrease = 0

/obj/item/gun_module/under/hand/simple
	name = "rifle hand"
	desc = "A vertical grip for a weapon's lower mounting rail. Improves handling while firing."
	gender = FEMALE
	icon_state = "hand"
	item_state = "hand"
	overlay_state = "hand_o"
	class = GUN_MODULE_CLASS_SHOTGUN_UNDER | GUN_MODULE_CLASS_RIFLE_UNDER
	overlay_offset = list(ATTACHMENT_OFFSET_X = 1, ATTACHMENT_OFFSET_Y = 0)
	bonus_accuracy = 10
	spread_reduction = 0.20
	custom_price = 2 * PAYCHECK_LOWER

/obj/item/gun_module/under/hand/angle
	name = "rifle angle hand"
	desc = "An angled grip for a weapon's lower mounting rail. Improves handling while firing."
	gender = FEMALE
	icon_state = "hand_a"
	item_state = "hand_a"
	overlay_state = "hand_a_o"
	class = GUN_MODULE_CLASS_SHOTGUN_UNDER | GUN_MODULE_CLASS_RIFLE_UNDER
	overlay_offset = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 0)
	custom_price = 3 * PAYCHECK_LOWER

/**
 * MARK: Laser Sight
 */

/obj/item/gun_module/under/laser
	name = "laser sight"
	desc = "A rail-mounted laser sight. Improves accuracy and reduces shot dispersion."
	icon_state = "laser"
	item_state = "laser"
	overlay_state = "laser_o"
	class = GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_SHOTGUN_UNDER | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_SNIPER_UNDER
	overlay_offset = list(ATTACHMENT_OFFSET_X = -1, ATTACHMENT_OFFSET_Y = 1)
	var/enable = FALSE
	var/buffered_overlay_on
	var/bonus_accuracy = 10
	var/spread_decrease = 0
	var/datum/component/laser_sight/component_type
	custom_price = 2 * PAYCHECK_LOWER

/obj/item/gun_module/under/laser/Destroy()
	. = ..()
	if(buffered_overlay_on)
		QDEL_NULL(buffered_overlay_on)

/obj/item/gun_module/under/laser/create_overlay()
	if(!enable)
		return ..()
	if(!buffered_overlay_on)
		buffered_overlay_on = mutable_appearance(icon, overlay_state + "_on", layer = FLOAT_LAYER - 1)
	return buffered_overlay_on

/obj/item/gun_module/under/laser/update_icon_state()
	if(enable)
		icon_state = "[initial(icon_state)]_on"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun_module/under/laser/on_attach(obj/item/gun/target_gun, mob/user)
	RegisterSignal(target_gun, COMSIG_GUN_AFTER_LASER_SIGHT_TOGGLE, PROC_REF(laser_sight_toggle))
	gun.AddComponent(component_type)

/obj/item/gun_module/under/laser/on_detach(obj/item/gun/target_gun, mob/user)
	var/datum/component/comp = target_gun.GetComponent(component_type)
	QDEL_NULL(comp)
	UnregisterSignal(target_gun, COMSIG_GUN_AFTER_LASER_SIGHT_TOGGLE)

/obj/item/gun_module/under/laser/proc/laser_sight_toggle(datum/source, mob/user, enable)
	SIGNAL_HANDLER

	src.enable = enable
	if(gun)
		gun.add_attachment_overlay(src)
		update_icon()
	if(enable)
		add_bonus_accuracy()
		return
	remove_bonus_accuracy()

/obj/item/gun_module/under/laser/proc/add_bonus_accuracy()
	gun.accuracy.add_accuracy(bonus_accuracy)
	if(!gun.accuracy.max_spread)
		return
	spread_decrease = initial(gun.accuracy.max_spread) * 0.25
	gun.accuracy.max_spread = gun.accuracy.max_spread - spread_decrease

/obj/item/gun_module/under/laser/proc/remove_bonus_accuracy()
	gun.accuracy.add_accuracy(-bonus_accuracy)
	gun.accuracy.max_spread += spread_decrease
	spread_decrease = 0

/obj/item/gun_module/under/laser/ray
	name = "laser sight (ray)"
	component_type = /datum/component/laser_sight/ray

/obj/item/gun_module/under/laser/point
	name = "laser sight (point)"
	component_type = /datum/component/laser_sight/point

/obj/item/gun_module/under/bayonet
	name = "bayonet"
	desc = "A universal short blade with a specialized rifle barrel mount, intended primarily for close-range thrusting attacks. Its compact, reliable design makes it an effective auxiliary weapon."
	icon_state = "bayonet_short"
	item_state = "knife"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	overlay_state = "bayonet_short_o"
	overlay_offset = list(ATTACHMENT_OFFSET_X = 2, ATTACHMENT_OFFSET_Y = 4)
	class = GUN_MODULE_CLASS_RIFLE_UNDER
	force = 12
	throwforce = 12
	sharp =  TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'
	custom_price = 2 * PAYCHECK_CREW
	/// Addition force for attached gun
	var/bonus_force = 8
	/// Variable for save gun old hitsound
	var/old_hitsound
	/// Variable for save gun old sharp var
	var/old_sharp

/obj/item/gun_module/under/bayonet/sharpen_act(obj/item/whetstone/whetstone, mob/user)
	. = ..()
	if(!.)
		return
	bonus_force = clamp(bonus_force + whetstone.increment, 0, whetstone.max)

/obj/item/gun_module/under/bayonet/long
	name = "long bayonet"
	desc = "A large blade with an extended point, designed to mount on a weapon. Its length and strength provide additional force in melee, making it useful when firing is impossible or impractical."
	icon_state = "bayonet_long"
	overlay_state = "bayonet_long_o"
	overlay_offset = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = 4)
	w_class = WEIGHT_CLASS_NORMAL
	force = 15
	custom_price = 3 * PAYCHECK_CREW
	bonus_force = 10

/obj/item/gun_module/under/bayonet/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.force += bonus_force
	old_sharp = target_gun.sharp
	target_gun.sharp = TRUE
	old_hitsound = target_gun.hitsound
	target_gun.hitsound = hitsound

/obj/item/gun_module/under/bayonet/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.force -= bonus_force
	target_gun.sharp = old_sharp
	target_gun.hitsound = old_hitsound
	old_hitsound = null


// MARK: Underbarrel gun
/obj/item/gun_module/under/gun
	name = "underbarrel gun"
	desc = "An underbarrel weapon module. You should not be seeing this description."
	overlay_offset = list(ATTACHMENT_OFFSET_X = -2, ATTACHMENT_OFFSET_Y = 2)
	class = GUN_MODULE_CLASS_RIFLE_UNDER
	/// Attached internal gun instance
	var/obj/item/gun/internal_gun = null
	/// Attached internal gun type path
	var/internal_gun_type = null

/obj/item/gun_module/under/gun/Initialize(mapload)
	. = ..()
	if(internal_gun_type)
		internal_gun = new internal_gun_type(src)

/obj/item/gun_module/under/gun/Destroy()
	. = ..()
	QDEL_NULL(internal_gun)

/obj/item/gun_module/under/gun/on_attach(obj/item/gun/target_gun, mob/user)
	if(!internal_gun)
		return

	RegisterSignal(gun, COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY, PROC_REF(on_fire_from_internal_gun))
	RegisterSignal(gun, COMSIG_ATOM_ATTACKBY, PROC_REF(on_gun_pre_attack_by))

/obj/item/gun_module/under/gun/on_detach(obj/item/gun/target_gun, mob/user)
	UnregisterSignal(gun, list(COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY, COMSIG_ATOM_ATTACKBY))

/obj/item/gun_module/under/gun/proc/on_fire_from_internal_gun(obj/item/item, mob/user, atom/target, list/modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(fire_internal_gun), item, user, target, modifiers)
	return TRUE

/obj/item/gun_module/under/gun/proc/fire_internal_gun(obj/item/item, mob/user, atom/target, list/modifiers)
	if(!internal_gun)
		return
	internal_gun.set_gun_user(user)
	internal_gun.start_fire(user, target, get_turf(target), params = list2params(modifiers - RIGHT_CLICK))
	internal_gun.set_gun_user(null)

/obj/item/gun_module/under/gun/proc/on_gun_pre_attack_by(atom/source, obj/item/item, mob/living/attacker, list/modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(try_reload_internal_gun), item, attacker, modifiers)

/obj/item/gun_module/under/gun/proc/try_reload_internal_gun(obj/item/item, mob/living/attacker, list/modifiers)
	if(!internal_gun)
		return
	internal_gun.attackby(item, attacker, modifiers)


// MARK: Grenade launcher
/obj/item/gun_module/under/gun/grenade_launcher
	name = "underbarrel grenade launcher"
	desc = "An underbarrel 40mm grenade launcher module."
	icon_state = "grenade"
	overlay_state = "grenade_o"
	internal_gun_type = /obj/item/gun/projectile/revolver/grenadelauncher

/obj/item/gun_module/under/gun/grenade_launcher/try_reload_internal_gun(obj/item/item, mob/living/user, list/modifiers)
	var/obj/item/gun/projectile/revolver/grenadelauncher/launcher = internal_gun
	if(launcher && istype(launcher) && launcher.get_ammo() > 0)
		launcher.unload_act(user)
	return ..()

/obj/item/gun_module/under/gun/grenade_launcher/integrated
	can_detach = FALSE
	overlay_state = null

/obj/item/gun_module/under/gun/grenade_launcher/integrated/unloaded/Initialize(mapload)
	. = ..()
	QDEL_NULL(internal_gun.chambered)

// MARK: Shotgun
/obj/item/gun_module/under/gun/shotgun
	name = "underbarrel shotgun"
	desc = "An underbarrel 12-gauge shotgun module holding 3+1 shells."
	icon_state = "shotgun"
	overlay_state = "shotgun_o"
	internal_gun_type = /obj/item/gun/projectile/shotgun/riot/short

/obj/item/gun_module/under/gun/shotgun/fire_internal_gun(obj/item/item, mob/user, atom/target, list/modifiers)
	. = ..()
	var/obj/item/gun/projectile/shotgun/riot/short/shotgun = internal_gun
	if(shotgun && istype(shotgun) && shotgun.get_ammo() > 0)
		addtimer(CALLBACK(shotgun, TYPE_PROC_REF(/obj/item/gun/projectile/shotgun, pump), user), 0.1 SECONDS)

// MARK: Taser
/obj/item/gun_module/under/gun/taser
	name = "underbarrel taser"
	desc = "An underbarrel taser module. Holds fifteen shots but unfortunately cannot be recharged."
	icon_state = "shotgun"
	overlay_state = "shotgun_o"
	internal_gun_type = /obj/item/gun/energy/taser
