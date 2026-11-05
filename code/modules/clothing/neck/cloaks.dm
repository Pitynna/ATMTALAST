//Cloaks. No, not THAT kind of cloak.

/obj/item/clothing/neck/cloak //We need this "White" for better color adjustment.
	name = "cloak"
	desc = "It's a cloak that can be worn around your neck in a pretty dull color."
	icon_state = "cloak"
	item_state = "syndcapt"
	body_parts_covered = UPPER_TORSO | ARMS
	var/colour = null

/obj/item/clothing/neck/cloak/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)
	add_atom_colour(colour, FIXED_COLOUR_PRIORITY)

/obj/item/clothing/neck/cloak/grey
	colour = "#535353"

/obj/item/clothing/neck/cloak/head_of_security
	name = "head of security's cloak"
	desc = "Worn by the leader of Brigston, ruling the station with an iron fist."
	icon_state = "hoscloak"

/obj/item/clothing/neck/cloak/security
	name = "security officer's cloak"
	desc = "Worn by security officers."
	icon_state = "seccloak"

/obj/item/clothing/neck/cloak/quartermaster
	name = "quartermaster's cloak"
	desc = "Worn by the God-emperor of Cargonia, supplying the station with the necessary tools for survival."
	icon_state = "qmcloak"

/obj/item/clothing/neck/cloak/chief_medical_officer
	name = "chief medical officer's cloak"
	desc = "Worn by the leader of Medistan, the valiant men and women keeping pestilence at bay."
	icon_state = "cmocloak"

/obj/item/clothing/neck/cloak/chief_engineer
	name = "chief engineer's white cloak"
	desc = "Worn by the leader of both Atmosia and Delamistan, wielder of unlimited power."
	icon_state = "cecloak"

/obj/item/clothing/neck/cloak/chief_engineer/white
	desc = "Worn by the leader of both Atmosia and Delamistan, wielder of unlimited power. This one is white."
	icon_state = "cecloak_white"

/obj/item/clothing/neck/cloak/research_director
	name = "research director's cloak"
	desc = "Worn by the leader of Scientopia, the greatest thaumaturgist and researcher of rapid unexpected self disassembly."
	icon_state = "rdcloak"

/obj/item/clothing/neck/cloak/captain
	name = "captain's cloak"
	desc = "Worn by the supreme leader of the NSS Cyberiad."
	icon_state = "capcloak"

/obj/item/clothing/neck/cloak/captain/Initialize(mapload)
	. = ..()
	desc = "Worn by the supreme leader of [station_name()]."

/obj/item/clothing/neck/cloak/head_of_personnel
	name = "head of personnel's cloak"
	desc = "Worn by the Head of Personnel. It smells faintly of bureaucracy."
	icon_state = "hopcloak"

/obj/item/clothing/neck/cloak/nanotrasen_representative
	name = "Nanotrasen Representative's cloak"
	desc = "Worn by a Nanotrasen representative. A faint whisper of denunciation can be heard from under the cloak."
	icon_state = "ntrcloak"

/obj/item/clothing/neck/cloak/blueshield
	name = "Blueshield's cloak"
	desc = "Worn by a Blueshield officer, that faithfully defends its goals."
	icon_state = "blueshieldcloak"

/obj/item/clothing/neck/cloak/healer
	name = "healer's cloak"
	desc = "Worn by the best and most skilled healers, the handlers of hyposprays, pills, auto-menders and first-aid kits."
	icon_state = "healercloak"

/obj/item/clothing/neck/cloak/toggle/owlwings
	name = "owl cloak"
	desc = "A soft brown cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive the ladies mad."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "owl_wings"
	actions_types = list(/datum/action/item_action/toggle_wings)

/obj/item/clothing/neck/cloak/toggle/owlwings/griffinwings
	name = "griffon cloak"
	desc = "A plush white cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive your captives mad."
	icon_state = "griffin_wings"
	item_state = "griffin_wings"

/obj/item/clothing/neck/cloak/bishop
	name = "bishop's cloak"
	desc = "Become the space pope."
	icon_state = "bishopcloak"
	item_state = "bishopcloak"

/obj/item/clothing/neck/cloak/bishopblack
	name = "black bishop cloak"
	desc = "Become the space pope."
	icon_state = "blackbishopcloak"
	item_state = "blackbishopcloak"

/obj/item/clothing/neck/cloak/syndiecap
	name = "syndicate captain's cloak"
	desc = "A cloak that inspires fear among Nanotrasen employees, worn by the greatest Syndicate captains."
	icon_state = "syndcapt"

/obj/item/clothing/neck/cloak/syndiecap/comms
	name = "syndicate officer's cloak"
	desc = "A cloak that inspires fear among Nanotrasen employees, worn by the greatest Syndicate officers."

/obj/item/clothing/neck/cloak/syndieadm
	name = "syndicate admiral's cloak"
	desc = "A deep red cloak, worn by only the greatest of the Syndicate. If you are looking at this, you probably won't be looking at it for much longer."
	icon_state = "syndadmiral"
	item_state = "syndadmiral"

/obj/item/clothing/neck/cloak/spacecloak
	name = "space cloak"
	desc = "Hole, a blackhole on your back!"
	icon_state = "spacecloak"
	item_state = "spacecloak"

/obj/item/clothing/neck/cloak/civil_cape
	name = "standard cape cloak"
	desc = "A dark, almost black cape made from heavy fabric with deep-blue edging and two metal clasps. Known for smelling faintly of formaldehyde when wet, a manufacturing defect that was never fixed."
	icon_state = "civil_cape"
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/neck.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/neck.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/neck.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/neck.dmi',
		SPECIES_STOK = 'icons/mob/clothing/neck.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/neck.dmi',
	)

/obj/item/clothing/neck/cloak/commander_cape
	name = "commander cape cloak"
	desc = "A dark anthracite cape with broad blue panels and neat gold embroidery. Its titanium clasps are finished in blackened gold. The dark-blue lining bears the gold-embroidered words Per aspera ad astra."
	icon_state = "commander_cape"
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/neck.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/neck.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/neck.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/neck.dmi',
		SPECIES_STOK = 'icons/mob/clothing/neck.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/neck.dmi',
	)


/obj/item/clothing/neck/cloak/sec_cape
	name = "security officer cape cloak"
	desc = "A long, dark cape made from reinforced fabric with red trim. An NT logo marks its clasp. The trim darkens on contact with blood, though you probably won't notice while covered in blood from head to toe."
	icon_state = "sec_cape"
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/neck.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/neck.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/neck.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/neck.dmi',
		SPECIES_STOK = 'icons/mob/clothing/neck.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/neck.dmi',
	)

/obj/item/clothing/neck/cloak/hos_cape
	name = "marine cape cloak"
	desc = "A cape made from matte, almost nonreflective fabric. Its clasp resembles a medal for heroism. The lower edges look acid-scorched, and it smells of napalm. Gold embroidery inside reads Gloria dei T.S.F."
	icon_state = "hos_cape"
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/neck.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/neck.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/neck.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/neck.dmi',
		SPECIES_STOK = 'icons/mob/clothing/neck.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/neck.dmi',
	)
