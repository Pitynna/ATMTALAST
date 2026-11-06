/datum/action/item_action/atmta_dornan_speak
	name = "Dornan: speak"

/datum/action/item_action/atmta_dornan_select
	name = "Dornan: choose phrase"

/obj/item/clothing/head/atmta/dornan
	actions_types = list(/datum/action/item_action/atmta_dornan_speak, /datum/action/item_action/atmta_dornan_select)
	COOLDOWN_DECLARE(voice_cooldown)
	var/selected_phrase = "Idiot!"
	var/static/list/voice_lines = list(
		"Idiot!" = 'sound/voice/atmta_dornan/idiot0.ogg',
		"Idiot! (alternate)" = 'sound/voice/atmta_dornan/idiot1.ogg',
		"You are out of uniform!" = 'sound/voice/atmta_dornan/idiot2.ogg',
		"Your uniform is your responsibility!" = 'sound/voice/atmta_dornan/idiot3.ogg',
		"Where is your uniform?" = 'sound/voice/atmta_dornan/idiot4.ogg',
		"Who are you, private?" = 'sound/voice/atmta_dornan/idiot5.ogg',
		"You have lost your equipment!" = 'sound/voice/atmta_dornan/idiot6.ogg',
		"That equipment is expensive!" = 'sound/voice/atmta_dornan/idiot7.ogg',
		"You owe us 510 years!" = 'sound/voice/atmta_dornan/idiot8.ogg',
		"What is your business here?" = 'sound/voice/atmta_dornan/idiot9.ogg',
		"Report to the armory!" = 'sound/voice/atmta_dornan/idiot10.ogg',
		"You are out of line!" = 'sound/voice/atmta_dornan/idiot11.ogg',
		"You are not a hero!" = 'sound/voice/atmta_dornan/idiot12.ogg',
		"You are a civilian!" = 'sound/voice/atmta_dornan/idiot13.ogg',
		"Who is this?" = 'sound/voice/atmta_dornan/idiot14.ogg',
		"Get back to your post!" = 'sound/voice/atmta_dornan/idiot15.ogg',
		"That is classified!" = 'sound/voice/atmta_dornan/idiot16.ogg',
		"Dismissed!" = 'sound/voice/atmta_dornan/idiot17.ogg',
	)

/obj/item/clothing/head/atmta/dornan/ui_action_click(mob/user, datum/action/action, leftclick)
	if(istype(action, /datum/action/item_action/atmta_dornan_select))
		var/choice = tgui_input_list(user, "Choose a helmet voice line.", name, voice_lines)
		if(choice && loc == user && !user.incapacitated())
			selected_phrase = choice
		return
	return attack_self(user)

/obj/item/clothing/head/atmta/dornan/attack_self(mob/living/user)
	if(loc != user || user.incapacitated() || !COOLDOWN_FINISHED(src, voice_cooldown))
		return
	COOLDOWN_START(src, voice_cooldown, 5 SECONDS)
	playsound(src, voice_lines[selected_phrase], 60, FALSE)
	user.visible_message(span_boldwarning("[user]'s helmet bellows: [selected_phrase]"))

/datum/action/item_action/atmta_spiral_power
	name = "ROW ROW"

/obj/item/bedsheet/kaminacape
	name = "Sky-piercer cape"
	desc = "The symbol of man's will."
	icon = 'icons/obj/clothing/atmta/items.dmi'
	icon_state = "kaminacape"
	item_state = "kaminacape"
	sprite_sheets = null
	onmob_sheets = list(ITEM_SLOT_NECK_STRING = 'icons/mob/clothing/atmta/back.dmi')
	actions_types = list(/datum/action/item_action/atmta_spiral_power)
	COOLDOWN_DECLARE(spiral_cooldown)
	var/mob/living/aura_owner
	var/mutable_appearance/spiral_aura

/obj/item/bedsheet/kaminacape/ui_action_click(mob/living/user, datum/action/action, leftclick)
	if(loc != user || user.incapacitated() || !COOLDOWN_FINISHED(src, spiral_cooldown))
		return
	COOLDOWN_START(src, spiral_cooldown, 5 MINUTES)
	clear_spiral()
	aura_owner = user
	spiral_aura = mutable_appearance('icons/mob/clothing/atmta/aura.dmi', "spiral")
	user.add_overlay(spiral_aura)
	user.visible_message(span_notice("[user] glows with a strong, manly aura!"))
	addtimer(CALLBACK(src, PROC_REF(clear_spiral)), 20 SECONDS)

/obj/item/bedsheet/kaminacape/proc/clear_spiral()
	if(aura_owner && spiral_aura)
		aura_owner.cut_overlay(spiral_aura)
	aura_owner = null
	spiral_aura = null

/obj/item/bedsheet/kaminacape/dropped(mob/user, slot, silent = FALSE)
	clear_spiral()
	return ..()

/obj/item/bedsheet/kaminacape/Destroy()
	clear_spiral()
	return ..()
