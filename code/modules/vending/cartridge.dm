/obj/machinery/vending/cart
	name = "PTech"
	desc = "Cartridges for PDA's."
	slogan_list = list(
		"Не заб+удьте закуп+ить п+ару к+артриджей!",
		"К+артриджы и КПК! КПК и к+артриджи!",
		"Как портат+ивно! Как уд+обно!",
	)

	icon_state = "cart_off"
	panel_overlay = "cart_panel"
	screen_overlay = "cart"
	lightmask_overlay = "cart_lightmask"
	broken_overlay = "cart_broken"
	broken_lightmask_overlay = "cart_broken_lightmask"
	deny_overlay = "cart_deny"
	refill_canister = /obj/item/vending_refill/cart
	default_price = PAYCHECK_CREW
	default_premium_price = PAYCHECK_COMMAND

	products = list(
		/obj/item/pda = 10,
		/obj/item/eftpos = 6,
		/obj/item/cartridge/medical = 10,
		/obj/item/cartridge/chemistry = 10,
		/obj/item/cartridge/engineering = 10,
		/obj/item/cartridge/atmos = 10,
		/obj/item/cartridge/janitor = 10,
		/obj/item/cartridge/signal/toxins = 10,
		/obj/item/cartridge/signal = 10,
	)
	contraband = list(
		/obj/item/cartridge/clown = 1,
		/obj/item/cartridge/mime = 1,
	)
