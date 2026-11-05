/*
 * Science
 */
/obj/item/clothing/under/rank/research_director
	name = "research director's jumpsuit"
	desc = "It's a jumpsuit worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	icon_state = "director"
	item_state = "g_suit"
	item_color = "director"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 10, BIO = 10, FIRE = 0, ACID = 35)

/obj/item/clothing/under/rank/scientist
	name = "scientist's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has markings that denote the wearer as a scientist."
	icon_state = "science"
	item_state = "w_suit"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/scientist/skirt
	name = "scientist's jumpskirt"
	desc = "A breathable purple jumpskirt with light markings, designating the wearer a scientist."
	icon_state = "sciencef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/scientist/student
	name = "scientist student jumpsuit"
	desc = "This jumpsuit bears special markings identifying its wearer as a student scientist. Its specialized fabric offers some protection against biological contamination."
	icon_state = "student"
	item_color = "student"

/obj/item/clothing/under/rank/scientist/student/skirt
	name = "scientist student jumpskirt"
	desc = "This skirt bears special markings identifying its wearer as a student scientist. Its specialized fabric offers some protection against biological contamination."
	icon_state = "studentf"
	item_color = "studentf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/scientist/student/assistant
	name = "scientist assistant jumpsuit"
	desc = "This jumpsuit bears special markings identifying its wearer as a research assistant. Its specialized fabric offers some protection against biological contamination."
	icon_state = "sci_ass"
	item_color = "sci_ass"

/obj/item/clothing/under/rank/scientist/student/assistant/skirt
	name = "scientist assistant jumpskirt"
	desc = "This skirt bears special markings identifying its wearer as a research assistant. Its specialized fabric offers some protection against biological contamination."
	icon_state = "sci_ass_f"
	item_color = "sci_ass_f"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/chemist
	name = "chemist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a chemist rank stripe on it."
	icon_state = "chemistry"
	item_state = "chemistry"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 50, ACID = 65)

/obj/item/clothing/under/rank/chemist/skirt
	name = "chemist's jumpskirt"
	desc = "This skirt bears special markings identifying its wearer as a chemist. Its specialized fabric offers some protection against biological contamination."
	icon_state = "chemistryf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/*
 * Medical
 */
/obj/item/clothing/under/rank/chief_medical_officer
	name = "chief medical officer's jumpsuit"
	desc = "It's a jumpsuit worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmo"
	item_state = "cmo"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/chief_medical_officer/skirt
	name = "chief medical officer's jumpskirt"
	desc = "It's a jumpskirt worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmof"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/geneticist
	name = "geneticist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a genetics rank stripe on it."
	icon_state = "genetics"
	item_state = "genetics"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/geneticist/skirt
	name = "geneticist's jumpskirt"
	desc = "A tear-proof purple jumpskirt with wine colored markings, designating the wearer a geneticist."
	icon_state = "geneticsf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/virologist
	name = "virologist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a virologist rank stripe on it."
	icon_state = "virology"
	item_state = "virology"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/virologist/skirt
	name = "virologist's jumpskirt"
	desc = "This skirt bears special markings identifying its wearer as a virologist. Its specialized fabric offers some protection against biological contamination."
	icon_state = "virologyf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/nursesuit
	name = "nurse's suit"
	desc = "It's a jumpsuit commonly worn by nursing staff in the medical department."
	icon_state = "nursesuit"
	item_state = "nursesuit"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/nurse
	name = "nurse's dress"
	desc = "A dress commonly worn by the nursing staff in the medical department."
	gender = NEUTER
	icon_state = "nurse"
	item_state = "nurse"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/orderly
	name = "orderly's uniform"
	desc = "A white suit to be worn by orderly people who love orderly things."
	gender = FEMALE
	icon_state = "orderly"
	item_state = "orderly"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical
	name = "medical doctor's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel."
	icon_state = "medical"
	item_state = "medical"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/medical/intern
	name = "intern jumpsuit"
	desc = "This jumpsuit bears special markings identifying its wearer as a medical intern. Its specialized fabric offers some protection against biological contamination."
	icon_state = "intern"
	item_state = "intern"

/obj/item/clothing/under/rank/medical/intern/skirt
	name = "intern jumpskirt"
	desc = "This skirt bears special markings identifying its wearer as a medical intern. Its specialized fabric offers some protection against biological contamination."
	icon_state = "internf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/intern/assistant
	name = "medical assistant jumpsuit"
	desc = "This jumpsuit bears special markings identifying its wearer as a medical assistant. Its specialized fabric offers some protection against biological contamination."
	icon_state = "med_ass"
	item_state = "med_ass"

/obj/item/clothing/under/rank/medical/intern/assistant/skirt
	name = "medical assistant jumpskirt"
	desc = "This skirt bears special markings identifying its wearer as a medical assistant. Its specialized fabric offers some protection against biological contamination."
	icon_state = "med_ass_f"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/skirt
	name = "medical doctor's jumpskirt"
	desc = "This skirt bears special markings identifying its wearer as a doctor. Its specialized fabric offers some protection against biological contamination."
	icon_state = "medicalf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/blue
	name = "blue medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in baby blue."
	gender = FEMALE
	icon_state = "scrubsblue"
	item_state = "scrubsblue"

