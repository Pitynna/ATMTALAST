/obj/projectile/bullet/reusable/arrow //only for wooden bow!
	name = "arrow"
	icon_state = "arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	range = 10
	damage = 25
	miss_sound = SFX_ARROW_MISS
	var/faction_bonus_damage = 13
	var/nemesis_factions = MINING_FACTIONS
	var/nemesis_faction = FALSE

/obj/projectile/bullet/reusable/arrow/prehit(atom/target)
	var/mob/living/H = target

	if(!ismob(H) || !LAZYLEN(nemesis_factions))
		return

	for(var/faction in H.faction)
		if(faction in nemesis_factions)
			nemesis_faction = TRUE
			damage += faction_bonus_damage
			break

	return ..()

/obj/projectile/bullet/reusable/arrow/apply_effect_on_hit(mob/living/target, blocked, hit_zone)
	var/obj/item/arrow_type = ammo_type
	if(!blocked && !HAS_TRAIT(target, TRAIT_EMBEDIMMUNE) && prob(arrow_type.embed_chance))
		target.embed_item_inside(new arrow_type(loc), hit_zone)
		dropped = TRUE
	return..()

/obj/projectile/bullet/reusable/arrow/modern
	name = "modern arrow"
	icon_state = "arrow_modern"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/modern
	range = 15
	damage = 30
	armour_penetration = 10

/obj/projectile/bullet/reusable/arrow/homemade
	name = "homemade arrow"
	icon_state = "arrow_homemade"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/homemade
	range = 8
