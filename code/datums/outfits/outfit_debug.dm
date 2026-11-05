/datum/outfit/admin/debug
	name = "Debug outfit"

	uniform = /obj/item/clothing/under/patriotsuit
	suit = /obj/item/clothing/suit/space/hardsuit/singuloth
	back = /obj/item/storage/backpack
	backpack_contents = list(
		/obj/item/melee/energy/axe = 1,
		/obj/item/storage/part_replacer/bluespace/tier4 = 1,
		/obj/item/gun/magic/wand/resurrection/debug = 1,
		/obj/item/gun/magic/wand/death/debug = 1,
		/obj/item/debug/human_spawner = 1,
	)
	belt = /obj/item/storage/belt/military/abductor/full
	l_ear = /obj/item/radio/headset/centcom/debug
	glasses = /obj/item/clothing/glasses/hud/debug
	mask = /obj/item/clothing/mask/gas/welding/advanced
	shoes = /obj/item/clothing/shoes/combat/swat

	// shit down here is mine
	box = /obj/item/storage/box/debug/debugtools
	suit_store = /obj/item/tank/internals/oxygen
	gloves = /obj/item/clothing/gloves/combat
	id = /obj/item/card/id/admin
	pda = /obj/item/pda/centcom

	toggle_helmet = TRUE

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/surgery/advanced,
		/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus/hardened,
		/obj/item/organ/internal/cyberimp/arm/janitorial/advanced,
	)

/datum/outfit/admin/debug/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Debugger", "admin")

/obj/item/radio/headset/centcom/debug
	name = "AVD-CNED bowman headset"
	ks2type = /obj/item/encryptionkey/all

/obj/item/encryptionkey/all
	name = "AVD-CNED Encryption Key"
	icon = 'icons/obj/radio.dmi'
	icon_state = "rainbow"
	greyscale_config = null
	greyscale_colors = null
	channels = list(ERT_FREQ_NAME = 1, DTH_FREQ_NAME = 1, SCI_FREQ_NAME = 1, COMM_FREQ_NAME = 1, MED_FREQ_NAME = 1, ENG_FREQ_NAME = 1, SEC_FREQ_NAME = 1, SUP_FREQ_NAME = 1, SRV_FREQ_NAME = 1, PRS_FREQ_NAME = 1, PROC_FREQ_NAME = 1) // just in case
	syndie = TRUE

/obj/item/encryptionkey/all/Initialize(mapload)
	. = ..()
	for(var/channel in SSradio.radiochannels)
		channels[channel] = TRUE // yeah, all channels, sure, probably fine

/obj/item/clothing/mask/gas/welding/advanced
	name = "AVD-CNED welding mask"
	desc = "Retinal damage is no joke."
	tint = FLASH_PROTECTION_NONE

/obj/item/gun/magic/wand/resurrection/debug
	desc = "Is it possible for something to be even more powerful than regular magic? This wand is."
	max_charges = 500
	variable_charges = FALSE
	can_charge = TRUE
	recharge_rate = 1

/obj/item/gun/magic/wand/death/debug
	desc = "In some obscure circles, this is known as the 'cloning tester's friend'."
	max_charges = 500
	variable_charges = FALSE
	can_charge = TRUE
	recharge_rate = 1

/obj/item/clothing/glasses/hud/debug
	name = "AVD-CNED glasses"
	desc = "Diagnostic, Hydroponic, Medical, and Security HUD. Built-in advanced reagent scanner. Protects the wearer from supermatter hallucinations and welding flashes."
	icon_state = "nvgmeson"
	flash_protect = FLASH_PROTECTION_WELDER

	prescription_upgradable = FALSE

	HUDType = list(DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED, DATA_HUD_SECURITY_ADVANCED, DATA_HUD_HYDROPONIC)
	examine_extensions = EXAMINE_HUD_SECURITY_READ | EXAMINE_HUD_SECURITY_WRITE | EXAMINE_HUD_MEDICAL | EXAMINE_HUD_SKILLS

	var/xray = FALSE

/obj/item/clothing/glasses/hud/debug/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(xray)
		add_xray(user)

/obj/item/clothing/glasses/hud/debug/dropped(mob/living/carbon/human/user)
	. = ..()
	if(xray)
		remove_xray(user)

/obj/item/clothing/glasses/hud/debug/examine(mob/user)
	. = ..()
	. += span_notice("Щелкните <b>Alt + ЛКМ</b>, чтобы переключить иксрей.")

