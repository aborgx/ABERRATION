class_name EnemyEngineer
extends EnemyBase

func _ready() -> void:
	max_health = 90
	move_speed = 210.0
	run_speed = 350.0
	attack_range = 3.0
	engage_range = 12.0
	retreat_threshold = 30
	super._ready()