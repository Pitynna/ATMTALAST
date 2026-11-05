/obj/item/radio/headset
	name = "radio headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys."
	var/radio_desc = ""
	icon_state = "headset"
	item_state = "headset"
	equip_sound = 'sound/items/handling/equip/generic_equip4.ogg'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/ears.dmi',
		SPECIES_VOX_ARMALIS = 'icons/mob/clothing/species/armalis/ears.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/ears.dmi',
	) //We read you loud and skree-er.
	materials = list(MAT_METAL=75)
	canhear_range = 0 // can't hear headsets from very far away
	interaction_flags_mouse_drop = FORBID_TELEKINESIS_REACH

	slot_flags = ITEM_SLOT_EARS
	var/translate_binary = FALSE
	var/translate_hive = FALSE
	var/obj/item/encryptionkey/keyslot2 = null

	var/ks1type = null
	var/ks2type = null
	dog_fashion = null
	requires_tcomms = TRUE

/obj/item/radio/headset/Initialize(mapload)
	if(ks1type)
		keyslot = new ks1type(src)
	if(ks2type)
		keyslot2 = new ks2type(src)
	. = ..()
	possibly_deactivate_in_loc()

/obj/item/radio/headset/Destroy()
	QDEL_NULL(keyslot)
	QDEL_NULL(keyslot2)
	QDEL_NULL(syndiekey)
	return ..()

/obj/item/radio/headset/examine_tags(mob/user)
	. = ..()
	if((item_flags & BANGPROTECT_MINOR) || (item_flags & BANGPROTECT_TOTAL))
		.["защищающий слух"] = "Защищает органы слуха носителя от громких звуков."

/obj/item/radio/headset/get_internal_channels()
	return list()

/obj/item/radio/headset/proc/possibly_deactivate_in_loc()
	if(!listening)
		return
	if(ismob(loc))
		set_listening(should_be_listening)
	else
		set_listening(FALSE, actual_setting = FALSE)

/obj/item/radio/headset/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	possibly_deactivate_in_loc()

/obj/item/radio/headset/examine(mob/user)
	. = ..()
	if(in_range(src, user) && radio_desc)
		. += span_notice("<b>Доступные частоты:</b>")
		. += span_notice("[radio_desc]")

/obj/item/radio/headset/handle_message_mode(mob/living/M, list/message_pieces, channel)
	if(channel == SPEC_FREQ_NAME)
		if(translate_binary)
			var/datum/language/binary = GLOB.all_languages[LANGUAGE_BINARY]
			binary.broadcast(M, strip_prefixes(multilingual_to_message(message_pieces)))
			return RADIO_CONNECTION_NON_SUBSPACE
		if(translate_hive)
			var/datum/language/hivemind = GLOB.all_languages[LANGUAGE_HIVE_XENOS]
			hivemind.broadcast(M, strip_prefixes(multilingual_to_message(message_pieces)))
			return RADIO_CONNECTION_NON_SUBSPACE
		return RADIO_CONNECTION_FAIL

	return ..()

/obj/item/radio/headset/is_listening()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.l_ear == src || H.r_ear == src)
			return ..()
	else if(isanimal(loc) || isAI(loc) || istype(loc, /obj/item/paicard))
		return ..()

	return FALSE

