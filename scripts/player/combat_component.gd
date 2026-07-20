class_name CombatComponent
extends Node

signal hit_landed(target: Node, damage: int, hit_type: String)
signal frenesia_gained(amount: int)
signal combo_updated(count: int)
signal melee_attack_started(combo_count: int)

# --- Melee ---
@export var melee_damage: int = 30
@export var melee_range: float = 2.5
@export var max_combo: int = 3
@export var combo_window: float = 0.5
@export var melee_cooldown: float = 0.3

var current_combo: int = 0
var can_combo: bool = false
var combo_timer: float = 0.0
var melee_cooldown_timer: float = 0.0

# --- Nail Launch ---
@export var nail_damage: int = 20
@export var nail_range: float = 20.0
@export var nail_penetration: int = 3
@export var max_charge_time: float = 1.0
@export var nail_cooldown: float = 0.3

var nail_charge_time: float = 0.0
var is_charging_nail: bool = false
var nail_cooldown_timer: float = 0.0
var last_charge_level: int = 1

# --- Scream ---
@export var scream_damage: int = 10
@export var scream_range: float = 8.0
@export var scream_stun_duration: float = 1.5
@export var scream_cooldown: float = 8.0

var scream_cooldown_timer: float = 0.0

# --- Grab ---
@export var grab_range: float = 3.0
@export var grab_damage: int = 40
@export var grab_cooldown: float = 1.0

var grab_cooldown_timer: float = 0.0

# --- Dash Attack ---
@export var dash_attack_damage: int = 35
@export var dash_attack_speed: float = 1500.0
@export var dash_attack_duration: float = 0.3
@export var dash_attack_cooldown: float = 2.0

var dash_attack_cooldown_timer: float = 0.0
var is_dash_attacking: bool = false
var dash_attack_timer: float = 0.0
var dash_attack_direction: Vector2 = Vector2.ZERO
var is_invincible: bool = false

# --- Ground Slam ---
@export var ground_slam_damage: int = 50
@export var ground_slam_radius: float = 4.0
@export var ground_slam_cooldown: float = 5.0
@export var ground_slam_stun_duration: float = 1.0

var ground_slam_cooldown_timer: float = 0.0
var is_on_floor: bool = true

# --- References ---
var body: CharacterBody3D = null
var movement = null
var frenesia = null

# --- Damage/Speed Multipliers (from Frenesia) ---
var damage_multiplier: float = 1.0
var speed_multiplier: float = 1.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# Melee combo window
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			_reset_combo()
	
	# Melee cooldown
	if melee_cooldown_timer > 0:
		melee_cooldown_timer -= delta
	
	# Nail charge
	if is_charging_nail:
		nail_charge_time += delta
	
	if nail_cooldown_timer > 0:
		nail_cooldown_timer -= delta
	
	# Scream cooldown
	if scream_cooldown_timer > 0:
		scream_cooldown_timer -= delta
	
	# Grab cooldown
	if grab_cooldown_timer > 0:
		grab_cooldown_timer -= delta
	
	# Dash attack
	if dash_attack_cooldown_timer > 0:
		dash_attack_cooldown_timer -= delta
	
	if is_dash_attacking:
		dash_attack_timer -= delta
		if dash_attack_timer <= 0:
			_end_dash_attack()
	
	# Ground slam cooldown
	if ground_slam_cooldown_timer > 0:
		ground_slam_cooldown_timer -= delta

# --- Melee ---
func melee_attack(input_dir: Vector2) -> void:
	if melee_cooldown_timer > 0:
		return
	
	if current_combo >= max_combo:
		_reset_combo()
		return
	
	current_combo += 1
	combo_timer = combo_window
	can_combo = current_combo < max_combo
	melee_cooldown_timer = melee_cooldown
	combo_updated.emit(current_combo)
	melee_attack_started.emit(current_combo)
	
	# Calculate damage with frenesia multiplier
	var damage = melee_damage
	if frenesia:
		damage = int(damage * frenesia.get_damage_multiplier())
	damage = int(damage * damage_multiplier)
	
	# Perform hit detection (raycast)
	var hit_target = _perform_melee_hit(input_dir, melee_range)
	if hit_target:
		hit_target.take_damage(damage)
		hit_landed.emit(hit_target, damage, "melee")
		frenesia_gained.emit(5 * current_combo)  # combo bonus
	
	# Play animation
	_play_melee_animation(current_combo)

