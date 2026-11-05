/datum/reagent/consumable/drink/orangejuice
	name = "Orange Juice"
	id = "orangejuice"
	description = "И вкусно, и богато витамином С — что ещё нужно?"
	drink_icon = "glass_orange"
	drink_name = "Glass of Orange Juice"
	drink_desc = "Vitamins! Yay!"
	taste_description = "апельсиного сока"

/datum/reagent/consumable/drink/orangejuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(30))
		update_flags |= M.adjustOxyLoss(-0.5, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/tomatojuice
	name = "Tomato Juice"
	id = "tomatojuice"
	description = "Почему томатный, а не помидорный сок?"
	color = "#731008" // rgb: 115, 16, 8
	drink_icon = "glass_red"
	drink_name = "Glass of Tomato Juice"
	drink_desc = "Are you sure this is tomato juice?"
	taste_description = "томатного сока"

/datum/reagent/consumable/drink/pineapplejuice
	name = "Pineapple Juice"
	id = "pineapplejuice"
	description = "Ананасы, выжатые до жидкого состояния. Сладко и приторно."
	color = "#e5b437"
	drink_icon = "glass_orange"
	drink_name = "Glass of Pineapple Juice"
	drink_desc = "A bright drink, sweet and sugary."
	taste_description = "ананасового сока"

/datum/reagent/consumable/drink/tomatojuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/limejuice
	name = "Lime Juice"
	id = "limejuice"
	description = "Кисло-сладкий сок лайма."
	color = "#365E30" // rgb: 54, 94, 48
	drink_icon = "glass_green"
	drink_name = "Glass of Lime Juice"
	drink_desc = "A glass of sweet-sour lime juice."
	taste_description = "лаймового сока"

/datum/reagent/consumable/drink/limejuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/carrotjuice
	name = "Carrot Juice"
	id = "carrotjuice"
	description = "Это как морковь, только без хруста. Полезно для глаз!"
	color = "#973800" // rgb: 151, 56, 0
	drink_icon = "carrotjuice"
	drink_name = "Glass of Carrot Juice"
	drink_desc = "Just like a carrot, but without the crunching."
	taste_description = "морковного сока"

/datum/reagent/consumable/drink/carrotjuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustEyeBlurry(-2 SECONDS)
	M.AdjustEyeBlind(-2 SECONDS)
	if(current_cycle > 20 && prob(current_cycle - 10))
		update_flags |= M.CureNearsighted(EYE_DAMAGE, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/doctor_delight
	name = "The Doctor's Delight"
	id = "doctorsdelight"
	description = "Полезная смесь соков, которая поможет вам восстановиться перед следующей зарубой на тулбоксах."
	color = "#FF8CFF" // rgb: 255, 140, 255
	drink_icon = "doctorsdelightglass"
	drink_name = "Doctor's Delight"
	drink_desc = "A healthy mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."
	taste_description = "здорового питания"

/datum/reagent/consumable/drink/doctor_delight/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/triple_citrus
	name = "Triple Citrus"
	id = "triple_citrus"
	description = "Освежающий микс из сока различных цитрусовых. Замечательно."
	color = "#23A046"
	drink_icon = "triplecitrus"
	drink_name = "Glass of Triple Citrus Juice"
	drink_desc = "As colorful and healthy as it is delicious."
	taste_description = "сока цитрусовых"

/datum/reagent/consumable/drink/triple_citrus/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST)
		M.adjustToxLoss(-rand(1,2))

/datum/reagent/consumable/drink/berryjuice
	name = "Berry Juice"
	id = "berryjuice"
	description = "Вкусная смесь из нескольких видов ягод."
	color = "#863333" // rgb: 134, 51, 51
	drink_icon = "berryjuice"
	drink_name = "Glass of Berry Juice"
	drink_desc = "Berry juice. Or maybe it's jam. Who cares?"
	taste_description = "ягодного сока"

/datum/reagent/consumable/drink/poisonberryjuice
	name = "Poison Berry Juice"
	id = "poisonberryjuice"
	description = "Вкусная смесь из нескольких видов ядовитых и опасных ягод."
	color = "#863353" // rgb: 134, 51, 83
	drink_icon = "poisonberryjuice"
	drink_name = "Glass of Poison Berry Juice"
	drink_desc = "A glass of deadly juice."
	taste_description = "ягодного сока"

/datum/reagent/consumable/drink/poisonberryjuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/applejuice
	name = "Apple Juice"
	id = "applejuice"
	description = "Сладкой сок, полученный из выжатых яблок. Подходит для всех возрастов."
	color = "#ECFF56" // rgb: 236, 255, 86
	taste_description = "яблочного сока"

/datum/reagent/consumable/drink/watermelonjuice
	name = "Watermelon Juice"
	id = "watermelonjuice"
	description = "Вкусный сок из арбуза."
	color = "#863333" // rgb: 134, 51, 51
	taste_description = "арбузного сока"

/datum/reagent/consumable/drink/lemonjuice
	name = "Lemon Juice"
	id = "lemonjuice"
	description = "Этот сок ОЧЕНЬ кислый."
	color = "#863333" // rgb: 175, 175, 0
	drink_icon = "lemonglass"
	drink_name = "Glass of Lemon Juice"
	drink_desc = "Sour..."
	taste_description = "лимонного сока"

/datum/reagent/consumable/drink/grapejuice
	name = "Grape Juice"
	id = "grapejuice"
	description = "Не запачкайте рубашку."
	color = "#993399" // rgb: 153, 51, 153
	taste_description = "виноградного сока"

/datum/reagent/consumable/drink/banana
	name = "Banana Juice"
	id = "banana"
	description = "Сырая сущность банана."
	color = "#863333" // rgb: 175, 175, 0
	drink_icon = "banana"
	drink_name = "Glass of Banana Juice"
	drink_desc = "The raw essence of a banana. HONK"
	taste_description = "бананового сока"

/datum/reagent/consumable/drink/banana/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(HAS_TRAIT(M, TRAIT_COMIC) || is_monkeybasic(M))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/strawwberry
	name = "Strawberry Juice"
	id = "strawwberry"
	description = "Сырая сущность клубники."
	color = "#fc2525"
	drink_name = "glass of strawberry juice"
	drink_desc = "The raw essence of strawberries."
	taste_description = "клубники"

/datum/reagent/consumable/drink/nothing
	name = "Nothing"
	id = "nothing"
	description = "Абсолютно ничего."
	drink_icon = "nothing"
	drink_name = "Nothing"
	drink_desc = "Absolutely nothing."
	taste_description = "ничего"

/datum/reagent/consumable/drink/nothing/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && M.mind && HAS_MIND_TRAIT(M, TRAIT_MIMING))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/potato_juice
	name = "Potato Juice"
	id = "potato"
	description = "Сок картофеля. Ух."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	drink_icon = "glass_brown"
	drink_name = "Glass of  Potato Juice"
	drink_desc = "Who in the hell requests this? Gross!"
	taste_description = "рвоты или ещё чего похуже"

