// This is synced up to the poster placing animation.
#define PLACE_SPEED 30

// MARK: The poster item

/obj/item/poster
	name = "rolled-up poster"
	desc = "The poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its vulgar themes have marked it as contraband aboard Nanotrasen space facilities."
	icon = 'icons/obj/contraband.dmi'
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_SMALL
	var/poster_type
	var/obj/structure/sign/poster/poster_structure
	var/is_unfurled = FALSE

/obj/item/poster/Initialize(mapload, obj/structure/sign/poster/new_poster_structure)
	. = ..()
	poster_structure = new_poster_structure
	if(!new_poster_structure && poster_type)
		poster_structure = new poster_type(src)

	update_appearance(UPDATE_ICON_STATE | UPDATE_DESC)

/obj/item/poster/Destroy()
	poster_structure = null
	. = ..()

/obj/item/poster/update_icon_state()
	if(!poster_structure)
		return
	if(is_unfurled)
		icon_state = poster_structure.icon_state
		return
	icon_state = poster_structure.poster_item_icon_state

/obj/item/poster/update_desc()
	. = ..()
	if(!poster_structure)
		return
	if(is_unfurled)
		desc = poster_structure.desc
		return
	desc = poster_structure.poster_item_desc

/obj/item/poster/update_name(updates = ALL)
	. = ..()
	if(!poster_structure)
		return
	if(is_unfurled)
		name = "\"[poster_structure.original_name]\""
		ru_names = poster_structure.ru_names
	else
		name = "rolled-up poster"
		ru_names = null

/obj/item/poster/proc/roll_up(mob/user)
	if(!is_unfurled)
		return
	is_unfurled = FALSE
	update_appearance(UPDATE_ICON_STATE | UPDATE_NAME | UPDATE_DESC)
	playsound(src, 'sound/effects/pageturn3.ogg', 30, TRUE)
	to_chat(user, span_notice("Вы аккуратно сворачиваете постер."))

/obj/item/poster/attack_self(mob/living/user)
	. = ..()
	if(!poster_structure)
		return

	if(is_unfurled)
		roll_up(user)
		return

	is_unfurled = TRUE
	update_appearance(UPDATE_ICON_STATE | UPDATE_NAME | UPDATE_DESC)
	playsound(src, 'sound/effects/pageturn1.ogg', 30, TRUE)
	to_chat(user, span_notice("Вы разворачиваете постер: [poster_structure.original_name]"))

/obj/item/poster/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	roll_up(user)

/obj/item/poster/on_enter_storage(obj/item/storage/S)
	. = ..()
	roll_up()

// These icon_states may be overriden, but are for mapper's convinence
/obj/item/poster/random_contraband
	name = "random contraband poster"
	poster_type = /obj/structure/sign/poster/contraband/random
	icon_state = "rolled_poster"

/obj/item/poster/random_official
	name = "random official poster"
	poster_type = /obj/structure/sign/poster/official/random
	icon_state = "rolled_poster_legit"

/obj/item/poster/syndicate_recruitment
	poster_type = /obj/structure/sign/poster/contraband/syndicate_recruitment
	icon_state = "rolled_poster"

/obj/item/poster/commando
	poster_type = /obj/structure/sign/poster/contraband/commando
	icon_state = "rolled_poster"

/obj/item/poster/cheng
	poster_type = /obj/structure/sign/poster/official/mr_cheng
	icon_state = "rolled_poster"

// MARK: Actual decals

/obj/structure/sign/poster
	name = "poster"
	desc = "A large piece of space-resistant printed paper."
	icon = 'icons/obj/contraband.dmi'
	var/original_name
	var/random_basetype
	var/ruined = FALSE
	var/never_random = FALSE // used for the 'random' subclasses.

	var/poster_item_name = "hypothetical poster"
	var/poster_item_desc = "This hypothetical poster item should not exist, let's be honest here."
	var/poster_item_icon_state = "rolled_poster"

/obj/structure/sign/poster/Initialize(mapload)
	. = ..()
	if(random_basetype)
		randomise(random_basetype)
	if(!ruined)
		original_name = name
		name = "poster — [original_name]"
		desc = "Большой лист устойчивой к космическим условиям печатной бумаги.\n[desc]"
		ru_names = build_poster_ru_names()

/obj/structure/sign/poster/proc/build_poster_ru_names()
	if(!original_name)
		return
	var/alist/base_names = get_ru_names()
	if(!base_names)
		return
	return alist(
		NOMINATIVE = "[base_names[NOMINATIVE]] \"[original_name]\"",
		GENITIVE = "[base_names[GENITIVE]] \"[original_name]\"",
		DATIVE = "[base_names[DATIVE]] \"[original_name]\"",
		ACCUSATIVE = "[base_names[ACCUSATIVE]] \"[original_name]\"",
		INSTRUMENTAL = "[base_names[INSTRUMENTAL]] \"[original_name]\"",
		PREPOSITIONAL = "[base_names[PREPOSITIONAL]] \"[original_name]\"",
	)

