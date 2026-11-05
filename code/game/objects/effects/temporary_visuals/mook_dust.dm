/obj/effect/temp_visual/mook_dust
	name = "dust"
	desc = "It's just a cloud of dust!"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "mook_leap_cloud"
	layer = BELOW_MOB_LAYER
	pixel_x = -16
	pixel_y = -16
	base_pixel_y = -16
	base_pixel_x = -16

/obj/effect/temp_visual/mook_dust/small

/obj/effect/temp_visual/mook_dust/small/Initialize(mapload)
	. = ..()
	transform = transform.Scale(0.5)
