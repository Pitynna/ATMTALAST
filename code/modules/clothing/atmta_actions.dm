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

/obj/item/clothing/neck/inner_voice_tie
	var/whisper_timer
	var/static/list/whispers = list(
		"Братан, ссора закрыта. Дело передано в отдел плясок.",
		"Ты молодец. Поставь стакан. С такими уликами сначала фотографируются.",
		"Кончай хандрить. У нас ещё ни одна плохая идея не оформлена официально.",
		"Нам пора сваливать, братан. Для алиби прихвати закуску.",
		"Братан! Срочно! Я забыл зачем.",
		"Приём, это узел связи. Тот, который у тебя на шее.",
		"Если бумажки так важны, пусть они сами себя допросят.",
		"Он говорит «улика». А я вижу чудесный повод остаться до закрытия.",
		"В правилах одни буквы. А у тебя, между прочим, характер.",
		"Давай, братан. Подпись потом придумаем.",
	)

/obj/item/clothing/neck/inner_voice_tie/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_NECK && !whisper_timer)
		schedule_whisper()

/obj/item/clothing/neck/inner_voice_tie/dropped(mob/user, slot, silent = FALSE)
	stop_whispers()
	return ..()

/obj/item/clothing/neck/inner_voice_tie/Destroy()
	stop_whispers()
	return ..()

/obj/item/clothing/neck/inner_voice_tie/proc/schedule_whisper()
	whisper_timer = addtimer(CALLBACK(src, PROC_REF(whisper)), rand(1, 5) MINUTES, TIMER_STOPPABLE)

/obj/item/clothing/neck/inner_voice_tie/proc/stop_whispers()
	if(whisper_timer)
		deltimer(whisper_timer)
		whisper_timer = null

/obj/item/clothing/neck/inner_voice_tie/proc/whisper()
	whisper_timer = null
	var/mob/living/wearer = loc
	if(!isliving(wearer) || wearer.get_item_by_slot(ITEM_SLOT_NECK) != src)
		return
	if(wearer.client && wearer.stat != DEAD)
		to_chat(wearer, span_notice("<i>Галстук: [pick(whispers)]</i>"))
	schedule_whisper()

/datum/action/item_action/atmta_druid_speak
	name = "Druid: speak"

/datum/action/item_action/atmta_druid_select
	name = "Druid: choose phrase"

/obj/item/clothing/suit/apron/greenhouse_druid
	actions_types = list(/datum/action/item_action/atmta_druid_speak, /datum/action/item_action/atmta_druid_select)
	COOLDOWN_DECLARE(voice_cooldown)
	var/selected_phrase = "Меня будить?"
	var/static/list/voice_lines = list(
		"Меня будить?" = 'sound/voice/atmta_druid/why_wake_me.ogg',
		"Когда начинать?" = 'sound/voice/atmta_druid/when_to_start.ogg',
		"Конечно." = 'sound/voice/atmta_druid/of_course.ogg',
		"У нас мало времени." = 'sound/voice/atmta_druid/little_time.ogg',
		"Ну что?.." = 'sound/voice/atmta_druid/well_then.ogg',
		"А я без сна…" = 'sound/voice/atmta_druid/without_sleep.ogg',
		"Зашибу!" = 'sound/voice/atmta_druid/smash.ogg',
		"И тут я…" = 'sound/voice/atmta_druid/and_then_i.ogg',
		"Лучше бы дал поесть…" = 'sound/voice/atmta_druid/let_me_eat.ogg',
		"Не валяй дурака!" = 'sound/voice/atmta_druid/stop_fooling_around.ogg',
	)

/obj/item/clothing/suit/apron/greenhouse_druid/item_action_slot_check(slot, mob/user, datum/action/action)
	return slot == ITEM_SLOT_CLOTH_OUTER

/obj/item/clothing/suit/apron/greenhouse_druid/ui_action_click(mob/living/user, datum/action/action, leftclick)
	if(user.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER) != src || user.incapacitated())
		return
	if(istype(action, /datum/action/item_action/atmta_druid_select))
		var/choice = tgui_input_list(user, "Choose a druid voice line.", name, voice_lines)
		if(choice && user.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER) == src && !user.incapacitated())
			selected_phrase = choice
		return
	if(!COOLDOWN_FINISHED(src, voice_cooldown))
		return
	COOLDOWN_START(src, voice_cooldown, 5 SECONDS)
	playsound(src, voice_lines[selected_phrase], 60, FALSE)
	user.visible_message(span_boldwarning("[user] growls: [selected_phrase]"))
