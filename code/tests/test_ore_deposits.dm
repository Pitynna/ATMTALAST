/// Round-start ore deposits must follow the agreed layout rules (docs/MINING_DRILLS.md).
/datum/unit_test/ore_deposit_layout/Run()
	var/mining_z = get_optional_mining_z()
	if(!mining_z)
		return // Minimal test maps and SKIP_MINING deliberately omit the mine.
	var/static/datum/ore_deposit_generator/rules = new // Only read for its settings.
	var/list/counts = list()
	var/list/all_tiles = list()
	for(var/datum/ore_deposit/deposit as anything in GLOB.ore_deposits)
		counts[deposit.ore_id] += 1
		TEST_ASSERT(deposit.ore_id in rules.deposit_kinds, "[deposit.name] has an unknown ore id")
		TEST_ASSERT(deposit.amount >= rules.min_amount && deposit.amount <= rules.max_amount, "[deposit.name] holds [deposit.amount] ore")
		var/list/turfs = deposit.get_turfs()
		TEST_ASSERT(length(turfs) >= rules.min_size && length(turfs) <= rules.max_size, "[deposit.name] has [length(turfs)] tiles")
		if(length(turfs) >= 3)
			TEST_ASSERT_NOT(rules.is_rectangle(turfs), "[deposit.name] must not be a plain line or block")
		// Every tile must be reachable from the first one through cardinal neighbours.
		var/list/connected = list(turfs[1])
		var/index = 1
		while(index <= length(connected))
			var/turf/current = connected[index++]
			for(var/direction in GLOB.cardinal)
				var/turf/neighbour = get_step(current, direction)
				if((neighbour in turfs) && !(neighbour in connected))
					connected += neighbour
		TEST_ASSERT_EQUAL(length(connected), length(turfs), "[deposit.name] must be one connected group")
		for(var/turf/location as anything in turfs)
			TEST_ASSERT_EQUAL(location.z, mining_z, "Deposits belong to the mining asteroid")
			TEST_ASSERT_NULL(all_tiles[location], "Deposits must not share tiles")
			all_tiles[location] = deposit
			for(var/obj/effect/ore_deposit_tile/tile in location)
				TEST_ASSERT_EQUAL(!!tile.invisibility, ismineralturf(location), "Deposit tiles must be hidden exactly while rock covers them")
			if(ismineralturf(location))
				var/turf/simulated/mineral/rock = location
				TEST_ASSERT(!rock.mineralType || rock.mineralType == deposit.ore_type, "[deposit.name] at [location.x]:[location.y] must not lie under another ore")
	for(var/ore_id in list("diamond", "bluespace"))
		TEST_ASSERT(counts[ore_id] >= rules.deposit_kinds[ore_id][2], "At least [rules.deposit_kinds[ore_id][2]] [ore_id] deposits are guaranteed")
	for(var/turf/first as anything in all_tiles)
		for(var/turf/second as anything in all_tiles)
			if(all_tiles[first] != all_tiles[second])
				TEST_ASSERT(get_dist(first, second) >= rules.deposit_spacing, "Deposits at [first.x]:[first.y] and [second.x]:[second.y] are too close")
