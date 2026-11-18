// Clothing stains, an idea from Goonstation: a mess that lands on clothing (or on someone lying in it)
// shows up in the clothing's name until it is washed.

/obj/item/clothing
	/// Stain words shown before the name, e.g. "dirty", "puke-coated". Null when clean.
	var/list/stains
	/// The name before any stain words were added.
	var/stain_base_name
	/// The name we last set; if something else renamed us since, that becomes the new base name.
	var/stain_shown_name

/// Adds a stain word to the name. Returns TRUE if the clothing got a new stain.
/obj/item/clothing/proc/add_stain(stain_name)
	if(!stain_name || (stain_name in stains))
		return FALSE
	if(!stains)
		stains = list()
		stain_base_name = name
	else if(name != stain_shown_name)
		stain_base_name = name
	stains += stain_name
	stain_shown_name = "[jointext(stains, " ")] [stain_base_name]"
	name = stain_shown_name
	return TRUE

/// Removes every stain. Returns TRUE if there was anything to clean.
/obj/item/clothing/proc/clean_stains()
	if(!length(stains))
		return FALSE
	if(name == stain_shown_name)
		name = stain_base_name
	stains = null
	stain_base_name = null
	stain_shown_name = null
	return TRUE

/obj/effect/decal/cleanable
	/// Stain word given to clothing this mess lands on. Null for messes that don't stain.
	var/stain_name

/// Stains loose clothing on our turf and the outer layer of anyone lying in us.
/obj/effect/decal/cleanable/proc/stain_clothing()
	if(!stain_name || !isturf(loc))
		return
	for(var/atom/movable/thing as anything in loc)
		if(istype(thing, /obj/item/clothing))
			var/obj/item/clothing/clothes = thing
			clothes.add_stain(stain_name)
		else if(ishuman(thing))
			var/mob/living/carbon/human/person = thing
			if(!IS_HORIZONTAL(person))
				continue
			var/obj/item/clothing/outer = person.wear_suit || person.w_uniform
			if(istype(outer))
				outer.add_stain(stain_name)

/obj/effect/decal/cleanable/blood
	stain_name = "blood-stained"

/obj/effect/decal/cleanable/blood/drip
	stain_name = null

/obj/effect/decal/cleanable/blood/writing
	stain_name = null

/obj/effect/decal/cleanable/blood/tracks
	stain_name = null

/obj/effect/decal/cleanable/blood/xtracks
	stain_name = null

/obj/effect/decal/cleanable/blood/footprints
	stain_name = null

/obj/effect/decal/cleanable/blood/xeno
	stain_name = "slimy"

/obj/effect/decal/cleanable/blood/oil
	stain_name = "oily"

/obj/effect/decal/cleanable/blood/paint
	stain_name = "paint-splattered"

/obj/effect/decal/cleanable/vomit
	stain_name = "puke-coated"

/obj/effect/decal/cleanable/vomit/green
	stain_name = "green-puke-coated"

/obj/effect/decal/cleanable/dirt
	stain_name = "dirty"

/obj/effect/decal/cleanable/ash
	stain_name = "sooty"

/obj/effect/decal/cleanable/flour
	stain_name = "floury"

/obj/effect/decal/cleanable/liquid_fuel
	stain_name = "fuel-soaked"

/obj/effect/decal/cleanable/tomato_smudge
	stain_name = "tomato-stained"

/obj/effect/decal/cleanable/egg_smudge
	stain_name = "egg-stained"

/obj/effect/decal/cleanable/plant_smudge
	stain_name = "grass-stained"

/obj/effect/decal/cleanable/insectguts
	stain_name = "bug-splattered"
