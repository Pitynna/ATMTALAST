/datum/export/stack
	abstract_type = /datum/export/stack
	unit_name = "sheet"

/datum/export/stack/get_amount(obj/object)
	var/obj/item/stack/stack = object
	if(istype(stack))
		return stack.amount
	return 0

//Only for Syndicate for now, NT has quests
/datum/export/stack/plasma
	cost = CARGO_CRATE_VALUE * 2
	k_hit_percentile = 0.4 / MAX_STACK_SIZE //Meaning selling 1 full stack of materials will decrease subsequent sales by 40%
	k_recovery_time = 4 MINUTES
	sales_market = EXPORT_NONE
	amount_report_multiplier = SHEET_MATERIAL_AMOUNT
	message = "cm3 of plasma"
	//material_id = /datum/material/plasma
	export_types = list(/obj/item/stack/sheet/mineral/plasma)
	//use_shared_exports = FALSE
