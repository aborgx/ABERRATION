class_name EnemyBase
extends CharacterBody3D

# --- Components ---
@onready var fsm: FSMComponent = $FSMComponent
@onready var utility_ai: UtilityAI = $UtilityAI
@onready var boids: BoidsComponent = $BoidsComponent
@onready var navigation: NavigationComponent = $NavigationComponent
@onready var avoidance: AvoidanceComponent = $AvoidanceComponent
@onready var anim_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null

# --- Stats ---
@export var max_health: int = 100
@export var move_speed: float = 300.0
@export var run_speed: float = 500.0
@export var attack_range: float = 2.5
@export var engage_range: float = 15.0
@export var lose_range: float = 30.0
@export var retreat_threshold: int = 30

var health: int = 0
var is_dead: bool = false
var can_see_player: bool = false
var player_distance: float = 0.0
var is_under_fire: bool = false
var has_cover: bool = false
var has_flank_position: bool = false
var allies_attacking_front: int = 0
var allies_nearby: int = 0
var ammo: int = 30

# --- Player reference ---
var player: Node3D

# --- Placeholder position for patrol/retreat ---
var patrol_waypoint: Vector3
var retreat_point: Vector3

func _ready() -> void:
	health = max_health
	is_dead = false
	
	# Find player
	player = get_tree().get_first_node_in_group("player")
	
	# Setup FSM states
	_setup_fsm()
	
	# Connect signals
	fsm.state_changed.connect(_on_state_changed)

func _setup_fsm() -> void:
	fsm.add_state("idle", _make_state("IdleState", "idle"))
	fsm.add_state("patrol", _make_state("PatrolState", "patrol"))
	fsm.add_state("alert", _make_state("AlertState", "alert"))
	fsm.add_state("engage", _make_state("EngageState", "engage"))
	fsm.add_state("attack", _make_state("AttackState", "attack"))
	fsm.add_state("retreat", _make_state("RetreatState", "retreat"))
	fsm.add_state("flee", _make_state("FleeState", "flee"))
	fsm.add_state("search", _make_state("SearchState", "search"))
	fsm.add_state("flank", _make_state("FlankState", "flank"))
	fsm.add_state("cover", _make_state("CoverState", "cover"))
	fsm.add_state("call_help", _make_state("CallHelpState", "call_help"))

func _make_state(script_name: String, state_name: String) -> Node:
	var script_path = "res://scripts/ai/states/" + script_name + ".gd"
	if ResourceLoader.exists(script_path):
		var state = ResourceLoader.load(script_path).new()
		state.name = state_name
		state.setup(self)
		add_child(state)
		return state
	# Fallback: empty state
	var empty = Node.new()
	empty.name = state_name
	add_child(empty)
	return empty

func _process(delta: float) -> void:
	if is_dead:
		return
	
	_update_perception()
	_update_utility_ai()
	_update_boids()
	
	if fsm:
		fsm._process(delta)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Let state set desired velocity first
	if fsm:
		fsm._physics_process(delta)
	
	# Then apply boids avoidance + speed cap + move_and_slide
	_apply_movement(delta)

func _update_perception() -> void:
	if not player:
		return
	
	player_distance = global_position.distance_to(player.global_position)
	can_see_player = _check_line_of_sight(player.global_position)

