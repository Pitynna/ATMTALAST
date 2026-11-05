//=========== Security CLown outfits ===========
/datum/outfit/admin/clown_security
	name = "Clown Security Officer"
	uniform = /obj/item/clothing/under/rank/security/clown
	mask = /obj/item/clothing/mask/gas/clown_hat
	suit = /obj/item/clothing/suit/armor/vest/security
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/clown_shoes
	head = /obj/item/clothing/head/helmet
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_ear = /obj/item/radio/headset/headset_sec/clown
	r_hand = /obj/item/gun/energy/clown/security
	l_pocket = /obj/item/signmaker
	r_pocket = /obj/item/bikehorn
	suit_store = /obj/item/gun/energy/dominator/sibyl
	id = /obj/item/card/id/security/clown
	pda = /obj/item/pda/clown/security
	belt = /obj/item/storage/belt/security

	back = /obj/item/storage/backpack/security
	backpack_contents = list(
		/obj/item/restraints/handcuffs/pinkcuffs = 2,
		/obj/item/cartridge/security = 1,
		/obj/item/flash = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/stamp/clown = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/storage/fancy/crayons = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/reagent_containers/cup/glass/bottle/bottleofbanana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/clown_recorder = 1,
		/obj/item/clothing/head/beret/sec = 1,
	)
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/sad_trombone)

	var/is_warden = FALSE
	var/is_physician = FALSE

/datum/outfit/admin/clown_security/warden
	name = "Clown Security Warden"

	suit = /obj/item/clothing/suit/armor/vest/warden
	head = /obj/item/clothing/head/warden
	belt = /obj/item/storage/belt/security/response_team
	l_hand = /obj/item/storage/lockbox/sibyl_system_mod
	r_hand = /obj/item/gun/energy/clown/security/warden
	back = /obj/item/storage/backpack/satchel_sec
	is_warden = TRUE

/datum/outfit/admin/clown_security/physician
	name = "Clown Security Physician"

	head = /obj/item/clothing/head/beret/med
	suit = /obj/item/clothing/suit/storage/fr_jacket
	r_ear = /obj/item/radio/headset/headset_brigphys
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/doctor
	belt = /obj/item/storage/belt/medical/surgery/loaded

	back = /obj/item/storage/backpack/duffel/medical
	backpack_contents = list(
		/obj/item/restraints/handcuffs/pinkcuffs = 2,
		/obj/item/flash = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/stamp/clown = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/storage/fancy/crayons = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/reagent_containers/cup/glass/bottle/bottleofbanana = 1,
		/obj/item/clown_recorder = 1,
		/obj/item/instrument/bikehorn = 1,

		/obj/item/cartridge/medical = 1,
		/obj/item/autopsy_scanner = 1,
		/obj/item/reagent_scanner = 1,
		/obj/item/storage/box/bodybags = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/storage/firstaid/fire = 1,
		/obj/item/storage/firstaid/brute = 1,
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/storage/firstaid/toxin = 1,
		/obj/item/storage/firstaid/o2 = 1,
		/obj/item/storage/pill_bottle/ert = 1,
		/obj/item/storage/pill_bottle/fakedeath = 1,
	)

	is_physician = TRUE

/datum/outfit/plasmaman/security/clown
	name = "Clown Security Plasmaman"

	head = /obj/item/clothing/head/helmet/space/plasmaman/security/security/clown
	uniform = /obj/item/clothing/under/plasmaman/security/security/clown

