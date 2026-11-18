// Swing signs and business cards, ideas from Goonstation 13. Sprites are CC BY-NC-SA 3.0 (docs/GOON_ASSETS.md),
// built by tools/goon_ports/extras.py; the code is our own.

#define GOON_MISC 'icons/obj/goon_misc.dmi'
#define SWING_SIGN_MAX_LENGTH 300

// MARK: Swing sign

/obj/structure/swing_sign
	name = "swing sign"
	desc = "A foldable chalkboard sign for announcements and advertisements. Write on it with a pen, fold it by hand."
	icon = GOON_MISC
	icon_state = "swingsign"
	density = TRUE
	anchored = FALSE
	max_integrity = 60
	resistance_flags = FLAMMABLE
	/// What is written on the board.
	var/message = ""
	/// Prefix of the icon states, so the cardboard sign can share the code.
	var/base_state = "swingsign"
	/// What the sign folds into.
	var/folded_type = /obj/item/swing_sign
	var/material_type = /obj/item/stack/sheet/wood

/obj/structure/swing_sign/cardboard
	name = "cardboard swing sign"
	desc = "A foldable cardboard sign for announcements and advertisements. Write on it with a pen, fold it by hand."
	icon_state = "swingsign_cardboard"
	base_state = "swingsign_cardboard"
	folded_type = /obj/item/swing_sign/cardboard
	material_type = /obj/item/stack/sheet/cardboard
	max_integrity = 30

/obj/structure/swing_sign/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/structure/swing_sign/update_icon_state()
	icon_state = message ? "[base_state]_written" : base_state

/obj/structure/swing_sign/examine(mob/user)
	. = ..()
	if(message)
		. += span_notice("It says:")
		. += "<div style='text-align:center'>[message]</div>"
	else
		. += span_notice("It's blank.")
	if(anchored)
		. += span_notice("It is screwed to the floor.")

/obj/structure/swing_sign/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!is_pen(tool))
		return NONE
	var/new_message = tgui_input_text(user, "What should the sign say? Leave empty to wipe it.", "Swing sign", html_decode(replacetext(message, "<br>", "\n")), SWING_SIGN_MAX_LENGTH, multiline = TRUE, encode = FALSE)
	if(isnull(new_message) || QDELETED(src) || !Adjacent(user))
		return ITEM_INTERACT_BLOCKING
	set_message(new_message)
	user.visible_message(span_notice("[user] writes on [src]."), span_notice("You write on [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/swing_sign/proc/set_message(new_message)
	new_message = trim(copytext_char(new_message, 1, SWING_SIGN_MAX_LENGTH + 1))
	message = replacetext(html_encode(new_message), "\n", "<br>")
	update_icon(UPDATE_ICON_STATE)

/obj/structure/swing_sign/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume))
		return
	set_anchored(!anchored)
	to_chat(user, span_notice("You [anchored ? "secure [src] to" : "unsecure [src] from"] the floor."))

/obj/structure/swing_sign/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(anchored)
		to_chat(user, span_warning("[src] is screwed down too tightly to fold!"))
		return TRUE
	user.visible_message(span_notice("[user] folds [src]."), span_notice("You fold [src]."))
	var/obj/item/swing_sign/folded = new folded_type(loc)
	folded.message = message
	user.put_in_hands(folded)
	qdel(src)
	return TRUE

/obj/structure/swing_sign/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	. = ..()
	if(!isliving(AM) || anchored || QDELETED(src))
		return
	var/mob/living/victim = AM
	visible_message(span_warning("[victim] crashes into [src] and knocks it flat!"))
	victim.Knockdown(2 SECONDS)
	playsound(src, 'sound/effects/woodhit.ogg', 50, TRUE)
	var/obj/item/swing_sign/folded = new folded_type(loc)
	folded.message = message
	qdel(src)

/obj/structure/swing_sign/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new material_type(loc, 2)
	qdel(src)

/obj/item/swing_sign
	name = "folded swing sign"
	desc = "A folded swing sign. Use it in hand to set it up."
	icon = GOON_MISC
	icon_state = "swingsign_folded"
	item_state = "swingsign_folded"
	lefthand_file = 'icons/mob/inhands/goon_misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/goon_misc_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 8
	throwforce = 10
	resistance_flags = FLAMMABLE
	hitsound = 'sound/effects/woodhit.ogg'
	var/message = ""
	var/deployed_type = /obj/structure/swing_sign

