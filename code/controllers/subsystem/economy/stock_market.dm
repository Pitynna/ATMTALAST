// Galactic stock exchange. Idea from Goonstation 13, code written anew.

SUBSYSTEM_DEF(stock_market)
	name = "Stock market"
	wait = 30 SECONDS
	runlevels = RUNLEVEL_GAME
	ss_flags = SS_BACKGROUND | SS_KEEP_TIMING

	/// Listed companies.
	var/list/datum/stock_company/companies = list()
	/// Companies that crashed this round, kept for the record.
	var/list/datum/stock_company/delisted = list()
	/// Latest articles, newest first.
	var/list/datum/stock_article/articles = list()
	/// Account number (as text) -> portfolio.
	var/list/portfolios = list()
	/// Broker names, made once per round.
	var/list/brokers = list()
	var/next_company_id = 1
	/// Set on the first tick of the round.
	var/round_started = FALSE

/datum/controller/subsystem/stock_market/Initialize()
	generate_brokers()
	for(var/i in 1 to STOCK_COMPANY_COUNT)
		var/datum/stock_company/company = create_company()
		// Fill the chart so it is not empty at round start.
		for(var/j in 1 to STOCK_HISTORY_LENGTH)
			company.tick(TRUE)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/stock_market/fire(resumed)
	if(!round_started)
		// The lobby may last long, so company events are timed from the round start.
		round_started = TRUE
		for(var/datum/stock_company/company as anything in companies)
			company.next_product_time = world.time + rand(3, 12) MINUTES
			company.next_report_time = world.time + rand(8, 20) MINUTES
			company.next_scandal_time = world.time + rand(20, 60) MINUTES
	for(var/datum/stock_company/company as anything in companies.Copy())
		company.tick()
		process_broker_offers(company)
	for(var/key in portfolios)
		var/datum/stock_portfolio/portfolio = portfolios[key]
		process_shorts(portfolio)
		process_loan(portfolio)
		portfolio.collect_overdue()

// MARK: Companies

/datum/controller/subsystem/stock_market/proc/create_company()
	var/industry_type = pick(subtypesof(/datum/stock_industry))
	var/datum/stock_industry/industry = new industry_type
	var/datum/stock_company/company = new(industry)
	company.name = generate_company_name(industry)
	company.ticker = generate_ticker(company.name)
	company.desc = "[company.name] works in the [industry.field] business and sells to [pick(industry.customers)]. Known for [english_list(company.products)]."
	company.id = "[next_company_id++]"
	companies += company
	return company

/datum/controller/subsystem/stock_market/proc/generate_company_name(datum/stock_industry/industry)
	var/static/list/surnames = list("Halvorsen", "Okafor", "Varga", "Lindqvist", "Moreau", "Tanaka", "Brandt", "Kowalski", "Achebe", "Rourke", "Delacroix", "Sato", "Novak", "Ferreira", "Iversen", "Castellan", "Abara", "Quill", "Marsh", "Tolland")
	var/static/list/prefixes = list("Astra", "Nova", "Helio", "Orbi", "Strato", "Quasar", "Zenith", "Vector", "Polar", "Meridian", "Cobalt", "Argent", "Obsidian", "Halcyon", "Kestrel", "Tycho", "Lagrange", "Perihelion")
	var/static/list/places = list("Tau Ceti", "Kepler", "Proxima", "Vega", "Altair", "Sirius", "Barnard", "Gliese", "Luyten", "Ross", "Wolf", "Epsilon")
	var/static/list/corp = list("Inc.", "Ltd", "Group", "Consortium", "Cooperative", "Interstellar", "Holdings", "& Partners")
	for(var/attempt in 1 to 20)
		var/company_name
		switch(rand(1, 5))
			if(1)
				company_name = "[pick(surnames)] [pick(industry.company_words)]"
			if(2)
				company_name = "[pick(prefixes)] [pick(industry.company_words)]"
			if(3)
				company_name = "[pick(places)] [pick(industry.company_words)] [pick(corp)]"
			if(4)
				company_name = "[pick(surnames)] & [pick(surnames)]"
			if(5)
				company_name = "[pick(prefixes)][lowertext(pick(industry.product_nouns))] [pick(corp)]"
		var/taken = FALSE
		for(var/datum/stock_company/other as anything in companies + delisted)
			if(other.name == company_name)
				taken = TRUE
				break
		if(!taken)
			return company_name
	return "[pick(prefixes)] [pick(industry.company_words)] [next_company_id]"

