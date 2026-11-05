/obj/item/sensor_device
	name = "handheld crew monitor"
	desc = "A miniature machine that tracks suit sensors across the station."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	item_state = "scanner"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "programming=3;materials=3;magnets=3"
	custom_price = PAYCHECK_CREW
	interaction_flags_mouse_drop = NEED_HANDS
	var/datum/ui_module/crew_monitor/crew_monitor

/obj/item/sensor_device/Initialize(mapload)
	.=..()
	crew_monitor = new(src)

/obj/item/sensor_device/Destroy()
	QDEL_NULL(crew_monitor)
	return ..()

/obj/item/sensor_device/attack_self(mob/user)
	ui_interact(user)

/obj/item/sensor_device/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(user.incapacitated() || !ishuman(user))
		return

	if(over_object != user)
		return

	attack_self(user)

/obj/item/sensor_device/ui_interact(mob/user, datum/tgui/ui = null)
	crew_monitor.ui_interact(user, ui)

/obj/item/sensor_device/advanced

/obj/item/sensor_device/advanced/command
	name = "command crew monitor"
	desc = "A miniature device for tracking station crew sensors. This model is configured for command personnel."
	item_state = "blueshield_monitor"
	icon_state = "c_scanner"

/obj/item/sensor_device/advanced/command/Initialize(mapload)
	. = ..()
	crew_monitor.tab_index = CREW_VISION_COMMAND

/obj/item/sensor_device/advanced/security
	name = "security crew monitor"
	desc = "A miniature device for tracking station crew sensors. This model is configured for security personnel."
	item_state = "brig_monitor"
	icon_state = "s_scanner"

/obj/item/sensor_device/advanced/security/Initialize(mapload)
	. = ..()
	crew_monitor.tab_index = CREW_VISION_SECURITY

/obj/item/sensor_device/advanced/mining
	name = "mining crew monitor"
	desc = "A miniature device for tracking station crew sensors. This model is configured for mining personnel."
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	icon_state = "shaft_scanner"
	item_state = "mining_scanner"

/obj/item/sensor_device/advanced/mining/Initialize(mapload)
	. = ..()
	crew_monitor.tab_index = CREW_VISION_MINING
