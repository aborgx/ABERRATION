class_name ModularProp
extends StaticBody3D

## Base class for all modular level props.
## Provides consistent collision, visual, and pooling interface.

@export var prop_type: String = "generic"
@export var is_destructible: bool = false
@export var health: int = 100

func _ready() -> void:
	set_collision_layer_value(2, true)  # Environment layer
	set_collision_mask_value(1, true)   # Player
	set_collision_mask_value(3, true)   # Enemies
	set_collision_mask_value(4, true)   # Projectiles

func take_damage(amount: int) -> void:
	if not is_destructible:
		return
	health -= amount
	if health <= 0:
		_destroy()

func _destroy() -> void:
	# Spawn debris, particles, sound
	queue_free()

func get_prop_data() -> Dictionary:
	return {
		"type": prop_type,
		"position": global_position,
		"rotation": global_rotation,
		"scale": scale
	}