//Not to be confused with /obj/item/reagent_containers/cup/glass/bottle

/obj/item/reagent_containers/cup/bottle
	name = "bottle"
	desc = "A small bottle."
	gender = FEMALE
	icon_state = "bottle"
	item_state = "bottle"
	possible_transfer_amounts = list(5, 10, 15, 30)
	volume = 30
	can_lid = TRUE
	materials = list(MAT_GLASS = 1000)
	custom_price = PAYCHECK_MIN * 0.6
	fill_icon_thresholds = list(1, 10, 25, 50, 75, 80, 100)
	is_glass = TRUE

/obj/item/reagent_containers/cup/bottle/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "bottle"
	update_appearance()

/obj/item/reagent_containers/cup/bottle/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!reagents.total_volume)
		C.stored_comms["glass"] += 3
		qdel(src)
		return TRUE
	return ..()

/obj/item/reagent_containers/cup/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle containing toxic compounds."
	list_reagents = list("toxin" = 30)

/obj/item/reagent_containers/cup/bottle/atropine
	name = "atropine bottle"
	desc = "A small bottle containing atropine, used for cardiac emergencies."
	list_reagents = list("atropine" = 30)
	custom_price = PAYCHECK_MIN

/obj/item/reagent_containers/cup/bottle/saline
	name = "saline-glucose bottle"
	desc = "A small bottle containing saline-glucose solution."
	list_reagents = list("salglu_solution" = 30)

/obj/item/reagent_containers/cup/bottle/saline/get_short_name()
	return "Физраствор"

/obj/item/reagent_containers/cup/bottle/salicylic
	name = "salicylic acid bottle"
	desc = "A small bottle containing medicine for pain and fevers."
	list_reagents = list("sal_acid" = 30)

/obj/item/reagent_containers/cup/bottle/salicylic/get_short_name()
	return "Сал. кислота"

/obj/item/reagent_containers/cup/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	list_reagents = list("cyanide" = 30)

/obj/item/reagent_containers/cup/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("mutagen" = 30)

/obj/item/reagent_containers/cup/bottle/mutagen/get_short_name()
	return "Нестаб. мутаген"

/obj/item/reagent_containers/cup/bottle/ammonia
	name = "ammonia bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится аммиак."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("ammonia" = 30)

/obj/item/reagent_containers/cup/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится диэтиламин."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("diethylamine" = 30)

/obj/item/reagent_containers/cup/bottle/facid
	name = "Fluorosulfuric Acid Bottle"
	desc = "A small bottle. Contains a small amount of Fluorosulfuric Acid"
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("facid" = 30)

/obj/item/reagent_containers/cup/bottle/facid/get_short_name()
	return "Фторсер. кислота"

/obj/item/reagent_containers/cup/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	list_reagents = list("adminordrazine" = 30)

/obj/item/reagent_containers/cup/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "A small bottle. Contains hot sauce."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("capsaicin" = 30)

/obj/item/reagent_containers/cup/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "A small bottle. Contains cold sauce."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("frostoil" = 30)

/obj/item/reagent_containers/cup/bottle/frostoil/get_short_name()
	return "Лед. масло"

/obj/item/reagent_containers/cup/bottle/morphine
	name = "Morphine Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится морфин."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("morphine" = 30)
	custom_price = PAYCHECK_MIN

/obj/item/reagent_containers/cup/bottle/ether
	name = "Ether Bottle"
	desc = "A small bottle of an ether, a strong anesthetic and sedative."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("ether" = 30)

/obj/item/reagent_containers/cup/bottle/charcoal
	name = "Charcoal Bottle"
	desc = "A small bottle. Contains charcoal."
	icon_state = "wide_bottle"
	item_state = "wide_bottle"
	list_reagents = list("charcoal" = 30)

/obj/item/reagent_containers/cup/bottle/charcoal/get_short_name()
	return "Акт. уголь"

/obj/item/reagent_containers/cup/bottle/epinephrine
	name = "Epinephrine Bottle"
	desc = "A small bottle. Contains epinephrine - used to stabilize patients."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("epinephrine" = 30)

/obj/item/reagent_containers/cup/bottle/pancuronium
	name = "Pancuronium Bottle"
	desc = "A small bottle of pancuronium."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("pancuronium" = 30)

