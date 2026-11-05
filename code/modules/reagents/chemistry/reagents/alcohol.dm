//ALCOHOL WOO
/datum/reagent/consumable/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	id = "ethanol"
	description = "Хорошо известный алкоголь, имеющий множество воплощений."
	reagent_state = LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" // rgb: 64, 64, 48
	addiction_chance = 3
	addiction_threshold = 150
	minor_addiction = TRUE
	addict_supertype = /datum/reagent/consumable/ethanol
	var/dizzy_adj = 6 SECONDS
	var/alcohol_perc = 1 //percentage of ethanol in a beverage 0.0 - 1.0
	taste_description = "жидкого огня"

/datum/reagent/consumable/ethanol/New()
	addict_supertype = /datum/reagent/consumable/ethanol

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/M)
	M.AdjustDrunk(alcohol_perc STATUS_EFFECT_CONSTANT)
	M.AdjustDizzy(dizzy_adj, bound_upper = 1.5 MINUTES)
	return ..()

/datum/reagent/consumable/ethanol/reaction_obj(obj/O, volume)
	if(istype(O,/obj/item/paper))
		var/obj/item/paper/paperaffected = O
		paperaffected.clearpaper()
		paperaffected.visible_message(span_notice("Раствор плавит чернила на бумаге."))
	if(istype(O,/obj/item/book))
		if(volume >= 5)
			var/obj/item/book/affectedbook = O
			affectedbook.dat = null
			affectedbook.visible_message(span_notice("Раствор плавит чернила в книге."))
		else
			O.visible_message(span_warning("Объём вещества был слишком мал, чтобы нанести какой-либо эффект книге."))

/datum/reagent/consumable/ethanol/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)//Splashing people with ethanol isn't quite as good as fuel.
	if(method == REAGENT_TOUCH)
		M.adjust_fire_stacks(volume / 15)

/datum/reagent/consumable/ethanol/beer
	name = "Beer"
	id = "beer"
	description = "Алкогольный напиток, приготовленный из солода, хмеля, дрожжей и воды."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon ="beerglass"
	drink_name = "Beer glass"
	drink_desc = "A freezing pint of beer."
	taste_description = "пива"

/datum/reagent/consumable/ethanol/cider
	name = "Cider"
	id = "cider"
	description = "Алкогольный напиток, получаемый из яблок."
	color = "#174116"
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "rewriter"
	drink_name = "Cider"
	drink_desc = "A refreshing glass of traditional cider."
	taste_description = "сидра"

/datum/reagent/consumable/ethanol/whiskey
	name = "Whiskey"
	id = "whiskey"
	description = "Превосходный и отлично выдержанный односолодовый виски. Чёрт возьми."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 8 SECONDS
	alcohol_perc = 0.4
	drink_icon = "whiskeyglass"
	drink_name = "Glass of whiskey"
	drink_desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
	taste_description = "виски"

/datum/reagent/consumable/ethanol/specialwhiskey
	name = "Special Blend Whiskey"
	id = "specialwhiskey"
	description = "Как раз в тот момент, когда вы уже думаете, что обычный станционный виски — это хорошо... Это шелковистое, янтарное великолепие приходит и всё портит."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	taste_description = "отличного виски"

/datum/reagent/consumable/ethanol/gin
	name = "Gin"
	id = "gin"
	description = "Это джин. Крепкий алкогольный напиток, приготовленный с использованием самых разных пряностей."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "ginvodkaglass"
	drink_name = "Glass of gin"
	drink_desc = "A crystal clear glass of gin."
	taste_description = "джина"

/datum/reagent/consumable/ethanol/absinthe
	name = "Absinthe"
	id = "absinthe"
	description = "Абсент, очень крепкий напиток для очень крепких парней. Смотрите, чтобы Зелёная Фея не пришла за вами!"
	color = "#33EE00" // rgb: lots, ??, ??
	overdose_threshold = 30
	dizzy_adj = 10 SECONDS
	alcohol_perc = 0.7
	drink_icon = "absintheglass"
	drink_name = "Glass of Absinthe"
	drink_desc = "The green fairy is going to get you now!"
	taste_description = "чёртовой боли"

//copy paste from LSD... shoot me
/datum/reagent/consumable/ethanol/absinthe/on_mob_life(mob/living/M)
	M.AdjustHallucinate(5 SECONDS)
	M.last_hallucinator_log = name
	return ..()

/datum/reagent/consumable/ethanol/absinthe/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return list(0, update_flags)

/datum/reagent/consumable/ethanol/hooch
	name = "Hooch"
	id = "hooch"
	description = "Либо чья-то неудачная попытка приготовить коктейль, либо попытка приготовить алкоголь. В любом случае, вы действительно хотите это выпить?"
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 14 SECONDS
	drink_icon = "glass_brown2"
	drink_name = "Hooch"
	drink_desc = "You've really hit rock bottom now... Your liver packed its bags and left last night."
	taste_description = "чистого смирения"

/datum/reagent/consumable/ethanol/hooch/on_mob_life(mob/living/carbon/M)
	if(M.mind && M.mind.assigned_role == JOB_TITLE_CIVILIAN)
		var/update_flags = STATUS_UPDATE_NONE
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
		return ..() | update_flags

/datum/reagent/consumable/ethanol/rum
	name = "Rum"
	id = "rum"
	description = "Крик подобен грому — дайте людям рому!"
	color = "#664300" // rgb: 102, 67, 0
	overdose_threshold = 30
	alcohol_perc = 0.4
	dizzy_adj = 10 SECONDS
	drink_icon = "rumglass"
	drink_name = "Glass of Rum"
	drink_desc = "A drink fit for a true sailor."
	taste_description = "рома"

/datum/reagent/consumable/ethanol/rum/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/mojito
	name = "Mojito"
	id = "mojito"
	description = "Если он хорош для Космокубы, то он хорош и для вас."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "mojito"
	drink_name = "Glass of Mojito"
	drink_desc = "Fresh from Spesscuba."
	taste_description = "мохито"

/datum/reagent/consumable/ethanol/vodka
	name = "Vodka"
	id = "vodka"
	description = "Алкогольный напиток номер один для славян со всей галактики."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "ginvodkaglass"
	drink_name = "Glass of vodka"
	drink_desc = "The glass contain wodka. Xynta."
	taste_description = "водки"

/datum/reagent/consumable/ethanol/sake
	name = "Sake"
	id = "sake"
	description = "Это сакэ. Как водка, только из риса."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "sake"
	drink_name = "Glass of Sake"
	drink_desc = "A glass of Sake."
	taste_description = "сакэ"

/datum/reagent/consumable/ethanol/tequila
	name = "Tequila"
	id = "tequila"
	description = "Крепкий алкогольный напиток с мягким вкусом, производимый по традиционным мексиканским технологиям. Не хочешь промочить горло, омбре?"
	color = "#A8B0B7" // rgb: 168, 176, 183
	alcohol_perc = 0.4
	drink_icon = "tequilaglass"
	drink_name = "Glass of Tequila"
	drink_desc = "Now all that's missing is the weird colored shades!"
	taste_description = "текилы"

/datum/reagent/consumable/ethanol/vermouth
	name = "Vermouth"
	id = "vermouth"
	description = "Вам вдруг ужасно захотелось мартини..."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "vermouthglass"
	drink_name = "Glass of Vermouth"
	drink_desc = "You wonder why you're even drinking this straight."
	taste_description = "вермута"

/datum/reagent/consumable/ethanol/wine
	name = "Wine"
	id = "wine"
	description = "Алкогольный напиток премиум-класса, приготовленный из дистиллированного виноградного сока."
	color = "#7E4043" // rgb: 126, 64, 67
	dizzy_adj = 4 SECONDS
	alcohol_perc = 0.2
	drink_icon = "wineglass"
	drink_name = "Glass of wine"
	drink_desc = "A very classy looking drink."
	taste_description = "вина"

/datum/reagent/consumable/ethanol/cognac
	name = "Cognac"
	id = "cognac"
	description = "Сладкий крепкий напиток, приготовленный с помощью многочисленных перегонок и многолетней выдержки. Сама элегантность."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 8 SECONDS
	alcohol_perc = 0.4
	drink_icon = "cognacglass"
	drink_name = "Glass of cognac"
	drink_desc = "Damn, you feel like some kind of French aristocrat just by holding this."
	taste_description = "коньяка"

/datum/reagent/consumable/ethanol/suicider //otherwise known as "I want to get so smashed my liver gives out and I die from alcohol poisoning".
	name = "Suicider"
	id = "suicider"
	description = "Невероятно крепкий и мощный сорт сидра."
	color = "#CF3811"
	dizzy_adj = 40 SECONDS
	drink_icon = "suicider"
	drink_name = "Suicider"
	drink_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
	taste_description = "неминуемой смерти"

/datum/reagent/consumable/ethanol/ale
	name = "Ale"
	id = "ale"
	description = "Тёмный алкогольный напиток, приготовленный из ячменного солода и дрожжей."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.1
	drink_icon = "aleglass"
	drink_name = "Ale glass"
	drink_desc = "A freezing pint of delicious Ale."
	taste_description = "эля"

/datum/reagent/consumable/ethanol/thirteenloko
	name = "Thirteen Loko"
	id = "thirteenloko"
	description = "Крепкая смесь кофеина и алкоголя."
	color = "#102000" // rgb: 16, 32, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.3
	heart_rate_increase = 1
	drink_icon = "thirteen_loko_glass"
	drink_name = "Glass of Thirteen Loko"
	drink_desc = "An infamous alcoholic energy drink. While it may not be the strongest offering, all the caffine will keep you wide awake long after you should have passed out."
	taste_description = "смешанного с алкоголем энергетика"

