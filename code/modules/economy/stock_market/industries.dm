// Industries give companies their names, products and the words used in news about them.

/datum/stock_industry
	/// Shown in the UI.
	var/name = "Industry"
	/// The field in the genitive case, for news in Russian: "на рынке %field%".
	var/field = "товаров общего назначения"
	/// Words that may end a company name.
	var/list/company_words = list("Holdings")
	/// First half of product names.
	var/list/product_prefixes = list("Omni")
	/// Second half of product names.
	var/list/product_nouns = list("Thing")
	/// Optional model markers appended to product names.
	var/list/product_models = list("", "", " Mk II", " Pro", " Lite", " X", " 3000", " Plus")
	/// Who buys the products, for article flavour.
	var/list/customers = list("потребители")
	/// How base volatility of companies in this field is scaled.
	var/volatility_mult = 1
	/// Nyx Daily economic news about these goods moves the field: dearer goods help it, cheaper goods hurt it.
	var/list/news_topics = list()

/datum/stock_industry/proc/generate_product_name()
	return "[pick(product_prefixes)][pick(product_nouns)][pick(product_models)]"

/datum/stock_industry/medical
	news_topics = list(BIOMEDICAL, EMERGENCY)
	name = "Medical"
	field = "фармацевтики"
	company_words = list("Pharmaceuticals", "Biomedical", "Health", "Life Sciences", "Clinics")
	product_prefixes = list("Cura", "Vita", "Medi", "Hemo", "Neuro", "Cardio", "Derma", "Immuno")
	product_nouns = list("zine", "pril", "dex", "gel", "patch", "scan", "stim", "cillin")
	customers = list("больницы", "клиники фронтира", "страховые компании", "медотсеки станций")

/datum/stock_industry/mining
	news_topics = list(MINERALS)
	name = "Mining"
	field = "горнодобычи"
	company_words = list("Mining", "Minerals", "Ore Works", "Extraction", "Metals")
	product_prefixes = list("Deep", "Core", "Rock", "Vein", "Magma", "Iron", "Quarry")
	product_nouns = list("drill", "borer", "crusher", "smelter", "rig", "charge", "hauler")
	customers = list("астероидные колонии", "рудные заводы", "старатели", "верфи")
	volatility_mult = 1.2

/datum/stock_industry/plasma
	news_topics = list(EGAS, ELECTRICAL)
	name = "Energy"
	field = "плазменной энергетики"
	company_words = list("Energy", "Power", "Plasma", "Fuel", "Reactors")
	product_prefixes = list("Flux", "Ion", "Fusion", "Solar", "Plasma", "Volt", "Arc")
	product_nouns = list("cell", "core", "reactor", "array", "condenser", "turbine", "capacitor")
	customers = list("исследовательские станции", "колониальные энергосети", "транспортные линии", "орбитальные поселения")
	volatility_mult = 1.4

/datum/stock_industry/engineering
	news_topics = list(ROBOTICS, MAINTENANCE, ELECTRICAL)
	name = "Engineering"
	field = "робототехники и машиностроения"
	company_words = list("Robotics", "Machines", "Dynamics", "Engineering", "Systems")
	product_prefixes = list("Servo", "Mecha", "Robo", "Gear", "Auto", "Tensor", "Hydra")
	product_nouns = list("arm", "frame", "bot", "drive", "actuator", "welder", "lift")
	customers = list("заводы", "строительные бригады", "станционные инженеры", "верфи")

/datum/stock_industry/agriculture
	news_topics = list(FOOD, ANIMALS)
	name = "Agriculture"
	field = "продовольствия и сельского хозяйства"
	company_words = list("Farms", "Foods", "Agro", "Harvest", "Ranches")
	product_prefixes = list("Green", "Sun", "Crisp", "Golden", "Fresh", "Hydro", "Root")
	product_nouns = list("grain", "melon", "snack", "loaf", "pod", "sprout", "yield")
	customers = list("сети супермаркетов", "колониальные кухни", "фудкорты", "корабельные камбузы")
	volatility_mult = 0.8

/datum/stock_industry/communications
	news_topics = list(ADMINISTRATIVE)
	name = "Communications"
	field = "связи и медиа"
	company_words = list("Communications", "Networks", "Media", "Telecom", "Signal")
	product_prefixes = list("Tele", "Quantum", "Hyper", "Link", "Echo", "Beam", "Relay")
	product_nouns = list("net", "phone", "cast", "relay", "pad", "stream", "chat")
	customers = list("подписчики", "рекламодатели", "новостные агентства", "экипажи станций")

/datum/stock_industry/consumer
	news_topics = list(CLOTHING, GEAR_EVA)
	name = "Consumer goods"
	field = "потребительских товаров"
	company_words = list("Stores", "Brands", "Wholesale", "Outlets", "Trading")
	product_prefixes = list("Comfy", "Shiny", "Snug", "Mega", "Lux", "Pocket", "Home")
	product_nouns = list("wear", "box", "kit", "blender", "lamp", "sofa", "bag")
	customers = list("покупатели", "семьи", "коллекционеры", "розничные сети")
	volatility_mult = 0.9

/datum/stock_industry/shipping
	news_topics = list(SECURITY, EMERGENCY)
	name = "Logistics"
	field = "грузоперевозок и логистики"
	company_words = list("Logistics", "Freight", "Shipping", "Lines", "Transit")
	product_prefixes = list("Swift", "Long", "Star", "Bulk", "Express", "Void", "Cargo")
	product_nouns = list("hauler", "route", "dock", "pallet", "liner", "tug", "lane")
	customers = list("торговцы", "шахтёрские аванпосты", "квартирмейстеры станций", "колонисты")
