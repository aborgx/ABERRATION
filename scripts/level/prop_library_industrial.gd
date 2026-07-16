class_name PropLibraryIndustrial
extends Node

## Industrial Zone-Specific Prop Library — ONLY level-unique modules
## Shared structural/utility/lighting/furniture come from PropLibraryGlobal

var prop_scenes: Dictionary = {}

func _ready() -> void:
	_register_industrial_props()

func _register_industrial_props() -> void:
	# ============================================================
	# INDUSTRIAL-SPECIFIC STRUCTURAL (variants of global with industrial materials)
	# ============================================================
	prop_scenes["ind_wall"] = preload("res://scenes/props_industrial/ind_wall_module.tscn")
	prop_scenes["ind_wall_corrugated"] = preload("res://scenes/props_industrial/ind_wall_corrugated_module.tscn")
	prop_scenes["ind_wall_insulated"] = preload("res://scenes/props_industrial/ind_wall_insulated_module.tscn")
	prop_scenes["ind_floor"] = preload("res://scenes/props_industrial/ind_floor_module.tscn")
	prop_scenes["ind_floor_grate"] = preload("res://scenes/props_industrial/ind_floor_grate_module.tscn")
	prop_scenes["ind_floor_checker"] = preload("res://scenes/props_industrial/ind_floor_checker_module.tscn")
	prop_scenes["ind_ceiling"] = preload("res://scenes/props_industrial/ind_ceiling_module.tscn")
	prop_scenes["ind_ceiling_truss"] = preload("res://scenes/props_industrial/ind_ceiling_truss_module.tscn")
	prop_scenes["ind_door_rollup"] = preload("res://scenes/props_industrial/ind_door_rollup_module.tscn")
	prop_scenes["ind_door_sliding_heavy"] = preload("res://scenes/props_industrial/ind_door_sliding_heavy_module.tscn")
	prop_scenes["ind_door_personnel"] = preload("res://scenes/props_industrial/ind_door_personnel_module.tscn")
	prop_scenes["ind_window_wire"] = preload("res://scenes/props_industrial/ind_window_wire_module.tscn")
	prop_scenes["ind_window_high"] = preload("res://scenes/props_industrial/ind_window_high_module.tscn")
	
	# ============================================================
	# INDUSTRIAL MODULES (the 15+ unique to industrial setting)
	# ============================================================
	prop_scenes["press_hydraulic"] = preload("res://scenes/props_industrial/press_hydraulic_module.tscn")
	prop_scenes["conveyor_belt"] = preload("res://scenes/props_industrial/conveyor_belt_module.tscn")
	prop_scenes["conveyor_belt_curved"] = preload("res://scenes/props_industrial/conveyor_belt_curved_module.tscn")
	prop_scenes["conveyor_belt_incline"] = preload("res://scenes/props_industrial/conveyor_belt_incline_module.tscn")
	prop_scenes["assembly_line"] = preload("res://scenes/props_industrial/assembly_line_module.tscn")
	prop_scenes["robot_arm"] = preload("res://scenes/props_industrial/robot_arm_module.tscn")
	prop_scenes["crane_overhead"] = preload("res://scenes/props_industrial/crane_overhead_module.tscn")
	prop_scenes["crane_gantry"] = preload("res://scenes/props_industrial/crane_gantry_module.tscn")
	prop_scenes["forklift"] = preload("res://scenes/props_industrial/forklift_module.tscn")
	prop_scenes["pallet_rack"] = preload("res://scenes/props_industrial/pallet_rack_module.tscn")
	prop_scenes["storage_tank"] = preload("res://scenes/props_industrial/storage_tank_module.tscn")
	prop_scenes["silo"] = preload("res://scenes/props_industrial/silo_module.tscn")
	prop_scenes["cooling_tower_ind"] = preload("res://scenes/props_industrial/cooling_tower_ind_module.tscn")
	prop_scenes["transformer_yard"] = preload("res://scenes/props_industrial/transformer_yard_module.tscn")
	prop_scenes["substation"] = preload("res://scenes/props_industrial/substation_module.tscn")
	prop_scenes["pipe_rack"] = preload("res://scenes/props_industrial/pipe_rack_module.tscn")
	prop_scenes["valve_station"] = preload("res://scenes/props_industrial/valve_station_module.tscn")
	prop_scenes["pump_station"] = preload("res://scenes/props_industrial/pump_station_module.tscn")
	prop_scenes["compressor_station"] = preload("res://scenes/props_industrial/compressor_station_module.tscn")
	prop_scenes["flare_stack"] = preload("res://scenes/props_industrial/flare_stack_module.tscn")
	prop_scenes["vent_stack"] = preload("res://scenes/props_industrial/vent_stack_module.tscn")
	prop_scenes["scrubber"] = preload("res://scenes/props_industrial/scrubber_module.tscn")
	prop_scenes["baghouse"] = preload("res://scenes/props_industrial/baghouse_module.tscn")
	prop_scenes["cyclone"] = preload("res://scenes/props_industrial/cyclone_module.tscn")
	
	# ============================================================
	# INDUSTRIAL EQUIPMENT / MACHINERY
	# ============================================================
	prop_scenes["lathe"] = preload("res://scenes/props_industrial/lathe_module.tscn")
	prop_scenes["milling_machine"] = preload("res://scenes/props_industrial/milling_machine_module.tscn")
	prop_scenes["grinder"] = preload("res://scenes/props_industrial/grinder_module.tscn")
	prop_scenes["drill_press"] = preload("res://scenes/props_industrial/drill_press_module.tscn")
	prop_scenes["band_saw"] = preload("res://scenes/props_industrial/band_saw_module.tscn")
	prop_scenes["welder"] = preload("res://scenes/props_industrial/welder_module.tscn")
	prop_scenes["plasma_cutter"] = preload("res://scenes/props_industrial/plasma_cutter_module.tscn")
	prop_scenes["press_brake"] = preload("res://scenes/props_industrial/press_brake_module.tscn")
	prop_scenes["shear"] = preload("res://scenes/props_industrial/shear_module.tscn")
	prop_scenes["roller"] = preload("res://scenes/props_industrial/roller_module.tscn")
	prop_scenes["bender"] = preload("res://scenes/props_industrial/bender_module.tscn")
	prop_scenes["punch"] = preload("res://scenes/props_industrial/punch_module.tscn")
	prop_scenes["injection_molder"] = preload("res://scenes/props_industrial/injection_molder_module.tscn")
	prop_scenes["extruder"] = preload("res://scenes/props_industrial/extruder_module.tscn")
	prop_scenes["blow_molder"] = preload("res://scenes/props_industrial/blow_molder_module.tscn")
	
	# ============================================================
	# INDUSTRIAL FURNACES / THERMAL
	# ============================================================
	prop_scenes["furnace_blast"] = preload("res://scenes/props_industrial/furnace_blast_module.tscn")
	prop_scenes["furnace_electric"] = preload("res://scenes/props_industrial/furnace_electric_module.tscn")
	prop_scenes["furnace_induction"] = preload("res://scenes/props_industrial/furnace_induction_module.tscn")
	prop_scenes["kiln"] = preload("res://scenes/props_industrial/kiln_module.tscn")
	prop_scenes["annealing_oven"] = preload("res://scenes/props_industrial/annealing_oven_module.tscn")
	prop_scenes["heat_treat"] = preload("res://scenes/props_industrial/heat_treat_module.tscn")
	prop_scenes["quenching_tank"] = preload("res://scenes/props_industrial/quenching_tank_module.tscn")
	prop_scenes["tempering_oven"] = preload("res://scenes/props_industrial/tempering_oven_module.tscn")
	
	# ============================================================
	# INDUSTRIAL CHEMICAL / PROCESS
	# ============================================================
	prop_scenes["reactor_vessel"] = preload("res://scenes/props_industrial/reactor_vessel_module.tscn")
	prop_scenes["mixing_tank"] = preload("res://scenes/props_industrial/mixing_tank_module.tscn")
	prop_scenes["separator"] = preload("res://scenes/props_industrial/separator_module.tscn")
	prop_scenes["distillation_column"] = preload("res://scenes/props_industrial/distillation_column_module.tscn")
	prop_scenes["heat_exchanger"] = preload("res://scenes/props_industrial/heat_exchanger_module.tscn")
	prop_scenes["filter_press"] = preload("res://scenes/props_industrial/filter_press_module.tscn")
	prop_scenes["centrifuge_ind"] = preload("res://scenes/props_industrial/centrifuge_ind_module.tscn")
	prop_scenes["dryer_rotary"] = preload("res://scenes/props_industrial/dryer_rotary_module.tscn")
	prop_scenes["crystallizer"] = preload("res://scenes/props_industrial/crystallizer_module.tscn")
	prop_scenes["evaporator"] = preload("res://scenes/props_industrial/evaporator_module.tscn")
	
	# ============================================================
	# INDUSTRIAL CONTROL / INSTRUMENTATION
	# ============================================================
	prop_scenes["control_room_console"] = preload("res://scenes/props_industrial/control_room_console_module.tscn")
	prop_scenes["scada_station"] = preload("res://scenes/props_industrial/scada_station_module.tscn")
	prop_scenes["hmi_panel"] = preload("res://scenes/props_industrial/hmi_panel_module.tscn")
	prop_scenes["annunciator_panel"] = preload("res://scenes/props_industrial/annunciator_panel_module.tscn")
	prop_scenes["chart_recorder"] = preload("res://scenes/props_industrial/chart_recorder_module.tscn")
	prop_scenes["field_instrument"] = preload("res://scenes/props_industrial/field_instrument_module.tscn")
	prop_scenes["dcs_cabinet"] = preload("res://scenes/props_industrial/dcs_cabinet_module.tscn")
	prop_scenes["plc_cabinet"] = preload("res://scenes/props_industrial/plc_cabinet_module.tscn")
	prop_scenes["marshalling_cabinet"] = preload("res://scenes/props_industrial/marshalling_cabinet_module.tscn")
	prop_scenes["junction_box"] = preload("res://scenes/props_industrial/junction_box_module.tscn")
	
	# ============================================================
	# INDUSTRIAL SAFETY / ENVIRONMENTAL
	# ============================================================
	prop_scenes["eye_wash_ind"] = preload("res://scenes/props_industrial/eye_wash_ind_module.tscn")
	prop_scenes["safety_shower_ind"] = preload("res://scenes/props_industrial/safety_shower_ind_module.tscn")
	prop_scenes["spill_containment"] = preload("res://scenes/props_industrial/spill_containment_module.tscn")
	prop_scenes["fire_monitor"] = preload("res://scenes/props_industrial/fire_monitor_module.tscn")
	prop_scenes["deluge_valve"] = preload("res://scenes/props_industrial/deluge_valve_module.tscn")
	prop_scenes["foam_system"] = preload("res://scenes/props_industrial/foam_system_module.tscn")
	prop_scenes["gas_detector"] = preload("res://scenes/props_industrial/gas_detector_module.tscn")
	prop_scenes["flame_detector"] = preload("res://scenes/props_industrial/flame_detector_module.tscn")
	prop_scenes["h2s_monitor"] = preload("res://scenes/props_industrial/h2s_monitor_module.tscn")
	prop_scenes["wind_sock"] = preload("res://scenes/props_industrial/wind_sock_module.tscn")
	prop_scenes["muster_point"] = preload("res://scenes/props_industrial/muster_point_module.tscn")
	prop_scenes["escape_chute"] = preload("res://scenes/props_industrial/escape_chute_module.tscn")
	prop_scenes["lifeboat"] = preload("res://scenes/props_industrial/lifeboat_module.tscn")
	
	# ============================================================
	# INDUSTRIAL LIGHTING (industrial-specific variants)
	# ============================================================
	prop_scenes["light_high_bay"] = preload("res://scenes/props_industrial/light_high_bay_module.tscn")
	prop_scenes["light_flood"] = preload("res://scenes/props_industrial/light_flood_module.tscn")
	prop_scenes["light_explosion_proof"] = preload("res://scenes/props_industrial/light_explosion_proof_module.tscn")
	prop_scenes["light_obstruction"] = preload("res://scenes/props_industrial/light_obstruction_module.tscn")
	prop_scenes["light_runway"] = preload("res://scenes/props_industrial/light_runway_module.tscn")
	prop_scenes["light_stack"] = preload("res://scenes/props_industrial/light_stack_module.tscn")
	
	# ============================================================
	# INDUSTRIAL HAZARDS / ENVIRONMENTAL
	# ============================================================
	prop_scenes["oil_spill"] = preload("res://scenes/props_industrial/oil_spill_module.tscn")
	prop_scenes["chemical_pool"] = preload("res://scenes/props_industrial/chemical_pool_module.tscn")
	prop_scenes["steam_vent_ind"] = preload("res://scenes/props_industrial/steam_vent_ind_module.tscn")
	prop_scenes["hot_surface"] = preload("res://scenes/props_industrial/hot_surface_module.tscn")
	prop_scenes["moving_machinery"] = preload("res://scenes/props_industrial/moving_machinery_module.tscn")
	prop_scenes["pinch_point"] = preload("res://scenes/props_industrial/pinch_point_module.tscn")
	prop_scenes["confined_space"] = preload("res://scenes/props_industrial/confined_space_module.tscn")
	prop_scenes["h2s_zone"] = preload("res://scenes/props_industrial/h2s_zone_module.tscn")
	prop_scenes["radiation_zone_ind"] = preload("res://scenes/props_industrial/radiation_zone_ind_module.tscn")
	prop_scenes["asbestos_zone"] = preload("res://scenes/props_industrial/asbestos_zone_module.tscn")
	
	# ============================================================
	# BOSS AREA — treated as unique SCENE, not generic prefab
	# ============================================================
	# prop_scenes["boss_arena_foundry"] = preload("res://scenes/levels/boss_arena_foundry.tscn")  # SCENE

func instance_prop(prop_name: String, position: Vector3 = Vector3.ZERO, rotation: Vector3 = Vector3.ZERO, scale: Vector3 = Vector3.ONE) -> Node3D:
	if not prop_scenes.has(prop_name):
		push_error("Industrial prop not found: ", prop_name)
		return null
	
	var instance = prop_scenes[prop_name].instantiate()
	instance.global_position = position
	instance.rotation = rotation
	instance.scale = scale
	return instance

func get_prop_names() -> Array[String]:
	return prop_scenes.keys()