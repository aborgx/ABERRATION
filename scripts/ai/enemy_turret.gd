class_name EnemyTurret
extends Node3D
## Stationary turret enemy. Detects player, rotates toward target, fires projectiles.
## Not a full EnemyBase — uses simpler AI for fixed emplacement.

signal turret_destroyed

@export var max_health: int = 100
@export var detection_range: float = 15.0
@export var fire_rate: float = 1.5
@export var projectile_speed: float = 800.0
@export var rotation_speed: float = 2.0

var health: int
var is_active: bool = true
var target: Node3D = null
var fire_timer: float = 0.0
var can_see_target: bool = false

func _ready() -> void:
	health = max_health
	add_to_group("enemies")

func _process(delta: float) -> void:
	if not is_active:
		return
	
	_acquire_target()
	
	if can_see_target and target:
		_rotate_toward_target(delta)
		fire_timer -= delta
		if fire_timer <= 0:
			_fire()
	
	# Auto-destroy if health depleted
	if health <= 0:
		_destroy()

func _acquire_target() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		can_see_target = false
		return
	
	var dist = global_position.distance_to(player.global_position)
	if dist > detection_range:
		can_see_target = false
		return
	
	# Line of sight check
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, player.global_position, 2)
	var result = space.intersect_ray(query)
	
	can_see_target = not result
	if can_see_target:
		target = player

func _rotate_toward_target(delta: float) -> void:
	if not target:
		return
	var dir = (target.global_position - global_position).normalized()
	var target_basis = global_transform.looking_at(global_position + dir * Vector3(1, 0, 1), Vector3.UP)
	global_transform = global_transform.interpolate_with(target_basis, rotation_speed * delta)

func _fire() -> void:
	fire_timer = fire_rate
	# Placeholder: spawn projectile toward target
	# Would instantiate a bullet scene and launch it

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		_destroy()

func _destroy() -> void:
	is_active = false
	turret_destroyed.emit()
	queue_free()
