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
	title = "Презентация нового продукта"
	desc = "Компания [company.name] представит новинку в сфере [company.industry.field] в [when(next_phase)] по станционному времени."

/datum/stock_event/product/transition()
	var/static/list/good = list(
		"%product% от %company% может перевернуть рынок %field%",
		"Обозреватели не могут оторваться от %product%",
		"%company% попадает в точку с %product%",
	)
	var/static/list/neutral = list(
		"%product%: надёжно, безопасно и немного скучно",
		"%company% показывает %product%, %customers% пожимают плечами",
		"Первые отзывы о %product% неоднозначны",
	)
	var/static/list/bad = list(
		"%product% грозит стать провалом",
		"Первые образцы %product% развалились на испытаниях",
		"Презентация %company% закончилась неловкой тишиной",
	)
	switch(phase)
		if(1)
			product_name = company.industry.generate_product_name()
			quality = pick(-3, -2, -1, 0, 0, 1, 1, 2, 3)
			var/list/tokens = list("product" = product_name)
			var/headline = pick(quality > 0 ? good : (quality < 0 ? bad : neutral))
			var/body
			if(quality > 0)
				body = "Компания %company% представила %product% в переполненном зале. %author% из издания «%outlet%» называет новинку «лучшим, что случилось в сфере %field% за год», а %customers% уже спрашивают о предзаказах."
			else if(quality < 0)
				body = "Компания %company% представила %product% в полупустом зале. Демонстрационные образцы дважды перегрелись, и %author% из издания «%outlet%» советует подождать второй ревизии."
			else
				body = "Компания %company% представила %product%. Продукт делает то, что обещано, и не более. %author% из издания «%outlet%» ожидает ровных, но ничем не примечательных продаж."
			publish(headline, "Первое знакомство с %product%", body, quality, abs(quality) >= 3 ? STOCK_NEWS_POSTED : STOCK_NEWS_MINOR, tokens)
			company.affect_opinion(quality / 2)
			next_phase = world.time + rand(5, 10) MINUTES
			title = "Выход продукта: [product_name]"
			desc = "[product_name] поступит в продажу в [when(next_phase)] по станционному времени."
		if(2)
			var/result = quality + rand(-1, 1)
			var/list/tokens = list("product" = product_name)
			if(result > 0)
				publish("%product% раскупили за несколько часов", "%company% срочно пополняет склады", "Склады компании %company% опустели в первый же день продаж %product%. Аналитики повышают прогнозы по %ticker%.", result, result >= 3 ? STOCK_NEWS_POSTED : STOCK_NEWS_MINOR, tokens)
			else if(result < 0)
				publish("%product% пылится на полках", "Магазины требуют от %company% возврата денег", "Продажи %product% оказались намного ниже обещанного инвесторам. Некоторые магазины уже отправляют товар обратно в %company%.", result, result <= -3 ? STOCK_NEWS_POSTED : STOCK_NEWS_MINOR, tokens)
			else
				publish("Продажи %product% соответствуют ожиданиям", "%company% обошлась без сюрпризов", "%product% продаётся примерно так, как и ожидалось. Ни быки, ни медведи не получили желаемого.", 0, STOCK_NEWS_MINOR, tokens)
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
	var/list/tokens = list("profit" = "[rand(2, 90)],[rand(0, 9)] млн")
	if(score > 0)
		publish("%company% превзошла прогнозы", "Квартальная прибыль — %profit% кредитов", "Компания %company% отчиталась о квартальной прибыли в %profit% кредитов, выше ожиданий аналитиков. Спрос держится: %customers% продолжают закупки.", score, STOCK_NEWS_MINOR, tokens)
	else if(score < 0)
		publish("%company% не выполнила план", "Квартальные итоги разочаровали", "Компания %company% показала результаты хуже обещанных и винит слабый спрос. Совет директоров уверяет, что следующий квартал будет лучше.", score, STOCK_NEWS_MINOR, tokens)
	else
		publish("Ровный квартал для %company%", "Без резких движений", "Компания %company% заработала примерно столько же, сколько в прошлом квартале. Аналитики сохраняют рейтинги %ticker% без изменений.", 0, STOCK_NEWS_MINOR, tokens)
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
	executive = random_name(pick(MALE, FEMALE))
	position = pick("генеральный директор", "финансовый директор", "глава исследовательского отдела", "председатель совета директоров", "директор по продажам")
	crime = pick("инсайдерской торговле", "подкупе таможенного инспектора", "контрабанде", "подделке отчётности", "продаже коммерческой тайны конкуренту", "уклонении от проверок безопасности", "уклонении от налогов на трёх планетах")
	guilty = prob(60)

