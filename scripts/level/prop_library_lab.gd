class_name PropLibraryLab
extends Node
## Registry for laboratory modular props.

var prop_scenes: Dictionary = {
	"lab_wall": preload("res://scenes/props_lab/lab_wall_module.tscn"),
	"lab_floor": preload("res://scenes/props_lab/lab_floor_module.tscn"),
	"lab_door": preload("res://scenes/props_lab/lab_door_module.tscn"),
	"lab_window": preload("res://scenes/props_lab/lab_window_module.tscn"),
	"lab_corridor": preload("res://scenes/props_lab/lab_corridor_module.tscn"),
	"lab_room": preload("res://scenes/props_lab/lab_room_module.tscn"),
	"containment_vat": preload("res://scenes/props_lab/containment_vat.tscn"),
	"experiment_table": preload("res://scenes/props_lab/experiment_table.tscn"),
	"server_rack": preload("res://scenes/props_lab/server_rack.tscn"),
	"control_console": preload("res://scenes/props_lab/control_console.tscn"),
	"ventilation_duct": preload("res://scenes/props_lab/ventilation_duct.tscn"),
	"lab_shelf": preload("res://scenes/props_lab/lab_shelf.tscn"),
	"lab_light": preload("res://scenes/props_lab/lab_light.tscn"),
	"turret_lab": preload("res://scenes/props_lab/turret_prop_lab.tscn"),
	"laser_grid": preload("res://scenes/props_lab/laser_grid.tscn"),
	"pipe_cluster": preload("res://scenes/props_lab/pipe_cluster.tscn"),
	"flood_water": preload("res://scenes/props_lab/flood_water.tscn"),
}

func get_prop(prop_type: String) -> PackedScene:
	return prop_scenes.get(prop_type, null)

func get_all_types() -> Array[String]:
	return prop_scenes.keys()

func instantiate_prop(prop_type: String) -> Node3D:
	var scene = get_prop(prop_type)
	return scene.instantiate() if scene else null
