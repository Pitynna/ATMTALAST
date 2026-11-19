// Buying from and selling to traders.

/// Department -> accesses that may spend its budget at the trade console.
GLOBAL_LIST_INIT(trade_department_spenders, list(
	STATION_DEPARTMENT_COMMAND = list(ACCESS_CAPTAIN),
	STATION_DEPARTMENT_MEDICAL = list(ACCESS_CMO),
	STATION_DEPARTMENT_ENGINEERING = list(ACCESS_CE),
	STATION_DEPARTMENT_SCIENCE = list(ACCESS_RD),
	STATION_DEPARTMENT_SECURITY = list(ACCESS_HOS),
	STATION_DEPARTMENT_SUPPLY = list(ACCESS_QM, ACCESS_CARGO),
	STATION_DEPARTMENT_SERVICE = list(ACCESS_HOP),
	STATION_DEPARTMENT_LEGAL = list(ACCESS_MAGISTRATE),
	STATION_DEPARTMENT_CIVILIAN = list(ACCESS_HOP),
))

/// Department -> accesses that open crates bought with its budget. Supply crates are not locked.
GLOBAL_LIST_INIT(trade_department_openers, list(
	STATION_DEPARTMENT_COMMAND = list(ACCESS_HEADS),
	STATION_DEPARTMENT_MEDICAL = list(ACCESS_MEDICAL),
	STATION_DEPARTMENT_ENGINEERING = list(ACCESS_ENGINE),
	STATION_DEPARTMENT_SCIENCE = list(ACCESS_RESEARCH),
	STATION_DEPARTMENT_SECURITY = list(ACCESS_SECURITY),
	STATION_DEPARTMENT_SERVICE = list(ACCESS_HOP, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_LIBRARY),
	STATION_DEPARTMENT_LEGAL = list(ACCESS_LAWYER, ACCESS_MAGISTRATE),
	STATION_DEPARTMENT_CIVILIAN = list(ACCESS_HOP),
))

/// Goods bought from a trader, waiting for the next shuttle to the station.
/datum/trade_order
	var/trader_name = ""
	/// Real name of the buyer for personal orders.
	var/owner_name
	/// Department that paid, for department orders.
	var/department
	/// Item path -> how many items.
	var/list/goods = list()

/// Locked crate for personal and department purchases.
/obj/structure/closet/crate/secure/trade_parcel
	name = "trade crate"
	desc = "A sealed crate from a trader. The lock reads the buyer's ID."
	req_access = list(ACCESS_QM)
	/// Personal orders open for this name.
	var/owner_name
	/// Department orders open for this department's access.
	var/department

/obj/structure/closet/crate/secure/trade_parcel/proc/address(datum/trade_order/order)
	if(order.department)
		department = order.department
		name = "trade crate ([order.department])"
		req_access = GLOB.trade_department_openers[order.department]
		check_one_access = TRUE
	else
		owner_name = order.owner_name
		name = "trade crate ([order.owner_name])"

/obj/structure/closet/crate/secure/trade_parcel/allowed(mob/user)
	var/obj/item/card/id/id = user?.get_id_card()
	if(owner_name && id?.registered_name == owner_name)
		return TRUE
	return ..()

/obj/structure/closet/crate/secure/trade_parcel/examine(mob/user)
	. = ..()
	if(owner_name)
		. += span_notice("It is addressed to [owner_name].")
	if(department)
		. += span_notice("It is addressed to the [department] department.")

/// Put this in a crate on the supply shuttle to sell its contents to a trader.
/obj/item/paper/trade_consignment
	name = "consignment note"
	desc = "Put it in a crate with the goods and leave the crate aboard the trade freighter. Stations without a trade bay send it on the supply shuttle."
	var/trader_type

/obj/item/paper/trade_consignment/proc/setup(datum/trader/trader)
	trader_type = trader.type
	name = "consignment note ([trader.name])"
	var/list/lines = list("<center><b>CONSIGNMENT NOTE</b></center><hr>")
	lines += "Buyer: <b>[trader.name]</b>, [trader.title]<br>"
	lines += "Payment: supply department account, at the trader's prices on arrival.<br><br>"
	lines += "<b>Wanted goods:</b><br>"
	for(var/datum/trade_offer/offer as anything in trader.buying)
		lines += "[offer.name]: [offer.price] cr[offer.stock >= 0 ? ", up to [offer.stock]" : ""]<br>"
	lines += "<hr><i>Goods not on this list are disposed of without payment.</i>"
	info = lines.Join("")
	update_icon()

// MARK: SStrade trading procs

/datum/controller/subsystem/trade/proc/get_trader(trader_type)
	for(var/datum/trader/trader as anything in traders)
		if(trader.type == trader_type)
			return trader

/// Keeps at least two lawful traders around after a market shift.
/datum/controller/subsystem/trade/proc/shift_traders()
	for(var/datum/trader/trader as anything in traders)
		trader.market_shift()
	var/list/present = list()
	var/list/absent = list()
	for(var/datum/trader/trader as anything in traders)
		if(trader.contraband)
			continue
		if(trader.away)
			absent += trader
		else
			present += trader
	while(length(present) < 2 && length(absent))
		var/datum/trader/trader = pick_n_take(absent)
		trader.arrive()
		present += trader