/datum/reagent/consumable/drink/milk
	name = "Milk"
	id = "milk"
	description = "Непрозрачная белая жидкость, вырабатываемая молочными железами млекопитающих."
	color = "#DFDFDF" // rgb: 223, 223, 223
	drink_icon = "glass_white"
	drink_name = "Glass of milk"
	drink_desc = "White and nutritious goodness!"
	taste_description = "молока"

/datum/reagent/consumable/drink/milk/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 2)
	return ..() | update_flags

/datum/reagent/consumable/drink/milk/soymilk
	name = "Soy Milk"
	id = "soymilk"
	description = "Непрозрачная белая жидкость, изготовленная из соевых бобов."
	color = "#DFDFC7" // rgb: 223, 223, 199
	drink_name = "Glass of soy milk"
	drink_desc = "White and nutritious soy goodness!"
	taste_description = "фальшивого молока"

/datum/reagent/consumable/drink/milk/cream
	name = "Cream"
	id = "cream"
	description = "Жирная, но всё ещё жидкая часть молока. Почему бы вам не смешать это с виски, а?"
	color = "#DFD7AF" // rgb: 223, 215, 175
	drink_name = "Glass of cream"
	drink_desc = "A glass of cream, a mix of higher-fat fractions of milk that have been skimmed off. Occasionally drunk straight, but more often used as a mixer or culinary ingrediant."
	taste_description = "сливок"

