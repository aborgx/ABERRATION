class_name EnemyFlamethrower
extends EnemyBase

func _ready() -> void:
	max_health = 120
	move_speed = 240.0
	run_speed = 400.0
	attack_range = 5.0
	engage_range = 10.0
	retreat_threshold = 35
	super._ready()