/obj/item/pda_case
	name = "silicone PDA case"
	desc = "A transparent silicone case."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda_case"
	/// New icon state for the PDA
	var/new_icon_state = "pda-clear"
	/// New item state for the PDA
	var/new_item_state = "pda-clear"
	/// New description for the PDA
	var/new_desc = ""
	/// New sound for the received messages, in a format of associative list: sound name -> sound file
	var/list/new_ttone

/obj/item/pda_case/Destroy()
	new_ttone?.Cut()
	return ..()

/obj/item/pda/proc/apply_pda_case(obj/item/pda_case/new_case)
	if(!istype(new_case))
		CRASH("Wrong item passed into apply_pda_case().")
	if(new_case.new_ttone)
		ttone_sound |= new_case.new_ttone
		ttone = new_case.new_ttone[1]
	current_case = new_case
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)

/obj/item/pda/proc/remove_pda_case()
	if(!current_case)
		return
	if(current_case.new_ttone)
		ttone_sound -= current_case.new_ttone
		if(ttone == current_case.new_ttone[1])
			ttone = initial(ttone)
	QDEL_NULL(current_case)
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)

/obj/item/pda_case/beer
	name = "PDA case \"BEER\""
	desc = "A luxurious case shaped like a beer mug. Unlocks a unique incoming message sound: beer."
	icon_state = "pda_case_beer"
	new_desc = "A profound quote on the back of the case reads: \"All anyone on the station talks about is beer...\" Using the PDA as a mug is still not recommended."
	new_icon_state = "pda-beer"
	new_item_state = "pda-beer"
	new_ttone = list("beer" = 'sound/items/PDA/beer.ogg')

/obj/item/pda_case/rat
	name = "PDA case \"RAT\""
	desc = "A case shaped like a grey rat. Unlocks a unique incoming message sound: squeak."
	icon_state = "pda_case_rat"
	new_desc = "An inscription scratched into the back of the case reads: \"Someone on this station is definitely a rat...\""
	new_icon_state = "pda-rat"
	new_item_state = "pda-rat"
	new_ttone = list("squeak" = 'sound/items/PDA/mouse_squeak.ogg')


/obj/item/pda_case/swaga
	name = "PDA case \"SWAGA\""
	desc = "A formal black case with gold buttons. Unlocks a unique incoming message sound: levelup."
	icon_state = "pda_case_swaga"
	new_desc = "A profound quote on the back of the case reads: \"True robusts move silently, like a greytider through maintenance.\" Biting the gold buttons to test them is still not recommended."
	new_icon_state = "pda-swaga"
	new_item_state = "pda-swaga"
	new_ttone = list("levelup" = 'sound/items/PDA/mario_1up.ogg')