/datum/controller/subsystem/stock_market/proc/generate_ticker(company_name)
	var/list/words = splittext(company_name, " ")
	var/symbol = ""
	for(var/word in words)
		var/first = copytext(word, 1, 2)
		if(findtext(first, regex("\[A-Za-z]")) && length(symbol) < 4)
			symbol += uppertext(first)
	var/first_word = uppertext(words[1])
	var/letter = 2
	while(length(symbol) < 3 && letter <= length(first_word))
		var/char = copytext(first_word, letter, letter + 1)
		if(findtext(char, regex("\[A-Z]")))
			symbol += char
		letter++
	while(length(symbol) < 3)
		symbol += ascii2text(rand(65, 90))
	var/base = symbol
	while(ticker_taken(symbol))
		symbol = copytext(base, 1, 3) + ascii2text(rand(65, 90))
	return symbol

/datum/controller/subsystem/stock_market/proc/ticker_taken(symbol)
	for(var/datum/stock_company/other as anything in companies + delisted)
		if(other.ticker == symbol)
			return TRUE
	return FALSE

/datum/controller/subsystem/stock_market/proc/get_company(id)
	for(var/datum/stock_company/company as anything in companies)
		if(company.id == id)
			return company

/// Removes a crashed company. Its shares are lost, short positions on it are closed in favour of the borrower.
/datum/controller/subsystem/stock_market/proc/delist(datum/stock_company/company)
	company.bankrupt = TRUE
	company.price = 0
	companies -= company
	delisted += company
	QDEL_LIST_CONTENTS(company.broker_offers)
	for(var/key in portfolios)
		var/datum/stock_portfolio/portfolio = portfolios[key]
		for(var/datum/stock_short/short as anything in portfolio.shorts.Copy())
			if(short.company != company)
				continue
			portfolio.shorts -= short
			var/datum/money_account/account = portfolio.get_account()
			account?.credit(short.deposit_paid, "Short deposit returned, [company.ticker] delisted", "Galactic Exchange", "Galactic Exchange")
			portfolio.add_log("[company.ticker] delisted, short from [short.broker] closed, deposit of [short.deposit_paid] cr returned.")
			qdel(short)
		var/lost = portfolio.held(company)
		if(lost)
			portfolio.remove_shares(company, lost)
			portfolio.add_log("[company.ticker] delisted, [lost] shares cancelled.")
			portfolio.notify("[company.name] collapsed, your [lost] shares of [company.ticker] are cancelled.")

	var/datum/stock_company/newcomer = create_company()
	for(var/j in 1 to 10)
		newcomer.tick(TRUE)
	var/datum/stock_article/article = new(newcomer)
	article.headline = "[newcomer.name] lists on the exchange"
	article.subtitle = "Shares of [newcomer.ticker] open at [newcomer.price] cr"
	article.body = "[newcomer.name], a [newcomer.industry.field] company, takes the place of [company.name] on the exchange. [newcomer.desc]"
	article.opinion = 1
	article.importance = STOCK_NEWS_POSTED
	publish(article)

// MARK: News

/datum/controller/subsystem/stock_market/proc/publish(datum/stock_article/article)
	article.time_text = station_time_timestamp("hh:mm")
	articles.Insert(1, article)
	if(length(articles) > STOCK_NEWS_LENGTH)
		articles.Cut(STOCK_NEWS_LENGTH + 1)
	if(article.importance < STOCK_NEWS_POSTED)
		return
	var/datum/feed_channel/channel = get_news_channel()
	var/datum/feed_message/message = new
	message.author = article.outlet
	message.title = article.headline
	message.body = "[article.subtitle]. [article.body] ([article.author], [article.outlet])"
	message.admin_locked = TRUE
	channel.add_message(message)
	if(article.importance < STOCK_NEWS_ALERT)
		return
	for(var/obj/machinery/newscaster/newscaster as anything in GLOB.allNewscasters)
		newscaster.alert_news(NEWS_CHANNEL_STOCKS)

