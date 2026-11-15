/obj/item/clothing/gloves/fingerless/weaver
	name = "weaver chitin gloves"
	desc = "Grey gloves without fingertips made from the hide of a dead arachnid found on lavaland. Makes wearer stronger in disarming ability."
	icon_state = "weaver_chitin"
	item_state = "weaver_chitin"
	extra_knock_chance = 20
	var/stamdamage_low = 10
	var/stamdamage_high = 15

/obj/item/clothing/gloves/fingerless/weaver/Touch(atom/A, proximity)
	. = FALSE
	if(!ishuman(loc))
		return FALSE

	var/mob/living/carbon/human/user = loc
	if(!user.mind || user.mind.martial_art)
		return FALSE

	if(user.a_intent != INTENT_HARM || !proximity || isturf(A))
		return FALSE

	var/damage = rand((user.dna.species.punchdamagelow + user.physiology.punch_damage_low) * user.physiology.punch_damage_low_mod, (user.dna.species.punchdamagehigh + user.physiology.punch_damage_high) * user.physiology.punch_damage_high_mod)
	var/stamindamage = rand(stamdamage_low, stamdamage_high)
	if(ishuman(A))
		user.do_attack_animation(A, "kick")
		playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
		var/mob/living/carbon/human/target = A
		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		add_attack_logs(user, target, "Melee attacked with weaver gloves")

		target.visible_message(span_danger("[user] сокруша[PLUR_ET_YUT(user)] [target] [declent_ru(INSTRUMENTAL)]!"))

		target.apply_damage(damage, BRUTE, affecting)
		target.apply_damage(stamindamage, STAMINA, affecting)
		return TRUE
