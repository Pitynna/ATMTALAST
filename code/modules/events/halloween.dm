/datum/event/spooky
	name = "2 SPOOKY! (Halloween)"

/datum/event/spooky/start()
	..()
	for(var/mob/living/carbon/human/human as anything in GLOB.human_list)
		var/obj/item/storage/backpack/backpack = locate() in human.contents
		if(backpack)
			new /obj/item/storage/spooky(backpack)

	for(var/mob/living/simple_animal/pet/dog/corgi/Ian/Ian in GLOB.mob_living_list)
		Ian.place_on_head(new /obj/item/bedsheet(Ian))

/datum/event/spooky/announce(fake)
	GLOB.minor_announcement.announce(
		message = pick("ГРЕМИ КОСТЯМИ!","АТТРАКЦИОН НЕ КОНЧАЕТСЯ!", "ВЫСКАКИВАЕТ СКЕЛЕТ!", "ЖУТКИЕ СТРАШНЫЕ СКЕЛЕТЫ!", "ЧЛЕНЫ ЭКИПАЖА, БЕРЕГИТЕСЬ — ВАС ЖДЁТ ИСПУГ!"),
		new_title = "ЗВОНОК ИДЁТ ИЗ САМОГО ДОМА"
	)

//spooky foods (you can't actually make these when it's not halloween)
/obj/item/reagent_containers/food/snacks/cookie/spookyskull
	name = "skull cookie"
	desc = "Spooky! With the flavor of delicious calcium!"
	icon = 'icons/obj/holiday/halloween_items.dmi'
	icon_state = "skeletoncookie"

/obj/item/reagent_containers/food/snacks/cookie/spookycoffin
	name = "coffin cookie"
	desc = "Spooky! With the flavor of delicious coffee!"
	icon = 'icons/obj/holiday/halloween_items.dmi'
	icon_state = "coffincookie"

/obj/item/storage/spooky
	name = "trick-o-treat bag"
	desc = "A pumpkin-shaped bag full of treats!"
	icon = 'icons/obj/holiday/halloween_items.dmi'
	icon_state = "treatbag"

/obj/item/storage/spooky/populate_contents()
	. = ..()
	var/list/candy_variants = list(
		/obj/item/reagent_containers/food/snacks/cookie/spookyskull,
		/obj/item/reagent_containers/food/snacks/cookie,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/candiedapple,
		/obj/item/organ/internal/brain,
	) + valid_subtypesof(/obj/item/reagent_containers/food/snacks/candy)
	for(var/distrobuteinbag in 0 to 7)
		var/type = pick(candy_variants)
		new type(src)