/obj/item/clothing/glasses/hud/debug/click_alt(mob/user)
	if(!ishuman(user))
		return NONE
	var/mob/living/carbon/human/human_user = user
	if(human_user.glasses != src)
		return CLICK_ACTION_BLOCKING
	if(xray)
		remove_xray(human_user)
	else
		add_xray(human_user)
	xray = !xray
	balloon_alert(user, "рентген-зрение [!xray ? "де" : ""]активировано") // ctodo test
	human_user.update_sight()
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/glasses/hud/debug/visor_toggling(mob/living/carbon/human/user)
	return

/obj/item/clothing/glasses/hud/debug/proc/remove_xray(mob/user)
	see_in_dark = initial(see_in_dark)
	lighting_alpha = initial(lighting_alpha)
	REMOVE_TRAIT(user, TRAIT_XRAY, "debug_glasses[UID()]")

/obj/item/clothing/glasses/hud/debug/proc/add_xray(mob/user)
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	ADD_TRAIT(user, TRAIT_XRAY, "debug_glasses[UID()]")

/obj/item/debug
	abstract_type = /obj/item/debug

/obj/item/debug/human_spawner
	name = "human spawner"
	desc = "Spawn a human by aiming at a turf and clicking. Use in hand to change type."
	icon = 'icons/obj/weapons/magic.dmi'
	icon_state = "nothingwand"
	w_class = WEIGHT_CLASS_SMALL
	var/datum/species/selected_species
	var/valid_species = list()

/obj/item/debug/human_spawner/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	. = ..()
	if(isturf(target))
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(target)
		if(selected_species)
			H.setup_dna(selected_species.type)

/obj/item/debug/human_spawner/attack_self(mob/user)
	..()
	var/choice = tgui_input_list(user, "Выберите расу", "Создатель гуманоидов", GLOB.all_species, null)
	selected_species = GLOB.all_species[choice]

/obj/item/rcd/combat/admin
	name = "AVD-CNED RCD"
	max_matter = INFINITY
	matter = INFINITY
	locked = FALSE

/obj/item/stack/spacecash/debug
	amount = 50000
	max_amount = 50000

/obj/item/bodyanalyzer/debug
	name = "AVD-CNED handheld body analyzer"
	cell_type = /obj/item/stock_parts/cell/infinite
	scan_time = 1 SECONDS
	scan_cd = 0

/obj/item/scalpel/laser/manager/debug
	name = "AVD-CNED IMS"
	desc = "A wonder of modern medicine. This tool functions as any other sort of surgery tool, and finishes in only a fraction of the time. Hey, how'd you get your hands on this, anyway?"
	toolspeed = 0.01

/obj/item/scalpel/laser/manager/debug/attack_self(mob/user)
	. = ..()
	toolspeed = toolspeed == 0.5 ? 0.01 : 0.5
	to_chat(user, "Установленная скорость работы у [declent_ru(GENITIVE)] - [toolspeed].")
	balloon_alert(user, "скорость изменена")
	playsound(src, 'sound/effects/pop.ogg', 50, FALSE)		//Change the mode

/obj/item/organ/internal/cyberimp/arm/surgery/advanced
	name = "AVD-CNED surgical toolset implant"
	greyscale_colors = "#848fe6#8f0b0b#8f0b0b#8f0b0b"
	contents = newlist(
		/obj/item/scalpel/laser/manager/debug,
		/obj/item/hemostat/alien, // its needed specifically for some surgeries
		/obj/item/circular_saw/alien,
		/obj/item/healthanalyzer/advanced,
		/obj/item/gun/medbeam,
		/obj/item/handheld_defibrillator,
		/obj/item/bodyanalyzer/debug
	)

/obj/item/organ/internal/cyberimp/arm/janitorial/advanced
	name = "AVD-CNED janitorial toolset"
	desc = "A set of advanced janitorial tools hidden behind a concealed panel on the user's arm."
	parent_organ_zone = BODY_ZONE_L_ARM
	slot = INTERNAL_ORGAN_L_ARM_DEVICE

	contents = newlist(
		/obj/item/mop/advanced/debug,
		/obj/item/soap/syndie/debug,
		/obj/item/lightreplacer/bluespace/debug,
		/obj/item/reagent_containers/spray/cleaner/advanced/debug,
		/obj/item/gun/energy/gun/advtaser/mounted // yeah why not
	)

