// MARK: Base HUD Glasses
/obj/item/clothing/glasses/hud
	abstract_type = /obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	origin_tech = "magnets=3;biotech=2"
	prescription_upgradable = TRUE
	/// The visual icons granted by wearing these glasses.
	var/HUDType = null

/obj/item/clothing/glasses/hud/examine(mob/user)
	. = ..()
	if(emagged)
		. += span_warning("Дисплей едва заметно мерцает.")

/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot, initial)
	. = ..()
	if(!istype(user) || !HUDType || !(slot & (ITEM_SLOT_EYES|ITEM_SLOT_HEAD)))
		return .

	if(islist(HUDType))
		for(var/new_hud in HUDType)
			var/datum/atom_hud/hud = GLOB.huds[new_hud]
			hud.show_to(user)
		return .

	var/datum/atom_hud/hud = GLOB.huds[HUDType]
	hud.show_to(user)

/obj/item/clothing/glasses/hud/dropped(mob/living/carbon/human/user, slot, silent = FALSE)
	. = ..()
	if(!istype(user) || !HUDType || !(slot & (ITEM_SLOT_EYES|ITEM_SLOT_HEAD)))
		return .

	if(islist(HUDType))
		for(var/new_hud in HUDType)
			var/datum/atom_hud/hud = GLOB.huds[new_hud]
			hud.hide_from(user)
		return .

	var/datum/atom_hud/hud = GLOB.huds[HUDType]
	hud.hide_from(user)

/obj/item/clothing/glasses/hud/emp_act(severity)
	. = ..()
	if(!emagged)
		emagged = TRUE