/datum/controller/subsystem/stock_market/proc/get_news_channel()
	var/datum/feed_channel/channel = GLOB.news_network.get_channel_by_name(NEWS_CHANNEL_STOCKS)
	if(channel)
		return channel
	channel = new
	channel.channel_name = NEWS_CHANNEL_STOCKS
	channel.author = EDITOR_STOCKS
	channel.description = "Market news from across the galaxy: product launches, scandals and crashes."
	channel.icon = "chart-line"
	channel.frozen = TRUE
	channel.admin_locked = TRUE
	GLOB.news_network.channels += channel
	return channel

// MARK: Portfolios and trading

/datum/controller/subsystem/stock_market/proc/get_portfolio(datum/money_account/account, create = TRUE)
	var/key = "[account.account_number]"
	var/datum/stock_portfolio/portfolio = portfolios[key]
	if(!portfolio && create)
		portfolio = new(account)
		portfolios[key] = portfolio
	return portfolio

/datum/controller/subsystem/stock_market/proc/trade_fee(total)
	return max(STOCK_MIN_FEE, round(total * STOCK_TRADE_FEE / 100))

/// Returns null on success or the reason the deal failed.
/datum/controller/subsystem/stock_market/proc/buy(datum/money_account/account, datum/stock_company/company, amount, terminal)
	amount = round(amount)
	if(amount <= 0 || amount > STOCK_MAX_ORDER)
		return "Orders must be from 1 to [STOCK_MAX_ORDER] shares."
	if(company.bankrupt)
		return "[company.ticker] is not traded."
	if(account.suspended)
		return "Account suspended."
	var/datum/stock_portfolio/portfolio = get_portfolio(account)
	if(portfolio.overdue_debt > 0)
		return "Pay off your overdue debt of [round(portfolio.overdue_debt)] cr first."
	var/total = company.quote(amount, TRUE)
	var/fee = trade_fee(total)
	if(account.money < total + fee)
		return "Not enough credits: [total + fee] cr needed."
	account.charge(total + fee, null, "Bought [amount] shares of [company.ticker]", terminal, "Galactic Exchange")
	company.apply_trade(amount, TRUE)
	portfolio.add_shares(company, amount, total)
	portfolio.add_log("Bought [amount] [company.ticker] for [total] cr (fee [fee] cr).")

/datum/controller/subsystem/stock_market/proc/sell(datum/money_account/account, datum/stock_company/company, amount, terminal)
	amount = round(amount)
	if(amount <= 0 || amount > STOCK_MAX_ORDER)
		return "Orders must be from 1 to [STOCK_MAX_ORDER] shares."
	if(company.bankrupt)
		return "[company.ticker] is not traded."
	var/datum/stock_portfolio/portfolio = get_portfolio(account)
	if(portfolio.held(company) < amount)
		return "You only hold [portfolio.held(company)] shares of [company.ticker]."
	var/total = company.quote(amount, FALSE)
	var/fee = trade_fee(total)
	company.apply_trade(amount, FALSE)
	portfolio.remove_shares(company, amount)
	var/income = max(0, total - fee)
	account.credit(income, "Sold [amount] shares of [company.ticker]", terminal, "Galactic Exchange")
	portfolio.add_log("Sold [amount] [company.ticker] for [total] cr (fee [fee] cr).")
	portfolio.collect_overdue()

// MARK: Short selling

