
//Bartender
/obj/item/clothing/head/chefhat
	name = "chef's hat"
	desc = "The commander in chef's headwear."
	icon_state = "chef"
	item_state = "chef"
	strip_delay = 10
	put_on_delay = 10
	dog_fashion = /datum/dog_fashion/head/chef

/obj/item/clothing/head/caphat
	name = "captain's hat"
	desc = "It's good being the king."
	gender = FEMALE
	icon_state = "captain"
	item_state = "caphat"
	armor = list(MELEE = 25, BULLET = 15, LASER = 25, ENERGY = 10, BOMB = 25, BIO = 0, FIRE = 50, ACID = 50)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/captain

/obj/item/clothing/head/caphat/parade
	name = "captain's parade cap"
	desc = "Worn only by Captains with an abundance of class."
	icon_state = "capcap"
	item_state = "capcap"
	dog_fashion = null

/obj/item/clothing/head/caphat/blue
	name = "captain's white parade cap"
	desc = "Белая капитанская фуражка с синими полосами. Такие фуражки носят исключительно важные персоны."
	icon_state = "cap_parade_alt"
	item_state = "cap_parade_alt"
	dog_fashion = null

/obj/item/clothing/head/caphat/office
	name = "captain's blue parade cap"
	desc = "Синяя капитанская фуражка с белыми полосами. Такие фуражки носят исключительно важные персоны."
	icon_state = "cap_office"
	item_state = "cap_office"
	dog_fashion = null

/obj/item/clothing/head/caphat/beret
	name = "captain's beret"
	desc = "For Captains that are more inclined towards style."
	gender = MALE
	icon_state = "cap_beret"
	item_state = "cap_beret"

/obj/item/clothing/head/hopcap
	name = "head of personnel's cap"
	desc = "The symbol of true bureaucratic micromanagement."
	gender = FEMALE
	icon_state = "hopcap"
	armor = list(MELEE = 25, BULLET = 15, LASER = 25, ENERGY = 10, BOMB = 25, BIO = 0, FIRE = 50, ACID = 50)
	dog_fashion = /datum/dog_fashion/head/hop

/obj/item/clothing/head/ntrep
	name = "Nanotrasen Representative's hat"
	desc = "A cap issued to Nanotrasen Representatives."
	gender = FEMALE
	icon_state = "ntrep"

/obj/item/clothing/head/beret/purple
	name = "scientist beret"
	desc = "A purple beret, with a small golden crescent moon sewn onto it."
	icon_state = "beret_purple"
	item_state = "purpleberet"

/obj/item/clothing/head/beret/purple/rd
	name = "research director's beret"
	desc = "A purple beret with a gold science insignia emblazoned on it. Stop your scientists blowing up your department in style."

/obj/item/clothing/head/hooded/chaplain_hood
	name = "chaplain's hood"
	desc = "It's hood that covers the head. It keeps you warm during the space winters."
	icon_state = "chaplain_hood"
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/hooded/chaplain_hood/no_name
	name = "dark robe's hood"
	flags_inv = parent_type::flags_inv|HIDENAME

/obj/item/clothing/head/hooded/nun_hood
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/hooded/monk_hood
	name = "monk hood"
	desc = "Wooden board not included."
	icon_state = "monk_hood"
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/witchhunter_hat
	name = "witchhunter hat"
	desc = "This hat saw much use back in the day."
	gender = FEMALE
	icon_state = "witchhunterhat"
	item_state = "witchhunterhat"
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/bishopmitre
	name = "bishop mitre"
	desc = "An opulent hat that functions as a radio to God. Or as a lightning rod, depending on who you ask."
	gender = FEMALE
	icon_state = "bishopmitre"
	item_state = "bishopmitre"

/obj/item/clothing/head/blackbishopmitre
	name = "black bishop mitre"
	desc = "An opulent hat that functions as a radio to God. Or as a lightning rod, depending on who you ask."
	gender = FEMALE
	icon_state = "blackbishopmitre"
	item_state = "blackbishopmitre"

