class_name PropLibrary
extends Node
## Registry for all modular level props.
## Provides lookup by type string for procedural level generation.

var prop_scenes: Dictionary = {
	"wall": preload("res://scenes/props/wall_module.tscn"),
	"floor": preload("res://scenes/props/floor_module.tscn"),
	"pillar": preload("res://scenes/props/pillar_module.tscn"),
	"door": preload("res://scenes/props/door_module.tscn"),
	"window": preload("res://scenes/props/window_module.tscn"),
	"stairs": preload("res://scenes/props/stairs_module.tscn"),
	"corridor": preload("res://scenes/props/corridor_module.tscn"),
	"room": preload("res://scenes/props/room_module.tscn"),
	"barricade": preload("res://scenes/props/barricade_prop.tscn"),
	"turret": preload("res://scenes/props/turret_prop.tscn"),
	"tank": preload("res://scenes/props/tank_prop.tscn"),
	"computer": preload("res://scenes/props/computer_prop.tscn"),
	"bed": preload("res://scenes/props/bed_prop.tscn"),
	"desk": preload("res://scenes/props/desk_prop.tscn"),
	"shelf": preload("res://scenes/props/shelf_prop.tscn"),
	"lamp": preload("res://scenes/props/lamp_prop.tscn"),
}

func get_prop(prop_type: String) -> PackedScene:
	if prop_scenes.has(prop_type):
		return prop_scenes[prop_type]
	return null

func get_all_types() -> Array[String]:
	return prop_scenes.keys()

func instantiate_prop(prop_type: String) -> Node3D:
	var scene = get_prop(prop_type)
	if scene:
		return scene.instantiate()
	return null
