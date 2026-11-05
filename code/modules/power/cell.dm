/obj/item/stock_parts/cell
	name = "power cell A"
	desc = "A rechargeable electrochemical power cell. This one is cheap and doesn't have very good capacity as a result."
	gender = FEMALE
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	origin_tech = "powerstorage=1"
	force = 5
	throwforce = 5
	throw_range = 5
	/// How much charge the battery currently has
	var/charge = 0
	/// How much charge the battery can hold
	var/maxcharge = 1000
	materials = list(MAT_METAL = 700, MAT_GLASS = 50)
	/// If the battery will explode
	var/rigged = FALSE
	/// How much charge is given every tick when recharging
	var/chargerate = 100
	/// Whether it will recharge automatically
	var/self_recharge = FALSE
	/// Whether the description will include the maxcharge
	var/ratingdesc = TRUE
	/// Additional overlay to signify battery being organic
	var/grown_battery = FALSE
	// For custom overlays.
	var/overlay_charged = "cell-o2"
	// Damage multiplier the cells take from emps to prevent stuff like bluespace cells taking 40 shots to drain.
	var/emp_damage_modifier = 1

/obj/item/stock_parts/cell/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	charge = maxcharge
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/stock_parts/cell/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(isturf(old_loc))
		return
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/magic_charge_act(mob/user)
	. = NONE

	if(charge >= maxcharge)
		return

	if(prob(80) && adjust_maxcharge(-200))
		. |= RECHARGE_BURNOUT

	charge = maxcharge
	. |= RECHARGE_SUCCESSFUL

	update_appearance(UPDATE_ICON)

/obj/item/stock_parts/cell/proc/adjust_maxcharge(amount)
	if(self_recharge)
		return FALSE	// SelfCharging uses static charge values ​​per tick, so we don't want it to mess up the recharge balance.

	var/old_maxcharge = maxcharge
	maxcharge = max(maxcharge + amount, 1)
	update_icon(UPDATE_OVERLAYS)
	return maxcharge != old_maxcharge

/obj/item/stock_parts/cell/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, self_recharge))
		if(var_value)
			START_PROCESSING(SSobj, src)
		else
			STOP_PROCESSING(SSobj, src)

/obj/item/stock_parts/cell/process()
	if(self_recharge)
		give(chargerate * 0.25)
	else
		return PROCESS_KILL

/obj/item/stock_parts/cell/update_overlays()
	. = ..()
	if(grown_battery)
		. += image('icons/obj/engines_and_power/power.dmi', "grown_wires")
	if(charge < 0.01)
		return
	else if(charge / maxcharge >= 0.995)
		. += overlay_charged
	else
		. += "cell-o1"

/obj/item/stock_parts/cell/proc/percent()		// return % charge of cell
	return 100 * charge / maxcharge

// use power from a cell
/obj/item/stock_parts/cell/use(amount)
	if(rigged && amount > 0)
		explode()
		return FALSE
	if(charge < amount)
		return FALSE
	charge = (charge - amount)
	return TRUE

// recharge the cell
/obj/item/stock_parts/cell/proc/give(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(maxcharge < amount)
		amount = maxcharge
	var/power_used = min(maxcharge - charge, amount)
	charge += power_used
	return power_used

/obj/item/stock_parts/cell/examine(mob/user)
	. = ..()

	. += span_notice("<b>Максимальная мощность:</b> [display_power(maxcharge, FALSE)].")

	if(rigged)
		. += span_notice("Судя по всему, химический элемент был модифицирован.")
	else
		. += span_notice("<b>Индикатор заряда:</b> [round(percent())]%")

/obj/item/stock_parts/cell/suicide_act(mob/user)
	to_chat(viewers(user), span_suicide("[user] облизыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)]! Похоже, что [GEND_HE_SHE(user)] пыта[PLUR_ET_YUT(user)]ся совершить самоубийство!"))
	return FIRELOSS

/obj/item/stock_parts/cell/attackby(obj/item/I, mob/user, params)
	if(issyringe(I))
		add_fingerprint(user)
		var/obj/item/reagent_containers/syringe/syringe = I
		if(syringe.mode != 1)	// injecting
			balloon_alert(user, "не в режиме ввода!")
			return ATTACK_CHAIN_PROCEED
		if(!syringe.reagents.total_volume)
			balloon_alert(user, "пусто!")
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "вещество введено")
		if(syringe.reagents.has_reagent("plasma", 5) || syringe.reagents.has_reagent("plasma_dust", 5))
			rigged = TRUE
			log_admin("LOG: [key_name(user)] injected a power cell with plasma, rigging it to explode.")
			message_admins("LOG: [key_name_admin(user)] injected a power cell with plasma, rigging it to explode.")
		syringe.reagents.clear_reagents()
		syringe.update_icon()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/stock_parts/cell/proc/explode()
	var/turf/T = get_turf(loc)
	if(charge == 0)
		return
	var/devastation_range = -1 //round(charge/11000)
	var/heavy_impact_range = round(sqrt(charge) / 60)
	var/light_impact_range = round(sqrt(charge) / 30)
	var/flash_range = light_impact_range
	if(light_impact_range == 0)
		corrupt()
		return
	log_admin("LOG: Rigged power cell explosion, last touched by [fingerprintslast]")
	message_admins("LOG: Rigged power cell explosion, last touched by [fingerprintslast]")
	rigged = FALSE

	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range, cause = src)
	qdel(src)