/obj/item/clothing/glasses/hud/visor_toggling(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	if(visor_vars_to_toggle & VISOR_EXAM_EXTENTIONS)
		examine_extensions ^= initial(examine_extensions)

	if(visor_vars_to_toggle & VISOR_HUDTYPE)
		HUDType ^= initial(HUDType)

		var/datum/atom_hud/H = GLOB.huds[initial(HUDType)]
		if(istype(user) && src == user.glasses)
			if(HUDType)
				H.show_to(user)
			else
				H.hide_from(user)

/// Allows you to toggle HUDType on glasses.
/obj/item/clothing/glasses/hud/proc/multiHUD_toggling(mob/living/carbon/human/user)
	if(!HUDType || !user)
		return

	var/datum/atom_hud/oldHUD = GLOB.huds[HUDType]
	var/hudMode = null

	// DATA_HUD_MEDICAL_ADVANCED ->  DATA_HUD_SECURITY_ADVANCED
	switch(HUDType)
		if(DATA_HUD_MEDICAL_ADVANCED)
			HUDType = DATA_HUD_SECURITY_ADVANCED
			examine_extensions = EXAMINE_HUD_SECURITY_READ | EXAMINE_HUD_SECURITY_WRITE
			hudMode = "охранный"
		if(DATA_HUD_SECURITY_ADVANCED)
			HUDType = DATA_HUD_MEDICAL_ADVANCED
			examine_extensions = EXAMINE_HUD_MEDICAL
			hudMode = "медицинский"

	if(user.glasses == src)
		oldHUD.hide_from(user)
		var/datum/atom_hud/newHUD = GLOB.huds[HUDType]
		newHUD.show_to(user)

	balloon_alert(user, "режим ИЛС — [hudMode]")
	playsound(user, 'sound/items/buttonclick.ogg', 50, TRUE)

// MARK: Medical
/obj/item/clothing/glasses/hud/health
	name = "Medical HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = EXAMINE_HUD_MEDICAL

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/health/night
	name = "Night Vision Medical HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	icon_state = "healthhudnight"
	item_state = "nvghud"
	origin_tech = "magnets=4;biotech=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/health/heart
	name = "Heart Medical Glasses"
	desc = "Fashionable heart-shaped glasses with a medical HUD that scans visible living creatures and displays their health information."
	icon_state = "heart_med"
	item_state = "heart_med"

/obj/item/clothing/glasses/hud/health/patch
	name = "Medical HUD Eyepatch"
	desc = "A heads-up eyepatch that scans the humans in view and provides accurate data about their health status."
	gender = FEMALE
	icon_state = "medhudpatch"
	item_state = "medhudpatch"
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/health/sunglasses
	name = "medical sunglasses"
	desc = "Sunglasses with a medical HUD."
	icon_state = "sunhudmed"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/hud/health/tajblind
	name = "medical veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed medical HUD."
	gender = FEMALE
	icon_state = "tajblind_med"
	item_state = "tajblind_med"
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/health/tajblind/sunglasses
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/hud/health/tajblind/attack_self(mob/user)
	toggle_veil(user)

/obj/item/clothing/glasses/hud/health/visor
	name = "Medical optical visor"
	desc = "An advanced eye visor with a medical HUD that scans visible living creatures and displays their health information."
	gender = MALE
	icon_state = "medicalvisor"
	item_state = "medicalvisor"

/obj/item/clothing/glasses/hud/health/meson
	name = "Medical-Meson HUD"
	desc = "A medical heads-up display that comes with an optical meson scanner."
	icon_state = "mesonhealth"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/glasses/hud/health/monocle
	name = "Medical HUD Monocle"
	desc = "An optical instrument held in place by the muscles of the face. Includes a medical HUD that scans visible living creatures and displays their health information."
	gender = MALE
	icon_state = "monohudmed"
	item_state = "monohud"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/diagnostic
	name = "Diagnostic HUD"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits."
	icon_state = "diagnostichud"
	origin_tech = "magnets=2;engineering=2"
	HUDType = DATA_HUD_DIAGNOSTIC

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/diagnostic/patch
	name = "Diagnostic HUD Eyepatch"
	desc = "A heads-up eyepatch capable of analyzing the integrity and status of robotics and exosuits."
	gender = FEMALE
	icon_state = "diaghudpatch"
	item_state = "diaghudpatch"
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/diagnostic/heart
	name = "Heart Diagnostic Glasses"
	desc = "Fashionable heart-shaped glasses with a diagnostic HUD that analyzes the integrity and condition of robotic systems."
	icon_state = "heart_diagnostic"
	item_state = "heart_diagnostic"

/obj/item/clothing/glasses/hud/diagnostic/night
	name = "Night Vision Diagnostic HUD"
	desc = "A robotics diagnostic HUD fitted with a light amplifier."
	icon_state = "diagnostichudnight"
	item_state = "nvghud"
	origin_tech = "magnets=4;powerstorage=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/diagnostic/sunglasses
	name = "diagnostic sunglasses"
	desc = "Sunglasses with a diagnostic HUD."
	icon_state = "sunhuddiag"
	item_state = "sunhuddiag"
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/hud/diagnostic/tajblind
	name = "diagnostic veil"
	desc = "A tajaran veil capable of analyzing the integrity and status of robotics and exosuits."
	gender = FEMALE
	icon_state = "tajblind_diagnostic"
	item_state = "tajblind_diagnostic"
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/diagnostic/tajblind/sunglasses
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/hud/diagnostic/tajblind/attack_self(mob/user)
	toggle_veil(user)

/obj/item/clothing/glasses/hud/diagnostic/visor
	name = "Optical Diagnostic Visor"
	desc = "An advanced eye visor with a diagnostic HUD that analyzes the integrity and condition of robotic systems."
	gender = MALE
	icon_state = "diagvisor"
	item_state = "diagvisor"

/obj/item/clothing/glasses/hud/diagnostic/monocle
	name = "Diagnostic HUD Monocle"
	desc = "An optical instrument held in place by the muscles of the face. Includes a diagnostic HUD that analyzes the integrity and condition of robotic systems."
	gender = MALE
	icon_state = "monohuddiag"
	item_state = "monohud"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/security
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	origin_tech = "magnets=3;combat=2"
	var/global/list/jobs[0]
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = EXAMINE_HUD_SECURITY_READ | EXAMINE_HUD_SECURITY_WRITE

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/security/read_only
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/glasses/hud/security/patch
	name = "Security HUD Eyepatch"
	desc = "A heads-up eyepatch that scans the humans in view and provides accurate data about their ID status and security records."
	gender = FEMALE
	icon_state = "sechudpatch"
	item_state = "sechudpatch"
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/security/patch/read_only
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/glasses/hud/security/night
	name = "Night Vision Security HUD"
	desc = "An advanced heads-up display which provides id data and vision in complete darkness."
	icon_state = "securityhudnight"
	origin_tech = "magnets=4;combat=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "security sunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	origin_tech = "magnets=3;combat=3;engineering=3"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/security/sunglasses/heart
	name = "Heart Security Glasses"
	desc = "Fashionable heart-shaped glasses with a security HUD that scans visible humanoids and displays their security status."
	icon_state = "heart_sec"
	item_state = "heart_sec"

/obj/item/clothing/glasses/hud/security/sunglasses/heart/read_only
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/glasses/hud/security/sunglasses/tacticool
	name = "security tactical glasses"
	desc = "Ballistic glasses with a security HUD. Gives you tacticool protection and selfish increase. The elastic band allows it to be worn over a helmet."
	icon_state = "secgoggles-g"
	item_state = "secgoggles-g"
	over_hat = TRUE
	can_toggle = TRUE
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT | VISOR_DARKNESSVIEW | VISOR_FULL_HUD
	visor_flags_cover = GLASSESCOVERSEYES
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/security/sunglasses/tacticool/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/right_click_mapper/attack_self, "Переключить [declent_ru(ACCUSATIVE)]")

