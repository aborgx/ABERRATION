class_name BossAssaultRobot
extends EnemyBase

var weak_points = {
	"head": 2.0,
	"back": 3.0,
	"legs": 0.5,
	"arms": 0.0
}

enum Phase { PHASE1, PHASE2, PHASE3 }
var current_phase: int = 1

func _ready() -> void:
	max_health = 5000
	move_speed = 80.0
	run_speed = 120.0
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	_check_phase_transition()

func _check_phase_transition() -> void:
	var hp_pct = health / max_health
	
	if hp_pct <= 0.3 and current_phase != 3:
		current_phase = 3
		_enter_phase3()
	elif hp_pct <= 0.6 and current_phase != 2:
		current_phase = 2
		_enter_phase2()

func _enter_phase2() -> void:
	_separate_parts()

func _enter_phase3() -> void:
	_start_self_destruct()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	match current_phase:
		1: _phase1_behavior(delta)
		2: _phase2_behavior(delta)
		3: _phase3_behavior(delta)

func _phase1_behavior(delta: float) -> void:
	if player_distance < 15.0:
		_fire_laser()
	else:
		_fire_missiles()

func _phase2_behavior(delta: float) -> void:
	# Flying parts attack
	pass

func _phase3_behavior(delta: float) -> void:
	# Self-destruct sequence
	pass

func _fire_laser() -> void:
	pass

func _fire_missiles() -> void:
	pass

func _separate_parts() -> void:
	pass

func _start_self_destruct() -> void:
	pass