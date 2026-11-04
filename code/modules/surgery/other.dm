//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////

/datum/surgery/infection
	name = "Санация"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/cauterize)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_L_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_TAIL,
		BODY_ZONE_WING,
	)

/datum/surgery/bleeding
	name = "Восстановление повреждённых сосудов"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/generic/cauterize,
	)
	possible_locs = list(
		BODY_ZONE_L_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_TAIL,
		BODY_ZONE_WING,
	)
	restricted_speciestypes = list(/datum/species/plasmaman)

/datum/surgery/bleeding/special
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/generic/cauterize,
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
	)
	restricted_speciestypes = list(/datum/species/wryn, /datum/species/kidan, /datum/species/plasmaman)

/datum/surgery/bleeding/plasmaman
	name = "Восстановление повреждённых сосудов (Плазмолюд)"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ/plasma,
		/datum/surgery_step/generic/cauterize,
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_L_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_TAIL,
		BODY_ZONE_WING,
	)
	target_speciestypes = list(/datum/species/plasmaman)
	restricted_speciestypes = null

/datum/surgery/bleeding/insect
	name = "Восстановление повреждённых сосудов (Инсектоид)"
	steps = list(
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize,
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
	)
	target_speciestypes = list(/datum/species/wryn, /datum/species/kidan)
	restricted_speciestypes = null

/datum/surgery/debridement
	name = "Восстановление мёртвых тканей"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/fix_dead_tissue,
		/datum/surgery_step/treat_necrosis,
		/datum/surgery_step/generic/cauterize,
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_L_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_TAIL,
		BODY_ZONE_WING,
	)

/datum/surgery/bleeding/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(affected.has_internal_bleeding())
		return TRUE
	return FALSE

/datum/surgery/debridement/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(!affected.is_dead())
		return FALSE
	return TRUE

/datum/surgery/suture
	name = "Зашить кровотечения"
	steps = list(
		/datum/surgery_step/generic/suture,
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_L_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_TAIL,
	)

/datum/surgery/suture/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(affected.bleeding_amount > 0)
		return TRUE
	return FALSE

/datum/surgery_step/fix_vein
	name = "заживление кровеносных сосудов"
	begin_sound = 'sound/surgery/fixovein1.ogg'
	end_sound = 'sound/surgery/hemostat1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_FIXOVEIN = 100,
		/obj/item/stack/cable_coil = 90,
		/obj/item/stack/sheet/sinew = 90,
	)
	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

	time = 3.2 SECONDS

/datum/surgery_step/fix_vein/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected.has_internal_bleeding())
		user.balloon_alert(user, "сосуды в норме!")
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message(
		span_notice("[user] начина[PLUR_ET_YUT(user)] заживлять повреждённые сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете заживлять повреждённые сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Боль в ваш[GEND_EM_EI_EM_IH(affected)] [affected.declent_ru(PREPOSITIONAL)] просто невыносима!")
	return ..()

/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] заживля[PLUR_ET_YUT(user)] повреждённые сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы заживляете повреждённые сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	affected.stop_internal_bleeding()
	affected.stop_arterial_bleeding()
	affected.stop_bleeding()
	if(ishuman(user) && prob(40))
		var/mob/living/carbon/human/U = user
		U.bloody_hands(target, 0)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[PLUR_ET_YUT(user)] рукой, со всей силы засовывая [tool.declent_ru(ACCUSATIVE)] глубоко в рану на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, со всей силы засовывая [tool.declent_ru(ACCUSATIVE)] глубоко в рану на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(5, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/fix_dead_tissue		//Debridement
	name = "удаление мёртвой плоти"
	begin_sound = 'sound/surgery/scalpel1.ogg'
	end_sound = 'sound/surgery/scalpel2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_SCALPEL = 100,
		/obj/item/kitchen/knife = 90,
		/obj/item/shard = 60,
	)

	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

	time = 1.6 SECONDS

/datum/surgery_step/fix_dead_tissue/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[PLUR_ET_YUT(user)] срезать и удалять мёртвую плоть в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете срезать и удалять мёртвую плоть в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Боль в ваш[GEND_EM_EI_EM_IH(affected)] [affected.declent_ru(PREPOSITIONAL)] просто невыносима!")
	return ..()

