/obj/item/organ/internal/liver/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Эта принадлежала таярану."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_liver"
	alcohol_intensity = 1.4

/obj/item/organ/internal/eyes/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran eyeballs"
	desc = "Парный орган, отвечающий за зрение — восприятие света и его трансформацию в видимое изображение. Эти принадлежали таярану."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_eyes"
	colourblind_matrix = MATRIX_TAJ_CBLIND //The colour matrix parameter that the mob will receive when they get the disability.
	replace_colours = TRITANOPIA_COLOR_REPLACE
	see_in_dark = 8

/obj/item/organ/internal/ears/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали таярану."

/obj/item/organ/internal/heart/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran heart"
	desc = "Орган, качающий кровь или её заменяющую субстанцию по организму гуманоида. Это принадлежало таярану."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_heart-on"
	item_base = "tajaran_heart"

/obj/item/organ/internal/brain/tajaran
	species_type = /datum/species/tajaran
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Этот принадлежал таярану."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_brain"
	mmi_icon = 'icons/obj/species_organs/tajaran.dmi'

/obj/item/organ/internal/lungs/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали таярану."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_lungs"

/obj/item/organ/internal/kidneys/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали таярану."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_kidneys"

/obj/item/organ/external/tail/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran tail"
	desc = "Хвост. Этот принадлежал таярану."
	icon_name = "tajtail_s"
	max_damage = 20
