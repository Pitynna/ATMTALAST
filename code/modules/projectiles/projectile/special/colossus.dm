/obj/projectile/colossus
	name = "death bolt"
	icon_state= "chronobolt"
	damage = 25
	armour_penetration = 100
	speed = 3.5

/obj/projectile/colossus/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isturf(target) || isobj(target))
		target.ex_act(EXPLODE_HEAVY)