/obj/item/mop/advanced/debug
	name = "AVD-CNED mop"
	desc = "I know you want to do it. Make shit slippery."
	mopcap = 100
	mopspeed = 1
	refill_rate = 50

/obj/item/soap/syndie/debug
	name = "super soap"
	desc = "The fastest soap in the space-west."
	cleanspeed = 1

/obj/item/lightreplacer/bluespace/debug
	name = "AVD-CNED light... thingy. You know what it is."
	max_uses = 20000
	uses = 20000

/obj/item/reagent_containers/spray/cleaner/advanced/debug
	name = "AVD-CNED advanced space cleaner"
	desc = "AVD-CNED!-brand non-foaming space cleaner! How fancy."
	volume = 50000
	spray_maxrange = 10
	spray_currentrange = 10
	list_reagents = list("cleaner" = 50000)
	delay = 0.1 SECONDS // it costs 1000 reagents to fire this cleaner... for 12 seconds.

/obj/item/storage/box/debug
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_combined_w_class = 1000
	storage_slots = 99

/obj/item/storage/box/debug/debugtools
	name = "debug tools"

/obj/item/storage/box/debug/debugtools/populate_contents()
	new /obj/item/card/emag(src)
	new /obj/item/rcd/combat/admin(src)
	new /obj/item/healthanalyzer/advanced(src)
	new /obj/item/rpd/bluespace(src)
	new /obj/item/stack/spacecash/debug(src)
	new /obj/item/storage/box/beakers/bluespace(src)
	new /obj/item/storage/box/debug/material(src)
	new /obj/item/storage/box/debug/misc_debug(src)
	new /obj/item/storage/box/survival/centcomofficer(src)
	new /obj/item/radio/uplink/admin(src)

/obj/item/storage/box/debug/material
	name = "box of materials"

/obj/item/storage/box/debug/material/populate_contents()
	new /obj/item/stack/sheet/metal/fifty(src)
	new /obj/item/stack/sheet/plasteel/fifty(src)
	new /obj/item/stack/sheet/plastic/fifty(src)
	new /obj/item/stack/sheet/glass/fifty(src)
	new /obj/item/stack/sheet/rglass/fifty(src)
	new /obj/item/stack/sheet/plasmaglass/fifty(src)
	new /obj/item/stack/sheet/plasmarglass/fifty(src)
	new /obj/item/stack/sheet/titaniumglass/fifty(src)
	new /obj/item/stack/sheet/plastitaniumglass/fifty(src)
	new /obj/item/stack/sheet/mineral/sandstone/fifty(src)
	new /obj/item/stack/sheet/mineral/diamond/fifty(src)
	new /obj/item/stack/sheet/mineral/uranium/fifty(src)
	new /obj/item/stack/sheet/mineral/plasma/fifty(src)
	new /obj/item/stack/sheet/mineral/gold/fifty(src)
	new /obj/item/stack/sheet/mineral/silver/fifty(src)
	new /obj/item/stack/sheet/mineral/bananium/fifty(src)
	new /obj/item/stack/sheet/mineral/tranquillite/fifty(src)
	new /obj/item/stack/sheet/mineral/titanium/fifty(src)
	new /obj/item/stack/sheet/mineral/plastitanium/fifty(src)
	new /obj/item/stack/sheet/mineral/abductor/fifty(src)
	new /obj/item/stack/sheet/mineral/adamantine/fifty(src)
	new /obj/item/stack/sheet/mineral/snow/fifty(src)
	new /obj/item/stack/sheet/mineral/mythril/fifty(src)

/obj/item/storage/box/debug/misc_debug
	name = "misc admin items"

/obj/item/storage/box/debug/misc_debug/populate_contents()
	new /obj/item/badminBook(src)
	new /obj/item/reagent_containers/cup/glass/bottle/vodka/badminka(src)
	new /obj/item/crowbar/power(src) // >admin only lol
	new /obj/item/clothing/gloves/fingerless/rapid/admin(src)
	new /obj/item/clothing/under/acj(src)
	new /obj/item/clothing/suit/advanced_protective_suit(src)
	new /obj/item/multitool/ai_detect/admin(src) // for giggles and shits
	new /obj/item/adminfu_scroll(src)
	new /obj/item/teleporter/admin(src)
	new /obj/item/storage/belt/bluespace/admin(src) // god i love storage nesting
	new /obj/item/mining_scanner/admin(src)
	new /obj/item/gun/energy/meteorgun/pen(src)
