/obj/item/card/id/golem
	name = "Free Golem ID"
	desc = "A card used to claim mining points and buy gear. Use it to mark it as yours."
	icon_state = "research"
	access = list(ACCESS_FREE_GOLEMS, ACCESS_ROBOTICS, ACCESS_CLOWN, ACCESS_MIME) //access to robots/mechs

/obj/item/card/id/golem/attack_self(mob/user as mob)
	if(!registered && ishuman(user))
		registered_name = user.real_name
		SetOwnerInfo(user)
		assignment = "Свободный голем"
		RebuildHTML()
		update_label()
		registered = TRUE
		balloon_alert(user, "зарегестрировано на вас")
	else
		..()
