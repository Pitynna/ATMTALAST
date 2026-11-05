/obj/item/organ/internal/xenos
	origin_tech = "biotech=5"
	icon_state = null
	tough = TRUE
	sterile = TRUE
	/// List of all powers carbon will get from inserted organ.
	var/list/alien_powers

/**
 * This adds and removes alien spells upon addition, if a noncarbon tries to do this well... I blame adminbus
 */
/obj/item/organ/internal/xenos/insert(mob/living/carbon/user, special = ORGAN_MANIPULATION_DEFAULT)
	..()
	if(length(alien_powers))
		for(var/power_to_add in alien_powers)
			user.AddSpell(new power_to_add)

/obj/item/organ/internal/xenos/remove(mob/living/carbon/user, special = ORGAN_MANIPULATION_DEFAULT)
	if(length(alien_powers))
		for(var/power_to_remove in alien_powers)
			var/datum/action/cooldown/spell/actual_spell = locate(power_to_remove) in user.actions
			actual_spell.Remove(user)
	. = ..()

/obj/item/organ/internal/xenos/prepare_eat()
	var/obj/object = ..()
	object.reagents.add_reagent("sacid", 10)
	return object

//XENOMORPH ORGANS
/obj/item/organ/internal/brain/xeno
	name = "xenomorph brain"
	desc = "We barely understand the brains of terrestial animals. Who knows what we may find in the brain of such an advanced species?"
	icon_state = "brain-x"
	origin_tech = "biotech=6"
	mmi_icon = 'icons/mob/alien.dmi'
	mmi_icon_state = "AlienMMI"

/obj/item/organ/internal/xenos/plasmavessel
	name = "xeno plasma vessel"
	desc = "An organ responsible for secreting plasma inside a xenomorph."
	gender = FEMALE
	icon_state = "plasma"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "biotech=5;plasmatech=4"
	slot = INTERNAL_ORGAN_PLASMAVESSEL
	alien_powers = list(/datum/action/cooldown/spell/conjure/plant_weeds, /datum/action/cooldown/spell/touch/transfer_plasma)
	/// Used as a marker for hud updates on Life(). Ridiculous initial value required to update hud on organ insertion.
	var/old_plasma_amount = 9999
	/// Current amount of plasma.
	var/stored_plasma = 0
	/// Maximum vessel capacity.
	var/max_plasma = 500
	/// Gained heal amount per Life() cycle, while on weeds.
	var/heal_rate = 7.5
	/// Gained passive heal amount per Life() cycle.
	var/passive_heal_rate = 1
	/// Gained plasma amount per Life() cycle.
	var/plasma_rate = 10

/obj/item/organ/internal/xenos/plasmavessel/queen
	name = "bloated xeno plasma vessel"
	desc = "An organ responsible for secreting plasma inside a xenomorph. This belonged to a xenomorph queen."
	icon_state = "plasma_large"
	origin_tech = "biotech=6;plasmatech=4"
	max_plasma = 750
	stored_plasma = 300
	plasma_rate = 30
	alien_powers = list(/datum/action/cooldown/spell/conjure/plant_weeds/queen, /datum/action/cooldown/spell/touch/transfer_plasma)

/obj/item/organ/internal/xenos/plasmavessel/praetorian
	name = "huge xeno plasma vessel"
	desc = "An organ responsible for secreting plasma inside a xenomorph. This belonged to a xenomorph praetorian."
	icon_state = "plasma_large"
	max_plasma = 750
	stored_plasma = 100
	plasma_rate = 15

/obj/item/organ/internal/xenos/plasmavessel/drone
	name = "large xeno plasma vessel"
	desc = "An organ responsible for secreting plasma inside a xenomorph. This belonged to a xenomorph drone."
	icon_state = "plasma_large"
	max_plasma = 300
	stored_plasma = 200
	plasma_rate = 25

/obj/item/organ/internal/xenos/plasmavessel/sentinel
	name = "medium xeno plasma vessel"
	desc = "An organ responsible for secreting plasma inside a xenomorph. This belonged to a xenomorph sentinel."
	max_plasma = 200
	stored_plasma = 100
	plasma_rate = 25

/obj/item/organ/internal/xenos/plasmavessel/hunter
	name = "small xeno plasma vessel"
	desc = "An organ responsible for secreting plasma inside a xenomorph. This belonged to a xenomorph hunter."
	icon_state = "plasma_tiny"
	max_plasma = 150
	stored_plasma = 100

/obj/item/organ/internal/xenos/plasmavessel/larva
	name = "tiny xeno plasma vessel"
	desc = "An organ responsible for secreting plasma inside a xenomorph. This belonged to a xenomorph larva."
	icon_state = "plasma_tiny"
	max_plasma = 100
	alien_powers = list()

/obj/item/organ/internal/xenos/plasmavessel/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("plasma", stored_plasma/10)
	return S

