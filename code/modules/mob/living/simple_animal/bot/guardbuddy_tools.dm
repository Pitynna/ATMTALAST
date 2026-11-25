/obj/item/guardbuddy_module
	/// Maximum range in tiles. Zero means the module has no active use.
	var/use_range = 0
	var/battery_cost = 5
	var/use_delay = 4 SECONDS
	var/security_tool = FALSE
	var/tool_error

/obj/item/guardbuddy_module/proc/can_apply(mob/living/simple_animal/bot/guardbuddy/bot, atom/target)
	return TRUE

/obj/item/guardbuddy_module/proc/apply(mob/living/simple_animal/bot/guardbuddy/bot, atom/target)
	return FALSE

/obj/item/guardbuddy_module/proc/fire_projectile(mob/living/simple_animal/bot/guardbuddy/bot, atom/target, obj/projectile/projectile, fire_sound)
	projectile.firer = bot
	if(!projectile.preparePixelProjectile(target, bot))
		return FALSE
	playsound(bot, fire_sound, 45, TRUE)
	projectile.fire()
	return TRUE

/obj/item/guardbuddy_module/flash
	name = "Guardbuddy flash"
	desc = "A short-range flash module for stopping a threat."
	icon_state = "tool_flash"
	use_range = 1
	security_tool = TRUE

/obj/item/guardbuddy_module/flash/can_apply(mob/living/simple_animal/bot/guardbuddy/bot, atom/target)
	return isliving(target)

/obj/item/guardbuddy_module/flash/apply(mob/living/simple_animal/bot/guardbuddy/bot, mob/living/target)
	playsound(bot, 'sound/weapons/flash.ogg', 45, TRUE)
	if(target.flash_eyes(affect_silicon = TRUE))
		target.Weaken(2 SECONDS)
	return TRUE

/obj/item/guardbuddy_module/taser
	name = "Guardbuddy taser"
	desc = "A module that fires a short-range electrode."
	icon_state = "tool_taser"
	use_range = 5
	battery_cost = 12
	security_tool = TRUE

/obj/item/guardbuddy_module/taser/apply(mob/living/simple_animal/bot/guardbuddy/bot, atom/target)
	return fire_projectile(bot, target, new /obj/projectile/energy/electrode(get_turf(bot)), 'sound/weapons/taser.ogg')

/obj/item/guardbuddy_module/arc
	name = "Guardbuddy Elektro-Arc"
	desc = "A module that sends an electric arc at the selected target."
	icon_state = "tool_tesla"
	use_range = 4
	battery_cost = 20
	security_tool = TRUE

/obj/item/guardbuddy_module/arc/apply(mob/living/simple_animal/bot/guardbuddy/bot, atom/target)
	return fire_projectile(bot, target, new /obj/projectile/energy/tesla_cannon(get_turf(bot)), 'sound/weapons/taser.ogg')

/obj/item/guardbuddy_module/reagent
	desc = "A Guardbuddy module with a single beaker slot."
	var/obj/item/reagent_containers/cup/beaker/beaker
	var/dose = 10

/obj/item/guardbuddy_module/reagent/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/reagent_containers/cup/beaker) && user.a_intent != INTENT_HARM)
		insert_beaker(item, user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/item/guardbuddy_module/reagent/attack_self(mob/user)
	if(beaker && user.is_in_hands(src))
		eject_beaker(user)
		return TRUE
	return ..()

/obj/item/guardbuddy_module/reagent/examine(mob/user)
	. = ..()
	. += span_notice(beaker ? "Loaded: [mixture_description()]" : "The beaker slot is empty.")
	. += span_notice("Use the loose module in hand to remove its beaker.")

/obj/item/guardbuddy_module/reagent/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == beaker)
		beaker = null

/obj/item/guardbuddy_module/reagent/Destroy()
	if(beaker && get_turf(src))
		beaker.forceMove(get_turf(src))
	beaker = null
	return ..()

/obj/item/guardbuddy_module/reagent/proc/insert_beaker(obj/item/reagent_containers/cup/beaker/new_beaker, mob/user)
	if(beaker)
		to_chat(user, span_warning("Remove the existing beaker first."))
		return FALSE
	if(!user.drop_transfer_item_to_loc(new_beaker, src))
		return FALSE
	beaker = new_beaker
	tool_error = null
	to_chat(user, span_notice("You fit [beaker] into [src]."))
	return TRUE

/obj/item/guardbuddy_module/reagent/proc/eject_beaker(mob/user)
	var/obj/item/reagent_containers/cup/beaker/old_beaker = beaker
	if(!old_beaker)
		return FALSE
	old_beaker.forceMove(get_turf(src))
	user.put_in_hands(old_beaker)
	tool_error = null
	return TRUE

/obj/item/guardbuddy_module/reagent/proc/mixture_description()
	if(!beaker)
		return "No beaker"
	var/list/components = list()
	for(var/datum/reagent/ingredient as anything in beaker.reagents.reagent_list)
		components += "[ingredient.name] ([round(ingredient.volume, 0.1)]u)"
	var/volume = round(beaker.reagents.total_volume, 0.1)
	return volume ? "[volume]u: [components.Join(", ")]" : "Empty beaker (0u)"

/obj/item/guardbuddy_module/reagent/can_apply(mob/living/simple_animal/bot/guardbuddy/bot, atom/target)
	if(!beaker)
		tool_error = "Insert a beaker."
		return FALSE
	if(beaker.reagents.total_volume < dose)
		tool_error = "At least [dose]u required for an application."
		return FALSE
	return TRUE

/obj/item/guardbuddy_module/reagent/medicator
	name = "Guardbuddy Medicator"
	desc = "A syringe launcher supplied by a removable beaker."
	icon_state = "tool_syringe"
	use_range = 6
	use_delay = 6 SECONDS
	dose = 10