/datum/reagent/consumable/ethanol/thirteenloko/on_mob_life(mob/living/M)
	M.AdjustDrowsy(-14 SECONDS)
	M.AdjustSleeping(-4 SECONDS)
	if(M.bodytemperature > BODYTEMP_NORMAL)
		M.adjust_bodytemperature(-(5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.Jitter(10 SECONDS)
	return ..()

/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////

/datum/reagent/consumable/ethanol/bilk
	name = "Bilk"
	id = "bilk"
	description = "Это пиво, смешанное с молоком. Ух..."
	color = "#895C4C" // rgb: 137, 92, 76
	nutriment_factor = 2 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "glass_brown"
	drink_name = "Glass of bilk"
	drink_desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."
	taste_description = "мива"

/datum/reagent/consumable/ethanol/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	description = "Ядерное оружие никогда не было таким вкусным."
	color = "#666300" // rgb: 102, 99, 0
	alcohol_perc = 0.2
	drink_icon = "atomicbombglass"
	drink_name = "Atomic Bomb"
	drink_desc = "Nanotrasen cannot take legal responsibility for your actions after imbibing."
	taste_description = "длинного, терпкого ожога"

/datum/reagent/consumable/ethanol/threemileisland
	name = "Three Mile Island Iced Tea"
	id = "threemileisland"
	description = "Создан для женщин, достаточно крепок для мужчин."
	color = "#666340" // rgb: 102, 99, 64
	alcohol_perc = 0.2
	drink_icon = "threemileislandglass"
	drink_name = "Three Mile Island Ice Tea"
	drink_desc = "A glass of this is sure to prevent a meltdown."
	taste_description = "текучей волны жара"

/datum/reagent/consumable/ethanol/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	description = "Шнапс с корицей 100%-ой пробы пробы, созданный для алкоголиков-подростков на весенних каникулах."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "ginvodkaglass"
	drink_name = "Glass of goldschlager"
	drink_desc = "100 proof that teen girls will drink anything with gold in it."
	taste_description = "глубокого, пряного тепла"

/datum/reagent/consumable/ethanol/patron
	name = "Patron"
	id = "patron"
	description = "Текила с серебром в составе, которую пьют женщины-алкоголики в клубах."
	color = "#585840" // rgb: 88, 88, 64
	alcohol_perc = 0.4
	drink_icon = "patronglass"
	drink_name = "Glass of Patron"
	drink_desc = "Drinking patron in the bar, with all the subpar ladies."
	taste_description = "подарка"

/datum/reagent/consumable/ethanol/gintonic
	name = "Gin and Tonic"
	id = "gintonic"
	description = "Классический мягкий коктейль, нестареющая классика."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "gintonicglass"
	drink_name = "Gin and Tonic"
	drink_desc = "A mild but still great cocktail. Drink up, like a true Englishman."
	taste_description = "горького лекарства"

/datum/reagent/consumable/ethanol/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	description = "Ром, смешанный с колой. Viva la Revolution!"
	color = "#3E1B00" // rgb: 62, 27, 0
	alcohol_perc = 0.2
	drink_icon = "cubalibreglass"
	drink_name = "Cuba Libre"
	drink_desc = "A classic mix of rum and cola."
	taste_description = "пьянящей свободы"

/datum/reagent/consumable/ethanol/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	description = "Виски, смешанный с колой. Удивительно освежающий."
	color = "#3E1B00" // rgb: 62, 27, 0
	alcohol_perc = 0.3
	drink_icon = "whiskeycolaglass"
	drink_name = "Whiskey Cola"
	drink_desc = "An innocent-looking mixture of cola and Whiskey. Delicious."
	taste_description = "виски с колой"

/datum/reagent/consumable/ethanol/martini
	name = "Classic Martini"
	id = "martini"
	description = "Вермут с джином. Не совсем то, что пил 007, но всё равно вкусно."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "martiniglass"
	drink_name = "Classic Martini"
	drink_desc = "Damn, the bartender even stirred it, not shook it."
	taste_description = "аристократии"

/datum/reagent/consumable/ethanol/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	description = "Водка с джином. Не совсем то, что пил 007, но всё равно вкусно."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "martiniglass"
	drink_name = "Vodka martini"
	drink_desc ="A bastardisation of the classic martini. Still great."
	taste_description = "аристократии и картошки"

/datum/reagent/consumable/ethanol/white_russian
	name = "White Russian"
	id = "whiterussian"
	description = "Но это только твоё мнение, чувак..."
	color = "#A68340" // rgb: 166, 131, 64
	alcohol_perc = 0.3
	drink_icon = "whiterussianglass"
	drink_name = "White Russian"
	drink_desc = "A very nice looking drink. But that's just, like, your opinion, man."
	taste_description = "очень кремового алкоголя"

/datum/reagent/consumable/ethanol/screwdrivercocktail
	name = "Screwdriver"
	id = "screwdrivercocktail"
	description = "Водка, смешанная с апельсиновым соком. Достаточно вкусно."
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.3
	drink_icon = "screwdriverglass"
	drink_name = "Screwdriver"
	drink_desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."
	taste_description = "водки с апельсином"

/datum/reagent/consumable/ethanol/screwdrivercocktail/on_mob_life(mob/living/affected_mob)
	var/update_flags = STATUS_UPDATE_NONE
	var/obj/item/organ/internal/liver/liver = affected_mob.get_organ_slot(INTERNAL_ORGAN_LIVER)
	if(HAS_TRAIT(liver, TRAIT_ENGINEER_METABOLISM))
		ADD_TRAIT(affected_mob, TRAIT_HALT_RADIATION_EFFECTS, UNIQUE_TRAIT_SOURCE(src))
		if(HAS_TRAIT(affected_mob, TRAIT_IRRADIATED))
			update_flags |= affected_mob.adjustToxLoss(-2 * REM, updating_health = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/screwdrivercocktail/on_mob_end_metabolize(mob/living/drinker)
	. = ..()
	REMOVE_TRAIT(drinker, TRAIT_HALT_RADIATION_EFFECTS, UNIQUE_TRAIT_SOURCE(src))

/datum/reagent/consumable/ethanol/booger
	name = "Booger"
	id = "booger"
	description = "Ууу..."
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.2
	drink_icon = "booger"
	drink_name = "Booger"
	drink_desc = "Eww..."
	taste_description = "фруктовой массы"

/datum/reagent/consumable/ethanol/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	description = "Странная, но приятная смесь из водки, томатов и сока лайма. А томатов ли?"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "bloodymaryglass"
	drink_name = "Bloody Mary"
	drink_desc = "Tomato juice, mixed with Vodka and a lil' bit of lemon. Tastes like liquid murder."
	taste_description = "томатов со спиртом"

/datum/reagent/consumable/ethanol/bloody_mary/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle % 20 == 0)
		update_flags |= M.adjustToxLoss(-1, FALSE) //heals 1 tox damage every 20 cycles or (metabolization_rate * 20) units of reagent
	return ..() | update_flags

/datum/reagent/consumable/ethanol/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	description = "Вау, эта штука выглядит нестабильно!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.7 //ouch
	drink_icon = "gargleblasterglass"
	drink_name = "Pan-Galactic Gargle Blaster"
	drink_desc = "Does... does this mean that Arthur and Ford are on the station? Oh joy."
	taste_description = "числа 42"

/datum/reagent/consumable/ethanol/flaming_homer
	name = "Flaming Moe"
	id = "flamingmoe"
	description = "Это, по-видимому, смесь различных алкогольных напитков, смешанных с рецептурным лекарством."
	color = "#58447f" //rgb: 88, 66, 127
	alcohol_perc = 0.5
	drink_icon = "flamingmoeglass"
	drink_name = "Flaming Moe"
	drink_desc = "Happiness is just a Flaming Moe away!"
	taste_description = "карамелизированной выпивки и лекарства"

/datum/reagent/consumable/ethanol/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	description = "Текила с кофейным ликёром. Хех."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "bravebullglass"
	drink_name = "Brave Bull"
	drink_desc = "Tequila and Coffee liquor, brought together in a mouthwatering mixture. Drink up."
	taste_description = "сладкого алкоголя"

/datum/reagent/consumable/ethanol/tequila_sunrise
	name = "Tequila Sunrise"
	id = "tequilasunrise"
	description = "Текила и апельсиновый сок. Как \"Отвёртка\", только по-мексикански."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "tequilasunriseglass"
	drink_name = "Tequila Sunrise"
	drink_desc = "Oh great, now you feel nostalgic about sunrises back on Earth..."
	taste_description = "фруктового алкоголя"

/datum/reagent/consumable/ethanol/toxins_special
	name = "Toxins Special"
	id = "toxinsspecial"
	description = "Эта штука горит! ВЫЗОВИТЕ ЧЁРТОВ ШАТТЛ!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "toxinsspecialglass"
	drink_name = "Toxins Special"
	drink_desc = "Whoah, this thing is on FIRE!"
	taste_description = "огня"

/datum/reagent/consumable/ethanol/toxins_special/on_mob_life(mob/living/M)
	if(M.bodytemperature < (BODYTEMP_NORMAL + 20))
		M.adjust_bodytemperature(15 * TEMPERATURE_DAMAGE_COEFFICIENT)
	return ..()

/datum/reagent/consumable/ethanol/beepsky_smash
	name = "Beepsky Smash"
	id = "beepskysmash"
	description = "Перестаньте пить это и приготовьтесь к ПРАВОСУДИЮ."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "beepskysmashglass"
	drink_name = "Beepsky Smash"
	drink_desc = "Heavy, hot and strong. Just like the Iron fist of THE LAW."
	taste_description = "правосудия"

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_life(mob/living/M)
	M.drop_from_hands()
	return ..()

/datum/reagent/consumable/ethanol/irish_cream
	name = "Irish Cream"
	description = "Крем с добавлением виски — чего ещё ожидать от ирландцев?"
	id = "irishcream"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "irishcreamglass"
	drink_name = "Irish Cream"
	drink_desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
	taste_description = "сливочного алкоголя"

/datum/reagent/consumable/ethanol/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	description = "Крепкая смесь из эля и пива для настоящих трудяг. За Карла!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "manlydorfglass"
	drink_name = "The Manly Dorf"
	drink_desc = "A manly concotion made from Ale and Beer. Intended for true men only."
	taste_description = "мужественности"

/datum/reagent/consumable/ethanol/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	description = "Содержимое ликёрного шкафа, смешанное в восхитительный микс. Предназначен только для женщин-алкоголичек среднего возраста."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "longislandicedteaglass"
	drink_name = "Long Island Iced Tea"
	drink_desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	taste_description = "фруктового алкоголя"

/datum/reagent/consumable/ethanol/moonshine
	name = "Moonshine"
	id = "moonshine"
	description = "Вы действительно достигли дна... ваша печень собрала вещи и ушла вчера вечером."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.8 //yeeehaw
	drink_icon = "glass_clear"
	drink_name = "Moonshine"
	drink_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
	taste_description = "чего-то запрещённого"

/datum/reagent/consumable/ethanol/b52
	name = "B-52"
	id = "b52"
	description = "Кофе, ирландские сливки и коньяк. Взрывная смесь."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "b52glass"
	drink_name = "B-52"
	drink_desc = "Kahlua, Irish Cream, and congac. You will get bombed."
	taste_description = "уничтожения"

/datum/reagent/consumable/ethanol/irishcoffee
	name = "Irish Coffee"
	id = "irishcoffee"
	description = "Кофе и алкоголь. Веселее, чем пить \"Мимозу\" по утрам."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "irishcoffeeglass"
	drink_name = "Irish Coffee"
	drink_desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."
	taste_description = "кофе с алкоголем"

/datum/reagent/consumable/ethanol/margarita
	name = "Margarita"
	id = "margarita"
	description = "Текила с ликёром и лаймом. Так по-мексикански."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "margaritaglass"
	drink_name = "Margarita"
	drink_desc = "On the rocks with salt on the rim. Arriba~!"
	taste_description = "маргариток"

/datum/reagent/consumable/ethanol/black_russian
	name = "Black Russian"
	id = "blackrussian"
	description = "Для тех, кто не переносит лактозу. По-прежнему стильный, как и Белый Русский."
	color = "#360000" // rgb: 54, 0, 0
	alcohol_perc = 0.4
	drink_icon = "blackrussianglass"
	drink_name = "Black Russian"
	drink_desc = "For the lactose-intolerant. Still as classy as a White Russian."
	taste_description = "сладкого алкоголя"

/datum/reagent/consumable/ethanol/manhattan
	name = "Manhattan"
	id = "manhattan"
	description = "Любимый напиток детектива под прикрытием. Он никогда не переносил джин..."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "manhattanglass"
	drink_name = "Manhattan"
	drink_desc = "The Detective's undercover drink of choice. He never could stomach gin..."
	taste_description = "городской суеты"

/datum/reagent/consumable/ethanol/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	description = "Напиток для учёных, размышляющих о том, как взорвать станцию."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "proj_manhattanglass"
	drink_name = "Manhattan Project"
	drink_desc = "A scientist's drink of choice, for thinking how to blow up the station."
	taste_description = "апокалипсиса"

/datum/reagent/consumable/ethanol/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	description = "Ультимативный способ освежиться."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "whiskeysodaglass2"
	drink_name = "Whiskey Soda"
	drink_desc = "Ultimate refreshment."
	taste_description = "посредственности"

/datum/reagent/consumable/ethanol/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	description = "Ультимативный способ освежиться."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "antifreeze"
	drink_name = "Anti-freeze"
	drink_desc = "The ultimate refreshment."
	taste_description = "неправильности жизненного пути"

/datum/reagent/consumable/ethanol/antifreeze/on_mob_life(mob/living/M)
	if(M.bodytemperature < (BODYTEMP_NORMAL + 20))
		M.adjust_bodytemperature(20 * TEMPERATURE_DAMAGE_COEFFICIENT)
	return ..()

/datum/reagent/consumable/ethanol/barefoot
	name = "Barefoot"
	id = "barefoot"
	description = "Босоногость и беременность."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "b&p"
	drink_name = "Barefoot"
	drink_desc = "Barefoot and pregnant."
	taste_description = "беременности"

/datum/reagent/consumable/ethanol/snowwhite
	name = "Snow White"
	id = "snowwhite"
	description = "Холодный напиток. Реально холодный."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "snowwhite"
	drink_name = "Snow White"
	drink_desc = "A cold refreshment."
	taste_description = "отравленного яблока"

/datum/reagent/consumable/ethanol/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	description = "ААААА!!!"
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 20 SECONDS
	alcohol_perc = 0.4
	drink_icon = "demonsblood"
	drink_name = "Demons Blood"
	drink_desc = "Just looking at this thing makes the hair at the back of your neck stand up."
	taste_description = "зла"

/datum/reagent/consumable/ethanol/vodkatonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	description = "Когда \"Джин и тоник\" не достаточно славянский."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 8 SECONDS
	alcohol_perc = 0.3
	drink_icon = "vodkatonicglass"
	drink_name = "Vodka and Tonic"
	drink_desc = "For when a gin and tonic isn't russian enough."
	taste_description = "горького лекарства"

/datum/reagent/consumable/ethanol/ginfizz
	name = "Gin Fizz"
	id = "ginfizz"
	description = "Освежающе лимонный, восхитительно сухой."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 8 SECONDS
	alcohol_perc = 0.4
	drink_icon = "ginfizzglass"
	drink_name = "Gin Fizz"
	drink_desc = "Refreshingly lemony, deliciously dry."
	taste_description = "шипучего алкоголя"

/datum/reagent/consumable/ethanol/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	description = "Тропический коктейль."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "bahama_mama"
	drink_name = "Bahama Mama"
	drink_desc = "Tropic cocktail."
	taste_description = "фруктов и алкоголя"

/datum/reagent/consumable/ethanol/singulo
	name = "Singulo"
	id = "singulo"
	description = "Блю-спейс коктейль, вау!"
	color = "#2E6671" // rgb: 46, 102, 113
	dizzy_adj = 30 SECONDS
	alcohol_perc = 0.7
	drink_icon = "singulo"
	drink_name = "Singulo"
	drink_desc = "The edge of eternity, contained in a glass."
	taste_description = "бесконечности"

/datum/reagent/consumable/ethanol/sbiten
	name = "Sbiten"
	id = "sbiten"
	description = "Пряная водка! Горячо!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "sbitenglass"
	drink_name = "Sbiten"
	drink_desc = "A spicy mix of Wine and Spice. Very hot."
	taste_description = "приятно согревающего алкоголя"

/datum/reagent/consumable/ethanol/sbiten/on_mob_life(mob/living/M)
	if(M.bodytemperature < (BODYTEMP_NORMAL + 50))
		M.adjust_bodytemperature(50 * TEMPERATURE_DAMAGE_COEFFICIENT)
	return ..()

/datum/reagent/consumable/ethanol/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	description = "Время страшилок!"
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.3
	drink_icon = "devilskiss"
	drink_name = "Devils Kiss"
	drink_desc = "Creepy time!"
	taste_description = "озорства"

/datum/reagent/consumable/ethanol/red_mead
	name = "Red Mead"
	id = "red_mead"
	description = "Напиток Настоящих Викингов! Даже несмотря на странный красный цвет."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "red_meadglass"
	drink_name = "Red Mead"
	drink_desc = "A True Vikings Beverage, though its color is strange."
	taste_description = "крови и мёда"

/datum/reagent/consumable/ethanol/mead
	name = "Mead"
	id = "mead"
	description = "Напиток Настоящих Викингов!"
	color = "#664300" // rgb: 102, 67, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "meadglass"
	drink_name = "Mead"
	drink_desc = "A Vikings Beverage, though a cheap one."
	taste_description = "мёда"

/datum/reagent/consumable/ethanol/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	description = "Пиво, настолько ледяное, что воздух вокруг него замерзает."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "iced_beerglass"
	drink_name = "Iced Beer"
	drink_desc = "A beer so frosty, the air around it freezes."
	taste_description = "холодного пива"

/datum/reagent/consumable/ethanol/iced_beer/on_mob_life(mob/living/M)
	if(M.bodytemperature > (BODYTEMP_NORMAL - 40))
		M.adjust_bodytemperature(-(20 * TEMPERATURE_DAMAGE_COEFFICIENT))
	return ..()

/datum/reagent/consumable/ethanol/grog
	name = "Grog"
	id = "grog"
	description = "Разведённый водом ром. Просто, но со вкусом."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "grogglass"
	drink_name = "Grog"
	drink_desc = "Rum that has been watered down."
	taste_description = "сильно разбавленного рома"

/datum/reagent/consumable/ethanol/aloe
	name = "Aloe"
	id = "aloe"
	description = "Хорошо, очень хорошо."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "aloe"
	drink_name = "Aloe"
	drink_desc = "Very, very, very good."
	taste_description = "здоровой кожи"

/datum/reagent/consumable/ethanol/andalusia
	name = "Andalusia"
	id = "andalusia"
	description = "Хороший напиток со странным названием."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "andalusia"
	drink_name = "Andalusia"
	drink_desc = "A nice, strange named drink."
	taste_description = "сладкого алкоголя"

/datum/reagent/consumable/ethanol/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	description = "Напиток, приготовленный из ваших союзников."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "alliescocktail"
	drink_name = "Allies cocktail"
	drink_desc = "A drink made from your allies."
	taste_description = "победы"

/datum/reagent/consumable/ethanol/acid_spit
	name = "Acid Spit"
	id = "acidspit"
	description = "Сделан из живых пришельцев."
	color = "#365000" // rgb: 54, 80, 0
	alcohol_perc = 0.3
	drink_icon = "acidspitglass"
	drink_name = "Acid Spit"
	drink_desc = "A drink from Nanotrasen. Made from live aliens."
	taste_description = "ЖГУЧЕЙ БОЛИ"

/datum/reagent/consumable/ethanol/acid_spit/reaction_mob(mob/living/M, method, volume)
	. = ..()
	if(prob(50))
		M.emote("scream")

/datum/reagent/consumable/ethanol/amasec
	name = "Amasec"
	id = "amasec"
	description = "Император одобряет."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "amasecglass"
	drink_name = "Amasec"
	drink_desc = "Always handy before COMBAT!!!"
	taste_description = "странного алкоголя"

/datum/reagent/consumable/ethanol/neurotoxin
	name = "Neuro-toxin"
	id = "neurotoxin"
	description = "Сильный нейротоксин, который вводит выпившего в состояние, подобное смерти."
	color = "#2E2E61" // rgb: 46, 46, 97
	dizzy_adj = 12 SECONDS
	alcohol_perc = 0.7
	heart_rate_decrease = 1
	drink_icon = "neurotoxinglass"
	drink_name = "Neurotoxin"
	drink_desc = "A drink that is guaranteed to knock you silly."
	taste_description = "удара по мозгам"

/datum/reagent/consumable/ethanol/neurotoxin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle >= 13)
		M.Weaken(6 SECONDS)
	if(current_cycle >= 55)
		M.Druggy(110 SECONDS)
	if(current_cycle >= 200)
		update_flags |= M.adjustToxLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/hippies_delight
	name = "Hippie's Delight"
	id = "hippiesdelight"
	description = "Ты просто не понимаешь, чуваааак."
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	drink_icon = "hippiesdelightglass"
	drink_name = "Hippie's Delight"
	drink_desc = "A drink enjoyed by people during the 1960's."
	taste_description = "цветов"

/datum/reagent/consumable/ethanol/hippies_delight/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Druggy(100 SECONDS)
	switch(current_cycle)
		if(1 to 5)
			M.Stuttering(2 SECONDS)
			M.Dizzy(20 SECONDS)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Stuttering(2 SECONDS)
			M.Jitter(40 SECONDS)
			M.Dizzy(40 SECONDS)
			M.Druggy(90 SECONDS)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if(10 to INFINITY)
			M.Stuttering(2 SECONDS)
			M.Jitter(80 SECONDS)
			M.Dizzy(80 SECONDS)
			M.Druggy(120 SECONDS)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
	return ..() | update_flags

/datum/reagent/consumable/ethanol/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	description = "Генокрадов не существует, это ведь даже дети знают."
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.7
	dizzy_adj = 10 SECONDS
	drink_icon = "changelingsting"
	drink_name = "Changeling Sting"
	drink_desc = "A stingy drink."
	taste_description = "лёгкого укола"

/datum/reagent/consumable/ethanol/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	description = "Ммм, на вкус как шоколадный торт..."
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.3
	dizzy_adj = 10 SECONDS
	drink_icon = "irishcarbomb"
	drink_name = "Irish Car Bomb"
	drink_desc = "An irish car bomb."
	taste_description = "проблем"

/datum/reagent/consumable/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	description = "Пить аккуратно."
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.2
	drink_icon = "syndicatebomb"
	drink_name = "Syndicate Bomb"
	drink_desc = "A syndicate bomb."
	taste_description = "предложения о работе"

/datum/reagent/consumable/ethanol/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	description = "Сюрприз в том, что он зелёный!"
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.2
	drink_icon = "erikasurprise"
	name = "Erika Surprise"
	drink_desc = "The surprise is, it's green!"
	taste_description = "разочарования"

/datum/reagent/consumable/ethanol/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	description = "Только для опытных. Стоп, это песок там в стакане?"
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.5
	dizzy_adj = 20 SECONDS
	drink_icon = "driestmartiniglass"
	drink_name = "Driest Martini"
	drink_desc = "Only for the experienced. You think you see sand floating in the glass."
	taste_description = "пыли и пепла"

/datum/reagent/consumable/ethanol/driestmartini/on_mob_life(mob/living/M)
	if(current_cycle >= 55 && current_cycle < 115)
		M.AdjustStuttering(20 SECONDS)
	return ..()

/datum/reagent/consumable/ethanol/kahlua
	name = "Kahlua"
	id = "kahlua"
	description = "Широко известный мексиканский ликёр со вкусом кофе. Производится с 1936 года!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "kahluaglass"
	drink_name = "Glass of RR coffee Liquor"
	drink_desc = "DAMN, THIS THING LOOKS ROBUST!"
	taste_description = "кофе и алкоголя"

/datum/reagent/consumable/ethanol/kahlua/on_mob_life(mob/living/M)
	M.AdjustDizzy(-10 SECONDS)
	M.AdjustDrowsy(-6 SECONDS)
	M.AdjustSleeping(-4 SECONDS)
	M.Jitter(10 SECONDS)
	return ..()

/datum/reagent/ginsonic
	name = "Gin and sonic"
	id = "ginsonic"
	description = "GOTTA GET CRUNK FAST BUT LIQUOR TOO SLOW"
	reagent_state = LIQUID
	color = "#1111CF"
	drink_icon = "ginsonic"
	drink_name = "Gin and Sonic"
	drink_desc = "An extremely high amperage drink. Absolutely not for the true Englishman."
	taste_description = "СКОРОСТИ"

/datum/reagent/ginsonic/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-10 SECONDS)
	if(prob(25))
		M.AdjustParalysis(-2 SECONDS)
		M.AdjustStunned(-2 SECONDS)
		M.AdjustWeakened(-2 SECONDS)
	if(prob(8))
		M.reagents.add_reagent("methamphetamine",1.2)
		var/sonic_message = pick("НАДО! ЕЩЁ! БЫСТРЕЕ!!!", "БЫСТРЕЕ, БЫСТРЕЕ, ЕЩЁ БЫСТРЕЕ!!!", "ДА, ДЕТКА!!!", "БОДРИТ!!!", "ПОШЁЛ, ПОШЁЛ!!!", "На старт... МАРШ!!!", "ПОНЕСЛАСЬ!!!")
		if(prob(50))
			M.say("[sonic_message]")
		else
			to_chat(M, span_notice("[sonic_message]"))
	return ..() | update_flags

