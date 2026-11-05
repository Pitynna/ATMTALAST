/*****************************Money bag********************************/

/obj/item/storage/bag/money
	name = "money bag"
	desc = "A spacious bag made from heavy fabric and decorated with a large dollar sign. Ideal for storing coins or banknotes."

	icon_state = "moneybag"
	item_state = "moneybag"
	force = 10
	resistance_flags = FLAMMABLE
	max_integrity = 100
	storage_slots = 40
	max_combined_w_class = 40
	can_hold = list(/obj/item/coin, /obj/item/stack/spacecash)

/obj/item/storage/bag/money/vault/populate_contents()
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/adamantine(src)
