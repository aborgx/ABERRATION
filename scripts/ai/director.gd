class_name Director
extends Node

@export var tension_curve: Curve
@export var spawn_rate_curve: Curve
@export var enemy_type_curve: Curve

var current_tension: float = 0.0
var time_in_level: float = 0.0
var enemies_killed: int = 0
var damage_taken: int = 0

func _process(delta: float) -> void:
	time_in_level += delta
	update_tension()

func update_tension() -> void:
	var tension_from_time = 0.0
	if tension_curve:
		tension_from_time = tension_curve.sample(time_in_level / 300.0)
	
	var tension_from_kills = enemies_killed * 0.01
	var tension_from_damage = damage_taken * 0.001
	
	current_tension = clamp(
		tension_from_time + tension_from_kills + tension_from_damage,
		0.0,
		1.0
	)

func get_spawn_rate() -> float:
	if spawn_rate_curve:
		return spawn_rate_curve.sample(current_tension)
	return 1.0

func get_enemy_types() -> Array[String]:
	var types: Array[String] = []
	var num_types = 0
	if enemy_type_curve:
		num_types = int(enemy_type_curve.sample(current_tension))
	
	match num_types:
		0: types = ["infantry"]
		1: types = ["infantry", "shield"]
		2: types = ["infantry", "shield", "sniper"]
		3: types = ["infantry", "shield", "sniper", "flamethrower"]
		4: types = ["infantry", "shield", "sniper", "flamethrower", "engineer"]
		_: types = ["infantry"]
	
	return types

func on_enemy_killed() -> void:
	enemies_killed += 1

func on_player_damage(amount: int) -> void:
	damage_taken += amount