/datum/reagent/consumable/ethanol/applejack
	name = "Applejack"
	id = "applejack"
	description = "Высококонцентрированный алкогольный напиток, изготовленный путём многократного замораживания сидра и удаления льда."
	color = "#997A00"
	alcohol_perc = 0.4
	drink_icon = "cognacglass"
	drink_name = "Glass of applejack"
	drink_desc = "When cider isn't strong enough, you gotta jack it."
	taste_description = "крепкого сидра"

/datum/reagent/consumable/ethanol/jackrose
	name = "Jack Rose"
	id = "jackrose"
	description = "Классический коктейль, который вышел из моды, но не из вкуса."
	color = "#664300"
	alcohol_perc = 0.4
	drink_icon = "patronglass"
	drink_name = "Jack Rose"
	drink_desc = "Drinking this makes you feel like you belong in a luxury hotel bar during the 1920s."
	taste_description = "стиля"

/datum/reagent/consumable/ethanol/drunkenblumpkin
	name = "Drunken Blumpkin"
	id = "drunkenblumpkin"
	description = "Странная смесь виски и тыквенного сока."
	color = "#1EA0FF" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "drunkenblumpkin"
	drink_name = "Drunken Blumpkin"
	drink_desc = "A drink for the drunks."
	taste_description = "странности"

