/obj/item/storage/box/syndicate/Initialize(mapload, list/bundle)
	. = ..()
	if(bundle)
		for(var/index in bundle)
			switch(index)
				if("Name")
					name = bundle[index]
				if("Desc")
					desc = bundle[index]
				else
					var/number = bundle[index]
					for(var/i in 1 to number)
						new index(src)

/obj/item/storage/box/syndie_kit
	name = "Box"
	gender = MALE
	icon_state = "box_of_doom"
	item_state = "syndie"

/obj/item/storage/box/syndie_kit/mantisblade
	name = "mantis blade kit"
	desc = "A box containing two mantis blades."
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/mantisblade/populate_contents()
	new /obj/item/autoimplanter/oneuse/mantisblade(src)
	new /obj/item/autoimplanter/oneuse/mantisblade/l(src)

/obj/item/storage/box/syndie_kit/space
	name = "Boxed Space Suit and Helmet"
	can_hold = list(
		/obj/item/clothing/suit/space/syndicate/black/red,
		/obj/item/clothing/head/helmet/space/syndicate/black/red,
		/obj/item/tank/internals/emergency_oxygen/engi/syndi,
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/tank/jetpack/oxygen/harness,
	)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/space/populate_contents()
	new /obj/item/clothing/suit/space/syndicate/black/red(src)
	new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)
	new /obj/item/tank/jetpack/oxygen/harness(src)

/obj/item/storage/box/syndie_kit/hardsuit
	name = "Boxed Blood Red Suit and Helmet"
	can_hold = list(/obj/item/clothing/suit/space/hardsuit/syndi, /obj/item/tank/internals/emergency_oxygen/engi/syndi, /obj/item/clothing/mask/gas/syndicate)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/hardsuit/populate_contents()
	new /obj/item/clothing/suit/space/hardsuit/syndi(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)

/obj/item/storage/box/syndie_kit/counterfeiter_bundle
	name = "Counterfeiter Bundle"
	desc = "A box containing all the neccessary equipment to forge stamps and insignias, making the user capable of faking any Nanotrasen documents."

/obj/item/storage/box/syndie_kit/counterfeiter_bundle/populate_contents()
	new /obj/item/stamp/chameleon(src)
	new /obj/item/pen/fakesign(src)

/obj/item/storage/box/syndie_kit/conversion
	name = "box (CK)"

/obj/item/storage/box/syndie_kit/conversion/populate_contents()
	new /obj/item/conversion_kit(src)
	new /obj/item/ammo_box/speedloader/a357(src)

/obj/item/storage/box/syndie_kit/emp
	name = "boxed EMP kit"

/obj/item/storage/box/syndie_kit/emp/populate_contents()
	new /obj/item/grenade/empgrenade(src)
	new /obj/item/grenade/empgrenade(src)
	new /obj/item/implanter/emp/(src)

/obj/item/storage/box/syndie_kit/c4
	name = "Pack of C-4 Explosives"

/obj/item/storage/box/syndie_kit/c4/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/plastic/c4(src)

/obj/item/storage/box/syndie_kit/t4
	name = "Pack of T-4 Explosives"
	desc = "Contains five T4 breaching charges."

/obj/item/storage/box/syndie_kit/t4/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/plastic/x4/thermite(src)

/obj/item/storage/box/syndie_kit/t4P
	name = "Small pack of T-4 Explosives"
	desc = "Contains three T4 breaching charges."

/obj/item/storage/box/syndie_kit/t4P/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/grenade/plastic/x4/thermite(src)

/obj/item/storage/box/syndie_kit/throwing_weapons
	name = "boxed throwing kit"
	can_hold = list(
		/obj/item/throwing_star,
		/obj/item/restraints/legcuffs/bola/tactical,
	)
	max_combined_w_class = 16
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/throwing_weapons/populate_contents()
	for(var/I in 1 to 4)
		new /obj/item/throwing_star(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)

/obj/item/storage/box/syndie_kit/sarin
	name = "sarin gas grenades"
	desc = "A box containing sarin grenades."

