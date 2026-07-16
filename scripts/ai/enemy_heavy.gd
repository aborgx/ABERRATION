class_name EnemyHeavy
extends EnemyBase

func _ready() -> void:
	max_health = 300
	move_speed = 120.0
	run_speed = 200.0
	attack_range = 3.0
	engage_range = 20.0
	retreat_threshold = 50
	super._ready()