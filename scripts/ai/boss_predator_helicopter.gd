class_name BossPredatorHelicopter
extends EnemyBase

enum Phase { PHASE1, PHASE2, PHASE3 }
var current_phase: Phase = Phase.PHASE1

func _ready() -> void:
	max_health = 8000
	move_speed = 200.0
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	_update_phase()

func _update_phase() -> void:
	var hp_pct = health / max_health
	
	if hp_pct <= 0.3 and current_phase != Phase.PHASE3:
		current_phase = Phase.PHASE3
		_enter_phase3()
	elif hp_pct <= 0.6 and current_phase != Phase.PHASE2:
		current_phase = Phase.PHASE2
		_enter_phase2()

func _enter_phase2() -> void:
	_land_and_deploy()

func _enter_phase3() -> void:
	_take_off_all_weapons()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	match current_phase:
		Phase.PHASE1: _phase1_behavior(delta)
		Phase.PHASE2: _phase2_behavior(delta)
		Phase.PHASE3: _phase3_behavior(delta)

func _phase1_behavior(delta: float) -> void:
	_strafe_attack()
	if randf() < 0.02:
		_fire_rocket()

func _phase2_behavior(delta: float) -> void:
	_defend_position()

func _phase3_behavior(delta: float) -> void:
	_all_out_attack()

func _strafe_attack() -> void:
	pass

func _fire_rocket() -> void:
	pass

func _land_and_deploy() -> void:
	pass

func _defend_position() -> void:
	pass

func _take_off_all_weapons() -> void:
	pass

func _all_out_attack() -> void:
	pass