class_name EnemyShield
extends EnemyBase

func _ready() -> void:
	max_health = 200
	move_speed = 180.0
	run_speed = 300.0
	attack_range = 2.0
	engage_range = 12.0
	retreat_threshold = 40
	super._ready()