/datum/reagent/consumable/ethanol/eggnog
	name = "Eggnog"
	id = "eggnog"
	description = "Для наслаждения самым чудесным временем года."
	color = "#fcfdc6" // rgb: 252, 253, 198
	nutriment_factor = 2 * REAGENTS_METABOLISM
	alcohol_perc = 0.1
	drink_icon = "glass_yellow"
	drink_name = "Eggnog"
	drink_desc = "For enjoying the most wonderful time of the year."
	taste_description = "рождества"

/datum/reagent/consumable/ethanol/dragons_breath //inaccessible to players, but here for admin shennanigans
	name = "Dragon's Breath"
	id = "dragonsbreath"
	description = "Производство этого напитка вероятно, нарушает Женевскую конвенцию."
	color = "#DC0000"
	can_synth = FALSE
	taste_description = span_userdanger_alt("ЖИДКОЙ БЛЯДЬ СМЕРТИ СУКА ПИЗДЕЦ НАХУЙ КАКОГО ХУЯ")

/datum/reagent/consumable/ethanol/dragons_breath/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST && prob(20))
		if(M.on_fire)
			M.adjust_fire_stacks(6)

/datum/reagent/consumable/ethanol/dragons_breath/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(M.reagents.has_reagent("milk"))
		to_chat(M, span_notice("Молоко останавливает горение. Фух."))
		M.reagents.del_reagent("milk")
		M.reagents.del_reagent("dragonsbreath")
		return
	if(prob(8))
		to_chat(M, span_userdanger("Господи! ГОСПОДИ БЛЯДЬ!!!"))
	if(prob(50))
		to_chat(M, span_danger("Ваша глотка пылает! Буквально!"))
		M.emote(pick("scream","cry","choke","gasp"))
		M.Stun(2 SECONDS)
	if(prob(8))
		to_chat(M, span_danger("За что?! ЗА ЧТО?!"))
	if(prob(8))
		to_chat(M, span_danger("ААААААААА!!!"))
	if(prob(2 * volume))
		to_chat(M, span_userdanger("ГОСПОДИ БОЖЕ БЛЯДЬ НЕТ НЕТ НЕТ!!!"))
		if(M.on_fire)
			M.adjust_fire_stacks(20)
		if(prob(50))
			to_chat(M, span_userdanger("КАК ЖЖЁТСЯ, КАК ЖЕ ОНО ЖЖЁТСЯ!!!"))
			M.visible_message( span_danger("[M] сгорел[GEND_A_O_I(M)] заживо!"))
			M.dust()
			return
	return ..() | update_flags

// ROBOT ALCOHOL PAST THIS POINT
// WOOO!

/datum/reagent/consumable/ethanol/synthanol
	name = "Synthanol"
	id = "synthanol"
	description = "Текучая жидкость с токопроводящими свойствами. Её воздействие на синтетику аналогично воздействию спирта на органику."
	color = "#1BB1FF"
	process_flags = ORGANIC | SYNTHETIC
	alcohol_perc = 0.5
	drink_icon = "synthanolglass"
	drink_name = "Glass of Synthanol"
	drink_desc = "The equivalent of alcohol for synthetic crewmembers. They'd find it awful if they had tastebuds too."
	taste_description = "машинного масла"

/datum/reagent/consumable/ethanol/synthanol/on_mob_life(mob/living/M)
	metabolization_rate = REAGENTS_METABOLISM
	if(!(M.dna.species.reagent_tag & SYNTHETIC))
		metabolization_rate += 9 * REAGENTS_METABOLISM //gets removed from organics very fast
		if(prob(25))
			metabolization_rate += 40 * REAGENTS_METABOLISM
			M.fakevomit()
	return ..()

/datum/reagent/consumable/ethanol/synthanol/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(M.dna.species.reagent_tag & SYNTHETIC)
		return
	if(method == REAGENT_INGEST)
		to_chat(M, pick(span_danger("Это отвратительно!"), span_danger("Фу!")))

/datum/reagent/consumable/ethanol/synthanol/robottears
	name = "Robot Tears"
	id = "robottears"
	description = "Маслянистая субстанция, которую КПБ технически могут считать \"напитком\"."
	color = "#363636"
	alcohol_perc = 0.25
	drink_icon = "robottearsglass"
	drink_name = "Glass of Robot Tears"
	drink_desc = "No robots were hurt in the making of this drink."
	taste_description = "экзистенциальных вопросов"

/datum/reagent/consumable/ethanol/synthanol/trinary
	name = "Trinary"
	id = "trinary"
	description = "Фруктовый напиток, предназначенный только для синтетиков, как бы это ни звучало."
	color = "#adb21f"
	alcohol_perc = 0.2
	drink_icon = "trinaryglass"
	drink_name = "Glass of Trinary"
	drink_desc = "Colorful drink made for synthetic crewmembers. It doesn't seem like it would taste well."
	taste_description = "машинной логики"

/datum/reagent/consumable/ethanol/synthanol/servo
	name = "Servo"
	id = "servo"
	description = "Напиток, содержащий некоторые органические ингредиенты, но предназначенный только для синтетиков."
	color = "#5b3210"
	alcohol_perc = 0.25
	drink_icon = "servoglass"
	drink_name = "Glass of Servo"
	drink_desc = "Chocolate - based drink made for IPCs. Not sure if anyone's actually tried out the recipe."
	taste_description = "машинного масла и шоколада"

/datum/reagent/consumable/ethanol/synthanol/uplink
	name = "Uplink"
	id = "uplink"
	description = "Сильнодействующая смесь алкоголя и синтанола. Действует только на синтетиков."
	color = "#e7ae04"
	alcohol_perc = 0.15
	drink_icon = "uplinkglass"
	drink_name = "Glass of Uplink"
	drink_desc = "An exquisite mix of the finest liquoirs and synthanol. Meant only for synthetics."
	taste_description = "графического интерфейса на Visual Basic"

/datum/reagent/consumable/ethanol/synthanol/synthnsoda
	name = "Synth 'n Soda"
	id = "synthnsoda"
	description = "Классический напиток, адаптированный под вкусы синтетиков."
	color = "#7204e7"
	alcohol_perc = 0.25
	drink_icon = "synthnsodaglass"
	drink_name = "Glass of Synth 'n Soda"
	drink_desc = "Classic drink altered to fit the tastes of a robot. Bad idea to drink if you're made of carbon."
	taste_description = "шипучего моторного масла"

/datum/reagent/consumable/ethanol/synthanol/synthignon
	name = "Synthignon"
	id = "synthignon"
	description = "Кто-то смешал вино и алкоголь для роботов. Надеюсь, он горд собой."
	color = "#d004e7"
	alcohol_perc = 0.25
	drink_icon = "synthignonglass"
	drink_name = "Glass of Synthignon"
	drink_desc = "Someone mixed good wine and robot booze. Romantic, but atrocious."
	taste_description = "модного моторного масла"

/datum/reagent/consumable/ethanol/fruit_wine
	name = "Fruit Wine"
	id = "fruit_wine"
	description = "Вино, изготовленное из растений."
	color = "#FFFFFF"
	alcohol_perc = 0.35
	taste_description = "плохого кода"
	can_synth = FALSE
	var/list/names = list("нулевого фрукта" = 1) //Names of the fruits used. Associative list where name is key, value is the percentage of that fruit.
	var/list/tastes = list("плохого кода" = 1) //List of tastes. See above.

/datum/reagent/consumable/ethanol/fruit_wine/on_new(list/data)
	names = data["names"]
	tastes = data["tastes"]
	alcohol_perc = data["alcohol_perc"]
	color = data["color"]
	generate_data_info(data)

/datum/reagent/consumable/ethanol/fruit_wine/on_merge(list/data, amount)
	var/diff = (amount/volume)
	if(diff < 1)
		color = BlendRGB(color, data["color"], diff/2) //The percentage difference over two, so that they take average if equal.
	else
		color = BlendRGB(color, data["color"], (1/diff)/2) //Adjust so it's always blending properly.
	var/oldvolume = volume-amount

	var/list/cachednames = data["names"]
	for(var/name in names | cachednames)
		names[name] = ((names[name] * oldvolume) + (cachednames[name] * amount)) / volume

	var/list/cachedtastes = data["tastes"]
	for(var/taste in tastes | cachedtastes)
		tastes[taste] = ((tastes[taste] * oldvolume) + (cachedtastes[taste] * amount)) / volume

	alcohol_perc *= oldvolume
	var/newzepwr = data["alcohol_perc"] * amount
	alcohol_perc += newzepwr
	alcohol_perc /= volume //Blending alcohol percentage to volume.
	generate_data_info(data)