func _reset_combo() -> void:
	current_combo = 0
	can_combo = false
	combo_timer = 0.0
	combo_updated.emit(0)

func _perform_melee_hit(input_dir: Vector2, range: float) -> Node:
	# Sphere cast for melee hit
	if not body:
		return null
	
	var space_state = body.get_world_3d().direct_space_state
	var from = body.global_position + Vector3(0, 1, 0)
	var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, body.rotation.y)
	var to = from + direction * range
	
	var query = PhysicsRayQueryParameters3D.create(from, to, 4)  # layer 3 = enemies
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	if result:
		var collider = result.collider
		if collider and collider.has_method("take_damage"):
			return collider
	return null

func _play_melee_animation(combo_count: int) -> void:
	if body and body.has_node("AnimationPlayer"):
		body.get_node("AnimationPlayer").play("melee_" + str(combo_count))

# --- Nail Launch ---
func start_nail_charge() -> void:
	if nail_cooldown_timer > 0:
		return
	if not is_charging_nail:
		is_charging_nail = true
		nail_charge_time = 0.0

func release_nail_launch(input_dir: Vector2) -> void:
	if not is_charging_nail:
		return
	
	is_charging_nail = false
	nail_cooldown_timer = nail_cooldown
	
	var charge_level = 1
	if nail_charge_time >= max_charge_time * 0.66:
		charge_level = 3
	elif nail_charge_time >= max_charge_time * 0.33:
		charge_level = 2
	
	last_charge_level = charge_level
	_fire_nails(input_dir, charge_level)

func _fire_nails(input_dir: Vector2, charge_level: int) -> void:
	var base_damage = nail_damage
	if frenesia:
		base_damage = int(base_damage * frenesia.get_damage_multiplier())
	base_damage = int(base_damage * damage_multiplier)
	
	var nail_count = 1
	var is_explosive = false
	var is_paralyzing = false
	
	match charge_level:
		1:
			nail_count = 1
		2:
			nail_count = 3
		3:
			nail_count = 1
			is_explosive = true
	
	for i in range(nail_count):
		var spread_angle = 0.0
		if nail_count > 1:
			spread_angle = (i - (nail_count - 1) / 2.0) * 0.2  # ~11 degrees spread
		
		var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, body.rotation.y + spread_angle)
		_spawn_nail(direction, base_damage, is_explosive, is_paralyzing)

func _spawn_nail(direction: Vector3, damage: int, explosive: bool, paralyzing: bool) -> void:
	# Raycast for nail penetration
	if not body:
		return
	
	var space_state = body.get_world_3d().direct_space_state
	var from = body.global_position + Vector3(0, 1.5, 0)
	var to = from + direction * nail_range
	
	var query = PhysicsRayQueryParameters3D.create(from, to, 4)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	var hit_count = 0
	
	while result and hit_count < nail_penetration:
		var collider = result.collider
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage)
			hit_landed.emit(collider, damage, "nail")
			frenesia_gained.emit(3)
			hit_count += 1
		
		# Continue ray for penetration
		from = result.position + direction * 0.1
		to = from + direction * (nail_range - (result.position - body.global_position).length())
		query = PhysicsRayQueryParameters3D.create(from, to, 4)
		query.collide_with_areas = true
		query.collide_with_bodies = true
		result = space_state.intersect_ray(query)

# --- Scream ---
func scream() -> void:
	if scream_cooldown_timer > 0:
		return
	
	scream_cooldown_timer = scream_cooldown
	
	var damage = scream_damage
	if frenesia:
		damage = int(damage * frenesia.get_damage_multiplier())
	damage = int(damage * damage_multiplier)
	
	# Area effect — find all enemies in range
	if not body:
		return
	
	var space_state = body.get_world_3d().direct_space_state
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = scream_range
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = sphere_shape
	query.transform = Transform3D.IDENTITY.translated(body.global_position)
	query.collision_mask = 4
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var collider = result.collider
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage)
			hit_landed.emit(collider, damage, "scream")
			frenesia_gained.emit(2)
			
			# Stun effect
			if collider.has_method("stun"):
				collider.stun(scream_stun_duration)
			
			# Break shield formation
			if collider.has_method("break_formation"):
				collider.break_formation()

