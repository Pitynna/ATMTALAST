/* For employment contracts and infernal contracts */

/obj/item/paper/contract
	throw_range = 3
	throw_speed = 3
	var/signed = FALSE
	var/datum/mind/target
	item_flags = NOBLUDGEON

/obj/item/paper/contract/Destroy(force)
	target = null
	return ..()

/obj/item/paper/contract/proc/update_text()
	return

/obj/item/paper/contract/update_icon_state()
	return

/obj/item/paper/contract/employment
	icon_state = "good_contract"
	signed = TRUE

/obj/item/paper/contract/employment/Initialize(mapload, mob/living/nOwner)
	. = ..()
	if(!nOwner || !nOwner.mind)
		return INITIALIZE_HINT_QDEL
	target = nOwner.mind
	update_text()
	GLOB.employmentContracts |= src

/obj/item/paper/contract/employment/update_text()
	name = "Employment Contract - [target]"
	info = "<center>Условия трудоустройства</center><br><br><br><br>Настоящий Договор заключён между [target] (в дальнейшем именуемый Раб) и корпорацией \"Нанотрейзен\" (в дальнейшем именуемой Вездесущим и полезным наблюдателем за человечеством). Договор вступает в силу с момента его подписания.\
	<br>Преамбула \
	<br>Раб, будучи рождённым естественным путём человеком (или иным гуманоидом), обладает навыками, которыми он может быть полезен Вездесущему и полезному наблюдателю за человечеством. Раб ищет трудоустройства в Вездесущем и полезном наблюдателе за человечеством.\
	<br>При этом Вездесущий и полезный наблюдатель за человечеством согласен иногда выплачивать Рабу вознаграждение, в обмен на его постоянную службу.\
	<br>Настоящим, принимая во внимание вышеперечисленные взаимные выгоды и прочие соображения, стороны взаимно договариваются о нижеследующем:\
	<br>В обмен на незначительные выплаты Раб соглашается работать на Вездесущего и полезного наблюдателя за человечеством до конца своей нынешней и всех своих будущих жизней.\
	<br>Кроме того, Раб соглашается передать право на владение своей душой отделу лояльности Вездесущего и полезного наблюдателя за человечеством.\
	<br>В случае, если передача души Раба невозможна, Раб вносит вместо неё залог.<br>Подписано,<br><i>[target]</i>"

/obj/item/paper/contract/employment/Destroy()
	GLOB.employmentContracts -= src
	. = ..()
