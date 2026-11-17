// Ruins of the mining asteroid, see code/datums/ruins/asteroid.dm
/area/ruin/asteroid
	name = "Asteroid Ruin"
	icon_state = "away"
	always_unpowered = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	ambience_index = AMBIENCE_MINING
	sound_environment = SOUND_AREA_ASTEROID

/area/ruin/asteroid/saddam_hideout
	name = "Hideout"
	icon_state = "red"

/// The little cave in front of the sealed wall. Airless like the rest of the rock.
/area/ruin/asteroid/saddam_hideout/approach
	name = "Hideout Approach"
	icon_state = "explored"
	outdoors = TRUE

/area/ruin/asteroid/schizo_room
	name = "Studio"
	icon_state = "purple"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