/// Returns null on success or the reason the purchase failed.
/datum/controller/subsystem/trade/proc/purchase(datum/trade_offer/offer, amount, datum/money_account/account, owner_name, department)
	var/datum/trader/trader = offer.trader
	amount = round(amount)
	if(!trader || trader.away || !(offer in trader.selling))
		return "This offer is gone."
	if(amount <= 0)
		return "Choose how many to buy."
	if(offer.stock >= 0 && amount > offer.stock)
		return "[trader.name] only has [offer.stock] left."
	if(account.suspended)
		return "Account suspended."
	var/total = offer.price * amount
	if(account.money < total)
		return "Not enough credits: [total] cr needed."
	var/purpose = "Purchase of [amount] x [offer.name][department ? " by [owner_name]" : ""]"
	account.charge(total, null, purpose, "Trade console", trader.name)
	if(offer.stock >= 0)
		offer.stock -= amount
	var/datum/trade_order/order = new
	order.trader_name = trader.name
	order.owner_name = owner_name
	order.department = department
	order.goods[offer.item_path] = amount * offer.bundle
	pending_orders += order
	trader.say(trader.dialogue_purchase)
	if(offer.stock == 0)
		trader.selling -= offer
		qdel(offer)

/// Supply shuttle fallback for maps without a trade bay.
/datum/controller/subsystem/trade/proc/deliver_by_supply(obj/docking_port/mobile/supply/shuttle, obj/docking_port/stationary/destination)
	if(freighter_available() || !is_station_level(destination.z))
		return
	deliver_orders(shuttle.areaInstance)

/// Unloads pending orders onto free floor of a shuttle area.
/datum/controller/subsystem/trade/proc/deliver_orders(area/cargo_area)
	if(!length(pending_orders))
		return
	var/list/spots = list()
	for(var/turf/simulated/floor in cargo_area)
		if(floor.density)
			continue
		var/blocked = FALSE
		for(var/obj/thing in floor)
			if(thing.density)
				blocked = TRUE
				break
		if(!blocked)
			spots += floor
	for(var/datum/trade_order/order as anything in pending_orders.Copy())
		if(!length(spots))
			return // the rest waits for the next run
		var/turf/spot = pick_n_take(spots)
		var/obj/structure/closet/crate/crate
		if(order.department != STATION_DEPARTMENT_SUPPLY)
			var/obj/structure/closet/crate/secure/trade_parcel/parcel = new(spot)
			parcel.address(order)
			crate = parcel
		else
			crate = new /obj/structure/closet/crate(spot)
			crate.name = "trade crate ([order.trader_name])"
		for(var/path in order.goods)
			spawn_goods(path, order.goods[path], crate)
		pending_orders -= order
		qdel(order)

/datum/controller/subsystem/trade/proc/spawn_goods(path, count, atom/destination)
	if(ispath(path, /obj/item/stack))
		var/obj/item/stack/stack_type = path
		var/per_stack = initial(stack_type.max_amount)
		while(count > 0)
			var/amount = min(count, per_stack)
			new path(destination, amount)
			count -= amount
		return
	for(var/i in 1 to count)
		new path(destination)

/**
 * Sells what a crate holds to the trader named on its consignment note.
 * Called for every crate the supply shuttle takes away. Returns TRUE if the crate had a note.
 */
/datum/controller/subsystem/trade/proc/process_consignment(atom/movable/crate, list/report)
	if(!is_crate(crate))
		return FALSE
	var/obj/item/paper/trade_consignment/note = locate() in crate
	if(!note)
		return FALSE
	var/datum/trader/trader = get_trader(note.trader_type)
	if(!trader)
		return FALSE
	var/total = 0
	var/list/sold = list()
	for(var/obj/item/thing in crate.get_all_contents_ignoring(typecacheof(list(/obj/item/paper/trade_consignment))))
		if(thing == crate || QDELETED(thing))
			continue
		for(var/datum/trade_offer/offer as anything in trader.buying)
			var/datum/commodity/commodity = get_commodity(offer.commodity_type)
			if(!commodity?.matches(thing))
				continue
			var/units = commodity.units_in(thing)
			if(offer.stock >= 0)
				units = min(units, offer.stock)
			if(units <= 0)
				break
			total += units * offer.price
			sold[offer.name] += units
			if(offer.stock >= 0)
				offer.stock -= units
			if(isstack(thing))
				var/obj/item/stack/stack = thing
				if(stack.amount > units)
					stack.use(units)
					break
			qdel(thing)
			break
	qdel(note)
	if(!total)
		report += "[trader.name] found nothing they wanted in a consigned crate.<br>"
		return TRUE
	total = round(total)
	var/datum/money_account/cargo_account = GLOB.department_accounts[STATION_DEPARTMENT_SUPPLY]
	cargo_account.credit(total, "Sale to [trader.name]", "Trade console", trader.name)
	var/list/parts = list()
	for(var/name in sold)
		parts += "[sold[name]] [name]"
	report += "[span_good("+[total] [MONEY_NAME]")]: [trader.name] bought [english_list(parts)].<br>"
	return TRUE
