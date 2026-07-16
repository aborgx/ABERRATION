extends Node3D
## Test level script — minimal integration test for Wave 1.

func _ready() -> void:
	print("TestLevel: Ready — Wave 1 integration test")
	# Verify player exists
	var player = get_node_or_null("Player")
	if player:
		print("TestLevel: Player found")
	else:
		print("TestLevel: err — Player not found")
	# Verify HUD exists
	var hud = get_node_or_null("HUD")
	if hud:
		print("TestLevel: HUD found")
	else:
		print("TestLevel: err — HUD not found")

func _process(delta: float) -> void:
	# Debug: print player state
	var player = get_node_or_null("Player")
	if player and Input.is_action_just_pressed("ui_cancel"):  # ESC
		var state = player.get("current_state")
		if state == null:
			state = "unknown"
		print("Player state: ", state)
		print("Health: ", player.health, " Frenesia: ", player.frenesia)