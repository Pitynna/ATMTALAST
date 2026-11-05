#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1

/obj/item/reagent_containers/syringe
	name = "syringe"
	desc = "A syringe."
	icon = 'icons/goonstation/objects/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	belt_icon = "syringe"
	fill_icon_state = "syringe"
	possible_transfer_amounts = list(5, 10, 15)
	volume = 15
	sharp = TRUE
	pass_open_check = TRUE
	materials = list(MAT_METAL=10, MAT_GLASS=20)
	container_type = TRANSPARENT
	custom_price = PAYCHECK_MIN * 0.2
	fill_icon_thresholds = list(1, 5, 10 ,15)
	var/busy = FALSE
	var/mode = SYRINGE_DRAW
	var/projectile_type = /obj/projectile/bullet/dart/syringe
	///If this variable is true, the syringe will work through hardsuits / biosuits.
	var/penetrates_thick = FALSE
	///If this variable is true, the syringe will work through unathi skin
	var/ignores_pierceimmune = FALSE

/obj/item/reagent_containers/syringe/Initialize(mapload)
	if(list_reagents) //syringe starts in inject mode if its already got something inside
		mode = SYRINGE_INJECT
	. = ..()

/obj/item/reagent_containers/syringe/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	update_icon()

/obj/item/reagent_containers/syringe/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	update_icon()

/obj/item/reagent_containers/syringe/attack_self(mob/user)
	mode = !mode
	update_icon()

/obj/item/reagent_containers/syringe/attack_self_secondary(mob/user)
	if(has_variable_transfer_amount)
		select_transfer_amount(user)

/obj/item/reagent_containers/syringe/attack_hand()
	..()
	update_icon()

/obj/item/reagent_containers/syringe/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

