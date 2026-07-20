extends Node3D
func _ready():
	await get_tree().create_timer(1.0).timeout  # let player fall and land

	var player = $Player
	var anim_tree = null
	for c in player.get_node("Model").get_children():
		if c is AnimationTree:
			anim_tree = c
	if anim_tree == null:
		print("NO ANIMTREE"); return

	# Wait for landing
	await get_tree().create_timer(0.5).timeout
	print("AFTER LAND is_on_ground=", player.is_on_ground, " in_air=", anim_tree.get("parameters/conditions/in_air"))

	# Walk forward
	Input.action_press("move_forward")
	await get_tree().create_timer(0.5).timeout
	print("WALK is_moving=", anim_tree.get("parameters/conditions/is_moving"), " is_sprinting=", anim_tree.get("parameters/conditions/is_sprinting"))
	Input.action_release("move_forward")

	# Sprint
	Input.action_press("move_forward")
	Input.action_press("sprint")
	await get_tree().create_timer(0.5).timeout
	print("SPRINT is_moving=", anim_tree.get("parameters/conditions/is_moving"), " is_sprinting=", anim_tree.get("parameters/conditions/is_sprinting"))
	Input.action_release("sprint")
	Input.action_release("move_forward")

	# Stop
	await get_tree().create_timer(0.5).timeout
	print("STOP is_moving=", anim_tree.get("parameters/conditions/is_moving"), " is_sprinting=", anim_tree.get("parameters/conditions/is_sprinting"))

	# Attack
	var combat = player.get_node_or_null("CombatComponent")
	if combat != null:
		combat.melee_attack_started.emit(1)
		await get_tree().create_timer(0.02).timeout
		print("ATTACK is_attacking=", anim_tree.get("parameters/conditions/is_attacking"))
		await get_tree().create_timer(0.1).timeout
		print("ATTACK END is_attacking=", anim_tree.get("parameters/conditions/is_attacking"))

	# Death
	player.is_dead = true
	await get_tree().create_timer(0.1).timeout
	print("DEATH is_dead=", anim_tree.get("parameters/conditions/is_dead"))

	get_tree().quit()
