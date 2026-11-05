/obj/structure/sign
	icon = 'icons/obj/decals.dmi'
	anchored = TRUE
	layer = NOT_HIGH_OBJ_LAYER
	max_integrity = 100
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)
	var/does_emissive = FALSE
	var/random_number = FALSE
	var/buildable_sign = TRUE

/obj/structure/sign/Initialize(mapload)
	. = ..()
	if(does_emissive || random_number)
		update_icon(UPDATE_OVERLAYS)

/obj/structure/sign/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	switch(held_item?.tool_behaviour)
		if(TOOL_WELDER)
			context[SCREENTIP_CONTEXT_LMB] = "Repair"
			return CONTEXTUAL_SCREENTIP_SET
		if(TOOL_SCREWDRIVER)
			if(!buildable_sign)
				return ///Cannot be unfastened regardless.
			context[SCREENTIP_CONTEXT_LMB] = "Unfasten"
			return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/structure/sign/update_overlays()
	. = ..()

	underlays.Cut()
	if(does_emissive)
		underlays += emissive_appearance(icon, "[icon_state]_lightmask", src)
	if(random_number)
		add_overlay(mutable_appearance(icon, "_num[pick("0","1","2","3","4","5","6","7","8","9","10","inf")]"))

/obj/structure/sign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/weapons/slash.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, TRUE)

/obj/structure/sign/screwdriver_act(mob/user, obj/item/I)
	if(!buildable_sign)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	balloon_alert(user, "откручено")
	deconstruct(TRUE)

/obj/structure/sign/deconstruct(disassembled)
	var/obj/item/sign/S = new(src.loc)
	S.name = name
	S.desc = desc
	S.icon_state = icon_state
	//var/icon/I = icon('icons/obj/decals.dmi', icon_state)
	//S.icon = I.Scale(24, 24)
	S.sign_state = icon_state
	qdel(src)

/obj/item/sign
	name = "sign"
	desc = ""
	icon = 'icons/obj/decals.dmi'
	resistance_flags = FLAMMABLE
	var/sign_state = ""

/obj/item/sign/screwdriver_act(mob/living/user, obj/item/I)
	if(!isturf(loc))
		return

	var/direction = tgui_input_list(usr, "В каком направлении?", "Выбор направления", list("Север", "Восток", "Юг", "Запад", "Отмена"))
	if(direction == "Отмена")
		return TRUE // These gotta be true or we stab the sign
	if(QDELETED(src))
		return TRUE // Unsure about this, but stabbing something that doesnt exist seems like a bad idea

	var/obj/structure/sign/sign = new(loc)
	switch(direction)
		if("Север")
			sign.pixel_y = 32
		if("Восток")
			sign.pixel_x = 32
		if("Юг")
			sign.pixel_y = -32
		if("Запад")
			sign.pixel_x = -32
		else
			return TRUE // We dont want to stab it or place it, so we return
	sign.name = name
	sign.desc = desc
	sign.icon_state = sign_state
	balloon_alert(user, "прикручено")
	qdel(src)
	return TRUE

/obj/structure/sign/double/map
	name = "station map"
	desc = "A framed picture of the station."
	max_integrity = 500
	build

/obj/structure/sign/double/map/left
	icon_state = "map-left"

/obj/structure/sign/double/map/right
	icon_state = "map-right"

/obj/structure/sign/double/no_idiots
	name = "Counting sign"
	desc = "Indicates how many days the station operates without idiots at the SuperMatter crystal control panel"

/obj/structure/sign/double/no_idiots/left
	icon_state = "no_idiots_left"
	random_number = TRUE

/obj/structure/sign/double/no_idiots/right
	icon_state = "no_idiots_right"

/obj/structure/sign/securearea
	name = "\improper SECURE AREA"
	desc = "WARNING: High-Security area! Identification MUST be worn at all times."
	icon_state = "securearea"

/obj/structure/sign/biohazard
	name = "\improper BIOHAZARD"
	desc = "DANGER: BIOLOGICAL HAZARD. Biological PPE is REQUIRED past this point!"
	icon_state = "bio"

/obj/structure/sign/electricshock
	name = "\improper HIGH VOLTAGE"
	desc = "DANGER OF DEATH: HIGH VOLTAGE. Electrical PPE is REQUIRED before coming into contact with energized equipment!"
	icon_state = "shock"

/obj/structure/sign/examroom
	name = "\improper EXAM"
	desc = "A guidance sign which reads 'EXAM ROOM'"
	icon_state = "examroom"

/obj/structure/sign/vacuum
	name = "\improper HARD VACUUM AHEAD"
	desc = "DANGER OF DEATH: Breathing apparatus and pressure suit required beyond this point."
	icon_state = "space"

/obj/structure/sign/vacuum/external
	name = "\improper EXTERNAL AIRLOCK"
	desc = "A warning sign which reads 'EXTERNAL AIRLOCK'."
	layer = MOB_LAYER

