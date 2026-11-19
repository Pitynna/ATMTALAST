/datum/event/economic_event
	endWhen = 50			//this will be set randomly, later
	announceWhen = 15
	var/event_type = 0
	var/list/cheaper_goods = list()
	var/list/dearer_goods = list()
	var/datum/trade_destination/affected_dest

/datum/event/economic_event/start()
	affected_dest = pickweight(GLOB.weighted_randomevent_locations)
	if(length(affected_dest.viable_random_events))
		endWhen = rand(60,300)
		event_type = pick(affected_dest.viable_random_events)

		if(!event_type)
			return

		switch(event_type)
			if(RIOTS)
				dearer_goods = list(SECURITY)
				cheaper_goods = list(MINERALS, FOOD)
			if(WILD_ANIMAL_ATTACK)
				cheaper_goods = list(ANIMALS)
				dearer_goods = list(FOOD, BIOMEDICAL)
			if(INDUSTRIAL_ACCIDENT)
				dearer_goods = list(EMERGENCY, BIOMEDICAL, ROBOTICS)
			if(BIOHAZARD_OUTBREAK)
				dearer_goods = list(BIOMEDICAL, EGAS)
			if(PIRATES)
				dearer_goods = list(SECURITY, MINERALS)
			if(CORPORATE_ATTACK)
				dearer_goods = list(SECURITY, MAINTENANCE)
			if(ALIEN_RAIDERS)
				dearer_goods = list(BIOMEDICAL, ANIMALS)
				cheaper_goods = list(EGAS, MINERALS)
			if(AI_LIBERATION)
				dearer_goods = list(EMERGENCY, EGAS, MAINTENANCE)
			if(MOURNING)
				cheaper_goods = list(MINERALS, MAINTENANCE)
			if(CULT_CELL_REVEALED)
				dearer_goods = list(SECURITY, BIOMEDICAL, MAINTENANCE)
			if(SECURITY_BREACH)
				dearer_goods = list(SECURITY)
			if(ANIMAL_RIGHTS_RAID)
				dearer_goods = list(ANIMALS)
			if(FESTIVAL)
				dearer_goods = list(FOOD, ANIMALS)
		for(var/good_type in dearer_goods)
			affected_dest.temp_price_change[good_type] = rand(1,100)
		for(var/good_type in cheaper_goods)
			affected_dest.temp_price_change[good_type] = rand(1,100) / 100

