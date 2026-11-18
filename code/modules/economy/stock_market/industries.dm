// Industries give companies their names, products and the words used in news about them.

/datum/stock_industry
	/// Shown in the UI.
	var/name = "Industry"
	/// How the field is called in articles: "the %industry% market".
	var/field = "general goods"
	/// Words that may end a company name.
	var/list/company_words = list("Holdings")
	/// First half of product names.
	var/list/product_prefixes = list("Omni")
	/// Second half of product names.
	var/list/product_nouns = list("Thing")
	/// Optional model markers appended to product names.
	var/list/product_models = list("", "", " Mk II", " Pro", " Lite", " X", " 3000", " Plus")
	/// Who buys the products, for article flavour.
	var/list/customers = list("consumers")
	/// How base volatility of companies in this field is scaled.
	var/volatility_mult = 1

/datum/stock_industry/proc/generate_product_name()
	return "[pick(product_prefixes)][pick(product_nouns)][pick(product_models)]"

/datum/stock_industry/medical
	name = "Medical"
	field = "pharmaceutical"
	company_words = list("Pharmaceuticals", "Biomedical", "Health", "Life Sciences", "Clinics")
	product_prefixes = list("Cura", "Vita", "Medi", "Hemo", "Neuro", "Cardio", "Derma", "Immuno")
	product_nouns = list("zine", "pril", "dex", "gel", "patch", "scan", "stim", "cillin")
	customers = list("hospitals", "frontier clinics", "insurance providers", "station medbays")

/datum/stock_industry/mining
	name = "Mining"
	field = "mining"
	company_words = list("Mining", "Minerals", "Ore Works", "Extraction", "Metals")
	product_prefixes = list("Deep", "Core", "Rock", "Vein", "Magma", "Iron", "Quarry")
	product_nouns = list("drill", "borer", "crusher", "smelter", "rig", "charge", "hauler")
	customers = list("asteroid colonies", "ore refineries", "prospectors", "shipyards")
	volatility_mult = 1.2

/datum/stock_industry/plasma
	name = "Energy"
	field = "plasma energy"
	company_words = list("Energy", "Power", "Plasma", "Fuel", "Reactors")
	product_prefixes = list("Flux", "Ion", "Fusion", "Solar", "Plasma", "Volt", "Arc")
	product_nouns = list("cell", "core", "reactor", "array", "condenser", "turbine", "capacitor")
	customers = list("research stations", "colonial grids", "shipping lines", "orbital habitats")
	volatility_mult = 1.4

/datum/stock_industry/engineering
	name = "Engineering"
	field = "robotics and engineering"
	company_words = list("Robotics", "Machines", "Dynamics", "Engineering", "Systems")
	product_prefixes = list("Servo", "Mecha", "Robo", "Gear", "Auto", "Tensor", "Hydra")
	product_nouns = list("arm", "frame", "bot", "drive", "actuator", "welder", "lift")
	customers = list("factories", "construction crews", "station engineers", "shipyards")

/datum/stock_industry/agriculture
	name = "Agriculture"
	field = "food and agriculture"
	company_words = list("Farms", "Foods", "Agro", "Harvest", "Ranches")
	product_prefixes = list("Green", "Sun", "Crisp", "Golden", "Fresh", "Hydro", "Root")
	product_nouns = list("grain", "melon", "snack", "loaf", "pod", "sprout", "yield")
	customers = list("grocery chains", "colony kitchens", "food courts", "galley crews")
	volatility_mult = 0.8

/datum/stock_industry/communications
	name = "Communications"
	field = "communications"
	company_words = list("Communications", "Networks", "Media", "Telecom", "Signal")
	product_prefixes = list("Tele", "Quantum", "Hyper", "Link", "Echo", "Beam", "Relay")
	product_nouns = list("net", "phone", "cast", "relay", "pad", "stream", "chat")
	customers = list("subscribers", "advertisers", "news outlets", "station crews")

/datum/stock_industry/consumer
	name = "Consumer goods"
	field = "consumer goods"
	company_words = list("Stores", "Brands", "Wholesale", "Outlets", "Trading")
	product_prefixes = list("Comfy", "Shiny", "Snug", "Mega", "Lux", "Pocket", "Home")
	product_nouns = list("wear", "box", "kit", "blender", "lamp", "sofa", "bag")
	customers = list("shoppers", "families", "collectors", "retail chains")
	volatility_mult = 0.9

/datum/stock_industry/shipping
	name = "Logistics"
	field = "shipping and logistics"
	company_words = list("Logistics", "Freight", "Shipping", "Lines", "Transit")
	product_prefixes = list("Swift", "Long", "Star", "Bulk", "Express", "Void", "Cargo")
	product_nouns = list("hauler", "route", "dock", "pallet", "liner", "tug", "lane")
	customers = list("merchants", "mining outposts", "station quartermasters", "colonists")
