class_name PropLibrary
extends Node

## Registry for all modular level props.
## Provides easy instancing and categorization.

var prop_scenes: Dictionary = {}

func _ready() -> void:
	_register_all_props()

func _register_all_props() -> void:
	# Structural
	prop_scenes["wall"] = preload("res://scenes/props/wall_module.tscn")
	prop_scenes["floor"] = preload("res://scenes/props/floor_module.tscn")
	prop_scenes["pillar"] = preload("res://scenes/props/pillar_module.tscn")
	prop_scenes["door"] = preload("res://scenes/props/door_module.tscn")
	prop_scenes["window"] = preload("res://scenes/props/window_module.tscn")
	prop_scenes["stairs"] = preload("res://scenes/props/stairs_module.tscn")
	prop_scenes["corridor"] = preload("res://scenes/props/corridor_module.tscn")
	prop_scenes["room"] = preload("res://scenes/props/room_module.tscn")
	
	# Cover / Destructible
	prop_scenes["barricade"] = preload("res://scenes/props/barricade_prop.tscn")
	prop_scenes["turret"] = preload("res://scenes/props/turret_prop.tscn")
	prop_scenes["tank"] = preload("res://scenes/props/tank_prop.tscn")
	
	# Environmental
	prop_scenes["computer"] = preload("res://scenes/props/computer_prop.tscn")
	prop_scenes["bed"] = preload("res://scenes/props/bed_prop.tscn")
	prop_scenes["desk"] = preload("res://scenes/props/desk_prop.tscn")
	prop_scenes["shelf"] = preload("res://scenes/props/shelf_prop.tscn")
	prop_scenes["lamp"] = preload("res://scenes/props/lamp_prop.tscn")
	
	# Additional structural variants
	prop_scenes["wall_corner"] = preload("res://scenes/props/wall_corner_module.tscn")
	prop_scenes["wall_t"] = preload("res://scenes/props/wall_t_module.tscn")
	prop_scenes["wall_cross"] = preload("res://scenes/props/wall_cross_module.tscn")
	prop_scenes["floor_large"] = preload("res://scenes/props/floor_large_module.tscn")
	prop_scenes["floor_small"] = preload("res://scenes/props/floor_small_module.tscn")
	prop_scenes["ceiling"] = preload("res://scenes/props/ceiling_module.tscn")
	prop_scenes["vent"] = preload("res://scenes/props/vent_module.tscn")
	prop_scenes["pipe_horizontal"] = preload("res://scenes/props/pipe_horizontal_module.tscn")
	prop_scenes["pipe_vertical"] = preload("res://scenes/props/pipe_vertical_module.tscn")
	prop_scenes["cable_tray"] = preload("res://scenes/props/cable_tray_module.tscn")
	prop_scenes["railing"] = preload("res://scenes/props/railing_module.tscn")
	prop_scenes["fence"] = preload("res://scenes/props/fence_module.tscn")
	prop_scenes["gate"] = preload("res://scenes/props/gate_module.tscn")
	prop_scenes["stairs_spiral"] = preload("res://scenes/props/stairs_spiral_module.tscn")
	prop_scenes["elevator_shaft"] = preload("res://scenes/props/elevator_shaft_module.tscn")
	prop_scenes["loading_dock"] = preload("res://scenes/props/loading_dock_module.tscn")
	
	# Office / Interior
	prop_scenes["cubicle"] = preload("res://scenes/props/cubicle_prop.tscn")
	prop_scenes["chair"] = preload("res://scenes/props/chair_prop.tscn")
	prop_scenes["filing_cabinet"] = preload("res://scenes/props/filing_cabinet_prop.tscn")
	prop_scenes["whiteboard"] = preload("res://scenes/props/whiteboard_prop.tscn")
	prop_scenes["water_cooler"] = preload("res://scenes/props/water_cooler_prop.tscn")
	prop_scenes["vending_machine"] = preload("res://scenes/props/vending_machine_prop.tscn")
	prop_scenes["locker"] = preload("res://scenes/props/locker_prop.tscn")
	prop_scenes["bench"] = preload("res://scenes/props/bench_prop.tscn")
	prop_scenes["trash_can"] = preload("res://scenes/props/trash_can_prop.tscn")
	prop_scenes["fire_extinguisher"] = preload("res://scenes/props/fire_extinguisher_prop.tscn")
	prop_scenes["emergency_exit"] = preload("res://scenes/props/emergency_exit_prop.tscn")
	prop_scenes["security_camera"] = preload("res://scenes/props/security_camera_prop.tscn")
	prop_scenes["keycard_reader"] = preload("res://scenes/props/keycard_reader_prop.tscn")
	
	# Industrial / Police Station specific
	prop_scenes["evidence_locker"] = preload("res://scenes/props/evidence_locker_prop.tscn")
	prop_scenes["interrogation_table"] = preload("res://scenes/props/interrogation_table_prop.tscn")
	prop_scenes["one_way_mirror"] = preload("res://scenes/props/one_way_mirror_prop.tscn")
	prop_scenes["cell_door"] = preload("res://scenes/props/cell_door_module.tscn")
	prop_scenes["cell_bed"] = preload("res://scenes/props/cell_bed_prop.tscn")
	prop_scenes["cell_toilet"] = preload("res://scenes/props/cell_toilet_prop.tscn")
	prop_scenes["armory_rack"] = preload("res://scenes/props/armory_rack_prop.tscn")
	prop_scenes["ammo_crate"] = preload("res://scenes/props/ammo_crate_prop.tscn")
	prop_scenes["weapon_locker"] = preload("res://scenes/props/weapon_locker_prop.tscn")
	prop_scenes["riot_shield_rack"] = preload("res://scenes/props/riot_shield_rack_prop.tscn")
	prop_scenes["barrier_tape"] = preload("res://scenes/props/barrier_tape_prop.tscn")
	prop_scenes["traffic_cone"] = preload("res://scenes/props/traffic_cone_prop.tscn")
	prop_scenes["spike_strip"] = preload("res://scenes/props/spike_strip_prop.tscn")

func instance_prop(prop_name: String, position: Vector3 = Vector3.ZERO, rotation: Vector3 = Vector3.ZERO, scale: Vector3 = Vector3.ONE) -> Node3D:
	if not prop_scenes.has(prop_name):
		push_error("Prop not found: ", prop_name)
		return null
	
	var instance = prop_scenes[prop_name].instantiate()
	instance.global_position = position
	instance.rotation = rotation
	instance.scale = scale
	return instance

func get_prop_names() -> Array[String]:
	return prop_scenes.keys()