/obj/item/guardbuddy_module/reagent/medicator/apply(mob/living/simple_animal/bot/guardbuddy/bot, atom/target)
	var/obj/projectile/bullet/dart/syringe/syringe = new(get_turf(bot))
	// Charge the syringe before launch. The payload belongs to the projectile even if it misses.
	beaker.reagents.trans_to(syringe, dose, no_react = TRUE)
	return fire_projectile(bot, target, syringe, 'sound/items/syringeproj.ogg')

/obj/item/guardbuddy_module/reagent/smoker
	name = "Guardbuddy Smoker"
	desc = "A chemical smoke module supplied by a removable beaker."
	icon_state = "tool_smoke"
	use_range = 1
	use_delay = 12 SECONDS
	battery_cost = 10
	dose = 15
	security_tool = TRUE

/obj/item/guardbuddy_module/reagent/smoker/apply(mob/living/simple_animal/bot/guardbuddy/bot, atom/target)
	var/turf/start = get_turf(bot)
	var/datum/reagents/portion = new(dose)
	beaker.reagents.trans_to(portion, dose, no_react = TRUE)
	var/datum/effect_system/fluid_spread/smoke/chem/quick/smoke = new()
	smoke.set_up(range = 1, holder = bot, location = start, carry = portion, silent = TRUE)
	smoke.start()
	qdel(portion)
	qdel(smoke)
	return TRUE

/obj/item/guardbuddy_module/launcher
	use_range = 6
	use_delay = 5 SECONDS
	var/payload_type

/obj/item/guardbuddy_module/launcher/apply(mob/living/simple_animal/bot/guardbuddy/bot, atom/target)
	var/obj/item/payload = new payload_type(get_turf(bot))
	payload.throw_at(target, use_range, 2, bot)
	return TRUE

/obj/item/guardbuddy_module/launcher/pie
	name = "Shoddy Pie Launcher"
	desc = "A Guardbuddy module that throws a cream pie."
	icon_state = "tool_pie"
	payload_type = /obj/item/reagent_containers/food/snacks/pie

/obj/item/guardbuddy_module/launcher/snowball
	name = "Snowballer XL"
	desc = "A Guardbuddy module that throws a festive snowball."
	icon_state = "tool_xmas"
	payload_type = /obj/item/snowball

/obj/item/guardbuddy_bulletbuddy
	name = "BulletBuddy fabrication kit"
	desc = "An upgrade that spends battery charge to make rubber rounds for a mounted Taurus."
	icon = 'icons/obj/guardbuddy/parts.dmi'
	icon_state = "misc_upgrade"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/guardbuddy_module/weapon
	name = "Guardbuddy weapon mount"
	desc = "An empty manipulator adapter for a standard disabler or R45 Taurus revolver."
	icon_state = "tool_generic"
	use_range = 6
	security_tool = TRUE
	var/obj/item/gun/weapon
	var/obj/item/guardbuddy_bulletbuddy/fabricator
	COOLDOWN_DECLARE(ammo_cycle)

/obj/item/guardbuddy_module/weapon/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(istype(item, /obj/item/guardbuddy_bulletbuddy))
		if(!fabricator && user.drop_transfer_item_to_loc(item, src))
			fabricator = item
		return ATTACK_CHAIN_BLOCKED_ALL
	if(isgun(item))
		if(!weapon && (item.type == /obj/item/gun/energy/disabler || item.type == /obj/item/gun/projectile/revolver/taurus) && user.drop_transfer_item_to_loc(item, src))
			weapon = item
		else
			to_chat(user, span_warning("The mount needs an empty slot and a compatible gun."))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/item/guardbuddy_module/weapon/attack_self(mob/user)
	if(!user.is_in_hands(src))
		return ..()
	var/obj/item/part = weapon ? weapon : fabricator
	if(!part)
		return ..()
	part.forceMove(get_turf(src))
	user.put_in_hands(part)
	return TRUE

/obj/item/guardbuddy_module/weapon/examine(mob/user)
	. = ..()
	. += span_notice("Weapon: [weapon ? weapon.name : "None"]. BulletBuddy: [fabricator ? "Installed" : "Empty"].")

/obj/item/guardbuddy_module/weapon/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == weapon)
		weapon = null
	if(gone == fabricator)
		fabricator = null

/obj/item/guardbuddy_module/weapon/can_apply(mob/living/simple_animal/bot/guardbuddy/bot, atom/target)
	if(!weapon || !weapon.can_shoot(bot))
		tool_error = weapon ? "Mounted weapon has no charge or ammunition." : "No weapon mounted."
		return FALSE
	return TRUE

/obj/item/guardbuddy_module/weapon/apply(mob/living/simple_animal/bot/guardbuddy/bot, atom/target)
	return !!weapon.fast_fire(target, bot)

/obj/item/guardbuddy_module/weapon/proc/fabricate(mob/living/simple_animal/bot/guardbuddy/bot)
	var/obj/item/gun/projectile/revolver/taurus/revolver = weapon
	if(!fabricator || !istype(revolver) || !COOLDOWN_FINISHED(src, ammo_cycle) || !bot.cell || bot.cell.charge < 25 || revolver.get_ammo(FALSE, FALSE) >= revolver.magazine.max_ammo)
		return FALSE
	var/obj/item/ammo_casing/c45colt/rubber/round = new(src)
	if(!revolver.magazine.give_round(round, replace_spent = TRUE))
		qdel(round)
		return FALSE
	bot.cell.use(25)
	revolver.chamber_round()
	COOLDOWN_START(src, ammo_cycle, 10 SECONDS)
	return TRUE
