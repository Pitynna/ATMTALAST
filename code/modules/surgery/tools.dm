/obj/item/retractor
	name = "retractor"
	desc = "A sterilized tissue retractor used for holding open incisions."
	gender = MALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	item_state = "retractor"
	materials = list(MAT_METAL=6000, MAT_GLASS=3000)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=1;biotech=1"
	tool_behaviour = TOOL_RETRACTOR

/obj/item/retractor/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/retractor/laser
	name = "Advanced Laser Retractors"
	desc = "A retractor with a laser tip. This one looks to be the pinnacle of precision energy a surgery tools!"
	icon_state = "retractor_laser"
	item_state = "retractor_laser"
	toolspeed = 0.4

/obj/item/retractor/augment
	desc = "Micro-mechanical manipulator for retracting stuff."
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5

/obj/item/retractor/primitive_retractor
	name = "primitive bone retractor"
	desc = "A primitive bone instrument for holding surgical cavities open."
	icon_state = "primitive_retractor"
	item_state = "primitive_retractor"

/obj/item/hemostat
	name = "hemostat"
	desc = "A sterilized steel surgical clamp for sealing exposed blood vessels during surgery."
	gender = MALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	item_state = "hemostat"
	materials = list(MAT_METAL=5000, MAT_GLASS=2500)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("атаковал", "ущипнул")
	tool_behaviour = TOOL_HEMOSTAT

/obj/item/hemostat/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/hemostat/laser
	name = "Advanced Laser Hemostat"
	desc = "A hemostat with a laser clamp. This one looks to be the pinnacle of precision energy a surgery tools!"
	icon_state = "hemostat_laser"
	item_state = "hemostat_laser"
	toolspeed = 0.4

/obj/item/hemostat/augment
	desc = "Tiny servos power a pair of pincers to stop bleeding."
	toolspeed = 0.5

/obj/item/hemostat/primitive_hemostat
	name = "primitive hemostat"
	desc = "A primitive bone instrument for clamping bleeding vessels during surgery."
	icon_state = "primitive_hemostat"
	item_state = "primitive_hemostat"

/obj/item/cautery
	name = "cautery"
	desc = "A unipolar electrocauter used to sear surgical incisions shut."
	gender = MALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	item_state = "cautery"
	materials = list(MAT_METAL=2500, MAT_GLASS=750)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("подпалил")
	tool_behaviour = TOOL_CAUTERY
	heat = T500K

/obj/item/cautery/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/cautery/augment
	desc = "A heated element that cauterizes wounds."
	toolspeed = 0.5

/obj/item/cautery/primitive_cautery
	name = "primitive cautery"
	desc = "A primitive bone instrument for cauterizing wounds."
	icon_state = "primitive_cautery"
	item_state = "primitive_cautery"

/obj/item/surgicaldrill
	name = "surgical drill"
	desc = "A sterilized drill used to create holes in bone and teeth."
	icon = 'icons/obj/surgery.dmi'
	gender = FEMALE
	icon_state = "drill"
	item_state = "drills"
	hitsound = 'sound/weapons/drill.ogg'
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	flags = CONDUCT
	force = 15
	sharp = 1
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("продырявил")
	tool_behaviour = TOOL_DRILL

/obj/item/surgicaldrill/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/surgicaldrill/suicide_act(mob/living/user)
	user.visible_message(
		span_suicide("[user] наматыва[PLUR_ET_YUT(user)] себя на [declent_ru(ACCUSATIVE)]!\n\
		Похоже, что [GEND_HE_SHE(user)] соверша[PLUR_ET_YUT(user)] суицид!")
		)

	addtimer(CALLBACK(src, PROC_REF(second_act), user), 2.5 SECONDS)
	user.SpinAnimation(3, 10)

	ADD_TRAIT(user, TRAIT_IMMOBILIZED, UNIQUE_TRAIT_SOURCE(src))
	playsound(user, 'sound/machines/juicer.ogg', 20, TRUE)

	return OBLITERATION

/obj/item/surgicaldrill/proc/second_act(mob/user)
	if(!user)
		return

	for(var/obj/item/item in user.get_equipped_items())
		user.drop_item_ground(item)

	user.gib()