/obj/item/organ/internal/xenos/plasmavessel/on_life()
	if(!owner)
		return
	if(owner.on_fire)
		return

	update_hud()

	var/heal_amt = passive_heal_rate
	var/plasma_amt = 0
	if(locate(/obj/structure/alien/weeds) in owner.loc)
		if(owner.health >= owner.maxHealth)
			plasma_amt = plasma_rate
		else
			heal_amt += heal_rate
			plasma_amt = plasma_rate/2
	else
		if(stored_plasma < 50)
			plasma_amt = plasma_rate/10

	if(!isalien(owner))
		heal_amt *= 0.2

	var/update = NONE
	update |= owner.heal_overall_damage(heal_amt, heal_amt, updating_health = FALSE)
	update |= owner.heal_damages(oxy = heal_amt, clone = heal_amt, updating_health = FALSE)
	if(update)
		owner.updatehealth()

	owner.adjust_alien_plasma(plasma_amt)
	update_hud()

/obj/item/organ/internal/xenos/plasmavessel/proc/update_hud()
	if(old_plasma_amount != stored_plasma)
		old_plasma_amount = stored_plasma
		owner.update_plasma_display(owner)

/obj/item/organ/internal/xenos/acidgland
	name = "xeno acid gland"
	desc = "An organ responsible for secreting acid inside a xenomorph."
	gender = FEMALE
	icon_state = "acid"
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_ACIDGLAND
	origin_tech = "biotech=5;materials=2;combat=2"
	alien_powers = list(/datum/action/cooldown/spell/touch/corrosive_acid_spit)

/obj/item/organ/internal/xenos/acidgland/sentinel
	name = "medium xeno acid gland"
	desc = "An organ responsible for secreting acid inside a xenomorph. This belonged to a xenomorph sentinel."
	alien_powers = list(/datum/action/cooldown/spell/touch/corrosive_acid_spit/sentinel)

/obj/item/organ/internal/xenos/acidgland/praetorian
	name = "massive xeno acid gland"
	desc = "An organ responsible for secreting acid inside a xenomorph. This belonged to a xenomorph praetorian."
	alien_powers = list(/datum/action/cooldown/spell/touch/corrosive_acid_spit/praetorian)

/obj/item/organ/internal/xenos/acidgland/queen
	name = "royal xeno acid gland"
	desc = "An organ responsible for secreting acid inside a xenomorph. This belonged to a xenomorph queen."
	alien_powers = list(/datum/action/cooldown/spell/touch/corrosive_acid_spit/queen)

/obj/item/organ/internal/xenos/hivenode
	name = "xeno hive node"
	desc = "An organ responsible for telepathic communication with the xenomorph hive."
	icon_state = "hivenode"
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_HIVENODE
	origin_tech = "biotech=5;magnets=4;bluespace=3"
	w_class = WEIGHT_CLASS_TINY
	alien_powers = list(/datum/action/cooldown/spell/pointed/xeno_whisper)

/obj/item/organ/internal/xenos/hivenode/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	M.faction |= "alien"
	M.add_language(LANGUAGE_XENOS)
	M.add_language(LANGUAGE_HIVE_XENOS)

/obj/item/organ/internal/xenos/hivenode/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	M.faction -= "alien"
	M.remove_language(LANGUAGE_XENOS)
	M.remove_language(LANGUAGE_HIVE_XENOS)
	. = ..()

/obj/item/organ/internal/xenos/neurotoxin
	name = "large xeno neurotoxin gland"
	desc = "An organ responsible for secreting neurotoxin inside a xenomorph."
	gender = FEMALE
	icon_state = "neurotox"
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_NEUROTOXIN_GLAND
	origin_tech = "biotech=5;combat=5"
	alien_powers = list(/datum/action/cooldown/spell/pointed/projectile/neurotoxin_spit)

/obj/item/organ/internal/xenos/neurotoxin/sentinel
	name = "medium xeno neurotoxin gland"
	desc = "An organ responsible for secreting neurotoxin inside a xenomorph. This belonged to a sentinel."
	alien_powers = list(/datum/action/cooldown/spell/pointed/projectile/neurotoxin_spit/sentinel)

/obj/item/organ/internal/xenos/resinspinner
	name = "xeno resin organ"//...there tiger....
	desc = "An organ responsible for secreting resin inside a xenomorph."
	gender = FEMALE
	icon_state = "liver-x"
	parent_organ_zone = BODY_ZONE_PRECISE_MOUTH
	slot = INTERNAL_ORGAN_RESIN_SPINNER
	origin_tech = "biotech=5;materials=4"
	alien_powers = list(/datum/action/cooldown/spell/build_resin)

/obj/item/organ/internal/xenos/eggsac
	name = "xeno egg sac"
	desc = "An organ responsible for secreting resin inside a xenomorph."
	icon_state = "eggsac"
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN
	slot = INTERNAL_ORGAN_EGGSAC
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "biotech=6"
	alien_powers = list(/datum/action/cooldown/spell/conjure/xeno_eggs)
