
/obj/item/encryptionkey
	name = "Standard Encryption Key"
	desc = "An encyption key for a radio headset. Contains cypherkeys."
	icon = 'icons/map_icons/items/encryptionkey.dmi'
	icon_state = "/obj/item/encryptionkey"
	item_state = ""
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/encryptionkey_basic
	greyscale_colors = "#535353#535353"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "engineering=2;bluespace=1"
	var/translate_binary = FALSE
	var/translate_hive = FALSE
	var/syndie = FALSE
	var/change_voice = FALSE
	var/list/channels = list()

/obj/item/encryptionkey/syndicate
	name = "syndicate encryption key"
	desc = "Ключ шифрования, устанавливаемый в гарнитуру. Содержит в себе лучшее хакерское ПО, доступное на чёрном рынке и позволяющее получить доступ ко всем частотам \"Нанотрейзен\"."
	icon_state = "/obj/item/encryptionkey/syndicate"
	greyscale_config = /datum/greyscale_config/encryptionkey_syndie
	greyscale_colors = "#3c3c3c#ff0000#ff0000"
	channels = list(SYND_FREQ_NAME = 1)
	origin_tech = "syndicate=1;engineering=3;bluespace=2"
	syndie = TRUE //Signifies that it de-crypts Syndicate transmissions
	change_voice = TRUE
	var/fake_name = "Агент ЗОВИТЕ КОДЕРА"
	var/static/list/fakename_list

/obj/item/encryptionkey/syndicate/Initialize(mapload)
	if(!LAZYLEN(fakename_list))
		fakename_list = GLOB.html_colors.Copy()
	. = ..()
	if(change_voice)
		fake_name = "Агент [pick_n_take(fakename_list)]"

/obj/item/encryptionkey/syndicate/nukeops
	greyscale_colors = "#941c1c#3c3c3c#18ff00"
	change_voice = FALSE

/obj/item/encryptionkey/syndteam
	name = "syndicate encryption key"
	desc = "Ключ шифрования, устанавливаемый в гарнитуру. Содержит в себе лучшее хакерское ПО, доступное на чёрном рынке и позволяющее получить доступ ко всем частотам \"Нанотрейзен\"."
	icon_state = "/obj/item/encryptionkey/syndicate"
	greyscale_config = null
	channels = list(SYNDTEAM_FREQ_NAME = 1, SYND_FREQ_NAME = 1)
	origin_tech = "syndicate=4"
	syndie = TRUE //Signifies that it de-crypts Syndicate transmissions

/obj/item/encryptionkey/soviet
	name = "Soviet encryption key"
	icon_state = "/obj/item/encryptionkey/soviet"
	greyscale_config = /datum/greyscale_config/encryptionkey_stripe
	greyscale_colors = "#e90808#ffea00"
	channels = list(SOV_FREQ_NAME = 1)

/obj/item/encryptionkey/binary
	name = "binary translator key"
	desc = "An encryption key for a radio headset. To access the binary channel, use :+."
	icon_state = "/obj/item/encryptionkey/binary"
	greyscale_config = /datum/greyscale_config/encryptionkey_square
	greyscale_colors = "#4b499f"
	translate_binary = TRUE
	origin_tech = "syndicate=1;engineering=4;bluespace=3"

/obj/item/encryptionkey/headset_sec
	name = "Security Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/headset_sec"
	greyscale_config = /datum/greyscale_config/encryptionkey_stripe
	greyscale_colors = "#d21c1c#ffaa3e"
	channels = list(SEC_FREQ_NAME = 1, PRS_FREQ_NAME = 1)

/obj/item/encryptionkey/prisoner
	name = "Prisoners Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/prisoner"
	greyscale_colors = "#da7f17"
	channels = list(PRS_FREQ_NAME = 1)

/obj/item/encryptionkey/green
	name = "Green tean Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/green"
	greyscale_colors = "#2bff00"
	channels = list(GREEN_NAME = 1)

