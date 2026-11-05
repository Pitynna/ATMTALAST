// =============== HEADSETS ===============

/obj/item/radio/headset/vox
	name = "vox headset"
	desc = "A long-range headset for staying in touch with the flock."
	origin_tech = "syndicate=3"
	ks1type = /obj/item/encryptionkey/vox
	requires_tcomms = FALSE
	instant = TRUE // Work instantly if there are no comms
	freqlock = TRUE
	default_frequency = VOX_RAID_FREQ

/obj/item/radio/headset/vox/alt
	name = "vox protect headset"
	desc = "A long-range headset for staying in touch with the flock. Protects the ears from loud sounds."
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"
	item_flags = BANGPROTECT_MINOR

/obj/item/encryptionkey/vox
	name = "vox raider key"
	icon = 'icons/obj/machines/trader_machine.dmi'
	icon_state = "vox_key"
	greyscale_config = null
	channels = list(VOX_RAID_FREQ_NAME = 1, SYND_FREQ_NAME = 1)
	origin_tech = "syndicate=3"
	syndie = TRUE