/datum/reagent/consumable/drink/milk/chocolate_milk
	name = "Chocolate milk"
	id ="chocolate_milk"
	description = "Молоко с шоколадом. Прямо как в детстве."
	color = "#85432C"
	drink_name = "Chocolate milk"
	taste_description = "шоколадного сока"

/datum/reagent/consumable/drink/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Сделано с любовью! И какао-бобами."
	color = "#403010" // rgb: 64, 48, 16
	adj_temp_hot = 5
	drink_icon = "hot_coco"
	drink_name = "Glass of hot coco"
	drink_desc = "Delicious and cozy."
	taste_description = "горячего шоколада"

/datum/reagent/consumable/drink/coffee
	name = "Coffee"
	id = "coffee"
	description = "Кофе — это напиток, приготовленный из обжаренных семян кофейного растения, которые обычно называют какао-бобами."
	color = "#482000" // rgb: 72, 32, 0
	nutriment_factor = 0
	adj_dizzy = -10 SECONDS
	adj_drowsy = -6 SECONDS
	adj_sleepy = -4 SECONDS
	adj_temp_hot = 25
	overdose_threshold = 45
	addiction_chance = 1 // It's true.
	addiction_threshold = 200
	minor_addiction = TRUE
	addict_supertype = /datum/reagent/consumable/drink/coffee
	heart_rate_increase = 1
	drink_icon = "glass_brown"
	drink_name = "Glass of coffee"
	drink_desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."
	taste_description = "кофе"

/datum/reagent/consumable/drink/coffee/New()
	addict_supertype = /datum/reagent/consumable/drink/coffee

/datum/reagent/consumable/drink/coffee/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustStaminaLoss(-1, FALSE)
	if(holder.has_reagent("frostoil"))
		holder.remove_reagent("frostoil", 5)
	return ..() | update_flags

/datum/reagent/consumable/drink/coffee/overdose_process(mob/living/target, severity)
	if(volume > 45)
		target.Jitter(10 SECONDS)
	if(volume > 50 && prob(10)) //10% to knockdown
		target.unbuckle_if_not_cuffed()
		target.Knockdown(2 SECONDS)
	return list(0, STATUS_UPDATE_NONE)

/datum/reagent/consumable/drink/coffee/icecoffee
	name = "Iced Coffee"
	id = "icecoffee"
	description = "Кофе со льдом, освежающе-бодрящий."
	color = "#102838" // rgb: 16, 40, 56
	adj_temp_hot = 0
	adj_temp_cool = 5
	drink_icon = "icedcoffeeglass"
	drink_name = "Iced Coffee"
	drink_desc = "A drink to perk you up and refresh you!"
	taste_description = "освежающе-холодного кофе"

/datum/reagent/consumable/drink/coffee/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	description = "Вкусный и бодрящий напиток. Самое то для чтения всех этих ваших левацких книжек."
	color = "#664300" // rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp_hot = 5
	drink_icon = "soy_latte"
	drink_name = "Soy Latte"
	drink_desc = "A nice and refrshing beverage while you are reading."
	taste_description = "фальшивого молочного кофе"

