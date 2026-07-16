class_name BossJuggernaut
extends EnemyBase

enum Phase { PHASE1, PHASE2, PHASE3 }
var current_phase: Phase = Phase.PHASE1
var shield_active: bool = false
var armor_broken: bool = false

func _ready() -> void:
	max_health = 2000
	move_speed = 150.0
	run_speed = 250.0
	attack_range = 3.0
	engage_range = 20.0
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	_update_phase()

func _update_phase() -> void:
	var hp_pct = health / max_health
	
	if hp_pct <= 0.4 and current_phase != Phase.PHASE3:
		current_phase = Phase.PHASE3
		_enter_phase3()
	elif hp_pct <= 0.7 and current_phase != Phase.PHASE2:
		current_phase = Phase.PHASE2
		_enter_phase2()

func _enter_phase2() -> void:
	_spawn_reinforcements(5)
	shield_active = true

func _enter_phase3() -> void:
	armor_broken = true
	speed_multiplier = 1.5
	damage_multiplier = 1.5

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	match current_phase:
		Phase.PHASE1:
			_phase1_behavior(delta)
		Phase.PHASE2:
			_phase2_behavior(delta)
		Phase.PHASE3:
			_phase3_behavior(delta)

func _phase1_behavior(delta: float) -> void:
	if player_distance < 10.0:
		_shoot()
	else:
		navigation.set_target(player.global_position)

func _phase2_behavior(delta: float) -> void:
	if shield_active:
		if player_distance < 3.0:
			_shield_bash()
	else:
		navigation.set_target(player.global_position)

func _phase3_behavior(delta: float) -> void:
	if can_attack:
		_melee_attack()
		attack_cooldown = 0.5

func _shoot() -> void:
	pass

func _shield_bash() -> void:
	pass

func _melee_attack() -> void:
	pass

func _spawn_reinforcements(count: int) -> void:
	var spawn = get_tree().get_first_node_in_group("spawn_manager")
	if spawn:
		for i in range(count):
			spawn.spawn_enemy("infantry")