/obj/structure/sign/poster/proc/randomise(base_type)
	var/list/poster_types = subtypesof(base_type)
	var/list/approved_types = list()
	for(var/t in poster_types)
		var/obj/structure/sign/poster/T = t
		if(initial(T.icon_state) && !initial(T.never_random))
			approved_types |= T

	var/obj/structure/sign/poster/selected = pick(approved_types)

	name = initial(selected.name)
	desc = initial(selected.desc)
	icon_state = initial(selected.icon_state)
	poster_item_name = initial(selected.poster_item_name)
	poster_item_desc = initial(selected.poster_item_desc)
	poster_item_icon_state = initial(selected.poster_item_icon_state)
	ruined = initial(selected.ruined)

/obj/structure/sign/poster/screwdriver_act()
	return

/obj/structure/sign/poster/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(ruined)
		balloon_alert(user, "вы убираете остатки постера")
		qdel(src)
	else
		balloon_alert(user, "вы аккуратно снимаете постер")
		roll_and_drop(user.loc)

/obj/structure/sign/poster/attack_hand(mob/user)
	if(ruined)
		return
	visible_message("[user] разрывает [declent_ru(NOMINATIVE)] одним решительным движением!")
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, TRUE)

	var/obj/structure/sign/poster/ripped/R = new(loc)
	R.pixel_y = pixel_y
	R.pixel_x = pixel_x
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/sign/poster/proc/roll_and_drop(loc, mob/user)
	if(ruined)
		qdel(src)
		return
	pixel_x = 0
	pixel_y = 0
	var/obj/item/poster/P = new(loc, src)
	if(user)
		transfer_fingerprints_to(P)
	forceMove(P)
	return P

//seperated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/simulated/wall/proc/place_poster(obj/item/poster/P, mob/user)
	if(!P.poster_structure)
		return
	var/stuff_on_wall = 0
	for(var/obj/O in contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(O, /obj/structure/sign/poster))
			balloon_alert(user, "нет места!")
			return
		stuff_on_wall++
		if(stuff_on_wall >= 4)
			balloon_alert(user, "нет места!")
			return

	balloon_alert(user, "размещение...") //Looks like it's uncluttered enough. Place the poster.

	var/obj/structure/sign/poster/D = P.poster_structure

	var/temp_loc = user.loc

	switch(getRelativeDirection(user, src))
		if(NORTH)
			D.pixel_x = 0
			D.pixel_y = 32
		if(EAST)
			D.pixel_x = 32
			D.pixel_y = 0
		if(SOUTH)
			D.pixel_x = 0
			D.pixel_y = -32
		if(WEST)
			D.pixel_x = -32
			D.pixel_y = 0
		else
			balloon_alert(user, "слишком далеко!")
			return

	P.transfer_fingerprints_to(D)
	flick("poster_being_set", D)
	D.forceMove(temp_loc)
	qdel(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 100, TRUE)

	if(do_after(user, PLACE_SPEED, src))
		if(!D || QDELETED(D))
			return

		if(iswallturf(src) && user && user.loc == temp_loc)	//Let's check if everything is still there
			balloon_alert(user, "постер размещён")
			return

	balloon_alert(user, "постер упал!")
	D.roll_and_drop(temp_loc, user)

// MARK: Poster variations

/obj/structure/sign/poster/ripped
	ruined = TRUE
	icon_state = "poster_ripped"
	name = "ripped poster"
	desc = "You can't make out anything from the poster's original print. It's ruined."

/obj/structure/sign/poster/random
	name = "random poster" // could even be ripped
	icon_state = "random_anything"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster

// MARK: Contraband posters
/obj/structure/sign/poster/contraband
	poster_item_name = "contraband poster"
	poster_item_desc = "Этот постер оснащён собственной автоматической клеевой системой для удобного крепления на любую вертикальную поверхность. Его вульгарные темы сделали его контрабандой на объектах \"Нанотрейзен\"."

/obj/structure/sign/poster/contraband/random
	name = "random contraband poster"
	icon_state = "random_contraband"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/contraband

/obj/structure/sign/poster/contraband/free_tonto
	name = "Free Tonto"
	desc = "A salvaged shred of a much larger flag, colors bled together and faded from age."
	icon_state = "poster1"

/obj/structure/sign/poster/contraband/atmosia_independence
	name = "Atmosia Declaration of Independence"
	desc = "A relic of a failed rebellion."
	icon_state = "poster2"

/obj/structure/sign/poster/contraband/fun_police
	name = "Fun Police"
	desc = "A poster condemning the station's security forces."
	icon_state = "poster3"

/obj/structure/sign/poster/contraband/lusty_xenomorph
	name = "Lusty Xenomorph"
	desc = "A heretical poster depicting the titular star of an equally heretical book."
	icon_state = "poster4"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/lusty_xenomorph, 32, 32)

/obj/structure/sign/poster/contraband/syndicate_recruitment
	name = "Syndicate Recruitment"
	desc = "See the galaxy! Shatter corrupt megacorporations! Join today!"
	icon_state = "poster5"

/obj/structure/sign/poster/contraband/clown
	name = "Clown"
	desc = "Honk."
	icon_state = "poster6"

/obj/structure/sign/poster/contraband/smoke
	name = "Smoke"
	desc = "A poster advertising a rival corporate brand of cigarettes."
	icon_state = "poster7"

/obj/structure/sign/poster/contraband/grey_tide
	name = "Grey Tide"
	desc = "A rebellious poster symbolizing assistant solidarity."
	icon_state = "poster8"

