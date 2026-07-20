extends AnimationTree
class_name AnimationTreeSetup

## Creates and configures AnimationTree for the player via code.
## StateMachine: Idle ↔ Walk ↔ Sprint → Jump → Fall → Attack/Hit → Death
## BlendSpace1D for Walk↔Sprint blend (speed parameter)
## Root motion for movement.

signal tree_ready(animation_tree: AnimationTree)

## References (set before calling create_animation_tree)
@export var player: CharacterBody3D = null
@export var animation_player_node: AnimationPlayer = null

# --- State indices into STATE_NAMES ---
const STATE_NAMES := ["Idle", "Walk", "Sprint", "Jump", "Fall", "Attack", "Hit", "Death", "Alert"]
const STATE_IDLE   := 0
const STATE_WALK   := 1
const STATE_SPRINT := 2
const STATE_JUMP   := 3
const STATE_FALL   := 3
const STATE_ATTACK := 5
const STATE_HIT    := 6
const STATE_DEATH  := 7
const STATE_ALERT  := 8

# --- Blend times (seconds) ---
const BLEND_SMOOTH := 0.2
const BLEND_FAST   := 0.1
const BLEND_SLOW   := 0.25

var _state_machine: AnimationNodeStateMachine = null
var _blend_space: AnimationNodeBlendSpace1D = null

func _ready() -> void:
	create_animation_tree()

func create_animation_tree() -> AnimationTree:
	"""Build and return a fully configured AnimationTree."""
	# For testing, player can be null
	# assert(player != null, "AnimationTreeSetup: player must be set")
	assert(animation_player_node != null, "AnimationTreeSetup: animation_player must be set")

	# Load animations from .tres files into AnimationPlayer
	_load_animations()

	# Set this AnimationTree's animation player (NodePath to AnimationPlayer in scene tree)
	var ap_path := animation_player_node.get_path()
	print("DEBUG: AnimationTree path = ", get_path())
	print("DEBUG: AnimationPlayer path = ", ap_path)
	print("DEBUG: AnimationPlayer found = ", animation_player_node != null)
	self.set_animation_player(ap_path)
	print("DEBUG: AnimationTree.animation_player = ", self.get_animation_player())

	# Build state machine
	tree_root = _build_state_machine()

	# Set initial state via AnimationNodeStateMachinePlayback (Godot 4.7 API)
	# start_node property does not exist in 4.7; playback.start() is the correct call
	var playback = get("parameters/playback")
	if playback != null:
		playback.start(&"Idle")

	# Initialize all conditions to false
	set("parameters/conditions/is_moving", false)
	set("parameters/conditions/is_sprinting", false)
	set("parameters/conditions/in_air", false)
	set("parameters/conditions/is_attacking", false)
	set("parameters/conditions/is_hit", false)
	set("parameters/conditions/is_dead", false)
	set("parameters/conditions/is_alert", false)

	# Speed parameter for Walk↔Sprint blend
	set("parameters/Walk/blend_position", 0.0)

	active = true

	tree_ready.emit(self)
	return self

func _load_animations() -> void:
	"""Load animation .tres files into AnimationPlayer."""
	var anim_map := {
		"idle": "res://animations/player_idle.tres",
		"walk": "res://animations/player_walk.tres",
		"run": "res://animations/player_run.tres",
		"jump": "res://animations/player_jump.tres",
		"attack": "res://animations/player_attack.tres",
		"death": "res://animations/player_death.tres",
		"fall": "res://animations/player_jump.tres",  # reuse jump for fall
		"hit": "res://animations/player_idle.tres",   # placeholder
		"alert": "res://animations/player_idle.tres", # placeholder
	}
	
	# AnimationPlayer already has a default library at index 0
	var anim_lib = animation_player_node.get_animation_library(&"")
	if not anim_lib:
		anim_lib = AnimationLibrary.new()
		animation_player_node.add_animation_library("", anim_lib)
	
	for anim_name in anim_map:
		var anim_res = load(anim_map[anim_name])
		if anim_res:
			anim_lib.add_animation(anim_name, anim_res)
			print("Loaded animation: ", anim_name)
		else:
			print("Failed to load: ", anim_map[anim_name])

