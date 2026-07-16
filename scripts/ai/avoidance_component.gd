class_name AvoidanceComponent
extends Node3D

@export var avoidance_radius: float = 2.0
@export var avoidance_weight: float = 2.0

func calculate_avoidance_force(enemy: Dictionary, neighbors: Array) -> Vector3:
	var force = Vector3.ZERO
	var pos = enemy.global_position
	
	for neighbor in neighbors:
		var diff = pos - neighbor.global_position
		var distance = diff.length()
		
		if distance < avoidance_radius and distance > 0:
			force += diff.normalized() * (avoidance_radius - distance)
	
	return force * avoidance_weight