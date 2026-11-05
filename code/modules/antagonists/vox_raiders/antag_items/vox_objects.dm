/obj/item/clothing/glasses/meson/cyber/vox
	name = "meson vox eye"
	desc = "A meson cybernetic eye with an eye-socket mounting system. Completely replaces a functioning eye or fills an empty socket. WARNING: Can only be removed surgically. Its size prevents wearing other eyewear, as it replaces glasses."

/obj/item/clothing/glasses/meson/cyber/vox/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_EYES)
		ADD_TRAIT(src, TRAIT_NODROP, UNIQUE_TRAIT_SOURCE(src))
	else
		REMOVE_TRAIT(src, TRAIT_NODROP, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/glasses/thermal/cyber/vox
	name = "thermal vox eye"
	desc = "A thermal cybernetic eye with an eye-socket mounting system. Completely replaces a functioning eye or fills an empty socket. WARNING: Can only be removed surgically. Its size prevents wearing other eyewear, as it replaces glasses."

/obj/item/clothing/glasses/thermal/cyber/vox/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_EYES)
		ADD_TRAIT(src, TRAIT_NODROP, UNIQUE_TRAIT_SOURCE(src))
	else
		REMOVE_TRAIT(src, TRAIT_NODROP, UNIQUE_TRAIT_SOURCE(src))

