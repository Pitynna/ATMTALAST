/obj/item/storage/box/swabs
	name = "box of swab kits"
	desc = "A sterile box full of forensic swabs, used to acquire DNA samples and test for lingering weapon residue."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "dnakit"

/obj/item/storage/box/swabs/populate_contents()
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)

/obj/item/storage/box/fingerprints
	name = "box of fingerprint cards"
	desc = "A sealed box full of fingerprint cards, used to acquire print sets from humanoids."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "dnakit"

/obj/item/storage/box/fingerprints/populate_contents()
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