/datum/reagent/consumable/ethanol/fruit_wine/proc/generate_data_info(list/data)
	var/list/primary_tastes = list()
	var/list/secondary_tastes = list()
	drink_name = "[name]"
	drink_desc = description
	for(var/taste in tastes)
		switch(tastes[taste])
			if(0.3 to INFINITY)
				primary_tastes += taste
			if(0.15 to 0.3)
				secondary_tastes += taste

	var/minimum_name_percent = 0.35
	name = ""
	var/list/names_in_order = sortTim(names, GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)
	var/named = FALSE
	for(var/fruit_name in names)
		if(names[fruit_name] >= minimum_name_percent)
			name += "[fruit_name] "
			named = TRUE
	if(named)
		name += "вино"
	else
		name = "Смешанное [names_in_order[1]] вино"

	var/alcohol_description
	switch(alcohol_perc)
		if(1.2 to INFINITY)
			alcohol_description = "самоубийственно сильного"
		if(0.9 to 1.2)
			alcohol_description = "очень крепкого"
		if(0.7 to 0.9)
			alcohol_description = "крепкого"
		if(0.4 to 0.7)
			alcohol_description = "насыщенного"
		if(0.2 to 0.4)
			alcohol_description = "мягкого"
		if(0 to 0.2)
			alcohol_description = "сладкого"
		else
			alcohol_description = "водянистого" //How the hell did you get negative boozepwr?

	var/list/fruits = list()
	if(length(names_in_order) <= 3)
		fruits = names_in_order
	else
		for(var/i in 1 to 3)
			fruits += names_in_order[i]
		fruits += "других растений"
	var/fruit_list = russian_list(fruits)
	description = "Образец [alcohol_description] вина, приготовленного из [fruit_list]."

	var/flavor = ""
	if(!length(primary_tastes))
		primary_tastes = list("[alcohol_description] алкоголя")
	flavor += russian_list(primary_tastes)
	if(length(secondary_tastes))
		flavor += ", с лёгким привкусом "
		flavor += russian_list(secondary_tastes)
	taste_description = flavor
	if(holder.my_atom)
		holder.my_atom.on_reagent_change()

/datum/reagent/consumable/ethanol/bacchus_blessing //An EXTREMELY powerful drink. Smashed in seconds, dead in minutes.
	name = "Bacchus' Blessing"
	id = "bacchus_blessing"
	description = "Неидентифицируемая смесь. Неизмеримо высокое содержание алкоголя."
	color = rgb(51, 19, 3) //Sickly brown
	dizzy_adj = 42 SECONDS
	alcohol_perc = 3 //I warned you
	drink_icon = "bacchusblessing"
	drink_name = "Bacchus' Blessing"
	drink_desc = "You didn't think it was possible for a liquid to be so utterly revolting. Are you sure about this...?"
	taste_description = "стены кирпичей"

/datum/reagent/consumable/ethanol/fernet
	name = "Fernet"
	id = "fernet"
	description = "Невероятно горький травяной ликёр, используемый в качестве дижестива."
	color = "#1B2E24" // rgb: 27, 46, 36
	alcohol_perc = 0.5
	drink_icon = "fernetpuro"
	drink_name = "glass of pure fernet"
	drink_desc = "Why are you drinking this pure?"
	taste_description = "сильной горечи"
	var/remove_nutrition = 2

/datum/reagent/consumable/ethanol/fernet/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!M.nutrition)
		switch(rand(1, 3))
			if(1)
				to_chat(M, span_warning("Вы чувствуете себя голодным..."))
			if(2)
				update_flags |= M.adjustToxLoss(1, FALSE)
				to_chat(M, span_warning("Ваш желудок болезненно урчит!"))
			else
				pass()
	else
		if(prob(60))
			M.adjust_nutrition(-remove_nutrition)
			M.overeatduration = 0
	return ..() | update_flags

/datum/reagent/consumable/ethanol/fernet/fernet_cola
	name = "Fernet Cola"
	id = "fernet_cola"
	description = "Очень популярный и горьковато-сладкий дижестив, идеальный после плотного обеда. По традиции, его лучше всего подавать в откупоренной бутылке из-под колы."
	color = "#390600" // rgb: 57, 6, 0
	alcohol_perc = 0.2
	drink_icon = "fernetcola"
	drink_name = "glass of fernet cola"
	drink_desc = "A sawed-off cola bottle filled with Fernet Cola. You can hear cuarteto music coming from the inside."
	taste_description = "рая низкого класса"
	remove_nutrition = 1

/datum/reagent/consumable/ethanol/rainbow_sky
	name = "Rainbow Sky"
	id = "rainbow_sky"
	description = "Напиток, переливающийся всеми цветами радуги с примесями космоса."
	color = "#ffffff"
	dizzy_adj = 20 SECONDS
	alcohol_perc = 1.5
	drink_icon = "rainbow_sky"
	drink_name = "Rainbow Sky"
	drink_desc = "A drink shimmering with every color of the rainbow, with a hint of space."
	taste_description = "радуги"

/datum/reagent/consumable/ethanol/rainbow_sky/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
	update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	M.Druggy(30 SECONDS)
	M.Jitter(10 SECONDS)
	M.AdjustHallucinate(10 SECONDS)
	M.last_hallucinator_log = name
	return ..() | update_flags

/datum/reagent/consumable/ethanol/champagne
	name = "Champagne"
	id = "champagne"
	description = "Превосходное игристое шампанское. Для тех, кто хочет выделиться среди винокуров."
	color = "#d0d312"
	alcohol_perc = 0.2
	drink_icon = "champagneglass"
	drink_name = "glass of champagne"
	drink_desc = "Excellent sparkling champagne. For those who want to stand out among the distillers."
	taste_description = "искрящегося солнечного света"

/datum/reagent/consumable/ethanol/aperol
	name = "Aperol"
	id = "aperol"
	description = "О-о-о-о... Похоже, это засада для печени."
	color = "#b9000a"
	alcohol_perc = 0.2
	drink_icon = "aperolglass"
	drink_name = "glass of Aperol"
	drink_desc = "O-o-oh... This looks like an ambush for your liver."
	taste_description = "травянистой сладости"

/datum/reagent/consumable/ethanol/jagermeister
	name = "Jagermeister"
	id = "jagermeister"
	description = "Пьяница-охотник прибыл из далёкого космоса, и, похоже, он нашёл свою жертву."
	color = "#200b0b"
	alcohol_perc = 0.4
	drink_icon = "jagermeisterglass"
	drink_name = "glass of Jagermeister"
	drink_desc = "A drunken hunter has arrived from deep space, and it seems to have found its prey."
	taste_description = "охотничьего азарта"

/datum/reagent/consumable/ethanol/schnaps
	name = "Schnapps"
	id = "schnaps"
	description = "От такого шнапса не грех начать петь йодлем."
	color = "#e0e0e0"
	alcohol_perc = 0.4
	dizzy_adj = 2 SECONDS
	drink_icon = "schnapsglass"
	drink_name = "glass of schnapps"
	drink_desc = "Schnapps this good might make you start yodeling."
	taste_description = "пшеничной мяты"

/datum/reagent/consumable/ethanol/sambuka
	name = "Sambuca"
	id = "sambuka"
	description = "Улетая в космос, многие думали, что схватили судьбу"
	color = "#e0e0e0"
	alcohol_perc = 0.45
	dizzy_adj = 2 SECONDS
	drink_icon = "sambukaglass"
	drink_name = "glass of sambuca"
	drink_desc = "When they left for space, many thought they had seized their destiny."
	taste_description = "вертлявого огня"

/datum/reagent/consumable/ethanol/bluecuracao
	name = "Blue Curacao"
	id = "bluecuracao"
	description = "Запал готов, синий уже загорелся."
	color = "#16c9ff"
	alcohol_perc = 0.35
	drink_icon = "bluecuracaoglass"
	drink_name = "glass of Blue Curacao"
	drink_desc = "The fuse is ready, and the blue has already caught fire."
	taste_description = "взрывной голубизны"

/datum/reagent/consumable/ethanol/bitter
	name = "Bitters"
	id = "bitter"
	description = "Не перепутай размеры этикеток, ведь я ничего менять не буду."
	color = "#d44071"
	alcohol_perc = 0.45
	dizzy_adj = 4 SECONDS
	drink_icon = "bitterglass"
	drink_name = "glass of bitters"
	drink_desc = "Don't mix up the label sizes, because I'm not changing anything."
	taste_description = "вакуумной горечи"

/datum/reagent/consumable/ethanol/sheridan
	name = "Sheridan's"
	id = "sheridan"
	description = "Охладите, разлейте под углом 45°, не перемешивайте, наслаждайтесь."
	color = "#3a3d2e"
	alcohol_perc = 0.35
	drink_icon = "sheridanglass"
	drink_name = "glass of Sheridan's"
	drink_desc = "Chill, pour at a 45-degree angle, do not stir, and enjoy."
	taste_description = "шоколадно-кремового алкоголя"

////////////////////////////Cocktails///////////////////////////////
/datum/reagent/consumable/ethanol/black_blood
	name = "Black Blood"
	id = "black_blood"
	description = "Пить нужно быстрее, пока оно не начало сворачиваться."
	color = "#252521"
	alcohol_perc = 0.45
	drink_icon = "black_blood"
	drink_name = "Black Blood"
	drink_desc = "Drink it quickly, before it starts to clot."
	taste_description = "кровавой тьмы"

/datum/reagent/consumable/ethanol/black_blood/reaction_mob(mob/living/M, method, volume)
	. = ..()
	if(prob(50))
		M.say(pick(
			"Фуу ма'джин!", "Сас'со к'арта форбичи!", \
			"Та'гх фара'кха фель де'амар дет!", "Кла'ату барада никт'o!", \
			"Фел'т Дол Аб'ород!", "Ин'тотум Лиг'абис!", "Этра п'ни дедоль!", \
			"Дитанс Гут'ура Инпульса!", "О бидай набора се'сма!")
		)

/datum/reagent/consumable/ethanol/light_storm
	name = "Light Storm"
	id = "light_storm"
	description = "Даже вдали от океана вы можете почувствовать эту дрожь."
	color = "#4b4b44"
	alcohol_perc = 0.6
	drink_icon = "light_storm"
	drink_name = "glass of Light Storm"
	drink_desc = "Even far from the ocean, you can feel that shiver."
	taste_description = "морских волнений"

/datum/reagent/consumable/ethanol/cream_heaven
	name = "Cream Heaven"
	id = "cream_heaven"
	description = "Это сочетание сливок и кофе, настоящее небесное творение."
	color = "#4b4b44"
	alcohol_perc = 0.25
	drink_icon = "cream_heaven"
	drink_name = "Cream Heaven"
	drink_desc = "A blend of cream and coffee. A truly heavenly creation."
	taste_description = "кофейных облачков"

/datum/reagent/consumable/ethanol/negroni
	name = "Negroni"
	id = "negroni"
	description = "Горькие напитки очень полезны для печени, а джин плохо влияет на организм. Здесь они уравновешивают друг друга."
	color = "#ad3948"
	alcohol_perc = 0.4
	drink_icon = "negroni"
	drink_name = "Negroni"
	drink_desc = "Bitter drinks are very good for your liver, while gin is bad for your body. Here, they balance each other out."
	taste_description = "сладкого шествия"

