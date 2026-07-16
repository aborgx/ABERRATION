class_name BoidsComponent
extends Node3D

@export var separation_weight: float = 1.5
@export var alignment_weight: float = 1.0
@export var cohesion_weight: float = 0.5
@export var separation_radius: float = 2.0
@export var alignment_radius: float = 5.0
@export var cohesion_radius: float = 10.0

func calculate_boids_force(enemy: Dictionary, neighbors: Array) -> Vector3:
	var separation = calculate_separation(enemy, neighbors)
	var alignment = calculate_alignment(enemy, neighbors)
	var cohesion = calculate_cohesion(enemy, neighbors)
	
	return (separation * separation_weight +
			alignment * alignment_weight +
			cohesion * cohesion_weight)

func calculate_separation(enemy: Dictionary, neighbors: Array) -> Vector3:
	var force = Vector3.ZERO
	var pos = enemy.global_position
	
	for neighbor in neighbors:
		var diff = pos - neighbor.global_position
		var dist = diff.length()
		
		if dist > 0 and dist < separation_radius:
			force += diff.normalized() / dist
	
	return force.normalized() if force.length() > 0 else Vector3.ZERO

func calculate_alignment(enemy: Dictionary, neighbors: Array) -> Vector3:
	var avg_velocity = Vector3.ZERO
	var count = 0
	
	for neighbor in neighbors:
		var dist = enemy.global_position.distance_to(neighbor.global_position)
		if dist < alignment_radius:
			avg_velocity += neighbor.velocity
			count += 1
	
	if count > 0:
		avg_velocity /= count
		return avg_velocity.normalized()
	
	return Vector3.ZERO

func calculate_cohesion(enemy: Dictionary, neighbors: Array) -> Vector3:
	var avg_position = Vector3.ZERO
	var count = 0
	
	for neighbor in neighbors:
		var dist = enemy.global_position.distance_to(neighbor.global_position)
		if dist < cohesion_radius:
			avg_position += neighbor.global_position
			count += 1
	
	if count > 0:
		avg_position /= count
		return (avg_position - enemy.global_position).normalized()
	
	return Vector3.ZERO

func get_neighbors(enemy: Dictionary, radius: float) -> Array:
	# To be implemented by enemy - returns nearby enemies
	return []