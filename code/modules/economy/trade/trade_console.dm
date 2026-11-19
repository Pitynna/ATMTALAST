// Console for the commodity market and the NPC traders.

/obj/machinery/computer/trade_console
	name = "trade console"
	desc = "Shows prices on the galactic commodity market and puts you in touch with travelling traders. Swipe your ID to buy."
	icon_keyboard = "tech_key"
	icon_screen = "supply"
	circuit = /obj/item/circuitboard/trade_console
	light_color = LIGHT_COLOR_BROWN
	/// Who is logged in. Anyone else sees the console as logged out.
	var/datum/weakref/logged_user
	var/datum/money_account/logged_account
	/// Logged in user has cargo access and may spend the supply budget.
	var/cargo_access = FALSE
	/// Spend the supply budget instead of the personal account.
	var/use_department = FALSE
	var/status_message
	/// Stops note printing spam.
	COOLDOWN_DECLARE(print_cooldown)

/obj/machinery/computer/trade_console/Destroy()
	logged_user = null
	logged_account = null
	return ..()

/obj/machinery/computer/trade_console/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/trade_console/attack_hand(mob/user)
	if(..())
		return TRUE
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/trade_console/emag_act(mob/user)
	if(emagged)
		return
	emagged = TRUE
	atom_say("Trade filters disabled. Unlisted contacts available.")
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	if(user)
		add_attack_logs(user, src, "emagged")

/obj/machinery/computer/trade_console/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TradeConsole", name)
		ui.open()

/obj/machinery/computer/trade_console/proc/session_account(mob/user)
	if(!logged_account || logged_user?.resolve() != user)
		return null
	return logged_account

/// Account that pays for purchases right now.
/obj/machinery/computer/trade_console/proc/paying_account(mob/user)
	if(!session_account(user))
		return null
	if(use_department && cargo_access)
		return GLOB.department_accounts[STATION_DEPARTMENT_SUPPLY]
	return logged_account

/obj/machinery/computer/trade_console/proc/visible_traders()
	. = list()
	for(var/datum/trader/trader as anything in SStrade.traders)
		if(trader.away || (trader.contraband && !emagged))
			continue
		. += trader

/obj/machinery/computer/trade_console/ui_data(mob/user)
	var/list/data = list()
	data["market"] = SStrade.market_ui_data()
	var/list/trader_data = list()
	for(var/datum/trader/trader as anything in visible_traders())
		trader_data += list(trader.ui_entry())
	data["traders"] = trader_data
	var/away_count = 0
	for(var/datum/trader/trader as anything in SStrade.traders)
		if(trader.away && (!trader.contraband || emagged))
			away_count++
	data["away_count"] = away_count
	data["pending_orders"] = length(SStrade.pending_orders)
	data["freighter"] = SStrade.freighter_status()
	data["status"] = status_message
	var/datum/money_account/account = session_account(user)
	data["logged_in"] = !!account
	if(account)
		data["owner"] = account.owner_name
		data["balance"] = account.money
		data["cargo_access"] = cargo_access
		data["use_department"] = use_department && cargo_access
		var/datum/money_account/cargo_account = GLOB.department_accounts[STATION_DEPARTMENT_SUPPLY]
		data["department_balance"] = cargo_account.money
	return data

/obj/machinery/computer/trade_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	var/mob/user = ui.user
	. = TRUE
	if(action == "login")
		login(user)
		return
	var/datum/money_account/account = session_account(user)
	if(!account)
		status_message = "Please log in first."
		return
	switch(action)
		if("logout")
			logged_user = null
			logged_account = null
			cargo_access = FALSE
			use_department = FALSE
			status_message = null
		if("toggle_department")
			use_department = cargo_access && !use_department
		if("buy")
			var/datum/trade_offer/offer = locateUID(params["ref"])
			if(!istype(offer) || !offer.selling || !(offer.trader in visible_traders()))
				return
			var/datum/money_account/payer = paying_account(user)
			var/department = payer != account
			status_message = SStrade.purchase(offer, text2num(params["amount"]), payer, department ? null : account.owner_name)
			if(!status_message)
				status_message = "Ordered from [offer.trader?.name]. It arrives on the next trade freighter."
				playsound(src, 'sound/machines/twobeep.ogg', 30, TRUE)
		if("haggle")
			var/datum/trade_offer/offer = locateUID(params["ref"])
			if(!istype(offer) || !(offer.trader in visible_traders()))
				return
			if(!offer.selling && !cargo_access)
				status_message = "Only cargo staff can negotiate what traders pay the station."
				return
			var/datum/trader/trader = offer.trader
			var/asking = tgui_input_number(user, "Current price: [offer.price] cr. What price do you propose?", "Haggle with [trader.name]", offer.price, 1000000, 1)
			if(isnull(asking) || QDELETED(offer) || session_account(user) != account)
				return
			trader.haggle(offer, asking)
			status_message = null
		if("consignment")
			if(!cargo_access)
				status_message = "Only cargo staff can sell to traders."
				return
			var/datum/trader/trader = locateUID(params["ref"])
			if(!istype(trader) || !(trader in visible_traders()))
				return
			if(!COOLDOWN_FINISHED(src, print_cooldown))
				status_message = "The printer is busy."
				return
			COOLDOWN_START(src, print_cooldown, 5 SECONDS)
			var/obj/item/paper/trade_consignment/note = new(loc)
			note.setup(trader)
			playsound(src, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
			status_message = "Consignment note printed. Put it in a crate with the goods and leave the crate aboard the trade freighter."

/obj/machinery/computer/trade_console/proc/login(mob/user)
	if(issilicon(user))
		status_message = "Synthetic units cannot hold a trade account."
		return
	var/obj/item/card/id/id = user.get_id_card()
	if(!istype(id))
		status_message = "No ID card found. Wear or hold your ID."
		return
	var/datum/money_account/account = attempt_account_access_nosec(id.associated_account_number)
	if(!account)
		status_message = "No bank account is linked to this ID."
		return
	if(account.security_level)
		var/pin = tgui_input_number(user, "Enter the PIN of your account", "Trade console", 0, 999999, 0)
		if(isnull(pin) || !attempt_account_access(account.account_number, pin, 2))
			status_message = "Incorrect PIN."
			return
	if(account.suspended)
		status_message = "This account is suspended."
		return
	logged_account = account
	logged_user = WEAKREF(user)
	cargo_access = (ACCESS_CARGO in id.GetAccess()) || (ACCESS_QM in id.GetAccess())
	use_department = FALSE
	status_message = "Welcome, [account.owner_name]."

/// Called by SStrade when prices change.
/obj/machinery/computer/trade_console/proc/market_shifted(list/hot)
	if(!is_operational())
		return
	if(length(hot))
		atom_say("Market prices updated. In demand: [english_list(hot)].")
	else
		atom_say("Market prices updated.")
	playsound(src, 'sound/machines/twobeep.ogg', 30, TRUE)

/obj/item/circuitboard/trade_console
	board_name = "Trade Console"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/trade_console
	origin_tech = "programming=2"

/datum/design/trade_console
	name = "Console Board (Trade Console)"
	desc = "Allows for the construction of circuit boards used to build a trade console."
	id = "trade_console"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/trade_console
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)
