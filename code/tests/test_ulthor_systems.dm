/// Real control dispatch, camera frames and radio delivery on the migrated map.
#ifndef ULTHOR_CAMERAS_ONLY
/datum/unit_test/ulthor_door_controls/Run()
	if(!istype(SSmapping.map_datum, /datum/map/ulthor))
		return
	var/mob/living/carbon/human/tester = allocate(/mob/living/carbon/human)
	var/obj/item/card/id/card = allocate(/obj/item/card/id, tester)
	card.access = get_all_accesses() | get_all_centcom_access()
	tester.wear_id = card
	var/tested = 0
	for(var/obj/machinery/door_control/button in world)
		if(!is_ulthor_mapped_fixture(button))
			continue
		var/list/targets = list()
		for(var/obj/machinery/door/door in GLOB.airlocks)
			if(door.z != button.z)
				continue
			if(button.normaldoorcontrol ? istype(door, /obj/machinery/door/airlock) : istype(door, /obj/machinery/door/poddoor))
				if(door:id_tag in button.get_ids())
					targets += door
		TEST_ASSERT(length(targets), "Button [button.name] at [button.x]:[button.y] must have a door target")
		TEST_ASSERT(button.safety_z_check, "Mapped buttons must not control another Z-level")
		TEST_ASSERT(button.powered() && !(button.stat & (NOPOWER|BROKEN)), "Button [button.name] must have working power")
		TEST_ASSERT(button.allowed(tester), "The maintenance test ID must operate [button.name]")
		var/list/states = list()
		for(var/obj/machinery/door/door as anything in targets)
			states[door] = list(door.density, door.locked, door.autoclose)
			door.autoclose = FALSE
		if(!button.device)
			button.build_device()
		var/obj/item/assembly/control/control = button.device
		var/old_desired = button.desiredstate
		if(istype(control, /obj/item/assembly/control/airlock))
			var/obj/item/assembly/control/airlock/airlock_control = control
			old_desired = airlock_control.desiredstate
		button.attack_hand(tester)
		sleep(1.2 SECONDS)
		for(var/obj/machinery/door/door as anything in targets)
			var/list/state = states[door]
			if(button.normaldoorcontrol && (button.specialfunctions & BOLTS))
				TEST_ASSERT_EQUAL(door.locked, old_desired, "[button.name] must change the actual door bolts")
			else
				TEST_ASSERT_NOTEQUAL(door.density, state[1], "[button.name] must move its door at [door.x]:[door.y]")
			if(state[2])
				door.lock()
			else
				door.unlock()
			if(state[1])
				INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, close))
			else
				INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, open))
			door.autoclose = state[3]
		sleep(1.2 SECONDS)
		tested++
		if(tested % 8 == 0)
			log_world("ULTHOR SYSTEMS: tested [tested] door controls")
	TEST_ASSERT(tested, "Ulthor door controls must be present")
	log_world("ULTHOR SYSTEMS: [tested] door buttons dispatched to real doors")

#endif

