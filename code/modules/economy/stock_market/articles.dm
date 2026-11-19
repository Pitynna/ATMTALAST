// News articles about listed companies.

/datum/stock_article
	var/headline = "Markets hold their breath"
	var/subtitle = ""
	var/body = ""
	var/author = ""
	var/outlet = ""
	/// Station time it was published at.
	var/time_text = ""
	/// From -5 (awful) to 5 (great). Only for flavour in the UI.
	var/opinion = 0
	/// Ticker of the company it is about, if any.
	var/ticker
	/// See STOCK_NEWS_* defines.
	var/importance = STOCK_NEWS_MINOR

/datum/stock_article/New(datum/stock_company/about)
	. = ..()
	if(about)
		ticker = about.ticker
	outlet = pick_outlet()
	author = pick_author(outlet)

/// Outlets are made once per round so their names repeat and feel like real papers.
/datum/stock_article/proc/pick_outlet()
	var/static/list/outlets
	if(!outlets)
		outlets = list()
		// Places in the genitive case.
		var/list/places = list("Тау Кита", "Кеплера", "Проксимы", "Веги", "Альтаира", "Сириуса", "Барнарда", "Глизе", "Лейтена", "Росса", "Эпсилона", "Лагранжа")
		var/list/papers = list("Вестник", "Курьер", "Обозреватель", "Бюллетень", "Страж", "Телеграф", "Меркурий", "Глашатай")
		var/list/papers_lower = list("вестник", "курьер", "обозреватель", "бюллетень", "страж", "телеграф", "меркурий", "глашатай")
		var/list/adjectives = list("Орбитальный", "Межзвёздный", "Коммерческий", "Вечерний", "Свободный", "Независимый", "Деловой")
		for(var/i in 1 to 6)
			var/outlet_name
			switch(rand(1, 3))
				if(1)
					outlet_name = "[pick(papers)] [pick(places)]"
				if(2)
					outlet_name = "[pick(adjectives)] [pick(papers_lower)]"
				if(3)
					outlet_name = "[pick(adjectives)] [pick(papers_lower)] [pick(places)]"
			outlets[outlet_name] = list()
	return pick(outlets)

/datum/stock_article/proc/pick_author(outlet_name)
	var/static/list/authors_by_outlet = list()
	var/list/authors = authors_by_outlet[outlet_name]
	if(!authors)
		authors = list()
		authors_by_outlet[outlet_name] = authors
	if(length(authors) < 3 && (!length(authors) || prob(40)))
		var/full_name = random_name(pick(MALE, FEMALE))
		var/list/parts = splittext(full_name, " ")
		authors += length(parts) > 1 ? "[copytext_char(parts[1], 1, 2)]. [parts[length(parts)]]" : full_name
	return pick(authors)

/datum/stock_article/proc/ui_entry()
	return list(
		"headline" = headline,
		"subtitle" = subtitle,
		"body" = body,
		"author" = author,
		"outlet" = outlet,
		"time" = time_text,
		"opinion" = opinion,
		"ticker" = ticker,
	)

/// Fills %tokens% of a template from an assoc list.
/proc/stock_fill(template, list/tokens)
	. = template
	for(var/token in tokens)
		. = replacetext(., "%[token]%", "[tokens[token]]")

/// Tokens every company article can use.
/datum/stock_company/proc/article_tokens(product)
	return list(
		"company" = name,
		"ticker" = ticker,
		"field" = industry.field,
		"customers" = pick(industry.customers),
		"product" = product || pick(products),
	)