/obj/structure/sign/poster/contraband/missing_gloves
	name = "Missing Gloves"
	desc = "This poster references the uproar that followed Nanotrasen's financial cuts toward insulated-glove purchases."
	icon_state = "poster9"

/obj/structure/sign/poster/contraband/hacking_guide
	name = "Hacking Guide"
	desc = "This poster details the internal workings of the common Nanotrasen airlock. Sadly, it appears out of date."
	icon_state = "poster10"

/obj/structure/sign/poster/contraband/rip_badger
	name = "RIP Badger"
	desc = "This seditious poster references Nanotrasen's genocide of a space station full of badgers."
	icon_state = "poster11"

/obj/structure/sign/poster/contraband/ambrosia_vulgaris
	name = "Ambrosia Vulgaris"
	desc = "This poster is lookin' pretty trippy man."
	icon_state = "poster12"

/obj/structure/sign/poster/contraband/donut_corp
	name = "Donut Corp."
	desc = "This poster is an unauthorized advertisement for Donut Corp."
	icon_state = "poster13"

/obj/structure/sign/poster/contraband/eat
	name = "EAT."
	desc = "This poster promotes rank gluttony."
	icon_state = "poster14"

/obj/structure/sign/poster/contraband/tools
	name = "Tools"
	desc = "This poster looks like an advertisement for tools, but is in fact a subliminal jab at the tools at CentComm."
	icon_state = "poster15"

/obj/structure/sign/poster/contraband/power
	name = "Power"
	desc = "A poster that positions the seat of power outside Nanotrasen."
	icon_state = "poster16"

/obj/structure/sign/poster/contraband/power_people
	name = "Power to the people"
	desc = "Screw those EDF guys!"
	icon_state = "poster17"

/obj/structure/sign/poster/contraband/communist_state
	name = "Communist State"
	desc = "All hail the Communist party!"
	icon_state = "poster18"

/obj/structure/sign/poster/contraband/lamarr
	name = "Lamarr"
	desc = "This poster depicts Lamarr. Probably made by a traitorous Research Director."
	icon_state = "poster19"

/obj/structure/sign/poster/contraband/borg_fancy_1
	name = "Borg Fancy"
	desc = "Being fancy can be for any borg, just need a suit."
	icon_state = "poster20"

/obj/structure/sign/poster/contraband/borg_fancy_2
	name = "Borg Fancy v2"
	desc = "Borg Fancy, Now only taking the most fancy."
	icon_state = "poster21"

/obj/structure/sign/poster/contraband/kss13
	name = "Kosmicheskaya Stantsiya 13 Does Not Exist"
	desc = "A poster mocking CentComm's denial of the existence of the derelict station near Space Station 13."
	icon_state = "poster22"

/obj/structure/sign/poster/contraband/rebels_unite
	name = "Rebels Unite"
	desc = "A poster urging the viewer to rebel against Nanotrasen."
	icon_state = "poster23"

/obj/structure/sign/poster/contraband/c20r
	name = "C-20r"
	desc = "A poster advertising the Scarborough Arms C-20r."
	icon_state = "poster24"

/obj/structure/sign/poster/contraband/have_a_puff
	name = "Have a Puff"
	desc = "Who cares about lung cancer when you're high as a kite?"
	icon_state = "poster25"

/obj/structure/sign/poster/contraband/revolver
	name = "Revolver"
	desc = "Because seven shots are all you need."
	icon_state = "poster26"

/obj/structure/sign/poster/contraband/d_day_promo
	name = "D-Day Promo"
	desc = "A promotional poster for some rapper."
	icon_state = "poster27"

/obj/structure/sign/poster/contraband/syndicate_pistol
	name = "Syndicate Pistol"
	desc = "A poster advertising syndicate pistols as being 'classy as fuck'. It is covered in faded gang tags."
	icon_state = "poster28"

/obj/structure/sign/poster/contraband/energy_swords
	name = "Energy Swords"
	desc = "All the colors of the bloody murder rainbow."
	icon_state = "poster29"

/obj/structure/sign/poster/contraband/red_rum
	name = "Red Rum"
	desc = "Looking at this poster makes you want to kill."
	icon_state = "poster30"

/obj/structure/sign/poster/contraband/cc64k_ad
	name = "CC 64K Ad"
	desc = "The latest portable computer from Comrade Computing, with a whole 64kB of ram!"
	icon_state = "poster31"

/obj/structure/sign/poster/contraband/punch_shit
	name = "Punch Shit"
	desc = "Fight things for no reason, like a man!"
	icon_state = "poster32"

/obj/structure/sign/poster/contraband/the_griffin
	name = "The Griffin"
	desc = "The Griffin commands you to be the worst you can be. Will you?"
	icon_state = "poster33"

/obj/structure/sign/poster/contraband/pinup_syn
	name = "Pinup Girl Cindy Kate"
	desc = "This particular one is of Cindy Kate, a seductive performer well known among less savoury circles."
	icon_state = "poster34"

/obj/structure/sign/poster/contraband/wanted
	name = "Water Potassuimovich"
	desc = "On the poster you can see: a bald, black-eyed men, age 30, and he is wanted in the vastness of the entire space. What did he do to be so wanted... "
	icon_state = "poster35"

