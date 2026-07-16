class_name PropLibraryLab
extends Node

## Laboratory-Specific Prop Library — ONLY level-unique modules
## Shared structural/utility/lighting/furniture come from PropLibraryGlobal

var prop_scenes: Dictionary = {}

func _ready() -> void:
	_register_lab_props()

func _register_lab_props() -> void:
	# ============================================================
	# LAB-SPECIFIC STRUCTURAL (variants of global with lab materials)
	# ============================================================
	prop_scenes["lab_wall"] = preload("res://scenes/props_lab/lab_wall_module.tscn")
	prop_scenes["lab_wall_cleanroom"] = preload("res://scenes/props_lab/lab_wall_cleanroom_module.tscn")
	prop_scenes["lab_floor"] = preload("res://scenes/props_lab/lab_floor_module.tscn")
	prop_scenes["lab_floor_raised"] = preload("res://scenes/props_lab/lab_floor_raised_module.tscn")
	prop_scenes["lab_floor_grate"] = preload("res://scenes/props_lab/lab_floor_grate_module.tscn")
	prop_scenes["lab_ceiling"] = preload("res://scenes/props_lab/lab_ceiling_module.tscn")
	prop_scenes["lab_ceiling_cleanroom"] = preload("res://scenes/props_lab/lab_ceiling_cleanroom_module.tscn")
	prop_scenes["lab_door_airlock"] = preload("res://scenes/props_lab/lab_door_airlock_module.tscn")
	prop_scenes["lab_door_sliding"] = preload("res://scenes/props_lab/lab_door_sliding_module.tscn")
	prop_scenes["lab_door_blast"] = preload("res://scenes/props_lab/lab_door_blast_module.tscn")
	prop_scenes["lab_window_reinforced"] = preload("res://scenes/props_lab/lab_window_reinforced_module.tscn")
	prop_scenes["lab_window_observation"] = preload("res://scenes/props_lab/lab_window_observation_module.tscn")
	prop_scenes["lab_one_way_mirror"] = preload("res://scenes/props_lab/lab_one_way_mirror_module.tscn")
	
	# ============================================================
	# LAB-SPECIFIC MODULES (the 15+ unique to laboratory setting)
	# ============================================================
	prop_scenes["clean_room"] = preload("res://scenes/props_lab/clean_room_module.tscn")
	prop_scenes["glass_corridor"] = preload("res://scenes/props_lab/glass_corridor_module.tscn")
	prop_scenes["reactor_core"] = preload("res://scenes/props_lab/reactor_core_module.tscn")
	prop_scenes["containment_cell"] = preload("res://scenes/props_lab/containment_cell_module.tscn")
	prop_scenes["observation_room"] = preload("res://scenes/props_lab/observation_room_module.tscn")
	prop_scenes["specimen_tank"] = preload("res://scenes/props_lab/specimen_tank_module.tscn")
	prop_scenes["vent_shaft"] = preload("res://scenes/props_lab/vent_shaft_module.tscn")
	prop_scenes["server_rack_lab"] = preload("res://scenes/props_lab/server_rack_lab_module.tscn")
	prop_scenes["decontamination_gate"] = preload("res://scenes/props_lab/decontamination_gate_module.tscn")
	prop_scenes["elevator_module_lab"] = preload("res://scenes/props_lab/elevator_module_lab.tscn")
	prop_scenes["cable_bridge"] = preload("res://scenes/props_lab/cable_bridge_module.tscn")
	prop_scenes["emergency_generator_lab"] = preload("res://scenes/props_lab/emergency_generator_lab_module.tscn")
	prop_scenes["biohazard_storage"] = preload("res://scenes/props_lab/biohazard_storage_module.tscn")
	prop_scenes["security_checkpoint_lab"] = preload("res://scenes/props_lab/security_checkpoint_lab_module.tscn")
	prop_scenes["research_office"] = preload("res://scenes/props_lab/research_office_module.tscn")
	
	# ============================================================
	# LAB EQUIPMENT / FURNITURE (lab-themed variants)
	# ============================================================
	prop_scenes["experiment_table"] = preload("res://scenes/props_lab/experiment_table_module.tscn")
	prop_scenes["control_console_lab"] = preload("res://scenes/props_lab/control_console_lab_module.tscn")
	prop_scenes["lab_bench"] = preload("res://scenes/props_lab/lab_bench_module.tscn")
	prop_scenes["fume_hood"] = preload("res://scenes/props_lab/fume_hood_module.tscn")
	prop_scenes["biosafety_cabinet"] = preload("res://scenes/props_lab/biosafety_cabinet_module.tscn")
	prop_scenes["centrifuge"] = preload("res://scenes/props_lab/centrifuge_module.tscn")
	prop_scenes["incubator"] = preload("res://scenes/props_lab/incubator_module.tscn")
	prop_scenes["autoclave"] = preload("res://scenes/props_lab/autoclave_module.tscn")
	prop_scenes["microscope"] = preload("res://scenes/props_lab/microscope_module.tscn")
	prop_scenes["spectrometer"] = preload("res://scenes/props_lab/spectrometer_module.tscn")
	prop_scenes["pcr_machine"] = preload("res://scenes/props_lab/pcr_machine_module.tscn")
	prop_scenes["freezer_ultra_low"] = preload("res://scenes/props_lab/freezer_ultra_low_module.tscn")
	prop_scenes["liquid_nitrogen_tank"] = preload("res://scenes/props_lab/liquid_nitrogen_tank_module.tscn")
	prop_scenes["gas_cylinder_rack"] = preload("res://scenes/props_lab/gas_cylinder_rack_module.tscn")
	prop_scenes["chemical_cabinet"] = preload("res://scenes/props_lab/chemical_cabinet_module.tscn")
	prop_scenes["eye_wash_lab"] = preload("res://scenes/props_lab/eye_wash_lab_module.tscn")
	prop_scenes["safety_shower_lab"] = preload("res://scenes/props_lab/safety_shower_lab_module.tscn")
	prop_scenes["spill_kit"] = preload("res://scenes/props_lab/spill_kit_module.tscn")
	prop_scenes["sharps_container"] = preload("res://scenes/props_lab/sharps_container_module.tscn")
	prop_scenes["biohazard_bag"] = preload("res://scenes/props_lab/biohazard_bag_module.tscn")
	
	# ============================================================
	# LAB SECURITY / CONTAINMENT
	# ============================================================
	prop_scenes["laser_grid"] = preload("res://scenes/props_lab/laser_grid_module.tscn")
	prop_scenes["turret_lab"] = preload("res://scenes/props_lab/turret_lab_module.tscn")
	prop_scenes["containment_field"] = preload("res://scenes/props_lab/containment_field_module.tscn")
	prop_scenes["airlock_cycle"] = preload("res://scenes/props_lab/airlock_cycle_module.tscn")
	prop_scenes["pressure_door"] = preload("res://scenes/props_lab/pressure_door_module.tscn")
	prop_scenes["quarantine_barrier"] = preload("res://scenes/props_lab/quarantine_barrier_module.tscn")
	
	# ============================================================
	# LAB LIGHTING (lab-specific variants)
	# ============================================================
	prop_scenes["light_lab_ceiling"] = preload("res://scenes/props_lab/light_lab_ceiling_module.tscn")
	prop_scenes["light_lab_emergency"] = preload("res://scenes/props_lab/light_lab_emergency_module.tscn")
	prop_scenes["light_lab_uv"] = preload("res://scenes/props_lab/light_lab_uv_module.tscn")
	prop_scenes["light_lab_containment"] = preload("res://scenes/props_lab/light_lab_containment_module.tscn")
	prop_scenes["light_lab_biosafety"] = preload("res://scenes/props_lab/light_lab_biosafety_module.tscn")
	
	# ============================================================
	# LAB HAZARDS / ENVIRONMENTAL
	# ============================================================
	prop_scenes["flood_water_lab"] = preload("res://scenes/props_lab/flood_water_lab_module.tscn")
	prop_scenes["chemical_spill"] = preload("res://scenes/props_lab/chemical_spill_module.tscn")
	prop_scenes["steam_leak"] = preload("res://scenes/props_lab/steam_leak_module.tscn")
	prop_scenes["gas_leak"] = preload("res://scenes/props_lab/gas_leak_module.tscn")
	prop_scenes["radiation_zone"] = preload("res://scenes/props_lab/radiation_zone_module.tscn")
	prop_scenes["emp_field"] = preload("res://scenes/props_lab/emp_field_module.tscn")
	
	# ============================================================
	# BOSS AREA — treated as unique SCENE, not generic prefab
	# ============================================================
	# prop_scenes["boss_arena_assault_robot"] = preload("res://scenes/levels/boss_arena_assault_robot.tscn")  # SCENE

func instance_prop(prop_name: String, position: Vector3 = Vector3.ZERO, rotation: Vector3 = Vector3.ZERO, scale: Vector3 = Vector3.ONE) -> Node3D:
	if not prop_scenes.has(prop_name):
		push_error("Lab prop not found: ", prop_name)
		return null
	
	var instance = prop_scenes[prop_name].instantiate()
	instance.global_position = position
	instance.rotation = rotation
	instance.scale = scale
	return instance

func get_prop_names() -> Array[String]:
	return prop_scenes.keys()