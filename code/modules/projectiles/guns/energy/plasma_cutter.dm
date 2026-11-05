// MARK: Generic
/obj/item/gun/energy/plasmacutter
	name = "plasma cutter"
	desc = "A mining tool capable of expelling concentrated plasma bursts. Its effectiveness drops dramatically outside of low-pressure environments. You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	icon_state = "plasmacutter"
	item_state = "plasmacutter"
	origin_tech = "combat=1;materials=3;magnets=2;plasmatech=3;engineering=1"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma)
	usesound = 'sound/items/welder.ogg'
	container_type = OPENCONTAINER
	attack_verb = list("атаковал", "полоснул", "порезал")
	force = 12
	sharp = 1
	can_charge = FALSE
	accuracy = GUN_ACCURACY_RIFLE
	heat = T3800K

/obj/item/gun/energy/plasmacutter/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("Заряд [get_examine_icon(user)] [declent_ru(GENITIVE)] [round(cell.percent())]%")

/obj/item/gun/energy/plasmacutter/get_temperature()
	return 3800

/obj/item/gun/energy/plasmacutter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/mineral/plasma))
		add_fingerprint(user)
		var/obj/item/stack/sheet/mineral/plasma/plasma = I
		if(cell.charge >= cell.maxcharge)
			balloon_alert(user, "заряд на максимуме!")
			return ATTACK_CHAIN_PROCEED
		if(!plasma.use(1))
			balloon_alert(user, "недостаточно плазмы!")
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "заряд увеличен")
		cell.give(1000)
		on_recharge()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/stack/ore/plasma))
		add_fingerprint(user)
		var/obj/item/stack/ore/plasma/plasma = I
		if(cell.charge >= cell.maxcharge)
			balloon_alert(user, "заряд на максимуме!")
			return ATTACK_CHAIN_PROCEED
		if(!plasma.use(1))
			balloon_alert(user, "недостаточно плазмы!")
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "заряд увеличен")
		cell.give(500)
		on_recharge()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/gun/energy/plasmacutter/update_overlays()
	return list()

// MARK: Advanced
/obj/item/gun/energy/plasmacutter/adv
	name = "advanced plasma cutter"
	icon_state = "adv_plasmacutter"
	item_state = "adv_plasmacutter"
	origin_tech = "combat=3;materials=4;magnets=3;plasmatech=4;engineering=2"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/adv)
	force = 15
	accuracy = GUN_ACCURACY_SNIPER

/obj/item/gun/energy/plasmacutter/adv/mega
	name = "magmite plasma cutter"
	icon_state = "adv_plasmacutter_m"
	item_state = "plasmacutter_mega"
	desc = "A mining tool capable of expelling concentrated plasma bursts. You could use it to cut limbs off xenos! Or, you know, mine stuff. This one has been enhanced with plasma magmite."
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/adv/mega)
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/gun/energy/plasmacutter/shotgun
	name = "plasma cutter shotgun"
	desc = "An industrial-grade, heavy-duty mining shotgun."
	icon_state = "miningshotgun"
	item_state = "miningshotgun"
	origin_tech = "combat=5;materials=5;magnets=5;plasmatech=6;engineering=5"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/shotgun)
	force = 10
	accuracy = GUN_ACCURACY_SHOTGUN

/obj/item/gun/energy/plasmacutter/shotgun/mega
	name = "magmite plasma cutter shotgun"
	icon_state = "miningshotgun_mega"
	item_state = "miningshotgun_mega"
	desc = "An industrial-grade, heavy-duty mining shotgun. This one seems upgraded with plasma magmite."
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/shotgun/mega)
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
