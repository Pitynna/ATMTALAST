// MARK: Base
/obj/item/clothing/accessory/head_strip
	abstract_type = /obj/item/clothing/accessory/head_strip
	name = "FILE A BUG REPORT"
	icon_state = null
	item_state = null
	gender = FEMALE
	actions_types = list(/datum/action/item_action/show_head_strip)
	/// Name in Russian of the accessory without quotes, just the keyword
	var/strip_ru_name = null
	/// Cooldown for displaying accessory
	COOLDOWN_DECLARE(fluff_cooldown)

/obj/item/clothing/accessory/head_strip/Initialize(mapload)
	. = ..()
	var/bubble = get_bubble_override()
	if(bubble)
		AddComponent(/datum/component/bubble_icon_override, bubble, BUBBLE_ICON_PRIORITY_ACCESSORY)

/// Returns the speech bubble icon for this patch. Overridden in subtypes.
/obj/item/clothing/accessory/head_strip/proc/get_bubble_override()
	return

/obj/item/clothing/accessory/head_strip/attack_self(mob/user)
	. = ..()
	if(.)
		return
	fluff_attack_self_action(user)

/obj/item/clothing/accessory/head_strip/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_ACCESSORY)
		return TRUE

/obj/item/clothing/accessory/head_strip/proc/fluff_attack_self_action(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	if(!COOLDOWN_FINISHED(src, fluff_cooldown))
		return

	user.custom_emote(EMOTE_VISIBLE, "показыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)].")
	COOLDOWN_START(src, fluff_cooldown, 5 SECONDS)

/obj/item/clothing/accessory/head_strip/uniform_check(mob/living/carbon/human/target, mob/living/user, obj/item/clothing/under/uniform)
	. = ..()
	if(. && locate(/obj/item/clothing/accessory/head_strip, uniform.contents))
		return FALSE

/obj/item/clothing/accessory/head_strip/captain
	name = "Captain's strip"
	desc = "A densely stitched round patch of blue velvet with gold trim. The Nanotrasen logo is embroidered in gold metallic thread. Awarded by Central Command for outstanding station management."
	icon_state = "capstrip"
	item_state = "capstrip"
	strip_ru_name = JOB_TITLE_RU_CAPTAIN

/obj/item/clothing/accessory/head_strip/captain/get_bubble_override()
	return "CAP"

/obj/item/clothing/accessory/head_strip/rd
	name = "Research Director's strip"
	desc = "A densely stitched round patch of purple velvet. The Nanotrasen logo is embroidered in pinkish metallic thread. Awarded by Central Command for outstanding research achievements."
	icon_state = "rdstrip"
	item_state = "rdstrip"
	strip_ru_name = JOB_TITLE_RU_RD

/obj/item/clothing/accessory/head_strip/rd/get_bubble_override()
	return "RD"

/obj/item/clothing/accessory/head_strip/ce
	name = "Chief Engineer's strip"
	desc = "A densely stitched round patch of grey-and-yellow velvet. The Nanotrasen logo is embroidered in light-blue metallic thread. Awarded by Central Command for outstanding engineering achievements."
	icon_state = "cestrip"
	item_state = "cestrip"
	strip_ru_name = JOB_TITLE_RU_CHIEF_ENGINEER

/obj/item/clothing/accessory/head_strip/ce/get_bubble_override()
	return "CE"

/obj/item/clothing/accessory/head_strip/t4ce
	name = "Grand Chief Engineer's strip"
	desc = "A densely stitched round patch of grey velvet with the Nanotrasen logo embroidered in yellow metallic thread. Look closely and you can see electricity flowing through the thread, producing tiny sparks."
	icon_state = "t4cestrip"
	item_state = "t4cestrip"
	strip_ru_name = "Супер" + JOB_TITLE_RU_CHIEF_ENGINEER

/obj/item/clothing/accessory/head_strip/t4ce/get_bubble_override()
	return "T4CE"

/obj/item/clothing/accessory/head_strip/cmo
	name = "Chief Medical Officer's strip"
	desc = "A densely stitched round patch of light-blue velvet. The Nanotrasen logo is embroidered in white metallic thread. Awarded by Central Command for outstanding medical achievements."
	icon_state = "cmostrip"
	item_state = "cmostrip"
	strip_ru_name = JOB_TITLE_RU_CMO

/obj/item/clothing/accessory/head_strip/cmo/get_bubble_override()
	return "CMO"

/obj/item/clothing/accessory/head_strip/hop
	name = "Head of Personnel's strip"
	desc = "A densely stitched round patch of blue velvet with red edging. The Nanotrasen logo is embroidered in white metallic thread. Awarded by Central Command for outstanding personnel management."
	icon_state = "hopstrip"
	item_state = "hopstrip"
	strip_ru_name = JOB_TITLE_RU_HOP

/obj/item/clothing/accessory/head_strip/hop/get_bubble_override()
	return "HOP"

/obj/item/clothing/accessory/head_strip/hos
	name = "Head of Security's strip"
	desc = "A densely stitched round patch of black-and-red velvet. The Nanotrasen logo is embroidered in white-and-red metallic thread. Awarded by Central Command for outstanding service to the corporation."
	icon_state = "hosstrip"
	item_state = "hosstrip"
	strip_ru_name = JOB_TITLE_RU_HOS

/obj/item/clothing/accessory/head_strip/hos/get_bubble_override()
	return "HOS"

/obj/item/clothing/accessory/head_strip/qm
	name = "Quatermaster's strip"
	desc = "A densely stitched round patch of brown velvet. The Nanotrasen logo is embroidered in white metallic thread. Awarded by Central Command for outstanding logistics and cargo handling."
	icon_state = "qmstrip"
	item_state = "qmstrip"
	strip_ru_name = JOB_TITLE_RU_QUARTERMASTER

/obj/item/clothing/accessory/head_strip/qm/get_bubble_override()
	return "QM"

/obj/item/clothing/accessory/head_strip/bs
	name = "Blueshield's strip"
	desc = "A densely stitched round patch of blue velvet with dark-blue edging. The Nanotrasen logo is embroidered in white metallic thread. Awarded by Central Command for outstanding service to the corporation."
	icon_state = "bsstrip"
	item_state = "bsstrip"
	strip_ru_name = JOB_TITLE_RU_BLUESHIELD

/obj/item/clothing/accessory/head_strip/bs/get_bubble_override()
	return "BS"

/obj/item/clothing/accessory/head_strip/ntr
	name = "Nanotrasen Representative's strip"
	desc = "A densely stitched round patch of black velvet with gold edging. The Nanotrasen logo is embroidered in white metallic thread. Awarded by Central Command for exceptional service to the corporation."
	icon_state = "ntrstrip"
	item_state = "ntrstrip"
	strip_ru_name = JOB_TITLE_RU_REPRESENTATIVE

/obj/item/clothing/accessory/head_strip/ntr/get_bubble_override()
	return "NTR"

/obj/item/clothing/accessory/head_strip/syndicate
	name = "Syndicate strip"
	desc = "A dark-red round metal badge with a bright-green S in the center and a burgundy pin."
	icon_state = "syndistrip"
	item_state = "syndistrip"
	strip_ru_name = "Синдикат"

/obj/item/clothing/accessory/head_strip/syndicate/get_bubble_override()
	return "Syndie"

/obj/item/clothing/accessory/head_strip/comrad
	name = "Comrade patch"
	desc = "A rough rectangular khaki patch with white-and-gold side panels and USSP embroidered in red at its center. A standard patch issued to volunteers."
	icon_state = "patch_sssp"
	item_state = "patch_sssp"
	strip_ru_name = "Товарищ"

/obj/item/clothing/accessory/head_strip/comrad/get_bubble_override()
	return "comrad"

/obj/item/clothing/accessory/head_strip/federal
	name = "Federal strip"
	desc = "A densely stitched round patch of blue velvet with white edging and gold accents. The TSF logo is embroidered in white-and-gold metallic thread. Standard insignia for TSF citizens."
	icon_state = "stripe_federal"
	item_state = "stripe_federal"
	strip_ru_name = "Федерал"

/obj/item/clothing/accessory/head_strip/federal/get_bubble_override()
	return "federal"

/obj/item/clothing/accessory/head_strip/greytide
	name = "GreyTide strip"
	desc = "A densely stitched round grey patch with a gas mask in the center."
	icon_state = "greytstrip"
	item_state = "greytstrip"
	strip_ru_name = "GreyTide"

/obj/item/clothing/accessory/head_strip/greytide/get_bubble_override()
	return "greyt"

/obj/item/clothing/accessory/head_strip/lawyers_badge
	name = "attorney's badge"
	desc = "Fills you with the conviction of JUSTICE. Lawyers tend to want to show it to everyone they meet."
	icon_state = "lawyerbadge"
	item_state = "lawyerbadge"
	gender = MALE
	strip_ru_name = JOB_TITLE_RU_LAWYER

/obj/item/clothing/accessory/head_strip/lawyers_badge/get_bubble_override()
	return "lawyer"

/obj/item/clothing/accessory/head_strip/lawyers_badge/fluff_attack_self_action(mob/user)
	. = ..()
	if(prob(1))
		user.say("Показания противоречат доказательствам!")
	user.point_at(src)

/obj/item/clothing/accessory/head_strip/cheese_badge
	name = "great fellow's badge"
	desc = "A densely stitched round patch of yellow-orange velvet. Its center depicts either a crown or a wheel of cheese. Smells faintly of Monterey Jack."
	icon_state = "cheesebadge"
	item_state = "cheesebadge"
	gender = MALE
	strip_ru_name = "Сыр"

/obj/item/clothing/accessory/head_strip/cheese_badge/get_bubble_override()
	return "cheese"

/obj/item/clothing/accessory/head_strip/cheese_badge/fluff_attack_self_action(mob/user)
	. = ..()
	if(prob(1))
		user.say("СЫЫ-Ы-Ы-Ы-Ы-РР!")

/obj/item/clothing/accessory/head_strip/clown
	name = "clown's strip"
	desc = "A densely stitched round patch depicting a clown. Perfect for committing war crimes, because it isn't a war crime if you had fun!"
	icon_state = "clownstrip"
	item_state = "clownstrip"
	strip_ru_name = JOB_TITLE_RU_CLOWN

/obj/item/clothing/accessory/head_strip/clown/get_bubble_override()
	return "clown"

/obj/item/clothing/accessory/head_strip/deathsquad
	name = "deathsquad's strip"
	desc = "A densely stitched round patch of black velvet with red accents. Its center depicts the helmet of a Deathsquad trooper, who is \[REDACTED]."
	icon_state = "deathsquadstrip"
	item_state = "deathsquadstrip"
	strip_ru_name = "Эскадрон Смерти"

/obj/item/clothing/accessory/head_strip/deathsquad/get_bubble_override()
	return "deathsquad"

/obj/item/clothing/accessory/head_strip/triforce
	name = "triforce strip"
	desc = "A round patch of hard yellow plastic with a black border and three glowing light-blue triangles in the center. The triangles are clearly arranged incorrectly."
	icon_state = "triforcestrip"
	item_state = "triforcestrip"
	strip_ru_name = "Трифорс"

/obj/item/clothing/accessory/head_strip/triforce/get_bubble_override()
	return "triforce"

/obj/item/clothing/accessory/head_strip/black_cat
	name = "black cat strip"
	desc = "A densely stitched black velvet patch shaped like a cat's head, with embroidered eyes and a muzzle. Looks purrfect."
	icon_state = "blackcatstrip"
	item_state = "blackcatstrip"
	strip_ru_name = "Чёрный кот"

/obj/item/clothing/accessory/head_strip/black_cat/get_bubble_override()
	return "blackcat"

/obj/item/clothing/accessory/head_strip/fox
	name = "fox strip"
	desc = "A densely stitched orange-thread patch shaped like a fox's head, with embroidered eyes and a nose. Quite cute."
	icon_state = "foxstrip"
	item_state = "foxstrip"
	strip_ru_name = "Лиса"

/obj/item/clothing/accessory/head_strip/fox/get_bubble_override()
	return "fox"

/obj/item/clothing/accessory/head_strip/frog
	name = "frog strip"
	desc = "A densely stitched green velvet patch shaped like a cheerful frog, with an embroidered mouth and white belly. Made for true frog enthusiasts."
	icon_state = "frogstrip"
	item_state = "frogstrip"
	strip_ru_name = "Лягушка"

/obj/item/clothing/accessory/head_strip/frog/get_bubble_override()
	return "frog"

/obj/item/clothing/accessory/head_strip/whitecatstrip
	name = "white cat strip"
	desc = "A densely stitched white velvet patch shaped like a cat's head, with embroidered eyes and a muzzle. Looks cute."
	icon_state = "whitecatstrip"
	item_state = "whitecatstrip"
	strip_ru_name = "Белый кот"

/obj/item/clothing/accessory/head_strip/whitecatstrip/get_bubble_override()
	return "whitecat"

/obj/item/clothing/accessory/head_strip/orangecatstrip
	name = "orange cat strip"
	desc = "A densely stitched patch of three-colored thread shaped like a cat's head, with embroidered eyes and a muzzle. Looks very cute."
	icon_state = "orangecatstrip"
	item_state = "orangecatstrip"
	strip_ru_name = "Трёхцветный кот"

/obj/item/clothing/accessory/head_strip/orangecatstrip/get_bubble_override()
	return "orangecat"

/obj/item/clothing/accessory/head_strip/ratstrip
	name = "rat strip"
	desc = "A densely stitched grey velvet patch shaped like a rat's head, with embroidered eyes and a muzzle. Looks squeak-squeak-squeaky."
	icon_state = "ratstrip"
	item_state = "ratstrip"
	strip_ru_name = "Крыска"

/obj/item/clothing/accessory/head_strip/ratstrip/get_bubble_override()
	return "rat"

/obj/item/clothing/accessory/head_strip/devilstrip
	name = "devil strip"
	desc = "A densely stitched red velvet patch shaped like a devil's head, with horns above two sinister yellow eyes. Radiates infernal warmth."
	icon_state = "devilstrip"
	item_state = "devilstrip"
	strip_ru_name = "Дьявол"

/obj/item/clothing/accessory/head_strip/devilstrip/get_bubble_override()
	return "devil"

/obj/item/clothing/accessory/head_strip/labratstrip
	name = "lab rat strip"
	desc = "A densely stitched snow-white velvet patch shaped like a laboratory rat's head, with pink ears and red eyes. Looks as if it has seen a lot."
	icon_state = "labratstrip"
	item_state = "labratstrip"
	strip_ru_name = "Лабораторная Крыска"

/obj/item/clothing/accessory/head_strip/labratstrip/get_bubble_override()
	return "labrat"

/obj/item/clothing/accessory/head_strip/krampusstrip
	name = "krampus"
	desc = "A densely stitched icy-blue velvet patch shaped like Krampus's head, with branching horns and embroidered purple eyes. Perfect for anyone who has been naughty this year."
	icon_state = "krampusstrip"
	item_state = "krampusstrip"
	strip_ru_name = "Крампус"

/obj/item/clothing/accessory/head_strip/krampusstrip/get_bubble_override()
	return "krampus"

/obj/item/clothing/accessory/head_strip/pursuitstrip
	name = "pursuit"
	desc = "A densely stitched black velvet patch shaped like a wheel. A white P is embroidered in the center, flanked by blue and red warning lights. Smells faintly of burned rubber."
	icon_state = "pursuitstrip"
	item_state = "pursuitstrip"
	strip_ru_name = "Преследователь"

/obj/item/clothing/accessory/head_strip/pursuitstrip/get_bubble_override()
	return "pursuit"

/obj/item/clothing/accessory/head_strip/tvstrip
	name = "tvstrip"
	desc = "A densely stitched brown velvet patch shaped like an old television, with an embroidered color test pattern on its screen and two antennas on top. Don't adjust the colors; they're fine as they are."
	icon_state = "tvstrip"
	item_state = "tvstrip"
	strip_ru_name = "Телевизор"

/obj/item/clothing/accessory/head_strip/tvstrip/get_bubble_override()
	return "tv"