/obj/structure/sign/deathsposal
	name = "\improper DISPOSAL LEADS TO SPACE"
	desc = "A warning sign which reads 'DISPOSAL LEADS TO SPACE'"
	icon_state = "deathsposal"

/obj/structure/sign/pods
	name = "\improper ESCAPE PODS"
	desc = "A warning sign which reads 'ESCAPE PODS'"
	icon_state = "pods"

/obj/structure/sign/fire
	name = "\improper DANGER: FIRE"
	desc = "A warning sign which reads 'DANGER: FIRE'."
	icon_state = "fire"
	resistance_flags = FIRE_PROOF

/obj/structure/sign/nosmoking_1
	name = "\improper NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'"
	icon_state = "nosmoking"
	resistance_flags = FLAMMABLE

/obj/structure/sign/nosmoking_2
	name = "\improper NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'"
	icon_state = "nosmoking2"

/obj/structure/sign/radiation
	name = "\improper RADIOLOGICALLY SUPERVISED AREA"
	desc = "WARNING: Low level radiation may be present. Ensure your dose level remains below exposure limits."
	icon_state = "radiation"

/obj/structure/sign/radiation/rad_area
	name = "\improper RADIOLOGICALLY CONTROLLED AREA"
	desc = "DANGER: High levels of radiation may be present. Radiological PPE is REQUIRED beyond this point."

/obj/structure/sign/xeno_warning_mining
	name = "DANGEROUS ALIEN LIFE"
	desc = "A sign that warns would be travellers of hostile alien life in the vicinity."
	icon = 'icons/obj/mining.dmi'
	icon_state = "xeno_warning"

/obj/structure/sign/medbay
	name = "\improper MEDBAY"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here."
	icon_state = "lifestar"

/obj/structure/sign/medbay/redcross
	icon_state = "redcross"

/obj/structure/sign/medbay/greencross
	icon_state = "greencross"

/obj/structure/sign/goldenplaque
	name = "The Most Robust Men Award for Robustness"
	desc = "To be Robust is not an action or a way of life, but a mental state. Only those with the force of Will strong enough to act during a crisis, saving friend from foe, are truly Robust. Stay Robust my friends."
	icon_state = "goldenplaque"

/obj/structure/sign/kiddieplaque
	name = "AI developers plaque"
	desc = "Next to the extremely long list of names and job titles, there is a drawing of a little child. The child's eyes are crossed, and is drooling. Beneath the image, someone has scratched the word \"PACKETS\"."
	icon_state = "kiddieplaque"

/obj/structure/sign/atmosplaque
	name = "\improper ZAS Atmospherics Division plaque"
	desc = "This plaque commemorates the fall of the Atmos ZAS division. For all the charred, dizzy, and brittle men who have died in its horrible hands."
	icon_state = "atmosplaque"

/obj/structure/sign/beautyplaque
	name = "The Most Beautiful Woman Award for Beauty"
	desc = "Don't think, feel! It's like pointing your finger at the singularity. Don't concentrate on your finger, or you'll miss this divine beauty."
	icon_state = "beautyplaque"

/obj/structure/sign/kidanplaque
	name = "Kidan wall trophy"
	desc = "A dead and stuffed Diona nymph, mounted on a board."
	icon_state = "kidanplaque"

/obj/structure/sign/tajarplaque
	name = "Tajaran wall plaque"
	desc = "A nice tajaran photo, mounted on a board."
	icon_state = "tajarplaque"

/obj/structure/sign/mech
	name = "mech painting"
	desc = "A painting of a mech."
	icon_state = "mech"

/obj/structure/sign/nuke
	name = "nuke painting"
	desc = "A painting of a nuke."
	icon_state = "nuke"

/obj/structure/sign/clown
	name = "clown painting"
	desc = "A painting of the clown and mime. Awwww."
	icon_state = "clown"

/obj/structure/sign/bobross
	name = "calming painting"
	desc = "We don't make mistakes, just happy little accidents."
	icon_state = "bob"

/obj/structure/sign/singulo
	name = "singulo painting"
	desc = "A mesmerizing painting of a singularity. It seems to suck you in..."
	icon_state = "singulo"

/obj/structure/sign/barber
	name = "barber shop sign"
	desc = "A spinning sign indicating a barbershop is near."
	icon_state = "barber"
	does_emissive = TRUE

/obj/structure/sign/chinese
	name = "chinese restaurant sign"
	desc = "A glowing dragon invites you in."
	icon_state = "chinese"
	does_emissive = TRUE

/obj/structure/sign/bathhouse
	name = "\improper bathhouse sign"
	desc = "An old but serviceable sign depicting bathhouse equipment."
	icon_state = "banya"

/obj/structure/sign/science
	name = "\improper SCIENCE!"
	desc = "The science department, supposedly the entire reason that this station exists is because of the research done here."
	icon_state = "science1"

