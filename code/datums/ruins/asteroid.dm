// Ruins buried in the rock of the mining asteroid.
// They are seeded by loadMiningAsteroid() before the caves are carved, so tunnels never cut into them:
// the tunnel generator only digs through /area/mine/unexplored and keeps two tiles away from anything else.

/datum/map_template/ruin/asteroid
	abstract_type = /datum/map_template/ruin/asteroid
	prefix = "_maps/map_files/RandomRuins/AsteroidRuins/"
	cost = 1
	allow_duplicates = FALSE

/// Asteroid ruins are dug out by miners, so they only go where there is solid rock to hide them.
/datum/map_template/ruin/asteroid/can_place_on(turf/check)
	return ismineralturf(check)

/datum/map_template/ruin/asteroid/saddam_hideout
	id = "asteroid-saddam-hideout"
	suffix = "saddam_hideout.dmm"
	name = "Saddam's Hideout"
	description = "An indestructible bunker sealed from the inside. A red rune in front of the wall wants a life for the passage. 		Whoever lies in the hole behind it has a fan, a briefcase and plenty of time."

/datum/map_template/ruin/asteroid/schizo_room
	id = "asteroid-schizo-room"
	suffix = "schizo_room.dmm"
	name = "Schizo Room"
	description = "A tiny studio lost in the rock. Two men at a big table are still on air, 		and the poster on the table had better stay rolled up."
