class_name EnemyElite
extends EnemyBase

func _ready() -> void:
	max_health = 250
	move_speed = 240.0
	run_speed = 400.0
	attack_range = 3.0
	engage_range = 20.0
	retreat_threshold = 40
	super._ready()