/datum/outfit/admin/clown_security/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	if(ismachineperson(H))
		var/obj/item/organ/internal/cyberimp/brain/clown_voice/implant = new
		implant.insert(H)

	H.force_gene_block(GLOB.comicblock, TRUE, TRUE)
	H.add_language(LANGUAGE_CLOWN)

	var/clownsecurity_rank = pick("Офицер", "Кадет", "Новобранец", "Рядовой", "Ефрейтор", "Сержант", "Детектив", "Оперуполномоченный", "Расследователь", "Охранник", "Полевой офицер")
	if(is_physician)
		clownsecurity_rank = pick("Интерн", "Медик", "Врач", "Лекарь", "Хирург", "Консультант", "Лечащий врач", "Парамедик", "Патологоанатом", "Гробовщик", "Биотехник", "Сборщик трупов", "Сборщик органов")
	if(is_warden)
		clownsecurity_rank = pick("Надзиратель", "Смотритель", "Старший Офицер", "Старший Сержант", "Старшина", "Старший оперуполномоченный", "Комиссар", "Командор")
	var/clownsecurity_name = pick(GLOB.clown_names)
	H.real_name = "[clownsecurity_rank] [clownsecurity_name]"
	H.name = H.real_name

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		var/new_access = list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)
		if(is_physician)
			new_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_SECURITY, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS)
		if(is_warden)
			new_access = list(
				ACCESS_EVA, ACCESS_SECURITY, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT,
				ACCESS_FORENSICS_LOCKERS, ACCESS_PILOT, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
				ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
				ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS
			)
		apply_to_card(I, H, new_access, "Clown Security", "clownsecurity")
		I.access.Add(ACCESS_CLOWN, ACCESS_MIME, ACCESS_THEATRE)
		I.assignment = name
	H.update_hud_set()

//=========== security clown equipment ===========
/obj/item/pda/clown/security
	default_request_console_cartridge = /obj/item/cartridge/request_console/clown_security
	icon_state = "pda-security-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This PDA was commissioned by a secret customer who wished to remain honknonymous. Its surface is coated in polytetrafluoroethylene and banana residue."

/obj/item/card/id/security/clown
	name = "Security-Clown ID"
	registered_name = "Officer Clown"
	icon_state = "clownsecurity"
	desc = "Looking at this card, you realize that Central Command has a peculiar sense of humor."
	access = list(ACCESS_SECURITY, ACCESS_CLOWN, ACCESS_THEATRE, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)

/obj/item/radio/headset/headset_sec/clown
	name = "security clown's headset"
	desc = "For use by elite honk units. HONK!"
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"
	ks1type = /obj/item/encryptionkey/headset_sec
	ks2type = /obj/item/encryptionkey/headset_service

/obj/item/clothing/under/rank/security/clown
	desc = "A sturdy uniform stained with banana juice, offering its wearer reliable protection. The Universal Clown Federation and Central Command once fiercely debated issuing it to security wardens. Nanotrasen ultimately banned the uniform, and the Clown Federation reclaimed every copy for its own use. HONK!"
	name = "warden clown jumpsuit"
	icon_state = "security_clown"
	item_color = "security_clown"

/obj/item/gun/energy/clown/security
	name = "officer's HONK gun"
	desc = "A security clown's personal weapon. Devastating to the mental health of anyone on the receiving end. Banned twelve times by Nanotrasen conventions and approved thirteen times by clown councils. Its grip bears an engraved HONK and several crossed-out tally marks."
	icon_state = "honkrifle_security"
	item_state = null

/obj/item/gun/energy/clown/security/warden
	name = "warden's personal HONK gun"
	desc = "A clown warden's personal lethal weapon, awarded for services to Nanotrasen and (DATA HONKED). Rumor has it that this is one of the first examples manufactured during the mime-clown war on the clowns' homeworld."

//=========== plasmamet clothes ===========
/obj/item/clothing/head/helmet/space/plasmaman/security/security/clown
	name = "security clown plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for the warden, a pair of white stripes being added to differentiate them from other members of security. HONK!"
	icon_state = "security_clown_envirohelm"
	item_state = "security_clown_envirohelm"

/obj/item/clothing/under/plasmaman/security/security/clown
	name = "security clown plasma envirosuit"
	desc = "A plasmaman containment suit designed for the warden, white stripes being added to differentiate them from other members of security. HONK!"
	icon_state = "security_clown_envirosuit"
	item_state = "security_clown_envirosuit"
	item_color = "security_clown_envirosuit"
