// NPC traders reached through the trade console. Ideas from Goonstation 13, code written anew.

/// Something a trader sells to the station or buys from it.
/datum/trade_offer
	var/datum/trader/trader
	var/name = ""
	/// Trader sells it to the crew. Otherwise the trader buys it.
	var/selling = TRUE
	/// What is delivered, for things the trader sells.
	var/item_path
	/// Items per unit, for stacks sold in bundles.
	var/bundle = 1
	/// What the trader buys, for things the trader buys.
	var/commodity_type
	/// Price of one unit before any haggling, used as the reference for haggling limits.
	var/base_price = 10
	/// Current price of one unit.
	var/price = 10
	/// Multiplier on the commodity market price, for offers that follow the market.
	var/markup = 1
	/// Units left to sell, or units still wanted when buying. -1 means no limit.
	var/stock = -1
	/// The price was haggled and stays until the next market shift.
	var/haggled = FALSE

/datum/trade_offer/Destroy(force)
	trader = null
	return ..()

/// Sets the price from the market, or rerolls a fixed price around its base.
/datum/trade_offer/proc/reprice()
	haggled = FALSE
	var/datum/commodity/commodity = commodity_type ? SStrade.get_commodity(commodity_type) : null
	if(!commodity && item_path && bundle > 1)
		commodity = SStrade.commodity_for_path(item_path)
	if(commodity)
		base_price = commodity.price * markup * bundle
	price = max(1, round(base_price * rand(90, 110) / 100))

/datum/trade_offer/proc/ui_entry()
	return list(
		"ref" = UID(),
		"name" = name,
		"selling" = selling,
		"price" = price,
		"stock" = stock,
		"bundle" = bundle,
		"haggled" = haggled,
		"in_demand" = commodity_type ? !!SStrade.get_commodity(commodity_type)?.in_demand : FALSE,
	)

/datum/trader
	/// Personal name, made when the trader is created.
	var/name = "Trader"
	/// What the trader does, shown under the name.
	var/title = "travelling merchant"
	/// Font Awesome icon shown in the UI.
	var/icon = "user"
	var/color = "label"
	var/desc = ""

	/// Min and max haggle attempts per visit.
	var/list/base_patience = list(3, 5)
	/// Haggle attempts left this visit.
	var/patience = 3
	/// A haggle that moves the price by this many percent or more is refused.
	var/hike_tolerance = 25
	/// Happily accepts haggles that are bad for the crew.
	var/shady = FALSE
	/// Only shown on consoles with broken safeties.
	var/contraband = FALSE
	/// Not around right now.
	var/away = FALSE
	/// Chance to leave on a market shift.
	var/chance_leave = 30
	/// Chance to come back on a market shift.
	var/chance_arrive = 50

	/// Pool of goods for sale: list(path, base price, min stock, max stock, chance, bundle).
	var/list/sell_pool = list()
	/// How many goods from the pool are offered each visit.
	var/list/sell_count = list(4, 6)
	/// Commodity type -> markup over the market price.
	var/list/buy_pool = list()

	var/list/datum/trade_offer/selling = list()
	var/list/datum/trade_offer/buying = list()

	/// Last line the trader said.
	var/message = ""
	var/list/dialogue_greet = list("Hello. Take a look at my wares.")
	var/list/dialogue_haggle_accept = list("Alright, how about this?")
	var/list/dialogue_haggle_final = list("That is my final offer.")
	var/list/dialogue_haggle_reject = list("No, that will not work.")
	var/list/dialogue_wrong_haggle = list("If you insist!")
	var/list/dialogue_leave = list("I have had enough of this. Goodbye.")
	var/list/dialogue_purchase = list("Pleasure doing business. It ships on the next supply run.")
	var/list/dialogue_no_patience = list("We are done haggling.")

/datum/trader/New()
	. = ..()
	name = generate_name()
	arrive()

/datum/trader/Destroy(force)
	QDEL_LIST(selling)
	QDEL_LIST(buying)
	return ..()

/datum/trader/proc/generate_name()
	return name

/datum/trader/proc/say(list/lines)
	message = pick(lines)

