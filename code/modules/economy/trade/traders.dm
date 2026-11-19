// The traders. Names are made every round, personalities stay.

GLOBAL_LIST_INIT(trader_first_names, list("Ada", "Bram", "Cass", "Dorian", "Edda", "Finn", "Greta", "Hugo", "Ines", "Jory", "Kit", "Lev", "Mira", "Nils", "Orla", "Piet", "Rhea", "Sol", "Tamsin", "Vik"))
GLOBAL_LIST_INIT(trader_last_names, list("Ashby", "Brannock", "Corwin", "Dunmore", "Ellery", "Fenwick", "Garrow", "Hale", "Ivers", "Kell", "Lowry", "Marlow", "Norcross", "Osgood", "Penhallow", "Quint", "Rook", "Sallow", "Tremaine", "Voss"))

/// English name for people in galactic news. The station's own name lists are in Russian.
/proc/random_news_name()
	return "[pick(GLOB.trader_first_names)] [pick(GLOB.trader_last_names)]"

// MARK: Medical
/datum/trader/medical
	title = "mobile clinic supplier"
	icon = "briefcase-medical"
	color = "teal"
	desc = "Runs a hospital ship between frontier colonies. Polite, precise and never in a hurry."
	base_patience = list(3, 5)
	hike_tolerance = 25
	sell_pool = list(
		list(/obj/item/storage/firstaid/adv, 70, 2, 5, 100),
		list(/obj/item/reagent_containers/hypospray/autoinjector/charcoal, 35, 3, 8, 100),
		list(/obj/item/reagent_containers/hypospray/autoinjector/salbutamol, 35, 3, 8, 80),
		list(/obj/item/healthanalyzer/advanced, 160, 1, 3, 70),
		list(/obj/item/defibrillator/loaded, 280, 1, 2, 60),
		list(/obj/item/storage/firstaid/surgery, 180, 1, 2, 50),
		list(/obj/item/reagent_containers/hypospray/safety, 220, 1, 2, 50),
		list(/obj/item/organ/internal/heart/cybernetic, 320, 1, 2, 40),
		list(/obj/item/organ/internal/eyes/cybernetic, 220, 1, 2, 40),
		list(/obj/item/organ/internal/liver/cybernetic, 220, 1, 2, 40),
	)
	buy_pool = list(
		/datum/commodity/organs = 1.3,
		/datum/commodity/pills = 1.2,
		/datum/commodity/medical_stacks = 1.2,
		/datum/commodity/slime_extract = 1.1,
	)
	dialogue_greet = list(
		"Good day. Our pharmacy is open, please browse at your leisure.",
		"Welcome aboard. Everything here is sterile and fully certified.",
		"Ah, a station with a working medbay. How refreshing. What do you need?",
	)
	dialogue_haggle_accept = list(
		"I can lower it a little. For your patients' sake.",
		"Very well, a professional courtesy.",
		"Let us say this, and we both keep our dignity.",
	)
	dialogue_haggle_final = list(
		"This is the lowest I can go without breaking my own oath.",
		"My final price. The supplies will not pay for themselves.",
	)
	dialogue_haggle_reject = list(
		"I am afraid that is not a serious offer.",
		"Medicine costs what it costs. Please reconsider.",
		"No. Those are certified goods, not salvage.",
	)
	dialogue_wrong_haggle = list("How generous of you. Thank you.")
	dialogue_leave = list(
		"I have other patients waiting. Good day.",
		"I think we are done here. Do take care of yourselves.",
	)
	dialogue_purchase = list(
		"Packed and sealed. It will be on the next supply run.",
		"Thank you. Please follow the instructions on the label.",
	)
	dialogue_no_patience = list("I will not discuss prices any further.")

/datum/trader/medical/generate_name()
	return "Dr. [pick(GLOB.trader_last_names)]"

