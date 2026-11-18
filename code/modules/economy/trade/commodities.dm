// Goods with a market price that moves on every market shift.
// Traders buy and sell at these prices, and new CentCom supply requests pay more or less with them.

/datum/commodity
	var/name = "commodity"
	var/desc = ""
	/// See COMMODITY_* defines.
	var/category = COMMODITY_MINERALS
	/// What one unit is called: sheet, piece, pill.
	var/unit = "piece"
	/// Item types counted as this commodity, with subtypes.
	var/list/item_types = list()
	/// Subtypes that are a different commodity.
	var/list/exclude_types = list()
	/// Credits per unit when the market is calm.
	var/base_price = 10
	/// How far up the price can go on a shift, as a share of the base price.
	var/upper_fluc = 0.5
	/// How far down the price can go on a shift, as a share of the base price.
	var/lower_fluc = 0.4
	/// Current credits per unit.
	var/price = 10
	/// Bought at a premium this shift.
	var/in_demand = FALSE
	/// Prices of the last shifts.
	var/list/history = list()
	/// Matches CentCom chemical supply requests.
	var/reagent_quests = FALSE
	/// Not shown on the public market. Only some traders deal in it.
	var/hidden = FALSE

	var/list/item_cache
	var/list/exclude_cache

/datum/commodity/New()
	. = ..()
	item_cache = typecacheof(item_types)
	exclude_cache = typecacheof(exclude_types)
	price = base_price
	history += price

/datum/commodity/proc/matches_path(path)
	return is_type_in_typecache(path, item_cache) && !is_type_in_typecache(path, exclude_cache)

/datum/commodity/proc/matches(obj/item/thing)
	return matches_path(thing.type)

/// How many units an item holds, for stacks this is the stack size.
/datum/commodity/proc/units_in(obj/item/thing)
	if(isstack(thing))
		var/obj/item/stack/stack = thing
		return stack.amount
	return 1

/// Price now compared to the calm price.
/datum/commodity/proc/index()
	return price / base_price

/**
 * New price around the base one. Small moves are common, the edges of the range are rare.
 * Prices never build on the previous shift, so they cannot run away.
 */
/datum/commodity/proc/shift(hot_chance)
	var/roll = rand(-900, 900) / 10
	var/strength = 1 - cos(roll)
	var/new_price = base_price * (1 + (roll >= 0 ? upper_fluc : -lower_fluc) * strength)
	in_demand = roll > 0 && prob(hot_chance)
	if(in_demand)
		new_price *= rand(150, 300) / 100
	price = max(1, round(new_price, base_price < 10 ? 0.1 : 1))
	history += price
	if(length(history) > COMMODITY_HISTORY_LENGTH)
		history.Cut(1, 2)

/datum/commodity/proc/ui_entry()
	return list(
		"id" = "[type]",
		"name" = name,
		"desc" = desc,
		"category" = category,
		"unit" = unit,
		"price" = price,
		"base_price" = base_price,
		"in_demand" = in_demand,
		"history" = history,
	)

// MARK: Minerals
/datum/commodity/metal
	name = "Metal"
	unit = "sheet"
	item_types = list(/obj/item/stack/sheet/metal)
	base_price = 5

/datum/commodity/glass
	name = "Glass"
	unit = "sheet"
	item_types = list(/obj/item/stack/sheet/glass)
	base_price = 4

/datum/commodity/plasteel
	name = "Plasteel"
	unit = "sheet"
	item_types = list(/obj/item/stack/sheet/plasteel)
	base_price = 16

/datum/commodity/plasma
	name = "Plasma"
	unit = "sheet"
	item_types = list(/obj/item/stack/sheet/mineral/plasma)
	base_price = 30
	upper_fluc = 0.8
	lower_fluc = 0.5

/datum/commodity/silver
	name = "Silver"
	unit = "sheet"
	item_types = list(/obj/item/stack/sheet/mineral/silver)
	base_price = 22

/datum/commodity/gold
	name = "Gold"
	unit = "sheet"
	item_types = list(/obj/item/stack/sheet/mineral/gold)
	base_price = 30

/datum/commodity/uranium
	name = "Uranium"
	unit = "sheet"
	item_types = list(/obj/item/stack/sheet/mineral/uranium)
	base_price = 28
	upper_fluc = 0.7

/datum/commodity/titanium
	name = "Titanium"
	unit = "sheet"
	item_types = list(/obj/item/stack/sheet/mineral/titanium)
	base_price = 25

/datum/commodity/diamond
	name = "Diamond"
	unit = "sheet"
	item_types = list(/obj/item/stack/sheet/mineral/diamond)
	base_price = 80
	upper_fluc = 0.6

/datum/commodity/bluespace
	name = "Bluespace crystal"
	unit = "crystal"
	item_types = list(/obj/item/stack/sheet/bluespace_crystal, /obj/item/stack/ore/bluespace_crystal)
	base_price = 140
	upper_fluc = 0.8
	lower_fluc = 0.5

