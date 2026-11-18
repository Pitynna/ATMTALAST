// Console that shows the commodity market. Traders are added to it later.

/obj/machinery/computer/trade_console
	name = "trade console"
	desc = "Shows current prices on the galactic commodity market and what goods are in demand."
	icon_keyboard = "tech_key"
	icon_screen = "supply"
	circuit = /obj/item/circuitboard/trade_console
	light_color = LIGHT_COLOR_BROWN

/obj/machinery/computer/trade_console/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/trade_console/attack_hand(mob/user)
	if(..())
		return TRUE
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/trade_console/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TradeConsole", name)
		ui.open()

/obj/machinery/computer/trade_console/ui_data(mob/user)
	var/list/data = list()
	data["market"] = SStrade.market_ui_data()
	return data

/// Called by SStrade when prices change.
/obj/machinery/computer/trade_console/proc/market_shifted(list/hot)
	if(!is_operational())
		return
	if(length(hot))
		atom_say("Market prices updated. In demand: [english_list(hot)].")
	else
		atom_say("Market prices updated.")
	playsound(src, 'sound/machines/twobeep.ogg', 30, TRUE)

/obj/item/circuitboard/trade_console
	board_name = "Trade Console"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/trade_console
	origin_tech = "programming=2"

/datum/design/trade_console
	name = "Console Board (Trade Console)"
	desc = "Allows for the construction of circuit boards used to build a trade console."
	id = "trade_console"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/trade_console
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)
