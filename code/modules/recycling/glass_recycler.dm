/// Goonstation's kitchenware recycler, adapted to Paradise's cups and materials.
/obj/machinery/glass_recycler
	name = "glass recycler"
	desc = "Recycles empty glassware, plates, bowls, shards and glass sheets into new dishes and laboratory glassware. Empty containers before inserting them."
	icon = 'icons/goonstation/objects/glass_recycler.dmi'
	icon_state = "synthesizer"
	anchored = TRUE
	density = FALSE
	idle_power_usage = 10
	var/glass_amount = 0
	/// Material units charged for each empty product. Never print pre-filled vessels.
	var/static/list/products = list(
		/obj/item/reagent_containers/cup/glass/drinkingglass = 500,
		/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass = 500,
		/obj/item/reagent_containers/cup/glass/mug = 500,
		/obj/item/trash/plate = 500,
		/obj/item/trash/bowl = 500,
		/obj/item/reagent_containers/cup/beaker = 500,
		/obj/item/reagent_containers/cup/beaker/large = 2500,
		/obj/item/reagent_containers/cup/bottle = 1000,
	)

/obj/machinery/glass_recycler/Initialize(mapload)
	. = ..()
	component_parts = list(
		new /obj/item/circuitboard/glass_recycler(src),
		new /obj/item/stock_parts/matter_bin(src),
		new /obj/item/stock_parts/manipulator(src),
	)
	RefreshParts()

/obj/machinery/glass_recycler/screwdriver_act(mob/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "synthesizer", "synthesizer", tool)

/obj/machinery/glass_recycler/crowbar_act(mob/user, obj/item/tool)
	return default_deconstruction_crowbar(user, tool)

/obj/machinery/glass_recycler/wrench_act(mob/user, obj/item/tool)
	return default_unfasten_wrench(user, tool)

/obj/machinery/glass_recycler/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/glass_recycler/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(recycle_item(item, user))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/// Conservative recovery: a broken vessel never yields more than a basic glass.
/obj/machinery/glass_recycler/proc/recycling_value(obj/item/item)
	if(length(item.contents) || item.reagents?.total_volume || HAS_TRAIT(item, TRAIT_NODROP))
		return 0
	if(item.type == /obj/item/stack/sheet/glass)
		var/obj/item/stack/sheet/glass/sheets = item
		return sheets.amount * MINERAL_MATERIAL_AMOUNT
	if(istype(item, /obj/item/broken_bottle))
		return 500
	if(istype(item, /obj/item/shard))
		if(item.materials?[MAT_GLASS])
			return min(500, item.materials[MAT_GLASS])
		return 0
	if(products[item.type])
		return products[item.type]
	if(!istype(item, /obj/item/reagent_containers/cup))
		return 0
	var/obj/item/reagent_containers/cup/cup = item
	if(!cup.is_glass && !istype(cup, /obj/item/reagent_containers/cup/beaker))
		return 0
	for(var/material in cup.materials)
		if(material != MAT_GLASS && cup.materials[material] > 0)
			return 0
	// Several ordinary drinking bottles have no explicit material metadata.
	if(!length(cup.materials) && cup.is_glass)
		return 500
	return cup.materials?[MAT_GLASS] || 0

/obj/machinery/glass_recycler/proc/recycle_item(obj/item/item, mob/user)
	if((stat & (NOPOWER|BROKEN)) || panel_open)
		return FALSE
	var/value = recycling_value(item)
	if(!value)
		to_chat(user, span_warning("Only empty glassware, dishes, glass shards and plain glass sheets can be recycled. Remove any attached or stored objects first."))
		return FALSE
	if(!user.drop_transfer_item_to_loc(item, src))
		return FALSE
	glass_amount += value
	qdel(item)
	add_fingerprint(user)
	playsound(src, 'sound/effects/glassbr1.ogg', 35, FALSE)
	use_power(200)
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/glass_recycler/proc/create_product(product_id, mob/user)
	if((stat & (NOPOWER|BROKEN)) || panel_open || !isnum(product_id) || product_id != round(product_id) || product_id < 1 || product_id > length(products))
		return FALSE
	var/product_path = products[product_id]
	var/cost = products[product_path]
	if(glass_amount < cost)
		return FALSE
	var/obj/item/product = new product_path(drop_location())
	if(QDELETED(product))
		return FALSE
	glass_amount -= cost
	user?.put_in_hands(product)
	use_power(200)
	playsound(src, 'sound/machines/click.ogg', 30, FALSE)
	return product

/obj/machinery/glass_recycler/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GlassRecycler", name)
		ui.open()

/obj/machinery/glass_recycler/ui_data(mob/user)
	. = list("glass" = glass_amount, "available" = !(stat & (NOPOWER|BROKEN)) && !panel_open)

/obj/machinery/glass_recycler/ui_static_data(mob/user)
	var/list/catalog = list()
	for(var/index in 1 to length(products))
		var/obj/item/product = products[index]
		catalog += list(list("id" = index, "name" = initial(product.name), "cost" = products[product], "icon" = initial(product.icon), "icon_state" = initial(product.icon_state)))
	return list("products" = catalog)

/obj/machinery/glass_recycler/ui_act(action, params)
	if(..())
		return
	if(action == "create")
		return !!create_product(text2num(params["id"]), usr)

/obj/item/circuitboard/glass_recycler
	board_name = "Glass Recycler"
	build_path = /obj/machinery/glass_recycler
	board_type = "machine"
	origin_tech = "programming=1;materials=1"
	req_components = list(/obj/item/stock_parts/matter_bin = 1, /obj/item/stock_parts/manipulator = 1)

/datum/design/glass_recycler
	id = "glass_recycler"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 1, RESEARCH_TREE_MATERIALS = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/glass_recycler
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/supply_packs/organic/glass_recycler
	name = "Glass recycling equipment"
	contains = list(/obj/machinery/glass_recycler)
	cost = 200
	containername = "glass recycling equipment crate"
