
/datum/event/mundane_news
	endWhen = 10

/datum/event/mundane_news/announce()
	var/datum/trade_destination/affected_dest = pickweight(GLOB.weighted_mundaneevent_locations)
	var/event_type = 0
	if(length(affected_dest.viable_mundane_events))
		event_type = pick(affected_dest.viable_mundane_events)

	if(!event_type)
		return

	//copy-pasted from the admin verbs to submit new newscaster messages
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = NEWS_CHANNEL_NYX
	newMsg.admin_locked = TRUE

	//see if our location has custom event info for this event
	newMsg.body = affected_dest.get_custom_eventstring()
	if(!newMsg.body)
		newMsg.body = ""

		switch(event_type)
			if(RESEARCH_BREAKTHROUGH)
				newMsg.body = "A major breakthrough in [pick("plasma research", "super-compressed materials", "nano-augmentation", "bluespace research", "volatile power manipulation")] was announced [pick("yesterday", "a few days ago", "last week", "earlier this month")] by a private firm on [affected_dest.name]. Nanotrasen declined to comment on whether this could affect its profits."

			if(ELECTION)
				newMsg.body = "The pre-selection of additional candidates for the upcoming [pick("supervisory council", "advisory board", "parliament", "board of inquisitors")] elections on [affected_dest.name] was announced today. Among them is [pick("media mogul", "web celebrity", "industry titan", "superstar", "famed chef", "popular gardener", "former army officer", "multi-billionaire")] [random_news_name()]. In a statement to the press they said: "
				newMsg.body += "\"[pick("My only goal is to help the [pick("sick", "poor", "children")]", "I will keep Nanotrasen's profits at record highs", "I believe in our future", "We must return to our moral core", "Just... chill out, everyone")]!\""

			if(RESIGNATION)
				var/retiree = random_news_name()
				newMsg.body = "Nanotrasen regretfully announces the resignation of [pick("Sector Admiral", "Division Admiral", "Ship Admiral", "Vice Admiral")] [retiree]."
				if(prob(25))
					var/locstring = pick("Segunda", "Salusa", "Cepheus", "Andromeda", "Gruis", "Corona", "Aquila", "Asellus") + " " + pick("I", "II", "III", "IV", "V", "VI", "VII", "VIII")
					newMsg.body += " A ceremony will be held on [affected_dest.name] this afternoon, where they will be awarded the [pick("Red Star of Sacrifice", "Purple Heart of Heroism", "Blue Eagle of Loyalty", "Green Lion of Ingenuity")] for "
					if(prob(33))
						newMsg.body += "their actions at the Battle of [pick(locstring, "██████████")]."
					else if(prob(50))
						newMsg.body += "their contribution to the colony of [locstring]."
					else
						newMsg.body += "many years of loyal service."
				else if(prob(33))
					newMsg.body += " They are expected to settle on [affected_dest.name], where they have been granted a generous pension."
				else if(prob(50))
					newMsg.body += " The news was made public on [affected_dest.name] earlier today, where they gave their reason for leaving as '[pick("health", "family", "██████████")]'."
				else
					newMsg.body += " The Aerospace Authority wishes them well at the retirement ceremony to be held on [affected_dest.name]."

			if(CELEBRITY_DEATH)
				newMsg.body = "We regret to announce the sudden passing of the "
				if(prob(33))
					newMsg.body += "[pick("distinguished", "decorated", "veteran", "highly respected")] [pick("ship captain", "vice admiral", "colonel", "lieutenant colonel")] "
				else if(prob(50))
					newMsg.body += "[pick("award-winning", "popular", "highly respected", "trend-setting")] [pick("comedian", "artist", "playwright", "TV host")] "
				else
					newMsg.body += "[pick("successful", "highly respected", "brilliant", "esteemed")] [pick("scientist", "professor", "doctor", "researcher")] "

				newMsg.body += "[random_news_name()] on [affected_dest.name] [pick("last week", "yesterday", "this morning", "two days ago", "three days ago")][pick(". Murder is suspected, but no culprits have been found yet", " at the hands of Syndicate agents (since apprehended)", " in an industrial accident", " of [pick("heart failure", "kidney failure", "liver failure", "a brain haemorrhage")]")]."

			if(BARGAINS)
				newMsg.body += "BARGAINS! BARGAINS! BARGAINS! Commerce Control on [affected_dest.name] says everything must go! Prices are slashed in every shopping centre, so come and have the shopping trip of your life!"

			if(SONG_DEBUT)
				newMsg.body = "[pick("Singer", "Singer-songwriter", "Saxophonist", "Pianist", "Guitarist", "TV host", "Superstar")] [random_news_name()] has announced the debut of their new [pick("single", "album", "EP", "label")] \"[pick("All These", "Look At The", "Baby, Don't Look At The", "Those", "Dirty Nasty")] [pick("Roses", "Three Stars", "Starships", "Nanobots", "Cyborgs", "Skrell", "Sren'darr")] [pick("On Venus", "On Reade", "On Moghes", "In My Hand", "Slipping Through My Fingers", "Will Die For You", "Sing Your Heart Out", "Flying Away")]\" [pick("with pre-orders available now", "with a supporting tour", "with signing sessions", "with a launch concert")] on [affected_dest.name]."

			if(MOVIE_RELEASE)
				newMsg.body += "From the [pick("office", "home town", "home world", "mind")] of [pick("acclaimed", "award-winning", "popular", "stellar")] [pick("playwright", "author", "director", "actor", "TV star")] [random_news_name()] comes the latest sensation: \"[pick("Deadly", "The Last", "Lost", "Dead")] [pick("Starships", "Warriors", "Outcasts", "Tajaran", "Unathi", "Skrell")] [pick("Visit", "Ravage", "Loot", "Destroy")] [pick("Moghes", "Earth", "Biesel", "Ahdomai", "S'randarr", "the Void", "the Edge of Space")]\". Buy the webcast today or visit the galactic premiere on [affected_dest.name]!"

			if(BIG_GAME_HUNTERS)
				newMsg.body += "Hunters on [affected_dest.name] "
				if(prob(33))
					newMsg.body += "were surprised to find an unusual species, later identified by experts as [pick("a mammalian subclass", "an aberrant feral species", "a sentient lemur species", "organic-cybernetic hybrids")]. They are thought to have been brought in by [pick("alien smugglers", "early colonists", "Syndicate raiders", "tourists")], and this is the first such specimen found in the wild."
				else if(prob(50))
					newMsg.body += "were attacked by a ferocious [pick("nas'r", "diyaab", "samak", "predator not yet identified")]. Authorities urge caution, and locals are advised to stock up on weapons."
				else
					newMsg.body += "brought in an unusually [pick("valuable", "rare", "large", "ferocious", "intelligent")] [pick("mammal", "predator", "farwa", "samak")] for inspection [pick("today", "yesterday", "last week")]. Speculators suggest it may break several records."

			if(GOSSIP)
				newMsg.body += "[pick("TV host", "Web celebrity", "Superstar", "Model", "Actor", "Singer")] [random_news_name()]"
				if(prob(33))
					newMsg.body += " and their spouse announced the birth of their [pick("first", "second", "third")] child on [affected_dest.name] early this morning. Doctors report the child is healthy, and the parents are considering the name [pick(GLOB.trader_first_names)]."
				else if(prob(50))
					newMsg.body += " announced their [pick("separation", "break-up", "marriage")] with [pick("TV host", "web celebrity", "superstar", "model", "actor", "singer")] [random_news_name()] [pick("at a society ball", "at a new opening", "at a club")] on [affected_dest.name] yesterday. Experts are shocked."
				else
					newMsg.body += " is recovering from plastic surgery in a clinic on [affected_dest.name] for the [pick("second", "third", "fourth")] time. The decision was reportedly made in response to "
					newMsg.body += "[pick("unkind comments", "rumours spread by jealous friends", "a major sponsor ending their contract", "a disastrous interview on Nyx Tonight")]."

			if(TOURISM)
				newMsg.body += "Tourists are flocking to [affected_dest.name] after the surprise announcement of [pick("sales from a major retailer", "a huge new AR game from a popular entertainment company", "a tour by a popular artist")]. Nyx Daily is offering discount tickets for two to a concert by popular artist [random_news_name()] in exchange for eyewitness reports and up-to-the-minute coverage."

	GLOB.news_network.get_channel_by_name(NEWS_CHANNEL_NYX)?.add_message(newMsg)
	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(NEWS_CHANNEL_NYX)

/datum/event/trivial_news
	endWhen = 10

/datum/event/trivial_news/announce()
	//copy-pasted from the admin verbs to submit new newscaster messages
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = EDITOR_GIB
	//newMsg.is_admin_message = 1
	var/datum/trade_destination/affected_dest = pick(GLOB.weighted_mundaneevent_locations)
	newMsg.body = pick(world.file2list("strings/news/trivial.txt"))
	newMsg.body = replacetext(newMsg.body, "{{AFFECTED}}", affected_dest.name)

	GLOB.news_network.get_channel_by_name(NEWS_CHANNEL_GIB)?.add_message(newMsg)
	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(NEWS_CHANNEL_GIB)