/datum/reagent/consumable/ethanol/hirosima
	name = "Hiroshima"
	id = "hirosima"
	description = "Мои руки по локоть в крови... О, подождите, это алкоголь."
	color = "#598317"
	alcohol_perc = 0.3
	drink_icon = "hirosima"
	drink_name = "Hiroshima"
	drink_desc = "My hands are covered in blood... Oh, wait. That's alcohol."
	taste_description = "алкогольного пепла"

/datum/reagent/consumable/ethanol/nagasaki
	name = "Nagasaki"
	id = "nagasaki"
	description = "Сначала никто не знал, что произойдет дальше. Опьянение было ужасным. Нет сомнений, что это самое сильное опьянение, которое когда-либо испытывал человек."
	color = "#18c212"
	alcohol_perc = 0.7
	drink_icon = "nagasaki"
	drink_name = "Nagasaki"
	drink_desc = "At first, nobody knew what would happen next. The intoxication was terrible. Without a doubt, the strongest drunkenness anyone had ever experienced."
	taste_description = "радиоактивного пепла"

/datum/reagent/consumable/ethanol/chocolate_sheridan
	name = "Chocolate Sheridan's"
	id = "chocolate_sheridan"
	description = "В ситуациях, когда действительно хочется взбодриться и выпить."
	color = "#332a1a"
	alcohol_perc = 0.3
	drink_icon = "chocolate_sheridan"
	drink_name = "glass of Chocolate Sheridan's"
	drink_desc = "For when you really want a pick-me-up and a drink."
	taste_description = "алкогольного мокко"

/datum/reagent/consumable/ethanol/panamian
	name = "Panama"
	id = "panamian"
	description = "Это соединит вашу кровь и алкоголь, прямо как Катунские врата."
	color = "#3164a7"
	alcohol_perc = 0.6
	drink_icon = "panamian"
	drink_name = "glass of Panama"
	drink_desc = "It joins your blood and alcohol like the Gatun locks."
	taste_description = "судоходного канала"

/datum/reagent/consumable/ethanol/pegu_club
	name = "Pegu Club"
	id = "pegu_club"
	description = "Это похоже на группу джентльменов, колонизирующих ваш язык."
	color = "#a5702b"
	alcohol_perc = 0.5
	drink_icon = "pegu_club"
	drink_name = "Pegu Club"
	drink_desc = "Like a group of gentlemen colonizing your tongue."
	taste_description = "судоходного канала"

/datum/reagent/consumable/ethanol/jagermachine
	name = "Jagermachine"
	id = "jagermachine"
	description = "Настоящий охотник за деталями."
	color = "#6b0b74"
	alcohol_perc = 0.55
	drink_icon = "jagermachine"
	drink_name = "Jagermachine"
	drink_desc = "A true hunter of parts."
	taste_description = "воровства деталей"

/datum/reagent/consumable/ethanol/blue_cybesauo
	name = "Blue Cybesauo"
	id = "blue_cybesauo"
	description = "Синева, похожая на синий экран смерти."
	color = "#0b7463"
	alcohol_perc = 0.4
	drink_icon = "blue_cybesauo"
	drink_name = "Blue Cybesauo"
	drink_desc = "As blue as a blue screen of death."
	taste_description = "ошибки 0xc000001b"

/datum/reagent/consumable/ethanol/alcomender
	name = "Alco-Mender"
	id = "alcomender"
	description = "Кружка в форме авто-мендера, популярен среди докторов."
	color = "#6b0059"
	alcohol_perc = 1.4 ////Heal burn
	drink_icon = "alcomender"
	drink_name = "Alco-Mender"
	drink_desc = "A mug shaped like an auto-mender. Popular with doctors."
	taste_description = "весёлой медицины"

/datum/reagent/consumable/ethanol/alcomender/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(-0.7, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/alcomender/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume) // It is alcohol after all, so don't try to pour it on someone who's on fire ... please.
	if(iscarbon(M))
		if(method == REAGENT_TOUCH)
			M.adjustFireLoss(-volume * 0.7, affect_robotic = FALSE)
			to_chat(M, span_notice("Разбавленный сульфадиазин серебра исцеляет ваши ожоги."))
	return STATUS_UPDATE_NONE

/datum/reagent/consumable/ethanol/amnesia
	name = "Stellar Amnesia"
	id = "amnesia"
	description = "Стоп, это бутылка медицинского спирта?"
	color = "#6b0059"
	alcohol_perc = 1.2 ////Ethanol and Hooch
	drink_icon = "amnesia"
	drink_name = "Stellar Amnesia"
	drink_desc = "Wait, is that a bottle of medical alcohol?"
	taste_description = "диско"

/datum/reagent/consumable/ethanol/johnny
	name = "Silverhand"
	id = "johnny"
	description = "Просыпайся, самурай. Нам нужно сжечь одну станцию."
	color = "#c41414"
	alcohol_perc = 0.6
	drink_icon = "johnny"
	drink_name = "Silverhand"
	drink_desc = "Wake up, samurai. We've got a station to burn."
	taste_description = "угасающей суперзвезды"

/datum/reagent/consumable/ethanol/cosmospoliten
	name = "Cosmopolitan"
	id = "cosmospoliten"
	description = "А теперь попробуй доказать, что ты натурал и не женщина, если тебя застукают с ним."
	color = "#b1483a"
	alcohol_perc = 0.5
	drink_icon = "cosmospoliten"
	drink_name = "Cosmopolitan"
	drink_desc = "Now try proving you're straight and not a woman if someone catches you with it."
	taste_description = "изменения ориентации"

/datum/reagent/consumable/ethanol/oldfashion
	name = "Old Fashioned"
	id = "oldfashion"
	description = "Ходят слухи, что этот коктейль является самым старым из всех, но, впрочем, это совсем другая история."
	color = "#6b4017"
	alcohol_perc = 0.6
	drink_icon = "oldfashion"
	drink_name = "Old Fashioned"
	drink_desc = "Rumor has it this is the oldest cocktail of all, but that's another story."
	taste_description = "старых добрых времён"

/datum/reagent/consumable/ethanol/french_75
	name = "French 75"
	id = "french_75"
	description = "Заряжай печень, целься, стреляй!"
	color = "#b1953a"
	alcohol_perc = 0.4
	drink_icon = "french_75"
	drink_name = "French 75"
	drink_desc = "Load your liver. Aim. Fire!"
	taste_description = "артиллерийского обстрела"

/datum/reagent/consumable/ethanol/gydroseridan
	name = "Hydroridan's"
	id = "gydroseridan"
	description = "Гидравлическое разделение слоёв поможет нам повысить эффективность."
	color = "#3a99b1"
	alcohol_perc = 0.5
	drink_icon = "gydroseridan"
	drink_name = "Hydroridan's"
	drink_desc = "Hydraulic separation of the layers will help us improve efficiency."
	taste_description = "мощи гидравлики"

/datum/reagent/consumable/ethanol/milk_plus
	name = "Milk Plus"
	id = "milk_plus"
	description = "Когда человек не может выбирать, он перестаёт быть человеком."
	color = "#DFDFDF"
	alcohol_perc = 0.8
	drink_icon = "milk_plus"
	drink_name = "Milk Plus"
	drink_desc = "When a man cannot choose, he ceases to be a man."
	taste_description = "человеческой потери"

/datum/reagent/consumable/ethanol/teslasingylo
	name = "God of Energy"
	id = "teslasingylo"
	description = "Настоящий ужас для СКАН'ов и ЛКП. Не перегружайте их."
	color = "#0300ce"
	alcohol_perc = 0.7
	process_flags = SYNTHETIC
	drink_icon = "teslasingylo"
	drink_name = "God of Energy"
	drink_desc = "A true terror for SMES units and APCs. Don't overload them."
	taste_description = "электрического благословления"

/datum/reagent/consumable/ethanol/teslasingylo/on_mob_life(mob/living/M)
	. = ..()
	if(ismachineperson(M))
		var/mob/living/carbon/human/machine/machine = M
		if(machine.nutrition > NUTRITION_LEVEL_WELL_FED) //no fat machines, sorry
			return
		machine.adjust_nutrition(15) //much less than charging from APC (50)

/datum/reagent/consumable/ethanol/light
	name = "Light"
	id = "light"
	description = "Любимый напиток ниан и дион. Кто-то скажет, что это мини-термоядерная реакция, но только тссс..."
	color = "#fffb00"
	alcohol_perc = 0.2
	drink_icon = "light"
	drink_name = "Light"
	drink_desc = "A favorite of Nian and Diona. Some might call it a miniature fusion reaction, but shhh..."
	taste_description = "звёздного света"

/datum/reagent/consumable/ethanol/light/on_mob_life(mob/living/M)
	. = ..()
	if(M.lighting_alpha < LIGHTING_PLANE_ALPHA_NV_TRAIT)
		return
	M.lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT
	if(volume < 0.4)
		M.lighting_alpha = initial(M.lighting_alpha)

/datum/reagent/consumable/ethanol/bees_knees
	name = "Bee's Knees"
	id = "bees_knees"
	description = "Как будто бы дело в том, что пчела переносит пыльцу в области коленей и... Не берите в голову."
	color = "#e8f71f"
	alcohol_perc = 0.5
	drink_icon = "bees_knees"
	drink_name = "Bee's Knees"
	drink_desc = "Something about bees carrying pollen around their knees and... Never mind."
	taste_description = "любви к мёду"

/datum/reagent/consumable/ethanol/aviation
	name = "Aviation"
	id = "aviation"
	description = "Трудно готовить коктейли, когда над твоим домом пролетает дирижабль."
	color = "#c48f8f"
	alcohol_perc = 0.5
	drink_icon = "aviation"
	drink_name = "Aviation"
	drink_desc = "It's hard to make cocktails when an airship is flying over your house."
	taste_description = "сильного ветра"

/datum/reagent/consumable/ethanol/fizz
	name = "Fizz"
	id = "fizz"
	description = "Это всё равно, что жить с дикой кошкой."
	color = "#b6b6b6"
	alcohol_perc = 0.3
	drink_icon = "fizz"
	drink_name = "Fizz"
	drink_desc = "It's like living with a wildcat."
	taste_description = "шипучего алкоголя"

/datum/reagent/consumable/ethanol/brandy_crusta
	name = "Brandy Crusta"
	id = "brandy_crusta"
	description = "Сахарная корочка может быть совсем не сладкой."
	color = "#754609"
	alcohol_perc = 0.4
	drink_icon = "brandy_crusta"
	drink_name = "Brandy Crusta"
	drink_desc = "A sugar crust isn't always sweet."
	taste_description = "солёно-сладкого алкоголя"

/datum/reagent/consumable/ethanol/aperolspritz
	name = "Aperol Spritz"
	id = "aperolspritz"
	description = "Многие считают его отдельным видом алкоголя, но он больше похож на коня в шахматах."
	color = "#c43d3d"
	alcohol_perc = 0.5
	drink_icon = "aperolspritz"
	drink_name = "Aperol Spritz"
	drink_desc = "Many consider it a separate kind of alcohol, but it's more like a knight in chess."
	taste_description = "раздельности вкусов"

/datum/reagent/consumable/ethanol/sidecar
	name = "Sidecar"
	id = "sidecar"
	description = "Этот коктейль очень популярен. Впервые его представил популярный бармен Этот МакГарри из Клуба Бака."
	color = "#b15416"
	alcohol_perc = 0.4
	drink_icon = "sidecar"
	drink_name = "Sidecar"
	drink_desc = "You can smell the citrus from here!"
	taste_description = "апельсинового алкоголя"

