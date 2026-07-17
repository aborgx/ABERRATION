class_name BossJuggernaut
extends EnemyBase

enum Phase { PHASE1, PHASE2, PHASE3 }
var current_phase: Phase = Phase.PHASE1
var shield_active: bool = false
var armor_broken: bool = false
var speed_multiplier: float = 1.0
var damage_multiplier: float = 1.0
var can_attack: bool = true
var attack_cooldown: float = 1.0
var _attack_timer: float = 0.0

func _ready() -> void:
	max_health = 2000
	move_speed = 150.0
	run_speed = 250.0
	attack_range = 3.0
	engage_range = 20.0
	lose_range = 40.0
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	_update_phase()
	_attack_timer -= delta
	if _attack_timer <= 0:
		can_attack = true

func _update_phase() -> void:
	var hp_pct = float(health) / float(max_health)
	
	if hp_pct <= 0.4 and current_phase != Phase.PHASE3:
		current_phase = Phase.PHASE3
		_enter_phase3()
	elif hp_pct <= 0.7 and current_phase != Phase.PHASE2:
		current_phase = Phase.PHASE2
		_enter_phase2()

func _enter_phase2() -> void:
	_spawn_reinforcements(5)
	shield_active = true
	play_anim("alert")
	# Show shield visual
	var shield = get_node_or_null("Shield")
	if shield:
		shield.visible = true

func _enter_phase3() -> void:
	armor_broken = true
	speed_multiplier = 1.5
	damage_multiplier = 1.5
	shield_active = false
	# Hide shield
	var shield = get_node_or_null("Shield")
	if shield:
		shield.visible = false
	play_anim("attack")

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
	if not player:
		return
	if player_distance < 15.0:
		if can_attack:
			_shoot()
	else:
		var nav = nav_to(player.global_position)
		if nav.length() > 0:
			velocity.x = nav.x
			velocity.z = nav.z

func _phase2_behavior(delta: float) -> void:
	if not player:
		return
	if shield_active and player_distance < 4.0:
		if can_attack:
			_shield_bash()
	elif not shield_active:
		var nav = nav_to(player.global_position)
		if nav.length() > 0:
			velocity.x = nav.x
			velocity.z = nav.z

func _phase3_behavior(delta: float) -> void:
	if not player:
		return
	if can_attack and player_distance < attack_range:
		_melee_attack()
	else:
		var nav = nav_to(player.global_position)
		if nav.length() > 0:
			velocity.x = nav.x * speed_multiplier
			velocity.z = nav.z * speed_multiplier

func _shoot() -> void:
	can_attack = false
	_attack_timer = attack_cooldown
	play_anim("attack")
	# Placeholder: spawn projectile toward player

func _shield_bash() -> void:
	can_attack = false
	_attack_timer = 2.0
	play_anim("attack")
	# Placeholder: area damage around boss

func _melee_attack() -> void:
	can_attack = false
	_attack_timer = 0.5
	play_anim("attack")
	# Placeholder: melee damage to player if in range

func _spawn_reinforcements(count: int) -> void:
	var spawn = get_tree().get_first_node_in_group("spawn_manager")
	if spawn:
		for i in range(count):
			spawn.spawn_next_enemy()
			await get_tree().create_timer(0.5).timeout

func take_damage(amount: int) -> void:
	if shield_active:
		# Shield blocks frontal damage: check direction
		if player:
			var to_player = (player.global_position - global_position).normalized()
			var facing = -global_transform.basis.z.normalized()
			var dot = to_player.dot(facing)
			if dot > 0.3:  # Frontal cone
				amount = int(amount * 0.2)  # 80% damage reduction
	super.take_damage(amount)
