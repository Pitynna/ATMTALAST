// Legacy random anomaly event; research-tier anomalies are retired.
/datum/event/anomaly
	name = "Аномалия"
	announceWhen = 1
	var/obj/effect/old_anomaly/anomaly_path
	var/turf/target_turf

/datum/event/anomaly/setup()
	impact_area = findEventArea()
	if(!impact_area)
		kill()
		return
	var/list/candidates = get_area_turfs(impact_area)
	while(length(candidates))
		var/turf/candidate = pick_n_take(candidates)
		if(!candidate.is_blocked_turf(exclude_mobs = TRUE))
			target_turf = candidate
			break
	if(!target_turf)
		kill()
		return
	anomaly_path = pick(/obj/effect/old_anomaly/gravitational, /obj/effect/old_anomaly/energetic, /obj/effect/old_anomaly/bluespace, /obj/effect/old_anomaly/atmospheric)

/datum/event/anomaly/announce(false_alarm)
	var/area/target = false_alarm ? findEventArea() : impact_area
	if(target)
		GLOB.minor_announcement.announce(message = "Обнаружена пространственная аномалия. Предполагаемая локация: [target.name]", new_title = ANNOUNCE_ANOMALY_RU)

/datum/event/anomaly/start()
	if(target_turf && anomaly_path)
		announce_to_ghosts(new anomaly_path(target_turf))