/obj/structure/sign/poster/contraband/very_robust
	name = "Very Robust"
	desc = "You see a slightly battered poster, which shows a RED toolbox and the inscription \"Danger, very robust!\", some people say that this red paint on the poster is made of real blood."
	icon_state = "poster36"

/obj/structure/sign/poster/contraband/commando
	name = "Commandos"
	desc = "You see a muscular man in combat gear. Just the sight of this poster brings the scent of true masculinity."
	icon_state = "poster37"

/obj/structure/sign/poster/contraband/lostcat
	name = "Lost Cat"
	desc = "Kisik got lost. Armed and dangerous."
	icon_state = "poster38"

/obj/structure/sign/poster/contraband/bad_guy
	name = "Bad Guy"
	desc = "Smoking time. On a poster you can see grub with cigarette that promote people to have a cig and smoke on work."
	icon_state = "poster39"

/obj/structure/sign/poster/contraband/ninja
	name = "Space Ninja"
	desc = "This is a poster depicting the main character of the most popular animated series in the galaxy, \"Space Ninja\". The inscription on it says that the new season will start soon."
	icon_state = "poster40"

/obj/structure/sign/poster/contraband/Enlist_Syndicate
	name = "Enlist Syndicate"
	desc = "See the galaxy! Shatter corrupt megacorporations! Get paid! Join today!"
	icon_state = "poster41"

/obj/structure/sign/poster/contraband/Enlist_Gorlex
	name = "Enlist"
	desc = "Enlist with the Gorlex Marauders today! See the galaxy, kill corpos, get paid!"
	icon_state = "poster42"

/obj/structure/sign/poster/contraband/armor
	name = "Armor"
	desc = "A poster depicting an assistant in some kind of improvised armor. It looks bulky."
	icon_state = "poster_armor"

/obj/structure/sign/poster/contraband/graytech
	name = "Gray tech"
	desc = "A counterfeit welding-tool sword made by the dubious manufacturer Gray Tech."
	icon_state = "poster_graytech"

/obj/structure/sign/poster/contraband/bomb
	name = "Explosive Shell"
	desc = "A design for an improvised explosive shell using ingredients found at almost any facility."
	icon_state = "poster_bomb"

/obj/structure/sign/poster/contraband/bombarda
	name = "Bombarda"
	desc = "A blueprint and detailed guide to building and operating an improvised Bombarda grenade launcher. Someone has crossed out part of the name and written Bombaga above it."
	icon_state = "poster_bombarda"

/obj/structure/sign/poster/contraband/frag12
	name = "FRAG12"
	desc = "An overview of the construction and payload of the particularly dangerous FRAG12 shell. The section describing its damage is highlighted in red."
	icon_state = "poster_frag12"

/obj/structure/sign/poster/contraband/incammo
	name = "Incendiary Shell"
	desc = "A design for an improvised incendiary shell using ingredients found at almost any facility."
	icon_state = "poster_incammo"

/obj/structure/sign/poster/contraband/overload
	name = "Explosive Buckshot"
	desc = "Unstable explosive buckshot: the high-explosive equivalent of playing Russian roulette with a Makarov on behalf of the entire department, packaged as a shotgun shell."
	icon_state = "poster_overload"

/obj/structure/sign/poster/contraband/handmaderevolver
	name = "Improvised Revolver"
	desc = "A weapon for grey cowboys and desperate duelists, with a complete technical guide to its construction and use."
	icon_state = "poster_revolver"

/obj/structure/sign/poster/contraband/shotgun
	name = "Improvised Shotgun"
	desc = "When it comes to getting things done, it pays to bring something more serious."
	icon_state = "poster_shotgun"

/obj/structure/sign/poster/contraband/smokebomb
	name = "Smoke Shell"
	desc = "Help with getting out of a bad situation."
	icon_state = "poster_smokebomb"

/obj/structure/sign/poster/contraband/buckshot
	name = "Improvised Buckshot"
	desc = "A general schematic showing the internal arrangement of buckshot components. Always at hand, and always works!"
	icon_state = "poster_buckshot"

/obj/structure/sign/poster/contraband/handmadeammo
	name = "Improvised Cartridge"
	desc = "A schematic describing how to manufacture a pistol cartridge with limited materials."
	icon_state = "poster_handmadeammo"

/obj/structure/sign/poster/contraband/phosphorusammo
	name = "Phosphorus Cartridge"
	desc = "A phosphorus-modified version of an improvised pistol cartridge. Red lettering reads: Protect your eyes!"
	icon_state = "poster_phosphorusammo"

/obj/structure/sign/poster/contraband/flamethrower
	name = "Flamethrower"
	desc = "Now you are the arsonist. An extremely dangerous weapon for everyone, including its user."
	icon_state = "poster_flamethrower"

/obj/structure/sign/poster/contraband/bigbrother
	name = "Big Brother"
	desc = "Freedom is slavery. The corporation believes that personal freedom leads to chaos and disorder, and that true freedom can only be achieved through complete submission to the corporation."
	icon_state = "poster_bigbrother"

/obj/structure/sign/poster/contraband/slave
	name = "Slavery"
	desc = "Symbolizes extreme totalitarianism and the desire to control every action and thought of the workforce."
	icon_state = "poster_slave"