/obj/item/clothing/glasses/hud/security/sunglasses/tacticool/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/glasses/hud/security/sunglasses/read_only
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/glasses/hud/security/sunglasses/aviators
	name = "security aviators"
	desc = "A aviators with a security HUD."
	icon_state = "aviators"

/obj/item/clothing/glasses/hud/security/sunglasses/jensenshades
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "jensenshades"
	item_state = "jensenshades"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/glasses/hud/security/sunglasses/tajblind
	name = "security veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an in-built security HUD."
	gender = FEMALE
	icon_state = "tajblind_sec"
	item_state = "tajblind_sec"
	tint_up = 1
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/security/sunglasses/tajblind/attack_self(mob/user)
	toggle_veil(user)

/obj/item/clothing/glasses/hud/security/sunglasses/tajblind/read_only
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/glasses/hud/security/sunglasses/visor
	name = "Security visor"
	desc = "An advanced eye visor with a security HUD that scans visible humanoids and displays their security status. Also protects the wearer's eyes from bright light."
	gender = MALE
	icon_state = "securityvisor"
	item_state = "securityvisor"

/obj/item/clothing/glasses/hud/security/monocle
	name = "Security HUD Monocle"
	desc = "An optical instrument held in place by the muscles of the face. Includes a security HUD that scans visible humanoids and displays their security status."
	gender = MALE
	icon_state = "monohudsec"
	item_state = "monohud"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/hydroponic
	name = "Hydroponic HUD"
	desc = "A heads-up display capable of analyzing the health and status of plants growing in hydro trays and soil."
	icon_state = "hydroponichud"
	HUDType = DATA_HUD_HYDROPONIC
	examine_extensions = EXAMINE_HUD_BOTANY
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/hydroponic/patch
	name = "Hydroponic HUD Eyepatch"
	desc = "A heads-up eyepatch capable of analyzing the health and status of plants growing in hydro trays and soil."
	gender = FEMALE
	icon_state = "hydrohudpatch"
	item_state = "hydrohudpatch"
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/heart
	name = "Heart Hydroponic Glasses"
	desc = "Fashionable heart-shaped glasses with a botanical HUD that analyzes plants growing in hydroponic trays and soil."
	icon_state = "heart_hydro"
	item_state = "heart_hydro"

/obj/item/clothing/glasses/hud/hydroponic/night
	name = "Night Vision Hydroponic HUD"
	desc = "A hydroponic HUD fitted with a light amplifier."
	icon_state = "hydroponichudnight"
	item_state = "nvghud"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/hydroponic/sunglasses
	name = "hydroponic sunglasses"
	desc = "For cool botanists only"
	icon_state = "sunhudhydro"
	item_state = "sunhudhydro"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/hud/hydroponic/tajblind
	name = "blooming veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. There is botanical hud in it."
	gender = FEMALE
	icon_state = "tajblind_bot"
	item_state = "tajblind_bot"
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/hydroponic/tajblind/sunglasses
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/hud/hydroponic/tajblind/attack_self(mob/user)
	toggle_veil(user)