/obj/item/surgicaldrill/laser
	name = "Advanced Laser Surgical Drill"
	desc = "A surgery drill with a directed laser bit. This one looks to be the pinnacle of precision energy a surgery tools!"
	icon_state = "drill_laser"
	item_state = "drill_laser"
	toolspeed = 0.4

/obj/item/surgicaldrill/augment
	desc = "Effectively a small power drill contained within your arm, edges dulled to prevent tissue damage. May or may not pierce the heavens."
	hitsound = 'sound/weapons/circsawhit.ogg'
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5

/obj/item/scalpel
	name = "scalpel"
	desc = "A sterilized stainless steel cutting implement for making precise surgical incisions."
	gender = MALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	item_state = "scalpel"
	flags = CONDUCT
	force = 10.0
	sharp = 1
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	embed_chance = 10
	embedded_ignore_throwspeed_threshold = TRUE
	materials = list(MAT_METAL=4000, MAT_GLASS=1000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("атаковал", "полоснул", "уколол", "поранил", "порезал")
	hitsound = 'sound/weapons/bladeslice.ogg'
	tool_behaviour = TOOL_SCALPEL

/obj/item/scalpel/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)
	if(!HAS_TRAIT(src, TRAIT_SURGERY_INITIATOR))
		AddComponent(/datum/component/surgery_initiator)

/obj/item/scalpel/suicide_act(mob/user)
	to_chat(viewers(user), pick(span_suicide("[user] [declent_ru(INSTRUMENTAL)] среза[PLUR_ET_YUT(user)] свою кожу! Похоже, что [GEND_HE_SHE(user)] соверша[PLUR_ET_YUT(user)] суицид!"),
						span_suicide("[user] реж[PLUR_ET_UT(user)] своё горло с помощью [declent_ru(GENITIVE)]! Похоже, что [GEND_HE_SHE(user)] соверша[PLUR_ET_YUT(user)] суицид!"),
						span_suicide("[user] вонза[PLUR_ET_YUT(user)] [declent_ru(NOMINATIVE)] в свой желудок! Похоже, что [GEND_HE_SHE(user)] пыта[PLUR_ET_YUT(user)]ся совершить сэппуку!")))
	return BRUTELOSS

/obj/item/scalpel/augment
	desc = "Ultra-sharp blade attached directly to your bone for extra-accuracy."
	toolspeed = 0.5

/obj/item/scalpel/primitive_scalpel
	name = "primitive scalpel"
	desc = "A primitive scalpel made from bone. Still highly effective despite its material."
	icon_state = "primitive_scalpel"
	item_state = "primitive_scalpel"

/*
 * Researchable Scalpels
 */
/obj/item/scalpel/laser //parent type
	name = "laser scalpel"
	desc = "An advanced laser emitter for creating and cauterizing precise surgical incisions with extreme speed."
	icon_state = "scalpel_laser1_on"
	damtype = "fire"
	hitsound = 'sound/weapons/sear.ogg'

/obj/item/scalpel/laser/laser1 //lasers also count as catuarys
	name = "Basic Laser Scalpel"
	desc = "A scalpel augmented with a directed laser.  This one looks basic and could be improved."
	toolspeed = 0.8

/obj/item/scalpel/laser/laser2
	name = "Improved Laser Scalpel"
	desc = "A scalpel augmented with a directed laser. This one looks somewhat advanced."
	icon_state = "scalpel_laser2_on"
	toolspeed = 0.6

/obj/item/scalpel/laser/laser3
	name = "Advanced Laser Scalpel"
	desc = "A scalpel augmented with a directed laser.  This one looks to be the pinnacle of precision energy cutlery!"
	icon_state = "scalpel_laser3_on"
	toolspeed = 0.4

/obj/item/scalpel/laser/manager //super tool! Retractor/hemostat
	name = "incision management system"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	icon_state = "scalpel_manager_on"
	icon
	toolspeed = 0.2