/datum/reagent/consumable/drink/coffee/soy_latte/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.SetSleeping(0)
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/coffee/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	description = "Вкусный и бодрящий напиток. Самое то для чтения книг."
	color = "#664300" // rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp_hot = 5
	drink_icon = "cafe_latte"
	drink_name = "Cafe Latte"
	drink_desc = "A nice, strong and refreshing beverage while you are reading."
	taste_description = "молочного кофе"

/datum/reagent/consumable/drink/coffee/cafe_latte/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.SetSleeping(0)
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/coffee/cafe_latte/cafe_mocha
	name = "Cafe Mocha"
	id = "cafe_mocha"
	description = "Идеальное сочетание кофе, молока и шоколада."
	color = "#673629"
	drink_name = "Cafe Mocha"
	drink_desc = "The perfect blend of coffee, milk, and chocolate."
	taste_description = "шоколадного кофе"

/datum/reagent/consumable/drink/tea
	name = "Tea"
	id = "tea"
	description = "Вкусный чёрный чай. Содержит полезные антиоксиданты!"
	color = "#101000" // rgb: 16, 16, 0
	nutriment_factor = 0
	adj_dizzy = -4 SECONDS
	adj_drowsy = -2 SECONDS
	adj_sleepy = -6 SECONDS
	adj_temp_hot = 20
	addiction_chance = 1
	addiction_chance_additional = 10
	addiction_threshold = 300
	minor_addiction = TRUE
	addict_supertype = /datum/reagent/consumable/drink/tea
	drink_icon = "glass_brown"
	drink_name = "Glass of Tea"
	drink_desc = "A glass of hot tea. Perhaps a cup with a handle would have been smarter?"
	taste_description = "горячего чая"

/datum/reagent/consumable/drink/tea/New()
	addict_supertype = /datum/reagent/consumable/drink/tea

/datum/reagent/consumable/drink/tea/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/tea/icetea
	name = "Iced Tea"
	id = "icetea"
	description = "Освежает и бодрит. Самое то в жаркий денёк."
	color = "#104038" // rgb: 16, 64, 56
	adj_temp_hot = 0
	adj_temp_cool = 5
	drink_icon = "icetea"
	drink_name = "Iced Tea"
	drink_desc = "No relation to a certain rap artist/ actor."
	taste_description = "холодного чая"

/datum/reagent/consumable/drink/bananahonk
	name = "Banana Honk"
	id = "bananahonk"
	description = "Напиток из клоунского рая."
	color = "#664300" // rgb: 102, 67, 0
	drink_icon = "bananahonkglass"
	drink_name = "Banana Honk"
	drink_desc = "A drink from Banana Heaven."
	taste_description = "бананов и веселья"

/datum/reagent/consumable/drink/bananahonk/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(HAS_TRAIT(src, TRAIT_COMIC) || is_monkeybasic(M))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/silencer
	name = "Silencer"
	id = "silencer"
	description = "Напиток из мимского рая."
	color = "#664300" // rgb: 102, 67, 0
	drink_icon = "silencerglass"
	drink_name = "Silencer"
	drink_desc = "A drink from mime Heaven."
	taste_description = "тишины"

/datum/reagent/consumable/drink/silencer/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && (M.job in list(JOB_TITLE_MIME)))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/chocolatepudding
	name = "Chocolate Pudding"
	id = "chocolatepudding"
	description = "Отличный десерт для любителей шоколада."
	color = "#800000"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "chocolatepudding"
	drink_name = "Chocolate Pudding"
	drink_desc = "A decadent chocolate dessert, in drinkable form."
	taste_description = "шоколадной массы"

/datum/reagent/consumable/drink/vanillapudding
	name = "Vanilla Pudding"
	id = "vanillapudding"
	description = "Отличный десерт для любителей ванили."
	color = "#FAFAD2"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "vanillapudding"
	drink_name = "Vanilla Pudding"
	drink_desc = "A rich vanilla dessert, in drinkable form."
	taste_description = "ванильной массы"