/obj/structure/sign/poster/contraband/graytide
	name = "Mastered the Greytide"
	desc = "A picture of an assistant demonstrating mastery of a bombarda, a stunprod and a spear."
	icon_state = "poster_graytide"

/obj/structure/sign/poster/contraband/imposter
	name = "I Am a Poster"
	desc = "This poster certainly does not promise good news. Could there be a traitor among us?"
	icon_state = "im_poster"

/obj/structure/sign/poster/contraband/bread
	name = "Divine Punishment"
	desc = "Man lives by bread alone."
	icon_state = "bread"

/obj/structure/sign/poster/contraband/cone
	name = "Cone"
	desc = "An advertisement for a jazz session by the Man with the Traffic Cone."
	icon_state = "cone"

/obj/structure/sign/poster/contraband/felinid_smokers
	name = "Smoking Felinids"
	desc = "A poster of felinids relaxing on your station."
	icon_state = "felinid_smokers"

/obj/structure/sign/poster/contraband/kerberos_show
	name = "The Kerberos Show"
	desc = "Remember that none of this, including your life, is real."
	icon_state = "kerberos_show"

/obj/structure/sign/poster/contraband/valve
	name = "Valve"
	desc = "A poster encouraging you to open your eyes and your mind."
	icon_state = "valve"

/obj/structure/sign/poster/contraband/night_cat_blues
	name = "Midnight Cat"
	desc = "A minimalist image of a cat stretching in the twilight of Venus."
	icon_state = "night_cat_blues"

/obj/structure/sign/poster/contraband/worm
	name = "Worms"
	desc = "A chance to appear in every apple and every heart!"
	icon_state = "worm"

/obj/structure/sign/poster/contraband/syndicate_s
	name = "Syndicate Holding Company Logo"
	desc = "Muted red and crimson surround a black, monolithic letter S, recognized by mercenary organizations throughout the frontier and inhabited space. This holding company once bombed a Nanotrasen ship in Epsilon Eridani, prompting Nanotrasen to hastily withdraw and relocate its operations to neighboring Epsilon Lucustae."
	icon_state = "syndicate"

/obj/structure/sign/poster/contraband/quadra
	name = "Quadra Private Military Corporation Soldier"
	desc = "A man in black-and-red equipment stares at you through his helmet's visor, his gaze chilling you to the bone. Quadra is known for professional mercenaries who operate throughout the frontier, wreaking havoc on TSF, Nanotrasen and any other corporation daring to encroach on their territory. Their commander, Zenit, is rumored to be a supervising officer of the Syndicate's Board of Directors, making Quadra one of the frontier's most dangerous mercenary organizations."
	icon_state = "quadra"

/obj/structure/sign/poster/contraband/syndicate2
	name = "Syndicate Holding Company Recruitment Poster"
	desc = "Familiar blood-red tones surround a pitch-black snake shaped like an S. Below it, faded recruitment slogans read: The corporations stole your soul! They took away your right to exist! Wake up! Lift your head, cast off the burden of endless work, and join the holding company's free agents!"
	icon_state = "syndicate2"

/obj/structure/sign/poster/contraband/cattraction
	name = "Center of Attraction Photo Poster"
	desc = "A photograph of a concrete wall bearing the familiar Syndicate snake, apparently drawn in blood and enclosed in a star. The slogan beneath it reads: The Syndicate is a gathering place for universal evil! A note in the corner says: Photographed in Epsilon Lucustae."
	icon_state = "cattraction"

/obj/structure/sign/poster/contraband/gorlex_marauder
	name = "Gorlex Marauder"
	desc = "An unknown figure in the infamous hardsuit of the Gorlex Marauders watches you from crimson-black darkness. Half their body is lit by a red energy blade. The thought of the physical and moral monsters hired by Gorlex handlers makes you shiver. Good thing you work on the sector's quietest station..."
	icon_state = "gorlex_marauder"

/obj/structure/sign/poster/contraband/poster_donkko
	name = "Donk Co. Children's Poster"
	desc = "A little figure drawn in the style of a long-forgotten children's game from Earth stares out from this poster. Its cartoon Gorlex Marauder EVA suit looks more funny than frightening. Apparently the Syndicate starts recruiting in childhood."
	icon_state = "susposter"

/obj/structure/sign/poster/contraband/susposter
	name = "New Flavors from Donk Co."
	desc = "A poster advertising new donk-pocket flavors."
	icon_state = "poster_donkko"


//MARK: Official posters
/obj/structure/sign/poster/official
	poster_item_name = "motivational poster"
	poster_item_desc = "Официальный постер от \"Нанотрейзен\", призванный воспитывать покорную и послушную рабочую силу. Оснащён передовой клеевой основой для удобного крепления на любую вертикальную поверхность."
	poster_item_icon_state = "rolled_poster_legit"

/obj/structure/sign/poster/official/random
	name = "random official poster"
	random_basetype = /obj/structure/sign/poster/official
	icon_state = "random_official"
	never_random = TRUE

/obj/structure/sign/poster/official/here_for_your_safety
	name = "Here For Your Safety"
	desc = "A poster glorifying the station's security force."
	icon_state = "poster1_legit"

/obj/structure/sign/poster/official/nanotrasen_logo
	name = "Nanotrasen Logo"
	desc = "A poster depicting the Nanotrasen logo."
	icon_state = "poster2_legit"

