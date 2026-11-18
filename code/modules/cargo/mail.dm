// Station mail, an idea from Goonstation 13. Sprites are CC BY-NC-SA 3.0 (docs/GOON_ASSETS.md),
// built by tools/goon_ports/extras.py; the code is our own.
//
// Every MAIL_INTERVAL the next supply shuttle to dock at the station brings a crate of mail.
// Each package is addressed to a living crew member and DNA-locked to them. Inside is a small gift,
// picked from their department's list half of the time. Cargo gets paid for every package its owner opens.
// Anyone else can force a package open with something sharp, which tears it up and is logged as mail fraud.

#define MAIL_INTERVAL (15 MINUTES)
/// Share of the living crew that gets a package in each delivery (Goon aims for about three per player per hour).
#define MAIL_CREW_SHARE 0.375
#define MAIL_MAX_PER_DELIVERY 40
#define MAIL_PAYOUT_BASE 50
#define MAIL_PAYOUT_STEP 10
#define MAIL_PAYOUT_MAX 500

GLOBAL_VAR_INIT(next_mail_delivery, MAIL_INTERVAL)
GLOBAL_VAR_INIT(mail_opened, 0)

GLOBAL_LIST_INIT(mail_gifts_everyone, list(
	/obj/item/reagent_containers/food/snacks/candy/candybar = 4,
	/obj/item/reagent_containers/food/snacks/chocolatebar = 3,
	/obj/item/reagent_containers/food/snacks/cookie = 3,
	/obj/item/reagent_containers/food/snacks/donkpocket = 2,
	/obj/item/reagent_containers/cup/soda_cans/cola = 4,
	/obj/item/reagent_containers/cup/soda_cans/energy = 2,
	/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee = 2,
	/obj/item/storage/fancy/cigarettes/cigpack_random = 2,
	/obj/item/lighter/random = 2,
	/obj/item/deck/cards = 2,
	/obj/item/storage/fancy/crayons = 1,
	/obj/item/stack/spacecash/c100 = 1,
	/obj/item/coin/gold = 1,
))

GLOBAL_LIST_INIT(mail_gifts_by_department, list(
	"command" = list(
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 3,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 2,
		/obj/item/reagent_containers/cup/glass/bottle/whiskey = 2,
		/obj/item/lighter/zippo = 2,
		/obj/item/pen/fountain = 2,
		/obj/item/flash = 1,
	),
	"security" = list(
		/obj/item/storage/fancy/donut_box = 4,
		/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee = 3,
		/obj/item/reagent_containers/cup/soda_cans/energy = 3,
		/obj/item/flash = 2,
		/obj/item/stack/medical/bruise_pack = 1,
	),
	"engineering" = list(
		/obj/item/stack/cable_coil/random = 4,
		/obj/item/tank/internals/emergency_oxygen = 3,
		/obj/item/stock_parts/cell/high = 2,
		/obj/item/reagent_containers/cup/soda_cans/energy = 2,
		/obj/item/clothing/glasses/welding = 1,
		/obj/item/clothing/gloves/color/fyellow = 1,
	),
	"medical" = list(
		/obj/item/stack/medical/bruise_pack = 3,
		/obj/item/stack/medical/ointment = 3,
		/obj/item/clothing/gloves/color/latex = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/charcoal = 2,
		/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee = 2,
	),
	"science" = list(
		/obj/item/reagent_containers/cup/beaker/large = 3,
		/obj/item/stock_parts/cell/high = 2,
		/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee = 2,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 2,
	),
	"supply" = list(
		/obj/item/stack/packageWrap = 3,
		/obj/item/hand_labeler = 2,
		/obj/item/reagent_containers/cup/soda_cans/energy = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_random = 2,
		/obj/item/stack/spacecash/c100 = 1,
	),
	"service" = list(
		/obj/item/seeds/random = 3,
		/obj/item/reagent_containers/spray/cleaner = 2,
		/obj/item/reagent_containers/cup/glass/bottle/wine = 2,
		/obj/item/reagent_containers/food/snacks/cookie = 2,
		/obj/item/reagent_containers/food/snacks/grown/poppy = 2,
	),
))

