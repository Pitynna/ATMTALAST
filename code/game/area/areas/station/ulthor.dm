// Ulthor areas follow physical rooms; corridors and maintenance have separate circuits.
// Explicit editor states prevent inheriting /area's crossed-out "unknown" icon.

/area/station/service/ulthor_72_141
	name = "Ulthor Kitchen"
	icon_state = "kitchen"

/area/station/cargo/ulthor_76_110
	name = "Ulthor Recycling"
	icon_state = "disposal"

/area/station/service/ulthor_80_150
	name = "Ulthor Bar"
	icon_state = "barstation"

/area/station/commons/ulthor_81_165
	name = "Ulthor Arcade"
	icon_state = "arcade"

/area/station/service/ulthor_82_155
	name = "Ulthor Hydroponics"
	icon_state = "hydro"

/area/station/commons/ulthor_85_173
	name = "Ulthor Cryosleep"
	icon_state = "cryo"

/area/station/service/ulthor_86_180
	name = "Ulthor Chapel"
	icon_state = "chapeloffice"

/area/station/commons/ulthor_87_165
	name = "Ulthor Janitorial Office"
	icon_state = "janitor"

/area/station/commons/ulthor_89_175
	name = "Ulthor Chapel Storage"
	icon_state = "storage"

/area/station/service/ulthor_91_176
	name = "Ulthor Chapel Hall"
	icon_state = "chapel"

/area/station/service/ulthor_93_151
	name = "Ulthor Clown Office"
	icon_state = "clown_office"

/area/station/commons/ulthor_96_166
	name = "Ulthor Electrical Storage"
	icon_state = "engine_storage"

/area/station/command/ulthor_100_175
	name = "Ulthor Gateway"
	icon_state = "teleporter"

/area/station/command/ulthor_104_164
	name = "Ulthor Blueshield Office"
	icon_state = "blueshield"

/area/station/command/ulthor_106_160
	name = "Ulthor Representative Office"
	icon_state = "ntrep"

/area/station/medical/ulthor_108_176
	name = "Ulthor Medical Staff Room"
	icon_state = "medbaybreak"

/area/station/medical/ulthor_110_175
	name = "Ulthor Chemistry"
	icon_state = "chem"

/area/station/medical/ulthor_113_186
	name = "Ulthor Morgue"
	icon_state = "morgue"

/area/station/medical/ulthor_118_183
	name = "Ulthor Medical Storage"
	icon_state = "medbaysecstorage"

/area/station/medical/ulthor_122_183
	name = "Ulthor West Surgery"
	icon_state = "surgery1"

/area/station/science/ulthor_123_191
	name = "Ulthor Genetics"
	icon_state = "genetics"

/area/station/medical/ulthor_124_179
	name = "Ulthor Medbay"
	icon_state = "medbay"

/area/station/medical/ulthor_131_183
	name = "Ulthor East Surgery"
	icon_state = "surgery2"

/area/station/medical/ulthor_135_192
	name = "Ulthor Virology"
	icon_state = "virology"

/area/station/medical/ulthor_135_176
	name = "Ulthor Medical Hallway and Paramedic Office"
	icon_state = "medbay2"

/area/station/medical/ulthor_139_176
	name = "Ulthor Psychiatry"
	icon_state = "medbaypsych"

/area/station/command/ulthor_141_185
	name = "Ulthor CMO Office"
	icon_state = "CMO"

/area/station/ai/ulthor_141_152
	name = "Ulthor AI Core"
	icon_state = "ai_chamber"

/area/station/medical/ulthor_145_181
	name = "Ulthor Medical Maintenance"
	icon_state = "asmaint"

/area/station/telecomms/ulthor_145_147
	name = "Ulthor Station Telecomms"
	icon_state = "tcomms"

/area/station/ai/ulthor_148_151
	name = "Ulthor Cyborg Storage"
	icon_state = "ai_foyer"

/area/station/engineering/ulthor_149_129
	name = "Ulthor Engine Chamber"
	icon_state = "engine"

/area/station/engineering/ulthor_151_130
	name = "Ulthor Engineering"
	icon_state = "engine_hallway"

/area/station/engineering/ulthor_152_122
	name = "Ulthor Drone Control"
	icon_state = "engine_control"

/area/station/command/ulthor_153_164
	name = "Ulthor Vault"
	icon_state = "nuke_storage"

/area/station/command/ulthor_154_145
	name = "Ulthor Chief Engineer Office"
	icon_state = "head_quarters"

/area/station/engineering/ulthor_158_119
	name = "Ulthor Engineering Lounge"
	icon_state = "engine_monitoring"

/area/station/engineering/ulthor_163_93
	name = "Ulthor Mechanic Workshop"
	icon_state = "mechbay"

/area/station/science/ulthor_186_169
	name = "Ulthor Toxins Control"
	icon_state = "toxlaunch"

