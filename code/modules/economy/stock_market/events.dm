// Multi-phase company events. Each phase may publish an article and move the price.

/datum/stock_event
	var/datum/stock_company/company
	/// See STOCK_EVENT_* defines.
	var/state = STOCK_EVENT_HIDDEN
	/// Shown on the company page while the event is visible.
	var/title = ""
	var/desc = ""
	/// world.time of the next phase.
	var/next_phase = 0
	var/phase = 0

/datum/stock_event/New(datum/stock_company/owner)
	. = ..()
	company = owner
	setup()

/datum/stock_event/Destroy(force)
	company = null
	return ..()

/datum/stock_event/proc/setup()
	return

/datum/stock_event/proc/advance()
	if(state == STOCK_EVENT_DONE || world.time < next_phase)
		return
	phase++
	transition()

/datum/stock_event/proc/transition()
	state = STOCK_EVENT_DONE

/datum/stock_event/proc/finish()
	state = STOCK_EVENT_DONE
	title = ""
	desc = ""

/datum/stock_event/proc/when(time)
	return station_time_timestamp("hh:mm", time)

/datum/stock_event/proc/publish(headline, subtitle, body, opinion, importance = STOCK_NEWS_MINOR, list/extra_tokens)
	var/datum/stock_article/article = new(company)
	var/list/tokens = company.article_tokens()
	if(extra_tokens)
		for(var/key in extra_tokens)
			tokens[key] = extra_tokens[key]
	tokens["outlet"] = article.outlet
	tokens["author"] = article.author
	article.headline = stock_fill(headline, tokens)
	article.subtitle = stock_fill(subtitle, tokens)
	article.body = stock_fill(body, tokens)
	article.opinion = opinion
	article.importance = importance
	SSstock_market.publish(article)
	return article

// MARK: Product launch
/// Showcase is announced, reviews come in, then sales figures decide how it went.
/datum/stock_event/product
	var/product_name
	/// Review score from -3 to 3, picked when the product is shown.
	var/quality = 0

/datum/stock_event/product/setup()
	state = STOCK_EVENT_VISIBLE
	next_phase = world.time + rand(4, 8) MINUTES
	title = "Upcoming product showcase"
	desc = "[company.name] will present a new [company.industry.field] product at [when(next_phase)] station time."

/datum/stock_event/product/transition()
	var/static/list/good = list(
		"%product% by %company% could shake up the %field% market",
		"Reviewers can't put down the %product%",
		"%company% hits it out of the park with %product%",
	)
	var/static/list/neutral = list(
		"%product%: solid, safe and a little dull",
		"%company% shows %product%, %customers% shrug",
		"Mixed first looks at the %product%",
	)
	var/static/list/bad = list(
		"%product% is shaping up to be a flop",
		"Early units of %product% fall apart in testing",
		"%company% showcase ends in awkward silence",
	)
	switch(phase)
		if(1)
			product_name = company.industry.generate_product_name()
			quality = pick(-3, -2, -1, 0, 0, 1, 1, 2, 3)
			var/list/tokens = list("product" = product_name)
			var/headline = pick(quality > 0 ? good : (quality < 0 ? bad : neutral))
			var/body
			if(quality > 0)
				body = "%company% unveiled %product% to a packed hall. %author% of %outlet% calls it \"the best thing in %field% this year\", and %customers% are already asking about pre-orders."
			else if(quality < 0)
				body = "%company% unveiled %product% to a half-empty hall. Demo units overheated twice, and %author% of %outlet% advises %customers% to wait for a second revision."
			else
				body = "%company% unveiled %product%. It does what it says, and not much else. %author% of %outlet% expects steady but unremarkable sales."
			publish(headline, "Hands-on with the %product%", body, quality, abs(quality) >= 3 ? STOCK_NEWS_POSTED : STOCK_NEWS_MINOR, tokens)
			company.affect_opinion(quality / 2)
			next_phase = world.time + rand(5, 10) MINUTES
			title = "Product release: [product_name]"
			desc = "[product_name] goes on sale at [when(next_phase)] station time."
		if(2)
			var/result = quality + rand(-1, 1)
			var/list/tokens = list("product" = product_name)
			if(result > 0)
				publish("%product% sells out in hours", "%company% scrambles to restock", "Warehouses of %company% are empty after the first day of %product% sales. Analysts raise their forecasts for %ticker%.", result, result >= 3 ? STOCK_NEWS_POSTED : STOCK_NEWS_MINOR, tokens)
			else if(result < 0)
				publish("%product% gathers dust on shelves", "Retailers ask %company% for refunds", "Sales of %product% fall far below what %company% promised its investors. Some stores already send units back.", result, result <= -3 ? STOCK_NEWS_POSTED : STOCK_NEWS_MINOR, tokens)
			else
				publish("%product% sales meet expectations", "No surprises from %company%", "%product% is selling about as well as expected. Neither bulls nor bears got what they wanted.", 0, STOCK_NEWS_MINOR, tokens)
			company.affect_opinion(result * 1.5)
			company.products |= product_name
			company.next_product_time = world.time + rand(10, 20) MINUTES
			finish()