/// Package colour per department, a pale tint like Goon's.
GLOBAL_LIST_INIT(mail_department_colors, list(
	"command" = "#bcdcff",
	"security" = "#ffb3b3",
	"engineering" = "#ffe6a3",
	"medical" = "#c4e4ff",
	"science" = "#e2c4ff",
	"supply" = "#f0d0a8",
	"service" = "#c8f0c0",
))

/proc/mail_department_of(job_title)
	if(job_title in GLOB.command_positions)
		return "command"
	if(job_title in GLOB.security_positions)
		return "security"
	if(job_title in GLOB.engineering_positions)
		return "engineering"
	if(job_title in GLOB.medical_positions)
		return "medical"
	if(job_title in GLOB.science_positions)
		return "science"
	if(job_title in GLOB.supply_positions)
		return "supply"
	if(job_title in GLOB.service_positions)
		return "service"
	return null

/// Makes up to `amount` packages for living crew, at `where`. Returns the packages.
/proc/create_station_mail(atom/where, amount)
	. = list()
	var/list/crew = list()
	for(var/mob/living/carbon/human/person as anything in GLOB.human_list)
		if(!person.client || person.stat == DEAD || !person.mind?.assigned_role || !person.dna)
			continue
		if(!is_station_level(person.z))
			continue
		crew += person
	if(!length(crew))
		return
	var/list/already_picked = list()
	for(var/i in 1 to amount)
		var/mob/living/carbon/human/recipient = pick(crew)
		var/retries = 10
		while(already_picked[recipient] && retries-- > 0)
			recipient = pick(crew)
		already_picked[recipient] = TRUE
		var/department = mail_department_of(recipient.mind.assigned_role)
		var/list/gifts = (department && prob(50)) ? GLOB.mail_gifts_by_department[department] : GLOB.mail_gifts_everyone
		var/obj/item/mail_package/package = new(where)
		package.address(recipient, pickweight(gifts), department)
		. += package

// MARK: Package

/obj/item/mail_package
	name = "mail"
	desc = "A package!"
	icon = 'icons/obj/goon_misc.dmi'
	icon_state = "mail-1"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	/// What comes out when it is opened.
	var/gift_type
	/// unique_enzymes of the only person who can open it.
	var/target_dna
	var/recipient_name
	/// Which of the three envelope sprites we use, for the torn version.
	var/variant = 1

/obj/item/mail_package/Initialize(mapload)
	. = ..()
	variant = rand(1, 3)
	icon_state = "mail-[variant]"
	pixel_x = rand(-2, 2)
	pixel_y = rand(-2, 2)

/obj/item/mail_package/proc/address(mob/living/carbon/human/recipient, new_gift_type, department)
	gift_type = new_gift_type
	target_dna = recipient.dna.unique_enzymes
	recipient_name = recipient.real_name
	var/job = recipient.mind?.assigned_role
	name = job ? "mail for [recipient_name] ([job])" : "mail for [recipient_name]"
	desc = "A package for [recipient_name]. It has a DNA lock, so only [recipient_name] can open it."
	color = GLOB.mail_department_colors[department] || pick("#ffffcc", "#ffe0c8", "#e6e6ff", "#fefefe")

/obj/item/mail_package/attack_self(mob/living/carbon/human/user)
	if(!ishuman(user))
		to_chat(user, span_warning("You can't figure out how to open [src]."))
		return
	if(target_dna && user.dna?.unique_enzymes != target_dna)
		to_chat(user, span_warning("This isn't addressed to you! The DNA lock won't open, and opening someone else's mail is a crime anyway."))
		return
	open(user)
	GLOB.mail_opened++
	var/datum/money_account/cargo_account = GLOB.department_accounts[STATION_DEPARTMENT_SUPPLY]
	cargo_account?.credit(min(MAIL_PAYOUT_MAX, MAIL_PAYOUT_BASE + MAIL_PAYOUT_STEP * (GLOB.mail_opened - 1)), "Mail delivery", "Station Post", "Supply department account")