// MARK: Engineering
/datum/trader/engineering
	title = "salvage engineer"
	icon = "tools"
	color = "yellow"
	desc = "Strips derelict stations for parts and sells them with a grin. Haggling is half the fun for them."
	base_patience = list(4, 6)
	hike_tolerance = 30
	sell_pool = list(
		list(/obj/item/stock_parts/cell/high, 60, 3, 6, 100),
		list(/obj/item/storage/belt/utility/full, 90, 1, 3, 100),
		list(/obj/item/clothing/glasses/meson, 50, 2, 4, 90),
		list(/obj/item/clothing/gloves/color/yellow, 160, 1, 3, 80),
		list(/obj/item/weldingtool/hugetank, 80, 1, 3, 80),
		list(/obj/item/storage/part_replacer, 130, 1, 2, 70),
		list(/obj/item/stock_parts/capacitor/super, 70, 2, 5, 60),
		list(/obj/item/stock_parts/manipulator/pico, 70, 2, 5, 60),
		list(/obj/item/stock_parts/scanning_module/phasic, 70, 2, 5, 60),
		list(/obj/item/stock_parts/matter_bin/super, 70, 2, 5, 60),
		list(/obj/item/stock_parts/micro_laser/ultra, 70, 2, 5, 60),
		list(/obj/item/stock_parts/cell/hyper, 190, 1, 3, 50),
		list(/obj/item/clothing/shoes/magboots, 260, 1, 2, 40),
	)
	buy_pool = list(
		/datum/commodity/metal = 1.15,
		/datum/commodity/glass = 1.15,
		/datum/commodity/plasteel = 1.2,
		/datum/commodity/stock_parts = 1.2,
		/datum/commodity/circuitboards = 1.2,
		/datum/commodity/cable = 1.1,
	)
	dialogue_greet = list(
		"Hey! Fresh haul from a derelict, barely scorched. Have a look!",
		"Everything works. Mostly. Guaranteed! Sort of.",
		"Got parts, got tools, got a bad back from hauling all of it. Buy something.",
	)
	dialogue_haggle_accept = list(
		"Ha! Fine, you got me. How's this?",
		"You drive a hard bargain, chief. Meet me here?",
		"Alright, alright. For a fellow grease monkey.",
	)
	dialogue_haggle_final = list(
		"That's it, that's all I can do. I've got a hull to patch.",
		"Final price, and I'm only saying that because I like you.",
	)
	dialogue_haggle_reject = list(
		"Whoa, no. I pulled that out of a reactor room, you know.",
		"Ha, nice try. No.",
		"That's not haggling, that's robbery!",
	)
	dialogue_wrong_haggle = list("Uh... sure! No takebacks!")
	dialogue_leave = list(
		"Okay, I'm wasting fuel here. See you around!",
		"Nope, I'm out. Call me when you're serious.",
	)
	dialogue_purchase = list(
		"Done! I'll toss it on your next supply run.",
		"Sold! Mind the sharp edges.",
	)
	dialogue_no_patience = list("No more haggling, chief. Buy it or don't.")

/datum/trader/engineering/generate_name()
	return "[pick(GLOB.trader_first_names)] \"[pick("Sparks", "Wrench", "Rivet", "Fuse", "Gasket", "Socket")]\" [pick(GLOB.trader_last_names)]"

