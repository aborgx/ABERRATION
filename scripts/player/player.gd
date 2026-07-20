class_name Player
extends CharacterBody3D

## Simple player controller for visual test - no animation dependencies

signal health_changed(old_value: int, new_value: int)
signal frenesia_changed(old_value: int, new_value: int)
signal state_changed(new_state: String)

# --- Constants ---
const GRAVITY: float = -19.6
const JUMP_FORCE: float = 400.0
const COYOTE_TIME: float = 0.1
const JUMP_BUFFER: float = 0.1
const MOVE_SPEED: float = 6.0
const SPRINT_SPEED: float = 12.0
const ACCELERATION: float = 20.0
const DECELERATION: float = 25.0

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
var is_dead: bool = false

# --- Components (simple references) ---
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var collision_shape = $CollisionShape3D
@onready var model = $Model
@onready var movement = $MovementComponent
@onready var combat = $CombatComponent

var _anim_tree: AnimationTree = null

func _ready() -> void:
	# Hide mouse cursor and capture it
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	_load_rigged_model()

func _load_rigged_model() -> void:
	# Load the rigged+animated GLB at runtime via GLTFDocument (preload on .glb fails)
	var glb_path := "res://scenes/player/chr_player_rigged_anim.glb"
	var doc := GLTFDocument.new()
	var gltf_state := GLTFState.new()
	var err: Error = doc.append_from_file(glb_path, gltf_state)
	if err != OK:
		push_error("Player: failed to load GLB '%s' (err %d)" % [glb_path, err])
		return
	var glb_scene: Node = doc.generate_scene(gltf_state)
	if glb_scene == null:
		push_error("Player: GLB loaded but get_scene() returned null")
		return
	model.add_child(glb_scene)
	_apply_fallback_materials(glb_scene)

	# Find AnimationPlayer inside the GLB instance
	var anim_player: AnimationPlayer = null
	for n in glb_scene.get_children():
		if n is AnimationPlayer:
			anim_player = n
		elif n is Node3D:
			for c in n.get_children():
				if c is AnimationPlayer:
					anim_player = c
	if anim_player == null:
		push_warning("Player: no AnimationPlayer found in GLB")
		return

	# Build AnimationTree wired to the GLB's AnimationPlayer
	var tree = load("res://scripts/player/animation_tree_setup.gd").new()
	tree.name = "AnimationTree"
	tree.player = self
	tree.animation_player_node = anim_player
	model.add_child(tree)
	_anim_tree = tree
	# tree._ready() runs on add_child -> create_animation_tree() uses animation_player_node
	# Deferred re-start to ensure Idle plays (tree active before playback.start in setup)
	if _anim_tree != null:
		_anim_tree.call_deferred("set_active", true)
		var pb = _anim_tree.get("parameters/playback")
		if pb != null:
			pb.call_deferred("start", &"Idle")
	# Connect combat attack signal to AnimationTree trigger
	if combat != null:
		combat.melee_attack_started.connect(_on_melee_attack_started)

func _apply_fallback_materials(root: Node) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			var mesh: Mesh = child.mesh
			if mesh != null:
				var needs_mat := false
				for i in mesh.get_surface_count():
					if mesh.surface_get_material(i) == null:
						needs_mat = true
						break
				if needs_mat:
					var mat := StandardMaterial3D.new()
					mat.albedo_color = Color(0.6, 0.65, 0.7)
					for i in mesh.get_surface_count():
						if mesh.surface_get_material(i) == null:
							mesh.surface_set_material(i, mat)
		_apply_fallback_materials(child)

func _on_melee_attack_started(_combo_count: int) -> void:
	if _anim_tree != null:
		_anim_tree.trigger_attack()

func _update_animation_state() -> void:
	if _anim_tree == null:
		return
	var moving = movement.current_state != "prowl" or movement.move_direction.length() > 0.0
	_anim_tree.set_state_condition("is_moving", moving and is_on_ground)
	_anim_tree.set_state_condition("is_sprinting", movement.current_state == "sprint")
	_anim_tree.set_state_condition("in_air", not is_on_ground)
	_anim_tree.set_state_condition("is_dead", is_dead)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
	
	# Input
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Sprint
	var target_speed = MOVE_SPEED
	if Input.is_action_pressed("sprint"):
		target_speed = SPRINT_SPEED
	
	# Acceleration/Deceleration
	if direction != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, direction.x * target_speed, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, direction.z * target_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * delta)
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE
	
	# Camera rotation (mouse)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var mouse_delta = Input.get_last_mouse_velocity()
		rotate_y(-mouse_delta.x * 0.002)
		camera_pivot.rotate_x(-mouse_delta.y * 0.002)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -1.3, 1.3)
	
	move_and_slide()
	
	# Update grounded state
	is_on_ground = is_on_floor()
	_update_animation_state()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health + amount, health)
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	state_changed.emit("dead")

func add_frenesia(amount: int) -> void:
	frenesia = clamp(frenesia + amount, 0, max_frenesia)
	frenesia_changed.emit(frenesia - amount, frenesia)