/obj/item/reagent_containers/cup/bottle/sulfonal
	name = "Sulfonal Bottle"
	desc = "A small bottle of Sulfonal."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("sulfonal" = 30)

/obj/item/reagent_containers/cup/bottle/plasma
	name = "plasma dust bottle"
	desc = "A small bottle of plasma in dust form. Extremely toxic and reacts with micro-organisms inside blood."
	icon_state = "wide_bottle"
	item_state = "wide_bottle"
	list_reagents = list("plasma_dust" = 30)

/obj/item/reagent_containers/cup/bottle/plasma/get_short_name()
	return "Плазм. пыль"

/obj/item/reagent_containers/cup/bottle/diphenhydramine
	name = "diphenhydramine bottle"
	desc = "A small bottle of diphenhydramine."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("diphenhydramine" = 30)

/obj/item/reagent_containers/cup/bottle/oculine
	name = "oculine bottle"
	desc = "A small bottle of combined eye and ear medication."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("oculine" = 30)
	custom_price = PAYCHECK_MIN * 2

/obj/item/reagent_containers/cup/bottle/potassium_iodide
	name = "potassium iodide bottle"
	desc = "A small bottle of potassium iodide."
	icon_state = "wide_bottle"
	item_state = "wide_bottle"
	list_reagents = list("potass_iodide" = 30)

/**
 * MARK: Reagent bottle
 */

/obj/item/reagent_containers/cup/bottle/reagent
	name = "Reagent Bottle"
	icon_state = "reagent_bottle"
	item_state = "reagent_bottle"
	possible_transfer_amounts = list(5, 10, 15, 25, 50)
	volume = 50

/obj/item/reagent_containers/cup/bottle/reagent/oil
	name = "Oil Bottle"
	desc = "A reagent bottle. Contains oil."
	list_reagents = list("oil" = 50)
	pixel_x = -4
	pixel_y = 6

/obj/item/reagent_containers/cup/bottle/reagent/phenol
	name = "Phenol Bottle"
	desc = "A reagent bottle. Contains phenol."
	list_reagents = list("phenol" = 50)
	pixel_x = 6
	pixel_y = 6

/obj/item/reagent_containers/cup/bottle/reagent/acetone
	name = "Acetone Bottle"
	desc = "A reagent bottle. Contains acetone."
	list_reagents = list("acetone" = 50)
	pixel_x = -4

/obj/item/reagent_containers/cup/bottle/reagent/ammonia
	name = "Ammonia Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится аммиак."
	list_reagents = list("ammonia" = 50)
	pixel_x = 6

/obj/item/reagent_containers/cup/bottle/reagent/diethylamine
	name = "Diethylamine Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится диэтиламин."
	list_reagents = list("diethylamine" = 50)
	pixel_x = -4
	pixel_y = -6

/obj/item/reagent_containers/cup/bottle/reagent/acid
	name = "Acid Bottle"
	desc = "A reagent bottle. Contains sulfuric acid."
	list_reagents = list("sacid" = 50)
	pixel_x = 6
	pixel_y = -6

/obj/item/reagent_containers/cup/bottle/reagent/formaldehyde
	name = "Formaldehyde Bottle"
	desc = "A reagent bottle. Contains formaldehyde."
	list_reagents = list("formaldehyde" = 50)

/obj/item/reagent_containers/cup/bottle/reagent/synaptizine
	name = "Synaptizine Bottle"
	desc = "A reagent bottle. Contains synaptizine."
	list_reagents = list("synaptizine" = 50)

/obj/item/reagent_containers/cup/bottle/reagent/morphine
	name = "Morphine Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится морфин."
	list_reagents = list("morphine" = 50)

/obj/item/reagent_containers/cup/bottle/reagent/insulin
	name = "Insulin Bottle"
	desc = "A reagent bottle. Contains insulin."
	list_reagents = list("insulin" = 50)

/obj/item/reagent_containers/cup/bottle/reagent/hairgrownium
	name = "Hair Grow Gel"
	desc = "A bottle full of a stimulative hair growth formula."
	list_reagents = list("hairgrownium" = 50)

/obj/item/reagent_containers/cup/bottle/reagent/hair_dye
	name = "Quantum Hair Dye Bottle"
	desc = "A bottle of the ever-changing quantum hair dye."
	list_reagents = list("hair_dye" = 50)

