// This system defines news that will be displayed in the course of a round.
// Uses BYOND's type system to put everything into a nice format

/datum/news_announcement

	/// Time of the round at which this should be announced, in seconds
	var/round_time
	/// Body of the message
	var/message
	var/author = "Nanotrasen Editor"
	var/channel_name = NEWS_CHANNEL_NYX
	var/can_be_redacted = FALSE
	var/message_type = "Story"

/datum/news_announcement/revolution_inciting_event/paycuts_suspicion
	round_time = 60*10
	message = {"Leaked messages suggest that Nanotrasen plans to cut wages at many of its research
				stations in the Tau Ceti system. Apparently these stations have failed to deliver the expected
				profits, and adjustments are deemed necessary."}
	author = "Unauthorized"

/datum/news_announcement/revolution_inciting_event/paycuts_confirmation
	round_time = 60*40
	message = {"Earlier rumours of wage cuts at research stations in the Tau Ceti system have been
				confirmed. Shockingly, however, the cuts will only affect lower-tier staff. According to our
				sources, station management will not be affected."}
	author = "Unauthorized"

/datum/news_announcement/revolution_inciting_event/human_experiments
	round_time = 60*90
	message = {"Shocking reports of human experimentation have emerged. According to a refugee from
				one of the research stations in the Tau Ceti system, their station converted several of its labs
				to experiment on living people in order to raise revenue. These included virology research,
				genetic manipulation and "feeding them to slimes to see what happens". Allegedly the test subjects
				were neither monkeys nor volunteers, but unskilled staff forced into the experiments. Their deaths
				were reported by Nanotrasen as "workplace accidents"."}
	author = "Unauthorized"

/datum/news_announcement/bluespace_research/announcement
	round_time = 60*20
	message = {"A new field of research trying to explain several interesting space-time anomalies,
				known as "Bluespace Research", has reached new heights. Of the several hundred space stations
				orbiting in the Tau Ceti system, fifteen are now specially equipped to experiment with and study
				the effects of bluespace. Rumour has it that some of these stations even have working "travel gates"
				able to send whole research teams to alternate realities in an instant."}

/datum/news_announcement/random_junk/cheesy_honkers
	author = "Assistant Editor Carl Ritz"
	channel_name = NEWS_CHANNEL_GIB
	message = {"Do Cheesy Honkers increase the risk of miscarriage? Several health bodies say yes!"}
	round_time = 60 * 15

/datum/news_announcement/random_junk/net_block
	author = "Assistant Editor Carl Ritz"
	channel_name = NEWS_CHANNEL_GIB
	message = {"Several corporations have joined forces to block access to the website "wetskrell.nt".
				The site's administrators claim this breaks network laws."}
	round_time = 60 * 50

/datum/news_announcement/random_junk/found_ssd
	author = "Doctor Eric Hanfield"

	message = {"Several people have been found unconscious at their terminals. This is thought to be
				due to sleep deprivation or migraines from staring at screens for too long. Camera footage shows
				that many of them were playing games instead of working, and their pay has been docked accordingly."}
	round_time = 60 * 90

/datum/news_announcement/lotus_tree/explosions
	author = "Reporter Leland H. Howards"

	message = {"The recently launched civilian transport Lotus Tree suffered two powerful explosions near
				the bridge today. Unconfirmed reports put the death toll above 50. The cause of the explosions
				remains unknown, but there is speculation it may be linked to a recent policy change by the
				Mur-Li Corporation, the ship's main sponsor. The corporation also announced it will recognise
				inter-species marriages and grant tax breaks to such couples."}
	round_time = 60 * 30

/datum/news_announcement/food_riots/breaking_news
	author = "Reporter Ro'kii Ar-Rakis"

	message = {"Breaking news: Food riots have broken out in the asteroid colony of Refuge in the Tenebrae
				Lupus system. This came only hours after Nanotrasen representatives announced an end to trade
				with the colony, citing an increased presence of "hostile factions" that made trade too dangerous.
				Nanotrasen representatives gave no details about these factions. More on this at the top of the hour."}
	round_time = 60 * 10

/datum/news_announcement/food_riots/more
	author = "Reporter Ro'kii Ar-Rakis"

	message = {"More on the food riots in the Refuge colony: the Refuge Council has condemned Nanotrasen's
				withdrawal from the colony, stating that "there has been no increase in anti-Nanotrasen activity",
				and that "the only reason Nanotrasen is leaving is the complete exhaustion of plasma deposits in the
				Tenebrae Lupus system. We have almost nothing left to offer them". Nanotrasen representatives have
				denied these claims, calling them "yet more evidence" of anti-Nanotrasen sentiment in the colony.
				Meanwhile Refuge security has been unable to put down the unrest. More on this at six."}
	round_time = 60 * 60
GLOBAL_LIST_INIT(newscaster_standard_feeds, list(/datum/news_announcement/bluespace_research, /datum/news_announcement/lotus_tree, /datum/news_announcement/random_junk,  /datum/news_announcement/food_riots))

/proc/process_newscaster()
	check_for_newscaster_updates(SSticker.mode.newscaster_announcements)

GLOBAL_LIST_EMPTY(announced_news_types)

/proc/check_for_newscaster_updates(type)
	for(var/subtype in subtypesof(type))
		var/datum/news_announcement/news = new subtype()
		if(news.round_time * 10 <= world.time && !(subtype in GLOB.announced_news_types))
			GLOB.announced_news_types += subtype
			announce_newscaster_news(news)

/proc/announce_newscaster_news(datum/news_announcement/news)

	var/datum/feed_channel/sendto = GLOB.news_network.get_channel_by_name(news.channel_name)
	if(!sendto)
		sendto = new /datum/feed_channel
		sendto.channel_name = news.channel_name
		sendto.author = news.author
		sendto.frozen = TRUE
		sendto.admin_locked = TRUE
		GLOB.news_network.channels += sendto

	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = news.author ? news.author : sendto.author
	newMsg.admin_locked = !news.can_be_redacted
	newMsg.body = news.message

	sendto.add_message(newMsg)

	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(news.channel_name)
