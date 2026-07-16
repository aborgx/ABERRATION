class_name DestructibleProp
extends StaticBody3D

@export var max_health: int = 100
@export var destroy_effect: PackedScene

var health: int = 0

func _ready() -> void:
	health = max_health

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		_destroy()

func _destroy() -> void:
	if destroy_effect:
		var effect = destroy_effect.instantiate()
		get_parent().add_child(effect)
		effect.global_position = global_position
	queue_free()