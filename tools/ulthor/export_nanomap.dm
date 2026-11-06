/// Export initialized Ulthor appearances for the camera console nanomap.
/datum/unit_test/ulthor_nanomap_export/Run()
	if(!istype(SSmapping.map_datum, /datum/map/ulthor))
		return
	var/station_z = level_name_to_num(MAIN_STATION)
	TEST_ASSERT(station_z, "The station level must be loaded before capture")
	var/list/appearance_ids = list()
	var/list/placements = list()
	var/list/sprites = list()
	var/next_id = 0
	for(var/turf/tile as anything in Z_TURFS(station_z))
		var/list/tile_atoms = list(tile)
		for(var/atom/movable/thing in tile)
			if(thing.invisibility || is_light(thing) || !thing.icon)
				continue
			tile_atoms += thing
		for(var/atom/thing as anything in tile_atoms)
			if(!thing.icon || thing.alpha <= 0)
				continue
			var/appearance_key = thing.appearance
			var/sprite_id = appearance_ids[appearance_key]
			if(!sprite_id)
				next_id++
				sprite_id = next_id
				appearance_ids[appearance_key] = sprite_id
				ulthor_mapshot_prime_icons(thing)
				var/image/capture_appearance
				if(iswallturf(thing))
					capture_appearance = ulthor_mapshot_wall_appearance(thing)
				var/icon/flat = getFlatIcon(capture_appearance ? capture_appearance : thing, no_anim = TRUE)
				if(!flat)
					continue
				var/path = "data/ulthor_mapshot/sprites/[sprite_id].png"
				fcopy(flat, path)
				sprites += list(list("id" = sprite_id, "path" = path, "width" = flat.Width(), "height" = flat.Height()))
			var/offset_x = thing.pixel_x + thing.pixel_w
			var/offset_y = thing.pixel_y + thing.pixel_z
			if(ismovable(thing))
				var/atom/movable/movable = thing
				offset_x += movable.step_x
				offset_y += movable.step_y
			var/datum/decompose_matrix/transform = thing.transform ? thing.transform.decompose() : new
			placements += list(list(
				"sprite" = sprite_id,
				"x" = thing.x, "y" = thing.y,
				"pixel_x" = offset_x, "pixel_y" = offset_y,
				"plane" = thing.plane, "layer" = thing.layer,
				"blend" = thing.blend_mode,
				"scale_x" = transform.scale_x, "scale_y" = transform.scale_y,
				"rotation" = transform.rotation,
				"shift_x" = transform.shift_x, "shift_y" = transform.shift_y,
			))
		CHECK_TICK
		if(tile.x == world.maxx && tile.y % 32 == 0)
			log_world("MAPSHOT: captured through row [tile.y], [next_id] unique appearances")
	text2file(json_encode(list("width" = world.maxx, "height" = world.maxy, "z" = station_z, "sprites" = sprites, "placements" = placements)), "data/ulthor_mapshot/snapshot.json")
	log_world("MAPSHOT: exported [length(placements)] placements and [next_id] sprites from station Z=[station_z]")

/// Compiled generated icons may exist in BYOND's RSC without a corresponding file
/// on disk. Use BYOND's own icon state reader for this temporary capture.
/proc/ulthor_mapshot_prime_icons(image/appearance)
	if(!appearance)
		return
	if(appearance.icon && !length(GLOB.icon_states_cache_lookup[appearance.icon]))
		var/list/states = icon_states(appearance.icon)
		GLOB.icon_states_cache[appearance.icon] = states
		GLOB.icon_states_cache_lookup[appearance.icon] = list()
		for(var/state in states)
			GLOB.icon_states_cache_lookup[appearance.icon][state] = TRUE
	for(var/image/overlay as anything in appearance.overlays)
		ulthor_mapshot_prime_icons(overlay)
	for(var/image/underlay as anything in appearance.underlays)
		ulthor_mapshot_prime_icons(underlay)

/// Smoothed walls draw their visible faces on GAME_PLANE and their light-mask
/// base on WALL_PLANE. The ordinary flat-icon helper omits the visible faces.
/proc/ulthor_mapshot_wall_appearance(atom/source)
	var/image/copy = image('icons/blanks/32x32.dmi')
	copy.appearance = source.appearance
	copy.plane = FLOAT_PLANE
	copy.overlays = null
	copy.underlays = null
	for(var/image/overlay as anything in source.overlays)
		if(!overlay || !(overlay.plane in list(FLOAT_PLANE, GAME_PLANE, WALL_PLANE, FLOOR_PLANE)))
			continue
		copy.overlays += ulthor_mapshot_wall_appearance(overlay)
	for(var/image/underlay as anything in source.underlays)
		if(!underlay || !(underlay.plane in list(FLOAT_PLANE, GAME_PLANE, WALL_PLANE, FLOOR_PLANE)))
			continue
		copy.underlays += ulthor_mapshot_wall_appearance(underlay)
	return copy

/datum/unit_test/ulthor_nanomap_export
	priority = TEST_LONGER