/obj/item/clothing/head/det_hat
	name = "detective's hat"
	desc = "Someone who wears this will look very smart."
	gender = FEMALE
	icon_state = "detective"
	allowed = list(/obj/item/reagent_containers/food/snacks/candy/candy_corn, /obj/item/pen)
	armor = list(MELEE = 25, BULLET = 5, LASER = 25, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 30, ACID = 50)
	dog_fashion = /datum/dog_fashion/head/detective
	muhtar_fashion = /datum/muhtar_fashion/head/detective

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi',
	)

/obj/item/clothing/head/det_hat/black
	icon_state = "detective_coolhat_black"

/obj/item/clothing/head/det_hat/brown
	icon_state = "detective_coolhat_brown"

/obj/item/clothing/head/det_hat/grey
	icon_state = "detective_coolhat_grey"

//Mime
/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, an artist's favorite headwear."
	icon_state = "beret"
	dog_fashion = /datum/dog_fashion/head/beret

/obj/item/clothing/head/beret/durathread
	name = "durathread beret"
	desc = "A beret made from durathread, its resilient fibres provide some protection to the wearer."
	icon_state = "beretdurathread"
	item_color = null
	armor = list(MELEE = 15, BULLET = 5, LASER = 15, ENERGY = 5, BOMB = 10, BIO = 0, FIRE = 30, ACID = 5)

/obj/item/clothing/head/HoS
	name = "head of security cap"
	desc = "The robust standard-issue cap of the Head of Security. For showing the officers who's in charge."
	gender = FEMALE
	icon_state = "hoscap"
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 10, FIRE = 50, ACID = 60)
	strip_delay = 80

/obj/item/clothing/head/HoS/beret
	name = "head of security beret"
	desc = "A robust beret for the Head of Security, for looking stylish while not sacrificing protection."
	gender = MALE
	icon_state = "beret_hos_black"
	snake_fashion = /datum/snake_fashion/head/beret_hos_black

/obj/item/clothing/head/warden
	name = "warden's police hat"
	desc = "It's a special armored hat issued to the Warden of a security force. Protects the head from impacts."
	gender = FEMALE
	icon_state = "policehelm"
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 0, FIRE = 30, ACID = 60)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/warden

/obj/item/clothing/head/officer
	name = "officer's cap"
	desc = "A red cap with an old-fashioned badge on the front for establishing that you are, in fact, the law."
	gender = FEMALE
	icon_state = "customshelm"
	item_state = "customshelm"
	armor = list(MELEE = 35, BULLET = 30, LASER = 30,ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 20, ACID = 50)
	strip_delay = 60

/obj/item/clothing/head/beret/sec
	name = "security beret"
	desc = "A beret with the security insignia emblazoned on it. For officers that are more inclined towards style than safety."
	icon_state = "beret_officer"
	armor = list(MELEE = 35, BULLET = 30, LASER = 30,ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 20, ACID = 50)
	strip_delay = 60
	dog_fashion = null
	muhtar_fashion = /datum/muhtar_fashion/head/beret

/obj/item/clothing/head/beret/sec/black
	name = "black security beret"
	desc = "A beret with the security insignia emblazoned on it. For officers that are more inclined towards style than safety."
	icon_state = "beret_officer_black"

/obj/item/clothing/head/beret/sec/warden
	name = "warden's beret"
	desc = "A special beret with the Warden's insignia emblazoned on it. For wardens with class."
	icon_state = "beret_warden"
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 0, FIRE = 30, ACID = 50)

/obj/item/clothing/head/beret/brigphys
	name = "brigphys's beret"
	desc = "Берет, принадлежащий медику службы безопасности. Не обладает какой либо защитой."
	icon_state = "brigphysberet"