/datum/unit_test/ulthor_cameras/Run()
	if(!istype(SSmapping.map_datum, /datum/map/ulthor))
		return
	var/datum/asset/simple/nanomaps/map_assets = get_asset_datum(/datum/asset/simple/nanomaps)
	TEST_ASSERT(map_assets.assets["Ulthor_nanomap_z1.png"], "Camera consoles must receive the Ulthor map asset")
	var/list/tags = list()
	var/list/cameras = list()
	for(var/obj/machinery/camera/camera in GLOB.cameranet.cameras)
		if(!is_ulthor_mapped_fixture(camera))
			continue
		TEST_ASSERT(camera.c_tag && !tags[camera.c_tag], "Camera names must be nonempty and unique: [camera.c_tag]")
		tags[camera.c_tag] = TRUE
		TEST_ASSERT(camera.can_use(), "[camera.c_tag] must start operational")
		TEST_ASSERT(camera.powered(), "[camera.c_tag] must have area power")
		var/area/zone = get_area(camera)
		TEST_ASSERT_EQUAL(camera.myArea, zone, "Camera [camera.c_tag] must use its real room")
		TEST_ASSERT(camera.UID() in zone.cameras, "Camera [camera.c_tag] must register in the room camera list")
		TEST_ASSERT(length(camera.camera_see()), "Camera [camera.c_tag] must see actual map contents")
		cameras += camera
	var/consoles = 0
	var/frames = 0
	var/list/published = list()
	for(var/obj/machinery/computer/security/console in world)
		if(!is_ulthor_mapped_fixture(console))
			continue
		TEST_ASSERT(console.powered(), "Camera console at [console.x]:[console.y] must have power")
		var/list/data = console.ui_data()
		// Engineering monitors intentionally list alarm cameras, not normal CCTV.
		if(istype(console, /obj/machinery/computer/security/engineering))
			var/obj/machinery/camera/alarm_camera = locate() in locate(123,175,level_name_to_num(MAIN_STATION))
			var/area/alarm_area = get_area(alarm_camera)
			var/was_on_fire = alarm_area.fire
			alarm_area.firealert(console)
			data = console.ui_data()
			var/found_alarm_camera = FALSE
			for(var/list/alarm_entry in data["cameras"])
				if(alarm_entry["ref"] == alarm_camera.UID())
					found_alarm_camera = TRUE
			if(!was_on_fire)
				alarm_area.firereset(console)
			TEST_ASSERT(found_alarm_camera, "Engineering monitor must show cameras from the actual alarm area")
			TEST_ASSERT(was_on_fire || !("Fire Alarms" in alarm_camera.network), "Resetting the alarm must clear the temporary camera network")
		// Entertainment screens wait for a player-operated broadcast camera.
		if(istype(console, /obj/machinery/computer/security/telescreen/entertainment) && !length(data["cameras"]))
			continue
		TEST_ASSERT(length(data["cameras"]), "Console [console.name] at [console.x]:[console.y] must offer cameras on its real network")
		var/obj/machinery/camera/old_camera = console.active_camera
		for(var/list/entry in data["cameras"])
			var/obj/machinery/camera/camera = locateUID(entry["ref"])
			if(!(camera in cameras))
				continue
			published[camera] = TRUE
			console.active_camera = camera
			console.last_camera_turf = null
			console.update_active_camera_screen()
			TEST_ASSERT(length(console.cam_screen.vis_contents), "Console must draw [camera.c_tag]'s visible turfs")
			frames++
			if(frames == 1)
				camera.toggle_cam(null, FALSE)
				console.update_active_camera_screen()
				var/showed_static = !length(console.cam_screen.vis_contents)
				camera.toggle_cam(null, FALSE)
				console.update_active_camera_screen()
				TEST_ASSERT(showed_static, "Disabling a camera must replace its frame with static")
				TEST_ASSERT(length(console.cam_screen.vis_contents), "Re-enabling the same camera must restore its image without switching away")
		console.active_camera = old_camera
		console.last_camera_turf = null
		console.update_active_camera_screen()
		consoles++
	for(var/obj/machinery/camera/camera as anything in cameras)
		TEST_ASSERT(published[camera], "[camera.c_tag] must be reachable from at least one mapped console")
	var/station_z = level_name_to_num(MAIN_STATION)
	for(var/list/anchor in list(list(76,160,/area/station/service/ulthor_82_155), list(84,142,/area/station/service/ulthor_80_150), list(123,175,/area/station/medical/ulthor_124_179), list(166,145,/area/station/engineering/atmos)))
		TEST_ASSERT(istype(get_area(locate(anchor[1],anchor[2],station_z)), anchor[3]), "Camera room at [anchor[1]]:[anchor[2]] must match its department")
	log_world("ULTHOR SYSTEMS: [length(cameras)] cameras, [consoles] consoles, [frames] actual frames")

