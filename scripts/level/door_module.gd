class_name DoorModule
extends StaticBody3D

@export var open_speed: float = 3.0
@export var auto_close_delay: float = 3.0

var is_open: bool = false
var open_timer: float = 0.0
var target_rotation: float = 0.0

@onready var door_mesh: MeshInstance3D = $Door
@onready var trigger: Area3D = $TriggerArea

func _ready() -> void:
	trigger.body_entered.connect(_on_body_entered)
	trigger.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if is_open:
		open_timer -= delta
		if open_timer <= 0:
			close()
	
	# Smooth door rotation
	var current_rot = door_mesh.rotation.y
	if abs(current_rot - target_rotation) > 0.01:
		door_mesh.rotation.y = lerp_angle(current_rot, target_rotation, 10.0 * get_process_delta_time())

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body.is_in_group("enemies"):
		open()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") or body.is_in_group("enemies"):
		open_timer = auto_close_delay

func open() -> void:
	is_open = true
	target_rotation = PI / 2  # 90 degrees
	open_timer = auto_close_delay

func close() -> void:
	is_open = false
	target_rotation = 0.0