func _check_line_of_sight(target_pos: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var from = global_position + Vector3(0, 1.5, 0)
	var query = PhysicsRayQueryParameters3D.create(from, target_pos, 1 | 2)
	var result = space_state.intersect_ray(query)
	return not result

func _update_utility_ai() -> void:
	if not utility_ai:
		return
	
	var scores = utility_ai.calculate_scores({
		"health": health,
		"player_distance": player_distance,
		"ammo": ammo,
		"has_cover": has_cover,
		"is_under_fire": is_under_fire,
		"has_flank_position": has_flank_position,
		"allies_attacking_front": allies_attacking_front,
		"allies_nearby": allies_nearby
	}, {
		"has_cover": false
	})
	
	var best_action = utility_ai.get_best_action(scores)
	_apply_utility_decision(best_action)

func _apply_utility_decision(action: String) -> void:
	match action:
		"attack":
			if fsm.current_state != "attack" and player_distance < 5.0:
				fsm.transition("engage")
		"cover":
			fsm.transition("cover")
		"flank":
			fsm.transition("flank")
		"retreat":
			fsm.transition("retreat")
		"call_help":
			fsm.transition("call_help")
		_:
			pass

func _update_boids() -> void:
	if not boids:
		return
	
	var neighbors = _get_nearby_enemies(boids.cohesion_radius)
	var force = boids.calculate_boids_force({
		"global_position": global_position,
		"velocity": velocity
	}, neighbors)
	
	velocity.x += force.x * 0.5
	velocity.z += force.z * 0.5

func _get_nearby_enemies(radius: float) -> Array:
	var enemies = []
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsSphereQueryParameters3D.create(global_position, radius, 4)
	var results = space_state.intersect_sphere(query)
	
	for result in results:
		var collider = result.collider
		if collider and collider != self and collider.is_in_group("enemies"):
			enemies.append(collider)
	
	return enemies

func _apply_movement(delta: float) -> void:
	if is_dead:
		velocity = Vector3.ZERO
		return
	
	# Add avoidance force on top of state-set velocity
	var avoid_force = Vector3.ZERO
	if avoidance:
		var neighbors = _get_nearby_enemies(avoidance.avoidance_radius)
		avoid_force = avoidance.calculate_avoidance_force({"global_position": global_position}, neighbors)
	
	velocity.x += avoid_force.x
	velocity.z += avoid_force.z
	
	# Apply speed limit based on current state
	var speed_limit = move_speed
	if fsm:
		match fsm.current_state:
			"engage", "attack", "retreat", "flee":
				speed_limit = run_speed
	
	velocity = velocity.limit_length(speed_limit)
	move_and_slide()

func take_damage(amount: int) -> void:
	if is_dead:
		return
	
	health -= amount
	if health <= 0:
		health = 0
		_die()
	else:
		is_under_fire = true
		var director = get_tree().get_first_node_in_group("director")
		if director:
			director.on_player_damage(amount)

func _die() -> void:
	is_dead = true
	set_process(false)
	set_physics_process(false)
	visible = false
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(_return_to_pool)
	add_child(timer)
	timer.start()

func _return_to_pool() -> void:
	var pool = get_tree().get_first_node_in_group("pool_manager")
	if pool:
		pool.return_to_pool(self)
	else:
		queue_free()

func _on_state_changed(old_state: String, new_state: String) -> void:
	pass

# --- Utility methods for states ---

func play_anim(anim_name: String) -> void:
	if anim_player:
		anim_player.play(anim_name)

func move_toward(target_pos: Vector3, speed: float) -> void:
	var direction = (target_pos - global_position).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

func nav_to(target_pos: Vector3) -> Vector3:
	"""Returns navigation-guided velocity toward target_pos. Zero if no navigation."""
	if navigation:
		navigation.set_target(target_pos)
		return navigation.get_next_velocity(move_speed)
	return Vector3.ZERO

func get_retreat_point() -> Vector3:
	"""Find a point away from player."""
	if not player:
		return global_position + Vector3(10, 0, 0)
	var away_dir = (global_position - player.global_position).normalized()
	return global_position + away_dir * 20.0

func get_flank_point() -> Vector3:
	"""Find a flanking position relative to player."""
	if not player:
		return global_position + Vector3(5, 0, 5)
	var to_player = (player.global_position - global_position).normalized()
	var flank_dir = to_player.cross(Vector3.UP).normalized()
	var side = 1 if randi() % 2 == 0 else -1
	return player.global_position + flank_dir * side * 5.0 + to_player * 3.0