/obj/item/stock_parts/cell/proc/corrupt()
	charge /= 2
	maxcharge = max(maxcharge / 2, chargerate)
	if(prob(10))
		rigged = TRUE //broken batterys are dangerous

/obj/item/stock_parts/cell/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	use(round(min(charge, (STANDARD_CELL_CHARGE / severity) * emp_damage_modifier)))
	if(!QDELETED(src))
		update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/ex_act(severity, target)
	. = ..()
	if(QDELETED(src))
		return

	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				corrupt()
		if(EXPLODE_LIGHT)
			if(prob(25))
				corrupt()

/obj/item/stock_parts/cell/blob_act(obj/structure/blob/B)
	ex_act(EXPLODE_DEVASTATE)

/obj/item/stock_parts/cell/proc/get_electrocute_damage()
	// Wouldn't want it to consider more energy than whatever is actually in the cell if for some strange reason someone set the STANDARD_CELL_CHARGE to below 1kJ.
	return ELECTROCUTE_DAMAGE(charge / max(0.001 * STANDARD_CELL_CHARGE, 1))

// MARK: Cell variants
/obj/item/stock_parts/cell/empty/Initialize(mapload)
	. = ..()
	charge = 0

/obj/item/stock_parts/cell/upgraded
	name = "power cell A+"
	maxcharge = 2500
	materials = list(MAT_GLASS = 50)
	rating = 2
	chargerate = 1000

/obj/item/stock_parts/cell/upgraded/plus
	name = "power cell A++"
	maxcharge = 5000

/obj/item/stock_parts/cell/high
	name = "power cell AA"
	origin_tech = "powerstorage=2"
	icon_state = "hcell"
	maxcharge = 10000
	materials = list(MAT_GLASS = 60)
	rating = 3
	chargerate = 1500

/obj/item/stock_parts/cell/high/plus
	name = "high-capacity power cell+"
	maxcharge = 15000
	chargerate = 2250

/obj/item/stock_parts/cell/high/empty/Initialize(mapload)
	. = ..()
	charge = 0
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/super
	name = "power cell AAA"
	origin_tech = "powerstorage=3;materials=3"
	icon_state = "scell"
	maxcharge = 20000
	materials = list(MAT_GLASS = 300)
	rating = 4
	chargerate = 2000

/obj/item/stock_parts/cell/super/empty/Initialize(mapload)
	. = ..()
	charge = 0
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/hyper
	name = "power cell AAAA"
	origin_tech = "powerstorage=4;engineering=4;materials=4"
	icon_state = "hpcell"
	maxcharge = 30000
	materials = list(MAT_GLASS = 400)
	rating = 5
	chargerate = 3000

/obj/item/stock_parts/cell/hyper/empty/Initialize(mapload)
	. = ..()
	charge = 0
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/bluespace
	name = "bluespace power cell"
	desc = "A rechargeable electrochemical power cell. At the very forefront of power storage technology, there are few gains to be found from optimizing the cell's chemistry. \
	So the designers of this cell tried something much more conceptually simple: They took a super-capacity cell and made it twice as big. \
	They then exploited the transdimensional properties of bluespace to squeeze it down to a standard cell's form factor."
	origin_tech = "powerstorage=5;bluespace=4;materials=4;engineering=4"
	icon_state = "bscell"
	maxcharge = 40000
	materials = list(MAT_GLASS = 600)
	rating = 6
	chargerate = 4000
	overlay_charged = "cell-o2-bs"

/obj/item/stock_parts/cell/bluespace/empty/Initialize(mapload)
	. = ..()
	charge = 0
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/infinite
	name = "infinite-capacity power cell"
	icon_state = "icell"
	origin_tech =  "powerstorage=7"
	maxcharge = 30000
	materials = list(MAT_GLASS=1000)
	rating = 6
	chargerate = 30000

/obj/item/stock_parts/cell/infinite/use()
	return TRUE

/obj/item/stock_parts/cell/infinite/abductor
	name = "void core"
	desc = "An alien power cell of unknown design. It produces endless amounts of energy seemingly out of nowhere."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "cell"
	maxcharge = 50000
	rating = 12
	ratingdesc = FALSE

/obj/item/stock_parts/cell/infinite/abductor/update_overlays()
	return list()

