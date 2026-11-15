/**
 * # Ore deposit
 *
 * A seam of a single ore type spread over 2-5 connected asteroid tiles.
 * Deposits are only created by [/datum/ore_deposit_generator] at round start.
 * Stationary mining drills extract ore from them one unit at a time.
 * A depleted deposit disappears together with all of its tiles.
 */
GLOBAL_LIST_EMPTY(ore_deposits)

/datum/ore_deposit
	/// Shown on examine and in drill interfaces.
	var/name = "ore deposit"
	/// Key used for sprites: deposit_<ore_id>_<variant> and deposit_scan_<ore_id>.
	var/ore_id
	/// The ore stack produced, one unit of amount per extracted piece.
	var/obj/item/stack/ore/ore_type
	/// Ore left in the deposit.
	var/amount = 0
	/// Ore the deposit started with.
	var/initial_amount = 0
	/// The visible markers of this deposit, one per tile.
	var/list/obj/effect/ore_deposit_tile/tiles = list()
	/// The drill installed on this deposit. One deposit supports one drill.
	var/datum/weakref/drill_ref

/datum/ore_deposit/New(ore_id, ore_type, name, amount, list/turf/locations)
	. = ..()
	src.ore_id = ore_id
	src.ore_type = ore_type
	src.name = name
	src.amount = amount
	initial_amount = amount
	for(var/turf/location as anything in locations)
		tiles += new /obj/effect/ore_deposit_tile(location, src)
	for(var/obj/effect/ore_deposit_tile/tile as anything in tiles)
		tile.update_joins()
	GLOB.ore_deposits += src

/datum/ore_deposit/Destroy(force)
	GLOB.ore_deposits -= src
	var/list/old_tiles = tiles
	tiles = list()
	for(var/obj/effect/ore_deposit_tile/tile as anything in old_tiles)
		tile.deposit = null
		qdel(tile)
	drill_ref = null
	return ..()

/// Returns the drill installed on this deposit, if any.
/datum/ore_deposit/proc/get_drill()
	return drill_ref?.resolve()

/// Takes up to `requested` units of ore. Returns how many were actually taken.
/// The deposit deletes itself once it is empty.
/datum/ore_deposit/proc/extract(requested = 1)
	. = clamp(requested, 0, amount)
	amount -= .
	if(amount <= 0)
		qdel(src)

/// Every turf this deposit lies on.
/datum/ore_deposit/proc/get_turfs()
	. = list()
	for(var/obj/effect/ore_deposit_tile/tile as anything in tiles)
		. += tile.loc

/**
 * One tile of an [/datum/ore_deposit].
 *
 * Lies under the rock and stays hidden until the rock above is dug out.
 * Mining scanners reveal hidden tiles briefly, like ore in the walls.
 */
/obj/effect/ore_deposit_tile
	name = "ore deposit"
	desc = "A rich seam of ore running deep into the asteroid. A mining drill could work it for a long time."
	icon = 'icons/obj/mining_drills.dmi'
	icon_state = "deposit_iron_0_1"
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	density = FALSE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// The deposit we belong to.
	var/datum/ore_deposit/deposit
	/// Which of the sprite variants this tile uses.
	var/variant = 1
	/// Cardinal directions joined to tiles of the same deposit.
	var/joins = NONE

/obj/effect/ore_deposit_tile/Initialize(mapload, datum/ore_deposit/new_deposit)
	. = ..()
	if(!istype(new_deposit) || !isturf(loc))
		return INITIALIZE_HINT_QDEL
	deposit = new_deposit
	name = deposit.name
	variant = rand(1, 2)
	update_joins()
	// Turfs keep their signal registrations through ChangeTurf, so this follows the rock being dug.
	RegisterSignal(loc, COMSIG_TURF_CHANGE, PROC_REF(on_turf_change))
	update_cover()

/obj/effect/ore_deposit_tile/Destroy(force)
	if(isturf(loc))
		UnregisterSignal(loc, COMSIG_TURF_CHANGE)
	if(deposit)
		deposit.tiles -= src
		deposit = null
	return ..()

/obj/effect/ore_deposit_tile/proc/on_turf_change(turf/source, path, list/post_change_callbacks)
	SIGNAL_HANDLER
	post_change_callbacks += CALLBACK(src, PROC_REF(update_cover))

/// Hidden while rock covers us, visible once the tile is open.
/obj/effect/ore_deposit_tile/proc/update_cover()
	if(QDELETED(src))
		return
	if(is_covered())
		invisibility = INVISIBILITY_ABSTRACT
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	else
		invisibility = 0
		mouse_opacity = MOUSE_OPACITY_ICON

/obj/effect/ore_deposit_tile/proc/is_covered()
	return ismineralturf(loc)

/// Picks the sprite that merges with the neighbouring tiles of the same deposit.
/obj/effect/ore_deposit_tile/proc/update_joins()
	joins = NONE
	for(var/direction in GLOB.cardinal)
		for(var/obj/effect/ore_deposit_tile/neighbour in get_step(src, direction))
			if(neighbour.deposit == deposit)
				joins |= direction
				break
	icon_state = "deposit_[deposit.ore_id]_[joins]_[variant]"

// Deposits are part of the asteroid itself: nothing but extraction removes them.
/obj/effect/ore_deposit_tile/ex_act(severity, target)
	return

/obj/effect/ore_deposit_tile/singularity_act()
	return

/obj/effect/ore_deposit_tile/singularity_pull(atom/singularity, current_size)
	return

/**
 * Briefly shows the hidden deposit tiles around `center` on the rock above them.
 *
 * Drawn as an overlay of the rock turf itself, exactly like the ore highlights:
 * BYOND hides objects inside rock that is not in direct view, but meson vision
 * (SEE_TURFS) shows turfs and their overlays deep inside the rock.
 * The layer sits above the neighbouring oversized rock sprites so they do not cover it.
 */
/proc/ore_deposit_scan_pulse(turf/center, range = world.view)
	for(var/obj/effect/ore_deposit_tile/tile in range(range, center))
		if(!tile.deposit || !tile.is_covered())
			continue
		var/turf/rock = tile.loc
		var/image/deposit_overlay = image('icons/obj/mining_drills.dmi', icon_state = "deposit_scan_[tile.deposit.ore_id]_[tile.joins]", layer = ON_EDGED_TURF_LAYER)
		rock.add_overlay(deposit_overlay)
		addtimer(CALLBACK(rock, TYPE_PROC_REF(/atom, cut_overlay), deposit_overlay), 3.5 SECONDS)
