// Commodity market: prices shift every 15-20 minutes. Idea from Goonstation 13, code written anew.

SUBSYSTEM_DEF(trade)
	name = "Trade"
	wait = 1 MINUTES
	runlevels = RUNLEVEL_GAME
	ss_flags = SS_BACKGROUND | SS_KEEP_TIMING

	/// Commodity type -> datum.
	var/list/datum/commodity/commodities = list()
	/// world.time of the next market shift.
	var/next_shift = 0
	/// How many shifts happened this round.
	var/shift_count = 0
	/// NPC traders, present or away.
	var/list/datum/trader/traders = list()
	/// Bought goods waiting for the shuttle.
	var/list/datum/trade_order/pending_orders = list()

/datum/controller/subsystem/trade/Initialize()
	for(var/commodity_type in subtypesof(/datum/commodity))
		commodities[commodity_type] = new commodity_type
	market_shift(announce = FALSE)
	for(var/trader_type in subtypesof(/datum/trader))
		traders += new trader_type
	return SS_INIT_SUCCESS

/datum/controller/subsystem/trade/fire(resumed)
	if(world.time >= next_shift)
		market_shift()

/datum/controller/subsystem/trade/proc/market_shift(announce = TRUE)
	// Some shifts are hot and many goods are wanted, some are quiet.
	var/hot_chance = rand(10, 33)
	for(var/commodity_type in commodities)
		var/datum/commodity/commodity = commodities[commodity_type]
		commodity.shift(hot_chance)
	shift_count++
	next_shift = world.time + rand(MARKET_SHIFT_MIN, MARKET_SHIFT_MAX)
	shift_traders()
	if(!announce)
		return
	var/list/hot = list()
	for(var/commodity_type in commodities)
		var/datum/commodity/commodity = commodities[commodity_type]
		if(commodity.in_demand && !commodity.hidden)
			hot += commodity.name
	for(var/obj/machinery/computer/trade_console/console as anything in SSmachines.get_by_type(/obj/machinery/computer/trade_console))
		console.market_shifted(hot)

/datum/controller/subsystem/trade/proc/get_commodity(commodity_type)
	return commodities[commodity_type]

/// The commodity an item counts as, if any.
/datum/controller/subsystem/trade/proc/commodity_for_path(path)
	for(var/commodity_type in commodities)
		var/datum/commodity/commodity = commodities[commodity_type]
		if(commodity.matches_path(path))
			return commodity

/datum/controller/subsystem/trade/proc/commodity_for_reagents()
	for(var/commodity_type in commodities)
		var/datum/commodity/commodity = commodities[commodity_type]
		if(commodity.reagent_quests)
			return commodity

/**
 * Multiplier for the reward of a new CentCom supply request.
 * Averages the market index of everything the request asks for. Goods not on the market count as 1.
 */
/datum/controller/subsystem/trade/proc/quest_modifier(datum/cargo_quests_storage/storage)
	var/total = 0
	var/count = 0
	for(var/datum/cargo_quest/quest as anything in storage.current_quests)
		var/list/paths
		if(istype(quest, /datum/cargo_quest/reagents))
			var/datum/cargo_quest/reagents/reagent_quest = quest
			var/datum/commodity/chemicals = commodity_for_reagents()
			for(var/reagent in reagent_quest.required_reagents)
				total += chemicals ? chemicals.index() : 1
				count++
			continue
		if(istype(quest, /datum/cargo_quest/thing/minerals))
			var/datum/cargo_quest/thing/minerals/mineral_quest = quest
			paths = mineral_quest.required_minerals
		else
			paths = quest.req_items
		for(var/path in paths)
			var/datum/commodity/commodity = commodity_for_path(path)
			total += commodity ? commodity.index() : 1
			count++
	if(!count)
		return 1
	return clamp(total / count, MARKET_QUEST_MIN, MARKET_QUEST_MAX)

/datum/controller/subsystem/trade/proc/market_ui_data()
	var/list/goods = list()
	for(var/commodity_type in commodities)
		var/datum/commodity/commodity = commodities[commodity_type]
		if(commodity.hidden)
			continue
		goods += list(commodity.ui_entry())
	return list(
		"commodities" = goods,
		"next_shift" = max(0, round((next_shift - world.time) / 10)),
		"quest_min" = MARKET_QUEST_MIN,
		"quest_max" = MARKET_QUEST_MAX,
	)
