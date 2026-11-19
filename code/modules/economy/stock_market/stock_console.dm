// Console for trading on the galactic stock exchange with a personal or department account.

/obj/machinery/computer/stock_exchange
	name = "stock exchange console"
	desc = "A terminal linked to the Galactic Exchange. Swipe your ID to buy and sell shares with your own credits, or with your department's budget if you run it."
	icon_keyboard = "tech_key"
	icon_screen = "comm_logs"
	circuit = /obj/item/circuitboard/stock_exchange
	light_color = LIGHT_COLOR_GREEN
	/// Account currently logged in.
	var/datum/money_account/logged_account
	/// Who logged in. Anyone else sees the login screen.
	var/datum/weakref/logged_user
	/// Last error or result shown in the UI.
	var/status_message
	/// Departments whose budget the logged in user may invest.
	var/list/payable_departments = list()
	/// Department the user trades for, or null for the personal account.
	var/acting_department

/obj/machinery/computer/stock_exchange/Destroy()
	logged_account = null
	logged_user = null
	return ..()

/obj/machinery/computer/stock_exchange/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/stock_exchange/attack_hand(mob/user)
	if(..())
		return TRUE
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/stock_exchange/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StockExchange", name)
		ui.open()

/obj/machinery/computer/stock_exchange/proc/session_account(mob/user)
	if(!logged_account || logged_user?.resolve() != user)
		return null
	return logged_account

/// Account the deals go through: the personal one or a department budget.
/obj/machinery/computer/stock_exchange/proc/acting_account(mob/user)
	var/datum/money_account/account = session_account(user)
	if(account && acting_department && (acting_department in payable_departments))
		return GLOB.department_accounts[acting_department] || account
	return account

/obj/machinery/computer/stock_exchange/ui_data(mob/user)
	var/list/data = list()
	var/list/company_data = list()
	var/list/offers = list()
	for(var/datum/stock_company/company as anything in SSstock_market.companies)
		company_data += list(company.ui_entry())
		for(var/datum/stock_short/offer as anything in company.broker_offers)
			offers += list(offer.ui_entry())
	data["companies"] = company_data
	data["offers"] = offers
	var/list/news = list()
	for(var/datum/stock_article/article as anything in SSstock_market.articles)
		news += list(article.ui_entry())
	data["news"] = news
	data["fee_percent"] = STOCK_TRADE_FEE
	data["min_fee"] = STOCK_MIN_FEE
	data["max_order"] = STOCK_MAX_ORDER
	data["ltv_percent"] = STOCK_LOAN_LTV * 100
	data["margin_call_percent"] = STOCK_LOAN_MARGIN_CALL * 100
	data["interest_percent"] = STOCK_LOAN_INTEREST
	data["status"] = status_message
	var/datum/money_account/personal = session_account(user)
	data["logged_in"] = !!personal
	if(personal)
		var/datum/money_account/account = acting_account(user)
		data["owner"] = personal.owner_name
		data["acting_for"] = account == personal ? null : acting_department
		data["balance"] = account.money
		data["portfolio"] = SSstock_market.get_portfolio(account).ui_entry()
		var/list/payers = list(list("id" = null, "name" = "Personal account"))
		for(var/department in payable_departments)
			if(GLOB.department_accounts[department])
				payers += list(list("id" = department, "name" = "[department] budget"))
		data["payers"] = payers
	return data

/obj/machinery/computer/stock_exchange/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	var/mob/user = ui.user
	. = TRUE
	if(action == "login")
		login(user)
		return
	var/datum/money_account/personal = session_account(user)
	if(!personal)
		status_message = "Please log in first."
		return
	var/datum/money_account/account = acting_account(user)
	var/for_department = account != personal
	// Department deals show who made them in the account's transaction log.
	var/terminal = for_department ? "Galactic Exchange terminal ([personal.owner_name])" : "Galactic Exchange terminal"
	var/list/old_log = SSstock_market.get_portfolio(account).trade_log
	var/old_first = length(old_log) ? old_log[1] : null
	var/result
	switch(action)
		if("logout")
			logged_account = null
			logged_user = null
			payable_departments = list()
			acting_department = null
			status_message = null
			return
		if("set_payer")
			var/department = params["department"]
			acting_department = (department in payable_departments) ? department : null
			status_message = null
			return
		if("buy", "sell")
			var/datum/stock_company/company = SSstock_market.get_company(params["id"])
			if(!company)
				return
			var/amount = text2num(params["amount"])
			if(action == "buy")
				result = SSstock_market.buy(account, company, amount, terminal)
			else
				result = SSstock_market.sell(account, company, amount, terminal)
			if(!result)
				playsound(src, 'sound/machines/twobeep.ogg', 30, TRUE)
				result = "[action == "buy" ? "Bought" : "Sold"] [round(amount)] shares of [company.ticker]."
		if("take_short")
			var/datum/stock_short/offer = locateUID(params["ref"])
			if(!istype(offer))
				return
			result = SSstock_market.take_short(account, offer, terminal) || "Borrowed [offer.shares] shares of [offer.company.ticker]."
		if("return_short")
			var/datum/stock_short/short = locateUID(params["ref"])
			if(!istype(short) || short.borrower != SSstock_market.get_portfolio(account))
				return
			var/ticker = short.company.ticker
			if(SSstock_market.return_short(short))
				result = "Short position on [ticker] closed."
			else
				result = "You do not hold enough shares of [ticker] to return all of them."
		if("loan")
			result = SSstock_market.take_loan(account, text2num(params["amount"]), terminal) || "Margin loan granted."
		if("repay")
			result = SSstock_market.repay_loan(account, text2num(params["amount"]), terminal) || "Debt repaid."
	status_message = result
	if(for_department)
		var/datum/stock_portfolio/portfolio = SSstock_market.get_portfolio(account)
		if(length(portfolio.trade_log) && portfolio.trade_log[1] != old_first)
			portfolio.trade_log[1] += " By [personal.owner_name]."

/obj/machinery/computer/stock_exchange/proc/login(mob/user)
	if(issilicon(user))
		status_message = "Synthetic units cannot hold shares."
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
		var/pin = tgui_input_number(user, "Enter the PIN of your account", "Galactic Exchange", 0, 999999, 0)
		if(isnull(pin) || !attempt_account_access(account.account_number, pin, 2))
			status_message = "Incorrect PIN."
			return
	if(account.suspended)
		status_message = "This account is suspended."
		return
	logged_account = account
	logged_user = WEAKREF(user)
	var/list/access = id.GetAccess()
	payable_departments = list()
	for(var/department in GLOB.trade_department_spenders)
		for(var/needed in GLOB.trade_department_spenders[department])
			if(needed in access)
				payable_departments += department
				break
	acting_department = null
	status_message = "Welcome, [account.owner_name]."

/obj/item/circuitboard/stock_exchange
	board_name = "Stock Exchange Console"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/stock_exchange
	origin_tech = "programming=2"

/datum/design/stock_exchange
	name = "Console Board (Stock Exchange Console)"
	desc = "Allows for the construction of circuit boards used to build a stock exchange console."
	id = "stock_exchange"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/stock_exchange
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)
