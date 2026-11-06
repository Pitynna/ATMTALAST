// Player-obtainable hyntatmta clothing. Sources and exclusions: docs/ATMTA_PORT.md.

/obj/item/clothing/head/atmta
	icon = 'icons/obj/clothing/atmta/hats.dmi'
	sprite_sheets = null
	onmob_sheets = list(ITEM_SLOT_HEAD_STRING = 'icons/mob/clothing/atmta/head.dmi')

/obj/item/clothing/suit/atmta
	icon = 'icons/obj/clothing/atmta/suits.dmi'
	sprite_sheets = null
	onmob_sheets = list(ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/atmta/suit.dmi')

/obj/item/clothing/under/atmta
	icon = 'icons/obj/clothing/atmta/uniforms.dmi'
	sprite_sheets = null
	onmob_sheets = list(ITEM_SLOT_CLOTH_INNER_STRING = 'icons/mob/clothing/atmta/uniform.dmi')

/obj/item/clothing/gloves/atmta
	icon = 'icons/obj/clothing/atmta/gloves.dmi'
	sprite_sheets = null
	onmob_sheets = list(ITEM_SLOT_GLOVES_STRING = 'icons/mob/clothing/atmta/hands.dmi')

/obj/item/clothing/shoes/atmta
	icon = 'icons/obj/clothing/atmta/shoes.dmi'
	sprite_sheets = null
	onmob_sheets = list(ITEM_SLOT_FEET_STRING = 'icons/mob/clothing/atmta/feet.dmi')

/obj/item/clothing/suit/atmta/space
	parent_type = /obj/item/clothing/suit/space
	icon = 'icons/obj/clothing/atmta/suits.dmi'
	sprite_sheets = null
	onmob_sheets = list(ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/atmta/suit.dmi')
	rad_insulation = 0.5

/obj/item/clothing/gloves/atmta/biker
	name = "Biker's Gloves"
	desc = "Stylish blue gloves"
	icon_state = "biker"
	item_state = "biker"
	item_color = "biker"

/obj/item/clothing/gloves/atmta/dio
	name = "DIO's metal wristbands"
	desc = "These wristbands look fabulous, it's useless useless useless to deny."
	icon_state = "DIO"
	item_state = "DIO"
	item_color = "DIO"

/obj/item/clothing/head/atmta/biker
	name = "Biker's Helmet"
	desc = "This helmet should protect you from russians and masked vigilantes."
	armor = list(MELEE = 25, BULLET = 15, LASER = 20, ENERGY = 10, BOMB = 10, BIO = 0, )
	icon_state = "biker"
	item_state = "biker"
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME|HIDEHAIR

/obj/item/clothing/head/atmta/dio
	name = "DIO's heart headband"
	desc = "Why is there a heart on this headband? The World may never know."
	icon_state = "DIO"
	item_state = "DIO"

/obj/item/clothing/head/atmta/dornan
	name = "Sergeant's helmet"
	desc = "This helmet's appearance will make you cry."
	icon_state = "dornan"
	item_state = "dornan"
	armor = list(MELEE = 15, BULLET = 40, LASER = 10, ENERGY = 10, BOMB = 40, BIO = 0, )
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME|HIDEHAIR

/obj/item/clothing/head/atmta/kung
	name = "Kung headband"
	desc = "Stripe of red cloth. You can wear it on your head."
	icon_state = "kung_headband"
	item_state = "kung_headband"

/obj/item/clothing/head/atmta/richard
	name = "Richard"
	desc = "Do you like hurting people?"
	icon_state = "richard"
	item_state = "richard"
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME|HIDEHAIR

/obj/item/clothing/head/atmta/slastena
	name = "Slastena's hair"
	desc = "Made of genuine cotton candy"
	icon_state = "slastena"
	item_state = "slastena"
	flags_inv = HIDEHAIR

/obj/item/clothing/shoes/atmta/biker
	name = "Biker's shoes"
	desc = "Stylish white shoes"
	icon_state = "biker"
	item_state = "biker"

/obj/item/clothing/shoes/atmta/dio
	name = "DIO's ring shoes"
	desc = "These help you stand."
	icon_state = "DIO"
	item_color = "DIO"
	item_state = "DIO"

/obj/item/clothing/shoes/atmta/kung
	name = "Kung shoes"
	desc = "Pair of a high red shoes."
	icon_state = "kung_shoes"
	item_state = "kung_shoes"

/obj/item/clothing/shoes/atmta/slastena
	name = "Slastena's shoes"
	desc = "Well... That's pink ballet shoes."
	icon_state = "slastena"
	item_state = "slastena"

/obj/item/clothing/suit/atmta/dio
	name = "DIO's yellow jacket"
	desc = "So fashionable it's menacing."
	icon_state = "DIO"
	item_state = "DIO"

/obj/item/clothing/suit/atmta/fullmetal
	name = "Alchemist's suit"
	desc = "Full-metal jacket (not really)"
	icon_state = "alchrobe"
	item_state = "alchrobe"
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/atmta/kung
	name = "Kung jacket"
	desc = "Leather jaket with an old security badge attached to it"
	icon_state = "kung_jacket"
	item_state = "kung_jacket"

/obj/item/clothing/suit/atmta/mechanicus
	name = "Adeptus Mechanicus robes"
	desc = "Sweet ol'grim dark future."
	icon_state = "adeptus"
	item_state = "adeptus"
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/atmta/oldsnake
	name = "Old Man's sneaking suit"
	desc = "Cigs and octocamos not included."
	icon_state = "sneakmans"
	item_state = "sneakmans"
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/atmta/phantomblood
	name = "Dio Brando's ancient outfit"
	desc = "From the good ol'times when mask can get you STONED."
	icon_state = "vclothes"
	item_state = "vclothes"
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/atmta/scorpiojacket
	name = "Scorpio Jacket"
	desc = "Stylish white satin jacket with a scorpion embroidered on the back."
	icon_state = "scorpio_jacket"
	item_state = "scorpio_jacket"

/obj/item/clothing/suit/atmta/simoncoat
	name = "NT's Honorable long coat"
	desc = "For those men who pierced the sky out."
	icon_state = "simon_coat"
	item_state = "simon_coat"

/obj/item/clothing/suit/atmta/space/hev
	name = "HEV suit"
	desc = "It will save you from the products of half-life"
	icon_state = "hev"
	item_state = "hev"
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/atmta/sundowner
	name = "armoured greatcoat"
	desc = "An oversized black greatcoat, it makes you feel fucking invincible."
	icon_state = "sundowner_coat_allblack"
	item_state = "sundowner_coat_allblack"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 0, )
	flags_inv = HIDEJUMPSUIT
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	strip_delay = 80
	allowed = list(/obj/item/gun/energy, /obj/item/gun/projectile, /obj/item/reagent_containers/spray/pepper, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/flashlight/seclite, /obj/item/kitchen/knife/combat)

/obj/item/clothing/under/atmta/biker
	name = "Biker's outfit"
	desc = "Blue jeans with pink jacket"
	icon_state = "biker"
	item_state = "biker"
	item_color = "biker"

/obj/item/clothing/under/atmta/cia
	name = "casual IAA outfit"
	desc = "Just looking at this makes you feel in charge."
	icon_state = "CIA"
	item_state = "CIA"
	item_color = "CIA"

/obj/item/clothing/under/atmta/clubskirt
	name = "literature club skirt"
	desc = "Welcome to the club, buddy"
	icon_state = "clubskirt"
	item_state = "clubskirt"
	item_color = "clubskirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/atmta/dio
	name = "DIO's backless vest"
	desc = "Walk into the room wearing this, everyone stops."
	icon_state = "DIO"
	item_state = "DIO"
	item_color = "DIO"

/obj/item/clothing/under/atmta/jacketsuit
	name = "Richard's outfit"
	desc = "Do you know what time it is?"
	icon_state = "jacket"
	item_state = "jacket"
	item_color = "jacket"

/obj/item/clothing/under/atmta/kung
	name = "Kung Jeans"
	desc = "Pair of old jeans combined with a red tank-top"
	icon_state = "kung_suit"
	item_state = "kung_suit"
	item_color = "kung_suit"

/obj/item/clothing/under/atmta/slastena
	name = "Slastena's dress"
	desc = "Pink and cyan. Cute and formal."
	icon_state = "slastena"
	item_state = "slastena"
	item_color = "slastena"