# --- Grab ---
func grab() -> void:
	if grab_cooldown_timer > 0:
		return
	
	var target = _find_grab_target()
	if not target:
		return
	
	grab_cooldown_timer = grab_cooldown
	
	var damage = grab_damage
	if frenesia:
		damage = int(damage * frenesia.get_damage_multiplier())
	damage = int(damage * damage_multiplier)
	
	target.take_damage(damage)
	hit_landed.emit(target, damage, "grab")
	frenesia_gained.emit(15)
	
	# Grab options: execute if low HP, else smash
	if target.health <= target.max_health * 0.3:
		_execute_target(target)
	else:
		_smash_target(target)

func _find_grab_target() -> Node:
	if not body:
		return null
	
	var space_state = body.get_world_3d().direct_space_state
	var from = body.global_position + Vector3(0, 1, 0)
	var direction = -body.global_transform.basis.z
	var to = from + direction * grab_range
	
	var query = PhysicsRayQueryParameters3D.create(from, to, 4)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	if result:
		var collider = result.collider
		if collider and collider.has_method("take_damage"):
			return collider
	return null

func _execute_target(target: Node) -> void:
	# Finisher animation, massive frenesia
	frenesia_gained.emit(20)
	# TODO: finisher animation

func _smash_target(target: Node) -> void:
	# Smash into ground/wall
	pass

func can_grab(target: Node) -> bool:
	if grab_cooldown_timer > 0:
		return false
	if not body:
		return false
	var distance = body.global_position.distance_to(target.global_position)
	return distance <= grab_range

# --- Dash Attack ---
func dash_attack(input_dir: Vector2) -> void:
	if dash_attack_cooldown_timer > 0 or is_dash_attacking:
		return
	
	if movement and not movement.try_dash(input_dir):
		return
	
	dash_attack_cooldown_timer = dash_attack_cooldown
	is_dash_attacking = true
	is_invincible = true
	dash_attack_timer = dash_attack_duration
	dash_attack_direction = input_dir
	
	# Damage enemies along dash path
	_dash_attack_hit(input_dir)

func _dash_attack_hit(input_dir: Vector2) -> void:
	if not body:
		return
	
	var damage = dash_attack_damage
	if frenesia:
		damage = int(damage * frenesia.get_damage_multiplier())
	damage = int(damage * damage_multiplier)
	
	var space_state = body.get_world_3d().direct_space_state
	var from = body.global_position
	var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, body.rotation.y)
	var to = from + direction * 5.0  # dash distance
	
	var query = PhysicsRayQueryParameters3D.create(from, to, 4)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	if result:
		var collider = result.collider
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage)
			hit_landed.emit(collider, damage, "dash_attack")
			frenesia_gained.emit(5)

func _end_dash_attack() -> void:
	is_dash_attacking = false
	is_invincible = false

func can_dash_attack() -> bool:
	return dash_attack_cooldown_timer <= 0 and not is_dash_attacking

# --- Ground Slam ---
func ground_slam() -> void:
	if ground_slam_cooldown_timer > 0 or is_on_floor:
		return
	
	ground_slam_cooldown_timer = ground_slam_cooldown
	
	var damage = ground_slam_damage
	if frenesia:
		damage = int(damage * frenesia.get_damage_multiplier())
	damage = int(damage * damage_multiplier)
	
	# Area effect
	if not body:
		return
	
	var space_state = body.get_world_3d().direct_space_state
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = ground_slam_radius
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = sphere_shape
	query.transform = Transform3D.IDENTITY.translated(body.global_position)
	query.collision_mask = 4
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var collider = result.collider
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage)
			hit_landed.emit(collider, damage, "ground_slam")
			frenesia_gained.emit(5)
			
			if collider.has_method("stun"):
				collider.stun(ground_slam_stun_duration)

func can_ground_slam() -> bool:
	return ground_slam_cooldown_timer <= 0 and not is_on_floor