// MARK: Ore
/datum/trader/ore
	title = "asteroid prospector"
	icon = "gem"
	color = "orange"
	desc = "A tough old miner from the belt. Pays well for good rock and has no time for small talk."
	base_patience = list(2, 4)
	hike_tolerance = 20
	sell_pool = list(
		list(/obj/item/mining_scanner, 40, 2, 4, 100),
		list(/obj/item/pickaxe/drill, 110, 1, 3, 100),
		list(/obj/item/resonator, 160, 1, 2, 80),
		list(/obj/item/borg/upgrade/modkit/cooldown, 160, 1, 2, 60),
		list(/obj/item/borg/upgrade/modkit/range, 160, 1, 2, 60),
		list(/obj/item/gun/energy/kinetic_accelerator, 320, 1, 2, 50),
		list(/obj/item/pickaxe/drill/diamonddrill, 420, 1, 1, 40),
		list(/obj/item/stack/sheet/mineral/diamond, 0, 1, 3, 50, 5),
		list(/obj/item/stack/sheet/bluespace_crystal, 0, 1, 2, 30, 3),
	)
	buy_pool = list(
		/datum/commodity/ore = 1.2,
		/datum/commodity/ore_diamond = 1.2,
		/datum/commodity/gem = 1.25,
		/datum/commodity/plasma = 1.15,
		/datum/commodity/silver = 1.1,
		/datum/commodity/gold = 1.1,
		/datum/commodity/uranium = 1.1,
		/datum/commodity/titanium = 1.1,
		/datum/commodity/diamond = 1.15,
		/datum/commodity/bluespace = 1.15,
	)
	dialogue_greet = list(
		"Got rock? I pay for rock.",
		"Belt's dry this season. Whatever you dig up, I'll take.",
		"Tools are good. Prices are fair. Don't waste my time.",
	)
	dialogue_haggle_accept = list(
		"Hmph. Fine.",
		"Alright. This much.",
		"You dig like you haggle, I hope.",
	)
	dialogue_haggle_final = list("Last price. Take it or leave it.")
	dialogue_haggle_reject = list(
		"No.",
		"Not a chance.",
		"You think rock grows on trees?",
	)
	dialogue_wrong_haggle = list("...Your loss.")
	dialogue_leave = list(
		"Enough. I've got claims to work.",
		"Waste of air. Bye.",
	)
	dialogue_purchase = list("Done. Next supply run.")
	dialogue_no_patience = list("I said last price.")

/datum/trader/ore/generate_name()
	return "Prospector [pick(GLOB.trader_last_names)]"

// MARK: Clothing
/datum/trader/clothing
	title = "travelling tailor"
	icon = "tshirt"
	color = "pink"
	desc = "Sells fashion to stations that have forgotten what it is. Loves a compliment, hates a cheapskate."
	base_patience = list(3, 6)
	hike_tolerance = 30
	sell_pool = list(
		list(/obj/item/clothing/head/beret, 25, 2, 5, 100),
		list(/obj/item/clothing/shoes/laceup, 30, 2, 5, 100),
		list(/obj/item/clothing/accessory/waistcoat, 30, 2, 4, 90),
		list(/obj/item/clothing/head/fedora, 35, 1, 3, 90),
		list(/obj/item/clothing/head/that, 40, 1, 3, 80),
		list(/obj/item/clothing/glasses/sunglasses, 50, 1, 3, 80),
		list(/obj/item/clothing/under/suit_jacket/really_black, 60, 1, 3, 80),
		list(/obj/item/clothing/suit/storage/lawyer/blackjacket, 60, 1, 3, 70),
		list(/obj/item/clothing/under/dress/plaid_blue, 45, 1, 3, 70),
		list(/obj/item/clothing/under/kilt, 35, 1, 2, 60),
		list(/obj/item/clothing/suit/jacket/leather, 90, 1, 2, 60),
		list(/obj/item/clothing/head/hairflower, 10, 3, 8, 60),
		list(/obj/item/clothing/suit/wizrobe/fake, 55, 1, 2, 40),
		list(/obj/item/clothing/head/wizard/fake, 35, 1, 2, 40),
	)
	buy_pool = list(
		/datum/commodity/cloth = 1.2,
		/datum/commodity/leather = 1.25,
		/datum/commodity/durathread = 1.25,
		/datum/commodity/clothing = 1.15,
	)
	dialogue_greet = list(
		"Darlings! Finally, a station in need of my talents.",
		"Oh, those jumpsuits. We can fix this. We can absolutely fix this.",
		"Welcome to the finest boutique this side of the nebula!",
	)
	dialogue_haggle_accept = list(
		"For you? Because you have potential. Here.",
		"Ugh, fine, but only because that colour suits you.",
		"A little discount for a future icon of fashion.",
	)
	dialogue_haggle_final = list(
		"Any lower and I'd have to sell my own scarf. Final price!",
		"That's it, darling. Art has a price.",
	)
	dialogue_haggle_reject = list(
		"Excuse me? This is hand-stitched!",
		"I'm going to pretend I didn't hear that.",
		"Darling, no. Just no.",
	)
	dialogue_wrong_haggle = list("Oh, someone appreciates quality! Done!")
	dialogue_leave = list(
		"I simply can't work with this. Ciao!",
		"I'm wasting my genius here. Farewell!",
	)
	dialogue_purchase = list(
		"Wrapped with love. It comes on your next supply run!",
		"Wear it with confidence, darling.",
	)
	dialogue_no_patience = list("We are done talking money, darling.")

