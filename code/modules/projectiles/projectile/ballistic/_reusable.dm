/obj/projectile/bullet/reusable
	name = "reusable bullet"
	desc = "How do you even reuse a bullet?"
	var/ammo_type = /obj/item/ammo_casing/caseless/
	var/dropped = 0
	impact_effect_type = null
	ricochets_max = 0

/obj/projectile/bullet/reusable/on_hit(atom/target, blocked = 0)
	. = ..()
	handle_drop()

/obj/projectile/bullet/reusable/on_range()
	handle_drop()
	..()

/obj/projectile/bullet/reusable/proc/handle_drop()
	if(!dropped)
		new ammo_type(loc)
		dropped = 1
