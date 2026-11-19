// Links between the exchange and other news: Nyx Daily economic events move prices,
// and the Gibson Gazette prints rumours about trouble before it is public.

// MARK: Nyx Daily economic events

/// Companies whose goods became dearer gain, those whose goods became cheaper lose.
/datum/controller/subsystem/stock_market/proc/economic_news(list/dearer, list/cheaper, place)
	var/list/gainers = list()
	var/list/losers = list()
	for(var/datum/stock_company/company as anything in companies)
		var/score = length(company.industry.news_topics & dearer) - length(company.industry.news_topics & cheaper)
		if(!score)
			continue
		company.affect_opinion(score * rand(10, 25) / 10)
		if(score > 0)
			gainers += company.ticker
		else
			losers += company.ticker
	if(!length(gainers) && !length(losers))
		return
	var/datum/stock_article/article = new
	article.headline = "Рынки реагируют на события: [place]"
	article.subtitle = "Сообщение «[NEWS_CHANNEL_NYX]» сдвинуло котировки"
	var/list/lines = list()
	if(length(gainers))
		lines += "Трейдеры скупают [english_list(gainers, and_text = " и ")] в надежде на рост спроса."
	if(length(losers))
		lines += "[english_list(losers, and_text = " и ")] дешеве[length(losers) == 1 ? "ет" : "ют"] вслед за ценами на их товары."
	article.body = lines.Join(" ")
	article.opinion = length(gainers) >= length(losers) ? 1 : -1
	publish(article)

/// Goods in the news get dearer or cheaper until the next market shift.
/datum/controller/subsystem/trade/proc/economic_news(list/dearer, list/cheaper)
	for(var/commodity_type in commodities)
		var/datum/commodity/commodity = commodities[commodity_type]
		var/score = length(commodity.news_topics & dearer) - length(commodity.news_topics & cheaper)
		if(!score)
			continue
		var/mult = score > 0 ? rand(115, 140) / 100 : rand(70, 88) / 100
		commodity.price = max(1, round(commodity.price * mult, commodity.base_price < 10 ? 0.1 : 1))
		if(length(commodity.history))
			commodity.history[length(commodity.history)] = commodity.price
		for(var/datum/trader/trader as anything in traders)
			for(var/datum/trade_offer/offer as anything in trader.buying)
				if(offer.commodity_type == commodity_type && !offer.haggled)
					offer.reprice()

// MARK: Gibson Gazette rumours

#define RUMOUR_SCANDAL "scandal"
#define RUMOUR_BANKRUPTCY "bankruptcy"

/// Most hidden troubles leak to the tabloids before they become news.
/datum/controller/subsystem/stock_market/proc/maybe_leak(datum/stock_event/event, kind)
	if(!prob(65))
		return
	var/delay = max(30 SECONDS, (event.next_phase - world.time) * rand(20, 70) / 100)
	addtimer(CALLBACK(src, PROC_REF(post_rumour), event.company, kind), delay)

/// Now and then the tabloids get it wrong.
/datum/controller/subsystem/stock_market/proc/maybe_false_rumour()
	if(!prob(3) || !length(companies))
		return
	post_rumour(pick(companies), pick(RUMOUR_SCANDAL, RUMOUR_BANKRUPTCY))

/datum/controller/subsystem/stock_market/proc/post_rumour(datum/stock_company/company, kind)
	if(QDELETED(company) || company.bankrupt)
		return
	var/static/list/scandal_lines = list(
		"Шёпот из переговорной: кое-кому на самом верху в %company% скоро предстоит беседа с корпоративной полицией. Вы этого от нас не слышали!",
		"Наш крот в %company% сообщает: шредеры работали всю ночь. Что они скрывают?",
		"Большой начальник из %company% вот-вот слетит с кресла? Три независимых источника говорят — да! В %company% от комментариев отказались!",
	)
	var/static/list/bankruptcy_lines = list(
		"В %company% скоро погасят свет? Инсайдеры говорят: кредиторы кружат, а касса ПУСТА!",
		"У штаб-квартиры %company% замечены судебные приставы! Наши источники уверяют: компании нечем платить по счетам!",
		"Говорят, %company% берёт в долг, чтобы выплатить зарплаты. Долго ли так протянется?",
	)
	var/text = pick(kind == RUMOUR_BANKRUPTCY ? bankruptcy_lines : scandal_lines)
	text = replacetext(text, "%company%", "[company.name] ([company.ticker])")
	var/datum/feed_message/message = new
	message.author = pick("Анонимный информатор", "Наш осведомлённый источник", EDITOR_GIB)
	message.title = pick("СЛУХИ", "ВЫ УСЛЫШАЛИ ЭТО ПЕРВЫМИ", "ИЗ ДОСТОВЕРНЫХ ИСТОЧНИКОВ", "ШЁПОТОМ")
	message.body = text
	message.admin_locked = TRUE
	var/datum/feed_channel/channel = GLOB.news_network.get_channel_by_name(NEWS_CHANNEL_GIB)
	if(!channel)
		return
	channel.add_message(message)
	for(var/obj/machinery/newscaster/newscaster as anything in GLOB.allNewscasters)
		newscaster.alert_news(NEWS_CHANNEL_GIB)

#undef RUMOUR_SCANDAL
#undef RUMOUR_BANKRUPTCY
