class_name PropLibraryGlobal
extends Node

## Global Shared Prop Library — reusable across ALL levels
## Wave 4 (Police Station) + Wave 5 (Laboratory) + Wave 6 (Industrial) + future levels

var prop_scenes: Dictionary = {}

func _ready() -> void:
	_register_global_props()

func _register_global_props() -> void:
	# ============================================================
	# STRUCTURAL CORE — reusable everywhere (walls, floors, doors)
	# ============================================================
	prop_scenes["wall"] = preload("res://scenes/props_global/wall_module.tscn")
	prop_scenes["wall_corner"] = preload("res://scenes/props_global/wall_corner_module.tscn")
	prop_scenes["wall_t"] = preload("res://scenes/props_global/wall_t_module.tscn")
	prop_scenes["wall_cross"] = preload("res://scenes/props_global/wall_cross_module.tscn")
	prop_scenes["wall_windowed"] = preload("res://scenes/props_global/wall_windowed_module.tscn")
	prop_scenes["wall_doorway"] = preload("res://scenes/props_global/wall_doorway_module.tscn")
	
	prop_scenes["floor"] = preload("res://scenes/props_global/floor_module.tscn")
	prop_scenes["floor_large"] = preload("res://scenes/props_global/floor_large_module.tscn")
	prop_scenes["floor_small"] = preload("res://scenes/props_global/floor_small_module.tscn")
	prop_scenes["floor_grate"] = preload("res://scenes/props_global/floor_grate_module.tscn")
	prop_scenes["floor_raised"] = preload("res://scenes/props_global/floor_raised_module.tscn")
	
	prop_scenes["ceiling"] = preload("res://scenes/props_global/ceiling_module.tscn")
	prop_scenes["ceiling_vented"] = preload("res://scenes/props_global/ceiling_vented_module.tscn")
	prop_scenes["ceiling_piped"] = preload("res://scenes/props_global/ceiling_piped_module.tscn")
	
	prop_scenes["pillar"] = preload("res://scenes/props_global/pillar_module.tscn")
	prop_scenes["pillar_thick"] = preload("res://scenes/props_global/pillar_thick_module.tscn")
	prop_scenes["pillar_decorative"] = preload("res://scenes/props_global/pillar_decorative_module.tscn")
	
	prop_scenes["door_standard"] = preload("res://scenes/props_global/door_standard_module.tscn")
	prop_scenes["door_security"] = preload("res://scenes/props_global/door_security_module.tscn")
	prop_scenes["door_blast"] = preload("res://scenes/props_global/door_blast_module.tscn")
	prop_scenes["door_sliding"] = preload("res://scenes/props_global/door_sliding_module.tscn")
	prop_scenes["door_airlock"] = preload("res://scenes/props_global/door_airlock_module.tscn")
	prop_scenes["door_cell"] = preload("res://scenes/props_global/door_cell_module.tscn")
	
	prop_scenes["window_standard"] = preload("res://scenes/props_global/window_standard_module.tscn")
	prop_scenes["window_reinforced"] = preload("res://scenes/props_global/window_reinforced_module.tscn")
	prop_scenes["window_observation"] = preload("res://scenes/props_global/window_observation_module.tscn")
	prop_scenes["window_blast"] = preload("res://scenes/props_global/window_blast_module.tscn")
	prop_scenes["one_way_mirror"] = preload("res://scenes/props_global/one_way_mirror_module.tscn")
	
	prop_scenes["stairs_straight"] = preload("res://scenes/props_global/stairs_straight_module.tscn")
	prop_scenes["stairs_spiral"] = preload("res://scenes/props_global/stairs_spiral_module.tscn")
	prop_scenes["stairs_emergency"] = preload("res://scenes/props_global/stairs_emergency_module.tscn")
	prop_scenes["ladder_vertical"] = preload("res://scenes/props_global/ladder_vertical_module.tscn")
	prop_scenes["ladder_horizontal"] = preload("res://scenes/props_global/ladder_horizontal_module.tscn")
	
	prop_scenes["corridor_straight"] = preload("res://scenes/props_global/corridor_straight_module.tscn")
	prop_scenes["corridor_corner"] = preload("res://scenes/props_global/corridor_corner_module.tscn")
	prop_scenes["corridor_t"] = preload("res://scenes/props_global/corridor_t_module.tscn")
	
	# ============================================================
	# LIGHTING — reusable everywhere
	# ============================================================
	prop_scenes["light_ceiling"] = preload("res://scenes/props_global/light_ceiling_module.tscn")
	prop_scenes["light_wall"] = preload("res://scenes/props_global/light_wall_module.tscn")
	prop_scenes["light_emergency"] = preload("res://scenes/props_global/light_emergency_module.tscn")
	prop_scenes["light_strip"] = preload("res://scenes/props_global/light_strip_module.tscn")
	prop_scenes["light_spot"] = preload("res://scenes/props_global/light_spot_module.tscn")
	prop_scenes["light_industrial"] = preload("res://scenes/props_global/light_industrial_module.tscn")
	prop_scenes["light_lab"] = preload("res://scenes/props_global/light_lab_module.tscn")
	
	# ============================================================
	# VENTILATION / PIPES / CABLES — reusable everywhere
	# ============================================================
	prop_scenes["vent_cover"] = preload("res://scenes/props_global/vent_cover_module.tscn")
	prop_scenes["vent_duct"] = preload("res://scenes/props_global/vent_duct_module.tscn")
	prop_scenes["grate_floor"] = preload("res://scenes/props_global/grate_floor_module.tscn")
	prop_scenes["grate_wall"] = preload("res://scenes/props_global/grate_wall_module.tscn")
	prop_scenes["pipe_horizontal"] = preload("res://scenes/props_global/pipe_horizontal_module.tscn")
	prop_scenes["pipe_vertical"] = preload("res://scenes/props_global/pipe_vertical_module.tscn")
	prop_scenes["pipe_junction"] = preload("res://scenes/props_global/pipe_junction_module.tscn")
	prop_scenes["pipe_valve"] = preload("res://scenes/props_global/pipe_valve_module.tscn")
	prop_scenes["cable_tray"] = preload("res://scenes/props_global/cable_tray_module.tscn")
	prop_scenes["cable_tray_corner"] = preload("res://scenes/props_global/cable_tray_corner_module.tscn")
	prop_scenes["cable_drop"] = preload("res://scenes/props_global/cable_drop_module.tscn")
	prop_scenes["conduit"] = preload("res://scenes/props_global/conduit_module.tscn")
	
	# ============================================================
	# RAILINGS / FENCES / BARRIERS — reusable everywhere
	# ============================================================
	prop_scenes["railing"] = preload("res://scenes/props_global/railing_module.tscn")
	prop_scenes["railing_stairs"] = preload("res://scenes/props_global/railing_stairs_module.tscn")
	prop_scenes["fence_chainlink"] = preload("res://scenes/props_global/fence_chainlink_module.tscn")
	prop_scenes["fence_metal"] = preload("res://scenes/props_global/fence_metal_module.tscn")
	prop_scenes["barrier_jersey"] = preload("res://scenes/props_global/barrier_jersey_module.tscn")
	prop_scenes["barrier_crowd"] = preload("res://scenes/props_global/barrier_crowd_module.tscn")
	prop_scenes["gate"] = preload("res://scenes/props_global/gate_module.tscn")
	prop_scenes["gate_security"] = preload("res://scenes/props_global/gate_security_module.tscn")
	
	# ============================================================
	# COVER / DESTRUCTIBLE — reusable everywhere
	# ============================================================
	prop_scenes["barricade"] = preload("res://scenes/props_global/barricade_module.tscn")
	prop_scenes["barricade_sandbag"] = preload("res://scenes/props_global/barricade_sandbag_module.tscn")
	prop_scenes["barricade_metal"] = preload("res://scenes/props_global/barricade_metal_module.tscn")
	prop_scenes["crate_wood"] = preload("res://scenes/props_global/crate_wood_module.tscn")
	prop_scenes["crate_metal"] = preload("res://scenes/props_global/crate_metal_module.tscn")
	prop_scenes["crate_plastic"] = preload("res://scenes/props_global/crate_plastic_module.tscn")
	prop_scenes["pallet"] = preload("res://scenes/props_global/pallet_module.tscn")
	prop_scenes["dumpster"] = preload("res://scenes/props_global/dumpster_module.tscn")
	prop_scenes["tank_small"] = preload("res://scenes/props_global/tank_small_module.tscn")
	prop_scenes["tank_large"] = preload("res://scenes/props_global/tank_large_module.tscn")
	prop_scenes["generator"] = preload("res://scenes/props_global/generator_module.tscn")
	prop_scenes["transformer"] = preload("res://scenes/props_global/transformer_module.tscn")
	
	# ============================================================
	# FURNITURE / PROPS — generic office/industrial (reusable)
	# ============================================================
	prop_scenes["desk"] = preload("res://scenes/props_global/desk_module.tscn")
	prop_scenes["chair"] = preload("res://scenes/props_global/chair_module.tscn")
	prop_scenes["chair_office"] = preload("res://scenes/props_global/chair_office_module.tscn")
	prop_scenes["filing_cabinet"] = preload("res://scenes/props_global/filing_cabinet_module.tscn")
	prop_scenes["locker"] = preload("res://scenes/props_global/locker_module.tscn")
	prop_scenes["locker_wide"] = preload("res://scenes/props_global/locker_wide_module.tscn")
	prop_scenes["shelf_metal"] = preload("res://scenes/props_global/shelf_metal_module.tscn")
	prop_scenes["shelf_wood"] = preload("res://scenes/props_global/shelf_wood_module.tscn")
	prop_scenes["cabinet"] = preload("res://scenes/props_global/cabinet_module.tscn")
	prop_scenes["whiteboard"] = preload("res://scenes/props_global/whiteboard_module.tscn")
	prop_scenes["monitor"] = preload("res://scenes/props_global/monitor_module.tscn")
	prop_scenes["keyboard"] = preload("res://scenes/props_global/keyboard_module.tscn")
	prop_scenes["printer"] = preload("res://scenes/props_global/printer_module.tscn")
	prop_scenes["water_cooler"] = preload("res://scenes/props_global/water_cooler_module.tscn")
	prop_scenes["vending_machine"] = preload("res://scenes/props_global/vending_machine_module.tscn")
	prop_scenes["bench"] = preload("res://scenes/props_global/bench_module.tscn")
	prop_scenes["trash_can"] = preload("res://scenes/props_global/trash_can_module.tscn")
	prop_scenes["fire_extinguisher"] = preload("res://scenes/props_global/fire_extinguisher_module.tscn")
	prop_scenes["emergency_exit_sign"] = preload("res://scenes/props_global/emergency_exit_sign_module.tscn")
	prop_scenes["security_camera"] = preload("res://scenes/props_global/security_camera_module.tscn")
	prop_scenes["keycard_reader"] = preload("res://scenes/props_global/keycard_reader_module.tscn")
	prop_scenes["keypad"] = preload("res://scenes/props_global/keypad_module.tscn")
	prop_scenes["intercom"] = preload("res://scenes/props_global/intercom_module.tscn")
	
	# ============================================================
	# SIGNAGE / DECALS — reusable everywhere
	# ============================================================
	prop_scenes["sign_exit"] = preload("res://scenes/props_global/sign_exit_module.tscn")
	prop_scenes["sign_hazard"] = preload("res://scenes/props_global/sign_hazard_module.tscn")
	prop_scenes["sign_biohazard"] = preload("res://scenes/props_global/sign_biohazard_module.tscn")
	prop_scenes["sign_radiation"] = preload("res://scenes/props_global/sign_radiation_module.tscn")
	prop_scenes["sign_high_voltage"] = preload("res://scenes/props_global/sign_high_voltage_module.tscn")
	prop_scenes["sign_fire"] = preload("res://scenes/props_global/sign_fire_module.tscn")
	prop_scenes["sign_no_entry"] = preload("res://scenes/props_global/sign_no_entry_module.tscn")
	prop_scenes["sign_direction"] = preload("res://scenes/props_global/sign_direction_module.tscn")
	prop_scenes["sign_room"] = preload("res://scenes/props_global/sign_room_module.tscn")
	prop_scenes["decal_blood"] = preload("res://scenes/props_global/decal_blood_module.tscn")
	prop_scenes["decal_scorch"] = preload("res://scenes/props_global/decal_scorch_module.tscn")
	prop_scenes["decal_bullet"] = preload("res://scenes/props_global/decal_bullet_module.tscn")
	prop_scenes["decal_crack"] = preload("res://scenes/props_global/decal_crack_module.tscn")
	prop_scenes["decal_oil"] = preload("res://scenes/props_global/decal_oil_module.tscn")
	prop_scenes["decal_chemical"] = preload("res://scenes/props_global/decal_chemical_module.tscn")

func instance_prop(prop_name: String, position: Vector3 = Vector3.ZERO, rotation: Vector3 = Vector3.ZERO, scale: Vector3 = Vector3.ONE) -> Node3D:
	if not prop_scenes.has(prop_name):
		push_error("Global prop not found: ", prop_name)
		return null
	
	var instance = prop_scenes[prop_name].instantiate()
	instance.global_position = position
	instance.rotation = rotation
	instance.scale = scale
	return instance

func get_prop_names() -> Array[String]:
	return prop_scenes.keys()