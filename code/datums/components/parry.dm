// The public type and initializer remain compatible with existing item registrations.
// Only passive blocking is supported; there are no active parries or stamina costs.
/datum/component/parry
	/// Legacy item rating: 0.5 means 50% passive protection.
	var/stamina_coefficient
	var/parryable_attack_types
	var/requires_two_hands = FALSE
	var/requires_activation = FALSE
	var/datum/callback/block_callback

/datum/component/parry/RegisterWithParent()
	// Retain item compatibility while using legacy passive protection.
	RegisterSignal(parent, COMSIG_ITEM_HIT_REACT, PROC_REF(attempt_parry))

/datum/component/parry/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_HIT_REACT)

/datum/component/parry/Initialize(_stamina_constant = 0, _stamina_coefficient = 0, _parry_time_out_time = PARRY_DEFAULT_TIMEOUT, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = 2 SECONDS, _no_parry_sound = FALSE, _requires_two_hands = FALSE, _requires_activation = FALSE, _block_callback = null)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	stamina_coefficient = _stamina_coefficient
	requires_two_hands = _requires_two_hands
	requires_activation = _requires_activation
	parryable_attack_types = _parryable_attack_types
	block_callback = _block_callback

/datum/component/parry/Destroy(force)
	block_callback = null
	return ..()

/datum/component/parry/proc/attempt_parry(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, damage = 0, attack_type = ITEM_ATTACK)
	SIGNAL_HANDLER
	if(owner.incapacitated())
		return
	if(!(attack_type & parryable_attack_types))
		return
	if(requires_two_hands && !HAS_TRAIT(parent, TRAIT_WIELDED))
		return
	if(requires_activation && !HAS_TRAIT(parent, TRAIT_ITEM_ACTIVE))
		return
	var/penetration = 0
	if(isitem(hitby))
		var/obj/item/hitby_item = hitby
		penetration = hitby_item.shields_penetration
	// Swords and riot shields block 50%; bucklers block 30%, without timed input.
	var/block_chance = (1 - stamina_coefficient) * 100
	if(!prob(clamp(block_chance - penetration, 0, 100)))
		return
	block_callback?.Invoke(hitby)
	return COMPONENT_BLOCK_SUCCESSFUL