/obj/item/mail_package/proc/open(mob/living/user, torn = FALSE)
	var/obj/item/gift = gift_type ? new gift_type(get_turf(src)) : null
	if(torn)
		var/obj/item/trash/torn_mail/scraps = new(get_turf(src))
		scraps.icon_state = "mail-[variant]-b"
		scraps.color = color
	user.temporarily_remove_item_from_inventory(src, force = TRUE)
	if(gift)
		to_chat(user, span_notice("You [torn ? "tear open" : "open"] [src] and pull out [gift]."))
		user.put_in_hands(gift)
	else
		to_chat(user, span_notice("[src] was empty! What a rip-off."))
	log_game("[key_name(user)] [torn ? "forced open" : "opened"] [src] and got [gift ? gift.type : "nothing"].")
	qdel(src)

/obj/item/mail_package/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!target_dna || !tool.sharp)
		return NONE
	if(ishuman(user))
		var/mob/living/carbon/human/person = user
		if(person.dna?.unique_enzymes == target_dna)
			attack_self(user)
			return ITEM_INTERACT_SUCCESS
	user.visible_message(span_warning("[user] starts cutting through [src]'s DNA lock..."), span_warning("You start cutting through [src]'s DNA lock..."))
	playsound(src, 'sound/items/screwdriver2.ogg', 50, TRUE)
	if(!do_after(user, 5 SECONDS, src))
		return ITEM_INTERACT_BLOCKING
	user.visible_message(span_warning("[user] tears [src] open!"), span_warning("You tear [src] open. That's mail fraud."))
	add_attack_logs(user, src, "committed mail fraud on mail for [recipient_name]")
	open(user, torn = TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/trash/torn_mail
	name = "torn package"
	desc = "The scraps of a mail package that was opened improperly and messily."
	icon = 'icons/obj/goon_misc.dmi'
	icon_state = "mail-1-b"

// MARK: Mail bag and crate

/obj/item/storage/bag/mail
	name = "mail bag"
	desc = "A satchel for carrying a lot of mail around the station."
	icon = 'icons/obj/goon_misc.dmi'
	icon_state = "mailsatchel"
	slot_flags = ITEM_SLOT_BELT
	storage_slots = 40
	max_combined_w_class = 80
	w_class = WEIGHT_CLASS_BULKY
	can_hold = list(/obj/item/mail_package)
	resistance_flags = FLAMMABLE

/obj/structure/closet/crate/mail
	name = "mail crate"
	desc = "Hopefully this mail gets delivered, or people might go postal."

// MARK: Delivery on the supply shuttle

/obj/docking_port/mobile/supply/proc/deliver_mail(obj/docking_port/stationary/destination)
	if(!is_station_level(destination.z) || world.time < GLOB.next_mail_delivery)
		return
	var/turf/spot
	for(var/turf/simulated/floor in areaInstance)
		if(floor.density)
			continue
		var/blocked = FALSE
		for(var/obj/thing in floor)
			if(thing.density)
				blocked = TRUE
				break
		if(!blocked)
			spot = floor
			break
	if(!spot)
		return
	var/living_crew = 0
	for(var/mob/living/carbon/human/person as anything in GLOB.human_list)
		if(person.client && person.stat != DEAD && is_station_level(person.z))
			living_crew++
	var/amount = min(MAIL_MAX_PER_DELIVERY, CEILING(living_crew * MAIL_CREW_SHARE, 1))
	if(amount < 1)
		return
	var/obj/structure/closet/crate/mail/crate = new(spot)
	var/list/packages = create_station_mail(crate, amount)
	if(!length(packages))
		qdel(crate)
		return
	if(length(packages) > 5)
		new /obj/item/storage/bag/mail(crate)
	GLOB.next_mail_delivery = world.time + MAIL_INTERVAL
	log_game("Mail: [length(packages)] package\s delivered on the supply shuttle.")

#undef MAIL_INTERVAL
#undef MAIL_CREW_SHARE
#undef MAIL_MAX_PER_DELIVERY
#undef MAIL_PAYOUT_BASE
#undef MAIL_PAYOUT_STEP
#undef MAIL_PAYOUT_MAX