/obj/item/reagent_containers/cup/bottle/reagent/omnizine
	name = "Omnizine Bottle"
	desc = "A reagent bottle. Contains Omnizine."
	list_reagents = list("omnizine" = 50)

/obj/item/reagent_containers/cup/bottle/reagent/strange_reagent
	name = "Strange Reagent Bottle"
	desc = "A bottle of glowing fluid."
	list_reagents = list("strange_reagent" = 30)

/**
 * MARK: Traitor poison bottle
 */

/obj/item/reagent_containers/cup/bottle/traitor
	desc = "It has a small skull and crossbones on it. Uh-oh!"
	possible_transfer_amounts = list(5, 10, 15, 25, 30, 40)
	volume = 40

/obj/item/reagent_containers/cup/bottle/traitor/Initialize(mapload)
	. = ..()
	reagents.add_reagent(pick_list(CHEMISTRY_TOOLS_FILE, "traitor_poison_bottle"), 40)

/**
 * MARK: Vuric cultures
 */

/obj/item/reagent_containers/cup/bottle/cold
	name = "Rhinovirus culture bottle"
	desc = "A small bottle. Contains XY-rhinovirus culture in synthblood medium."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/cold

/obj/item/reagent_containers/cup/bottle/flu
	name = "Flu virion culture bottle"
	desc = "A small bottle. Contains H13N1 flu virion culture in synthblood medium."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/flu

/obj/item/reagent_containers/cup/bottle/sneezing
	name = "Sneezing symptom bottle"
	desc = "A small bottle. Contains a simple advanced virus in synthblood medium that makes infected sneeze."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/sneezing

/obj/item/reagent_containers/cup/bottle/cough
	name = "Cough symptom bottle"
	desc = "A small bottle. Contains a simple advanced virus in synthblood medium that makes infected cough."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/cough

/obj/item/reagent_containers/cup/bottle/epiglottis_virion
	name = "Epiglottis virion culture bottle"
	desc = "A small bottle. Contains Epiglottis virion culture in synthblood medium."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/voice_change

/obj/item/reagent_containers/cup/bottle/liver_enhance_virion
	name = "Liver enhancement virion culture bottle"
	desc = "A small bottle. Contains liver enhancement virion culture in synthblood medium."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/heal

/obj/item/reagent_containers/cup/bottle/hullucigen_virion
	name = "Hullucigen virion culture bottle"
	desc = "A small bottle. Contains hullucigen virion culture in synthblood medium."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/hullucigen

/obj/item/reagent_containers/cup/bottle/pierrot_throat
	name = "Pierrot's Throat culture bottle"
	desc = "A small bottle. Contains H0NI<42 virion culture in synthblood medium."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/pierrot_throat

/obj/item/reagent_containers/cup/bottle/mind_restoration
	name = "Reality Purifier culture bottle"
	desc = "A small bottle. Contains Reality Purifier culture in synthblood medium."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/mind_restoration

/obj/item/reagent_containers/cup/bottle/advanced_regeneration
	name = "Advanced Neogenesis culture bottle"
	desc = "A small bottle. Contains Advanced Neogenesis culture in synthblood medium."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/advanced_regeneration

/obj/item/reagent_containers/cup/bottle/stealth_necrosis
	name = "Necroeyrosis culture bottle"
	desc = "A small bottle. Contains Necroeyrosis culture in synthblood medium."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/stealth_necrosis

/obj/item/reagent_containers/cup/bottle/pre_kingstons
	name = "Neverlasting Stranger culture bottle"
	desc = "A small bottle. Contains Neverlasting Stranger culture in synthblood medium."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/pre_kingstons

/obj/item/reagent_containers/cup/bottle/love
	name = "love"
	desc = "love"
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/love

/obj/item/reagent_containers/cup/bottle/aggression
	name = "aggression"
	desc = "aggression"
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/aggression

/obj/item/reagent_containers/cup/bottle/obsession
	name = "obsession"
	desc = "obsession"
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/obsession

/obj/item/reagent_containers/cup/bottle/confusion
	name = "confusion"
	desc = "confusion"
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/confusion

/obj/item/reagent_containers/cup/bottle/bones
	name = "bones"
	desc = "Someone's been drinking their milk."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/bones

