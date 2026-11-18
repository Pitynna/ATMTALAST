// Holdings of one bank account on the exchange, plus its short positions and margin loan.

/datum/stock_portfolio
	var/account_number
	var/owner_name = ""
	/// Company id -> shares held.
	var/list/shares = list()
	/// Company id -> credits paid for the shares held, for the average price.
	var/list/cost = list()
	/// Open short positions.
	var/list/datum/stock_short/shorts = list()
	/// Credits owed on the margin loan, interest included.
	var/loan_debt = 0
	/// Credits the exchange could not collect. Taken from the account as soon as it has money.
	var/overdue_debt = 0
	/// Latest deals, newest first.
	var/list/trade_log = list()

/datum/stock_portfolio/New(datum/money_account/account)
	. = ..()
	account_number = account.account_number
	owner_name = account.owner_name

/datum/stock_portfolio/proc/get_account()
	return attempt_account_access_nosec(account_number)

/datum/stock_portfolio/proc/add_log(text)
	trade_log.Insert(1, "[station_time_timestamp("hh:mm")] [text]")
	if(length(trade_log) > STOCK_LOG_LENGTH)
		trade_log.Cut(STOCK_LOG_LENGTH + 1)

/datum/stock_portfolio/proc/notify(text)
	var/datum/money_account/account = get_account()
	account?.notify_pda_owner("Galactic Exchange: [text]")

/datum/stock_portfolio/proc/held(datum/stock_company/company)
	return shares[company.id] || 0

/// Shares of the company still owed to brokers.
/datum/stock_portfolio/proc/borrowed(datum/stock_company/company)
	. = 0
	for(var/datum/stock_short/short as anything in shorts)
		if(short.company == company)
			. += short.debt_shares

/datum/stock_portfolio/proc/add_shares(datum/stock_company/company, amount, paid)
	shares[company.id] = held(company) + amount
	cost[company.id] = (cost[company.id] || 0) + paid

/datum/stock_portfolio/proc/remove_shares(datum/stock_company/company, amount)
	var/have = held(company)
	amount = min(amount, have)
	if(amount <= 0)
		return 0
	var/left = have - amount
	if(left <= 0)
		shares -= company.id
		cost -= company.id
	else
		shares[company.id] = left
		cost[company.id] = round(cost[company.id] * left / have)
	return amount

/// Market value of own shares, not counting borrowed ones. Margin loans are backed by it.
/datum/stock_portfolio/proc/collateral_value()
	. = 0
	for(var/datum/stock_company/company as anything in SSstock_market.companies)
		var/own = held(company) - borrowed(company)
		if(own > 0)
			. += own * company.price

/datum/stock_portfolio/proc/max_loan()
	return max(0, min(STOCK_LOAN_CAP, round(collateral_value() * STOCK_LOAN_LTV)) - round(loan_debt))

/// Takes what it can of the overdue debt from the account.
/datum/stock_portfolio/proc/collect_overdue()
	if(overdue_debt <= 0)
		return
	var/datum/money_account/account = get_account()
	if(!account || account.money <= 0)
		return
	var/taken = min(account.money, overdue_debt)
	overdue_debt -= taken
	account.set_money(account.money - taken)
	account.makeTransactionLog(taken, "Overdue exchange debt", "Galactic Exchange", "Galactic Exchange")
	add_log("Collected [taken] cr of overdue debt.")

/// Charges what the account has, the rest becomes overdue debt.
/datum/stock_portfolio/proc/force_charge(amount, purpose)
	amount = round(amount)
	if(amount <= 0)
		return
	var/datum/money_account/account = get_account()
	var/taken = account ? clamp(account.money, 0, amount) : 0
	if(taken)
		account.set_money(account.money - taken)
		account.makeTransactionLog(taken, purpose, "Galactic Exchange", "Galactic Exchange")
	if(amount > taken)
		overdue_debt += amount - taken
		add_log("[amount - taken] cr could not be paid and is now overdue.")

/datum/stock_portfolio/proc/ui_entry()
	var/list/holdings = list()
	for(var/datum/stock_company/company as anything in SSstock_market.companies)
		var/amount = held(company)
		if(!amount)
			continue
		holdings += list(list(
			"id" = company.id,
			"ticker" = company.ticker,
			"name" = company.name,
			"shares" = amount,
			"borrowed" = borrowed(company),
			"value" = round(amount * company.price),
			"avg_price" = round(cost[company.id] / amount, 0.01),
		))
	var/list/short_data = list()
	for(var/datum/stock_short/short as anything in shorts)
		short_data += list(short.ui_entry())
	return list(
		"holdings" = holdings,
		"shorts" = short_data,
		"loan_debt" = round(loan_debt),
		"max_loan" = max_loan(),
		"collateral" = round(collateral_value()),
		"overdue" = round(overdue_debt),
		"log" = trade_log,
	)

// MARK: Short selling
/**
 * A broker lends shares for a deposit. The borrower may sell them at once.
 * When the lease ends the shares are taken back from the portfolio and the deposit is returned.
 * If the borrower has not got them back by the end of the grace period, the missing shares are charged at market price.
 */
/datum/stock_short
	var/broker = ""
	var/datum/stock_company/company
	var/datum/stock_portfolio/borrower
	/// Shares lent.
	var/shares = 0
	/// Shares still to be returned.
	var/debt_shares = 0
	/// Share of the market value asked as a deposit, from 0.2 to 0.7.
	var/deposit_rate = 0.5
	/// Credits actually paid as the deposit.
	var/deposit_paid = 0
	var/lease_time = 0
	var/grace_time = 0
	var/offer_expires = 0
	var/lease_expires = 0
	var/grace_expires = 0

/datum/stock_short/New(datum/stock_company/lent_company, broker_name)
	. = ..()
	company = lent_company
	broker = broker_name
	shares = rand(1, 10) * 100
	debt_shares = shares
	deposit_rate = rand(20, 70) / 100
	lease_time = rand(15, 30) MINUTES
	grace_time = rand(3, 8) MINUTES
	offer_expires = world.time + rand(8, 15) MINUTES

/datum/stock_short/Destroy(force)
	company = null
	borrower = null
	return ..()

/datum/stock_short/proc/deposit_quote()
	return round(deposit_rate * company.price * shares)

/datum/stock_short/proc/ui_entry()
	return list(
		"ref" = UID(),
		"broker" = broker,
		"company" = company.id,
		"ticker" = company.ticker,
		"shares" = shares,
		"debt_shares" = debt_shares,
		"deposit" = borrower ? deposit_paid : deposit_quote(),
		"deposit_rate" = round(deposit_rate * 100),
		"lease_minutes" = round(lease_time / (1 MINUTES)),
		"grace_minutes" = round(grace_time / (1 MINUTES)),
		"offer_left" = borrower ? 0 : max(0, round((offer_expires - world.time) / 10)),
		"lease_left" = borrower ? max(0, round((lease_expires - world.time) / 10)) : 0,
		"grace_left" = borrower ? max(0, round((grace_expires - world.time) / 10)) : 0,
	)
