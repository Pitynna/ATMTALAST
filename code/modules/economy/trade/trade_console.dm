// Console for the commodity market and the NPC traders.

/obj/machinery/computer/trade_console
	name = "trade console"
	desc = "Shows prices on the galactic commodity market and puts you in touch with travelling traders. Swipe your ID to buy with your own credits, or with your department's budget if you run it."
	icon_keyboard = "tech_key"
	icon_screen = "supply"
	circuit = /obj/item/circuitboard/trade_console
	light_color = LIGHT_COLOR_BROWN
	/// Who is logged in. Anyone else sees the console as logged out.
	var/datum/weakref/logged_user
	/// Personal account of the logged in user. May be null: heads without one can still spend department budgets.
	var/datum/money_account/logged_account
	/// Name on the ID that logged in.
	var/logged_name
	/// Logged in user has cargo access: may sell to traders and haggle over what they pay.
	var/cargo_access = FALSE
	/// Departments whose budget the logged in user may spend.
	var/list/payable_departments = list()
	/// Department paying for purchases, or null for the personal account.
	var/paying_department
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

/// TRUE if this user is the one logged in.
/obj/machinery/computer/trade_console/proc/session_ok(mob/user)
	return logged_user && logged_user.resolve() == user && (logged_account || length(payable_departments))

/// Account that pays for purchases right now.
/obj/machinery/computer/trade_console/proc/paying_account(mob/user)
	if(!session_ok(user))
		return null
	if(paying_department && (paying_department in payable_departments))
		return GLOB.department_accounts[paying_department]
	if(logged_account)
		return logged_account
	// No personal account: fall back to the first budget the user runs.
	paying_department = payable_departments[1]
	return GLOB.department_accounts[paying_department]

/obj/machinery/computer/trade_console/proc/logout()
	logged_user = null
	logged_account = null
	logged_name = null
	cargo_access = FALSE
	payable_departments = list()
	paying_department = null

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
	data["logged_in"] = session_ok(user)
	if(session_ok(user))
		var/datum/money_account/payer = paying_account(user)
		data["owner"] = logged_name
		data["balance"] = payer?.money
		data["cargo_access"] = cargo_access
		var/list/payers = list()
		if(logged_account)
			payers += list(list("id" = null, "name" = "Personal account", "balance" = logged_account.money))
		for(var/department in payable_departments)
			var/datum/money_account/budget = GLOB.department_accounts[department]
			if(budget)
				payers += list(list("id" = department, "name" = "[department] budget", "balance" = budget.money))
		data["payers"] = payers
		data["paying_department"] = paying_department
	return data

/obj/machinery/computer/trade_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	var/mob/user = ui.user
	. = TRUE
	if(action == "login")
		login(user)
		return
	if(!session_ok(user))
		status_message = "Please log in first."
		return
	switch(action)
		if("logout")
			logout()
			status_message = null
		if("set_payer")
			var/department = params["department"]
			if(department in payable_departments)
				paying_department = department
			else if(logged_account)
				paying_department = null
		if("buy")
			var/datum/trade_offer/offer = locateUID(params["ref"])
			if(!istype(offer) || !offer.selling || !(offer.trader in visible_traders()))
				return
			var/datum/money_account/payer = paying_account(user)
			if(!payer)
				status_message = "No account to pay from."
				return
			var/department = payer != logged_account ? paying_department : null
			status_message = SStrade.purchase(offer, text2num(params["amount"]), payer, logged_name, department)
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
			if(isnull(asking) || QDELETED(offer) || !session_ok(user))
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
	var/list/access = id.GetAccess()
	var/list/departments = trade_payable_departments(access)
	var/datum/money_account/account = attempt_account_access_nosec(id.associated_account_number)
	if(account?.suspended)
		account = null
	if(account?.security_level)
		var/pin = tgui_input_number(user, "Enter the PIN of your account", "Trade console", 0, 999999, 0)
		if(isnull(pin) || !attempt_account_access(account.account_number, pin, 2))
			status_message = "Incorrect PIN."
			return
	// The ID's access is enough to spend department budgets, even without a personal account.
	if(!account && !length(departments))
		status_message = "No usable bank account is linked to this ID, and it gives no access to department budgets."
		return
	logout()
	logged_account = account
	logged_name = id.registered_name || account?.owner_name || "Unknown"
	logged_user = WEAKREF(user)
	cargo_access = (ACCESS_CARGO in access) || (ACCESS_QM in access)
	payable_departments = departments
	paying_department = account ? null : departments[1]
	status_message = account ? "Welcome, [logged_name]." : "Welcome, [logged_name]. No personal account found: only department budgets are available."

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

/// Departments whose budget an ID with this access may spend.
/proc/trade_payable_departments(list/access)
	. = list()
	for(var/department in GLOB.trade_department_spenders)
		if(!GLOB.department_accounts[department])
			continue
		for(var/needed in GLOB.trade_department_spenders[department])
			if(needed in access)
				. += department
				break
