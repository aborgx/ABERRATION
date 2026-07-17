extends Node
## Input action setup. Runs on project start to define all player input actions.
## Using code instead of project.godot [input] section for reliability.

func _ready() -> void:
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("move_up", KEY_W)
	_add_key_action("move_down", KEY_S)
	_add_key_action("jump", KEY_SPACE)
	_add_key_action("sprint", KEY_SHIFT)
	_add_key_action("crouch", KEY_CTRL)
	_add_key_action("dash", KEY_TAB)
	_add_mouse_action("attack_melee", MOUSE_BUTTON_LEFT)
	_add_mouse_action("attack_ranged", MOUSE_BUTTON_RIGHT)
	_add_key_action("scream", KEY_Q)
	_add_key_action("grab", KEY_E)
	_add_key_action("dash_attack", KEY_SHIFT)
	_add_key_action("ground_slam", KEY_CTRL)

func _add_key_action(name: String, keycode: Key, deadzone: float = 0.5) -> void:
	if InputMap.has_action(name):
		return
	InputMap.add_action(name, deadzone)
	var event = InputEventKey.new()
	event.keycode = keycode
	InputMap.action_add_event(name, event)

func _add_mouse_action(name: String, button: MouseButton, deadzone: float = 0.5) -> void:
	if InputMap.has_action(name):
		return
	InputMap.add_action(name, deadzone)
	var event = InputEventMouseButton.new()
	event.button_index = button
	InputMap.action_add_event(name, event)
