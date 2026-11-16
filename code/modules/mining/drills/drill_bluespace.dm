/// Channel name = the [/obj/machinery/bluespace_ore_receiver] listening on it. One receiver per channel.
GLOBAL_LIST_EMPTY(bluespace_ore_receivers)

#define BLUESPACE_CHANNEL_MAX_LENGTH 32

/// Cleans a channel name typed by a player. Returns null if nothing usable is left.
/proc/sanitize_bluespace_ore_channel(raw)
	if(!istext(raw))
		return null
	var/channel = trim(copytext_char(strip_html_simple(raw), 1, BLUESPACE_CHANNEL_MAX_LENGTH + 1))
	return length(channel) ? channel : null

/**
 * # Bluespace Ore Transmitter Module
 *
 * Sends a drill's buffered ore instantly to the receiver on its channel, on any Z-level.
 * Without a receiver the ore stays in the buffer and the drill reports "No receiver".
 * Uses no power beyond the drill's own consumption.
 */
/obj/item/mining_drill_module/transmitter
	name = "bluespace ore transmitter module"
	desc = "An output module for a stationary mining drill. Sends mined ore through bluespace to the ore receiver tuned to the same channel."
	icon_state = "module_transmitter"
	origin_tech = "bluespace=4;programming=4;engineering=4;plasmatech=3"
	/// The channel we send to.
	var/channel

/obj/item/mining_drill_module/transmitter/examine(mob/user)
	. = ..()
	. += span_notice("Channel: [channel ? channel : "not set"].")

/obj/item/mining_drill_module/transmitter/proc/get_receiver()
	if(!channel)
		return null
	var/obj/machinery/bluespace_ore_receiver/receiver = GLOB.bluespace_ore_receivers[channel]
	if(QDELETED(receiver))
		return null
	return receiver

/obj/item/mining_drill_module/transmitter/has_destination(obj/machinery/mining_drill/drill)
	return !!get_receiver()

/obj/item/mining_drill_module/transmitter/process_output(obj/machinery/mining_drill/drill)
	if(!drill.buffer_total())
		return
	var/obj/machinery/bluespace_ore_receiver/receiver = get_receiver()
	if(!receiver)
		return
	for(var/obj/item/stack/ore/ore_type as anything in drill.buffer.Copy())
		var/amount = drill.take_from_buffer(ore_type, drill.buffer[ore_type])
		if(amount > 0)
			receiver.receive_ore(ore_type, amount)

/obj/item/mining_drill_module/transmitter/get_ui_data(obj/machinery/mining_drill/drill)
	return list(
		"kind" = "transmitter",
		"channel" = channel,
		"connected" = !!get_receiver(),
	)

/obj/item/mining_drill_module/transmitter/ui_act_module(action, list/params, obj/machinery/mining_drill/drill, mob/user)
	if(action != "set_channel")
		return FALSE
	var/new_channel = sanitize_bluespace_ore_channel(params["channel"])
	if(!new_channel)
		return FALSE
	channel = new_channel
	drill.update_status()
	return TRUE

/datum/design/mining_drill_transmitter
	name = "Bluespace Ore Transmitter Module"
	desc = "An output module that sends a mining drill's ore to a bluespace ore receiver anywhere."
	id = "mining_drill_transmitter"
	req_tech = list(RESEARCH_TREE_BLUESPACE = 4, RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_PLASMA = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 2000, MAT_SILVER = 2000, MAT_BLUESPACE = 4000)
	build_path = /obj/item/mining_drill_module/transmitter
	category = list(PROTOLATHE_CATEGORY_MINING)

/**
 * # Bluespace Ore Receiver
 *
 * Collects ore sent by transmitter modules on its channel. Holds any amount, like an ore box.
 * Ore comes out only when someone presses the unload button.
 */
/obj/machinery/bluespace_ore_receiver
	name = "bluespace ore receiver"
	desc = "A bluespace-linked steel crate that catches ore sent by mining drills on its channel and holds any amount of it."
	icon = 'icons/obj/mining_drills.dmi'
	icon_state = "bs_receiver"
	base_icon_state = "bs_receiver"
	density = TRUE
	anchored = TRUE
	max_integrity = 300
	integrity_failure = 0
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 10, BOMB = 20, BIO = 0, FIRE = 60, ACID = 60)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	use_power = NO_POWER_USE
	interaction_flags_click = ALLOW_SILICON_REACH
	/// The channel we listen on.
	var/channel

