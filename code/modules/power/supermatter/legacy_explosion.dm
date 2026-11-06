// The only supermatter failure mode used by ATMTA.
/obj/machinery/power/supermatter_crystal/proc/legacy_explode()
	investigate_log("has exploded.", INVESTIGATE_ENGINE)
	explosion(get_turf(src), explosion_power, explosion_power * 2, explosion_power * 3, explosion_power * 4)
	qdel(src)