/datum/reagent/consumable/drink/cherryshake
	name = "Cherry Shake"
	id = "cherryshake"
	description = "Молочный коктейль со вкусом вишни."
	color = "#FFB6C1"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "cherryshake"
	drink_name = "Cherry Shake"
	drink_desc = "A cherry flavored milkshake."
	taste_description = "ягодного милк-шейка"

/datum/reagent/consumable/drink/bluecherryshake
	name = "Blue Cherry Shake"
	id = "bluecherryshake"
	description = "Экзотичный ягодный молочный коктейль."
	color = "#00F1FF"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "bluecherryshake"
	drink_name = "Blue Cherry Shake"
	drink_desc = "An exotic blue milkshake."
	taste_description = "голубики"

/datum/reagent/consumable/drink/pumpkin_latte
	name = "Pumpkin Latte"
	id = "pumpkin_latte"
	description = "Смесь тыквенного сока и кофе. Скорее всего, по неадекватно завышенной цене."
	color = "#F4A460"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	drink_icon = "pumpkin_latte"
	drink_name = "Pumpkin Latte"
	drink_desc = "A mix of coffee and pumpkin juice."
	taste_description = "дорогущего кофе для леваков"

/datum/reagent/consumable/drink/gibbfloats
	name = "Gibb Floats"
	id = "gibbfloats"
	description = "Мороженое, смешанное с Доктором Гиббом."
	color = "#B22222"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	drink_icon= "gibbfloats"
	drink_name = "Gibbfloat"
	drink_desc = "Dr. Gibb with ice cream on top."
	taste_description = "революции"

/datum/reagent/consumable/drink/pumpkinjuice
	name = "Pumpkin Juice"
	id = "pumpkinjuice"
	description = "Выжат из настоящей тыквы."
	color = "#FFA500"
	taste_description = "осени"

/datum/reagent/consumable/drink/blumpkinjuice
	name = "Blumpkin Juice"
	id = "blumpkinjuice"
	description = "Не выжат из настоящей тыквы."
	color = "#00BFFF"
	taste_description = "едкой рвоты"

/datum/reagent/consumable/drink/grape_soda
	name = "Grape soda"
	id = "grapesoda"
	description = "Любим детьми и трезвенниками."
	color = "#E6CDFF"
	taste_description = "виноградной газировки"

/datum/reagent/consumable/drink/coco/icecoco
	name = "Iced Cocoa"
	id = "icecoco"
	description = "Горячее какао со льдом, освежающий и прохладный."
	color = "#102838" // rgb: 16, 40, 56
	adj_temp_cool = 5
	drink_icon = "icedcoffeeglass"
	drink_name = "Iced Cocoa"
	drink_desc = "A sweeter drink to perk you up and refresh you!"
	taste_description = "освежающе-холодного какао"

/datum/reagent/consumable/drink/non_alcoholic_beer
	name = "Non-Alcoholic Beer"
	id = "noalco_beer"
	description = "Что может быть ещё более бессмысленным?"
	drink_icon = "alcohol_free_beer"
	drink_name = "Non-Alcoholic Beer"
	drink_desc = "What could be more pointless?"
	color = "#572c13"
	taste_description = "пива"

/datum/reagent/consumable/drink/laughsyrup
	name = "Laugh Syrup"
	description = "Сок, выжатый из смеющихся бобов. Шипучий и меняет вкус в зависимости от того, с чем его употребляют!"
	id = "laughsyrup"
	color = "#803280"
	nutriment_factor = 5 * REAGENTS_METABOLISM
	taste_mult = 2
	taste_description = "шипучей сладости"

/datum/reagent/consumable/drink/laughsyrup/on_mob_life(mob/living/M)
	if(prob(5))
		M.emote(pick("laugh", "giggle", "smile"))
	else if(prob(2))
		M.say(pick(list("Ха-ха!", "Хе-хе")))