/obj/item/reagent_containers/syringe/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return
	if(!target.reagents)
		return

	var/mob/living/L
	if(isliving(target))
		L = target
		if(!L.can_inject(user, TRUE, penetrate_thick = penetrates_thick, ignore_pierceimmune = ignores_pierceimmune))
			return

	SEND_SIGNAL(target, COMSIG_LIVING_TRY_SYRINGE, user)

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.holder_full())
				balloon_alert(user, "шприц полон!")
				return

			if(L) //living mob
				var/drawn_amount = reagents.maximum_volume - reagents.total_volume
				if(target != user)
					target.visible_message(span_danger("[user] пыта[PLUR_ET_YUT(user)]ся взять образец крови у [target]!"), \
											span_userdanger("[user] пыта[PLUR_ET_YUT(user)]ся взять у вас образец крови!"))
					busy = TRUE
					if(!do_after(user, 3 SECONDS, target, NONE))
						busy = FALSE
						return
					if(reagents.holder_full())
						return
				busy = FALSE
				if(L.transfer_blood_to(src, drawn_amount))
					L.visible_message(span_danger("[user] взял[GEND_A_O_I(user)] образец крови у [L]!"), \
										span_userdanger("[user] взял[GEND_A_O_I(user)] у вас образец крови!"))
				else
					balloon_alert(user, "больше крови не взять!")

			else //if not mob
				if(!target.reagents.total_volume)
					balloon_alert(user, "пусто!")
					return

				if(!target.is_drawable(user))
					balloon_alert(user, "отсюда вещество не забрать!")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, span_notice("Вы заполняете [declent_ru(ACCUSATIVE)] <b>[trans]</b> единиц[DECL_YEJ_AMI_AMI(trans)] вещества. Теперь он содержит <b>[reagents.total_volume]</b> единиц[DECL_U_Y_0(reagents.total_volume)] вещества."))
			if(reagents.holder_full())
				mode = !mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				balloon_alert(user, "шприц пуст!")
				return

			if(!L && !target.is_injectable(user)) //only checks on non-living mobs, due to how can_inject() handles
				balloon_alert(user, "сюда вещество не ввести!")
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				balloon_alert(user, "нет места!")
				return

			if(L) //living mob
				if(!L.can_inject(user, TRUE, penetrate_thick = penetrates_thick, ignore_pierceimmune = ignores_pierceimmune))
					return
				if(L != user)
					L.visible_message(span_danger("[user] пыта[PLUR_ET_YUT(user)]ся сделать [L] укол [declent_ru(INSTRUMENTAL)]!"), \
										span_userdanger("[user] пыта[PLUR_ET_YUT(user)]ся сделать вам укол [declent_ru(INSTRUMENTAL)]!"))
					if(!do_after(user, 3 SECONDS, L, NONE))
						return
					if(!reagents.total_volume)
						return
					if(L.reagents.total_volume >= L.reagents.maximum_volume)
						return
					L.visible_message(span_danger("[user] дела[PLUR_ET_YUT(user)] [L] укол [declent_ru(INSTRUMENTAL)]!"), \
										span_userdanger("[user] дела[PLUR_ET_YUT(user)] вам укол [declent_ru(INSTRUMENTAL)]!"))

			add_attack_logs(user, target, "Injected with [name] containing [reagents.log_list()], transfered [amount_per_transfer_from_this] units", reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)

			var/fraction = min(amount_per_transfer_from_this / reagents.total_volume, 1)
			reagents.reaction(L, REAGENT_INGEST, fraction)
			reagents.trans_to(target, amount_per_transfer_from_this)
			after_transfer(target)
			to_chat(user, span_notice("Вы вкололи <b>[amount_per_transfer_from_this]</b> единиц[DECL_U_Y_0(amount_per_transfer_from_this)] вещества с помощью [declent_ru(GENITIVE)]. В нём остаётся <b>[reagents.total_volume]</b> единиц[DECL_A_Y_0(reagents.total_volume)] вещества."))
			if(istype(target, /obj/item/reagent_containers/food))
				var/obj/item/reagent_containers/food/F = target
				F.log_eating = TRUE

			if(reagents.total_volume <= 0 && mode == SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()

/obj/item/reagent_containers/syringe/update_icon_state()
	var/rounded_vol
	if(reagents?.total_volume)
		rounded_vol = clamp(round((reagents.total_volume / volume * 15), 5), 1, 15)
	else
		rounded_vol = 0
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"

/obj/item/reagent_containers/syringe/get_sound_for_reagent_containers()
	return SFX_SYRINGEPOUR

/obj/item/reagent_containers/syringe/update_overlays()
	. = ..()
	if(ismob(loc) || istype(loc, /obj/item/gripper))
		var/injoverlay
		switch(mode)
			if(SYRINGE_DRAW)
				injoverlay = "draw"
			if(SYRINGE_INJECT)
				injoverlay = "inject"
		. += injoverlay
		update_equipped_item(update_speedmods = FALSE)

/obj/item/reagent_containers/syringe/antiviral
	name = "Syringe (spaceacillin)"
	desc = "Contains antiviral agents."
	list_reagents = list("spaceacillin" = 15)

/obj/item/reagent_containers/syringe/charcoal
	name = "Syringe (charcoal)"
	desc = "Contains charcoal - used to treat toxins and damage from toxins."
	list_reagents = list("charcoal" = 15)

/obj/item/reagent_containers/syringe/epinephrine
	name = "Syringe (Epinephrine)"
	desc = "Contains epinephrine - used to stabilize patients."
	list_reagents = list("epinephrine" = 15)

/obj/item/reagent_containers/syringe/insulin
	name = "Syringe (insulin)"
	desc = "Contains insulin - used to treat diabetes."
	list_reagents = list("insulin" = 15)

/obj/item/reagent_containers/syringe/calomel
	name = "Syringe (calomel)"
	desc = "Contains calomel, which be used to purge impurities, but is highly toxic itself."
	list_reagents = list("calomel" = 15)

/obj/item/reagent_containers/syringe/heparin
	name = "Syringe (heparin)"
	desc = "Contains heparin, a blood anticoagulant."
	list_reagents = list("heparin" = 15)

/obj/item/reagent_containers/syringe/bioterror
	name = "bioterror syringe"
	desc = "Contains several paralyzing reagents."
	list_reagents = list("neurotoxin" = 5, "capulettium_plus" = 5, "sodium_thiopental" = 5)

/obj/item/reagent_containers/syringe/gluttony
	name = "Gluttony's Blessing"
	desc = "A syringe recovered from a dread place. It probably isn't wise to use."
	amount_per_transfer_from_this = 1
	volume = 1
	list_reagents = list("gluttonytoxin" = 1)

/obj/item/reagent_containers/syringe/capulettium_plus
	name = "capulettium plus syringe"
	desc = "For silencing targets. Allows for fake deaths."
	list_reagents = list("capulettium_plus" = 15)

/obj/item/reagent_containers/syringe/sarin
	name = "sarin syringe"
	desc = "A deadly neurotoxin, for killing."
	list_reagents = list("sarin" = 15)

/obj/item/reagent_containers/syringe/pancuronium
	name = "pancuronium syringe"
	desc = "A powerful paralyzing poison."
	list_reagents = list("pancuronium" = 15)

/obj/item/reagent_containers/syringe/lethal
	name = "lethal injection syringe"
	desc = "A syringe used for lethal injections. It can hold up to 50 units."
	amount_per_transfer_from_this = 50
	volume = 50
	list_reagents = list("toxin" = 15, "pancuronium" = 10, "cyanide" = 5, "facid" = 10, "fluorine" = 10)

/obj/item/reagent_containers/syringe/steroids
	name = "steroid syringe"
	desc = "A syringe containing a substance that rapidly increases muscle mass at a cost to health."
	list_reagents = list("steroids" = 15)

#undef SYRINGE_DRAW
#undef SYRINGE_INJECT
