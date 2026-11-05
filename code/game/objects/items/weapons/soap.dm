/obj/item/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "soap"
	belt_icon = "soap"
	item_state = "soap"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 20
	item_flags = SKIP_ATTACK_MESSAGE
	var/cleanspeed = 50 //slower than mop

/obj/item/soap/ComponentInitialize()
	AddComponent(/datum/component/slippery, 4 SECONDS, lube_flags = (SLIDE|SLIP_WHEN_LYING))
	AddComponent(/datum/component/cleaner, cleanspeed, 0.1, pre_clean_callback=CALLBACK(src, PROC_REF(should_clean))) //less scaling for soapies

/obj/item/soap/proc/should_clean(datum/cleaning_source, atom/atom_to_clean, mob/living/cleaner)
	if(ishuman(atom_to_clean) && ishuman(cleaner) && !cleaner.stat && cleaner.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		return CLEAN_BLOCKED
	. = CLEAN_ALLOWED
	if(!check_allowed_items(atom_to_clean))
		. |= CLEAN_NO_XP|CLEAN_NO_WASH

/obj/item/soap/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		user.visible_message(
			span_warning("[user] мо[PLUR_ET_YUT(user)] рот [target.declent_ru(GENITIVE)] с [declent_ru(INSTRUMENTAL)]!"),
			span_notice("Вы моете рот [target.declent_ru(GENITIVE)] с [declent_ru(INSTRUMENTAL)]!"),
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

/obj/item/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of plasma."
	icon_state = "soapnt"
	item_state = "soapnt"

/obj/item/soap/homemade
	desc = "A homemade bar of soap. Smells of... well...."
	icon_state = "soapgibs"
	item_state = "soapgibs"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_apple
	desc = "A homemade bar of soap. Smells of apple"
	icon_state = "soapapple"
	item_state = "soapapple"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_potato
	desc = "A homemade bar of soap. Smells of potato"
	icon_state = "soappotato"
	item_state = "soappotato"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_pumpkin
	desc = "A homemade bar of soap. Smells of pumpkin"
	icon_state = "soappumpkin"
	item_state = "soappumpkin"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_silver
	desc = "A homemade bar of soap. Smells of silver"
	icon_state = "soapsilver"
	item_state = "soapsilver"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_tomato
	desc = "A homemade bar of soap. Smells of tomato"
	icon_state = "soaptomato"
	item_state = "soaptomato"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_uran
	desc = "A homemade bar of soap. Smells of uranium"
	icon_state = "soapuran"
	item_state = "soapuran"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_watermelon
	desc = "A homemade bar of soap. Smells of watermelon"
	icon_state = "soapwatermelon"
	item_state = "soapwatermelon"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_whiskey
	desc = "A homemade bar of soap. Smells of whiskey"
	icon_state = "soapwhiskey"
	item_state = "soapwhiskey"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_banana
	desc = "A homemade bar of soap. Smells of banana"
	icon_state = "soapbanana"
	item_state = "soapbanana"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_beer
	desc = "A homemade bar of soap. Smells of beer"
	icon_state = "soapbeer"
	item_state = "soapbeer"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_berry
	desc = "A homemade bar of soap. Smells of berries"
	icon_state = "soapberry"
	item_state = "soapberry"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_carrot
	desc = "A homemade bar of soap. Smells of carrot"
	icon_state = "soapcarrot"
	item_state = "soapcarrot"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_chocolate
	desc = "A homemade bar of soap. Smells of chocolate"
	icon_state = "soapchocolate"
	item_state = "soapchocolate"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_cola
	desc = "A homemade bar of soap. Smells of cola"
	icon_state = "soapcola"
	item_state = "soapcola"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_corn
	desc = "A homemade bar of soap. Smells of corn"
	icon_state = "soapcorn"
	item_state = "soapcorn"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_golden
	desc = "A homemade bar of soap. Smells of gold"
	icon_state = "soapgolden"
	item_state = "soapgolden"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_grape
	desc = "A homemade bar of soap. Smells of grape"
	icon_state = "soapgrape"
	item_state = "soapgrape"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_lemon
	desc = "A homemade bar of soap. Smells of lemon"
	icon_state = "soaplemon"
	item_state = "soaplemon"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_lime
	desc = "A homemade bar of soap. Smells of lime"
	icon_state = "soaplime"
	item_state = "soaplime"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_milk
	desc = "A homemade bar of soap. Smells of milk"
	icon_state = "soapmilk"
	icon_state = "soapmilk"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_orange
	desc = "A homemade bar of soap. Smells of orange"
	icon_state = "soaporange"
	item_state = "soaporange"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_pineapple
	desc = "A homemade bar of soap. Smells of pineapple"
	icon_state = "soappineapple"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/ducttape
	name = "duct-taped soap"
	desc = "A homemade bar of soap. It seems to be gibs and tape..Will this clean anything?"
	icon_state = "soapgibs"
	item_state = "soapgibs"

/obj/item/soap/ducttape/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return

	if(user.client && (target in user.client.screen))
		user.balloon_alert(user, "снимите это с себя!")
	else
		user.visible_message(span_warning("[user] начина[PLUR_ET_YUT(user)] возить [declent_ru(INSTRUMENTAL)] по [target.declent_ru(DATIVE)]."))
		if(do_after(user, cleanspeed, target))
			to_chat(user, span_notice("Вы \"моете\" [target.declent_ru(ACCUSATIVE)] [declent_ru(INSTRUMENTAL)]."))
			if(issimulatedturf(target))
				new /obj/effect/decal/cleanable/blood/gibs/cleangibs(target)
			else if(iscarbon(target))
				for(var/obj/item/carried_item in target.contents)
					if(!istype(carried_item, /obj/item/implant))//If it's not an implant.
						carried_item.add_mob_blood(target)//Oh yes, there will be blood...
				var/mob/living/carbon/human/H = target
				H.bloody_hands(target,0)
				H.bloody_body(target)

	return

/obj/item/soap/deluxe
	desc = "A luxury bar of soap. Smells of honey."
	icon_state = "soapdeluxe"
	item_state = "soapdeluxe"
	cleanspeed = 40 //slightly better because deluxe -- captain gets one of these

/obj/item/soap/ert
	desc = "High-quality sea-breeze-scented soap, specially made for scrubbing unfortunate crew members' dried blood from the floors."
	icon_state = "soapert"
	item_state = "soapert"
	cleanspeed = 10

/obj/item/soap/syndie
	desc = "An untrustworthy bar of soap made of strong chemical agents that dissolve blood faster."
	icon_state = "soapsyndie"
	item_state = "soapsyndie"
	belt_icon = "soapsyndie"
	cleanspeed = 10 //much faster than mop so it is useful for traitors who want to clean crime scenes
