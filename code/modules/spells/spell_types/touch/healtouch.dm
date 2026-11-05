//basic touch ability that heals basic damage types accessed by the ashwalker shaman
/datum/action/cooldown/spell/touch/healtouch
	name = "Целебное касание"
	desc = "Это заклинание заряжает вашу руку целительной энергиец, позволяя вам лечить некоторые повреждения."
	hand_path = /obj/item/melee/touch_attack/healtouch
	cooldown_time = 20 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "ИСЦЕЛЕНИЕ!"
	school = SCHOOL_RESTORATION
	can_cast_on_self = TRUE
	button_icon_state = "healtouch"
	sound = 'sound/magic/staff_healing.ogg'
	//total of 40 assuming they're hurt by both brute and burn
	var/brute = 20
	var/burn = 20
	var/tox = 10
	var/oxy = 50

/obj/item/melee/touch_attack/healtouch
	name = "healing touch"
	desc = "A blaze of life-granting energy from the hand. Heals minor to moderate injuries."
	icon_state = "disintegrate" //ironic huh
	item_state = "disintegrate"

/datum/action/cooldown/spell/touch/healtouch/is_valid_target(atom/cast_on)
	if(!ishuman(cast_on))
		return FALSE
	var/mob/living/carbon/human/target = cast_on
	if(target.can_block_magic(antimagic_flags))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/touch/healtouch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	var/mob/living/M = victim
	new /obj/effect/temp_visual/heal(get_turf(M), "#899d39")
	var/update = NONE
	update |= M.heal_overall_damage(brute, burn, updating_health = FALSE)
	update |= M.heal_damages(tox = tox, oxy = oxy, updating_health = FALSE)
	if(update)
		M.updatehealth("healing touch")
	for(var/datum/disease/D in M.diseases)
		if(D.curable)
			D.cure(need_immunity = FALSE)
	return TRUE