/datum/trader/clothing/generate_name()
	return "[pick("Maison", "Atelier", "House of")] [pick(GLOB.trader_last_names)]"

// MARK: Contraband
/datum/trader/shady
	title = "\"independent importer\""
	icon = "user-secret"
	color = "red"
	desc = "Nobody knows where they come from. The goods are real, the paperwork is not."
	contraband = TRUE
	shady = TRUE
	base_patience = list(2, 4)
	hike_tolerance = 35
	chance_leave = 40
	chance_arrive = 40
	sell_pool = list(
		list(/obj/item/clothing/mask/balaclava, 30, 2, 4, 100),
		list(/obj/item/storage/fancy/cigarettes/cigpack_syndicate, 90, 2, 4, 100),
		list(/obj/item/reagent_containers/food/pill/methamphetamine, 60, 3, 6, 90),
		list(/obj/item/soap/syndie, 70, 1, 3, 80),
		list(/obj/item/clothing/gloves/knuckles, 110, 1, 2, 80),
		list(/obj/item/storage/pill_bottle/random_drug_bottle, 160, 1, 2, 70),
		list(/obj/item/kitchen/knife/combat, 180, 1, 2, 60),
		list(/obj/item/clothing/mask/chameleon, 450, 1, 1, 40),
		list(/obj/item/clothing/under/chameleon, 550, 1, 1, 40),
		list(/obj/item/multitool/ai_detect, 650, 1, 1, 30),
		list(/obj/item/card/id/syndicate, 1600, 1, 1, 15),
	)
	buy_pool = list(
		/datum/commodity/organs = 1.6,
		/datum/commodity/gem = 1.5,
		/datum/commodity/pills = 1.4,
		/datum/commodity/bluespace = 1.3,
	)
	dialogue_greet = list(
		"Psst. You didn't see me, I didn't see you. Now, shopping.",
		"Everything is legal somewhere. Just not here.",
		"Cash, no questions, no receipts. Well, the console makes receipts. Ignore those.",
	)
	dialogue_haggle_accept = list(
		"Heh. Fine. Our little secret.",
		"You're tougher than you look. Deal.",
		"Alright, alright, keep your voice down.",
	)
	dialogue_haggle_final = list("That's the price. Any more and I start asking questions too.")
	dialogue_haggle_reject = list(
		"Don't insult me.",
		"Do I look like a charity?",
		"No. And stop shouting, people will hear.",
	)
	dialogue_wrong_haggle = list(
		"Heh. Pleasure doing business.",
		"Sure, sure. No refunds.",
	)
	dialogue_leave = list(
		"Security channel just lit up. I'm gone.",
		"Too much attention. Later.",
	)
	dialogue_purchase = list(
		"It'll be in the crate under the paperwork. Don't open it in public.",
		"Enjoy. You got it from a friend of a friend.",
	)
	dialogue_no_patience = list("Done talking.")

/datum/trader/shady/generate_name()
	return "\"[pick("Slick", "Whisper", "Lucky", "Shade", "Tinker", "Velvet", "Rook")]\""