/obj/item/storage/box/syndie_kit/sarin/populate_contents()
	for(var/I in 1 to 4)
		new /obj/item/grenade/chem_grenade/saringas(src)

/obj/item/storage/box/syndie_kit/bioterror
	name = "bioterror syringe kit"
	desc = "A box containing seven Bioterror syringes."

/obj/item/storage/box/syndie_kit/bioterror/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/reagent_containers/syringe/bioterror(src)

/obj/item/storage/box/syndie_kit/caneshotgun
	name = "cane gun kit"
	desc = "A box containing a cane shotgun and ammunition."

/obj/item/storage/box/syndie_kit/caneshotgun/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/ammo_casing/shotgun/assassination(src)
	new /obj/item/gun/projectile/revolver/doublebarrel/improvised/cane(src)

/obj/item/storage/box/syndie_kit/fake_revolver
	name = "trick revolver kit"
	desc = "A box containing a prank revolver."

/obj/item/storage/box/syndie_kit/fake_revolver/populate_contents()
	new /obj/item/toy/russian_revolver/trick_revolver(src)

/obj/item/storage/box/syndie_kit/mimery
	name = "advanced mimery kit"
	desc = "A box containing two advanced mimery books."

/obj/item/storage/box/syndie_kit/mimery/populate_contents()
	new /obj/item/spellbook/oneuse/mime/greaterwall(src)
	new	/obj/item/spellbook/oneuse/mime/fingergun(src)

/obj/item/storage/box/syndie_kit/atmosn2ogrenades
	name = "atmos N2O grenades kit"
	desc = "A box containing two cluster grenades filled with nitrous oxide."

/obj/item/storage/box/syndie_kit/atmosn2ogrenades/populate_contents()
	new /obj/item/grenade/clusterbuster/n2o(src)
	new /obj/item/grenade/clusterbuster/n2o(src)

/obj/item/storage/box/syndie_kit/atmosfiregrenades
	name = "plasma fire grenades kit"
	desc = "A box containing two cluster grenades filled with gaseous plasma."

/obj/item/storage/box/syndie_kit/atmosfiregrenades/populate_contents()
	new /obj/item/grenade/clusterbuster/plasma(src)
	new /obj/item/grenade/clusterbuster/plasma(src)

/obj/item/storage/box/syndie_kit/missionary_set
	name = "missionary starter kit"
	desc = "A box containing a Bible, a set of clothes and a staff."