/datum/commodity/plastic
	name = "Plastic"
	unit = "sheet"
	item_types = list(/obj/item/stack/sheet/plastic)
	base_price = 8

/datum/commodity/wood
	name = "Wood"
	unit = "plank"
	item_types = list(/obj/item/stack/sheet/wood)
	base_price = 4

// MARK: Ores
/datum/commodity/ore
	name = "Raw ore"
	desc = "Any unrefined ore except diamonds and bluespace."
	category = COMMODITY_ORES
	unit = "ore"
	item_types = list(/obj/item/stack/ore)
	exclude_types = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/bluespace_crystal)
	base_price = 3
	upper_fluc = 0.6

/datum/commodity/ore_diamond
	name = "Diamond ore"
	category = COMMODITY_ORES
	unit = "ore"
	item_types = list(/obj/item/stack/ore/diamond)
	base_price = 55

/datum/commodity/gem
	name = "Rare gems"
	category = COMMODITY_ORES
	unit = "gem"
	item_types = list(/obj/item/gem)
	base_price = 200
	upper_fluc = 0.7
	lower_fluc = 0.5

// MARK: Food
/datum/commodity/produce
	name = "Fresh produce"
	category = COMMODITY_FOOD
	item_types = list(/obj/item/reagent_containers/food/snacks/grown)
	base_price = 6
	upper_fluc = 0.7

/datum/commodity/meat
	name = "Meat"
	category = COMMODITY_FOOD
	unit = "cut"
	item_types = list(/obj/item/reagent_containers/food/snacks/meat)
	base_price = 8

/datum/commodity/meals
	name = "Prepared meals"
	desc = "Anything cooked or baked."
	category = COMMODITY_FOOD
	unit = "dish"
	item_types = list(/obj/item/reagent_containers/food/snacks)
	exclude_types = list(/obj/item/reagent_containers/food/snacks/grown, /obj/item/reagent_containers/food/snacks/meat)
	base_price = 15
	upper_fluc = 0.6

/datum/commodity/seeds
	name = "Seeds"
	category = COMMODITY_FOOD
	unit = "packet"
	item_types = list(/obj/item/seeds)
	base_price = 10

// MARK: Medical
/datum/commodity/medical_stacks
	name = "Bandages and gauze"
	category = COMMODITY_MEDICAL
	unit = "use"
	item_types = list(/obj/item/stack/medical)
	base_price = 4

/datum/commodity/pills
	name = "Pills and patches"
	category = COMMODITY_MEDICAL
	unit = "pill"
	item_types = list(/obj/item/reagent_containers/food/pill)
	base_price = 12
	upper_fluc = 0.6

/datum/commodity/organs
	name = "Organs"
	category = COMMODITY_MEDICAL
	unit = "organ"
	item_types = list(/obj/item/organ/internal)
	base_price = 120
	upper_fluc = 0.7
	lower_fluc = 0.5

/datum/commodity/chemicals
	name = "Chemicals"
	desc = "Reagents ordered by CentCom chemistry requests."
	category = COMMODITY_MEDICAL
	unit = "batch"
	base_price = 50
	upper_fluc = 0.6
	reagent_quests = TRUE

// MARK: Engineering
/datum/commodity/stock_parts
	name = "Machine parts"
	category = COMMODITY_ENGINEERING
	unit = "part"
	item_types = list(/obj/item/stock_parts)
	base_price = 15

/datum/commodity/circuitboards
	name = "Circuit boards"
	category = COMMODITY_ENGINEERING
	unit = "board"
	item_types = list(/obj/item/circuitboard)
	base_price = 40

/datum/commodity/cable
	name = "Cable"
	category = COMMODITY_ENGINEERING
	unit = "length"
	item_types = list(/obj/item/stack/cable_coil)
	base_price = 1

// MARK: Textiles
/datum/commodity/cloth
	name = "Cloth"
	category = COMMODITY_TEXTILES
	unit = "sheet"
	item_types = list(/obj/item/stack/sheet/cloth)
	base_price = 6

/datum/commodity/leather
	name = "Leather and hides"
	category = COMMODITY_TEXTILES
	unit = "sheet"
	item_types = list(/obj/item/stack/sheet/leather, /obj/item/stack/sheet/animalhide)
	base_price = 14

/datum/commodity/durathread
	name = "Durathread"
	category = COMMODITY_TEXTILES
	unit = "sheet"
	item_types = list(/obj/item/stack/sheet/durathread)
	base_price = 25

/datum/commodity/clothing
	name = "Jumpsuits"
	category = COMMODITY_TEXTILES
	unit = "suit"
	item_types = list(/obj/item/clothing/under)
	base_price = 20

// MARK: Science
/datum/commodity/slime_extract
	name = "Slime extracts"
	category = COMMODITY_SCIENCE
	unit = "extract"
	item_types = list(/obj/item/slime_extract)
	base_price = 60
	upper_fluc = 0.7
