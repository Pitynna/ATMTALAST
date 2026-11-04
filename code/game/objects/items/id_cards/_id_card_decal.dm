/obj/item/id_decal
	name = "identification card decal"
	desc = "A nano-cellophane wrap that molds to an ID card to make it look snazzy."
	icon = 'icons/obj/toy.dmi'
	icon_state = "id_decal"
	gender = FEMALE
	var/decal_desc = "Стандартная идентификационная карта персонала \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	var/decal_icon_state = "id"
	var/decal_item_state = "card-id"
	var/override_name = 0

/obj/item/id_decal/gold
	name = "gold ID card decal"
	icon_state = "id_decal_gold"
	desc = "Make your ID look like the Captain's or a self-centered HOP's. Applies to any ID."
	decal_desc = "Идентификационная карта персонала \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника. \
			Уникальная золотая отделка подчёркивает власть и могущество владельца."
	decal_icon_state = "gold"
	decal_item_state = "gold-id"

/obj/item/id_decal/silver
	name = "silver ID card decal"
	icon_state = "id_decal_silver"
	desc = "Make your ID look like HOP's because they wouldn't change it officially. Applies to any ID."
	decal_desc = "Идентификационная карта персонала \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника. \
			Уникальная серебряная отделка подчёркивает высокий статус владельца."
	decal_icon_state = "silver"
	decal_item_state = "silver-id"

/obj/item/id_decal/prisoner
	name = "prisoner ID card decal"
	icon_state = "id_decal_prisoner"
	desc = "All the cool kids have an ID that's this color. Applies to any ID."
	decal_desc = "Идентификационная карта для заключённых \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	decal_icon_state = "prisoner"
	decal_item_state = "orange-id"

/obj/item/id_decal/clown
	name = "prisoner ID card decal"
	desc = "All the cool kids have an ID that's this color. Applies to any ID."
	decal_icon_state = "clown"
	decal_item_state = "clown-id"

/obj/item/id_decal/centcom
	name = "centcom ID card decal"
	icon_state = "id_decal_centcom"
	desc = "All the prestige without the responsibility or the access. Applies to any ID."
	decal_desc = "Стандартная идентификационная карта персонала Центрального Командования \"Нанотрейзен\" в секторе \"Эпсилон Лукусты\". \
			Служит для подтверждения личности, определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	decal_icon_state = "centcom"

/obj/item/id_decal/emag
	name = "cryptographic sequencer ID card decal"
	icon_state = "id_decal_emag"
	desc = "A bundle of wires that you can tape to your ID to look very suspect. Applies to any ID."
	decal_desc = "ID-карта \"Нанотрейзен\" с прикреплённой магнитной лентой и какими-то микросхемами. \
			Судя по всему, это устройство предназначено для взлома систем безопасности электронных устройств."
	decal_icon_state = "emag"
	override_name = 1

/obj/item/id_decal/federal
	name = "federal ID card decal"
	icon_state = "id_decal_federal"
	desc = "A nanocellophane wrapper that conforms to an ID card. Purely cosmetic. Makes your card identify you as a citizen of the TSF."
	decal_desc = "Стандартная идентификационная карта персонала \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника. \
			Оформлена в цветах Транс-Солнечной Федерации."
	decal_icon_state = "federal"
	decal_item_state = "federal-id"

/obj/item/id_decal/comrad
	name = "comrad ID card decal"
	icon_state = "id_decal_comrad"
	desc ="A nanocellophane wrapper that conforms to an ID card. Purely cosmetic. Makes your card identify you as a citizen of the USSP."
	decal_desc = "Стандартная идентификационная карта персонала \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника. \
			Оформлена в цветах Союза Советских Социалистических Планет."
	decal_icon_state = "comrad"
	decal_item_state = "comrad-id"

/obj/item/id_decal/syndie
	name = "syndie ID card decal"
	icon_state = "id_decal_syndie"
	desc = "A nanocellophane wrapper that conforms to an ID card. Purely cosmetic. Makes your card look as if it belongs to a Syndicate employee."
	decal_desc = "Стандартная идентификационная карта персонала \"Синдиката\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	decal_icon_state = "syndieciv"
	decal_item_state = "syndieciv-id"

/proc/get_station_card_skins()
	return list(
		"data",
		"id",
		"gold",
		"silver",
		"security",
		"cadet",
		"medical",
		"intern",
		"research",
		"student",
		"cargo",
		"mining_medic",
		"engineering",
		"trainee",
		"HoS",
		"CMO",
		"RD",
		"CE",
		"clown",
		"mime",
		"rainbow",
		"prisoner",
	)

/proc/get_centcom_card_skins()
	return list(
		"centcom",
		"centcom_old",
		"nanotrasen",
		"ERT_leader",
		"ERT_empty",
		"ERT_security",
		"ERT_engineering",
		"ERT_medical",
		"ERT_janitorial",
		"deathsquad",
		"commander",
		"syndie",
		"TDred",
		"TDgreen",
	)

/proc/get_all_card_skins()
	return get_station_card_skins() + get_centcom_card_skins()

/proc/get_skin_desc(skin)
	switch(skin)
		if("id")
			return "Стандарт"
		if("data")
			return "Пустая"
		if("gold")
			return "Золотая"
		if("silver")
			return "Серебряная"
		if("security")
			return "Безопасность"
		if("cadet")
			return "Кадет"
		if("medical")
			return "Медицина"
		if("intern")
			return "Интерн"
		if("research")
			return "Наука"
		if("student")
			return "Студент"
		if("engineering")
			return "Инженерия"
		if("trainee")
			return "Стажёр"
		if("clown")
			return "Клоун"
		if("mime")
			return "Мим"
		if("rainbow")
			return "Радужная"
		if("prisoner")
			return "Заключённый"
		if("cargo")
			return "Снабжение"
		if("HoS")
			return "Глава Службы Безопасности"
		if("CMO")
			return "Главный Врач"
		if("RD")
			return "Научный Директор"
		if("CE")
			return "Главный Инженер"
		if("centcom_old")
			return "Центком (Старая)"
		if("ERT_leader")
			return "Командир ОБР"
		if("ERT_empty")
			return "ОБР (Стандарт)"
		if("ERT_security")
			return "ОБР (Безопасность)"
		if("ERT_engineering")
			return "ОБР (Инженерия)"
		if("ERT_medical")
			return "ОБР (Медицина)"
		if("ERT_janitorial")
			return "ОБР (Санитария)"
		if("syndie")
			return "Синдикат"
		if("TDred")
			return "Тандердом (Красная)"
		if("TDgreen")
			return "Тандердом (Зелёная)"
		if("mining_medic")
			return "Шахтёрский врач"
		else
			return capitalize(skin)