/obj/structure/sign/chemistry
	name = "\improper CHEMISTRY"
	desc = "A warning sign which reads 'CHEMISTRY'"
	icon_state = "chemistry1"

/obj/structure/sign/botany
	name = "\improper HYDROPONICS"
	desc = "A warning sign which reads 'HYDROPONICS'"
	icon_state = "hydro1"

/obj/structure/sign/xenobio
	name = "\improper XENOBIOLOGY"
	desc = "A sign labelling an area as a place where xenobiological entities are researched."
	icon_state = "xenobio"

/obj/structure/sign/xenobio/slime
	icon_state = "xenobio2"

/obj/structure/sign/evac
	name = "\improper EVACUATION"
	desc = "A sign labelling an area where evacuation procedures take place."
	icon_state = "evac"

/obj/structure/sign/drop
	name = "\improper DROP PODS"
	desc = "A sign labelling an area where drop pod loading procedures take place."
	icon_state = "drop"

/obj/structure/sign/doors
	name = "AIRLOCKS"
	desc = "A sign marking an area where airlocks may close suddenly."
	icon_state = "doors"

/obj/structure/sign/custodian
	name = "\improper CUSTODIAN"
	desc = "A sign labelling an area where the custodian works."
	icon_state = "custodian"

/obj/structure/sign/engineering
	name = "\improper ENGINEERING"
	desc = "Home to the vital systems that keep the station running. Sometimes you'll even find some engineers in here too!"
	icon_state = "engine"

/obj/structure/sign/cargo
	name = "\improper CARGO"
	desc = "The logistical heart of the station, handling incoming supply shipments, salvage, and minerals. Oh, and mail too."
	icon_state = "cargo"

/obj/structure/sign/med
	name = "\improper MEDBAY"
	desc = "A sign labelling an area where heal is real."
	icon_state = "med"

/obj/structure/sign/comand
	name = "\improper BRIDGE"
	desc = "A sign labelling an area where all heads drinks."
	icon_state = "comand"

/obj/structure/sign/security
	name = "\improper SECURITY"
	desc = "This is Security's turf. Better behave yourself around here."
	icon_state = "security"

/obj/structure/sign/holy
	name = "\improper HOLY"
	desc = "A sign labelling a religious area."
	icon_state = "holy"

/obj/structure/sign/restroom
	name = "\improper RESTROOM"
	desc = "A sign labelling a restroom."
	icon_state = "restroom"

/obj/structure/sign/directions/floor
	name = "\improper Floor"
	desc = "A direction sign, pointing out which floor you are."
	icon_state = "level"

/obj/structure/sign/directions/floor/alt
	icon_state = "level_alt"

/obj/structure/sign/directions/science
	name = "\improper Research Division"
	desc = "A direction sign, pointing out which way the Research Division is."
	icon_state = "direction_sci"

/obj/structure/sign/directions/engineering
	name = "\improper Engineering Department"
	desc = "A direction sign, pointing out which way the Engineering Department is."
	icon_state = "direction_eng"

/obj/structure/sign/directions/security
	name = "\improper Security Department"
	desc = "A direction sign, pointing out which way the Security Department is."
	icon_state = "direction_sec"

/obj/structure/sign/directions/medical
	name = "\improper Medical Bay"
	desc = "A direction sign, pointing out which way the Medical Bay is."
	icon_state = "direction_med"

/obj/structure/sign/directions/evac
	name = "\improper Escape Arm"
	desc = "A direction sign, pointing out which way the Escape Shuttle Dock is."
	icon_state = "direction_evac"

/obj/structure/sign/directions/cargo
	name = "\improper Cargo Department"
	desc = "A direction sign, pointing out which way the Supply Department is."
	icon_state = "direction_supply"

/obj/structure/sign/explosives
	name = "\improper HIGH EXPLOSIVES"
	desc = "DANGER: High explosives in this area!"
	icon_state = "explosives"

/obj/structure/sign/explosives/alt
	icon_state = "explosives2"

/obj/structure/sign/cave
	name = "\improper Cave Johnson portrait"
	desc = "The beAn couNters tolD me we liteRally could not afford to buy sEven dollars worth of plasma rocks, much less seventY million. Bought 'em anyway. Engineers said the plasma rocks were too volatile to experiment on. Tested on 'em anyway. Ground 'em up, mixed em into a gel. And guess what? Ground up plasma rocks are pure poison. I am deathly ill. Still, it turns out they're a great fire hazard. We're done here."
	icon_state = "cave"


/obj/structure/sign/magboots
	name = "\improper MAG BOOTS"
	desc = "WARNING: Magboots are REQUIRED in this area!"
	icon_state = "magboots"

/obj/structure/sign/turbine
	name = "\improper TURBINE"
	desc = "DANGER OF DEATH: NO GUARD ON TURBINE INTAKE!"
	icon_state = "turbine"