/datum/surgery_step/fix_dead_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] среза[PLUR_ET_YUT(user)] и удаля[PLUR_ET_YUT(user)] мёртвую плоть в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы срезаете и удаляете мёртвую плоть в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.open = ORGAN_ORGANIC_OPEN
	affected.owner.add_bleeding_bodypart(affected)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/fix_dead_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[PLUR_ET_YUT(user)] рукой, прорезая [tool.declent_ru(INSTRUMENTAL)] ткань в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, прорезая [tool.declent_ru(INSTRUMENTAL)] ткань в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(20, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/treat_necrosis
	name = "обработка омертвелых тканей"
	allowed_tools = list(
		/obj/item/reagent_containers/dropper = 100,
		/obj/item/reagent_containers/cup/bottle = 90,
		/obj/item/reagent_containers/cup/glass/drinkingglass = 85,
		/obj/item/reagent_containers/cup/glass/bottle = 80,
		/obj/item/reagent_containers/cup/beaker = 75,
		/obj/item/reagent_containers/spray = 60,
		/obj/item/reagent_containers/cup/bucket = 50,
	)

	time = 2.4 SECONDS

/datum/surgery_step/treat_necrosis/tool_check(mob/user, obj/item/tool)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/reagent_containers/container = tool
	if(!container.reagents.has_reagent("mitocholide"))
		user.visible_message(
			span_notice("[user] нерешительно смотр[PLUR_IT_YAT(user)] на [tool.declent_ru(ACCUSATIVE)], ничего не предпринимая."),
			span_notice("Вы нерешительно смотрите на [tool.declent_ru(ACCUSATIVE)]. Кажется, что [GEND_HE_SHE(tool)] не содержат митоколида."),
			chat_message_type = MESSAGE_TYPE_COMBAT
			)
		return FALSE

/datum/surgery_step/treat_necrosis/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!(affected.is_dead()))
		user.balloon_alert(user, "обработка не требуется!")
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message(
		span_notice("[user] начина[PLUR_ET_YUT(user)] обрабатывать митоколидом омертвелые ткани в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете обрабатывать митоколидом омертвелые ткани в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Вы чувствуете острую боль в [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()

/datum/surgery_step/treat_necrosis/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/obj/item/reagent_containers/container = tool
	var/mitocholide = FALSE

	if(container.reagents.has_reagent("mitocholide"))
		mitocholide = TRUE

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	if(trans > 0)
		container.reagents.reaction(target, REAGENT_INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

		if(mitocholide)
			affected.unnecrotize()

		user.visible_message(
			span_notice("[user] вылива[PLUR_ET_YUT(user)] [trans] единиц[DECL_U_Y_0(trans)] вещества из [tool.declent_ru(GENITIVE)] на омертвелые ткани в [affected.declent_ru(PREPOSITIONAL)] [target]."),
			span_notice("Вы выливаете [trans] единиц[DECL_U_Y_0(trans)] вещества из [tool.declent_ru(GENITIVE)] на омертвелые ткани в [affected.declent_ru(PREPOSITIONAL)] [target]."),
			chat_message_type = MESSAGE_TYPE_COMBAT
		)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/treat_necrosis/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!is_reagent_container(tool))
		return SURGERY_STEP_INCOMPLETE

	var/obj/item/reagent_containers/container = tool

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	container.reagents.reaction(target, REAGENT_INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

	user.visible_message(
		span_warning("[user] дёрга[PLUR_ET_YUT(user)] рукой, проливая [trans] единиц[DECL_U_Y_0(trans)] вещества из [tool.declent_ru(GENITIVE)] мимо раны на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, проливая [trans] единиц[DECL_U_Y_0(trans)] вещества из [tool.declent_ru(GENITIVE)] мимо раны на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	//no damage or anything, just wastes medicine
	return SURGERY_STEP_RETRY

//////////////////////////////////////////////////////////////////
//					Dethrall Shadowling						//
//////////////////////////////////////////////////////////////////
