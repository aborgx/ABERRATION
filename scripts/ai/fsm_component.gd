class_name FSMComponent
extends Node

signal state_changed(old_state: String, new_state: String)

@export var initial_state: String = "idle"

var current_state: String = ""
var states: Dictionary = {}

func _ready() -> void:
	current_state = initial_state
	_enter_state(current_state)

func _process(delta: float) -> void:
	if states.has(current_state):
		states[current_state].process(delta)

func _physics_process(delta: float) -> void:
	if states.has(current_state):
		states[current_state].physics_process(delta)

func transition(new_state: String) -> void:
	if new_state == current_state:
		return
	
	if states.has(current_state):
		states[current_state].exit()
	
	var old_state = current_state
	current_state = new_state
	
	if states.has(current_state):
		states[current_state].enter()
	
	state_changed.emit(old_state, new_state)

func add_state(state_name: String, state_node: Node) -> void:
	states[state_name] = state_node

func _enter_state(state_name: String) -> void:
	if states.has(state_name):
		states[state_name].enter()