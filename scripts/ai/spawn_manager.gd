class_name SpawnManager
extends Node

@export var max_enemies: int = 200
@export var spawn_radius: float = 30.0

var current_enemies: int = 0
var spawn_points: Array = []
var enemy_pool: Node
var director: Director

func _ready() -> void:
	spawn_points = get_tree().get_nodes_in_group("spawn_points")
	enemy_pool = get_tree().get_first_node_in_group("pool_manager")
	director = get_tree().get_first_node_in_group("director")

func get_spawn_rate() -> float:
	if director:
		return director.get_spawn_rate()
	return 1.0

func spawn_next_enemy() -> bool:
	if current_enemies >= max_enemies:
		return false
	if not director:
		return false
	var types: Array[String] = director.get_enemy_types()
	if types.is_empty():
		return false
	var enemy_type = types[randi() % types.size()]
	spawn_enemy(enemy_type)
	return true

func spawn_enemy(enemy_type: String) -> void:
	if current_enemies >= max_enemies:
		return
	
	var spawn_point = get_best_spawn_point()
	if spawn_point == null:
		return
	
	var enemy = enemy_pool.get_from_pool(enemy_type)
	if enemy == null:
		return
	
	enemy.global_position = spawn_point.global_position
	enemy.health = enemy.max_health
	enemy.visible = true
	enemy.set_process(true)
	enemy.set_physics_process(true)
	
	current_enemies += 1

func get_best_spawn_point() -> Node3D:
	var best_point = null
	var best_score = -1.0
	
	for point in spawn_points:
		var score = calculate_spawn_score(point)
		if score > best_score:
			best_score = score
			best_point = point
	
	return best_point

func calculate_spawn_score(point: Node3D) -> float:
	var score = 0.0
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = point.global_position.distance_to(player.global_position)
		if distance > 10.0 and distance < spawn_radius:
			score += 100.0 - distance
	
	if point.has_node("Cover"):
		score += 20.0
	
	score += randf() * 10.0
	
	return score