/obj/item/stock_parts/cell/potato
	name = "potato battery"
	desc = "A rechargeable starch-based power cell. The charge capacity depends on the potency of the plant used to create it."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "potato"
	origin_tech = "powerstorage=1;biotech=1"
	charge = 100
	maxcharge = 300
	materials = list()
	grown_battery = TRUE //it has the overlays for wires

/obj/item/stock_parts/cell/high/slime
	name = "charged slime core"
	desc = "A yellow slime core infused with plasma, it crackles with power."
	origin_tech = "powerstorage=5;biotech=4"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "yellow slime extract"
	materials = list()
	rating = 5 //self-recharge makes these desirable
	self_recharge = 1 // Infused slime cores self-recharge, over time
	chargerate = 500

/obj/item/stock_parts/cell/emproof
	name = "EMP-proof power cell A"
	desc = "An EMP-proof cell. If you can see this, make an issue report to GitHub."
	maxcharge = 500
	rating = 3

/obj/item/stock_parts/cell/emproof/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)

/obj/item/stock_parts/cell/emproof/empty/Initialize(mapload)
	. = ..()
	charge = 0
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/emproof/corrupt()
	return

/obj/item/stock_parts/cell/emproof/adjust_maxcharge(amount)
	return FALSE


// MARK: Weapon cells
/obj/item/stock_parts/cell/laser
	maxcharge = 1500

/obj/item/stock_parts/cell/laser/gatling
	maxcharge = 9000

/obj/item/stock_parts/cell/laser/tesla_cannon
	maxcharge = STANDARD_CELL_CHARGE * 0.5

/obj/item/stock_parts/cell/secborg
	name = "security borg power cell"
	origin_tech = null
	maxcharge = 600	//600 max charge / 100 charge per shot = six shots
	materials = list(MAT_GLASS = 40)
	rating = 2.5

/obj/item/stock_parts/cell/secborg/empty/Initialize(mapload)
	. = ..()
	charge = 0
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/pulse //265 pulse shots
	name = "pulse rifle power cell"
	maxcharge = 53000
	rating = 3
	chargerate = 1500
	emp_damage_modifier = 0.5

/obj/item/stock_parts/cell/pulse/prise
	chargerate = 0

/obj/item/stock_parts/cell/pulse/carbine //33 pulse shots
	name = "pulse carbine power cell"
	maxcharge = 6600

/obj/item/stock_parts/cell/pulse/pistol //13 pulse shots
	name = "pulse pistol power cell"
	maxcharge = 2600

/obj/item/stock_parts/cell/dominator
	name = "Dominator pistol power cell"
	maxcharge = 3000
	chargerate = 200
	rating = 2

/obj/item/stock_parts/cell/bsg
	name = "B.S.G power cell"
	maxcharge = 40000
	chargerate = 2600 // about 30 seconds to charge with a default recharger

/obj/item/stock_parts/cell/emittergun // 11 emitter shots
	name = "emitter gun power cell"
	maxcharge = 2200

/obj/item/stock_parts/cell/degraded
	name = "power cell A-"
	maxcharge = 750
	chargerate = 25

// MARK: Energy weapon cell
// Basic weapon cell (not as stock parts)
/obj/item/weapon_cell
	name = "energy weapon cell magazine"
	desc = "An energy weapon magazine."
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "Specter_accumulator"
	gender = MALE
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL = 500)
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 10
	pickup_sound = 'sound/items/handling/pickup/ammobox_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/ammobox_drop.ogg'
	var/obj/item/stock_parts/cell/internal_cell = new /obj/item/stock_parts/cell/laser

/obj/item/weapon_cell/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/weapon_cell/proc/is_available_shot(shot_energy_cost)
	return internal_cell.charge >= shot_energy_cost

/obj/item/weapon_cell/get_cell()
	return internal_cell

/obj/item/weapon_cell/examine(mob/user)
	. = ..()
	. += span_notice("<b>Максимальная мощность:</b> [display_power(internal_cell.maxcharge)].")

	if(internal_cell.rigged)
		. += span_notice("Судя по всему, химический элемент был модифицирован.")
	else
		. += span_notice("<b>Индикатор заряда:</b> [round(internal_cell.percent())]%.")


/obj/item/stock_parts/cell/specter
	name = "specter cell"
	desc = "A battery used as a magazine for the Specter pistol."
	maxcharge = 7200
	chargerate = 480

/obj/item/weapon_cell/specter
	name = "specter pistol cell"
	desc = "A battery used as a magazine for the Specter pistol."
	internal_cell = new /obj/item/stock_parts/cell/specter()
	materials = list(MAT_METAL = 35000)

/obj/item/weapon_cell/specter/update_overlays()
	. = list()
	var/charge_percent = internal_cell.percent()

	switch(charge_percent)
		if(1 to 25)
			. += "Specter_overlay_low"
		if(26 to 40)
			. += "Specter_overlay_half2"
		if(41 to 65)
			. += "Specter_overlay_half"
		if(66 to 100)
			. += "Specter_overlay_full"
		else
			. += "Specter_overlay_empty"
