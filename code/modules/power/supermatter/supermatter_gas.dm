/proc/init_sm_gas()
	var/list/gas_list = list()
	for(var/sm_gas_type in valid_subtypesof(/datum/sm_gas))
		var/datum/sm_gas/sm_gas = new sm_gas_type
		gas_list[sm_gas.gas_id] = sm_gas
	return gas_list

/// Return a list info of the SM gases.
/// Can only run after init_sm_gas
/proc/sm_gas_data()
	var/list/data = list()
	for(var/gas_id, gas_behavior in GLOB.sm_gas_behavior)
		var/datum/sm_gas/sm_gas = gas_behavior
		var/list/singular_gas_data = list()
		singular_gas_data["desc"] = sm_gas.desc

		// Positive is true if more of the amount is a good thing.
		var/list/numeric_data = list()
		if(sm_gas.power_transmission)
			var/list/si_derived_data = siunit_isolated(sm_gas.power_transmission * BASE_POWER_TRANSMISSION_RATE, "W/MeV", 2)
			numeric_data += list(list(
				"name" = "Бонус передачи энергии",
				"amount" = si_derived_data["coefficient"],
				"unit" = si_derived_data["unit"],
				"positive" = TRUE,
			))
		if(sm_gas.heat_modifier)
			numeric_data += list(list(
				"name" = "Множитель отходов",
				"amount" = 100 * sm_gas.heat_modifier,
				"unit" = "%",
				"positive" = FALSE,
			))
		if(sm_gas.heat_resistance)
			numeric_data += list(list(
				"name" = "Теплостойкость",
				"amount" = 100 * sm_gas.heat_resistance,
				"unit" = "%",
				"positive" = TRUE,
			))
		if(sm_gas.heat_power_generation)
			var/list/si_derived_data = siunit_isolated(sm_gas.heat_power_generation * GAS_HEAT_POWER_SCALING_COEFFICIENT MEGA SECONDS / SSair.wait, "eV/K/s", 2)
			numeric_data += list(list(
				"name" = "Прирост энергии от тепла",
				"amount" = si_derived_data["coefficient"],
				"unit" = si_derived_data["unit"],
				"positive" = TRUE,
			))
		if(sm_gas.powerloss_inhibition)
			numeric_data += list(list(
				"name" = "Подавление распада энергии",
				"amount" = 100 * sm_gas.powerloss_inhibition,
				"unit" = "%",
				"positive" = TRUE,
			))
		singular_gas_data["numeric_data"] = numeric_data
		data[gas_id] = singular_gas_data
	return data

/// Assoc of sm_gas_behavior[/datum/gas (path)] = datum/sm_gas (instance)
GLOBAL_LIST_INIT(sm_gas_behavior, init_sm_gas())

/// Contains effects of gases when absorbed by the sm.
/// If the gas has no effects you do not need to add another sm_gas subtype,
/// We already guard for nulls in [/obj/machinery/power/supermatter_crystal/proc/calculate_gases]
/datum/sm_gas
	abstract_type = /datum/sm_gas
	/// Path of the [/datum/gas] involved with this interaction.
	var/gas_id
	/// Influences zap power without interfering with the crystal's own energy. Gets scaled by [BASE_POWER_TRANSMISSION_RATE].
	var/power_transmission = 0
	/// How much more waste heat and gas the SM generates.
	var/heat_modifier = 0
	/// How extra hot the SM can run before taking damage
	var/heat_resistance = 0
	/// Lets the sm generate extra power from heat. Yeah...
	var/heat_power_generation = 0
	/// How much powerloss do we get rid of.
	var/powerloss_inhibition = 0
	/// Give a short description of the gas if needed. If the gas have extra effects describe it here.
	var/desc

/datum/sm_gas/proc/extra_effects(obj/machinery/power/supermatter_crystal/sm)
	return

/datum/sm_gas/oxygen
	gas_id = TLV_O2
	power_transmission = 0.15
	heat_power_generation = 1

/datum/sm_gas/nitrogen
	gas_id = TLV_N2
	heat_modifier = -2.5
	heat_power_generation = -1

/datum/sm_gas/carbon_dioxide
	gas_id = TLV_CO2
	heat_modifier = 1
	heat_power_generation = 1
	powerloss_inhibition = 1

/// Can be on Oxygen or CO2, but better lump it here since CO2 is rarer.
/datum/sm_gas/plasma
	gas_id = TLV_PL
	heat_modifier = 14
	power_transmission = 0.4
	heat_power_generation = 1

/datum/sm_gas/water_vapor
	gas_id = TLV_H2O
	heat_modifier = 11
	power_transmission = -0.25
	heat_power_generation = 1

/datum/sm_gas/nitrous_oxide
	gas_id = TLV_N2O
	heat_resistance = 5

/// Start to emit radballs at a maximum of 30% chance per tick
///Miasma is really just microscopic particulate. It gets consumed like anything else that touches the crystal.
/datum/sm_gas/hydrogen
	gas_id = TLV_H2
	heat_modifier = 9
	power_transmission = 2.5
	heat_resistance = 1
	heat_power_generation = 1

/datum/sm_gas/agent_b
	gas_id = TLV_AGENT_B
