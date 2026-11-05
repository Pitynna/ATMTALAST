/obj/item/grenade/frag
	name = "frag grenade"
	desc = "A grenade with a specially designed casing that will launch lethal fragments in all directions upon detonation. Fire in the hole!"
	icon_state = "frag"
	origin_tech = "materials=3;magnets=4"
	det_time = 3 SECONDS
	shrapnel_type = /obj/projectile/shrapnel/grenade
	shrapnel_radius = 4
	var/range = 5

/obj/item/grenade/frag/prime()
	. = ..()
	update_mob()
	explosion(loc, devastation_range = 0, heavy_impact_range = 1, light_impact_range = range, breach = FALSE, cause = src)
	qdel(src)

/obj/item/grenade/frag/contact
	name = "contact frag grenade"
	desc = "An impact fragmentation grenade. Detonates on its timer or upon landing, producing a blast wave and numerous fragments."
	det_time = 5 SECONDS

/obj/item/grenade/frag/contact/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!active || !throwingdatum || QDELETED(src))
		return
	var/turf/impact_turf = get_turf(hit_atom)
	if(!impact_turf || is_space_or_openspace(impact_turf))
		return
	prime()

/obj/item/grenade/frag/contact/examine(mob/user)
	. = ..()
	. += span_notice("Таймер установлен на <b>[det_time/10]</b> секунд[DECL_U_Y_0(det_time/10)].")

/obj/item/grenade/frag/contact/screwdriver_act(mob/living/user, obj/item/I)
	return