/obj/item/reagent_containers/cup/bottle/limb_throw
	name = "limb_throw"
	desc = "limb_throw"
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/limb_throw

/obj/item/reagent_containers/cup/bottle/laugh
	name = "laugh"
	desc = "laugh"
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/laugh

/obj/item/reagent_containers/cup/bottle/moan
	name = "moan"
	desc = "moan"
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/moan

/obj/item/reagent_containers/cup/bottle/infection
	name = "infection"
	desc = "infection"
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/infection

/obj/item/reagent_containers/cup/bottle/loyalty
	name = "loyalty"
	desc = "loyalty"
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/loyalty

/obj/item/reagent_containers/cup/bottle/pre_loyalty
	name = "pre_loyalty"
	desc = "pre_loyalty"
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/pre_loyalty

/obj/item/reagent_containers/cup/bottle/retrovirus
	name = "Retrovirus culture bottle"
	desc = "A small bottle. Contains a retrovirus culture in a synthblood medium."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/dna_retrovirus

/obj/item/reagent_containers/cup/bottle/gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS+ culture in synthblood medium."//Or simply - General BullShit
	icon_state = "round_bottle"
	item_state = "round_bottle"
	amount_per_transfer_from_this = 5
	spawned_disease = /datum/disease/virus/gbs

/obj/item/reagent_containers/cup/bottle/fake_gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS- culture in synthblood medium."//Or simply - General BullShit
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/fake_gbs

/obj/item/reagent_containers/cup/bottle/brainrot
	name = "Brainrot culture bottle"
	desc = "A small bottle. Contains Cryptococcus Cosmosis culture in synthblood medium."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/brainrot

/obj/item/reagent_containers/cup/bottle/magnitis
	name = "Magnitis culture bottle"
	desc = "A small bottle. Contains a small dosage of Fukkos Miracos."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/magnitis

/obj/item/reagent_containers/cup/bottle/wizarditis
	name = "Wizarditis culture bottle"
	desc = "A small bottle. Contains a sample of Rincewindus Vulgaris."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/wizarditis

/obj/item/reagent_containers/cup/bottle/anxiety
	name = "Severe Anxiety culture bottle"
	desc = "A small bottle. Contains a sample of Lepidopticides."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/anxiety

/obj/item/reagent_containers/cup/bottle/beesease
	name = "Beesease culture bottle"
	desc = "A small bottle. Contains a sample of invasive Apidae."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/beesease

/obj/item/reagent_containers/cup/bottle/fluspanish
	name = "Spanish flu culture bottle"
	desc = "A small bottle. Contains a sample of Inquisitius."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/fluspanish

/obj/item/reagent_containers/cup/bottle/tuberculosis
	name = "Fungal Tuberculosis culture bottle"
	desc = "A small bottle. Contains a sample of Fungal Tubercle bacillus."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/tuberculosis

/obj/item/reagent_containers/cup/bottle/regeneration
	name = "Regeneration culture bottle"
	desc = "A small bottle. Contains a sample of a virus that heals toxin damage."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/heal

/obj/item/reagent_containers/cup/bottle/sensory_restoration
	name = "Sensory Restoration culture bottle"
	desc = "A small bottle. Contains a sample of a virus that heals sensory damage."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/sensory_restoration

/obj/item/reagent_containers/cup/bottle/tuberculosiscure
	name = "BVAK bottle"
	desc = "A small bottle containing Bio Virus Antidote Kit."
	icon_state = "wide_bottle"
	item_state = "wide_bottle"
	list_reagents = list("atropine" = 5, "epinephrine" = 5, "salbutamol" = 10, "spaceacillin" = 10)

/obj/item/reagent_containers/cup/bottle/tuberculosiscure/get_short_name()
	return "Антидот"

/obj/item/reagent_containers/cup/bottle/zombiecure1
	name = "Anti-Plague Sequence Alpha bottle"
	desc = "A small bottle containing 50 units of Anti-Plague Sequence Alpha. Prevents infection, cures level 1 infection."
	list_reagents = list("zombiecure1" = 50)

/obj/item/reagent_containers/cup/bottle/zombiecure2
	name = "Anti-Plague Sequence Beta bottle"
	desc = "A small bottle containing 50 units of Anti-Plague Sequence Beta. Weakens zombies, heals low infections."
	list_reagents = list("zombiecure2" = 50)

