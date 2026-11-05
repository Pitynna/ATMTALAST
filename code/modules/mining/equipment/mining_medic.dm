/*
Almost every mining medic related stuff
*/

/obj/machinery/camera/portable/no_ai

/obj/machinery/camera/portable/no_ai/can_AI_see(ai)
	return FALSE

/obj/item/clothing/accessory/camera
	name = "mining camera"
	desc = "A small body camera with a large sensor that reads suit sensor data from the main station. Can stream to a mining medic's tablet and the station entertainment network."
	gender = FEMALE
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	icon_state = "mining_camera"
	item_state = "mining_camera"
	allow_duplicates = FALSE
	slot = ACCESSORY_SLOT_UTILITY
	actions_types = list(/datum/action/item_action/accessory/mining_camera)

	/// Is our camera on
	var/on = FALSE
	/// Our portable camera
	var/obj/machinery/camera/portable/no_ai/camera
	/// Can we see camera from intertainment network?
	var/news_feed = FALSE
	/// Main feed network
	var/feed = "mining"
	/// Can detect multiz sensors
	var/multiz = TRUE

/obj/item/clothing/accessory/camera/Destroy()
	if(camera) // null until we activate
		GLOB.active_entertainment_cameras -= camera
		camera.c_tag = null
		QDEL_NULL(camera)

	return ..()

/obj/item/clothing/accessory/camera/examine(mob/user)
	. = ..()
	. += span_notice("Камера <b>[on ? "в" : "вы"]ключена</b>.")
	. += span_notice("Ретрансляция на станцию <b>[news_feed ? "в" : "вы"]ключена</b>. Используйте <b>Alt+ЛКМ</b>, чтобы переключить режим трансляции камеры в развлекательную сеть.")

/obj/item/clothing/accessory/camera/add_eatable_component()
	return

/obj/item/clothing/accessory/camera/attack_self(mob/user)
	. = ..()
	update_camera_state(user)

/obj/item/clothing/accessory/camera/on_attached(obj/item/clothing/under/new_suit, mob/attacher)
	. = ..()
	if(. && isliving(has_suit.loc) && multiz)
		var/mob/living/wearer = has_suit.loc
		ADD_TRAIT(wearer, TRAIT_MULTIZ_SUIT_SENSORS, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/accessory/camera/on_removed(mob/detacher)
	. = ..()
	if(.)
		var/obj/item/clothing/under/old_suit = .
		if(isliving(old_suit.loc) && multiz)
			var/mob/living/wearer = old_suit.loc
			REMOVE_TRAIT(wearer, TRAIT_MULTIZ_SUIT_SENSORS, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/accessory/camera/attached_equip(mob/living/user)
	if(isliving(user) && multiz)
		ADD_TRAIT(user, TRAIT_MULTIZ_SUIT_SENSORS, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/accessory/camera/attached_unequip(mob/living/user)
	if(isliving(user) && multiz)
		REMOVE_TRAIT(user, TRAIT_MULTIZ_SUIT_SENSORS, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/accessory/camera/proc/update_camera_state(mob/living/carbon/user, force = FALSE)
	if(on)
		if(news_feed)
			GLOB.active_entertainment_cameras -= camera
		camera.c_tag = null
		QDEL_NULL(camera)
	else
		if(news_feed)
			camera = new(src, list(feed, "news"), user.name)
			GLOB.active_entertainment_cameras |= camera
		else
			camera = new(src, list(feed), user.name)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	if(!force)
		balloon_alert(user, "камера [on ? "в" : "вы"]ключена")

	for(var/obj/machinery/computer/security/telescreen/entertainment/TV in SSmachines.get_by_type(/obj/machinery/computer/security/telescreen/entertainment))
		TV.update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/accessory/camera/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][on ? "_on" : ""]"

/obj/item/clothing/accessory/camera/click_alt(mob/user)
	if(on)
		balloon_alert(user, "сначала выключите камеру!")
		return CLICK_ACTION_BLOCKING
	news_feed = !news_feed
	balloon_alert(user, "ретрансляция [news_feed ? "в" : "вы"]ключена")
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/accessory/camera/emp_act(severity)
	. = ..()
	if(on)
		update_camera_state(force = TRUE)

/obj/item/clothing/accessory/camera/security
	name = "security camera"
	desc = "Used by security teams and annoying AIs to watch over you."
	icon_state = "sec_camera"
	item_state = "sec_camera"
	slot = ACCESSORY_SLOT_DECOR //No one will remove their holster for a camera
	feed = "secfeed"

/obj/item/storage/box/mining_cameras
	name = "mining camera box"
	desc = "A small box for storing mining cameras."
	icon_state = "mining_camera_box"
	storage_slots =  12
	max_combined_w_class = INFINITY
	can_hold = list(
		/obj/item/clothing/accessory/camera,
	)

/obj/item/storage/box/mining_cameras/populate_contents()
	for(var/i in 1 to 12)
		new /obj/item/clothing/accessory/camera(src)

/obj/item/storage/box/sec_cameras
	name = "mining camera box"
	desc = "A small box for storing security body cameras."
	icon_state = "security_camera_box"

/obj/item/storage/box/sec_cameras/populate_contents()
	for(var/i in 1 to 12)
		new /obj/item/clothing/accessory/camera/security(src)

/obj/item/camera_bug/mining
	name = "mining camera monitor"
	desc = "A small device receiving data from mining cameras. Lets you watch miners struggle for survival across Lazis."
	icon_state = "mining_monitor"
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	item_state = "mining_monitor"
	origin_tech = "engineering=3"

/obj/item/camera_bug/mining/Initialize(mapload)
	. = ..()
	integrated_console.network = list("mining")

/obj/item/camera_bug/security
	name = "security camera monitor"
	desc = "An old TV hooked into the station's camera network."
	icon_state = "sec_monitor"
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	item_state = "sec_monitor"
	origin_tech = "engineering=3"

/obj/item/camera_bug/security/Initialize(mapload)
	. = ..()
	integrated_console.network = list("secfeed")
	integrated_console.affected_by_blackout = TRUE
