class_name EnemyMedic
extends EnemyBase

func _ready() -> void:
	max_health = 70
	move_speed = 270.0
	run_speed = 450.0
	attack_range = 2.0
	engage_range = 10.0
	retreat_threshold = 20
	super._ready()