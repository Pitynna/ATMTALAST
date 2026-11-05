/obj/machinery/cooker/cerealmaker
	name = "cereal maker"
	desc = "Now with Dann O's available!"
	icon = 'icons/obj/machines/cooking_machines.dmi'
	icon_state = "cereal_off"
	thiscooktype = "cereal"
	cooktime = 200
	onicon = "cereal_on"
	officon = "cereal_off"

/obj/machinery/cooker/cerealmaker/setIcon(obj/item/copyme, obj/item/copyto)
	var/image/img = new(copyme.icon, copyme.icon_state)
	img.transform *= 0.7
	copyto.add_overlay(img)
	copyto.copy_overlays(copyme)

/obj/machinery/cooker/cerealmaker/changename(obj/item/name, obj/item/setme)
	setme.name = "[name.name] cereal box"
	setme.desc = "[name.desc] It has been processed into [thiscooktype]."

/obj/machinery/cooker/cerealmaker/gettype()
	var/obj/item/reagent_containers/food/snacks/cereal/type = new(get_turf(src))
	return type