/datum/stock_event/scandal/transition()
	var/list/tokens = list("executive" = executive, "position" = position, "crime" = crime)
	switch(phase)
		if(1)
			publish("Арестован топ-менеджер %company%", "%executive% обвиняют в %crime%", "Сегодня утром корпоративная полиция задержала %executive% (%position%, %company%). Обвинение — в %crime%. В компании %company% заявляют, что полностью сотрудничают со следствием.", -3, STOCK_NEWS_POSTED, tokens)
			company.affect_opinion(-rand(2, 4))
			state = STOCK_EVENT_VISIBLE
			next_phase = world.time + rand(8, 12) MINUTES
			title = "Суд: [executive]"
			desc = "[capitalize(position)] компании [company.name] обвиняется в [crime]. Приговор ожидается в [when(next_phase)] по станционному времени."
		if(2)
			if(guilty)
				publish("Обвинительный приговор по делу %company%", "Компания ищет нового руководителя", "Суд вынес обвинительный приговор по делу о %crime%, %executive% отправляется за решётку. Компанию %company% ждут штраф и долгий аудит.", -2, STOCK_NEWS_POSTED, tokens)
				company.affect_opinion(-rand(1, 3))
			else
				publish("Оправдательный приговор по делу %company%", "Обвинения против руководства сняты", "Обвинения в %crime% сняты за недостатком улик, %executive% выходит на свободу. Ожидается, что акции %company% отыграют падение.", 2, STOCK_NEWS_POSTED, tokens)
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
	var/list/tokens = list("bailout" = "[bailout_millions] млн", "reason" = pick("развала цепочки поставок", "провала продуктовой линейки", "многолетних плохих кредитов", "проигранного судебного иска", "мошенничества в бухгалтерии", "потери крупнейшего клиента"))
	switch(phase)
		if(1)
			publish("%company% объявила о банкротстве", "Паника среди инвесторов, спасение под вопросом", "После %reason% компания %company% больше не может расплачиваться с кредиторами. Обсуждается пакет спасения на %bailout% кредитов.", -5, STOCK_NEWS_ALERT, tokens)
			company.affect_opinion(-rand(4, 6))
			state = STOCK_EVENT_VISIBLE
			next_phase = world.time + rand(6, 10) MINUTES
			title = "Банкротство [company.name]"
			desc = "Решение о спасении ожидается в [when(next_phase)] по станционному времени. Если его не будет, акции обесценятся."
		if(2)
			var/rescue_chance = company.trend > 0 ? 80 : 55
			if(prob(rescue_chance))
				publish("%company% спасена", "Подписан пакет помощи на %bailout% кредитов", "Компания %company% продолжит работу: кредиторы согласовали пакет спасения. Инвесторы настроены осторожно-оптимистично.", 3, STOCK_NEWS_ALERT, tokens)
				company.affect_opinion(rand(3, 6))
				finish()
			else
				publish("Крах %company%", "Акции %ticker% больше ничего не стоят", "Спасения не последовало. Компания %company% исключена из листинга биржи, её акции аннулированы.", -5, STOCK_NEWS_ALERT, tokens)
				finish()
				SSstock_market.delist(company)
