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

//********** Wooden Stool **********//
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