/obj/machinery/bluespace_ore_receiver/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/bluespace_ore_receiver(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal(null, 1)
	RefreshParts()

/obj/machinery/bluespace_ore_receiver/Destroy()
	release_channel()
	return ..()

/// Tunes to `new_channel`. Returns FALSE if another receiver already uses it.
/obj/machinery/bluespace_ore_receiver/proc/set_channel(new_channel)
	var/obj/machinery/bluespace_ore_receiver/owner = GLOB.bluespace_ore_receivers[new_channel]
	if(owner && owner != src && !QDELETED(owner))
		return FALSE
	release_channel()
	channel = new_channel
	GLOB.bluespace_ore_receivers[channel] = src
	update_icon()
	return TRUE

/obj/machinery/bluespace_ore_receiver/proc/release_channel()
	if(channel && GLOB.bluespace_ore_receivers[channel] == src)
		GLOB.bluespace_ore_receivers -= channel
	channel = null
	update_icon()

/obj/machinery/bluespace_ore_receiver/proc/receive_ore(obj/item/stack/ore/ore_type, amount)
	new ore_type(src, amount)
	flick("[base_icon_state]_receive", src)

/obj/machinery/bluespace_ore_receiver/proc/stored_ore()
	. = list()
	for(var/obj/item/stack/ore/ore in contents)
		.[ore.type] += ore.amount

/obj/machinery/bluespace_ore_receiver/proc/unload(atom/target)
	for(var/obj/item/stack/ore/ore in contents)
		ore.forceMove(target)

/obj/machinery/bluespace_ore_receiver/on_deconstruction()
	unload(drop_location())

/obj/machinery/bluespace_ore_receiver/examine(mob/user)
	. = ..()
	. += span_notice("Channel: [channel ? channel : "not set"].")

/obj/machinery/bluespace_ore_receiver/update_icon_state()
	icon_state = "[base_icon_state][channel ? "_on" : ""]"

/obj/machinery/bluespace_ore_receiver/update_overlays()
	. = ..()
	if(panel_open)
		. += "[base_icon_state]_panel"

/obj/machinery/bluespace_ore_receiver/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)
	return TRUE

/obj/machinery/bluespace_ore_receiver/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/bluespace_ore_receiver/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(!tool.use_tool(src, user, 0, volume = tool.tool_volume))
		return
	panel_open = !panel_open
	to_chat(user, span_notice("You [panel_open ? "open" : "close"] the maintenance panel of [src]."))
	update_icon()

/obj/machinery/bluespace_ore_receiver/crowbar_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return FALSE
	. = TRUE
	default_deconstruction_crowbar(user, tool)

/obj/machinery/bluespace_ore_receiver/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_unfasten_wrench(user, tool)

/obj/machinery/bluespace_ore_receiver/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BluespaceOreReceiver", name)
		ui.open()

/obj/machinery/bluespace_ore_receiver/ui_data(mob/user)
	var/list/data = list()
	data["channel"] = channel
	var/list/ore_list = list()
	var/total = 0
	var/list/stored = stored_ore()
	for(var/obj/item/stack/ore/ore_type as anything in stored)
		ore_list += list(list("name" = initial(ore_type.name), "amount" = stored[ore_type]))
		total += stored[ore_type]
	data["ore"] = ore_list
	data["total"] = total
	return data

/obj/machinery/bluespace_ore_receiver/ui_act(action, list/params)
	if(..())
		return
	var/mob/user = usr
	switch(action)
		if("set_channel")
			var/new_channel = sanitize_bluespace_ore_channel(params["channel"])
			if(!new_channel || new_channel == channel)
				return FALSE
			if(!set_channel(new_channel))
				to_chat(user, span_warning("Channel already in use"))
				return FALSE
			return TRUE
		if("clear_channel")
			release_channel()
			return TRUE
		if("unload")
			unload(drop_location())
			return TRUE

/obj/item/circuitboard/bluespace_ore_receiver
	board_name = "Bluespace Ore Receiver"
	build_path = /obj/machinery/bluespace_ore_receiver
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	origin_tech = "bluespace=4;programming=4;engineering=4;plasmatech=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/ore/bluespace_crystal = 1,
	)

/datum/design/bluespace_ore_receiver
	name = "Machine Board (Bluespace Ore Receiver)"
	desc = "The circuit board for a bluespace ore receiver."
	id = "bluespace_ore_receiver"
	req_tech = list(RESEARCH_TREE_BLUESPACE = 4, RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_PLASMA = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/bluespace_ore_receiver
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

#undef BLUESPACE_CHANNEL_MAX_LENGTH
