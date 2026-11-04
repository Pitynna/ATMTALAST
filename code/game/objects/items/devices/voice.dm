/obj/item/voice_changer
	name = "voice changer"
	desc = "A voice mimicking module."
	icon = 'icons/obj/device.dmi'
	icon_state = "voice_changer_off"

	actions_types = list(/datum/action/item_action/voice_changer/toggle, /datum/action/item_action/voice_changer/voice)

	var/obj/item/parent
	/// Флаг для Ниндзя и других подобных случаев, когда мы применяем войс ченджер, но не даём кнопок его контролировать на прямую
	var/inform_about_toggle = TRUE

	var/voice
	var/active

/obj/item/voice_changer/Initialize(mapload)
	. = ..()

	if(isitem(loc))
		parent = loc
		if(actions)
			LAZYOR(parent.actions, actions)

/obj/item/voice_changer/Destroy()
	if(isitem(parent))
		LAZYREMOVE(parent.actions, actions)
	parent = null
	return ..()

/obj/item/voice_changer/attack_self(mob/user)
	active = !active
	update_icon(UPDATE_ICON_STATE)
	if(inform_about_toggle)
		user.balloon_alert(user, "[active ? "включено" : "выключено"]")

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/voice_changer/update_icon_state()
	icon_state = "voice_changer_[active ? "on" : "off"]"

/obj/item/voice_changer/proc/set_voice(mob/user)
	var/mimic_voice

	var/mimic_option = tgui_alert(user, "What voice do you want to mimic?", "Set Voice Changer", list("Real Voice", "Custom Voice", "Cancel"))
	switch(mimic_option)
		if("Real Voice")
			var/mob/living/carbon/human/human = tgui_input_list(user, "Select a voice to copy from.", "Set Voice Changer", GLOB.human_list)
			if(!human)
				return

			mimic_voice = human.real_name
		if("Custom Voice")
			mimic_voice = reject_bad_name(tgui_input_text(user, "Enter a name to mimic.", "Set Voice Changer", null, max_length = MAX_NAME_LEN), TRUE)
			if(!mimic_voice)
				to_chat(user, span_warning("Invalid name, try again."))
				return
		if("Cancel")
			return

	voice = mimic_voice
	if(inform_about_toggle)
		to_chat(user, span_notice("You are now mimicking <b>[voice]</b>."))

//Войс ченджер является частью способности хамелиона и должен быть недосягаем без неё, хоть и хранится в маске
/obj/item/voice_changer/voice_modulator
	name = "voice modulator"
	desc = "A voice scrambling module."
	voice = UNKNOWN_NAME_RUS
	actions_types = list(/datum/action/item_action/voice_changer/toggle)

/obj/item/voice_changer/ghostface
	name = "Ghostface emmission"
	desc = "You shouldn't be seeing this!"
	voice = "Ghostface"
	active = TRUE
	actions_types = null
	inform_about_toggle = FALSE