/obj/item/scalpel/laser/manager/Initialize(mapload)
	. = ..()
	// this one can automatically retry its steps, too!
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/circular_saw
	name = "circular saw"
	desc = "A sterilized medical saw for use in cutting through bone."
	gender = FEMALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	hitsound = 'sound/weapons/circsawhit.ogg'
	mob_throw_hit_sound =  'sound/weapons/pierce.ogg'
	flags = CONDUCT
	force = 15
	sharp = 1
	throwforce = 9
	throw_speed = 3
	throw_range = 5
	embed_chance = 20
	embedded_ignore_throwspeed_threshold = TRUE
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	origin_tech = "biotech=1;combat=1"
	attack_verb = list("атаковал", "полоснул", "пропилил", "порезал")
	tool_behaviour = TOOL_SAW

/obj/item/circular_saw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/circular_saw/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		no_multi_hit = TRUE, \
	)

/obj/item/circular_saw/laser
	name = "Advanced Laser Circular Saw"
	desc = "A saw with a circular laser disk. This one looks to be the pinnacle of precision energy a surgery tools!"
	icon_state = "saw_laser"
	item_state = "saw_laser"
	origin_tech = "biotech=1;material=1"
	toolspeed = 0.6

/obj/item/circular_saw/augment
	desc = "A small but very fast spinning saw. Edges dulled to prevent accidental cutting inside of the surgeon."
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5

/obj/item/primitive_saw
	name = "primitive circular saw"
	desc = "A primitive surgical saw made from sturdy bone."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "primitive_saw"
	item_state = "primitive_saw"
	hitsound = 'sound/weapons/slice.ogg'
	mob_throw_hit_sound =  'sound/weapons/pierce.ogg'
	flags = CONDUCT
	force = 15.0
	sharp = 1
	throwforce = 9
	throw_speed = 3
	throw_range = 5
	embed_chance = 20
	embedded_ignore_throwspeed_threshold = TRUE
	attack_verb = list("атаковал", "полоснул", "пропилил", "порезал")

/obj/item/primitive_saw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

//misc, formerly from code/defines/weapons.dm
/obj/item/bonegel
	name = "bone gel"
	desc = "A large bottle of fast-setting medical adhesive. There's more than enough inside to last the shift."
	gender = MALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	item_state = "bone-gel"
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 1.0
	origin_tech = "materials=1;biotech=1"
	tool_behaviour = TOOL_BONEGEL

/obj/item/bonegel/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/bonegel/augment
	toolspeed = 0.5

/obj/item/bonegel/primitive_bonegel
	name = "primitive bone gel"
	desc = "A primitive mixture used to heal bones."
	icon_state = "primitive_bonegel"
	item_state = "primitive_bonegel"

/obj/item/FixOVein
	name = "FixOVein"
	desc = "An advanced medical device which uses an array of manipulators to reconnect and repair ruptured blood vessels."
	gender = MALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein"
	item_state = "fixovein"
	throwforce = 1.0
	origin_tech = "materials=1;biotech=1"
	w_class = WEIGHT_CLASS_SMALL
	tool_behaviour = TOOL_FIXOVEIN

/obj/item/FixOVein/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/FixOVein/augment
	toolspeed = 0.5

/obj/item/FixOVein/primitive_FixOVein
	name = "primitive FixOVein"
	desc = "A primitive tool for repairing blood vessels."
	gender = FEMALE
	icon_state = "primitive_fixovein"
	item_state = "primitive_fixovein"

/obj/item/bonesetter
	name = "bone setter"
	desc = "A stainless steel medical clamp used to reconnect fractured bones."
	gender = MALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	item_state = "bone setter"
	force = 8.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("атаковал", "ударил")
	origin_tech = "materials=1;biotech=1"
	tool_behaviour = TOOL_BONESET

/obj/item/bonesetter/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/bonesetter/laser
	name = "Advanced Laser Bone Setter"
	desc = "A bone settler with a laser teeth. This one looks to be the pinnacle of precision energy a surgery tools!"
	icon_state = "bonesetter_laser"
	item_state = "bonesetter_laser"
	toolspeed = 0.4

/obj/item/bonesetter/augment
	toolspeed = 0.5

/obj/item/bonesetter/primitive_bonesetter
	name = "primitive bone setter"
	desc = "A primitive bone instrument for setting bones."
	icon_state = "primitive_bonesetter"
	item_state = "primitive_bonesetter"

/obj/item/surgical_drapes
	name = "surgical drapes"
	desc = "Apearature brand surgical drapes providing privacy and infection control. Built from durathread."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "biotech=1"
	attack_verb = list("шлёпнул")
