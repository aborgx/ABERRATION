class_name EnemyBase
extends CharacterBody3D

# --- Components ---
@onready var fsm: FSMComponent = $FSMComponent
@onready var utility_ai: UtilityAI = $UtilityAI
@onready var boids: BoidsComponent = $BoidsComponent
@onready var navigation: NavigationComponent = $NavigationComponent
@onready var avoidance: AvoidanceComponent = $AvoidanceComponent

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
	fsm.add_state("idle", create_state("idle"))
	fsm.add_state("patrol", create_state("patrol"))
	fsm.add_state("alert", create_state("alert"))
	fsm.add_state("engage", create_state("engage"))
	fsm.add_state("attack", create_state("attack"))
	fsm.add_state("retreat", create_state("retreat"))
	fsm.add_state("flee", create_state("flee"))
	fsm.add_state("search", create_state("search"))
	fsm.add_state("flank", create_state("flank"))
	fsm.add_state("cover", create_state("cover"))
	fsm.add_state("call_help", create_state("call_help"))

func create_state(name: String) -> Node:
	var state = Node.new()
	state.name = name
	return state

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
	
	_apply_movement(delta)
	
	if fsm:
		fsm._physics_process(delta)

func _update_perception() -> void:
	if not player:
		return
	
	player_distance = global_position.distance_to(player.global_position)
	can_see_player = _check_line_of_sight(player.global_position)

func _check_line_of_sight(target_pos: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var from = global_position + Vector3(0, 1.5, 0)
	var direction = (target_pos - from).normalized()
	var distance = from.distance_to(target_pos)
	
	var query = PhysicsRayQueryParameters3D.create(from, target_pos, 1 | 2)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
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
	
	var target_speed = move_speed
	match fsm.current_state:
		"engage", "attack":
			target_speed = run_speed
		"retreat", "flee":
			target_speed = run_speed
		"patrol":
			target_speed = move_speed
		_:
			target_speed = move_speed
	
	var nav_vel = Vector3.ZERO
	if navigation and fsm.current_state in ["patrol", "engage", "retreat", "flee", "flank"]:
		nav_vel = navigation.get_next_velocity(target_speed)
	
	var avoid_force = Vector3.ZERO
	if avoidance:
		var neighbors = _get_nearby_enemies(avoidance.avoidance_radius)
		avoid_force = avoidance.calculate_avoidance_force({"global_position": global_position}, neighbors)
	
	var final_vel = nav_vel + avoid_force
	final_vel = final_vel.limit_length(target_speed)
	
	velocity.x = final_vel.x
	velocity.z = final_vel.z
	
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