/obj/item/radio/headset/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/encryptionkey))
		if(loc == user && (user.check_obscured_slots() & user.get_slot_by_item(src)))
			user.balloon_alert(user, "закрыто одеждой!")
			return ATTACK_CHAIN_PROCEED
		add_fingerprint(user)
		user.set_machine(src)
		if(keyslot && keyslot2)
			user.balloon_alert(user, "слоты для ключей заняты!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		if(keyslot)
			keyslot2 = I
		else
			keyslot = I
		recalculate_channels()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/radio/headset/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(ishuman(user) && loc == user)
		var/mob/living/carbon/human/H_user = user
		if(H_user.check_obscured_slots() & H_user.get_slot_by_item(src))
			user.balloon_alert(user, "закрыто одеждой!")
			return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	user.set_machine(src)
	if(keyslot || keyslot2)
		if(keyslot)
			var/turf/T = get_turf(user)
			if(T)
				keyslot.loc = T
				keyslot = null
		if(keyslot2)
			var/turf/T = get_turf(user)
			if(T)
				keyslot2.loc = T
				keyslot2 = null

		recalculate_channels()
		user.balloon_alert(user, "ключ извлечён")
		I.play_tool_sound(user, I.tool_volume)
	else
		user.balloon_alert(user, "слот для ключа пуст!")

/obj/item/radio/headset/recalculate_channels(setDescription = TRUE)
	. = ..()
	if(!setDescription)
		return
	setupRadioDescription()

/obj/item/radio/headset/load_channels()
	. = ..()
	load_keyslot(keyslot)
	load_keyslot(keyslot2)

/obj/item/radio/headset/load_keyslot(obj/item/encryptionkey/key)
	if(!istype(key))
		return

	translate_binary |= key.translate_binary
	translate_hive |= key.translate_hive

	if(!key.syndie)
		return

	syndiekey = key

/obj/item/radio/headset/get_base_channels()
	return (keyslot?.channels | keyslot2?.channels)

/obj/item/radio/headset/make_broken()
	. = ..()
	name = "broken radio headset"
	ru_names = alist(
		NOMINATIVE = "сломанная радиочастотная гарнитура",
		GENITIVE = "сломанную радиочастотную гарнитуру",
		DATIVE = "сломанной радиочастотной гарнитуры",
		ACCUSATIVE = "сломанную радиочастотную гарнитуру",
		INSTRUMENTAL = "сломанной радиочастотной гарнитурой",
		PREPOSITIONAL = "сломанной радиочастотной гарнитуре",
	)

/obj/item/radio/headset/reset_channels()
	. = ..()
	translate_binary = FALSE
	translate_hive = FALSE
	syndiekey = null

/obj/item/radio/headset/proc/setupRadioDescription()
	var/radio_text = ""
	for(var/i = 1 to length(channels))
		var/channel = channels[i]
		var/key = get_radio_key_from_channel(channel)
		radio_text += "[key] - [channel]"
		if(i != length(channels))
			radio_text += ", "

	radio_desc = radio_text

/obj/item/radio/headset/proc/make_syndie() // Turns normal radios into Syndicate radios!
	qdel(keyslot)
	keyslot = new /obj/item/encryptionkey/syndicate
	syndiekey = keyslot
	recalculate_channels()

/obj/item/radio/headset/alt
	name = "bowman headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys. Protects ears from flashbangs."
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/syndicate
	origin_tech = "syndicate=3"
	ks1type = /obj/item/encryptionkey/syndicate/nukeops
	requires_tcomms = FALSE
	instant = TRUE // Work instantly if there are no comms
	freqlock = TRUE

/obj/item/radio/headset/syndicate/alt //undisguised bowman with flash protection
	name = "syndicate headset"
	desc = "A syndicate headset that can be used to hear all radio frequencies. Protects ears from flashbangs."
	item_flags = BANGPROTECT_MINOR
	icon_state = "syndie_headset"
	item_state = "syndie_headset"

/obj/item/radio/headset/syndicate/syndteam
	ks1type = /obj/item/encryptionkey/syndteam

/obj/item/radio/headset/syndicate/alt/syndteam
	ks1type = /obj/item/encryptionkey/syndteam

/obj/item/radio/headset/syndicate/alt/lavaland
	name = "syndicate lavaland headset"
	desc = "A tactical headset built with Syndicate technology. Active noise cancellation protects the user's hearing. Special communication protocols provide access to encrypted Syndicate channels and allow monitoring of restricted Nanotrasen channels. Operates independently of local telecommunications systems. This model is intended for Syndicate personnel on the surface of Lazis."
	default_frequency = SYND_FREQ

/obj/item/radio/headset/syndicate/admin_officer
	name = "syndicate officer's headset"
	desc = "A tactical headset built with Syndicate technology. Active noise cancellation protects the user's hearing. Special communication protocols provide access to encrypted Syndicate channels and allow monitoring of restricted Nanotrasen channels. Operates independently of local telecommunications systems. An elite model for Syndicate command personnel."
	icon_state = "syndie_headset"
	item_state = "syndie_headset"
	ks1type = /obj/item/encryptionkey/syndteam
	ks2type = /obj/item/encryptionkey/syndicate
	freerange = TRUE
	freqlock = FALSE
	item_flags = BANGPROTECT_MINOR

/obj/item/radio/headset/alt/soviet
	name = "Soviet bowman headset"
	desc = "Used by U.S.S.P forces. Protects ears from flashbangs."
	icon_state = "syndie_headset"
	item_state = "syndie_headset"
	ks1type = /obj/item/encryptionkey/soviet
	requires_tcomms = FALSE
	instant = TRUE
	freqlock = TRUE

/obj/item/radio/headset/binary
	origin_tech = "syndicate=3"
	ks1type = /obj/item/encryptionkey/binary

/obj/item/radio/headset/headset_sec
	name = "security radio headset"
	desc = "This is used by your elite security force."
	icon_state = "sec_headset"
	ks2type = /obj/item/encryptionkey/headset_sec

/obj/item/radio/headset/headset_sec/alt
	name = "security bowman headset"
	desc = "This is used by your elite security force. Protects ears from flashbangs."
	item_flags = BANGPROTECT_MINOR
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"

/obj/item/radio/headset/headset_brigphys
	name = "brig physician's bowman headset"
	desc = "This is used by your elite security's medical personnel. Protects ears from flashbangs."
	item_flags = BANGPROTECT_MINOR
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"
	ks2type = /obj/item/encryptionkey/headset_medsec

/obj/item/radio/headset/prisoner
	name = "prisoner radio headset"
	desc = "A radio headset made from impact-resistant polymer. Supports two-way communication on encrypted facility frequencies. Used by prisoners."
	icon_state = "prisoner_headset"
	item_state = "prisoner_headset"
	ks2type = /obj/item/encryptionkey/prisoner
	freqlock = TRUE
	default_frequency = PRS_FREQ

/obj/item/radio/headset/green
	name = "green radio headset"
	desc = "A radio headset made from impact-resistant polymer. Supports two-way communication on encrypted facility frequencies. Used by the green team."
	icon_state = "syndie_headset"
	item_state = "syndie_headset"
	ks2type = /obj/item/encryptionkey/green
	freqlock = TRUE
	default_frequency = T1_FREQ

/obj/item/radio/headset/blue
	name = "blue radio headset"
	desc = "A radio headset made from impact-resistant polymer. Supports two-way communication on encrypted facility frequencies. Used by the blue team."
	icon_state = "syndie_headset"
	item_state = "syndie_headset"
	ks2type = /obj/item/encryptionkey/blue
	freqlock = TRUE
	default_frequency = T2_FREQ

/obj/item/radio/headset/red
	name = "red radio headset"
	desc = "A radio headset made from impact-resistant polymer. Supports two-way communication on encrypted facility frequencies. Used by the red team."
	icon_state = "syndie_headset"
	item_state = "syndie_headset"
	ks2type = /obj/item/encryptionkey/red
	freqlock = TRUE
	default_frequency = T3_FREQ

/obj/item/radio/headset/headset_iaa
	name = "lawyer radio headset"
	desc = "This is used by your elite legal team."
	icon_state = "sec_headset"
	ks2type = /obj/item/encryptionkey/headset_iaa

/obj/item/radio/headset/headset_iaa/alt
	name = "lawyer bowman headset"
	desc = "This is used by your elite legal team. Protects ears from flashbangs."
	item_flags = BANGPROTECT_MINOR
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"

/obj/item/radio/headset/headset_eng
	name = "engineering radio headset"
	desc = "When the engineers wish to chat like girls."
	icon_state = "eng_headset"
	ks2type = /obj/item/encryptionkey/headset_eng

/obj/item/radio/headset/headset_rob
	name = "robotics radio headset"
	desc = "Made specifically for the roboticists who cannot decide between departments."
	icon_state = "rob_headset"
	ks2type = /obj/item/encryptionkey/headset_rob

/obj/item/radio/headset/headset_med
	name = "medical radio headset"
	desc = "A headset for the trained staff of the medbay."
	icon_state = "med_headset"
	ks2type = /obj/item/encryptionkey/headset_med

/obj/item/radio/headset/headset_sci
	name = "science radio headset"
	desc = "A sciency headset. Like usual."
	icon_state = "sci_headset"
	ks2type = /obj/item/encryptionkey/headset_sci

/obj/item/radio/headset/headset_medsci
	name = "medical research radio headset"
	desc = "A headset that is a result of the mating between medical and science."
	icon_state = "medsci_headset"
	ks2type = /obj/item/encryptionkey/headset_medsci

/obj/item/radio/headset/headset_com
	name = "command radio headset"
	desc = "A headset with a commanding channel."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/headset_com

/obj/item/radio/headset/heads/captain
	name = "captain's headset"
	desc = "The headset of the boss."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/captain

/obj/item/radio/headset/heads/captain/alt
	name = "\proper the captain's bowman headset"
	desc = "The headset of the boss. Protects ears from flashbangs."
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/rd
	name = "Research Director's headset"
	desc = "Headset of the researching God."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/rd

/obj/item/radio/headset/heads/hos
	name = "head of security's headset"
	desc = "The headset of the man who protects your worthless lives."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/hos

/obj/item/radio/headset/heads/hos/alt
	name = "\proper the head of security's bowman headset"
	desc = "The headset of the man in charge of keeping order and protecting the station. Protects ears from flashbangs."
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/ce
	name = "chief engineer's headset"
	desc = "The headset of the guy who is in charge of morons."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/ce

/obj/item/radio/headset/heads/cmo
	name = "chief medical officer's headset"
	desc = "The headset of the highly trained medical chief."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/cmo

/obj/item/radio/headset/heads/hop
	name = "head of personnel's headset"
	desc = "The headset of the guy who will one day be captain."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/hop

/obj/item/radio/headset/heads/qm
	name = "quartermaster's headset"
	desc = "Smelling of tobacco and gunpowder, this headset has likely seen many backroom deals."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/qm

/obj/item/radio/headset/headset_cargo
	name = "supply radio headset"
	desc = "A headset used by the cargo department."
	icon_state = "cargo_headset"
	item_state = "cargo_headset"
	ks2type = /obj/item/encryptionkey/headset_cargo

/obj/item/radio/headset/headset_cargo/mining
	name = "mining radio headset"
	desc = "Headset used by shaft miners."
	icon_state = "mine_headset"

/obj/item/radio/headset/headset_service
	name = "service radio headset"
	desc = "Headset used by the service staff, tasked with keeping the station full, happy and clean."
	icon_state = "srv_headset"
	ks2type = /obj/item/encryptionkey/headset_service

/obj/item/radio/headset/heads/ntrep
	name = "nanotrasen representative's headset"
	desc = "The headset of the Nanotrasen Representative."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/ntrep

/obj/item/radio/headset/heads/magistrate
	name = "magistrate's headset"
	desc = "The headset of the Magistrate."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/magistrate

/obj/item/radio/headset/heads/magistrate/alt
	name = "\proper magistrate's bowman headset"
	desc = "The headset of the Magistrate. Protects ears from flashbangs."
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/blueshield
	name = "blueshield's headset"
	desc = "The headset of the Blueshield."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/blueshield

/obj/item/radio/headset/heads/blueshield/alt
	name = "\proper blueshield's bowman headset"
	desc = "The headset of the Blueshield. Protects ears from flashbangs."
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/ert
	name = "emergency response team headset"
	desc = "The headset of the boss's boss."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/ert
	freqlock = TRUE

/obj/item/radio/headset/ert/alt
	name = "emergency response team's bowman headset"
	desc = "An ergonomic tactical headset used by Nanotrasen-affiliated PMCs. Protects against loud noises."
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/ert/alt/solgov
	name = "Trans-Solar Federation Marine's bowman headset"
	desc = "An ergonomic combat headset used by the TSMC. Protects against loud noises."

/obj/item/radio/headset/ert/alt/commander
	name = "ERT commander's bowman headset"
	desc = "The headset of the boss. Protects ears from flashbangs. Can transmit even if telecomms are down."
	requires_tcomms = FALSE
	instant = TRUE

/obj/item/radio/headset/ert/alt/commander/solgov
	name = "Trans-Solar Federation Lieutenant's bowman headset"
	desc = "An ergonomic combat headset used by the TSMC. This model is equipped with an extra-strength transmitter for barking orders."

/obj/item/radio/headset/centcom
	name = "\proper centcom officer's bowman headset"
	desc = "The headset of final authority. Protects ears from flashbangs. Can transmit even if telecomms are down."
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"
	ks2type = /obj/item/encryptionkey/centcom
	requires_tcomms = FALSE
	instant = TRUE

/obj/item/radio/headset/centcom/solgov
	name = "Trans-Solar Federation General's bowman headset"
	desc = "An elite tactical headset made from advanced titanium-aluminum alloys around a composite-polymer frame. Active noise cancellation keeps surrounding sound comfortable, protects hearing and ensures clear audio during intense combat. Built-in telecommunications equipment supports reliable, high-quality two-way communication on every facility frequency, as well as restricted Marine Corps and elite TSF unit channels, providing real-time situational awareness. Operates independently of local telecommunications systems. Used by TSF generals."

/obj/item/radio/headset/heads/ai_integrated //No need to care about icons, it should be hidden inside the AI anyway.
	name = "AI subspace transceiver"
	desc = "Integrated AI radio transceiver."
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "radio"
	ks2type = /obj/item/encryptionkey/heads/ai_integrated
	var/myAi = null	// Atlantis: Reference back to the AI which has this radio.
	var/disabledAi = FALSE // Atlantis: Used to manually disable AI's integrated radio via intellicard menu.

/obj/item/radio/headset/headset_mining_medic
	name = "mining medic's radio headset"
	desc = "A rugged radio headset made from antiseptic plastic with a heat-resistant coating. Supports encrypted medical and supply frequencies and includes dust protection. Used by medical personnel working on the surface of Lazis."
	icon_state = "minmed_headset"
	ks2type = /obj/item/encryptionkey/headset_mining_medic

/obj/item/radio/headset/heads/ai_integrated/is_listening()
	if(disabledAi)
		return FALSE
	return ..()

/obj/item/radio/headset/all_channels // Its only feature is all channels.
	ks1type = /obj/item/encryptionkey/admin

/* Currently unusable due to language refactoring
/obj/item/radio/headset/event_1
	desc = "A headset linked to special long range alpha frequency in this sector."
	icon_state = "headset"
	item_state = "headset"
	ks1type = /obj/item/encryptionkey/event_1
	requires_tcomms = FALSE
	instant = TRUE
	freqlock = TRUE

/obj/item/radio/headset/event_2
	desc = "A headset linked to special long range beta frequency in this sector."
	icon_state = "headset"
	item_state = "headset"
	ks1type = /obj/item/encryptionkey/event_2
	requires_tcomms = FALSE
	instant = TRUE
	freqlock = TRUE

/obj/item/radio/headset/event_3
	desc = "A headset linked to special long range gamma frequency in this sector."
	icon_state = "headset"
	item_state = "headset"
	ks1type = /obj/item/encryptionkey/event_3
	requires_tcomms = FALSE
	instant = TRUE
	freqlock = TRUE
*/

/obj/item/bowman_conversion_tool
	name = "bowman headset conversion tool"
	desc = "Easy-to-apply device which enchances headset with loud noise protection."
	icon = 'icons/obj/radio.dmi'
	icon_state = "bowman_conversion_tool"
	var/static/list/valid_headset_types
	var/static/list/forbidden_headset_types = list(
		/obj/item/radio/headset/syndicate,
		/obj/item/radio/headset/abductor
	)
	var/static/list/forbidden_headset_typecache

/obj/item/bowman_conversion_tool/Initialize(mapload)
	. = ..()
	if(!forbidden_headset_typecache)
		forbidden_headset_typecache = list()
		for(var/path in forbidden_headset_types)
			forbidden_headset_typecache += typecacheof(path)

	if(!valid_headset_types)
		valid_headset_types = list()
		for(var/headset in subtypesof(/obj/item/radio/headset))
			var/obj/item/radio/headset/temp = headset
			if(initial(temp.item_flags) & BANGPROTECT_MINOR)
				if(headset in forbidden_headset_typecache)
					continue
				valid_headset_types[initial(temp.name)] = temp

/obj/item/bowman_conversion_tool/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	. = ..()
	if(!istype(target, /obj/item/radio/headset))
		return

	if(!proximity_flag)
		return

	var/headset_name = tgui_input_list(usr, "Выберите тип гарнитуры", "Тактическая гарнитура", valid_headset_types, null)
	if(!headset_name)
		user.balloon_alert(user, "модификация прервана!")
		return

	var/obj/item/radio/headset/headset = target
	headset.item_flags |= BANGPROTECT_MINOR
	var/headset_path = valid_headset_types[headset_name]
	var/obj/item/radio/headset/mask = new headset_path
	headset.name = initial(mask.name)
	headset.ru_names = mask.get_ru_names_cached()
	headset.desc = initial(mask.desc)
	headset.icon = initial(mask.icon)
	headset.icon_state = initial(mask.icon_state)
	to_chat(user, span_notice("Вы модифицировали гарнитуру в [headset.declent_ru(ACCUSATIVE)]. Теперь она защищает ваши органы слуха от громких звуков."))
	qdel(src)
	qdel(mask)
