// Живое превью персонажа в окне выбора снаряжения.
// Кукла собирается из настроек персонажа, при желании одевается в форму
// профессии с высоким приоритетом, затем на неё надевается выбранный
// лодаут и вещи на примерке (они вытесняют вещи того же слота).
// В окно уходит плоская картинка куклы (base64), без карты ByondUi:
// карта в лобби растягивалась и показывала куклу чёрной точкой.

/datum/ui_module/loadout
	/// Собранная кукла (в null space), из неё рисуются картинки.
	var/mob/living/carbon/human/dummy/preview_dummy
	/// Картинка куклы для окна, base64 PNG.
	var/preview_image
	/// index_name вещей, которые сейчас примеряются (не сохраняются).
	var/list/try_on = list()
	/// Показывать ли форму профессии под лодаутом.
	var/preview_show_job = TRUE
	/// Направление взгляда куклы.
	var/preview_dir = SOUTH

/datum/ui_module/loadout/Destroy(force)
	clear_preview()
	try_on.Cut()
	return ..()

/datum/ui_module/loadout/ui_close(mob/user)
	. = ..()
	try_on.Cut()
	clear_preview()

/datum/ui_module/loadout/proc/clear_preview()
	QDEL_NULL(preview_dummy)
	preview_image = null

/// Возвращает картинку куклы, собирая её при первом обращении.
/datum/ui_module/loadout/proc/ensure_preview(mob/user)
	if(QDELETED(preview_dummy))
		rebuild_preview(user)
	return preview_image

/datum/ui_module/loadout/proc/render_preview()
	if(QDELETED(preview_dummy))
		preview_image = null
		return
	preview_image = icon2base64(getFlatIcon(preview_dummy, preview_dir, no_anim = TRUE))

/// Профессия, выставленная игроком на высокий приоритет.
/datum/preferences/proc/get_high_priority_job()
	for(var/datum/job/job as anything in SSjobs.occupations)
		if(GetJobDepartment(job, 1) & job.flag)
			return job

/datum/ui_module/loadout/proc/preview_equip_gear(mob/living/carbon/human/dummy, datum/preferences/prefs, datum/gear/gear, force_hands = FALSE)
	if(!gear || gear.implantable)
		return
	var/list/metadata = prefs.loadout_gear[gear.index_name] || list()
	if(!gear.slot)
		if(!force_hands)
			return
		var/obj/item/hand_item = gear.spawn_item(null, metadata)
		if(istype(hand_item) && !dummy.put_in_hands(hand_item))
			qdel(hand_item)
		return
	var/obj/item/item = gear.spawn_item(null, metadata)
	if(!istype(item))
		qdel(item)
		return
	var/obj/item/old_item = dummy.get_item_by_slot(gear.slot)
	if(old_item)
		qdel(old_item)
	dummy.equip_to_slot_or_del(item, gear.slot)

/datum/ui_module/loadout/proc/rebuild_preview(mob/user)
	var/datum/preferences/prefs = user?.client?.prefs
	QDEL_NULL(preview_dummy)
	preview_image = null
	if(!prefs)
		return

	var/mob/living/carbon/human/dummy/dummy = new
	// copy_to подставляет случайное имя прямо в настройки; превью не должно их менять.
	var/saved_name = prefs.real_name
	prefs.copy_to(dummy)
	prefs.real_name = saved_name

	if(preview_show_job)
		var/datum/job/job = prefs.get_high_priority_job()
		job?.equip(dummy, visualsOnly = TRUE, announce = FALSE)

	for(var/index in prefs.loadout_gear)
		if(index in try_on)
			continue
		preview_equip_gear(dummy, prefs, GLOB.gear_datums[index])
	for(var/index in try_on)
		preview_equip_gear(dummy, prefs, GLOB.gear_datums[index], force_hands = TRUE)

	dummy.move_to_null_space()
	preview_dummy = dummy
	render_preview()

/datum/ui_module/loadout/proc/preview_rotate(clockwise)
	var/static/list/order = list(SOUTH, WEST, NORTH, EAST)
	var/pos = order.Find(preview_dir) || 1
	pos = clockwise ? (pos % 4) + 1 : ((pos + 2) % 4) + 1
	preview_dir = order[pos]
	render_preview()