/obj/structure/sign/poster/official/cleanliness
	name = "Cleanliness"
	desc = "A poster warning of the dangers of poor hygiene."
	icon_state = "poster3_legit"

/obj/structure/sign/poster/official/help_others
	name = "Help Others"
	desc = "A poster encouraging you to help fellow crewmembers."
	icon_state = "poster4_legit"

/obj/structure/sign/poster/official/build
	name = "Build"
	desc = "A poster glorifying the engineering team."
	icon_state = "poster5_legit"

/obj/structure/sign/poster/official/bless_this_spess
	name = "Bless This Spess"
	desc = "A poster blessing this area."
	icon_state = "poster6_legit"

/obj/structure/sign/poster/official/science
	name = "Science"
	desc = "A poster depicting an atom."
	icon_state = "poster7_legit"

/obj/structure/sign/poster/official/ian
	name = "Ian"
	desc = "Arf arf. Yap."
	icon_state = "poster8_legit"

/obj/structure/sign/poster/official/obey
	name = "Obey"
	desc = "A poster instructing the viewer to obey authority."
	icon_state = "poster9_legit"

/obj/structure/sign/poster/official/walk
	name = "Walk"
	desc = "A poster instructing the viewer to walk instead of running."
	icon_state = "poster10_legit"

/obj/structure/sign/poster/official/state_laws
	name = "State Laws"
	desc = "A poster instructing cyborgs to state their laws."
	icon_state = "poster11_legit"

/obj/structure/sign/poster/official/love_ian
	name = "Love Ian"
	desc = "Ian is love, Ian is life."
	icon_state = "poster12_legit"

/obj/structure/sign/poster/official/space_cops
	name = "Space Cops."
	desc = "A poster advertising the television show Space Cops."
	icon_state = "poster13_legit"

/obj/structure/sign/poster/official/ue_no
	name = "Ue No."
	desc = "This thing is all in Japanese."
	icon_state = "poster14_legit"

/obj/structure/sign/poster/official/get_your_legs
	name = "Get Your LEGS"
	desc = "LEGS: Leadership, Experience, Genius, Subordination."
	icon_state = "poster15_legit"

/obj/structure/sign/poster/official/do_not_question
	name = "Do Not Question"
	desc = "A poster instructing the viewer not to ask about things they aren't meant to know."
	icon_state = "poster16_legit"

/obj/structure/sign/poster/official/work_for_a_future
	name = "Work For A Future"
	desc = "A poster encouraging you to work for your future."
	icon_state = "poster17_legit"

/obj/structure/sign/poster/official/soft_cap_pop_art
	name = "Soft Cap Pop Art"
	desc = "A poster reprint of some cheap pop art."
	icon_state = "poster18_legit"

/obj/structure/sign/poster/official/safety_internals
	name = "Safety: Internals"
	desc = "A poster instructing the viewer to wear internals in the rare environments where there is no oxygen or the air has been rendered toxic."
	icon_state = "poster19_legit"

/obj/structure/sign/poster/official/safety_eye_protection
	name = "Safety: Eye Protection"
	desc = "A poster instructing the viewer to wear eye protection when dealing with chemicals, smoke, or bright lights."
	icon_state = "poster20_legit"

/obj/structure/sign/poster/official/safety_report
	name = "Safety: Report"
	desc = "A poster instructing the viewer to report suspicious activity to the security force."
	icon_state = "poster21_legit"

/obj/structure/sign/poster/official/report_crimes
	name = "Report Crimes"
	desc = "A poster encouraging the swift reporting of crime or seditious behavior to station security."
	icon_state = "poster22_legit"

/obj/structure/sign/poster/official/ion_rifle
	name = "Ion Rifle"
	desc = "A poster displaying an Ion Rifle."
	icon_state = "poster23_legit"

/obj/structure/sign/poster/official/foam_force_ad
	name = "Foam Force Ad"
	desc = "Foam Force, it's Foam or be Foamed!"
	icon_state = "poster24_legit"

/obj/structure/sign/poster/official/cohiba_robusto_ad
	name = "Cohiba Robusto Ad"
	desc = "Cohiba Robusto, the classy cigar."
	icon_state = "poster25_legit"

/obj/structure/sign/poster/official/anniversary_vintage_reprint
	name = "50th Anniversary Vintage Reprint"
	desc = "A reprint of a poster from 2505, commemorating the 50th Anniversery of Nanoposters Manufacturing, a subsidiary of Nanotrasen."
	icon_state = "poster26_legit"

/obj/structure/sign/poster/official/fruit_bowl
	name = "Fruit Bowl"
	desc = "Simple, yet awe-inspiring."
	icon_state = "poster27_legit"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/fruit_bowl, 32, 32)

/obj/structure/sign/poster/official/pda_ad
	name = "PDA Ad"
	desc = "A poster advertising the latest PDA from Nanotrasen suppliers."
	icon_state = "poster28_legit"

/obj/structure/sign/poster/official/enlist
	name = "Enlist"
	desc = "Enlist in the Nanotrasen ERT reserves today!"
	icon_state = "poster29_legit"

/obj/structure/sign/poster/official/nanomichi_ad
	name = "Nanomichi Ad"
	desc = "A poster advertising Nanomichi brand audio cassettes."
	icon_state = "poster30_legit"

