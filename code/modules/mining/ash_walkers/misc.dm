//********** Acid Bladder **********//
/obj/item/acid_bladder
	name = "acid bladder"
	desc = "A small acid sac harvested from a sulfuric tramp. Its fragile membrane will probably rupture if thrown at something. Or someone."
	gender = MALE
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "acid_bladder"
	lefthand_file = 'icons/mob/inhands/lavaland/fish_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_items_righthand.dmi'
	item_state = "acid_bladder"
	w_class = WEIGHT_CLASS_TINY

/obj/item/acid_bladder/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_atom))
		var/mob/living/living = hit_atom
		var/datum/reagents/reagents_list = new (50)
		reagents_list.add_reagent("facid", 40)
		living.visible_message(span_danger("Кислотный пузырек разрывается при попадании на [living], разбрызгивая кислоту по [GEND_HIS_HER(living)] телу!"))
		reagents_list.reaction(living, REAGENT_TOUCH)
		reagents_list.clear_reagents()
	else if(iswallturf(hit_atom))
		var/turf/simulated/wall/wall_target = hit_atom
		hit_atom.visible_message(span_danger("Кислотный пузырек разрывается при попадании на стену, медленно её расплавляя!"))
		wall_target.rot()
	else
		var/datum/reagents/reagents_list = new (100)
		reagents_list.add_reagent("facid", 80)
		reagents_list.reaction(hit_atom, REAGENT_TOUCH)
	qdel(src)

//********** Saw Blade **********//
/obj/item/circular_saw_blade
	name = "circular saw blade"
	desc = "A bony growth resembling a circular saw blade, torn from a blind reaper's skull. Can be used to upgrade a bone axe."
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "circular_saw_blade"
	lefthand_file = 'icons/mob/inhands/lavaland/fish_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_items_righthand.dmi'
	item_state = "circular_saw_blade"
	w_class = WEIGHT_CLASS_TINY

/obj/structure/grace_of_lazis
	name = "grace of lazis"
	desc = "An enormous quantity of meat impaled on a bone spear. A symbol of an extraordinarily successful hunting season."
	gender = FEMALE
	icon = 'icons/obj/lavaland/grace_of_lazis.dmi'
	icon_state = "grace_of_lazis4"
	anchored = TRUE
	density = TRUE
	max_integrity = 1000
	var/meat_parts = 40

/obj/structure/grace_of_lazis/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/kitchen/knife))
		return ..()

	to_chat(user, span_notice("Вы начинаете отрезать порцию мяса от постамента."))

	if(!do_after(user, 3 SECONDS, src, max_interact_count = 1))
		return ..()

	meat_parts--
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_notice("Вы отрезаете порцию мяса с постамента."))
	var/obj/item/reagent_containers/food/snacks/lavaland_food/grace_of_lazis/food = new()
	user.put_in_hands(food)
	if(meat_parts == 0)
		visible_message(span_warning("От постамента остаётся лишь одно копье!"))
		new /obj/item/twohanded/spear/bonespear(src.loc)
		qdel(src)
		return ATTACK_CHAIN_PROCEED
	return ATTACK_CHAIN_BLOCKED

/obj/structure/grace_of_lazis/update_icon_state()
	switch(meat_parts)
		if(1 to 10)
			icon_state = "grace_of_lazis1"
		if(11 to 20)
			icon_state = "grace_of_lazis2"
		if(21 to 30)
			icon_state = "grace_of_lazis3"
		if(31 to INFINITY)
			icon_state = "grace_of_lazis4"

//**********Food Scroll**********//
/obj/item/book/manual/lavaland_scroll
	name = "cooking scroll"
	desc = "Parchment made from human skin. Contains information on feeding a hungry tribe."
	gender = MALE
	icon_state = "food_scroll"
	item_state = "food_scroll"
	author = "Шаман голодного племени"
	title = "Руководство по Готовке"
	wiki_title = "Еда_пеплоходцев"

/obj/structure/fluff/ash_statue //used to mark point of interest
	name = "totem"
	desc = "A massive stone pillar bearing the skull of a slain beast. You appear to have entered the ash walkers' hunting grounds."
	icon = 'icons/obj/lavaland/grace_of_lazis.dmi'
	icon_state = "totem_stone"
	density = TRUE
	deconstructible = FALSE
	/// Used in shaman spell. Perfect for finding stuff ic
	var/special_name = "point of interest"

/obj/structure/fluff/ash_statue/Initialize(mapload)
	name = "totem - [special_name]"
	GLOB.lavaland_points_of_interest += src
	. = ..()

/obj/structure/fluff/ash_statue/Destroy(force)
	GLOB.lavaland_points_of_interest -= src
	. = ..()

/obj/structure/ash_totem
	name = "totem"
	desc = "An entirely ordinary totem! Looks cool. You should not be seeing this."
	gender = MALE
	icon = 'icons/obj/lavaland/grace_of_lazis.dmi'
	icon_state = "totem_wooden"
	max_integrity = 1000
	anchored = TRUE
	density = TRUE
	var/applied_dye = null
	var/applied_dye_fluff_name = null

/obj/structure/ash_totem/examine(mob/user)
	. = ..()
	. += span_notice("Эта статуя может использоваться вместо полноценного пеплоходца, если будет построена у ритуальной руны.")

	if(applied_dye && applied_dye_fluff_name) //jeez this is so hard to make it in russian holy fuck
		. += span_notice("На эту статую нанесена [applied_dye_fluff_name] краска.")

/obj/structure/ash_totem/update_overlays()
	. = ..()
	if(applied_dye)
		. += "[icon_state]_[applied_dye]"

/obj/structure/ash_totem/wooden
	name = "wooden totem"
	desc = "A massive statue carved from a single piece of wood. Its design vaguely resembles a human face contorted in terror."

/obj/structure/ash_totem/stone
	name = "stone totem"
	desc = "A massive stone statue bearing a slain animal's skull. The sinews holding the skull in place sway gently in the wind."
	icon_state = "totem_stone"

/obj/structure/ash_totem/bone
	name = "bone totem"
	desc = "A massive statue carved from an enormous bone. You do not know what animal it came from, and you clearly do not want to find out."
	icon_state = "totem_bone"

/obj/structure/chair/stool/wooden
	name = "wooden stool"
	desc = "A wooden stool, comfortable enough to sit on."
	gender = FEMALE
	icon_state = "wooden_stool"
	item_chair = /obj/item/chair/stool/wooden

/obj/item/chair/stool/wooden
	name = "wooden stool"
	desc = "A wooden stool, comfortable enough to hold in your hands."
	gender = FEMALE
	icon_state = "wooden_stool_toppled"
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	item_state = "wooden_stool"
	force = 8
	origin_type = /obj/structure/chair/stool/wooden
	break_chance = 10
