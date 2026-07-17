class_name Player
extends CharacterBody3D

## Main player controller for Aberration.
## Integrates MovementComponent, CombatComponent, FrenesiaComponent, handles physics and gravity.

signal health_changed(old_value: int, new_value: int)
signal frenesia_changed(old_value: int, new_value: int)
signal state_changed(new_state: String)

# --- Constants ---
const GRAVITY: float = -19.6  # Heavier than real for arcade feel
const JUMP_FORCE: float = 400.0
const COYOTE_TIME: float = 0.1
const JUMP_BUFFER: float = 0.1

# --- Exported ---
@export var max_health: int = 100
@export var max_frenesia: int = 100

# --- State ---
var health: int = 100
var frenesia: int = 0
var can_jump: bool = true
var is_on_ground: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# --- Components ---
@onready var movement = $MovementComponent
@onready var combat = $CombatComponent
@onready var frenesia_comp = $FrenesiaComponent

func _ready() -> void:
	# Connect movement signals
	movement.state_changed.connect(_on_movement_state_changed)
	movement.dash_started.connect(_on_dash_started)
	movement.dash_finished.connect(_on_dash_finished)
	
	# Connect combat signals
	combat.hit_landed.connect(_on_hit_landed)
	combat.frenesia_gained.connect(_on_frenesia_gained)
	combat.combo_updated.connect(_on_combo_updated)
	
	# Connect frenesia signals
	frenesia_comp.frenesia_changed.connect(_on_frenesia_changed)
	frenesia_comp.frenesia_level_changed.connect(_on_frenesia_level_changed)
	
	# Set references
	movement.body = self
	combat.body = self
	combat.movement = movement
	combat.frenesia = frenesia_comp
	frenesia_comp.body = self
	
	# Set initial state
	state_changed.emit("idle")

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Ground detection
	var was_on_ground = is_on_ground
	is_on_ground = is_on_floor()
	
	# Coyote time
	if was_on_ground and not is_on_ground:
		coyote_timer = COYOTE_TIME
	elif coyote_timer > 0:
		coyote_timer -= delta
	
	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER
	
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	# Jump logic
	if jump_buffer_timer > 0 and coyote_timer > 0 and can_jump:
		velocity.y = JUMP_FORCE
		jump_buffer_timer = 0
		coyote_timer = 0
	
	# Movement input
	var input_dir = movement.get_input_direction()
	
	# Dash check
	if Input.is_action_just_pressed("dash"):
		movement.try_dash()
	
	# Combat input
	# Melee
	if Input.is_action_just_pressed("attack_melee"):
		input_dir = movement.get_input_direction()
		combat.melee_attack(input_dir)
	
	# Nail Launch (charge)
	if Input.is_action_pressed("attack_ranged"):
		combat.start_nail_charge()
	elif Input.is_action_just_released("attack_ranged"):
		input_dir = movement.get_input_direction()
		combat.release_nail_launch(input_dir)
	
	# Scream
	if Input.is_action_just_pressed("scream"):
		combat.scream()
	
	# Grab
	if Input.is_action_just_pressed("grab"):
		combat.grab()
	
	# Dash Attack
	if Input.is_action_just_pressed("dash_attack"):
		input_dir = movement.get_input_direction()
		combat.dash_attack(input_dir)
	
	# Ground Slam
	if Input.is_action_just_pressed("ground_slam"):
		combat.ground_slam()
	
	# Apply frenesia speed multiplier to movement
	if frenesia_comp:
		movement.speed_multiplier = frenesia_comp.get_speed_multiplier()
	
	# Apply frenesia damage multiplier to combat
	if combat and frenesia_comp:
		combat.damage_multiplier = frenesia_comp.get_damage_multiplier()
	
	# Update combat timers
	combat._process(delta)
	frenesia_comp._process(delta)
	
	# Dash check
	if Input.is_action_just_pressed("dash"):
		movement.try_dash()
	
	# Apply movement (only horizontal, preserve Y for gravity/jump)
	var horizontal_velocity = movement.calculate_velocity(input_dir)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	# Move
	move_and_slide()

func take_damage(amount: int) -> void:
	var old_health = health
	health = clamp(health - amount, 0, max_health)
	health_changed.emit(old_health, health)
	
	# Frenesia penalty on damage
	frenesia_comp.on_damage_taken()
	
	if health <= 0:
		_die()

func add_frenesia(amount: int) -> void:
	var old_frenesia = frenesia
	frenesia = clamp(frenesia + amount, 0, max_frenesia)
	frenesia_changed.emit(old_frenesia, frenesia)

func _die() -> void:
	# Placeholder — will be expanded in later waves
	pass

func get_player_velocity() -> Vector3:
	return velocity

func _on_movement_state_changed(old_state: String, new_state: String) -> void:
	state_changed.emit(new_state)

func _on_dash_started() -> void:
	# Placeholder for dash VFX/sound
	pass

func _on_dash_finished() -> void:
	# Placeholder for dash VFX/sound
	pass

# --- Combat Signal Handlers ---

func _on_hit_landed(target: Node, damage: int, hit_type: String) -> void:
	# Camera shake based on hit type
	var shake_intensity = 0.2
	var shake_duration = 0.1
	match hit_type:
		"melee":
			shake_intensity = 0.3
			shake_duration = 0.15
		"nail":
			shake_intensity = 0.15
			shake_duration = 0.1
		"scream":
			shake_intensity = 0.4
			shake_duration = 0.2
		"grab":
			shake_intensity = 0.5
			shake_duration = 0.25
		"dash_attack":
			shake_intensity = 0.35
			shake_duration = 0.2
		"ground_slam":
			shake_intensity = 0.6
			shake_duration = 0.3
	
	if has_node("CameraPivot/Camera3D"):
		get_node("CameraPivot/Camera3D").shake(shake_intensity, shake_duration)
	
	# Hit flash
	_hit_flash()

func _on_frenesia_gained(amount: int) -> void:
	# Visual feedback
	pass

func _on_combo_updated(count: int) -> void:
	# UI feedback
	pass

func _on_frenesia_changed(old: int, new: int) -> void:
	# Update HUD artery
	if has_node("../HUD/Artery"):
		get_node("../HUD/Artery").frenesia = new

func _on_frenesia_level_changed(level: int) -> void:
	# Visual/audio changes per level
	match level:
		1: _set_frenesia_visuals(1.0)  # AGITATED
		2: _set_frenesia_visuals(1.5)  # FURIOUS
		3: _set_frenesia_visuals(2.0)  # FRENETIC
		4: _set_frenesia_visuals(3.0)  # OVERFRENESIA
		_: _set_frenesia_visuals(1.0)

func _set_frenesia_visuals(intensity: float) -> void:
	# Bloom, vignette, chromatic aberration, eye glow
	pass

func _hit_flash() -> void:
	# Screen flash red
	pass