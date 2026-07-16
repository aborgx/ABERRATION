class_name NavigationComponent
extends Node3D

@export var agent_radius: float = 0.5
@export var agent_height: float = 1.8
@export var max_climb: float = 0.3
@export var max_slope: float = 45.0
@export var cell_size: float = 0.2

var nav_agent: NavigationAgent3D

func _ready() -> void:
	nav_agent = NavigationAgent3D.new()
	nav_agent.agent_radius = agent_radius
	nav_agent.agent_height = agent_height
	nav_agent.max_climb = max_climb
	nav_agent.max_slope = max_slope
	add_child(nav_agent)

func set_target(target_pos: Vector3) -> void:
	if nav_agent:
		nav_agent.target_position = target_pos

func get_next_velocity(max_speed: float) -> Vector3:
	if not nav_agent or nav_agent.is_navigation_finished():
		return Vector3.ZERO
	
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - get_parent().global_position).normalized()
	return direction * max_speed

func is_navigation_finished() -> bool:
	return nav_agent and nav_agent.is_navigation_finished()