/obj/structure/sign/poster/official/twelve_gauge
	name = "12 Gauge"
	desc = "A poster boasting about the superiority of 12 gauge shotgun shells."
	icon_state = "poster31_legit"

/obj/structure/sign/poster/official/high_class_martini
	name = "High-Class Martini"
	desc = "I told you to shake it, no stirring."
	icon_state = "poster32_legit"

/obj/structure/sign/poster/official/the_owl
	name = "The Owl"
	desc = "The Owl would do his best to protect the station. Will you?"
	icon_state = "poster33_legit"

/obj/structure/sign/poster/official/spiders
	name = "Spider Risk"
	desc = "A poster detailing what to do when giant spiders are seen."
	icon_state = "poster34_legit"

/obj/structure/sign/poster/official/kill_syndicate
	name = "Kill Syndicate"
	desc = "A poster demanding that all crew should be ready to fight the Syndicate."
	icon_state = "poster35_legit"

/obj/structure/sign/poster/official/air1
	name = "Information on Air"
	desc = "A poster providing visual aid to remind crew of air canisters."
	icon_state = "poster36_legit"

/obj/structure/sign/poster/official/air2
	name = "Information on Air"
	desc = "A poster providing visual aid to remind crew of air canisters."
	icon_state = "poster37_legit"

/obj/structure/sign/poster/official/dig
	name = "Dig for Glory!"
	desc = "A poster trying to convince the crew to mine for ore."
	icon_state = "poster38_legit"

/obj/structure/sign/poster/official/religious
	name = "Religious Poster"
	desc = "A generic religious poster telling you to believe."
	icon_state = "poster39_legit"

/obj/structure/sign/poster/official/healthy
	name = "Stay Healthy!"
	desc = "A healthy crew is a happy crew!"
	icon_state = "poster40_legit"

/obj/structure/sign/poster/official/vodka
	name = "Bodka"
	desc = "Advertising poster of vodka, drink from real men for real men. Feel like a space bear."
	icon_state = "poster41_legit"

/obj/structure/sign/poster/official/tsf_emblem
	name = "TSF Emblem"
	desc = "Patriotic poster with an emblem of TSF and some dull text for marine honor on it."
	icon_state = "poster42_legit"

/obj/structure/sign/poster/official/wetskrell
	name = "WetSkrell"
	desc = "You can see a pretty skrell in red dress and with long headtails, which have decorative bands. It is advertising a site with \"adult recreation procedures\", the wetskrell.nt."
	icon_state = "poster43_legit"

/obj/structure/sign/poster/official/keepcalm
	name = "Keep Calm"
	desc = "This particular one is of a famous New Earth design, although a bit modified. Someone has scribbled an O over the A on the poster."
	icon_state = "poster44_legit"

/obj/structure/sign/poster/official/pinup_a
	name = "Pinup Girl Cindy"
	desc = "This particular one is of a historical corporate PR girl, Cindy, in a particularly feminine pose."
	icon_state = "poster45_legit"

/obj/structure/sign/poster/official/pinup_b
	name = "Pinup Girl Amy"
	desc = "This particular one is of Amy, the nymphomaniac urban legend of deep space. How this photograph came to be is not known."
	icon_state = "poster46_legit"

/obj/structure/sign/poster/official/insp_law
	name = "Inspirational Lawyer"
	desc = "An inspirational poster depicting a Skrellian lawyer. He seems to be shouting something, while pointing fiercely to the right."
	icon_state = "poster47_legit"

/obj/structure/sign/poster/official/space_a
	name = "Space Appreciation Poster"
	desc = "This is a poster produced by the Generic Space Company, as a part of a series of commemorative posters on the wonders of space. One of three."
	icon_state = "poster48_legit"

/obj/structure/sign/poster/official/space_b
	name = "Mars Appreciation Poster"
	desc = "This is a poster produced by the Generic Space Company, as a part of a series of commemorative posters on the wonders of space. Three of three."
	icon_state = "poster49_legit"

/obj/structure/sign/poster/official/wild_west
	name = "Wild Cargo"
	desc = "The beautiful wild place with their own sheriff."
	icon_state = "poster50_legit"

/obj/structure/sign/poster/official/razumause
	name = "Razumause"
	desc = "Hey hey! What`s can go wrong, yeah?"
	icon_state = "poster51_legit"

/obj/structure/sign/poster/official/assist_pride
	name = "Assistant pride"
	desc = "Even in space, the profession of assistant is in demand. And this poster shows you their beauty."
	icon_state = "poster52_legit"

/obj/structure/sign/poster/official/mr_cheng
	name = "Mr. Cheng!"
	desc = "Stunning discounts! The best product quality! Good prices for lots and lots of goods! Only Mr. Cheng."
	icon_state = "poster53_legit"

/obj/structure/sign/poster/official/cargotech
	name = "Mastered It"
	desc = "A cargo technician demonstrates mastery of MULEbots, the ordering console and the delivery system."
	icon_state = "poster_cargo"

/obj/structure/sign/poster/official/cargogorilas
	name = "Cargorillaz"
	desc = "A poster featuring the rock band Cargorillaz. Perhaps their success inspired Nanotrasen to give every station a pet named Mars."
	icon_state = "poster_cargogorilas"