/obj/item/clothing/glasses/hud/hydroponic/visor
	name = "Hydroponic Optical Visor"
	desc = "An advanced eye visor with a botanical HUD that analyzes plants growing in hydroponic trays and soil."
	gender = MALE
	icon_state = "hydroponicvisor"
	item_state = "hydroponicvisor"

/obj/item/clothing/glasses/hud/hydroponic/monocle
	name = "Hydroponic HUD Monocle"
	desc = "An optical instrument held in place by the muscles of the face. Includes a botanical HUD that analyzes plants growing in hydroponic trays and soil."
	gender = MALE
	icon_state = "monohudhydro"
	item_state = "monohud"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/skills
	name = "Skills HUD"
	desc = "A heads-up display capable of showing the employment history records of NT crew members."
	icon_state = "skill"
	item_state = "skill"
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = EXAMINE_HUD_SKILLS
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY  = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/skills/patch
	name = "Skills HUD Eyepatch"
	desc = "A heads-up eyepatch capable of showing the employment history records of NT crew members."
	gender = FEMALE
	icon_state = "skillhudpatch"
	item_state = "skillhudpatch"
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/skills/heart
	name = "Heart Skills Glasses"
	desc = "Fashionable heart-shaped glasses with a personnel HUD displaying Nanotrasen employees' work records."
	icon_state = "heart_skill"
	item_state = "heart_skill"

/obj/item/clothing/glasses/hud/skills/sunglasses
	name = "skills sunglasses"
	desc = "Sunglasses with a build-in skills HUD, showing the employment history of nearby NT crew members."
	icon_state = "sunhudskill"
	see_in_dark = 1 // None of these three can be converted to booleans. Do not try it.
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY  = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/skills/tajblind
	name = "skills veil"
	desc = "A tajaran veil capable of showing the employment history records of NT crew members."
	gender = FEMALE
	icon_state = "tajblind_skill"
	item_state = "tajblind_skill"
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/skills/tajblind/sunglasses
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/hud/skills/tajblind/attack_self(mob/user)
	toggle_veil(user)

/obj/item/clothing/glasses/hud/skills/visor
	name = "Skill Optical Visor"
	desc = "An advanced eye visor with a personnel HUD displaying Nanotrasen employees' work records."
	gender = MALE
	icon_state = "skillvisor"
	item_state = "skillvisor"
	flash_protect = FLASH_PROTECTION_FLASH

/obj/item/clothing/glasses/hud/skills/monocle
	name = "Skills HUD Monocle"
	desc = "An optical instrument held in place by the muscles of the face. Includes a personnel HUD displaying Nanotrasen employees' work records."
	gender = MALE
	icon_state = "monohudskill"
	item_state = "monohud"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/multimode
	name = "multi-mode HUD glasses"
	desc = "UV-shielded glasses that protect the wearer's eyes from bright flashes. Includes a multimode HUD that switches between medical and security modes."
	actions_types = list(/datum/action/item_action/switch_hud)
	icon_state = "sunhudmed"
	origin_tech = "magnets=4;combat=4;engineering=4;biotech=4"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY  = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/multimode/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/right_click_mapper/attack_self, "Переключить [declent_ru(ACCUSATIVE)]")

/obj/item/clothing/glasses/hud/multimode/attack_self(mob/user)
	multiHUD_toggling(user)

/obj/item/clothing/glasses/hud/multimode/captain
	name = "Gold multi-mod HUD glasses"
	desc = "UV-shielded glasses that protect the wearer's eyes from bright flashes. Includes a multimode HUD that switches between medical and security modes. Finished in gold."
	icon_state = "sunhudcap"
	item_state = "sunhudcap"
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY  = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/multimode/centcom
	name = "Centcom multi-mod HUD aviators"
	icon_state = "aviators"