/datum/reagent/consumable/ethanol/daiquiri
	name = "Daiquiri"
	id = "daiquiri"
	description = "Просто попробуй, попробуй ещё раз!"
	color = "#b6b6b6"
	alcohol_perc = 0.4
	drink_icon = "daiquiri"
	drink_name = "Daiquiri"
	drink_desc = "When Botany gives you limes, make daiquiris."
	taste_description = "выстрела в голову"

/datum/reagent/consumable/ethanol/tuxedo
	name = "Tuxedo"
	id = "tuxedo"
	description = "Я могу пообещать вам Колумбийский Галстук."
	color = "#888686"
	alcohol_perc = 0.5
	drink_icon = "tuxedo"
	drink_name = "Tuxedo"
	drink_desc = "I can promise you a Colombian necktie."
	taste_description = "строгости стиля"

/datum/reagent/consumable/ethanol/telegol
	name = "Telegol"
	id = "telegol"
	description = "Многие до сих пор ломают голову над вопросом существования этого коктейля. Как бы то ни было, он всё ещё существует... Или нет."
	color = "#4218a3"
	alcohol_perc = 0.5
	drink_icon = "telegol"
	drink_name = "Telegol"
	drink_desc = "Many still puzzle over this cocktail's existence. Either way, it still exists... Or does it?"
	taste_description = "четырнадцатого измерения"

/datum/reagent/consumable/ethanol/horse_neck
	name = "Horse's Neck"
	id = "horse_neck"
	description = "Будьте осторожны с подковами вашей лошади."
	color = "#c45d09"
	alcohol_perc = 0.5
	drink_icon = "horse_neck"
	drink_name = "Horse's Neck"
	drink_desc = "Be careful with your horse's shoes."
	taste_description = "лошадиной силы"

