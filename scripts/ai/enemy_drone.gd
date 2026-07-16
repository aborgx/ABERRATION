class_name EnemyDrone
extends EnemyBase

func _ready() -> void:
	max_health = 50
	move_speed = 450.0
	run_speed = 750.0
	attack_range = 4.0
	engage_range = 25.0
	retreat_threshold = 15
	super._ready()