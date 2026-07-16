class_name EnemyInfantry
extends EnemyBase

func _ready() -> void:
	max_health = 100
	move_speed = 300.0
	run_speed = 500.0
	attack_range = 2.5
	engage_range = 15.0
	retreat_threshold = 30
	super._ready()