// MARK: Quarterly report
/datum/stock_event/report
	state = STOCK_EVENT_HIDDEN

/datum/stock_event/report/setup()
	next_phase = world.time + rand(1, 3) MINUTES

/datum/stock_event/report/transition()
	var/score = clamp(round(company.trend + rand(-15, 15) / 10), -3, 3)
	var/list/tokens = list("profit" = "[rand(2, 90)].[rand(0, 9)] million")
	if(score > 0)
		publish("%company% beats forecasts", "Quarterly profit of %profit% credits", "%company% reported a quarterly profit of %profit% credits, ahead of what analysts expected. Demand from %customers% stays strong.", score, STOCK_NEWS_MINOR, tokens)
	else if(score < 0)
		publish("%company% misses targets", "Quarterly results disappoint", "%company% reported weaker results than promised and blamed slow demand from %customers%. The board says the next quarter will be better.", score, STOCK_NEWS_MINOR, tokens)
	else
		publish("%company% reports a flat quarter", "Steady as she goes", "%company% earned about as much as last quarter. Analysts keep their ratings on %ticker% unchanged.", 0, STOCK_NEWS_MINOR, tokens)
	company.affect_opinion(score)
	finish()

// MARK: Executive scandal
/// An executive is arrested, then a trial decides how bad it was.
/datum/stock_event/scandal
	var/executive
	var/position
	var/crime
	var/guilty = FALSE

/datum/stock_event/scandal/setup()
	next_phase = world.time + rand(4, 8) MINUTES
	SSstock_market.maybe_leak(src, "scandal")
	executive = random_news_name()
	position = pick("chief executive", "chief financial officer", "head of research", "board chair", "head of sales")
	crime = pick("insider trading", "bribing a customs inspector", "smuggling contraband", "cooking the books", "selling trade secrets to a rival", "skipping safety inspections", "tax evasion on three planets")
	guilty = prob(60)

/datum/stock_event/scandal/transition()
	var/list/tokens = list("executive" = executive, "position" = position, "crime" = crime)
	switch(phase)
		if(1)
			publish("%company% %position% arrested", "%executive% charged with %crime%", "Corporate police took %executive%, %position% of %company%, into custody this morning. The charges are %crime%. %company% says it is cooperating fully.", -3, STOCK_NEWS_POSTED, tokens)
			company.affect_opinion(-rand(2, 4))
			state = STOCK_EVENT_VISIBLE
			next_phase = world.time + rand(8, 12) MINUTES
			title = "Trial of [executive]"
			desc = "The [position] of [company.name] faces charges of [crime]. Verdict expected at [when(next_phase)] station time."
		if(2)
			if(guilty)
				publish("%executive% found guilty", "%company% looks for a new %position%", "The court found %executive% guilty of %crime%. %company% faces a fine and a long audit.", -2, STOCK_NEWS_POSTED, tokens)
				company.affect_opinion(-rand(1, 3))
			else
				publish("%executive% walks free", "Charges against %company% %position% dropped", "All charges of %crime% against %executive% were dropped for lack of evidence. %company% shares are expected to recover.", 2, STOCK_NEWS_POSTED, tokens)
				company.affect_opinion(rand(2, 3))
			finish()

// MARK: Bankruptcy
/// The company files for bankruptcy. It is either bailed out or crashes and leaves the exchange.
/datum/stock_event/bankruptcy
	var/bailout_millions

/datum/stock_event/bankruptcy/setup()
	next_phase = world.time + rand(4, 8) MINUTES
	SSstock_market.maybe_leak(src, "bankruptcy")
	bailout_millions = rand(70, 190)

/datum/stock_event/bankruptcy/transition()
	var/list/tokens = list("bailout" = "[bailout_millions] million", "reason" = pick("a collapsed supply chain", "a failed product line", "years of bad loans", "a lost lawsuit", "a fraud in the accounting department", "losing its biggest customer"))
	switch(phase)
		if(1)
			publish("%company% files for bankruptcy", "Investors panic, bailout pending", "%company% can no longer pay its creditors after %reason%. A bailout of %bailout% credits is being discussed.", -5, STOCK_NEWS_ALERT, tokens)
			company.affect_opinion(-rand(4, 6))
			state = STOCK_EVENT_VISIBLE
			next_phase = world.time + rand(6, 10) MINUTES
			title = "Bankruptcy of [company.name]"
			desc = "A decision on a bailout is expected at [when(next_phase)] station time. If there is none, the shares will be worthless."
		if(2)
			var/rescue_chance = company.trend > 0 ? 80 : 55
			if(prob(rescue_chance))
				publish("%company% bailed out", "A %bailout% credit rescue package is signed", "%company% will keep trading after creditors agreed to a rescue package. Investors are cautiously optimistic.", 3, STOCK_NEWS_ALERT, tokens)
				company.affect_opinion(rand(3, 6))
				finish()
			else
				publish("%company% collapses", "Shares in %ticker% are now worthless", "No bailout came. %company% is removed from the exchange and its shares are cancelled.", -5, STOCK_NEWS_ALERT, tokens)
				finish()
				SSstock_market.delist(company)
