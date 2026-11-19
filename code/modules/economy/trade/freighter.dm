// Trade freighter: brings traders' goods to the trade bay and takes consigned crates away.

#define FREIGHTER_AWAY "away"
#define FREIGHTER_INBOUND "inbound"
#define FREIGHTER_DOCKED "docked"
#define FREIGHTER_OUTBOUND "outbound"

/// How long the freighter waits at the station.
#define FREIGHTER_STAY (5 MINUTES)

/area/shuttle/trade_freighter
	name = "Trade Freighter"
	icon_state = "shuttle3"

/obj/docking_port/mobile/trade_freighter
	name = "trade freighter"
	id = TRADE_FREIGHTER_ID
	callTime = 1 MINUTES
	dir = 8
	width = 6
	dwidth = 4
	height = 8

/obj/machinery/door/airlock/external/trade_bay
	name = "Trade Bay Hatch"
	id_tag = TRADE_FREIGHTER_HOME
	req_access = list(ACCESS_CARGO)

/obj/machinery/door/airlock/external/trade_freighter
	name = "Freighter Hatch"
	id_tag = "s_docking_airlock"

/datum/controller/subsystem/trade
	var/freighter_state = FREIGHTER_AWAY
	/// When the docked freighter leaves.
	var/freighter_departure = 0
	var/obj/docking_port/mobile/trade_freighter/freighter

/// The freighter flies only on maps with a trade bay.
/datum/controller/subsystem/trade/proc/freighter_available()
	if(!freighter)
		freighter = SSshuttle.getShuttle(TRADE_FREIGHTER_ID)
		if(freighter)
			RegisterSignal(freighter, COMSIG_SHUTTLE_DOCK, PROC_REF(on_freighter_dock))
	return freighter && SSshuttle.getDock(TRADE_FREIGHTER_HOME) && SSshuttle.getDock(TRADE_FREIGHTER_AWAY)

/// Called on every market shift.
/datum/controller/subsystem/trade/proc/call_freighter()
	if(!freighter_available() || freighter_state != FREIGHTER_AWAY)
		return
	if(SSshuttle.moveShuttle(TRADE_FREIGHTER_ID, TRADE_FREIGHTER_HOME, TRUE))
		return
	freighter_state = FREIGHTER_INBOUND
	announce_trade("The trade freighter is on its way to the trade bay.")

/// Called every subsystem tick.
/datum/controller/subsystem/trade/proc/process_freighter()
	if(freighter_state != FREIGHTER_DOCKED || world.time < freighter_departure)
		return
	for(var/mob/living/stowaway in freighter.areaInstance)
		if(stowaway.stat == DEAD)
			continue
		freighter_departure = world.time + 1 MINUTES
		announce_trade("The trade freighter cannot depart while someone is aboard.")
		return
	if(SSshuttle.moveShuttle(TRADE_FREIGHTER_ID, TRADE_FREIGHTER_AWAY, TRUE))
		freighter_departure = world.time + 1 MINUTES
		return
	freighter_state = FREIGHTER_OUTBOUND
	announce_trade("The trade freighter is departing.")

/datum/controller/subsystem/trade/proc/on_freighter_dock(datum/source, obj/docking_port/stationary/new_dock)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(freighter_docked), new_dock)

/datum/controller/subsystem/trade/proc/freighter_docked(obj/docking_port/stationary/new_dock)
	if(new_dock.id == TRADE_FREIGHTER_HOME)
		freighter_state = FREIGHTER_DOCKED
		freighter_departure = world.time + FREIGHTER_STAY
		deliver_orders(freighter.areaInstance)
		announce_trade("The trade freighter has docked at the trade bay. It departs in [FREIGHTER_STAY / (1 MINUTES)] minutes. Leave crates with consignment notes aboard.")
	else if(new_dock.id == TRADE_FREIGHTER_AWAY)
		freighter_state = FREIGHTER_AWAY
		sell_freighter_cargo()

/// Consigned crates are sold. Anything else stays aboard and comes back.
/datum/controller/subsystem/trade/proc/sell_freighter_cargo()
	var/list/report = list()
	for(var/obj/structure/closet/crate/crate in freighter.areaInstance)
		if(process_consignment(crate, report))
			qdel(crate)
	if(!length(report))
		return
	SSshuttle.centcom_message += "<center>---[station_time_timestamp()]--- Trade freighter ---</center><br>[report.Join("")]<hr>"

/datum/controller/subsystem/trade/proc/freighter_status()
	if(!freighter_available())
		return "No trade bay on this station. Goods travel on the supply shuttle."
	switch(freighter_state)
		if(FREIGHTER_AWAY)
			return "The freighter is away. It comes back with the next market shift."
		if(FREIGHTER_INBOUND)
			return "The freighter is on its way to the trade bay."
		if(FREIGHTER_DOCKED)
			return "The freighter is docked at the trade bay. It departs in [DisplayTimeText(max(0, freighter_departure - world.time))]."
		if(FREIGHTER_OUTBOUND)
			return "The freighter is on its way back."

/datum/controller/subsystem/trade/proc/announce_trade(text)
	for(var/obj/machinery/computer/trade_console/console as anything in SSmachines.get_by_type(/obj/machinery/computer/trade_console))
		if(console.is_operational())
			console.atom_say(text)

#undef FREIGHTER_AWAY
#undef FREIGHTER_INBOUND
#undef FREIGHTER_DOCKED
#undef FREIGHTER_OUTBOUND
#undef FREIGHTER_STAY
