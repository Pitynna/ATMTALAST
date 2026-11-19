
GLOBAL_LIST_EMPTY(weighted_randomevent_locations)
GLOBAL_LIST_EMPTY(weighted_mundaneevent_locations)

/datum/trade_destination
	var/name = ""
	var/description = ""
	var/distance = 0
	var/list/willing_to_buy = list()
	var/list/willing_to_sell = list()
	var/can_shuttle_here = 0		//one day crew from the exodus will be able to travel to this destination
	var/list/viable_random_events = list()
	var/list/temp_price_change[BIOMEDICAL]
	var/list/viable_mundane_events = list()

/datum/trade_destination/proc/get_custom_eventstring(event_type)
	return null

//distance is measured in AU and co-relates to travel time
/datum/trade_destination/centcomm
	name = "Central Command"
	description = "Nanotrasen's administrative centre for the Tau Ceti system."
	distance = 1.2
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(SECURITY_BREACH, CORPORATE_ATTACK, AI_LIBERATION)
	viable_mundane_events = list(ELECTION, RESIGNATION, CELEBRITY_DEATH)

/datum/trade_destination/anansi
	name = "NMS Anansi"
	description = "A medical station owned by Nanotrasen and run by the Second Red Cross Society. Handles emergencies from the nearby colonies."
	distance = 1.7
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(SECURITY_BREACH, CULT_CELL_REVEALED, BIOHAZARD_OUTBREAK, PIRATES, ALIEN_RAIDERS)
	viable_mundane_events = list(RESEARCH_BREAKTHROUGH, RESEARCH_BREAKTHROUGH, BARGAINS, GOSSIP)

/datum/trade_destination/anansi/get_custom_eventstring(event_type)
	if(event_type == RESEARCH_BREAKTHROUGH)
		return "Thanks to research carried out aboard NMS Anansi, the Second Red Cross Society is proud to announce a major breakthrough in \
		[pick("mind-machine interfacing", "neuroscience", "nano-augmentation", "genetics")]. Nanotrasen is expected to announce a cooperation agreement within two weeks."
	return null

/datum/trade_destination/icarus
	name = "NDV Icarus"
	description = "A corvette assigned to patrol the space around the station."
	distance = 0.1
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(SECURITY_BREACH, AI_LIBERATION, PIRATES)

/datum/trade_destination/redolant
	name = "OAV Redolant"
	description = "An Osiris Atmospherics station orbiting a gas giant that has not been named yet. OA warships guard the installation and police shipping near the planet, which is nothing unusual in Tau Ceti. Nanotrasen grudgingly tolerates the foreign naval presence in exchange for a share of the profits."
	distance = 0.6
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(INDUSTRIAL_ACCIDENT, PIRATES, CORPORATE_ATTACK)
	viable_mundane_events = list(RESEARCH_BREAKTHROUGH, RESEARCH_BREAKTHROUGH)

/datum/trade_destination/redolant/get_custom_eventstring(event_type)
	if(event_type == RESEARCH_BREAKTHROUGH)
		return "Thanks to research carried out aboard OAV Redolant, Osiris Atmospherics is proud to announce a major breakthrough in \
		[pick("plasma research", "high energy flux capacitance", "super-compressed materials", "theoretical particle physics")]. Nanotrasen is expected to announce a cooperation agreement within two weeks."
	return null

/datum/trade_destination/beltway
	name = "Beltway mining chain"
	description = "A joint venture of Beltway and Nanotrasen to mine the rich outer asteroid belt of the Tau Ceti system."
	distance = 7.5
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(PIRATES, INDUSTRIAL_ACCIDENT)
	viable_mundane_events = list(TOURISM)

/datum/trade_destination/biesel
	name = "Biesel"
	description = "Large shipyards, a strong economy and a stable, educated population. Biesel stays mostly loyal to the SolGov and puts up with Nanotrasen. The capital is Lowell City."
	distance = 2.3
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RIOTS, INDUSTRIAL_ACCIDENT, BIOHAZARD_OUTBREAK, CULT_CELL_REVEALED, FESTIVAL, MOURNING)
	viable_mundane_events = list(BARGAINS, GOSSIP, SONG_DEBUT, MOVIE_RELEASE, ELECTION, TOURISM, RESIGNATION, CELEBRITY_DEATH)

/datum/trade_destination/new_gibson
	name = "New Gibson"
	description = "A heavily industrialised rocky planet holding most of the system's planetary resources. New Gibson is torn by unrest and has little wealth of its own beyond what the corporations competing with Nanotrasen for control hold."
	distance = 6.6
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RIOTS, INDUSTRIAL_ACCIDENT, BIOHAZARD_OUTBREAK, CULT_CELL_REVEALED, FESTIVAL, MOURNING)
	viable_mundane_events = list(ELECTION, TOURISM, RESIGNATION)

/datum/trade_destination/luthien
	name = "Luthien"
	description = "A small colony on a wild, untamed world, mostly jungle. Natives and wild beasts regularly attack the outpost, although Nanotrasen keeps tight military control."
	distance = 8.9
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(WILD_ANIMAL_ATTACK, CULT_CELL_REVEALED, FESTIVAL, MOURNING, ANIMAL_RIGHTS_RAID, ALIEN_RAIDERS)
	viable_mundane_events = list(ELECTION, TOURISM, BIG_GAME_HUNTERS, RESIGNATION)

/datum/trade_destination/reade
	name = "Reade"
	description = "A cold world short on metals. Nanotrasen runs extensive mining complexes on what land it can reach, trying to get anything at all out of this unprofitable colony."
	distance = 7.5
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(WILD_ANIMAL_ATTACK, CULT_CELL_REVEALED, FESTIVAL, MOURNING, ANIMAL_RIGHTS_RAID, ALIEN_RAIDERS)
	viable_mundane_events = list(ELECTION, TOURISM, BIG_GAME_HUNTERS, RESIGNATION)
