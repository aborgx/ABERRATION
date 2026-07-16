class_name BloodParticles
extends Node

@export var blood_particle_scene: PackedScene

func spawn_blood(position: Vector3, direction: Vector3, amount: int = 10) -> void:
	if not blood_particle_scene:
		return
	
	for i in range(amount):
		var particle = blood_particle_scene.instantiate()
		add_child(particle)
		particle.global_position = position
		particle.emitting = true
		
		# Random velocity in direction cone
		var spread = 0.5
		var vel = direction + Vector3(
			randf_range(-spread, spread),
			randf_range(0.5, 1.5),
			randf_range(-spread, spread)
		) * randf_range(5.0, 15.0)
		
		particle.velocity = vel
		particle.lifetime = randf_range(0.5, 1.5)
		particle.one_shot = true