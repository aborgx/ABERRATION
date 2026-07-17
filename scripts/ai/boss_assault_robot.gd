class_name BossAssaultRobot
extends EnemyBase

enum Phase { PHASE1, PHASE2, PHASE3 }
var current_phase: int = 1

# Combat stats
var can_attack: bool = true
var attack_cooldown: float = 2.0
var _attack_timer: float = 0.0
var speed_multiplier: float = 1.0
var damage_multiplier: float = 1.0

# Phase state
var parts_separated: bool = false
var self_destruct_active: bool = false
var self_destruct_time: float = 10.0

# Weak points: head(x2), back(x3), legs(x0.5)
var weak_points = {
	"head": 2.0,
	"back": 3.0,
	"legs": 0.5,
}

func _ready() -> void:
	max_health = 5000
	move_speed = 80.0
	run_speed = 120.0
	attack_range = 15.0
	engage_range = 25.0
	lose_range = 40.0
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	_check_phase_transition()
	_attack_timer -= delta
	if _attack_timer <= 0:
		can_attack = true

func _check_phase_transition() -> void:
	var hp_pct = float(health) / float(max_health)
	
	if hp_pct <= 0.3 and current_phase != 3:
		current_phase = 3
		_enter_phase3()
	elif hp_pct <= 0.6 and current_phase != 2:
		current_phase = 2
		_enter_phase2()

func _enter_phase2() -> void:
	_separate_parts()
	parts_separated = true
	play_anim("alert")

func _enter_phase3() -> void:
	_start_self_destruct()
	self_destruct_active = true
	speed_multiplier = 1.3
	damage_multiplier = 1.5
	play_anim("alert")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if self_destruct_active:
		self_destruct_time -= delta
		if self_destruct_time <= 0:
			_die()  # Override normal death
		return
	
	match current_phase:
		1: _phase1_behavior(delta)
		2: _phase2_behavior(delta)
		3: _phase3_behavior(delta)

func _phase1_behavior(delta: float) -> void:
	if not player:
		return
	if can_attack:
		if player_distance < 15.0:
			_fire_laser()
		else:
			_fire_missiles()
	
	# Move toward player if far
	if player_distance > 20.0:
		var nav = nav_to(player.global_position)
		if nav.length() > 0:
			velocity.x = nav.x
			velocity.z = nav.z

func _phase2_behavior(delta: float) -> void:
	if not player:
		return
	# Phase 2: flying parts attack + missiles
	if can_attack:
		_fire_missiles()
	# Circle around player
	if player:
		var circle_pos = player.global_position + Vector3(sin(Time.get_ticks_msec() * 0.001), 0, cos(Time.get_ticks_msec() * 0.001)) * 12.0
		var nav = nav_to(circle_pos)
		if nav.length() > 0:
			velocity.x = nav.x * speed_multiplier
			velocity.z = nav.z * speed_multiplier

func _phase3_behavior(delta: float) -> void:
	# Self-destruct is ticking — chase and attack
	if not player:
		return
	if can_attack:
		_fire_laser()
	# Aggressive chase
	if player:
		var nav = nav_to(player.global_position)
		if nav.length() > 0:
			velocity.x = nav.x * speed_multiplier
			velocity.z = nav.z * speed_multiplier

func _fire_laser() -> void:
	can_attack = false
	_attack_timer = attack_cooldown
	play_anim("attack")
	# Placeholder: laser beam attack toward player

func _fire_missiles() -> void:
	can_attack = false
	_attack_timer = 3.0
	play_anim("attack")
	# Placeholder: spawn 3 missile projectiles

func _separate_parts() -> void:
	# Placeholder: spawn smaller enemies from broken parts
	_spawn_reinforcements(3)

func _start_self_destruct() -> void:
	# Placeholder: visual/audio cue, 10s countdown
	pass

func _spawn_reinforcements(count: int) -> void:
	var spawn = get_tree().get_first_node_in_group("spawn_manager")
	if spawn:
		for i in range(count):
			spawn.spawn_next_enemy()
			await get_tree().create_timer(1.0).timeout

func take_damage(amount: int) -> void:
	# Weak point system
	var multiplier = 1.0
	# Placeholder: would check hit direction/area for weak point bonuses
	if parts_separated:
		multiplier = 1.5  # Exposed internals
	if self_destruct_active:
		multiplier = 2.0  # Core exposed
	super.take_damage(int(amount * multiplier))