/obj/item/storage/box/syndie_kit/missionary_set/populate_contents()
	new /obj/item/nullrod/missionary_staff(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe(src)
	var/obj/item/storage/bible/B = new /obj/item/storage/bible(src)
	if(prob(25))	//an omen of success to come?
		B.deity_name = "Success"
		B.icon_state = "bible_greentext"
		B.item_state = "greentext"

/obj/item/storage/box/syndie_kit/cutouts
	name = "adaptive cardboard figure kit"
	desc = "A box containing adaptive cardboard cutouts and a spray can."

/obj/item/storage/box/syndie_kit/cutouts/populate_contents()
	for(var/i in 1 to 3)
		new/obj/item/twohanded/cardboard_cutout/adaptive(src)
	new/obj/item/toy/crayon/spraycan(src)

/obj/item/storage/box/syndie_kit/bonerepair
	name = "emergency nanite kit"
	desc = "A box containing one prototype field bone repair kit."

/obj/item/storage/box/syndie_kit/bonerepair/populate_contents()
	new /obj/item/reagent_containers/hypospray/autoinjector/nanocalcium(src)
	var/obj/item/paper/P = new /obj/item/paper(src)
	P.name = "Prototype nanite repair guide" // The instructions need to be revised.
	P.desc = "For when you want to safely get off Mr Bones' Wild Ride."
	P.info = {"
<font face="Verdana" color=black></font><font face="Verdana" color=black><center><b>Prototype Emergency Repair Nanites</b><hr></center><br><br>

<b>Usage:</b> <br><br><br>

<font size = "1">This is a highly experimental prototype chemical designed to repair damaged bones, organs, and treat interenal bleeding of soldiers in the field, use only as a last resort. The autoinjector contains prototype nanites bearing a classifed payload. The nanites will simultaneously shut down body systems whilst aiding in repair.<br><br><br>Warning: Side effects can cause temporary paralysis, loss of co-ordination and sickness. <b>Do not use with any kind of stimulant or drugs. Serious damage can occur!</b><br><br><br>

To apply, hold the injector a short distance away from the outer thigh before applying firmly to the skin surface. The process of repairing should begin repair after a short time, during which you are advised to remain still. <br><br><br><br>After use you are advised to see a doctor at the next available opportunity. Mild scarring and tissue damage may occur after use. This is a prototype. We are not liable for any bone spurs, cancers, extra limbs, or creation of new viruses from use of the product.</font><br><hr></font>
	"}

/obj/item/storage/box/syndie_kit/chameleon
	name = "chameleon kit"
	desc = "A box containing a set of chameleon clothing."

/obj/item/storage/box/syndie_kit/chameleon/populate_contents()
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/suit/chameleon(src)
	new /obj/item/clothing/gloves/chameleon(src)
	new /obj/item/clothing/shoes/chameleon(src)
	new /obj/item/clothing/glasses/chameleon(src)
	new /obj/item/clothing/head/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/storage/backpack/chameleon(src)
	new /obj/item/radio/headset/chameleon(src)
	new /obj/item/clothing/neck/chameleon(src)
	new /obj/item/stamp/chameleon(src)
	new /obj/item/pda/chameleon(src)
	new /obj/item/pen/fakesign(src)

/obj/item/storage/box/syndie_kit/plasma_chameleon
	name = "plasmaman chameleon kit"
	desc = "A box containing a set of plasmaman chameleon clothing."

/obj/item/storage/box/syndie_kit/plasma_chameleon/populate_contents()
	new /obj/item/clothing/under/plasmaman/chameleon(src)
	new /obj/item/clothing/suit/chameleon(src)
	new /obj/item/clothing/gloves/chameleon(src)
	new /obj/item/clothing/shoes/chameleon(src)
	new /obj/item/clothing/glasses/chameleon(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/storage/backpack/chameleon(src)
	new /obj/item/radio/headset/chameleon(src)
	new /obj/item/stamp/chameleon(src)
	new /obj/item/pda/chameleon(src)
	new /obj/item/pen/fakesign(src)

/obj/item/storage/box/syndie_kit/dart_gun
	name = "dart gun kit"
	desc = "A box containing a miniature version of a standard syringe gun."

/obj/item/storage/box/syndie_kit/dart_gun/populate_contents()
	new /obj/item/gun/syringe/syndicate(src)
	new /obj/item/reagent_containers/syringe/capulettium_plus(src)
	new /obj/item/reagent_containers/syringe/sarin(src)
	new /obj/item/reagent_containers/syringe/pancuronium(src)

/obj/item/storage/box/syndie_kit/nuke
	name = "box"  // Stealth, because you will spawn with a box.
	icon_state = "box"

/obj/item/storage/box/syndie_kit/nuke/populate_contents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/nuke_core_container(src)
	new /obj/item/paper/guides/antag/nuke_instructions(src)

/obj/item/storage/box/syndie_kit/supermatter
	name = "box"  // Stealth, because you will spawn with a box.
	icon_state = "box"

/obj/item/storage/box/syndie_kit/supermatter/populate_contents()
	new /obj/item/scalpel/supermatter(src)
	new /obj/item/retractor/supermatter(src)
	new /obj/item/nuke_core_container/supermatter(src)
	new /obj/item/paper/guides/antag/supermatter_sliver(src)

/obj/item/storage/box/syndie_kit/genes
	name = "genetic superiority bundle"
	desc = "Fun for the whole family"

/obj/item/storage/box/syndie_kit/genes/populate_contents()
	new /obj/item/dnainjector/hulkmut(src)
	new /obj/item/dnainjector/xraymut(src)
	new /obj/item/dnainjector/telemut(src)
	new /obj/item/dnainjector/runfast(src)
	new /obj/item/dnainjector/insulation(src)

/obj/item/storage/box/syndie_kit/stungloves
	name = "stungloves kit"
	desc = "A box containing stun gloves and a battery."

/obj/item/storage/box/syndie_kit/stungloves/populate_contents()
	new /obj/item/clothing/gloves/color/yellow/stun(src)
	new /obj/item/stock_parts/cell/high/plus(src)
	new /obj/item/toy/crayon/white(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/rainbow(src)

/obj/item/storage/box/syndie_kit/cyborg_maint
	name = "cyborg repair kit"
	desc = "For people who wants to repair their robots."

/obj/item/storage/box/syndie_kit/cyborg_maint/populate_contents()
	new /obj/item/robot_parts/robot_component/armour(src)
	new /obj/item/robot_parts/robot_component/actuator(src)
	new /obj/item/robot_parts/robot_component/radio(src)
	new /obj/item/robot_parts/robot_component/binary_communication_device(src)
	new /obj/item/robot_parts/robot_component/camera(src)
	new /obj/item/robot_parts/robot_component/diagnosis_unit(src)
	new /obj/item/stack/nanopaste(src)
	new /obj/item/stack/nanopaste(src)
	new /obj/item/stack/nanopaste(src)
	new /obj/item/encryptionkey/syndicate(src)
	new /obj/item/robotanalyzer(src)
	var/obj/item/paper/P = new (src)
	P.name = "Cyborg Repair Instruction" // The instructions need to be revised.
	P.info = {"
<font face="Verdana" color=black></font><font face="Verdana" color=black><center><b>Краткая инструкция по пончинке роботов</b><hr></center><br><br>

<font size = "4">1. Возьмите Cyborg Analyzer, проведите им по роботу.<br>
2. Запомните сломанные компоненты, которые вывел Cyborg Analyzer.<br>
3. Если робот закрыт (будет визуально заметно), то попросите его открыться. Если он уничтожен — проведите ЕМАГом для открытия.<br>
4. Монтировкой откройте крышку робота.<br>
5. Руками вытащите батарейку у робота.<br>
6. Монтировкой снимите сломанные компоненты из пункта 2.<br>
7. Вставьте новые компоненты в робота.<br>
8. Вставьте батарейку в робота.<br>
9. Закройте крышку робота монтировкой.<br>
10. Залейте нанопастой поврежденные части робота.<br>
11. Готово. робот снова функционирует.<br>
<br><br><br>
	"}

/obj/item/storage/box/syndie_kit/chameleon_counter
	name = "chameleon counterfeiter kit"
	desc = "A box containing three chameleon projectors."

/obj/item/storage/box/syndie_kit/chameleon_counter/populate_contents()
	new /obj/item/chameleon_counterfeiter(src)
	new /obj/item/chameleon_counterfeiter(src)
	new /obj/item/chameleon_counterfeiter(src)

/obj/item/storage/box/syndie_kit/midichlorian
	name = "midichlorian kit"
	desc = "A box containing a midichlorian injector and an energy sword."

/obj/item/storage/box/syndie_kit/midichlorian/populate_contents()
	new /obj/item/melee/energy/sword/saber(src)
	new /obj/item/midichlorian_injector(src)

/obj/item/storage/box/syndie_kit/pistol_ammo
	name = "10mm ammunition kit"
	desc = "A box containing two 10mm magazines."

/obj/item/storage/box/syndie_kit/pistol_ammo/populate_contents()
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)

/obj/item/storage/box/syndie_kit/revolver_ammo
	name = ".357 ammunition kit"
	desc = "A box containing two .357 speedloaders."

/obj/item/storage/box/syndie_kit/revolver_ammo/populate_contents()
	new /obj/item/ammo_box/speedloader/a357(src)
	new /obj/item/ammo_box/speedloader/a357(src)

/obj/item/storage/box/syndie_kit/dangertray
	name = "danger tray pack"
	desc = "Normal size box with compartments for trays."
	can_hold = list(/obj/item/storage/bag/tray/danger)
	max_combined_w_class = 3
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/dangertray/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/storage/bag/tray/danger(src)

/obj/item/storage/box/syndie_kit/mr_chang_technique
	name = "Mr. Chang's aggressive marketing technique"
	desc = "Special delivery package that contains a set of items dedicated to maximize the income. Sell me that pen."
	icon_state = "box_chang"
	item_state = "chang"

/obj/item/storage/box/syndie_kit/mr_chang_technique/populate_contents()
	new /obj/item/mr_chang_technique(src)
	new /obj/item/clothing/suit/mr_chang_coat(src)
	new /obj/item/clothing/shoes/mr_chang_sandals(src)
	new /obj/item/clothing/head/mr_chang_band(src)

/obj/item/storage/box/syndie_kit/bowman_conversion_kit
	name = "bowman headset conversion kit"
	desc = "Easy-to-apply device which enchances headset with loud noise protection."

/obj/item/storage/box/syndie_kit/bowman_conversion_kit/populate_contents()
	new /obj/item/encryptionkey/syndicate(src)
	new /obj/item/bowman_conversion_tool(src)

/obj/item/storage/box/syndie_kit/commando_kit
	name = "knife fight kit"
	desc = "A box that smells like a mix of gunpowder, napalm and cheap whiskey.  Contains everything you need to survive in such places."
	icon_state = "commando_kit"
	item_state = "green"

/obj/item/storage/box/syndie_kit/commando_kit/populate_contents()
	new /obj/item/throwing_manual(src)
	new /obj/item/clothing/under/pants/camo/commando(src)
	new /obj/item/clothing/shoes/combat/commando(src)
	new /obj/item/clothing/head/commando(src)
	new /obj/item/poster/commando(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/clothing/accessory/holster/knives(src)
	new /obj/item/storage/box/syndie_kit/knives_kit(src)

/obj/item/storage/box/syndie_kit/knives_kit
	name = "throwing knives kit"
	desc = "A box containing seven throwing knives."

/obj/item/storage/box/syndie_kit/knives_kit/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/kitchen/knife/combat/throwing(src)

/obj/item/storage/box/syndie_kit/blackops_kit
	name = "black ops kit"
	desc = "A box containing clothing for dangerous covert operations."

/obj/item/storage/box/syndie_kit/blackops_kit/populate_contents()
	new /obj/item/clothing/under/syndicate/blackops(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/clothing/shoes/combat(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/glasses/night(src)
	new /obj/item/clothing/accessory/storage/webbing(src)
	new /obj/item/storage/belt/military/assault(src)
	new /obj/item/clothing/mask/balaclava(src)

/obj/item/storage/box/syndie_kit/combat_baking
	name = "combat bakery kit"
	desc = "A box containing weapons made from baked goods!"

/obj/item/storage/box/syndie_kit/combat_baking/populate_contents()
	new /obj/item/reagent_containers/food/snacks/baguette/combat(src)
	new /obj/item/reagent_containers/food/snacks/croissant/throwing(src)
	new /obj/item/reagent_containers/food/snacks/croissant/throwing(src)
	new /obj/item/book/granter/crafting_recipe/combat_baking(src)

/obj/item/storage/box/syndie_kit/ghostface_kit
	name = "Ghostface kit"
	desc = "A box containing a Ghostface costume and mask."

/obj/item/storage/box/syndie_kit/ghostface_kit/populate_contents()
	new /obj/item/clothing/suit/hooded/ghostfacesuit/true(src)
	new /obj/item/clothing/mask/gas/ghostface/true(src)
	new /obj/item/kitchen/knife/ghostface_knife(src)

/obj/item/storage/box/syndie_kit/gun_mods
	name = "gun upgrade kit"
	desc = "A box containing assorted weapon upgrade modules."
	icon_state = "box_attachments"
	item_state = "box_gun_mods"

/obj/item/storage/box/syndie_kit/gun_mods/populate_contents()
	new /obj/item/gun_module/muzzle/suppressor(src)
	new /obj/item/gun_module/muzzle/compensator(src)
	new /obj/item/gun_module/rail/scope/collimator/pistol(src)
	new /obj/item/gun_module/rail/scope/collimator(src)
	new /obj/item/gun_module/rail/scope/x4(src)
	new /obj/item/gun_module/under/hand/simple(src)
	new /obj/item/gun_module/under/hand/angle(src)
	new /obj/item/gun_module/under/laser/point(src)

/obj/item/storage/box/syndie_kit/gun_mods/super/populate_contents()
	. = ..()
	new /obj/item/gun_module/under/flashlight/pistol(src)
	new /obj/item/gun_module/under/flashlight/rifle(src)
	new /obj/item/gun_module/rail/hud/medical(src)
	new /obj/item/gun_module/rail/hud/security(src)
	new /obj/item/gun_module/rail/scope/x16(src)
	new /obj/item/gun_module/rail/scope/x8(src)
	new /obj/item/gun_module/under/laser/point(src)

/obj/item/storage/box/syndie_kit/compact_sniper
	name = "compact sniper rifle kit"
	desc = "A box containing a Bubz Mini compact sniper rifle, a spare magazine and a box of ammunition."

/obj/item/storage/box/syndie_kit/compact_sniper/populate_contents()
	new /obj/item/gun/projectile/automatic/sniper_rifle/compact(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/compact(src)
	new /obj/item/ammo_box/sniper_rounds_compact(src)

/obj/item/storage/box/syndie_kit/revolver
	name = "revolver ocelot kit"
	desc = "A box containing a revolver and three .357 speedloaders."

/obj/item/storage/box/syndie_kit/revolver/populate_contents()
	new /obj/item/gun/projectile/revolver(src)
	new /obj/item/ammo_box/speedloader/a357(src)
	new /obj/item/ammo_box/speedloader/a357(src)
	new /obj/item/ammo_box/speedloader/a357(src)

/obj/item/storage/box/syndie_kit/desert_eagle
	name = "desert eagle kit"
	desc = "A box containing a Desert Eagle, three spare magazines and two boxes of .50 AE ammunition."

/obj/item/storage/box/syndie_kit/desert_eagle/populate_contents()
	new	/obj/item/gun/projectile/automatic/pistol/deagle(src)
	new /obj/item/ammo_box/magazine/m50(src)
	new /obj/item/ammo_box/magazine/m50(src)
	new /obj/item/ammo_box/magazine/m50(src)
	new /obj/item/ammo_box/m50(src)
	new /obj/item/ammo_box/m50(src)

/obj/item/storage/box/syndie_kit/stechkin_pistol
	name = "stechkin pistol kit"
	desc = "A box containing an FK-69 Stechkin pistol and three spare magazines."

/obj/item/storage/box/syndie_kit/stechkin_pistol/populate_contents()
	new	/obj/item/gun/projectile/automatic/pistol/stechkin(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)

/obj/item/storage/box/syndie_kit/kedr_kit
	name = "smg K-45 kit"
	desc = "A box containing a K-45 submachine gun, a suppressor and four spare magazines."

/obj/item/storage/box/syndie_kit/kedr_kit/populate_contents()
	new	/obj/item/gun/projectile/automatic/smg/kedr(src)
	new /obj/item/gun_module/muzzle/suppressor(src)
	new /obj/item/ammo_box/magazine/kedr(src)
	new /obj/item/ammo_box/magazine/kedr(src)
	new /obj/item/ammo_box/magazine/kedr(src)
	new /obj/item/ammo_box/magazine/kedr(src)

/obj/item/storage/box/syndie_kit/kedr_ammo
	name = "ammunition for smg K-45"
	desc = "A box containing four loaded K-45 submachine gun magazines."

/obj/item/storage/box/syndie_kit/kedr_ammo/populate_contents()
	new /obj/item/ammo_box/magazine/kedr(src)
	new /obj/item/ammo_box/magazine/kedr(src)
	new /obj/item/ammo_box/magazine/kedr(src)
	new /obj/item/ammo_box/magazine/kedr(src)

/obj/item/storage/box/syndie_kit/rsh12_revolver
	name = "RSh-12 revolver kit"
	desc = "A box containing an RSh-12 revolver and three boxes of 12.7x55 ammunition."

/obj/item/storage/box/syndie_kit/rsh12_revolver/populate_contents()
	new	/obj/item/gun/projectile/revolver/rsh_12(src)
	new /obj/item/ammo_box/c12_dot_7X55(src)
	new /obj/item/ammo_box/c12_dot_7X55(src)
	new /obj/item/ammo_box/c12_dot_7X55(src)
	new /obj/item/clothing/accessory/holster(src)

/obj/item/storage/box/syndie_kit/combat_exoframe
	name = "combat exoframe kit"
	desc = "A box containing a combat exoskeleton module and an auto-implanter."
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/combat_exoframe/populate_contents()
	new /obj/item/organ/internal/cyberimp/chest/exoframe/combat(src)
	new /obj/item/autoimplanter/oneuse(src)

/obj/item/storage/box/syndie_kit/agent_base_kit
	name = "agent base kit"
	desc = "A kit containing the minimum equipment needed to carry out an assignment."
	var/static/list/possible_kits = list(
		/obj/item/storage/box/syndie_kit/scarecrow,
		/obj/item/storage/box/syndie_kit/chameleon_base,
		/obj/item/storage/belt/grenade/grenadier,
		/obj/item/storage/box/syndie_kit/knife,
		/obj/item/storage/box/syndie_kit/slip,
	)

/obj/item/storage/box/syndie_kit/agent_base_kit/populate_contents()
	. = ..()
	var/selected_type = pick(possible_kits)
	new selected_type(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	for(var/i in 1 to 2)
		new /obj/item/stack/medical/ointment/advanced(src)
	for(var/i in 1 to 2)
		new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/stack/medical/bruise_pack/military(src)
	new /obj/item/storage/box/syndie_kit/bonerepair(src)


/obj/item/storage/box/syndie_kit/scarecrow
	name = "scarecrow kit"
	desc = "A compact kit containing a Scarecrow pistol and equipment."

/obj/item/storage/box/syndie_kit/scarecrow/populate_contents()
	new /obj/item/gun/projectile/automatic/pistol/aps/scarecrow(src)
	for(var/i in 1 to 2)
		new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/clothing/accessory/holster(src)
	new /obj/item/storage/belt/security/webbing/pouch/fast(src)


/obj/item/storage/box/syndie_kit/chameleon_base
	name = "chameleon kit"
	desc = "A set of disguise clothing and communications equipment for field operations."

/obj/item/storage/box/syndie_kit/chameleon_base/populate_contents()
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/clothing/head/chameleon(src)
	new /obj/item/clothing/shoes/chameleon(src)
	new /obj/item/clothing/suit/chameleon(src)
	new /obj/item/radio/headset/chameleon(src)
	new /obj/item/encryptionkey/syndicate(src)
	new /obj/item/card/id/syndicate(src)


/obj/item/storage/belt/grenade/grenadier
	name = "grenadier's belt"
	desc = "A belt packed with assorted grenades for creating chaos."

/obj/item/storage/belt/grenade/grenadier/populate_contents()
	for(var/i in 1 to 8)
		new /obj/item/grenade/smokebomb(src)
	for(var/i in 1 to 2)
		new /obj/item/grenade/gluon(src)
		new /obj/item/grenade/empgrenade(src)
		new /obj/item/grenade/chem_grenade/lube(src)
		new /obj/item/grenade/chem_grenade/metalfoam(src)


/obj/item/storage/box/syndie_kit/knife
	name = "knife kit"
	desc = "A kit for close combat and stylish equipment."

/obj/item/storage/box/syndie_kit/knife/populate_contents()
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/clothing/accessory/holster/knives(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_syndicate(src)
	new /obj/item/lighter/zippo/engraved(src)
	new /obj/item/clothing/shoes/combat(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/clothing/under/syndicate(src)

/obj/item/storage/box/syndie_kit/slip
	name = "slip kit"
	desc = "A kit for creating the slipperiest possible situations."

/obj/item/storage/box/syndie_kit/slip/populate_contents()
	new /obj/item/clothing/shoes/chameleon/noslip(src)
	for(var/i in 1 to 5)
		new /obj/item/grenade/chem_grenade/cleaner(src)
	for(var/i in 1 to 5)
		new /obj/item/soap/syndie(src)
	for(var/i in 1 to 2)
		new /obj/item/grenade/clusterbuster/honk(src)