/obj/item/reagent_containers/cup/bottle/zombiecure3
	name = "Anti-Plague Sequence Gamma bottle"
	desc = "A small bottle containing 50 units of Anti-Plague Sequence Gamma. Lowers zombies healing. Heals stage 5 and slows stage 6 infections."
	list_reagents = list("zombiecure3" = 50)

/obj/item/reagent_containers/cup/bottle/zombiecure4
	name = "Anti-Plague Sequence Omega bottle"
	desc = "A small bottle containing 50 units of Anti-Plague Sequence Omega. Cures all cases of the Necrotizing Plague. Also heals dead limbs."
	list_reagents = list("zombiecure4" = 50)

/obj/item/reagent_containers/cup/bottle/monkeylangue
	name = "bottle of monkey language potion"
	desc = "A bottle of monkey language potion."
	icon_state = "round_bottle"
	item_state = "round_bottle"
	list_reagents = list("monkeylanguage" = 30)

/obj/item/reagent_containers/cup/bottle/syrup_bottle
	name = "syrup bottle"
	desc = "Стеклянная бутылка для сиропа, предназначенного для добавления в кофе. Оснащена удобным дозатором."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "syrup"
	base_icon_state = "syrup"
	possible_transfer_amounts = list(5, 10)
	volume = 50
	amount_per_transfer_from_this = 5
	container_type = NONE
	materials = list(MAT_GLASS = 500)
	can_lid = FALSE
	fill_icon_thresholds = list(20, 40, 60, 80, 100)

/obj/item/reagent_containers/cup/bottle/syrup_bottle/examine(mob/user)
	. = ..()
	. += span_notice("Используйте контейнер на [declent_ru(PREPOSITIONAL)], чтобы переместить в него содержимое бутылки.")
	return

/obj/item/reagent_containers/cup/bottle/syrup_bottle/update_icon_state()
	. = ..()
	if(is_open_container())
		icon_state = "syrup_open"
	else
		icon_state = "syrup"

/obj/item/reagent_containers/cup/bottle/syrup_bottle/attack_self(mob/user)
	if(is_open_container())
		container_type &= ~OPENCONTAINER
		user.balloon_alert(user, "крышка-дозатор надета")
	else
		container_type |= OPENCONTAINER
		user.balloon_alert(user, "крышка-дозатор снята")
	update_appearance()

//when you attack the syrup bottle with a container it refills it
/obj/item/reagent_containers/cup/bottle/syrup_bottle/attackby(obj/item/attacking_item, mob/user, params)

	if(is_open_container())
		return ..()

	if(!check_allowed_items(attacking_item, target_self = TRUE))
		return ATTACK_CHAIN_PROCEED

	if(attacking_item.is_refillable())
		if(!reagents.total_volume)
			user.balloon_alert(user, "пусто!")
			return ATTACK_CHAIN_PROCEED_SUCCESS

		if(attacking_item.reagents.holder_full())
			user.balloon_alert(user, "контейнер полон!")
			return ATTACK_CHAIN_PROCEED_SUCCESS
		var/transfer_amount = reagents.trans_to(attacking_item, amount_per_transfer_from_this)
		balloon_alert(user, "перемещено [transfer_amount] единиц[DECL_A_Y_0(transfer_amount)] вещества")
		flick("syrup_anim", src)

	attacking_item.update_icon()
	update_icon()
	return ATTACK_CHAIN_PROCEED_SUCCESS


//types of syrups

/obj/item/reagent_containers/cup/bottle/syrup_bottle/caramel
	name = "bottle of caramel syrup"
	desc = "Стеклянная бутылка для сиропа, предназначенного для добавления в кофе. Оснащена удобным дозатором. \
			Содержит карамелизированный сахар, также известный как карамель. Очень липкий."
	list_reagents = list("caramel" = 50)

/obj/item/reagent_containers/cup/bottle/syrup_bottle/liqueur
	name = "bottle of coffee liqueur syrup"
	desc = "Стеклянная бутылка для сиропа, предназначенного для добавления в кофе. Оснащена удобным дозатором. \
			Содержит мексиканский ликёр \"Калуа\". В производстве с 1936 года!"
	list_reagents = list("kahlua" = 50)
