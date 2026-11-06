/// Original ATMTA prison toilet, adapted to current interaction chains.
/obj/structure/toilet/parasha
	name = "BIDLOparasha X-1337"
	desc = "A battered prison toilet. Something useful might be hiding below the open lid; a fork could help fish it out."
	icon = 'icons/obj/atmta_parasha.dmi'
	var/next_scavenge = 0
	var/scavenging = FALSE
	var/static/list/loot_table = list(
		/obj/item/pizzabox/meat = 50,
		/obj/item/lighter = 50,
		/obj/item/rag = 50,
		/obj/item/bedsheet = 50,
		/obj/item/coin/silver = 50,
		/obj/item/toy/balloon = 50,
		/obj/item/bikehorn = 50,
		/obj/item/toy/crayon/rainbow = 50,
		/obj/item/clothing/glasses/sunglasses = 50,
		/obj/item/cane = 50,
		/obj/item/clothing/head/collectable/tophat = 50,
		/obj/item/clothing/mask/balaclava = 50,
		/obj/item/storage/belt/champion = 50,
		/obj/item/clothing/head/ushanka = 50,
		/obj/item/clothing/mask/luchador = 50,
		/obj/item/clothing/head/corgi = 50,
		/obj/item/clothing/head/bearpelt = 50,
		/obj/item/toy/balloon/syndicate = 50,
		/obj/item/toy/katana = 50,
		/obj/item/clothing/accessory/petcollar = 50,
		/obj/item/clothing/gloves/color/yellow/fake = 50,
		/obj/item/reagent_containers/food/snacks/donkpocket = 50,
		/obj/item/clothing/head/cueball = 50,
		/obj/item/clothing/head/fedora = 50,
		/obj/item/clothing/head/fez = 50,
		/obj/item/clothing/head/kitty = 50,
		/obj/item/clothing/mask/fakemoustache = 50,
		/obj/item/clothing/mask/pig = 50,
		/obj/item/clothing/mask/horsehead = 50,
		/obj/item/clothing/head/chicken = 50,
		/obj/item/clothing/mask/face/fawkes = 50,
		/obj/item/clothing/head/human_head = 50,
		/obj/item/kitchen/utensil/fork = 30,
		/obj/item/reagent_containers/cup/glass/bottle/rum = 30,
		/obj/item/reagent_containers/cup/glass/bottle/whiskey = 30,
		/obj/item/reagent_containers/cup/soda_cans/cola = 30,
		/obj/item/reagent_containers/cup/soda_cans/grape_juice = 30,
		/obj/item/reagent_containers/cup/soda_cans/sodawater = 30,
		/obj/item/stack/tape_roll = 20,
		/obj/item/hatchet = 20,
		/obj/item/clothing/gloves/color/yellow = 30,
		/obj/item/poster/random_contraband = 30,
		/obj/item/clothing/mask/breath = 20,
		/obj/item/screwdriver = 20,
		/obj/item/clothing/head/welding = 20,
		/obj/item/storage/backpack/clown = 20,
		/obj/item/pda = 13,
		/obj/item/assembly/prox_sensor = 12,
		/obj/item/assembly/timer = 12,
		/obj/item/assembly/igniter = 12,
		/obj/item/flashlight = 12,
		/obj/item/weldingtool/mini = 12,
		/obj/item/stack/sheet/mineral/diamond = 15,
		/obj/item/stack/sheet/metal = 15,
		/obj/item/stack/sheet/rglass = 15,
		/obj/item/stack/rods = 15,
		/obj/item/melee/baton = 14,
		/obj/item/clothing/head/helmet/space = 12,
		/obj/item/tank/internals/emergency_oxygen = 11,
		/obj/item/reagent_containers/food/snacks/monkeycube = 17,
		/obj/item/storage/backpack/satchel_flat = 16,
		/obj/item/storage/box/monkeycubes = 10,
		/obj/item/clothing/head/collectable/petehat = 10,
		/obj/item/radio/off = 6,
		/obj/item/twohanded/garrote/improvised = 6,
		/obj/item/clothing/suit/space = 8,
		/obj/item/grenade/iedcasing = 7,
		/obj/item/clothing/mask/gas = 8,
		/obj/item/grenade/smokebomb = 6,
		/obj/item/dnascrambler = 5,
		/obj/item/implanter/storage = 5,
		/obj/item/storage/pill_bottle/random_drug_bottle = 5,
		/obj/item/card/emag_broken = 3,
		/obj/item/pneumatic_cannon/ghetto = 3,
		/obj/item/clothing/under/contortionist = 3,
		/obj/item/weldingtool/hugetank = 3,
		/obj/item/deck/cards/syndicate = 3,
		/obj/item/melee/baton/security/cattleprod = 3,
		/obj/item/gun/projectile/revolver/doublebarrel/improvised = 2,
		/obj/item/scissors = 2,
		/obj/item/grenade/bananade = 2,
		/obj/item/grenade/plastic/x4 = 1,
		/obj/item/twohanded/spear = 1,
		/obj/item/storage/box/syndie_kit/space = 1,
	)
	var/static/list/loot_amounts = list(/obj/item/stack/sheet/metal = 20, /obj/item/stack/rods = 23)

MAPPING_DIRECTIONAL_HELPERS_CUSTOM(/obj/structure/toilet/parasha, 8, -8, 0, 0)

/obj/structure/toilet/parasha/attackby(obj/item/tool, mob/living/user, params)
	if(!istype(tool, /obj/item/kitchen/utensil/fork))
		return ..()
	if(!open)
		to_chat(user, span_notice("Open the lid first."))
		return ATTACK_CHAIN_BLOCKED_ALL
	if(scavenging || world.time < next_scavenge)
		to_chat(user, span_notice("There is nothing else within reach yet."))
		return ATTACK_CHAIN_BLOCKED_ALL
	scavenging = TRUE
	add_fingerprint(user)
	to_chat(user, span_notice("You start fishing around with the fork..."))
	playsound(src, 'sound/effects/mob_effects/slime_squish.ogg', 50, TRUE)
	if(do_after(user, 3 SECONDS, src) && open && user.is_in_hands(tool))
		spawn_loot(user)
	scavenging = FALSE
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/structure/toilet/parasha/proc/spawn_loot(mob/living/user)
	if(world.time < next_scavenge)
		return
	var/list/available_loot = loot_table.Copy()
	for(var/path in available_loot)
		if(is_legacy_blocked_type(path))
			available_loot -= path
	if(!length(available_loot))
		return
	var/path = pickweight(available_loot)
	var/obj/item/treasure
	if(ispath(path, /obj/item/stack) && loot_amounts[path])
		treasure = new path(drop_location(), loot_amounts[path])
	else
		treasure = new path(drop_location())
	next_scavenge = world.time + 2 MINUTES
	playsound(src, 'sound/effects/slosh.ogg', 50, TRUE)
	if(user)
		to_chat(user, span_notice("You fish [treasure] out of [src]!"))
	return treasure