#ifndef ULTHOR_CAMERAS_ONLY
/mob/living/carbon/human/ulthor_radio_probe
	var/list/received = list()

/mob/living/carbon/human/ulthor_radio_probe/hear_radio(list/message_pieces, verb, part_a, part_b, atom/movable/speaker, hard_to_hear, vname, atom/follow_target, check_name_against)
	for(var/datum/multilingual_say_piece/piece in message_pieces)
		received += piece.message

/datum/unit_test/ulthor_telecomms/Run()
	if(!istype(SSmapping.map_datum, /datum/map/ulthor))
		return
	var/station_z = level_name_to_num(MAIN_STATION)
	var/mining_z = level_name_to_num(MINING)
	var/obj/machinery/tcomms/core/core = locate() in locate(144,148,station_z)
	TEST_ASSERT_NOTNULL(core, "The station telecommunications core must load")
	TEST_ASSERT(core.active && core.powered() && !(core.stat & NOPOWER), "Telecommunications must start enabled and powered")
	TEST_ASSERT(core.zlevel_reachable(station_z) && core.zlevel_reachable(mining_z), "Core and relay must connect station and mining")
	var/mob/living/carbon/human/ulthor_radio_probe/station_listener = allocate(/mob/living/carbon/human/ulthor_radio_probe, locate(124,163,station_z))
	var/mob/living/carbon/human/ulthor_radio_probe/mining_listener = allocate(/mob/living/carbon/human/ulthor_radio_probe, locate(178,204,mining_z))
	station_listener.become_hearing_sensitive("ulthor_test")
	mining_listener.become_hearing_sensitive("ulthor_test")
	var/obj/item/radio/station_radio = allocate(/obj/item/radio, station_listener)
	var/obj/item/radio/mining_radio = allocate(/obj/item/radio, mining_listener)
	sleep(1)
	for(var/source_z in list(station_z,mining_z))
		var/datum/tcomms_message/message = new()
		message.source_level = source_z
		message.freq = PUB_FREQ
		message.connection = SSradio.return_frequency(PUB_FREQ)
		message.message_pieces = message_to_multilingual("Ulthor radio test [source_z]")
		message.sender_name = "Ulthor diagnostic"
		TEST_ASSERT(core.handle_message(message), "The live core must route the message")
		TEST_ASSERT(length(station_listener.received) && length(mining_listener.received), "Both radios must deliver the message to their listeners")
		station_listener.received.Cut()
		mining_listener.received.Cut()
		qdel(message)
	var/datum/tcomms_message/offline_message = new()
	offline_message.source_level = station_z
	offline_message.freq = PUB_FREQ
	offline_message.connection = SSradio.return_frequency(PUB_FREQ)
	offline_message.message_pieces = message_to_multilingual("Must not be delivered")
	core.active = FALSE
	var/blocked = !core.handle_message(offline_message)
	core.active = TRUE
	TEST_ASSERT(blocked && !length(station_listener.received) && !length(mining_listener.received), "An offline core must stop delivery")
	qdel(offline_message)
	TEST_ASSERT(station_radio.receive_range(PUB_FREQ,list(station_z)) >= 0 && mining_radio.receive_range(PUB_FREQ,list(mining_z)) >= 0, "Both radio receivers must function")
	for(var/obj/machinery/r_n_d/server/server in world)
		if(is_station_level(server.z))
			TEST_ASSERT(server.powered() && !(server.stat & (NOPOWER|BROKEN)), "R&D server at [server.x]:[server.y] must be powered")
			TEST_ASSERT(server.health > 0 && server.files, "The server research database must be healthy and initialized")
	log_world("ULTHOR SYSTEMS: radio delivered station to mining and mining to station; offline core blocked delivery")

#endif

/proc/is_ulthor_mapped_fixture(atom/thing)
	var/area/zone = get_area(thing)
	return is_station_level(thing.z) || findtext("[zone.type]", "/area/shuttle/ulthor_")