/obj/item/clothing/under/rank/medical/green
	name = "dark green medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in dark green."
	gender = FEMALE
	icon_state = "scrubsdarkgreen"
	item_state = "scrubsdarkgreen"

/obj/item/clothing/under/rank/medical/lightgreen
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in green."
	gender = FEMALE
	icon_state = "scrubsgreen"
	item_state = "scrubsgreen"

/obj/item/clothing/under/rank/medical/purple
	name = "purple medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in deep purple."
	gender = FEMALE
	icon_state = "scrubspurple"
	item_state = "scrubspurple"

/obj/item/clothing/under/rank/medical/mortician
	name = "coroner's scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is as dark as an emo's poetry."
	gender = FEMALE
	icon_state = "scrubsblack"
	item_state = "scrubsblack"

/obj/item/clothing/under/rank/medical/paramedic
	name = "paramedic's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards and radiation. It has a cross on the back denoting that the wearer is trained medical personnel."
	icon_state = "paramedic"
	item_state = "paramedic"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/paramedic/skirt
	name = "paramedic's jumpskirt"
	desc = "It's made of a special fiber that provides minor protection against biohazards and radiation blue jumpskirt. It has a cross on the chest denoting that the wearer is trained medical personnel."
	icon_state = "paramedicf"
	item_state = "paramedicf"

/obj/item/clothing/under/rank/psych
	name = "psychiatrist's jumpsuit"
	desc = "A basic white jumpsuit. It has turqouise markings that denote the wearer as a psychiatrist."
	icon_state = "psych"
	item_state = "psych"

/obj/item/clothing/under/rank/psych/skirt
	name = "psychiatrist's jumpskirt"
	desc = "A basic white jumpskirt. It has turqouise markings that denote the wearer as a psychiatrist."
	icon_state = "psychf"

/obj/item/clothing/under/rank/psych/turtleneck
	name = "psychologist's turtleneck"
	desc = "A turqouise turtleneck and a pair of dark blue slacks, belonging to a psychologist."
	gender = FEMALE
	icon_state = "psychturtle"
	item_state = "psychturtle"

/*
 * Medsci, unused (i think) stuff
 */
/obj/item/clothing/under/rank/geneticist_new
	name = "geneticist's jumpsuit"
	desc = "It's made of a special fiber which provides minor protection against biohazards."
	icon_state = "genetics_new"
	item_state = "w_suit"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/chemist_new
	name = "chemist's jumpsuit"
	desc = "It's made of a special fiber which provides minor protection against biohazards."
	icon_state = "chemist_new"
	item_state = "w_suit"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 50, ACID = 65)

/obj/item/clothing/under/rank/scientist_new
	name = "scientist's jumpsuit"
	desc = "Made of a special fiber that gives special protection against biohazards and small explosions."
	icon_state = "scientist_new"
	item_state = "w_suit"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/virologist_new
	name = "virologist's jumpsuit"
	desc = "Made of a special fiber that gives increased protection against biohazards."
	icon_state = "virologist_new"
	item_state = "w_suit"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/mining_medic
	name = "mining medic's jumpsuit"
	desc = "This jumpsuit bears special markings identifying its wearer as a mining medic. Its specialized fabric offers some protection against biological contamination."
	species_restricted = list("exclude", "lesser form")
	icon_state = "mining_medic"
	item_state = "mining_medic"

/obj/item/clothing/under/rank/medical/mining_medic/skirt
	name = "mining medic's jumpskirt"
	desc = "This skirt bears special markings identifying its wearer as a mining medic. Its specialized fabric offers some protection against biological contamination."
	species_restricted = list("exclude", "lesser form")
	icon_state = "mining_medic_f"
	item_state = "mining_medic_f"

/obj/item/clothing/under/rank/medical/brown
	name = "brown medical scrubs"
	desc = "Specialized medical clothing worn during surgery, colored brown. Its specialized fabric offers some protection against biological contamination."
	gender = FEMALE
	species_restricted = list("exclude", "lesser form")
	icon_state = "scrubs_brown"
	item_state = "scrubs_brown"

/obj/item/clothing/under/rank/medical/mining_paramedic
	name = "mining paramedic's jumpsuit"
	desc = "This jumpsuit bears special markings identifying its wearer as a mining medic. Its specialized fabric offers some protection against biological contamination."
	species_restricted = list("exclude", "lesser form")
	icon_state = "mining_paramedic"
	item_state = "mining_paramedic"

/obj/item/clothing/under/rank/medical/mining_paramedic/skirt
	name = "mining paramedic's jumpskirt"
	desc = "This skirt bears special markings identifying its wearer as a mining medic. Its specialized fabric offers some protection against biological contamination."
	species_restricted = list("exclude", "lesser form")
	icon_state = "mining_paramedic_f"
	item_state = "mining_paramedic_f"
