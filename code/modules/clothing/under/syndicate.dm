/obj/item/clothing/under/syndicate
	name = "tactical turtleneck"
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants."
	icon_state = "syndicate"
	item_state = "bl_suit"
	item_color = "syndicate"
	has_sensor = 0
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 40)
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/syndicate/combat
	name = "combat turtleneck"

/obj/item/clothing/under/syndicate/tacticool
	name = "tacticool turtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool"
	item_color = "tactifool"
	has_sensor = TRUE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 40)

/obj/item/clothing/under/syndicate/tacticool/skirt
	name = "tacticool skirt"
	icon_state = "tactifoolf"
	item_color = "tactifoolf"

/obj/item/clothing/under/syndicate/sniper
	name = "Tactical turtleneck suit"
	desc = "A double seamed tactical turtleneck disguised as a civilian grade silk suit. Intended for the most formal operator. The collar is really sharp."
	icon_state = "really_black_suit"
	item_color = "black_suit"

/obj/item/clothing/under/syndicate/sniper_civ
	name = "Executive tacticool suit"
	desc = "Модель тактической водолазки предназначена для ведения переговоров, а не для участия в боевых действиях."
	icon_state = "black_suit"
	item_color = "black_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/syndicate/blackops
	name = "Black ops coverall"
	desc = "Robust coverall made for covert oprations deep within enemy territory. Offers small protection to it's user due to durathread and kevlar inserts."
	icon_state = "blackops"
	item_state = "blackops"
	armor = list(MELEE = 15, BULLET = 15, LASER = 15,ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 10, ACID = 0)

/obj/item/clothing/under/syndicate/blackops_civ
	name = "Black ops coverall"
	desc = "Nice looking coverall made out of cheap fabric, not suitible for real combat."
	icon_state = "blackops"
	item_state = "blackops"
	has_sensor = TRUE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/plasmaman/syndie
	name = "tacticool envirosuit"
	desc = "Зловещий на вид защитный костюм для самых костлявых оперативников."
	icon_state = "syndie_envirosuit"
	item_color = "syndie_envirosuit"
	has_sensor = 0
	resistance_flags = FIRE_PROOF
