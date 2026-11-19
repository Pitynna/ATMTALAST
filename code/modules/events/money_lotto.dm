/datum/event/money_lotto
	var/winner_name = "John Smith"
	var/winner_sum = 0
	var/deposit_success = 0

/datum/event/money_lotto/start()
	winner_sum = pick(5000, 10000, 50000, 100000, 500000, 1000000, 1500000)
	if(length(GLOB.all_money_accounts))
		var/datum/money_account/D = pick(GLOB.all_money_accounts)
		winner_name = D.owner_name

		D.credit(winner_sum, "Winner!", "Biesel terminal #[rand(111,333)]", "Nyx Daily Stellar Slam lottery")
		deposit_success = 1

/datum/event/money_lotto/announce()
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = EDITOR_NYX
	newMsg.admin_locked = TRUE

	newMsg.body = "Nyx Daily congratulates [winner_name] on winning the Nyx Stellar Slam lottery and an incredible [winner_sum] credits!"
	if(!deposit_success)
		newMsg.body += " Unfortunately we could not verify the account details provided, so the money could not be transferred. Send a cheque for $500 to the ND 'Stellar Slam' office with updated details, and your winnings will be transferred within a month."

	GLOB.news_network.get_channel_by_name(NEWS_CHANNEL_NYX)?.add_message(newMsg)
	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(NEWS_CHANNEL_NYX)