/obj/item/swing_sign/cardboard
	name = "folded cardboard swing sign"
	icon_state = "swingsign_cardboard_folded"
	item_state = "swingsign_cardboard_folded"
	force = 2
	throwforce = 3
	hitsound = 'sound/weapons/tap.ogg'
	deployed_type = /obj/structure/swing_sign/cardboard

/obj/item/swing_sign/attack_self(mob/user)
	var/turf/target = get_turf(user)
	if(!isturf(target) || target.density)
		return
	for(var/obj/structure/swing_sign/other in target)
		to_chat(user, span_warning("There's already a sign here!"))
		return
	user.visible_message(span_notice("[user] sets up [src]."), span_notice("You set up [src]."))
	var/obj/structure/swing_sign/sign = new deployed_type(target)
	sign.message = message
	sign.update_icon(UPDATE_ICON_STATE)
	sign.setDir(user.dir)
	qdel(src)

// MARK: Business cards

/obj/item/business_card
	name = "business card"
	desc = "A small card with someone's details on it."
	icon = GOON_MISC
	icon_state = "businesscard"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	/// Name printed on the card, blank on a fresh card.
	var/holder_name
	/// Job printed under the name.
	var/holder_job
	/// A line written on by hand: a phone number, a slogan, a threat.
	var/note

/obj/item/business_card/examine(mob/user)
	. = ..()
	if(!holder_name && !note)
		. += span_notice("It's blank.")
		return
	if(holder_name)
		. += "<b>[holder_name]</b>"
	if(holder_job)
		. += "<i>[holder_job]</i>"
	if(note)
		. += "\"[note]\""

/obj/item/business_card/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!is_pen(tool))
		return NONE
	var/new_note = tgui_input_text(user, "What do you write on the card?", "Business card", note, 80)
	if(isnull(new_note) || !user.is_in_hands(src))
		return ITEM_INTERACT_BLOCKING
	note = new_note
	to_chat(user, span_notice("You write on [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/item/business_card/proc/imprint(new_name, new_job, style)
	holder_name = new_name
	holder_job = new_job
	icon_state = style
	name = "[holder_name]'s business card"

/obj/item/storage/box/business_cards
	name = "business card box"
	desc = "A box of blank business cards. Swipe your ID on it to have your name and job printed on the cards inside."
	icon_state = "box"
	storage_slots = 10
	max_combined_w_class = 10
	can_hold = list(/obj/item/business_card)
	/// Card designs to pick from when printing.
	var/static/list/styles = list(
		"classic" = "businesscard",
		"midnight" = "businesscard-alt",
		"royal" = "businesscard-seneca",
		"violet" = "businesscard-vurdulak",
		"mint" = "businesscard-josh",
		"seafoam" = "businesscard-clowntown",
		"gilded" = "businesscard-hemera",
		"executive" = "businesscard-mabinogi",
	)

/obj/item/storage/box/business_cards/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/business_card(src)

/obj/item/storage/box/business_cards/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/obj/item/card/id/id = tool.GetID()
	if(!id)
		return ..()
	if(!length(contents))
		balloon_alert(user, "коробка пуста!")
		return ITEM_INTERACT_BLOCKING
	var/list/choices = list()
	for(var/style in styles)
		choices[style] = image(GOON_MISC, styles[style])
	var/picked = show_radial_menu(user, src, choices, require_near = TRUE)
	if(!picked || QDELETED(id) || !(user.is_in_hands(src) || Adjacent(user)))
		return ITEM_INTERACT_BLOCKING
	var/printed = 0
	for(var/obj/item/business_card/card in contents)
		card.imprint(id.registered_name, id.assignment, styles[picked])
		printed++
	playsound(src, 'sound/goonstation/machines/printer_thermal.ogg', 40, TRUE)
	to_chat(user, span_notice("[src] prints [printed] business card\s for [id.registered_name]."))
	return ITEM_INTERACT_SUCCESS

#undef SWING_SIGN_MAX_LENGTH
#undef GOON_MISC