/obj/item/clothing/head/beret/eng
	name = "engineering beret"
	desc = "A beret with the engineering insignia emblazoned on it. For engineers that are more inclined towards style than safety."
	icon_state = "beret_engineering"

/obj/item/clothing/head/beret/atmos
	name = "atmospherics beret"
	desc = "A beret for those who have shown immaculate proficienty in piping. Or plumbing."
	icon_state = "beret_atmospherics"

/obj/item/clothing/head/beret/ce
	name = "chief engineer beret"
	desc = "A white beret with the engineering insignia emblazoned on it. Its owner knows what they're doing. Probably."
	icon_state = "beret_ce"

/obj/item/clothing/head/beret/sci
	name = "science beret"
	desc = "A purple beret with a lavender science insignia emblazoned on it. It has that authentic smell of burning plasma."
	icon_state = "beret_sci"

/obj/item/clothing/head/beret/med
	name = "medical beret"
	desc = "A light blue beret with a white cross finely threaded into it. It has that sterile smell about it."
	icon_state = "beret_med"

/obj/item/clothing/head/beret/elo
	name = "chief medical officer beret"
	desc = "Stylish beret of the Chief Medical Officer. You can smell a faint antiseptic smell coming from it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "elo-beret"
	item_state = "elo-beret"

/obj/item/clothing/head/surgery
	name = "surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs."
	gender = FEMALE
	icon_state = "surgcap_blue"
	flags_inv = HIDEHEADHAIR
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi',
	)

/obj/item/clothing/head/surgery/purple
	name = "purple surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is deep purple."
	icon_state = "surgcap_purple"

/obj/item/clothing/head/surgery/blue
	name = "blue surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is baby blue."

/obj/item/clothing/head/surgery/green
	name = "dark green surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is dark green."
	icon_state = "surgcap_darkgreen"

/obj/item/clothing/head/surgery/lightgreen
	name = "green surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is dark green."
	icon_state = "surgcap_green"

/obj/item/clothing/head/surgery/black
	name = "black surgical cap"
	desc = "A cap coroners wear during autopsies. Keeps their hair from falling into the cadavers. It is as dark as the coroner's humor."
	icon_state = "surgcap_black"

/obj/item/clothing/head/beret/solgov/command
	name = "Trans-Solar Federation Lieutenant's beret"
	desc = "A beret worn by marines of the Trans-Solar Federation. The insignia signifies the wearer bears the rank of a Lieutenant."
	icon_state = "solgov_beret"
	dog_fashion = null
	armor = list(MELEE = 35, BULLET = 30, LASER = 30,ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 20, ACID = 50)
	strip_delay = 80

/obj/item/clothing/head/beret/solgov/command/elite
	name = "Trans-Solar Federation Specops Lieutenant's beret"
	desc = "A beret worn by marines of the Trans-Solar Federation Specops division. The insignia signifies the wearer bears the rank of a Lieutenant."
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 10, FIRE = 50, ACID = 60)
	icon_state = "solgov_elite_beret"

/obj/item/clothing/head/chefcap
	name = "chef's red cap"
	desc = "Red cap for people who want show who`s really boss of this kitchen"
	item_state = "redchefcap"
	icon_state = "redchefcap"

/obj/item/clothing/head/surgery/brown
	name = "brown surgical cap"
	desc = "Коричневая шапочка, которую носят хирурги во время операций. Защищает внутренние органы пациента от попадания на них волос."
	icon_state = "surgcap_brown"

/obj/item/clothing/head/prison
	name = "prison hat"
	desc = "Тюремная шапка, которая должна предотвращать распространение космо вшей... По крайней мере так задумывалось."
	item_state = "prison_hat"
	icon_state = "prison_hat"

/obj/item/clothing/head/beret/mining_medic
	name = "mining medic's beret"
	desc = "Коричневый берет с вышитым на нём белым крестом. Такой обычно носит шахтёрский врач."
	icon_state = "beret_minmed"