/// Fresh stock and patience for a new visit.
/datum/trader/proc/arrive()
	away = FALSE
	patience = rand(base_patience[1], base_patience[2])
	QDEL_LIST(selling)
	QDEL_LIST(buying)
	var/list/pool = sell_pool.Copy()
	var/wanted = rand(sell_count[1], sell_count[2])
	while(length(selling) < wanted && length(pool))
		var/list/entry = pick_n_take(pool)
		if(length(entry) >= 5 && !prob(entry[5]))
			continue
		var/datum/trade_offer/offer = new
		offer.trader = src
		offer.selling = TRUE
		offer.item_path = entry[1]
		offer.bundle = length(entry) >= 6 ? entry[6] : 1
		var/obj/item/sample = offer.item_path
		offer.name = offer.bundle > 1 ? "[initial(sample.name)] x[offer.bundle]" : initial(sample.name)
		offer.base_price = entry[2]
		offer.markup = 1.4
		offer.stock = rand(entry[3], entry[4])
		offer.reprice()
		selling += offer
	for(var/commodity_type in buy_pool)
		var/datum/commodity/commodity = SStrade.get_commodity(commodity_type)
		if(!commodity)
			continue
		var/datum/trade_offer/offer = new
		offer.trader = src
		offer.selling = FALSE
		offer.commodity_type = commodity_type
		offer.name = "[commodity.name] (per [commodity.unit])"
		offer.markup = buy_pool[commodity_type]
		offer.stock = commodity.base_price >= 50 ? rand(5, 15) : rand(40, 150)
		offer.reprice()
		buying += offer
	say(dialogue_greet)

/// Called on every market shift.
/datum/trader/proc/market_shift()
	if(away)
		if(prob(chance_arrive))
			arrive()
		return
	if(patience <= 0 || prob(chance_leave))
		away = TRUE
		return
	for(var/datum/trade_offer/offer as anything in selling + buying)
		offer.reprice()

/datum/trader/proc/leave()
	say(dialogue_leave)
	away = TRUE

/**
 * Haggles over one offer. The trader meets the crew somewhere between the two prices,
 * leaning towards their own side. Every attempt costs patience.
 */
/datum/trader/proc/haggle(datum/trade_offer/offer, asking)
	if(away)
		return
	asking = round(asking)
	if(asking <= 0 || asking == offer.price)
		return
	if(patience <= 0)
		leave()
		return
	var/crew_buys = offer.selling
	// The crew asks for a worse deal.
	if(crew_buys ? asking > offer.price : asking < offer.price)
		if(shady)
			offer.price = asking
			offer.haggled = TRUE
			say(dialogue_wrong_haggle)
		else
			patience--
			say(dialogue_haggle_reject)
		return
	var/change = abs(asking - offer.price) / offer.price * 100
	var/too_far = crew_buys ? asking < offer.base_price / 4 : asking > offer.base_price * 4
	patience--
	if(change >= hike_tolerance || too_far)
		say(patience > 0 ? dialogue_haggle_reject : dialogue_no_patience)
		return
	var/middle = (offer.price + asking) / 2
	var/gap = round(abs(offer.price - middle))
	var/new_price = crew_buys ? middle + rand(0, gap) : middle - rand(0, gap)
	new_price = round(new_price)
	// Always give at least a little.
	if(new_price == offer.price)
		new_price += crew_buys ? -1 : 1
	offer.price = max(1, new_price)
	offer.haggled = TRUE
	say(patience > 0 ? dialogue_haggle_accept : dialogue_haggle_final)

/datum/trader/proc/ui_entry()
	var/list/sell_data = list()
	for(var/datum/trade_offer/offer as anything in selling)
		sell_data += list(offer.ui_entry())
	var/list/buy_data = list()
	for(var/datum/trade_offer/offer as anything in buying)
		buy_data += list(offer.ui_entry())
	return list(
		"id" = UID(),
		"name" = name,
		"title" = title,
		"desc" = desc,
		"icon" = icon,
		"color" = color,
		"message" = message,
		"patience" = patience,
		"contraband" = contraband,
		"selling" = sell_data,
		"buying" = buy_data,
	)
