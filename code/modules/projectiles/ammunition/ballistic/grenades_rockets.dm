// MARK: 84mm HE
/obj/item/ammo_casing/caseless/rocket
	ammo_marking = "84 mm HE"
	desc = "An 84mm High Explosive rocket. Fire at people and pray."
	caliber = CALIBER_84MM
	w_class = WEIGHT_CLASS_NORMAL //thats the rocket!
	icon_state = "84mm-he"
	projectile_type = /obj/projectile/bullet/a84mm_he
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'	// better than default casing but not ideal

/obj/item/ammo_casing/caseless/rocket/hedp
	ammo_marking = "84 mm HEDP"
	desc = "An 84mm High Explosive Dual Purpose rocket. Pointy end toward mechs and unarmed civilians."
	icon_state = "84mm-hedp"
	projectile_type = /obj/projectile/bullet/a84mm_hedp

// MARK: 70mm HE
/obj/item/ammo_casing/caseless/rocket/a70mm_he
	ammo_marking = "70 mm HE"
	desc = "A small-caliber high-explosive fragmentation rocket intended for use against infantry."
	caliber = CALIBER_ROCKET_70MM
	icon_state = "70mm-he"
	projectile_type = /obj/projectile/bullet/a70mm_he

// MARK: 40mm HE
/obj/item/ammo_casing/a40mm
	ammo_marking = "40 mm HE"
	icon_state = "40mmHE"
	materials = list(MAT_METAL = 8000)
	caliber = CALIBER_40MM
	projectile_type = /obj/projectile/bullet/a40mm
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/a40mm/update_desc(updates = ALL)
	. = ..()
	desc = "A loaded [ammo_marking] round for a grenade launcher. [extra_info]"

// MARK: 40mm - GL-06
/obj/item/ammo_casing/a40mm/secgl
	ammo_marking = "40 mm"
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "secgl_solid"
	item_state = "secgl_solid"
	drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'

/obj/item/ammo_casing/a40mm/secgl/solid
	ammo_marking = "40 mm Rubber"
	extra_info = "A solid rubber grenade for nonlethal takedowns."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/solid

/obj/item/ammo_casing/a40mm/secgl/flash
	ammo_marking = "40 mm Flashbang"
	extra_info = "A flashbang grenade for disorienting opponents."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/flash
	icon_state = "secgl_flash"
	item_state = "secgl_flash"

/obj/item/ammo_casing/a40mm/secgl/gas
	ammo_marking = "40 mm Tear Gas"
	extra_info = "Tear gas for nonlethal takedowns of targets without respiratory protection."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/gas
	icon_state = "secgl_gas"
	item_state = "secgl_gas"

/obj/item/ammo_casing/a40mm/secgl/barricade
	ammo_marking = "40 mm Barricade"
	extra_info = "A portable barricade for creating cover in open terrain."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/barricade
	icon_state = "secgl_barricade"
	item_state = "secgl_barricade"

/obj/item/ammo_casing/a40mm/secgl/exp
	ammo_marking = "40 mm Frag"
	extra_info = "A fragmentation grenade for lethal takedowns."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/exp
	icon_state = "secgl_exp"
	item_state = "secgl_exp"

/obj/item/ammo_casing/a40mm/secgl/paint
	ammo_marking = "40 mm \"Paint\""
	extra_info = "A paint grenade that marks the target on impact for tracking."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/paint
	icon_state = "secgl_paint"
	item_state = "secgl_paint"

// MARK: 40mm - Bombarda
/obj/item/ammo_casing/a40mm/improvised
	ammo_marking = "40 mm improvised"
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "exp_shell"
	item_state = "exp_shell"
	drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'

/obj/item/ammo_casing/a40mm/improvised/update_desc(updates = ALL)
	. = ..()
	desc = "An improvised [ammo_marking] grenade for a grenade launcher. Extremely unstable. [extra_info]"

/obj/item/ammo_casing/a40mm/improvised/exp_shell
	ammo_marking = "40 mm improvised \"Explosive\""
	extra_info = "Explodes on impact."
	projectile_type = /obj/projectile/grenade/improvised/exp_shot

/obj/item/ammo_casing/a40mm/improvised/flame_shell
	ammo_marking = "40 mm improvised \"Fire\""
	extra_info = "Ignites on impact."
	projectile_type = /obj/projectile/grenade/improvised/flame_shot
	icon_state = "flame_shell"
	item_state = "flame_shell"

/obj/item/ammo_casing/a40mm/improvised/smoke_shell
	ammo_marking = "40 mm improvised \"Smoke\""
	extra_info = "Creates a cloud of smoke on impact."
	projectile_type = /obj/projectile/grenade/improvised/smoke_shot
	icon_state = "smoke_shell"
	item_state = "smoke_shell"