func _build_state_machine() -> AnimationNodeStateMachine:
	_state_machine = AnimationNodeStateMachine.new()

	# Create all state nodes
	var states = {}
	for i in STATE_NAMES.size():
		var state_name = STATE_NAMES[i]
		var node: AnimationNode = null

		if state_name == "Walk":
			# Walk → Sprint uses BlendSpace1D
			_blend_space = _create_walk_sprint_blend()
			states[i] = _blend_space
		else:
			node = AnimationNodeAnimation.new()
			node.animation = state_name.to_lower()
			states[i] = node

	# Add all nodes to state machine
	for i in STATE_NAMES.size():
		_state_machine.add_node(STATE_NAMES[i], states[i], Vector2(120 * i, 200))

	# --- Transitions ──────────────────────────────────────────────────

	# Idle ↔ Walk (is_moving)
	_add_condition_transition("Idle", "Walk", "is_moving", BLEND_SMOOTH, true)
	_add_condition_transition("Walk", "Idle", "is_moving", BLEND_FAST, false)

	# Walk ↔ Sprint (is_sprinting)
	_add_condition_transition("Walk", "Sprint", "is_sprinting", BLEND_SMOOTH, true)
	_add_condition_transition("Sprint", "Walk", "is_sprinting", BLEND_FAST, false)

	# Any → Attack (is_attacking interrupts)
	for from_idx in [STATE_IDLE, STATE_WALK, STATE_SPRINT]:
		_add_condition_transition(STATE_NAMES[from_idx], "Attack", "is_attacking", BLEND_FAST, true)
	_add_condition_transition("Attack", "Walk", "is_attacking", BLEND_FAST, false)

	# Any → Jump (in_air)
	for from_idx in [0, 1, 2]:  # Idle, Walk, Sprint
		_add_condition_transition(STATE_NAMES[from_idx], "Jump", "in_air", BLEND_FAST, true)
	# Jump → Fall (auto, no condition)
	_add_auto_transition("Jump", "Fall", BLEND_SLOW)
	# Fall → Walk (landing)
	_add_condition_transition("Fall", "Walk", "in_air", BLEND_FAST, false)

	# Any → Hit (damage interrupt)
	for from_idx in [0, 1, 2, 5]:  # Idle, Walk, Sprint, Attack
		_add_condition_transition(STATE_NAMES[from_idx], "Hit", "is_hit", BLEND_FAST, true)
	_add_condition_transition("Hit", "Walk", "is_hit", BLEND_FAST, false)

# Any → Death (terminal)
	for i in STATE_NAMES.size():
		if i != 7:  # not Death
			_add_condition_transition(STATE_NAMES[i], "Death", "is_dead", BLEND_SLOW, true)

	# Idle ↔ Alert (enemy detected)
	_add_condition_transition("Idle", "Alert", "is_alert", BLEND_SMOOTH, true)
	_add_condition_transition("Alert", "Idle", "is_alert", BLEND_SMOOTH, false)

	# Set start node via AnimationNodeStateMachinePlayback (Godot 4.7 API)
	# start_node property does not exist in 4.7; use playback.start()
	# playback is available after tree_root is assigned and tree is in scene tree

	return _state_machine

func _create_walk_sprint_blend() -> AnimationNodeBlendSpace1D:
	var blend = AnimationNodeBlendSpace1D.new()
	blend.blend_mode = AnimationNodeBlendSpace1D.BLEND_MODE_INTERPOLATED
	blend.max_space = 1.0
	blend.min_space = 0.0
	blend.snap = 0.1
	blend.value_label = "speed"

	# Walk at 0.0
	var walk_node = AnimationNodeAnimation.new()
	walk_node.animation = "walk"
	blend.add_blend_point(walk_node, 0.0)

	# Sprint at 1.0
	var sprint_node = AnimationNodeAnimation.new()
	sprint_node.animation = "run"
	blend.add_blend_point(sprint_node, 1.0)

	blend.blend_mode = AnimationNodeBlendSpace1D.BLEND_MODE_INTERPOLATED
	return blend

func _add_condition_transition(
	from_state: StringName, to_state: StringName,
	condition: String, xfade: float,
	switch_on_true: bool = true
) -> void:
	var trans = AnimationNodeStateMachineTransition.new()
	trans.advance_condition = condition if switch_on_true else "!" + condition
	trans.xfade_time = xfade
	trans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
	_state_machine.add_transition(from_state, to_state, trans)

func _add_auto_transition(from_state: StringName, to_state: StringName, xfade: float) -> void:
	var trans = AnimationNodeStateMachineTransition.new()
	trans.xfade_time = xfade
	trans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
	_state_machine.add_transition(from_state, to_state, trans)

# ─── Runtime helpers ────────────────────────────────────────────────

func set_state_condition(condition_name: String, val: bool) -> void:
	set("parameters/conditions/" + condition_name, val)

func set_speed_blend(val: float) -> void:
	set("parameters/Walk/blend_position", clampf(val, 0.0, 1.0))

func set_speed_scale(val: float) -> void:
	set("parameters/speed_scale", val)

func trigger_attack() -> void:
	set_state_condition("is_attacking", true)
	await get_tree().create_timer(0.05).timeout
	set_state_condition("is_attacking", false)

func trigger_hit() -> void:
	set_state_condition("is_hit", true)
	await get_tree().create_timer(0.1).timeout
	set_state_condition("is_hit", false)

func trigger_death() -> void:
	set_state_condition("is_dead", true)

func set_alert(val: bool) -> void:
	set_state_condition("is_alert", val)

func _on_animation_tree_ready() -> void:
	pass

func _on_animation_finished(anim_name: StringName) -> void:
	pass