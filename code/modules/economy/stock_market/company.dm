// A listed company. Its price drifts on its own and reacts to news about it.

/datum/stock_company
	/// Unique id, used by the UI.
	var/id
	var/name = "Company"
	/// Short exchange symbol.
	var/ticker = "CMP"
	var/desc = ""
	var/datum/stock_industry/industry
	/// Products the company is known for.
	var/list/products = list()

	/// Current share price.
	var/price = 100
	/// Price at the previous exchange tick.
	var/last_price = 100
	/// Price at listing, used to judge how badly the company is doing.
	var/ipo_price = 100
	/// What the market thinks the company is really worth. The price is pulled towards it.
	var/fair_value = 100
	/// Standard deviation of the random part of the price move per tick.
	var/volatility = 0.015
	/// Slow drift of the company, from about -3 to 3.
	var/trend = 0
	/// Short lived mood from news, decays every tick.
	var/sentiment = 0
	/// Shares out on the open market. The fewer, the more crew trades move the price.
	var/float_shares = 50000
	/// Last prices for the chart.
	var/list/history = list()
	/// Delisted after a crash.
	var/bankrupt = FALSE

	/// Running events. Finished ones are dropped.
	var/list/datum/stock_event/events = list()
	/// Open offers from brokers to lend this company's shares.
	var/list/datum/stock_short/broker_offers = list()

	/// When the next product launch is announced.
	var/next_product_time = 0
	/// When the next quarterly report comes out.
	var/next_report_time = 0
	/// When something may go wrong in the boardroom.
	var/next_scandal_time = 0

/datum/stock_company/New(datum/stock_industry/new_industry)
	. = ..()
	industry = new_industry
	price = rand(20, 160)
	ipo_price = price
	fair_value = price * (rand(90, 110) / 100)
	last_price = price
	volatility = rand(8, 25) / 1000 * industry.volatility_mult
	trend = rand(-15, 15) / 10
	sentiment = rand(-5, 5) / 10
	float_shares = rand(20, 90) * 1000
	for(var/i in 1 to rand(2, 4))
		products |= industry.generate_product_name()
	next_product_time = world.time + rand(3, 12) MINUTES
	next_report_time = world.time + rand(8, 20) MINUTES
	next_scandal_time = world.time + rand(20, 60) MINUTES

/datum/stock_company/Destroy(force)
	QDEL_LIST_CONTENTS(events)
	QDEL_LIST_CONTENTS(broker_offers)
	industry = null
	return ..()

/// One market step. Moves the price and runs the company's events.
/datum/stock_company/proc/tick(simulated = FALSE)
	if(bankrupt)
		return
	if(!simulated)
		for(var/datum/stock_event/event as anything in events.Copy())
			event.advance()
			if(event.state == STOCK_EVENT_DONE)
				events -= event
				qdel(event)
		if(bankrupt)
			return
		schedule_events()

	last_price = price
	var/reversion = 0.03 * log(fair_value / price)
	var/change = trend * 0.0015 + sentiment * 0.006 + reversion + gaussian(0, volatility)
	price = max(STOCK_MIN_PRICE, round(price * NUM_E ** change, 0.01))

	fair_value = max(STOCK_MIN_PRICE, fair_value * NUM_E ** (trend * 0.001 + gaussian(0, volatility / 4)))
	sentiment *= 0.9
	if(abs(sentiment) < 0.02)
		sentiment = 0
	trend = clamp(trend + gaussian(0, 0.15) - trend * 0.05, -3, 3)

	history += price
	if(length(history) > STOCK_HISTORY_LENGTH)
		history.Cut(1, 2)

/// Starts new events when their time comes.
/datum/stock_company/proc/schedule_events()
	if(world.time >= next_product_time && !has_event(/datum/stock_event/product))
		events += new /datum/stock_event/product(src)
		next_product_time = INFINITY // set again when the launch is over
	if(world.time >= next_report_time)
		events += new /datum/stock_event/report(src)
		next_report_time = world.time + rand(12, 20) MINUTES
	if(world.time >= next_scandal_time && !has_event(/datum/stock_event/scandal))
		next_scandal_time = world.time + rand(25, 50) MINUTES
		if(prob(40))
			events += new /datum/stock_event/scandal(src)
	if(!has_event(/datum/stock_event/bankruptcy))
		var/chance = price < ipo_price * 0.35 ? 1 : 0.02
		if(prob(chance))
			events += new /datum/stock_event/bankruptcy(src)

/datum/stock_company/proc/has_event(event_type)
	for(var/datum/stock_event/event as anything in events)
		if(istype(event, event_type))
			return TRUE
	return FALSE

/// News moves the mood, the slow trend and the perceived worth of the company.
/datum/stock_company/proc/affect_opinion(boost)
	sentiment += boost * rand(5, 10) / 10
	fair_value = max(STOCK_MIN_PRICE, fair_value * (1 + boost * rand(1, 3) / 100))
	trend = clamp(trend + boost * rand(1, 3) / 10, -3, 3)

/// Price change since the start of the chart, in percent.
/datum/stock_company/proc/change_percent(points = 10)
	var/count = length(history)
	if(count < 2)
		return 0
	var/old = history[max(1, count - points)]
	return round((price - old) / old * 100, 0.01)

/**
 * Credits for a deal of shares, before the fee.
 * Crew orders move the price, so the deal goes at the average of the price before and after it.
 */
/datum/stock_company/proc/quote(amount, buying)
	var/after = price_after(amount, buying)
	return round(amount * (price + after) / 2)

/datum/stock_company/proc/price_after(amount, buying)
	var/impact = amount / float_shares * 0.5
	return max(STOCK_MIN_PRICE, round(price * (buying ? 1 + impact : 1 - impact), 0.01))

/datum/stock_company/proc/apply_trade(amount, buying)
	price = price_after(amount, buying)
	if(length(history))
		history[length(history)] = price

/datum/stock_company/proc/ui_entry()
	var/list/visible_events = list()
	for(var/datum/stock_event/event as anything in events)
		if(event.state != STOCK_EVENT_VISIBLE)
			continue
		visible_events += list(list("title" = event.title, "desc" = event.desc))
	return list(
		"id" = id,
		"name" = name,
		"ticker" = ticker,
		"desc" = desc,
		"industry" = industry.name,
		"price" = price,
		"last_price" = last_price,
		"change" = change_percent(),
		"history" = history,
		"bankrupt" = bankrupt,
		"events" = visible_events,
	)