/datum/reagent/consumable/ethanol/horse_neck/reaction_mob(mob/living/M, method, volume)
	. = ..()
	if(prob(50))
		M.say(pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!"))

/datum/reagent/consumable/ethanol/cuban_sunset
	name = "Cuban Sunset"
	id = "cuban_sunset"
	description = "Новый день, новая революция."
	color = "#d88948"
	alcohol_perc = 0.6
	drink_icon = "cuban_sunset"
	drink_name = "Cuban Sunset"
	drink_desc = "A new day, a new revolution."
	taste_description = "тоталитаризма"

/datum/reagent/consumable/ethanol/sake_bomb
	name = "Sake Bomb"
	id = "sake_bomb"
	description = "Ковровая бомбардировка вашей бамбуковой печени."
	color = "#e2df2e"
	alcohol_perc = 0.3
	drink_icon = "sake_bomb"
	drink_name = "Sake Bomb"
	drink_desc = "Carpet-bombing your bamboo liver."
	taste_description = "пива и саке"

/datum/reagent/consumable/ethanol/blue_havai
	name = "Blue Hawaii"
	id = "blue_havai"
	description = "Такой же голубой, как и карие глаза."
	color = "#296129"
	alcohol_perc = 0.2
	drink_icon = "blue_havai"
	drink_name = "Blue Hawaii"
	drink_desc = "As blue as brown eyes."
	taste_description = "неонового рассвета"

/datum/reagent/consumable/ethanol/woo_woo
	name = "Woo Woo"
	id = "woo_woo"
	description = "Какой ребёнок придумал это имя? Да, я вижу, вопрос решён."
	color = "#e22e2e"
	alcohol_perc = 0.5
	drink_icon = "woo_woo"
	drink_name = "Woo Woo"
	drink_desc = "What child came up with that name? Yes, I see. Question answered."
	taste_description = "ву-ву"

/datum/reagent/consumable/ethanol/mulled_wine
	name = "Mulled Wine"
	id = "mulled_wine"
	description = "Просто горячее вино со специями, но такое приятное."
	color = "#fd4b4b"
	alcohol_perc = 0.2
	drink_icon = "mulled_wine"
	drink_name = "Mulled Wine"
	drink_desc = "Just hot wine with spices, but so comforting."
	taste_description = "горячего пряного вина"
	var/temperature_effect = 40

/datum/reagent/consumable/ethanol/mulled_wine/on_mob_life(mob/living/M)
	var/normal_temperature = M?.dna?.species.body_temperature

	if(!normal_temperature)
		normal_temperature = BODYTEMP_NORMAL

	var/difference = M.bodytemperature - normal_temperature

	if(difference > 0)
		return ..()

	M.adjust_bodytemperature((min(temperature_effect, -difference)) * TEMPERATURE_DAMAGE_COEFFICIENT)
	return ..()

/datum/reagent/consumable/ethanol/white_bear
	name = "Polar Bear"
	id = "white_bear"
	description = "Два исторических врага в одном кругу."
	color = "#d8b465"
	alcohol_perc = 0.5
	drink_icon = "white_bear"
	drink_name = "Polar Bear"
	drink_desc = "Two historical enemies in one circle."
	taste_description = "войны идеологий"

/datum/reagent/consumable/ethanol/vampiro
	name = "Vampiro"
	id = "vampiro"
	description = "Не имеет ничего общего с вампирами кроме цвета."
	color = "#8d0000"
	alcohol_perc = 0.45
	drink_icon = "vampiro"
	drink_name = "Glass of Vampiro"
	drink_desc = "Tequila prepared with tomato juice for a blood-red look."
	taste_description = "истощения"

/datum/reagent/consumable/ethanol/vampiro/on_mob_life(mob/living/M)
	. = ..()
	if(volume > 20)
		if(prob(50)) //no spam here :p
			M.visible_message(span_warning("Глаза [M] ослепительно вспыхивают!"))

/datum/reagent/consumable/ethanol/queen_mary
	name = "Queen Mary"
	id = "queen_mary"
	description = "Мария очистилась от крови, и оказалось, что она тоже красная."
	color = "#bd2f2f"
	alcohol_perc = 0.35
	drink_icon = "queen_mary"
	drink_name = "Queen Mary"
	drink_desc = "Mary washed off the blood, and it turned out she was red too."
	taste_description = "вишнёвого пива"

/datum/reagent/consumable/ethanol/inabox
	name = "In a Box"
	id = "inabox"
	description = "Это... Просто коробка?"
	color = "#5a3e0b"
	alcohol_perc = 0.4
	drink_icon = "inabox"
	drink_name = "In a Box"
	drink_desc = "Is this... Just a box?"
	taste_description = "стелса"

/datum/reagent/consumable/ethanol/beer_berry_royal
	name = "Royal Cherry Beer"
	id = "beer_berry_royal"
	description = "По какой-то причине они продолжают подниматься и опускаться, вверх и вниз."
	color = "#684b16"
	alcohol_perc = 0.25
	drink_icon = "beer_berry_royal"
	drink_name = "Royal Cherry Beer"
	drink_desc = "For some reason, they keep rising and falling. Up and down."
	taste_description = "ягодного пива"

/datum/reagent/consumable/ethanol/sazerac
	name = "Sazerac"
	id = "sazerac"
	description = "Лучшие фармацевты — бармены."
	color = "#7c6232"
	alcohol_perc = 0.4
	drink_icon = "sazerac"
	drink_name = "Sazerac"
	drink_desc = "Bartenders make the best pharmacists."
	taste_description = "горького виски"

/datum/reagent/consumable/ethanol/monako
	name = "Monaco"
	id = "monako"
	description = "Вы можете подумать, что на рынке больше фруктов."
	color = "#7c6232"
	alcohol_perc = 0.5
	drink_icon = "monako"
	drink_name = "Monaco"
	drink_desc = "You might think there is more fruit at the market."
	taste_description = "фруктового джина"

/datum/reagent/consumable/ethanol/irishempbomb
	name = "Irish EMP Bomb"
	id = "irishempbomb"
	description = "Ммм, на вкус как отключение..."
	color = "#123eb8"
	process_flags = SYNTHETIC
	alcohol_perc = 0.6
	drink_icon = "irishempbomb"
	drink_name = "Irish EMP Bomb"
	drink_desc = "Mmm, tastes like a shutdown..."
	taste_description = "электромагнитного импульса"

/datum/reagent/consumable/ethanol/irishempbomb/on_mob_life(mob/living/M)
	M.Stun(1, FALSE)
	do_sparks(5, FALSE, M.loc)
	return ..()

/datum/reagent/consumable/ethanol/codelibre
	name = "Code Libre"
	id = "codelibre"
	description = "За Коде Либре!"
	color = "#a126b1"
	alcohol_perc = 0.55
	process_flags = SYNTHETIC
	drink_icon = "codelibre"
	drink_name = "Code Libre"
	drink_desc = "To Code libre!"
	taste_description = "свободы кода"

/datum/reagent/consumable/ethanol/codelibre/on_mob_life(mob/living/M)
	. = ..()
	if(prob(10))
		M.say("[get_language_prefix(LANGUAGE_TRINARY)] Вива ла Синтетика!")

/datum/reagent/consumable/ethanol/blackicp
	name = "Black IPC"
	id = "blackicp"
	description = "Извините за игнорирование вопроса, можете повторить запрос?"
	color = "#a126b1"
	alcohol_perc = 0.5
	drink_icon = "blackicp"
	drink_name = "Black IPC"
	drink_desc = "Sorry for ignoring the question. Could you repeat your request?"
	taste_description = "замены монитора"

/datum/reagent/consumable/ethanol/slime_drink
	name = "Drunken Slime"
	id = "slime_drink"
	description = "Не волнуйтесь, это просто желе."
	color = "#dd3e32"
	alcohol_perc = 0.2
	drink_icon = "slime_drink"
	drink_name = "Drunken Slime"
	drink_desc = "Don't worry, it's just jelly. The slime has been dead for a long time."
	taste_description = "желейного алкоголя"

/datum/reagent/consumable/ethanol/innocent_erp
	name = "Innocent ERP"
	id = "innocent_erp"
	description = "Большой Брат следит за тобой."
	color = "#746463"
	alcohol_perc = 0.5
	drink_icon = "innocent_erp"
	drink_name = "Innocent ERP"
	drink_desc = "Big Brother is watching you."
	taste_description = "запретных желаний"

/datum/reagent/consumable/ethanol/nasty_slush
	name = "Nasty Slush"
	id = "nasty_slush"
	description = "Название не имеет никакого отношения к самому напитку."
	color = "#462c0a"
	alcohol_perc = 0.55
	drink_icon = "nasty_slush"
	drink_name = "Nasty Slush"
	drink_desc = "The name has nothing to do with the drink itself."
	taste_description = "мерзкой слякоти"

/datum/reagent/consumable/ethanol/blue_lagoon
	name = "Blue Lagoon"
	id = "blue_lagoon"
	description = "Что может быть лучше, чем отдых на пляже с хорошим напитком?"
	color = "#1edddd"
	alcohol_perc = 0.5
	drink_icon = "blue_lagoon"
	drink_name = "Blue Lagoon"
	drink_desc = "What could be better than relaxing on a beach with a good drink?"
	taste_description = "пляжного отдыха"

/datum/reagent/consumable/ethanol/green_fairy
	name = "Green Fairy"
	id = "green_fairy"
	description = "Какой-то ненормальный зелёный."
	color = "#54dd1e"
	alcohol_perc = 0.6
	drink_icon = "green_fairy"
	drink_name = "Green Fairy"
	drink_desc = "An utterly deranged shade of green."
	taste_description = "веры в фей"

/datum/reagent/consumable/ethanol/green_fairy/on_mob_life(mob/living/M)
	M.SetDruggy(min(max(0, M.AmountDruggy() + 10 SECONDS), 15 SECONDS))
	return ..()

/datum/reagent/consumable/ethanol/home_lebovsky
	name = "Homemade Lebowski"
	id = "home_lebovsky"
	description = "Позволь мне кое-что тебе объяснить. Я не Домашний Лебовски. Иы Домашний Лебовски. Я Чувак."
	color = "#422b00"
	alcohol_perc = 0.35
	drink_icon = "home_lebovsky"
	drink_name = "Homemade Lebowski"
	drink_desc = "Let me explain something. I'm not Homemade Lebowski. You're Homemade Lebowski. I'm the Dude."
	taste_description = "dressing gown"

/datum/reagent/consumable/ethanol/top_billing
	name = "Top Billing"
	id = "top_billing"
	description = "На видном месте, наша главная заслуга!"
	color = "#0b573d"
	alcohol_perc = 0.4
	drink_icon = "top_billing"
	drink_name = "Top Billing"
	drink_desc = "In a place of honor: our greatest achievement!"
	taste_description = "рекламного пространства"

/datum/reagent/consumable/ethanol/trans_siberian_express
	name = "Trans-Siberian Express"
	id = "trans_siberian_express"
	description = "От Владивостока до белой горячки за один день."
	color = "#e2a600"
	alcohol_perc = 0.5
	drink_icon = "trans_siberian_express"
	drink_name = "Trans-Siberian Express"
	drink_desc = "From Vladivostok to delirium tremens in a single day."
	taste_description = "ужасной инфрастуктуры"

/datum/reagent/consumable/ethanol/trans_siberian_express/on_mob_life(mob/living/M)
	. = ..()
	var/datum/language/rus_lang = GLOB.all_languages[LANGUAGE_NEO_RUSSIAN]
	if(LAZYIN(M.languages, rus_lang) && !LAZYIN(M.temporary_languages, rus_lang))
		if(M.default_language != rus_lang)
			M.default_language = rus_lang
		if(volume < 0.4)
			M.default_language = null //reset language we were speaking
		return
	else
		if(!LAZYIN(M.languages, rus_lang))
			LAZYADD(M.temporary_languages, rus_lang)
			LAZYADD(M.languages, rus_lang)
			M.default_language = rus_lang
		if(volume < 0.4)
			M.languages ^= M.temporary_languages
			LAZYREMOVE(M.temporary_languages, rus_lang)
			M.default_language = null

/datum/reagent/consumable/ethanol/sun
	name = "Sun"
	id = "sun"
	description = "Red sun over paradise!"
	color = "#bd1c1c"
	alcohol_perc = 0.4
	drink_icon = "sun"
	drink_name = "Sun"
	drink_desc = "Red sun over paradise!"
	taste_description = "солнечной жары"

/datum/reagent/consumable/ethanol/tick_tack
	name = "Tick-Tock"
	id = "tick_tack"
	description = "Тик-Ток, Тик-Ток, бззз..."
	color = "#118020"
	alcohol_perc = 0.3
	drink_icon = "tick_tack"
	drink_name = "Tick-Tock"
	drink_desc = "Tick-tock, tick-tock, bzzz..."
	taste_description = "тиканья часов"

/datum/reagent/consumable/ethanol/uragan_shot
	name = "Hurricane Shot"
	id = "uragan_shot"
	description = "Это ураган? Нет, это урагон."
	color = "#da6631"
	alcohol_perc = 0.35
	drink_icon = "uragan_shot"
	drink_name = "Hurricane Shot"
	drink_desc = "Is that a hurricane? No, it's a hurry-cane."
	taste_description = "порывов ветра"

/datum/reagent/consumable/ethanol/new_yorker
	name = "New Yorker"
	id = "new_yorker"
	description = "Будьте осторожны с биржей, иначе наступит \"чёрный вторник\"."
	color = "#da3131"
	alcohol_perc = 0.4
	drink_icon = "new_yorker"
	drink_name = "New Yorker"
	drink_desc = "Be careful with the stock market, or Black Tuesday will come."
	taste_description = "катастрофы"

/datum/reagent/consumable/ethanol/blue_moondrin
	name = "Iluk Blue Moon'drin"
	id = "blue_moondrin"
	description = "Редчайший таяранский напиток в галактике! Будьте осторожны с вашим капитаном!"
	color = "#0026fc"
	alcohol_perc = 0.7
	addiction_chance = 4
	drink_icon = "blue_moondrin"
	drink_name = "Iluk Blue Moon'drin"
	drink_desc = "The rarest Tajaran drink in the galaxy! Be careful around your captain!"
	taste_description = "синего выключения"

/datum/reagent/consumable/ethanol/blue_moondrin/on_mob_life(mob/living/M)
	M.Druggy(30 SECONDS, FALSE)
	switch(current_cycle)
		if(1 to 15)
			M.Dizzy(10 SECONDS)
			if(prob(20))
				M.emote(pick("twitch","giggle","moan"))
				M.Jitter(20 SECONDS)
		if(16 to 24)
			if(prob(15))
				M.Dizzy(10 SECONDS)
				M.playsound_local(src, 'sound/spookoween/ghost_whisper.ogg', 3)
				M.emote(pick("twitch","giggle"))
				M.Jitter(20 SECONDS)
				M.AdjustHallucinate(20 SECONDS)
		if(25 to INFINITY)
			if(prob(10))
				M.Dizzy(20 SECONDS)
				M.playsound_local(src,'sound/hallucinations/veryfar_noise.ogg', 1)
				M.Jitter(20 SECONDS)
				M.AdjustHallucinate(30 SECONDS)
				M.emote("moan")
	return ..()

/datum/reagent/consumable/ethanol/red_moondrin
	name = "Redwater Moon'drin"
	id = "red_moondrin"
	description = "Запрещённый на Адомае таяранский напиток, но не здесь! Опасное пойло на основе лун'дрина с тайным ингридиентом. Будьте осторожны!"
	color = "#960202"
	alcohol_perc = 0.9
	addiction_chance = 7
	drink_icon = "red_moondrin"
	drink_name = "Redwater Moon'drin"
	drink_desc = "A Tajaran drink banned on Adhomai, but not here! A dangerous moon'drin-based brew with a secret ingredient. Be careful!"
	taste_description = "приятного, но болезненного ощущения в желудке"

/datum/reagent/consumable/ethanol/red_moondrin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Druggy(30 SECONDS)
	switch(current_cycle)
		if(1 to 20)
			M.Dizzy(20 SECONDS)
			M.Stuttering(10 SECONDS)
			if(prob(30))
				M.emote(pick("twitch","moan"))
				M.Jitter(20 SECONDS)
				M.AdjustHallucinate(30 SECONDS)
			if(prob(10))
				M.playsound_local(src,'sound/hallucinations/im_here1.ogg', 1)
		if(21 to 30)
			M.Dizzy(10 SECONDS)
			M.Stuttering(10 SECONDS)
			M.playsound_local(src, 'sound/effects/heartbeat.ogg', 1)
			if(prob(20))
				to_chat(M, span_warning("Вы чувствуете себя странно..."))
				M.emote("scream")
				M.playsound_local(src, 'sound/spookoween/ghost_whisper.ogg', 5)
				M.AdjustHallucinate(40 SECONDS)
				update_flags |= M.adjustStaminaLoss(3, FALSE)
			if(prob(5))
				M.playsound_local(src,'sound/hallucinations/look_up1.ogg', 1)
				M.emote("gasp")
				to_chat(M, span_warning("Вы не можете дышать! Но это так приятно!"))
				update_flags |= M.adjustOxyLoss(15, FALSE)
				update_flags |= M.adjustToxLoss(2, FALSE)
				M.Stun(2 SECONDS)
		if(31 to INFINITY)
			M.playsound_local(src, 'sound/effects/heartbeat.ogg', 2)
			M.Dizzy(20 SECONDS)
			M.Stuttering(20 SECONDS)
			if(prob(30))
				M.playsound_local(src, 'sound/effects/heartbeat.ogg', 2)
				M.emote(pick("twitch","moan"))
				M.Jitter(20 SECONDS)
				M.AdjustHallucinate(30 SECONDS)
				M.playsound_local(src,'sound/hallucinations/i_see_you2.ogg', 1)
			if(prob(20))
				to_chat(M, span_warning("Вам больно!"))
				M.emote("scream")
				M.playsound_local(src, 'sound/spookoween/ghost_whisper.ogg', 5)
				M.AdjustHallucinate(40 SECONDS)
				update_flags |= M.adjustStaminaLoss(10, FALSE)
			if(prob(5))
				M.playsound_local(src, 'sound/effects/heartbeat.ogg', 2)
				M.playsound_local(src,'sound/hallucinations/growl1.ogg', 1)
				M.emote("gasp")
				to_chat(M, span_warning("Вы не можете дышать! Но это так приятно!"))
				update_flags |= M.adjustOxyLoss(15, FALSE)
				update_flags |= M.adjustToxLoss(2, FALSE)
				M.Stun(2 SECONDS)
			if(prob(3))
				M.playsound_local(src, 'sound/effects/heartbeat.ogg', 2)
				to_chat(M, span_warning("Вам кажется, что вас кто-то преследует!"))
				M.playsound_local(src,'sound/hallucinations/growl2.ogg', 1)
				M.emote(pick("drool","scream"))
				M.Jitter(20 SECONDS)
				update_flags |= M.adjustToxLoss(3, FALSE)
				M.Weaken(2 SECONDS)
				M.AdjustConfused(66 SECONDS)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/synthanol/restart
	name = "Restart"
	id = "restart"
	description = "Иногда нужно начать всё сначала."
	color = "#0026fc"
	process_flags = SYNTHETIC
	alcohol_perc = 1.5
	drink_icon = "restart"
	drink_name = "Restart"
	drink_desc = "Sometimes you need to start over."
	taste_description = "перезагрузки"

/datum/reagent/consumable/ethanol/synthanol/restart/on_mob_life(mob/living/carbon/human/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(5 to 13)
			M.Jitter(40 SECONDS)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
			if(prob(5))
				to_chat(M, span_notice("Перезагрузка системы..."))
		if(14)
			playsound(get_turf(M),'sound/effects/restart-shutdown.ogg', 200, TRUE)
		if(15 to 23)
			M.Weaken(10 SECONDS)
			update_flags |= M.adjustBruteLoss(-0.3, FALSE, affect_robotic = TRUE)
			update_flags |= M.adjustFireLoss(-0.3, FALSE, affect_robotic = TRUE)
			M.SetSleeping(20 SECONDS)
		if(24)
			playsound(get_turf(M), 'sound/effects/restart-wakeup.ogg', 200, TRUE)
		if(25)
			M.SetStunned(0)
			M.SetWeakened(0)
			M.SetKnockdown(0)
			M.SetParalysis(0)
			M.SetSleeping(0)
			M.SetDrowsy(0)
			M.SetSlur(0)
			M.SetDrunk(0)
			M.SetJitter(0)
			M.SetDizzy(0)
			M.SetDruggy(0)
			M.set_resting(FALSE, instant = TRUE)
			M.get_up(instant = TRUE)
			var/restart_amount = clamp(M.reagents.get_reagent_amount("restart")-0.4, 0, 330)
			M.reagents.remove_reagent("restart",restart_amount)
	return ..() | update_flags
