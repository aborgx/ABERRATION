class_name EnemySniper
extends EnemyBase

func _ready() -> void:
	max_health = 80
	move_speed = 150.0
	run_speed = 250.0
	attack_range = 40.0
	engage_range = 30.0
	retreat_threshold = 25
	super._ready()