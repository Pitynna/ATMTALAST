/obj/item/clothing/gloves/bracer
	name = "bone bracers"
	desc = "For when you're expecting to get slapped on the wrist. Offers modest protection to your arms."
	icon_state = "bracers"
	item_state = "bracers"
	item_color = null	//So they don't wash.
	transfer_prints = TRUE
	strip_delay = 40
	body_parts_covered = ARMS
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 10, BULLET = 15, LASER = 10, ENERGY = 10, BOMB = 15, BIO = 10, FIRE = 0, ACID = 0)

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