/datum/controller/subsystem/stock_market/proc/generate_brokers()
	var/static/list/surnames = list("Ashgrove", "Bellweather", "Crane", "Draycott", "Everhart", "Fairbanks", "Grimsby", "Hollis", "Kingsley", "Merriweather", "Pemberton", "Radcliffe", "Sterling", "Thorne", "Whitlock")
	var/static/list/places = list("Tau Ceti", "Kepler", "Proxima", "Vega", "Altair", "Sirius", "Luyten", "Ross")
	var/static/list/firms = list("Securities", "Capital", "Brokerage", "Trust", "& Sons", "Partners", "Exchange House", "Investments")
	while(length(brokers) < 6)
		var/broker_name
		switch(rand(1, 3))
			if(1)
				broker_name = "[pick(surnames)] [pick(firms)]"
			if(2)
				broker_name = "[pick(surnames)] & [pick(surnames)]"
			if(3)
				broker_name = "[pick(places)] [pick(firms)]"
		brokers |= broker_name

/datum/controller/subsystem/stock_market/proc/process_broker_offers(datum/stock_company/company)
	for(var/datum/stock_short/offer as anything in company.broker_offers.Copy())
		if(world.time > offer.offer_expires)
			company.broker_offers -= offer
			qdel(offer)
	if(company.bankrupt || length(company.broker_offers) >= STOCK_MAX_BROKER_OFFERS)
		return
	if(prob(4))
		company.broker_offers += new /datum/stock_short(company, pick(brokers))

/datum/controller/subsystem/stock_market/proc/take_short(datum/money_account/account, datum/stock_short/offer, terminal)
	var/datum/stock_company/company = offer.company
	if(offer.borrower || !(offer in company.broker_offers))
		return "This offer is no longer available."
	if(account.suspended)
		return "Account suspended."
	var/datum/stock_portfolio/portfolio = get_portfolio(account)
	if(portfolio.overdue_debt > 0)
		return "Pay off your overdue debt of [round(portfolio.overdue_debt)] cr first."
	var/deposit = offer.deposit_quote()
	if(account.money < deposit)
		return "Not enough credits: the deposit is [deposit] cr."
	account.charge(deposit, null, "Deposit for [offer.shares] borrowed shares of [company.ticker]", terminal, offer.broker)
	company.broker_offers -= offer
	offer.borrower = portfolio
	offer.deposit_paid = deposit
	offer.lease_expires = world.time + offer.lease_time
	offer.grace_expires = offer.lease_expires + offer.grace_time
	portfolio.shorts += offer
	portfolio.add_shares(company, offer.shares, round(offer.shares * company.price))
	portfolio.add_log("Borrowed [offer.shares] [company.ticker] from [offer.broker], deposit [deposit] cr.")

/// Gives back as many borrowed shares as the portfolio holds. Returns TRUE if the short is closed.
/datum/controller/subsystem/stock_market/proc/return_short(datum/stock_short/short)
	var/datum/stock_portfolio/portfolio = short.borrower
	var/returned = portfolio.remove_shares(short.company, short.debt_shares)
	short.debt_shares -= returned
	if(returned)
		portfolio.add_log("Returned [returned] [short.company.ticker] to [short.broker].")
	if(short.debt_shares > 0)
		return FALSE
	portfolio.shorts -= short
	var/datum/money_account/account = portfolio.get_account()
	account?.credit(short.deposit_paid, "Deposit returned for [short.shares] shares of [short.company.ticker]", "Galactic Exchange", short.broker)
	portfolio.add_log("Short from [short.broker] closed, deposit of [short.deposit_paid] cr returned.")
	qdel(short)
	return TRUE

/datum/controller/subsystem/stock_market/proc/process_shorts(datum/stock_portfolio/portfolio)
	for(var/datum/stock_short/short as anything in portfolio.shorts.Copy())
		if(world.time < short.lease_expires)
			continue
		if(return_short(short))
			continue
		if(world.time < short.grace_expires)
			continue
		// Out of time: the missing shares are bought back at market price, the deposit counts towards it.
		var/datum/stock_company/company = short.company
		var/cost = round(short.debt_shares * company.price)
		var/owed = max(0, cost - short.deposit_paid)
		portfolio.shorts -= short
		portfolio.add_log("Failed to return [short.debt_shares] [company.ticker] to [short.broker]: charged [cost] cr minus the deposit.")
		portfolio.notify("You did not return [short.debt_shares] shares of [company.ticker] to [short.broker]. [owed] cr charged.")
		portfolio.force_charge(owed, "Unreturned shares of [company.ticker]")
		qdel(short)

