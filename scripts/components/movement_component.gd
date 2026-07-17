class_name MovementComponent
extends Node

## Movement component for Aberration player.
## Handles: prowl, sprint, crouch, dash states.

signal state_changed(old_state: String, new_state: String)
signal dash_started
signal dash_finished

# --- Speed Constants ---
const PROWL_SPEED: float = 300.0
const SPRINT_SPEED: float = 540.0
const CROUCH_SPEED: float = 180.0
const DASH_SPEED: float = 900.0
const DASH_DURATION: float = 0.2
const DASH_COOLDOWN: float = 0.3

# --- Exported ---
@export var acceleration: float = 20.0
@export var deceleration: float = 25.0

# --- State ---
var current_state: String = "prowl"
var can_dash: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var move_direction: Vector2 = Vector2.ZERO
var _dash_direction: Vector2 = Vector2(0.0, -1.0)
var _pre_dash_state: String = "prowl"

# --- References (set by player.gd) ---
var body: CharacterBody3D = null
var speed_multiplier: float = 1.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			_end_dash()
	
	if not can_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0.0:
			can_dash = true

func get_input_direction() -> Vector2:
	var input = Vector2.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")
	return input.normalized() if input.length() > 1.0 else input

func calculate_velocity(input_dir: Vector2) -> Vector3:
	if body == null:
		return Vector3.ZERO
	
	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()
	
	if input_dir.length() > 0.0:
		move_direction = input_dir
		if not is_dashing:
			_dash_direction = input_dir
	
	update_state(input_dir)
	
	var target_speed: float
	match current_state:
		"sprint":
			target_speed = SPRINT_SPEED
		"crouch":
			target_speed = CROUCH_SPEED
		"dash":
			target_speed = DASH_SPEED
		_:
			target_speed = PROWL_SPEED
	
	var source_direction = _dash_direction if is_dashing else input_dir
	var direction = Vector3(source_direction.x, 0.0, source_direction.y)
	if direction.length() > 1.0:
		direction = direction.normalized()
	direction = direction.rotated(Vector3.UP, body.rotation.y)
	
	var target_velocity = direction * target_speed * speed_multiplier
	var current_horizontal = Vector3(body.velocity.x, 0.0, body.velocity.z)
	
	var has_horizontal_input = source_direction.length() > 0.0
	var accel = acceleration if has_horizontal_input else deceleration
	var interpolation_weight = min(accel * get_process_delta_time(), 1.0)
	var horizontal_velocity = current_horizontal.lerp(target_velocity, interpolation_weight)
	
	return Vector3(horizontal_velocity.x, body.velocity.y, horizontal_velocity.z)

func try_dash(input_dir: Vector2 = Vector2.ZERO) -> bool:
	if can_dash and not is_dashing and current_state != "dash":
		if input_dir.length() > 1.0:
			input_dir = input_dir.normalized()
		if input_dir.length() > 0.0:
			move_direction = input_dir
			_dash_direction = input_dir
		elif move_direction.length() > 0.0:
			_dash_direction = move_direction.normalized()
		_start_dash()
		return true
	return false

func _start_dash() -> void:
	var old_state = current_state
	_pre_dash_state = old_state if old_state != "dash" else "prowl"
	is_dashing = true
	can_dash = false
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN + DASH_DURATION
	current_state = "dash"
	state_changed.emit(old_state, "dash")
	dash_started.emit()

func _end_dash() -> void:
	var old_state = current_state
	is_dashing = false
	current_state = _pre_dash_state
	state_changed.emit(old_state, current_state)
	dash_finished.emit()

func update_state(input_dir: Vector2) -> void:
	if is_dashing:
		return
	
	var old_state = current_state
	
	if Input.is_action_pressed("sprint") and input_dir.length() > 0:
		current_state = "sprint"
	elif Input.is_action_pressed("crouch"):
		current_state = "crouch"
	else:
		current_state = "prowl"
	
	if old_state != current_state:
		state_changed.emit(old_state, current_state)

func get_velocity() -> Vector3:
	if body:
		return body.velocity
	return Vector3.ZERO