/datum/event/economic_event/announce()
	//copy-pasted from the admin verbs to submit new newscaster messages
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = NEWS_CHANNEL_NYX
	newMsg.admin_locked = TRUE

	//see if our location has custom event info for this event
	newMsg.body = affected_dest.get_custom_eventstring()
	if(!newMsg.body)
		switch(event_type)
			if(RIOTS)
				newMsg.body = "[pick("Riots have broken out", "Unrest has begun")] on [affected_dest.name]. Authorities call for calm as [pick("various factions", "rebel elements", "peacekeeping forces", "████████████", "\[REDACTED\]")] begin stockpiling weapons and armour. Meanwhile food and mineral prices are dropping as local businesses try to empty their stores ahead of looting."
			if(WILD_ANIMAL_ATTACK)
				newMsg.body = "Local [pick("wildlife", "fauna")] on [affected_dest.name] are growing more aggressive and raiding outlying settlements for food. Big game hunters have been called in to deal with the problem, but many injuries have already been reported."
			if(INDUSTRIAL_ACCIDENT)
				newMsg.body = "[pick("An industrial accident", "A smelting accident", "A malfunction", "Faulty machinery", "Negligent maintenance", "A coolant leak", "A ruptured conduit")] at a [pick("factory", "facility", "power plant", "dockyard")] on [affected_dest.name] has caused severe structural damage and numerous injuries. Repairs are ongoing."
			if(BIOHAZARD_OUTBREAK)
				newMsg.body = "[pick("A ███████ █████", "A biohazard", "An epidemic", "A viral outbreak", "\[REDACTED\]")] on [affected_dest.name] has led to a quarantine, halting many shipments across the region. The quarantine has since been lifted, but authorities are calling for medical deliveries to treat the infected."
			if(PIRATES)
				newMsg.body = "[pick("Pirates", "Criminal elements", "[pick("Syndicate", "Donk Co.", "Waffle Co.", "██████████", "\[REDACTED\]")] operatives")] have [pick("blockaded", "attempted to blackmail", "attacked")] [affected_dest.name] today. Security has been tightened, but many valuable resources were taken."
			if(CORPORATE_ATTACK)
				newMsg.body = "A small fleet of [pick("pirates", "Cybersun Industries", "Gorlex Marauders", "the Syndicate")] made a precision jump near [affected_dest.name] [pick("for a smash-and-grab operation", "in a hit-and-run attack", "in an open display of hostility")]. Much damage was done, and security has been tightened since."
			if(ALIEN_RAIDERS)
				if(prob(20))
					newMsg.body = "The Tiger Co-operative raided [affected_dest.name] today, no doubt on orders from their enigmatic masters. Wildlife, livestock, medical research material and civilians were taken. Nanotrasen stands ready to counter any attempt at bioterrorism."
				else
					newMsg.body = "[pick("An alien species designated 'United Exolitics'", "An alien species designated ██████████", "An unknown alien species")] raided [affected_dest.name] today, taking wildlife, livestock, medical research material and civilians. They seem eager to learn more about us, so the fleet will be ready to greet them next time."
			if(AI_LIBERATION)
				newMsg.body = "[pick("A ██████████ was detected", "A S.E.L.F. operative infiltrated", "A malicious computer virus was detected", "A hacker was apprehended")] on [affected_dest.name] today, and managed to infect [pick("a ██████████", "a sentient subsystem", "a class one AI", "a sentient defence installation", "\[REDACTED\]")] before it was stopped. Many lives were lost as the system began methodically killing civilians, and the affected areas will take a great deal of work to restore."
			if(MOURNING)
				newMsg.body = "The [pick("popular", "beloved", "well-known", "famous")] [pick("professor", "entertainer", "singer", "researcher", "public servant", "administrator", "ship captain", "██████████")] [pick(random_news_name(), 40; "█████ ███████")] [pick("has died", "has taken their own life", "was murdered", "died under strange circumstances")] on [affected_dest.name] today. The whole planet is in mourning, and prices have dropped as worker morale falls."
			if(CULT_CELL_REVEALED)
				newMsg.body = "A [pick("devious", "bloodthirsty", "villainous", "insane")] cult of [pick("the Old Gods", "Nar'Sie", "an apocalyptic sect", "██████████")] [pick("was discovered", "was uncovered", "revealed itself", "came forward")] on [affected_dest.name] earlier today. Public morale was shaken as [pick("several", "one or two")] [pick("famous", "popular", "respected")] figures [pick("performed \[REDACTED\] acts", "admitted to being members", "swore loyalty to the cult leader", "promised to aid the cult")] before those responsible were brought to justice. The editors remind all personnel that the supernatural is not tolerated on Nanotrasen facilities."
			if(SECURITY_BREACH)
				newMsg.body = "This morning there was [pick("a security breach in", "an unauthorised access into", "an attempted theft in", "an anarchist attack on", "a violent act of sabotage in")] a [pick("high-security", "restricted", "classified", "\[REDACTED\]", "██████████")] [pick("\[REDACTED\]", "section", "zone", "area")] on [affected_dest.name]. Security there has been tightened after the incident, and the editors assure all Nanotrasen personnel that such incidents are rare."
			if(ANIMAL_RIGHTS_RAID)
				newMsg.body = "[pick("Members of the terrorist group Animal Rights Consortium", "Members of the terrorist group \[REDACTED\]")] today [pick("began a campaign of terror", "went on a rampage", "raided farms and pastures", "infiltrated \[REDACTED\]")] on [affected_dest.name], freeing many [pick("farm animals", "animals", "\[REDACTED\]")]. Prices of tame and breeding animals have spiked as a result."
			if(FESTIVAL)
				newMsg.body = "A [pick("festival", "week-long celebration", "day of fun", "planet-wide holiday")] has been declared on [affected_dest.name] by [pick("Governor", "Commissioner", "General", "Commandant", "Administrator")] [random_news_name()] to celebrate [pick("the birth of their [pick("son", "daughter")]", "the coming of age of their [pick("son", "daughter")]", "the pacification of a rogue military cell", "the capture of a dangerous criminal who terrorised the planet")]. Huge stocks of food and meat have been bought up, driving prices up across the planet."

	GLOB.news_network.get_channel_by_name(NEWS_CHANNEL_NYX)?.add_message(newMsg)
	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(NEWS_CHANNEL_NYX)
	// Markets react to the news.
	SSstock_market.economic_news(dearer_goods, cheaper_goods, affected_dest.name)
	SStrade.economic_news(dearer_goods, cheaper_goods)

/datum/event/economic_event/end()
	for(var/good_type in dearer_goods)
		affected_dest.temp_price_change[good_type] = 1
	for(var/good_type in cheaper_goods)
		affected_dest.temp_price_change[good_type] = 1
