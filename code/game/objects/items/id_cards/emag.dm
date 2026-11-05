/**
 * Emag (cryptographic sequencer) and Cmag (jestographic sequencer).
 */

/obj/item/card/emag
	name = "cryptographic sequencer"
	desc = "It's a card with a magnetic strip attached to some circuitry."
	icon_state = "emag"
	item_state = "card-id"
	gender = MALE
	origin_tech = "magnets=2;syndicate=3"
	item_flags = NOBLUDGEON|NO_MAT_REDEMPTION

/obj/item/card/emag/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

/obj/item/card/emag/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return
	target.emag_act(user)

/obj/item/card/emag/halloween
	name = "hack-o'-lantern"
	desc = "A pumpkin with a cryptographic sequencer sticking out of it."
	icon_state = "hack_o_lantern"

/obj/item/card/emag_broken
	name = "broken cryptographic sequencer"
	desc = "It's a card with a magnetic strip attached to some circuitry. It looks too busted to be used for anything but salvage."
	icon_state = "emag"
	item_state = "card-id"
	gender = MALE
	origin_tech = "magnets=2;syndicate=1"

/obj/item/card/cmag
	desc = "It's a card coated in a slurry of electromagnetic bananium."
	name = "jestographic sequencer"
	icon_state = "cmag"
	item_state = "card-id"
	gender = MALE
	origin_tech = "magnets=2;syndicate=2"
	item_flags = NOBLUDGEON|NO_MAT_REDEMPTION

/obj/item/card/cmag/ComponentInitialize()
	AddComponent(/datum/component/slippery, 4 SECONDS, lube_flags = (SLIDE|SLIP_WHEN_LYING))

/obj/item/card/cmag/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

/obj/item/card/cmag/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return
	INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, cmag_act), user)
