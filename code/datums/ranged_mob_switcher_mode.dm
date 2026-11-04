/**
 * Datum used in datum/element/ranged_mob_switcher
 *
 * Stores everything ranged related a simple hostile mob can have, plus extras for the element
 */
/datum/ranged_mob_switcher_mode
	/// Name of the mode
	var/name = "Какой-то выстрел"
	/// Cooldown of projectiles in this mode
	var/cooldown = 1 SECONDS
	/// Amount of projectiles in this mode
	var/amount = 1
	/// Rapid fire delay in this mode
	var/rapid_fire_delay
	/// Rapid fire spread
	var/rapid_fire_spread
	/// Type of projectile in this mode
	var/proj_type
	/// Sound of shooting projectiles in this mode
	var/sound
	/// Icon file used for radial menu
	var/icon
	/// Icon state used for radial menu
	var/icon_state

// MARK: Combat swarmer modes
