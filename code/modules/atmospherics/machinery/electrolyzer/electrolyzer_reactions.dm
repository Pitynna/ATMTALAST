GLOBAL_LIST_INIT(electrolyzer_reactions, electrolyzer_reactions_list())

/*
 * Global proc to build the electrolyzer reactions list
 */
/proc/electrolyzer_reactions_list()
	var/list/built_reaction_list = list()
	for(var/reaction_path in subtypesof(/datum/electrolyzer_reaction))
		var/datum/electrolyzer_reaction/reaction = new reaction_path()

		built_reaction_list[reaction.id] = reaction

	return built_reaction_list

/datum/electrolyzer_reaction
	var/list/requirements
	var/name = "reaction"
	var/id = "r"
	var/desc = ""
	var/list/factor

/**
 * Electrolyzer reaction.
 * Args:
 * * air_mixture: The gas_mixture receiving the electrolysis.
 * * working_power: How much energy to put into the electrolysis, in electrolyzer units. A value of 1 is what a tier 1 electrolyzer would put in.
 * * electrolyzer_args: Additional arguments for alternative methods of electrolysis.
 */
/datum/electrolyzer_reaction/proc/react(datum/gas_mixture/air_mixture, working_power, list/electrolyzer_args = list())
	return

/**
 * Checks whether the requirements are met for a reaction.
 * Args:
 * * air_mixture: The air mixture to check the requirements for.
 * * electrolyzer_args: Additional arguments for alternative methods of electrolysis.
 */
/datum/electrolyzer_reaction/proc/reaction_check(datum/gas_mixture/air_mixture, list/electrolyzer_args = list())
	return TRUE

/datum/electrolyzer_reaction/h2o_conversion
	name = "H2O Conversion"
	id = "h2o_conversion"
	desc = "Conversion of H2o into O2 and H2"
	requirements = list(
		/datum/gas/water_vapor = MINIMUM_MOLE_COUNT,
	)
	factor = list(
		/datum/gas/water_vapor = "2 moles of H2O get consumed",
		/datum/gas/oxygen = "1 mole of O2 gets produced",
		/datum/gas/hydrogen = "2 moles of H2 get produced",
		"Location" = "Can only happen on turfs with an active Electrolyzer.",
	)

/datum/electrolyzer_reaction/h2o_conversion/reaction_check(datum/gas_mixture/air_mixture, list/electrolyzer_args = list())
	if(air_mixture.water_vapor() < MINIMUM_MOLE_COUNT)
		return FALSE
	. = ..()

/datum/electrolyzer_reaction/h2o_conversion/react(datum/gas_mixture/air_mixture, working_power, list/electrolyzer_args = list())

	var/old_heat_capacity = air_mixture.heat_capacity()
	var/proportion = min(air_mixture.water_vapor() * INVERSE(2), (2.5 * (POW2(working_power))))
	air_mixture.set_water_vapor(air_mixture.water_vapor() - proportion * 2)
	air_mixture.set_oxygen(air_mixture.oxygen() + proportion)
	air_mixture.set_hydrogen(air_mixture.hydrogen() + proportion * 2)
	var/new_heat_capacity = air_mixture.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.set_temperature(max(air_mixture.temperature() * old_heat_capacity / new_heat_capacity, TCMB))
