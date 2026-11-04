/obj/projectile/bullet/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 33
	damage_type = TOX
	weaken = 1 SECONDS

/obj/projectile/bullet/neurotoxin/prehit(atom/target)
	if(isalien(target))
		weaken = 0
		nodamage = TRUE
	if(isobj(target) || issilicon(target) || ismachineperson(target))
		damage_type = BURN
	return ..()
