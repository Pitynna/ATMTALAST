// Живое превью персонажа в окне выбора снаряжения.
// Кукла собирается из настроек персонажа, при желании одевается в форму
// профессии с высоким приоритетом, затем на неё надевается выбранный
// лодаут и вещи на примерке (они вытесняют вещи того же слота).

/datum/ui_module/loadout
	/// Карта с куклой, показываемая в окне.
	var/atom/movable/screen/map_view/character_preview/preview_view
	/// index_name вещей, которые сейчас примеряются (не сохраняются).
	var/list/try_on = list()
	/// Показывать ли форму профессии под лодаутом.
	var/preview_show_job = TRUE
	/// Направление взгляда куклы.
	var/preview_dir = SOUTH
	/// Серая плитка пола под куклой, ограничивает карту одним тайлом.
	var/atom/movable/screen/preview_floor

/datum/ui_module/loadout/Destroy(force)
	clear_preview()
	try_on.Cut()
	return ..()

/datum/ui_module/loadout/ui_close(mob/user)
	. = ..()
	try_on.Cut()
	clear_preview(user?.client)

/// Убирает карту куклы с клиента и удаляет её.
/datum/ui_module/loadout/proc/clear_preview(client/viewer)
	if(QDELETED(preview_view))
		preview_view = null
		return
	viewer?.clear_map(preview_view.assigned_map)
	QDEL_NULL(preview_floor)
	QDEL_NULL(preview_view)

/datum/ui_module/loadout/proc/ensure_preview(mob/user, datum/tgui_window/window = null)
	if(QDELETED(preview_view))
		preview_view = new
		preview_view.generate_view("loadout_preview_[UID()]")
		rebuild_preview(user)
	preview_view.update_body()
	// Регистрируем только сам объект, без popup plane-группы из display_to():
	// её плашки освещения стоят в CENTER и растягивают рамку карты, а кукла
	// в null space под освещением получается чёрной точкой. Без плейн-мастеров
	// карта показывает один тайл куклы на весь элемент.
	if(QDELETED(preview_floor))
		preview_floor = new
		preview_floor.icon = 'icons/turf/floors.dmi'
		preview_floor.icon_state = "floor"
		preview_floor.plane = FLOOR_PLANE
		preview_floor.layer = TURF_LAYER
		preview_floor.del_on_map_removal = FALSE
		preview_floor.screen_loc = "[preview_view.assigned_map]:1,1"
		preview_floor.assigned_map = preview_view.assigned_map
	user?.client?.register_map_obj(preview_floor)
	user?.client?.register_map_obj(preview_view)
	return preview_view.assigned_map

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
	if(QDELETED(preview_view))
		return
	var/datum/preferences/prefs = user?.client?.prefs
	QDEL_NULL(preview_view.dummy)
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
	preview_view.dummy = dummy
	preview_view.preview_direction = preview_dir
	preview_view.update_body()

/datum/ui_module/loadout/proc/preview_rotate(clockwise)
	var/static/list/order = list(SOUTH, WEST, NORTH, EAST)
	var/pos = order.Find(preview_dir) || 1
	pos = clockwise ? (pos % 4) + 1 : ((pos + 2) % 4) + 1
	preview_dir = order[pos]
	if(!QDELETED(preview_view))
		preview_view.preview_direction = preview_dir
		preview_view.update_body()
