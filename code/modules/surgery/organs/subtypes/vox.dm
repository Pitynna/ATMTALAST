/obj/item/organ/internal/liver/vox
	species_type = /datum/species/vox
	name = "vox liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Эта принадлежала воксу."
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_liver"
	alcohol_intensity = 1.6
	sterile = TRUE

/obj/item/organ/internal/eyes/vox
	species_type = /datum/species/vox
	name = "vox eyeballs"
	desc = "Парный орган, отвечающий за зрение — восприятие света и его трансформацию в видимое изображение. Эти принадлежали воксу."
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_eyes"
	sterile = TRUE

/obj/item/organ/internal/ears/vox
	species_type = /datum/species/vox
	name = "vox ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали воксу."

/obj/item/organ/internal/heart/vox
	species_type = /datum/species/vox
	name = "vox heart"
	desc = "Орган, качающий кровь или её заменяющую субстанцию по организму гуманоида. Это принадлежало воксу."
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_heart-on"
	item_base = "vox_heart"
	sterile = TRUE

/obj/item/organ/internal/brain/vox
	species_type = /datum/species/vox
	name = "cortical stack"
	desc = "A peculiarly advanced bio-electronic device that seems to hold the memories and identity of a Vox."
	icon = 'icons/obj/species_organs/vox.dmi'
	icon_state = "cortical-stack"
	item_state = "vox_cortical-stack"
	mmi_icon = 'icons/obj/species_organs/vox.dmi'
	sterile = TRUE

/obj/item/organ/internal/kidneys/vox
	species_type = /datum/species/vox
	name = "vox kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали воксу."
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_kidneys"
	sterile = TRUE

/obj/item/organ/internal/lungs/vox
	name = "vox lungs"
	desc = "They're filled with dust....wow."
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_lungs"

	safe_oxygen_min = 0 //We don't breathe this
	safe_oxygen_max = 0.05 //This is toxic to us
	safe_nitro_min = 16 //We breathe THIS!
	oxy_damage_type = TOX //And it poisons us

/obj/item/organ/external/tail/vox
	species_type = /datum/species/vox
	name = "vox tail"
	desc = "Хвост. Этот принадлежал воксу."
	icon_name = "voxtail_s"
	max_damage = 25
	min_broken_damage = 20