// MARK: Margin loans

/datum/controller/subsystem/stock_market/proc/take_loan(datum/money_account/account, amount, terminal)
	amount = round(amount)
	if(amount <= 0)
		return "Enter a positive amount."
	if(account.suspended)
		return "Account suspended."
	var/datum/stock_portfolio/portfolio = get_portfolio(account)
	if(portfolio.overdue_debt > 0)
		return "Pay off your overdue debt of [round(portfolio.overdue_debt)] cr first."
	var/limit = portfolio.max_loan()
	if(amount > limit)
		return "You can borrow at most [limit] cr against your shares."
	portfolio.loan_debt += amount
	account.credit(amount, "Margin loan", terminal, "Galactic Exchange")
	portfolio.add_log("Took a margin loan of [amount] cr.")

/datum/controller/subsystem/stock_market/proc/repay_loan(datum/money_account/account, amount, terminal)
	var/datum/stock_portfolio/portfolio = get_portfolio(account)
	amount = min(round(amount), ceil(portfolio.loan_debt + portfolio.overdue_debt))
	if(amount <= 0)
		return "Nothing to repay."
	if(account.money < amount)
		return "Not enough credits."
	account.charge(amount, null, "Exchange debt repayment", terminal, "Galactic Exchange")
	var/to_overdue = min(amount, portfolio.overdue_debt)
	portfolio.overdue_debt -= to_overdue
	portfolio.loan_debt = max(0, portfolio.loan_debt - (amount - to_overdue))
	portfolio.add_log("Repaid [amount] cr of debt.")

/// Adds interest and sells shares when the debt grows too large for the collateral.
/datum/controller/subsystem/stock_market/proc/process_loan(datum/stock_portfolio/portfolio)
	if(portfolio.loan_debt <= 0)
		return
	portfolio.loan_debt *= 1 + STOCK_LOAN_INTEREST / 100
	var/collateral = portfolio.collateral_value()
	if(portfolio.loan_debt <= collateral * STOCK_LOAN_MARGIN_CALL)
		return
	// Margin call: sell own shares, most valuable first, until the debt is back under the limit.
	var/list/positions = list()
	for(var/datum/stock_company/company as anything in companies)
		var/own = portfolio.held(company) - portfolio.borrowed(company)
		if(own > 0)
			positions[company] = own * company.price
	sortTim(positions, GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)
	var/sold_total = 0
	for(var/datum/stock_company/company as anything in positions)
		if(portfolio.loan_debt <= portfolio.collateral_value() * STOCK_LOAN_LTV)
			break
		var/own = portfolio.held(company) - portfolio.borrowed(company)
		var/excess = portfolio.loan_debt - portfolio.collateral_value() * STOCK_LOAN_LTV
		// Selling a share lowers both the debt and the collateral, so sell a bit more than the gap.
		var/amount = min(own, STOCK_MAX_ORDER, ceil(excess / (company.price * (1 - STOCK_LOAN_LTV))) + 1)
		var/total = company.quote(amount, FALSE)
		var/income = max(0, total - trade_fee(total))
		company.apply_trade(amount, FALSE)
		portfolio.remove_shares(company, amount)
		portfolio.loan_debt -= income
		sold_total += income
		portfolio.add_log("Margin call: sold [amount] [company.ticker] for [income] cr.")
	if(portfolio.loan_debt < 0)
		var/datum/money_account/account = portfolio.get_account()
		account?.credit(round(-portfolio.loan_debt), "Margin call surplus", "Galactic Exchange", "Galactic Exchange")
		portfolio.loan_debt = 0
	else if(portfolio.collateral_value() <= 0)
		// Nothing left to sell: the rest is owed directly.
		portfolio.overdue_debt += round(portfolio.loan_debt)
		portfolio.loan_debt = 0
	if(sold_total)
		portfolio.notify("Margin call! Shares worth [sold_total] cr were sold to cover your loan.")
