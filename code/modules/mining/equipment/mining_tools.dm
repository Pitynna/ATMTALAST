/*****************Pickaxes & Drills & Shovels****************/
/obj/item/pickaxe
	name = "pickaxe"
	desc = "A tool for digging rock and stone. Better get to work."
	gender = FEMALE
	icon_state = "pickaxe"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 15
	throwforce = 10
	item_state = "pickaxe"
	w_class = WEIGHT_CLASS_BULKY
	materials = list(MAT_METAL=2000) //one sheet, but where can you make them?
	origin_tech = "materials=2;engineering=3"
	attack_verb = list("ударил", "уколол", "атаковал")
	var/drill_verb = "picking"
	sharp = 1
	embed_chance = 15
	embedded_ignore_throwspeed_threshold = TRUE
	var/excavation_amount = 100
	usesound = 'sound/effects/picaxe1.ogg'
	toolspeed = 0.8

/obj/item/pickaxe/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		swing_speed_mod = 2, \
		no_multi_hit = TRUE, \
		swing_sound = SFX_CHOP_SWING_LIGHT \
	)

/obj/item/pickaxe/emergency
	name = "emergency disembarkation tool"
	desc = "For extracting yourself from rough landings."
	gender = MALE
	icon_state = "emergency_disembarkation_tool"
	item_state = "emergency_disembarkation_tool"

/obj/item/pickaxe/safety
	name = "safety pickaxe"
	desc = "A pickaxe designed to be only effective at digging rock and ore, very ineffective as a weapon."
	icon_state = "safety_pickaxe"
	item_state = "safety_pickaxe"
	force = 1
	throwforce = 1
	attack_verb = list("неэффективно ударил")

/obj/item/pickaxe/mini
	name = "compact pickaxe"
	desc = "A smaller, compact version of the standard pickaxe."
	icon_state = "compact_pickaxe"
	item_state = "compact_pickaxe"
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL = 1000)

/obj/item/pickaxe/silver
	name = "silver-plated pickaxe"
	desc = "A silver-plated pickaxe that mines slightly faster than standard-issue."
	icon_state = "spickaxe"
	item_state = "spickaxe"
	belt_icon = "silver-plated pickaxe"
	origin_tech = "materials=3;engineering=4"
	toolspeed = 0.4 //mines faster than a normal pickaxe, bought from mining vendor
	force = 17
/obj/item/pickaxe/gold
	name = "gold-tipped pickaxe"
	desc = "A gold-plated pickaxe that mines faster than standard-issue."
	icon_state = "gpickaxe"
	item_state = "gpickaxe"
	belt_icon = "golden pickaxe"
	origin_tech = "materials=4;engineering=4"
	toolspeed = 0.3
	force = 18

/obj/item/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	desc = "A pickaxe with a diamond pick head. Extremely robust at cracking rock walls and digging up dirt."
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	belt_icon = "diamond-tipped pickaxe"
	origin_tech = "materials=5;engineering=4"
	toolspeed = 0.2
	force = 19
/obj/item/pickaxe/drill
	name = "mining drill"
	desc = "An electric mining drill for the especially scrawny."
	icon_state = "handdrill"
	item_state = "jackhammer"
	toolspeed = 0.4 //available from roundstart, faster than a pickaxe.
	hitsound = 'sound/weapons/drill.ogg'
	usesound = 'sound/weapons/drill.ogg'
	origin_tech = "materials=2;powerstorage=2;engineering=3"

/obj/item/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "An integrated electric mining drill."

/obj/item/pickaxe/drill/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	desc = "Yours is the drill that will pierce the heavens!"
	icon_state = "diamonddrill"
	origin_tech = "materials=6;powerstorage=4;engineering=4"
	toolspeed = 0.1
/obj/item/pickaxe/drill/cyborg/diamond //This is the BORG version!
	name = "diamond-tipped cyborg mining drill" //To inherit the NODROP trait, and easier to change borg specific drill mechanics.
	icon_state = "diamonddrill"
	toolspeed = 0.1

/obj/item/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	desc = "Cracks rocks with sonic blasts, and doubles as a demolition power tool for smashing walls."
	icon_state = "jackhammer"
	origin_tech = "materials=6;powerstorage=4;engineering=5;magnets=4"
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	toolspeed = 0.0 //the epitome of powertools, literally instant
	var/wall_toolspeed = 0.1 //instant wall breaking is bad.

/obj/item/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	gender = FEMALE
	icon_state = "shovel"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 8
	throwforce = 4
	item_state = "shovel"
	materials = list(MAT_METAL=50)
	origin_tech = "materials=2;engineering=2"
	attack_verb = list("ударил", "огрел")
	hitsound = 'sound/effects/Shovel_hitting_sound.ogg'
	usesound = 'sound/effects/shovel_dig.ogg'
	toolspeed = 0.8

/obj/item/shovel/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		afterswing_slowdown = 0.15, \
		no_multi_hit = TRUE, \
		swing_sound = SFX_BLUNT_SWING_LIGHT \
	)

/obj/item/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	item_state = "spade"
	belt_icon = "spade"
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL

/obj/item/shovel/spade/wooden
	name = "wooden spade"
	desc = "Маленький инструмент для вскапывания и перемещения земли. Эта модель сделана из древесины."
	icon_state = "wooden_spade"
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	item_state = "small_shovel"

/obj/item/shovel/safety
	name = "safety shovel"
	desc = "A large tool for digging and moving dirt. Was modified with extra safety, making it ineffective as a weapon."
	icon_state = "safety_shovel"
	item_state = "safety_shovel"
	force = 1
	throwforce = 1
	attack_verb = list("неэффективно ударил")
