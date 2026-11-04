/obj/item/card/id/captains_spare
	name = "captain's spare ID"
	icon_state = "gold"
	item_state = "gold-id"
	assignment = JOB_TITLE_RU_CAPTAIN

/obj/item/card/id/captains_spare/Initialize(mapload)
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/card/id/silver
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"
	item_state = "silver-id"

/obj/item/card/id/gold
	desc = "A golden card which shows power and might."
	icon_state = "gold"
	item_state = "gold-id"

/obj/item/card/id/gold/battle
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	access = list(ACCESS_CAPTAIN_REAL)

/obj/item/card/id/gold/battle/ComponentInitialize()
	AddElement(/datum/element/high_value_item)

/obj/item/card/id/gold/battle/Initialize(mapload)
	GLOB.poi_list += src
	. = ..()

/obj/item/card/id/gold/battle/Destroy()
	GLOB.poi_list -= src
	. = ..()

/obj/item/card/id/admin
	name = "admin ID card"
	desc = "An administrative identification card used to verify identity, determine facility access and record employee biometrics. Also useful for extensive admin shenanigans."
	icon_state = "admin"
	item_state = "gold-id"
	assignment = "Магистр щитспауна"
	untrackable = 1

/obj/item/card/id/admin/Initialize(mapload)
	access = get_absolutely_all_accesses()
	. = ..()

/obj/item/card/id/lifetime
	name = "Lifetime ID Card"
	desc = "A modified ID card given only to those people who have devoted their lives to the better interests of Nanotrasen. It sparkles blue."
	icon_state = "lifetimeid"

/obj/item/card/id/library_owl
	name = "Slavka ID"
	assignment = "Сыч Вячеслав"
	access = list(ACCESS_LIBRARY)

/obj/item/card/id/punpun
	name = "Pun Pun ID"
	assignment = "Пун Пун"
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)
