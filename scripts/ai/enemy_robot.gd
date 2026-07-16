class_name EnemyRobot
extends EnemyBase

func _ready() -> void:
	max_health = 500
	move_speed = 90.0
	run_speed = 150.0
	attack_range = 5.0
	engage_range = 15.0
	retreat_threshold = 100
	super._ready()