/area/shuttle/ulthor_laborcamp
	name = "Ulthor Laborcamp Shuttle"
	icon_state = "shuttlered"

/area/shuttle/ulthor_mining
	name = "Ulthor Mining Shuttle"
	icon_state = "shuttlegrn"

/area/shuttle/ulthor_supply
	name = "Ulthor Supply Shuttle"
	icon_state = "shuttle3"

/area/shuttle/ulthor_emergency
	name = "Ulthor Emergency Shuttle"
	icon_state = "shuttle2"

/area/shuttle/ulthor_specops
	name = "Ulthor Specops Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/ulthor_admin
	name = "Ulthor Admin Shuttle"
	icon_state = "shuttle"

/area/station/science/ulthor_coldroom
	name = "Ulthor Server Coldroom"
	icon_state = "servercold"

// Local children give implicit/generic legacy areas readable labels without
// changing shared area parents used by other station maps.

/area/station/ai/upload/ulthor
	name = "Ulthor AI Upload"
	icon_state = "ai_upload"

/area/station/command/office/qm/ulthor
	name = "Ulthor Quartermaster Office"
	icon_state = "quartoffice"

/area/station/science/robotics/ulthor
	name = "Ulthor Robotics and Research Access"
	icon_state = "research"

/area/station/maintenance/solars/port/ulthor
	name = "Ulthor West Solar Control and Maintenance"
	icon_state = "SolarcontrolP"

/area/station/solars/port/ulthor
	name = "Ulthor West Solar Array"
	icon_state = "panelsP"

/area/station/solars/starboard/ulthor
	name = "Ulthor South-East Solar Array"
	icon_state = "panelsS"

// Room and passage boundaries reviewed against Ulthor geometry and Delta/Cyberiad.

/area/station/commons/ulthor_bedroom_west_north
	name = "Ulthor North-West Bedroom"
	icon_state = "Sleep"

/area/station/commons/ulthor_bedroom_west_south
	name = "Ulthor West Bedroom"
	icon_state = "Sleep"

/area/station/engineering/ulthor_eva
	name = "Ulthor EVA Storage"
	icon_state = "eva"

/area/station/engineering/ulthor_monitoring
	name = "Ulthor Engineering Monitoring"
	icon_state = "engine_monitoring"

/area/station/engineering/ulthor_tool_storage
	name = "Ulthor Engineering Equipment Storage"
	icon_state = "engine_storage"

/area/station/hallway/ulthor_eva_access
	name = "Ulthor EVA Access Hallway"
	icon_state = "hallF"

/area/station/hallway/ulthor_service_center
	name = "Ulthor Service Hallway"
	icon_state = "hallF"

/area/station/hallway/ulthor_service_east
	name = "Ulthor Service East Hallway"
	icon_state = "hallF"

/area/station/hallway/ulthor_service_north
	name = "Ulthor North-West Hallway"
	icon_state = "hallF"

/area/station/hallway/ulthor_service_south
	name = "Ulthor Service South Hallway"
	icon_state = "hallF"

/area/station/hallway/ulthor_theatre_access
	name = "Ulthor Theatre Hallway"
	icon_state = "hallF"

/area/station/maintenance/ulthor_ai_passage
	name = "Ulthor AI Maintenance"
	icon_state = "green"

/area/station/maintenance/ulthor_engineering_passage
	name = "Ulthor Engineering Maintenance"
	icon_state = "green"

/area/station/maintenance/ulthor_northwest_passage
	name = "Ulthor North-West Maintenance"
	icon_state = "fpmaint"

/area/station/maintenance/ulthor_research_passage
	name = "Ulthor Research Maintenance"
	icon_state = "asmaint"

/area/station/maintenance/ulthor_service_passage
	name = "Ulthor Service Maintenance"
	icon_state = "pmaint"

/area/station/maintenance/ulthor_west_passage
	name = "Ulthor West Maintenance"
	icon_state = "pmaint"

/area/station/service/barber/ulthor
	name = "Ulthor Barbershop"
	icon_state = "barber"

/area/station/service/ulthor_bar_backroom
	name = "Ulthor Bar Backroom"
	icon_state = "barstation"

/area/station/service/ulthor_costume_storage
	name = "Ulthor Costume Storage"
	icon_state = "Theatre"

/area/station/service/ulthor_kitchen_coldroom
	name = "Ulthor Kitchen Coldroom"
	icon_state = "kitchen"

/area/station/service/ulthor_mime_office
	name = "Ulthor Mime Office"
	icon_state = "mime_office"

/area/station/service/ulthor_theatre
	name = "Ulthor Theatre"
	icon_state = "Theatre"

/area/station/maintenance/ulthor_asylum
	name = "Ulthor Abandoned Ward"
	icon_state = "fsmaint"

/area/station/engineering/ulthor_burn_room
	name = "Ulthor Burn Room"
	icon_state = "atmos"
