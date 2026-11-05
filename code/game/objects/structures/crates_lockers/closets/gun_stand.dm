// MARK: Gun stand
/obj/structure/closet/gun_stand
	name = "gun stand"
	desc = "A stand for storing a specific weapon. You should not be seeing this description."
	anchored = TRUE
	anchorable = FALSE
	density = FALSE
	no_overlays = TRUE
	armor = list(MELEE = 50, BULLET = 20, LASER = 0, ENERGY = 100, BOMB = 10, FIRE = 90, ACID = 50)
	var/obj/item/stored_item
	var/obj/item/stored_item_type
	opened = TRUE

/obj/structure/closet/gun_stand/Destroy()
	if(stored_item)
		if(!obj_integrity)
			stored_item.forceMove(loc)
			stored_item = null
		else
			QDEL_NULL(stored_item)
	return ..()

/obj/structure/closet/gun_stand/populate_contents()
	if(stored_item_type)
		stored_item = new stored_item_type(src)
	update_icon(UPDATE_ICON_STATE)

/obj/structure/closet/gun_stand/attackby(obj/item/attack_item, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(attack_item, stored_item_type))
		if(!user.drop_transfer_item_to_loc(attack_item, src))
			return ..()
		balloon_alert(user, "закреплено")
		stored_item = attack_item
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/closet/gun_stand/attack_hand(mob/user)
	if(!stored_item)
		return

	add_fingerprint(user)
	stored_item.forceMove_turf()
	user.put_in_hands(stored_item, ignore_anim = FALSE)
	balloon_alert(user, "извлечено")
	stored_item = null
	update_icon(UPDATE_ICON_STATE)

/obj/structure/closet/gun_stand/blob_act(obj/structure/blob/B)
	if(stored_item)
		stored_item.forceMove(loc)
	qdel(src)

/obj/structure/closet/gun_stand/update_icon_state()
	if(stored_item)
		icon_state = "[initial(icon_state)]_full"
	else
		icon_state = initial(icon_state)


//MARK: Finish rod stand
/obj/structure/closet/gun_stand/fishingrod
	name = "fishing cabinet"
	desc = "There is a small label that reads \"Fo* Em**gen*y u*e *nly\". All the other text is scratched out and replaced with various fish weights."
	icon_state = "fishingrod"
	stored_item_type = /obj/item/twohanded/fishing_rod

/obj/structure/closet/gun_stand/sechammer
	name = "tactical sledgehammer cabinet"
	desc = "A stand for a tactical sledgehammer. Its inscription reads: For special occasions."
	icon_state = "sechammer"
	stored_item_type = /obj/item/twohanded/sechammer

/obj/structure/closet/gun_stand/cargo_defender
	name = "cargo defender shotgun cabinet"
	desc = "A stand for the Cargo Defender shotgun."
	icon_state = "cargo_defender"
	stored_item_type = /obj/item/gun/projectile/shotgun/winchester/cargo
