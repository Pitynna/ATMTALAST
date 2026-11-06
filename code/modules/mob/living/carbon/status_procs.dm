/mob/living/carbon/proc/IsStamcrited()
	return HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA_TRAIT)

// Legacy player combat has no stamina resource. Keep these APIs for content compatibility.
/mob/living/carbon/adjustStaminaLoss(amount = 0, updating_health = TRUE, blocked = 0, forced = FALSE, used_weapon = null)
	return STATUS_UPDATE_NONE

/mob/living/carbon/setStaminaLoss(amount, updating_health = TRUE)
	return STATUS_UPDATE_NONE

/mob/living/carbon/proc/enter_stamcrit()
	if(IsStamcrited()) //Already in stamcrit
		return
	if(check_incapacitating_immunity(CANSTAMCRIT))
		return
	SEND_SIGNAL(src, COMSIG_CARBON_ENTER_STAMCRIT)
	to_chat(src, span_warning("Вы слишком истощены, чтобы передвигаться."))
	add_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_FLOORED, TRAIT_HANDS_BLOCKED), STAMINA_TRAIT)
	if(getStaminaLoss() < 120) // Puts you a little further into the initial stamcrit, makes stamcrit harder to outright counter with chems.
		adjustStaminaLoss(30, FALSE)
