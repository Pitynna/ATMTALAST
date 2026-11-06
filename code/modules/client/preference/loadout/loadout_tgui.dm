GLOBAL_LIST_EMPTY(gear_tgui_info)

/datum/ui_module/loadout
	name = "Выбор снаряжения"

/datum/ui_module/loadout/ui_state(mob/user)
	return GLOB.always_state

/datum/ui_module/loadout/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Loadout", name)
		ui.set_autoupdate(FALSE)
		ui.open()
		ensure_preview(user, ui.window)

/datum/ui_module/loadout/ui_data(mob/user)
	var/list/data = list()
	data["gear_slots"] = user?.client?.prefs.build_loadout()
	data["selected_gears"] = user?.client?.prefs?.tgui_loadout_gear
	data["character_preview_view"] = preview_view?.assigned_map
	data["try_on"] = try_on
	data["show_job"] = preview_show_job
	return data

/datum/ui_module/loadout/ui_static_data(mob/user)
	var/list/data = list()
	data["gears"] = GLOB.gear_tgui_info
	data["max_gear_slots"] = user?.client?.prefs?.max_gear_slots
	data["user_tier"] = user?.client?.donator_level
	return data

/datum/ui_module/loadout/ui_act(action, list/params)
	if(..())
		return
	. = TRUE

	var/mob/user = usr
	var/datum/preferences/prefs = user.client.prefs
	. = handle_loadout_action(action, params, user, prefs)
	if(.)
		rebuild_preview(user)

/datum/ui_module/loadout/proc/handle_loadout_action(action, list/params, mob/user, datum/preferences/prefs)
	switch(action)
		if("try_gear")
			var/index = params["gear"]
			if(!GLOB.gear_datums[index])
				return FALSE
			if(index in try_on)
				try_on -= index
			else
				try_on += index
			return TRUE

		if("clear_try_on")
			try_on.Cut()
			return TRUE

		if("toggle_job")
			preview_show_job = !preview_show_job
			return TRUE

		if("rotate")
			preview_rotate(params["clockwise"])
			return FALSE // кукла уже обновлена, пересборка не нужна

		if("toggle_gear")
			var/datum/gear/gear = GLOB.gear_datums[params["gear"]]
			if(gear && ("[gear.index_name]" in prefs.loadout_gear))
				prefs.loadout_gear -= "[gear.index_name]"
				return TRUE

			if(gear.donator_tier && user.client.donator_level < gear.donator_tier)
				to_chat(user, span_warning("Недоступно на вашем текущем уровне пожертвований!"))
				return FALSE

			user.client.prefs.build_loadout(gear)
			return TRUE

		if("set_tweak")
			if(!(params["gear"] in prefs.loadout_gear))
				return FALSE

			var/datum/gear/gear = GLOB.gear_datums[params["gear"]]
			var/datum/gear_tweak/tweak = locate(text2path(params["tweak"])) in gear.gear_tweaks
			prefs.set_tweak_metadata(gear, tweak, tweak.get_metadata(user, prefs.get_tweak_metadata(gear, tweak)))
			return TRUE

		if("clear_loadout")
			prefs.loadout_gear.Cut()
			return TRUE