/obj/item/encryptionkey/blue
	name = "Blue tean Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/blue"
	greyscale_colors = "#2200ff"
	channels = list(BLUE_NAME = 1)

/obj/item/encryptionkey/red
	name = "Red tean Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/red"
	greyscale_colors = "#ff0000"
	channels = list(RED_NAME = 1)

/obj/item/encryptionkey/headset_iaa
	name = "Lawyer Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/headset_sec"
	greyscale_config = /datum/greyscale_config/encryptionkey_stripe
	greyscale_colors = "#545454#ff296b"
	channels = list(SEC_FREQ_NAME = 1, PROC_FREQ_NAME = 1, PRS_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_eng
	name = "Engineering Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/headset_eng"
	greyscale_config = /datum/greyscale_config/encryptionkey_stripe
	greyscale_colors = "#ffcc00#ff7100"
	channels = list(ENG_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_rob
	name = "Robotics Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/headset_rob"
	greyscale_config = /datum/greyscale_config/encryptionkey_stripe
	greyscale_colors = "#4c4c4c#c200aa"
	channels = list(ENG_FREQ_NAME = 1, SCI_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_med
	name = "Medical Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/headset_med"
	greyscale_config = /datum/greyscale_config/encryptionkey_stripe
	greyscale_colors = "#ffffff#70d2c4"
	channels = list(MED_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_sci
	name = "Science Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/headset_sci"
	greyscale_config = /datum/greyscale_config/encryptionkey_stripe
	greyscale_colors = "#ffffff#c944d6"
	channels = list(SCI_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_medsci
	name = "Medical Research Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/headset_medsci"
	greyscale_config = /datum/greyscale_config/encryptionkey_stripe
	greyscale_colors = "#70d2c4#c944d6"
	channels = list(MED_FREQ_NAME = 1, SCI_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_medsec
	name = "Medical Security Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/headset_medsec"
	greyscale_config = /datum/greyscale_config/encryptionkey_stripe
	greyscale_colors = "#ffffff#ff0000"
	channels = list(SEC_FREQ_NAME = 1, MED_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_com
	name = "Command Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/headset_com"
	greyscale_colors = "#46629b"
	channels = list(COMM_FREQ_NAME = 1)

/obj/item/encryptionkey/heads
	greyscale_config = null

/obj/item/encryptionkey/heads/captain
	name = "Captain's Encryption Key"
	icon_state = "/obj/item/encryptionkey/heads/captain"
	greyscale_config = /datum/greyscale_config/encryptionkey_double_stripe
	greyscale_colors = "#46629b#ffcc00"
	channels = list(COMM_FREQ_NAME = 1, SEC_FREQ_NAME = 1, ENG_FREQ_NAME = 0, SCI_FREQ_NAME = 0, MED_FREQ_NAME = 0, SUP_FREQ_NAME = 0, SRV_FREQ_NAME = 0, PRS_FREQ_NAME = 0, PROC_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/rd
	name = "Research Director's Encryption Key"
	icon_state = "/obj/item/encryptionkey/heads/rd"
	greyscale_config = /datum/greyscale_config/encryptionkey_double_stripe
	greyscale_colors = "#8f469b#ffcc00"
	channels = list(SCI_FREQ_NAME = 1, COMM_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/hos
	name = "Head of Security's Encryption Key"
	icon_state = "/obj/item/encryptionkey/heads/hos"
	greyscale_config = /datum/greyscale_config/encryptionkey_double_stripe
	greyscale_colors = "#b11818#ffcc00"
	channels = list(SEC_FREQ_NAME = 1, COMM_FREQ_NAME = 1, PRS_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/ce
	name = "Chief Engineer's Encryption Key"
	icon_state = "/obj/item/encryptionkey/heads/ce"
	greyscale_config = /datum/greyscale_config/encryptionkey_double_stripe
	greyscale_colors = "#ffcc00#67ccba"
	channels = list(ENG_FREQ_NAME = 1, COMM_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/cmo
	name = "Chief Medical Officer's Encryption Key"
	icon_state = "/obj/item/encryptionkey/heads/cmo"
	greyscale_config = /datum/greyscale_config/encryptionkey_double_stripe
	greyscale_colors = "#5fd3ff#ffea69"
	channels = list(MED_FREQ_NAME = 1, COMM_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/hop
	name = "Head of Personnel's Encryption Key"
	icon_state = "/obj/item/encryptionkey/heads/hop"
	greyscale_config = /datum/greyscale_config/encryptionkey_double_stripe
	greyscale_colors = "#4a78de#fff368"
	channels = list(SRV_FREQ_NAME = 1, SEC_FREQ_NAME = 0, COMM_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/qm
	name = "Quartermaster's Encryption Key"
	icon_state = "/obj/item/encryptionkey/heads/qm"
	greyscale_config = /datum/greyscale_config/encryptionkey_double_stripe
	greyscale_colors = "#c2934a#fff368"
	channels = list(SUP_FREQ_NAME = 1, COMM_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/ntrep
	name = "Nanotrasen Representative's Encryption Key"
	icon_state = "/obj/item/encryptionkey/heads/ntrep"
	greyscale_config = /datum/greyscale_config/encryptionkey_stripe
	greyscale_colors = "#46629b#ffcc00"
	channels = list(COMM_FREQ_NAME = 1, SEC_FREQ_NAME = 0, PRS_FREQ_NAME = 0, ENG_FREQ_NAME = 0, SCI_FREQ_NAME = 0, MED_FREQ_NAME = 0, SUP_FREQ_NAME = 0, SRV_FREQ_NAME = 0, PROC_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/magistrate
	name = "Magistrate's Encryption Key"
	icon_state = "/obj/item/encryptionkey/heads/magistrate"
	greyscale_config = /datum/greyscale_config/encryptionkey_double_stripe
	greyscale_colors = "#545454#ff296b"
	channels = list(COMM_FREQ_NAME = 1, SEC_FREQ_NAME = 1, PRS_FREQ_NAME = 1, PROC_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/blueshield
	name = "Blueshield's Encryption Key"
	icon_state = "/obj/item/encryptionkey/heads/blueshield"
	greyscale_config = /datum/greyscale_config/encryptionkey_double_stripe
	greyscale_colors = "#545454#6877ff"
	channels = list(COMM_FREQ_NAME = 1)

/*
/obj/item/encryptionkey/headset_mine
	name = "Mining Radio Encryption Key"
	icon_state = "mine_cypherkey"
	channels = list("Шахта" = 1)
*/
/obj/item/encryptionkey/headset_cargo
	name = "Supply Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/headset_cargo"
	greyscale_config = /datum/greyscale_config/encryptionkey_stripe
	greyscale_colors = "#a98a4a#dc7dff"
	channels = list(SUP_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_service
	name = "Service Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/headset_service"
	greyscale_config = /datum/greyscale_config/encryptionkey_stripe
	greyscale_colors = "#6dd83d#e9ff22"
	channels = list(SRV_FREQ_NAME = 1)

/obj/item/encryptionkey/ert
	name = "Nanotrasen ERT Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/heads/blueshield"
	greyscale_config = null
	channels = list(ERT_FREQ_NAME = 1, SCI_FREQ_NAME = 1, COMM_FREQ_NAME = 1, MED_FREQ_NAME = 1, ENG_FREQ_NAME = 1, SEC_FREQ_NAME = 1, PRS_FREQ_NAME = 1, SUP_FREQ_NAME = 1, SRV_FREQ_NAME = 1, PROC_FREQ_NAME = 1)

/obj/item/encryptionkey/centcom
	name = "Centcom Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/centcom"
	greyscale_config = /datum/greyscale_config/encryptionkey_double_stripe
	greyscale_colors = "#479b46#ffcc00"
	channels = list(ERT_FREQ_NAME = 1, DTH_FREQ_NAME = 1, SCI_FREQ_NAME = 1, COMM_FREQ_NAME = 1, MED_FREQ_NAME = 1, ENG_FREQ_NAME = 1, SEC_FREQ_NAME = 1, PRS_FREQ_NAME = 1, SUP_FREQ_NAME = 1, SRV_FREQ_NAME = 1, PROC_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/ai_integrated //ported from bay, this goes 'inside' the AI.
	name = "AI Integrated Encryption Key"
	desc = "Integrated encryption key."
	icon_state = "/obj/item/encryptionkey/heads/ai_integrated"
	greyscale_config = /datum/greyscale_config/encryptionkey_double_stripe
	greyscale_colors = "#46629b#62ca00"
	channels = list(COMM_FREQ_NAME = 1, SEC_FREQ_NAME = 1, PRS_FREQ_NAME = 1, ENG_FREQ_NAME = 1, SCI_FREQ_NAME = 1, MED_FREQ_NAME = 1, SUP_FREQ_NAME = 1, SRV_FREQ_NAME = 1, AI_FREQ_NAME = 1, PROC_FREQ_NAME = 1)

/obj/item/encryptionkey/admin //totally shitspawn
	name = "Admin Radio Encryption Key"
	icon_state = "/obj/item/encryptionkey/admin"
	greyscale_config = /datum/greyscale_config/encryptionkey_double_stripe
	greyscale_colors = "#ffe964#87e748"
	channels = list(PUB_FREQ_NAME = 1, SCI_FREQ_NAME = 1, COMM_FREQ_NAME = 1, MED_FREQ_NAME = 1, ENG_FREQ_NAME = 1, SEC_FREQ_NAME = 1, PRS_FREQ_NAME = 1, SUP_FREQ_NAME = 1, SRV_FREQ_NAME = 1, PROC_FREQ_NAME = 1, AI_FREQ_NAME = 1, SYND_FREQ_NAME = 1,  \
		ERT_FREQ_NAME = 1, DTH_FREQ_NAME = 1, SYNDTEAM_FREQ_NAME = 1, SOV_FREQ_NAME = 1, MED_I_FREQ_NAME = 1, SEC_I_FREQ_NAME = 1, SPY_SPIDER_FREQ_NAME = 1, NINJA_FREQ_NAME = 1, EVENT_ALPHA_FREQ_NAME = 1, EVENT_BETA_FREQ_NAME = 1, EVENT_GAMMA_FREQ_NAME = 1, VOX_RAID_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_mining_medic
	name = "Medical Mining Encryption Key"
	channels = list(MED_FREQ_NAME = 1, SUP_FREQ_NAME = 1)
	icon_state = "/obj/item/encryptionkey/headset_mining_medic"
	greyscale_config = /datum/greyscale_config/encryptionkey_stripe
	greyscale_colors = "#ffffff#a98a4a"

/* Currently unusable due to language refactoring.
/obj/item/encryptionkey/event_1
	name = "Encryption key"
	desc = "An encryption key for a radio headset. To access special radio channel, use :1."
	icon_state = "sov_cypherkey"
	channels = list(EVENT_ALPHA_FREQ_NAME = 1)

/obj/item/encryptionkey/event_2
	name = "Encryption key"
	desc = "An encryption key for a radio headset. To access special radio channel, use :2."
	icon_state = "sov_cypherkey"
	channels = list(EVENT_BETA_FREQ_NAME = 1)

/obj/item/encryptionkey/event_3
	name = "Encryption key"
	desc = "An encryption key for a radio headset. To access special radio channel, use :3."
	icon_state = "sov_cypherkey"
	channels = list(EVENT_GAMMA_FREQ_NAME = 1)
*/
