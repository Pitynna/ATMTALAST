GLOBAL_LIST_INIT(gas_meta, meta_gas_list())
/proc/meta_gas_list()
	. = list()
	for(var/gas_path in subtypesof(/datum/gas))
		var/list/gas_info = new(7)
		var/datum/gas/gas = gas_path

		gas_info[META_GAS_ID] = gas.id
		gas_info[META_GAS_NAME] = gas.name
		gas_info[META_GAS_DESC] = gas.desc
		gas_info[META_GAS_PRIMARY_COLOR] = gas.primary_color
		gas_info[META_GAS_SCRUB_FLAG] = gas.scrub_flag
		gas_info[META_GAS_SENSOR_FLAG] = gas.sensor_flag
		gas_info[META_BASE_VALUE] = gas.base_value
		.[gas.id] = gas_info


/*||||||||||||||/----------\||||||||||||||*\
||||||||||||||||[GAS DATUMS]||||||||||||||||
||||||||||||||||\__________/||||||||||||||||
|||| These should never be instantiated. ||||
|||| They exist only to make it easier   ||||
|||| to add a new gas. They are accessed ||||
|||| only by meta_gas_list().            ||||
\*||||||||||||||||||||||||||||||||||||||||*/

/datum/gas
	var/id = ""
	var/name = ""
	var/desc
	///RGB code for use when a generic color representing the gas is needed. Colors taken from contants.ts
	var/primary_color
	var/scrub_flag
	var/sensor_flag
	var/base_value = 0

/datum/gas/oxygen
	id = TLV_O2
	name = "Oxygen"
	desc = "The gas most life forms need to be able to survive. Also an oxidizer."
	primary_color = "#0000ff"
	scrub_flag = SCRUB_O2
	sensor_flag = SENSOR_COMPOSITION_OXYGEN
	base_value = 0.2

/datum/gas/nitrogen
	id = TLV_N2
	name = "Nitrogen"
	desc = "A very common gas that used to pad artificial atmospheres to habitable pressure."
	primary_color = "#ffff00"
	scrub_flag = SCRUB_N2
	sensor_flag = SENSOR_COMPOSITION_NITROGEN
	base_value = 0.1

/datum/gas/carbon_dioxide
	id = TLV_CO2
	name = "Carbon Dioxide"
	desc = "A waste product of respiration, also produced by combustion."
	primary_color = COLOR_GRAY
	scrub_flag = SCRUB_CO2
	sensor_flag = SENSOR_COMPOSITION_CO2
	base_value = 0.2

/datum/gas/plasma
	id = TLV_PL
	name = "Plasma"
	desc = "A flammable gas with many other curious properties. Its research is one of NT's primary objective."
	primary_color = "#ffc0cb"
	scrub_flag = SCRUB_PL
	sensor_flag = SENSOR_COMPOSITION_TOXINS
	base_value = 1.5

/datum/gas/water_vapor
	id = TLV_H2O
	name = "Water Vapor"
	desc = "Water, in gas form. Makes floors slippery and washes items on them."
	primary_color = "#b0c4de"
	scrub_flag = SCRUB_H2O
	sensor_flag = SENSOR_COMPOSITION_H2O
	base_value = 0.5

/datum/gas/nitrous_oxide
	id = TLV_N2O
	name = "Nitrous Oxide"
	desc = "Causes drowsiness, euphoria, and eventually unconsciousness."
	primary_color = "#ffe4c4"
	scrub_flag = SCRUB_N2O
	sensor_flag = SENSOR_COMPOSITION_N2O
	base_value = 1.5

/datum/gas/hydrogen
	id = TLV_H2
	name = "Hydrogen"
	desc = "A highly flammable gas."
	primary_color = "#ffffff"
	scrub_flag = SCRUB_H2
	sensor_flag = SENSOR_COMPOSITION_H2
	base_value = 1

/datum/gas/agent_b
	id = TLV_AGENT_B
	name = "Agent b"
	desc = "Unknown gas."
	primary_color = COLOR_GRAY
	sensor_flag = SENSOR_COMPOSITION_AGENT_B
	base_value = 5
