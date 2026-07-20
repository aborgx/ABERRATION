class_name CameraController
extends Node3D

## Third-person camera with dead zone, look ahead, wall avoidance, and zoom.

@export var target: Node3D = null
@export var distance: float = 6.0
@export var height: float = 2.5
@export var look_down_angle: float = 15.0
@export var follow_speed: float = 10.0
@export var look_ahead_distance: float = 2.0
@export var wall_avoidance_enabled: bool = true
@export var min_distance: float = 2.0
@export var max_distance: float = 12.0
@export var zoom_speed: float = 0.5

# --- Internal ---
var camera: Camera3D
var real_offset: Vector3 = Vector3.ZERO
var target_offset: Vector3 = Vector3.ZERO

# --- Camera Shake ---
var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var shake_offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	# Auto-find player if no target set
	if target == null:
		target = get_tree().get_first_node_in_group("player")
	
	# Create camera if not in scene tree
	if not has_node("Camera3D"):
		camera = Camera3D.new()
		camera.name = "Camera3D"
		add_child(camera)
	else:
		camera = $Camera3D
	
	# Configure camera
	camera.fov = 60.0
	
	# Set rotation for look-down angle
	rotation.x = -deg_to_rad(look_down_angle)

func _physics_process(delta: float) -> void:
	if target == null:
		return
	
	# Reset camera local offset every frame (shake overrides below)
	camera.position = Vector3.ZERO
	
	# Calculate desired position
	var target_pos = target.global_position
	var forward = -target.global_transform.basis.z
	var right = target.global_transform.basis.x
	
	# Zoom (mouse wheel)
	var zoom_delta := 0.0
	if Input.is_action_just_pressed("zoom_in"):
		zoom_delta -= zoom_speed
	if Input.is_action_just_pressed("zoom_out"):
		zoom_delta += zoom_speed
	if zoom_delta != 0.0:
		distance = clampf(distance + zoom_delta, min_distance, max_distance)

	# Base offset (behind and above target)
	target_offset = Vector3(0, height, distance)
	
	# Look ahead based on velocity
	if target.has_method("get_velocity"):
		var velocity = target.get_velocity()
		if velocity.length() > 1.0:
			var look_ahead = velocity.normalized() * look_ahead_distance
			target_offset += look_ahead
	
	# Wall avoidance via raycast
	if wall_avoidance_enabled:
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			target_pos,
			target_pos + target_offset.normalized() * distance,
			1  # Collision mask layer 1 (Environment)
		)
		var result = space_state.intersect_ray(query)
		
		if result:
			# Hit wall — move camera closer
			var hit_distance = target_pos.distance_to(result.position)
			target_offset = target_offset.normalized() * max(hit_distance - 0.5, 1.0)
	
	# Smooth follow
	real_offset = real_offset.lerp(target_offset, follow_speed * delta)
	
	# Apply position
	global_position = target_pos + real_offset
	
	# Look at target
	look_at(target_pos, Vector3.UP)
	
	# Camera shake
	if shake_timer > 0:
		shake_timer -= delta
		
		# Perlin noise for natural shake
		var t = shake_timer / shake_duration
		var current_intensity = shake_intensity * t
		
		shake_offset.x = randf_range(-1, 1) * current_intensity
		shake_offset.y = randf_range(-1, 1) * current_intensity
		shake_offset.z = 0
		
		camera.position = shake_offset

func shake(intensity: float = 0.3, duration: float = 0.2) -> void:
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration