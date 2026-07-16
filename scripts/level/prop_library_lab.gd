class_name PropLibraryLab
extends Node

## Laboratory-Specific Prop Library — ONLY level-unique modules
## Shared structural/utility/lighting/furniture come from PropLibraryGlobal

var prop_scenes: Dictionary = {}

func _ready() -> void:
	_register_lab_props()

func _register_lab_props() -> void:
	# ============================================================
	# LAB 17 PROPS — modular scene kit (created per spec)
	# ============================================================
	prop_scenes["lab_wall"] = preload("res://scenes/props_lab/lab_wall_module.tscn")
	prop_scenes["lab_floor"] = preload("res://scenes/props_lab/lab_floor_module.tscn")
	prop_scenes["lab_door"] = preload("res://scenes/props_lab/lab_door_module.tscn")
	prop_scenes["lab_window"] = preload("res://scenes/props_lab/lab_window_module.tscn")
	prop_scenes["lab_corridor"] = preload("res://scenes/props_lab/lab_corridor_module.tscn")
	prop_scenes["lab_room"] = preload("res://scenes/props_lab/lab_room_module.tscn")
	prop_scenes["containment_vat"] = preload("res://scenes/props_lab/containment_vat.tscn")
	prop_scenes["experiment_table"] = preload("res://scenes/props_lab/experiment_table.tscn")
	prop_scenes["server_rack"] = preload("res://scenes/props_lab/server_rack.tscn")
	prop_scenes["control_console"] = preload("res://scenes/props_lab/control_console.tscn")
	prop_scenes["ventilation_duct"] = preload("res://scenes/props_lab/ventilation_duct.tscn")
	prop_scenes["lab_shelf"] = preload("res://scenes/props_lab/lab_shelf.tscn")
	prop_scenes["lab_light"] = preload("res://scenes/props_lab/lab_light.tscn")
	prop_scenes["turret_prop"] = preload("res://scenes/props_lab/turret_prop.tscn")
	prop_scenes["laser_grid"] = preload("res://scenes/props_lab/laser_grid.tscn")
	prop_scenes["pipe_cluster"] = preload("res://scenes/props_lab/pipe_cluster.tscn")
	prop_scenes["flood_water"] = preload("res://scenes/props_lab/flood_water.tscn")
	
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