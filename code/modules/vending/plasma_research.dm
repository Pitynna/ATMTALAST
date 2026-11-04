/obj/machinery/vending/plasmaresearch
	name = "Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"

	panel_overlay = "generic_panel"
	screen_overlay = "generic"
	lightmask_overlay = "generic_lightmask"
	broken_overlay = "generic_broken"
	broken_lightmask_overlay = "generic_broken_lightmask"
	default_price = PAYCHECK_CREW
	default_premium_price = PAYCHECK_COMMAND

	products = list(
		/obj/item/assembly/prox_sensor = 8,
		/obj/item/assembly/igniter = 8,
		/obj/item/assembly/signaler = 8,
		/obj/item/wirecutters = 1,
		/obj/item/assembly/timer = 8,
	)
	contraband = list(
		/obj/item/flashlight = 5,
		/obj/item/assembly/voice = 3,
		/obj/item/assembly/health = 3,
		/obj/item/assembly/infra = 3,
	)
