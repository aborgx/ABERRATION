extends Node
## Patrol: enemy walks between waypoints.

var enemy: EnemyBase
var current_waypoint: Vector3

func setup(e: EnemyBase) -> void:
	enemy = e

func enter() -> void:
	current_waypoint = _pick_waypoint()
	enemy.play_anim("walk")

func exit() -> void:
	pass

func process(delta: float) -> void:
	if enemy.can_see_player:
		enemy.fsm.transition("alert")

func physics_process(delta: float) -> void:
	if enemy.global_position.distance_to(current_waypoint) < 2.0:
		current_waypoint = _pick_waypoint()
	enemy.move_toward(current_waypoint, enemy.move_speed)

func _pick_waypoint() -> Vector3:
	# Use spawn point or wander around start position
	var spawns = enemy.get_tree().get_nodes_in_group("spawn_points")
	if spawns.size() > 0:
		var idx = randi() % spawns.size()
		return spawns[idx].global_position
	# Fallback: wander in a radius
	var angle = randf() * TAU
	var dist = 5.0 + randf() * 10.0
	var offset = Vector3(cos(angle), 0, sin(angle)) * dist
	return enemy.global_position + offset