/obj/structure/sign/poster/official/cargofriends
	name = "Cargo Technicians"
	desc = "This poster shows that cargo is more than a job: it is a way to make new friends."
	icon_state = "poster_cargofriends"

/obj/structure/sign/poster/official/mge
	name = "Muscular Cargo Technician"
	desc = "A muscular cargo technician declares: Work harder, and you can be this buff too!"
	icon_state = "poster_mge"

/obj/structure/sign/poster/official/qm
	name = "Quartermistress"
	desc = "A quartermistress encourages you to work in the Supply Department."
	icon_state = "poster_qm"

/obj/structure/sign/poster/official/minegem
	name = "BRING IT"
	desc = "A picture of a precious gemstone, with a small caption suggesting that you bring it to the Supply Department."
	icon_state = "poster_minegem"

/obj/structure/sign/poster/official/kurit
	name = "Smoking Smokes You"
	desc = "THINK ABOUT IT."
	icon_state = "kurit"

/obj/structure/sign/poster/official/breakfast
	name = "Breakfast"
	desc = "MMM, FOOD..."
	icon_state = "breakfast"

/obj/structure/sign/poster/official/krill
	name = "Krill"
	desc = "There is only one of me in this whole world. One in a krillion."
	icon_state = "krill"

/obj/structure/sign/poster/official/selected_ambient_works
	name = "Selected Ambient Works 85–92"
	desc = "A poster of a strange-looking faucet. Or is it a horse?.."
	icon_state = "selected_ambient_works"

/obj/structure/sign/poster/official/tell_all_the_people
	name = "Tell All The People"
	desc = "Tell them not to follow me."
	icon_state = "tell_all_the_people"

/obj/structure/sign/poster/official/sweet_ginger_green
	name = "Sweet Ginger Green"
	desc = "When you don't know what to listen to at work, put on Sweet Ginger Green!"
	icon_state = "sweet_ginger_green"

/obj/structure/sign/poster/official/vine_lady
	name = "Vine Lady"
	desc = "The poster depicts a refined lady holding a glass of wine."
	icon_state = "vine_lady"

/obj/structure/sign/poster/official/a_broken_frame
	name = "A Broken Frame"
	desc = "Looking for posters in fashion magazines."
	icon_state = "a_broken_frame"

/obj/structure/sign/poster/official/fight_songs
	name = "Fight Songs"
	desc = "A critical hit to the eardrums."
	icon_state = "fight_songs"

/obj/structure/sign/poster/official/rolling_stones
	name = "The Rolling Stones"
	desc = "Where are they rolling?"
	icon_state = "rolling_stones"

/obj/structure/sign/poster/official/richard_d_james
	name = "Richard D. James"
	desc = "What a handsome young man. I wonder what music he listens to?"
	icon_state = "richard_d_james"

/obj/structure/sign/poster/official/alberto_balsalm
	name = "Alberto Balsalm"
	desc = "The best hair conditioner in the galaxy!"
	icon_state = "alberto_balsalm"

/obj/structure/sign/poster/official/corploveyou
	name = "The Corporation Loves You!"
	desc = "A charming assistant makes a heart with her hands, reminding everyone that the corporation loves its employees!"
	icon_state = "corploveyou"

/obj/structure/sign/poster/official/explosionsafe
	name = "Explosions? Nonsense!"
	desc = "This assistant has no reason to fear lies about stations being bombed! Neither do you!"
	icon_state = "explosionsafe"

/obj/structure/sign/poster/official/clearstation
	name = "Clean Station"
	desc = "A clean station means a healthy crew! Away with dirt and rubbish! Clean hands and a tidy appearance are the way to go!"
	icon_state = "clearstation"

/obj/structure/sign/poster/official/safebody
	name = "Protective Equipment"
	desc = "This assistant is wearing a hard hat. Are you? Protect yourself from workplace hazards!"
	icon_state = "safebody"

/obj/structure/sign/poster/official/fitness
	name = "Stay Fit"
	desc = "This assistant exercises to make her work more efficient!"
	icon_state = "fitness"

/obj/structure/sign/poster/official/hardwork
	name = "Hard Work"
	desc = "You can't catch a space carp without effort. This assistant is ready to work hard to reach her goal!"
	icon_state = "hardwork"

// MARK: Secret posters

/obj/structure/sign/poster/secret
	poster_item_name = "Secret poster"
	poster_item_desc = "Крайне Секретный постер."

/obj/structure/sign/poster/secret/lady
	name = "Scientist lady"
	desc = "A gorgeous looking lady wearing a labcoat. Whoah, hot!"
	icon_state = "poster1_secret"

/obj/structure/sign/poster/secret/Viper
	name = "Wanted Syndicate Officer"
	desc = "On the poster you can see: A red-haired man in aviator glasses, slightly over 30, with a cigar in his mouth, dressed in a fur coat over a tactical turtleneck."
	icon_state = "poster2_secret"

/obj/structure/sign/poster/secret/lizard
	name = "Lewd Lizard"
	desc = "This lewd poster depicts a lizard preparing to mate."
	icon_state = "poster3_secret"

/obj/structure/sign/poster/secret/sexiqm
	name = "Modest Quartermistress"
	desc = "The poster depicts a modest young woman in a quartermaster's dress, sitting on that very crate."
	icon_state = "poster4_secret"

#undef PLACE_SPEED
