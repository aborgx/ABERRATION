extends SceneTree
func _init():
	var path = "res://scenes/test/test_level.tscn"
	var packed = ResourceLoader.load(path, "PackedScene")
	if packed == null:
		print("ERROR: cannot load test_level.tscn"); quit(1)
	var level = packed.instantiate()
	root.add_child(level)
	await create_timer(0.8).timeout

	var player = level.get_node_or_null("Player")
	if player == null:
		print("NO PLAYER"); quit(1)

	var anim_tree = null
	for c in player.get_node("Model").get_children():
		if c is AnimationTree:
			anim_tree = c
	if anim_tree == null:
		print("NO ANIMTREE"); quit(1)
	print("ANIMTREE active=", anim_tree.active)

	# Force grounded state to validate movement conditions (headless physics artifact workaround)
	player.is_on_ground = true

	# 1. Idle baseline (grounded)
	await create_timer(0.1).timeout
	print("IDLE is_moving=", anim_tree.get("parameters/conditions/is_moving"), " is_sprinting=", anim_tree.get("parameters/conditions/is_sprinting"), " in_air=", anim_tree.get("parameters/conditions/in_air"))

	# 2. Move forward (walk)
	Input.action_press("move_forward")
	await create_timer(0.3).timeout
	print("WALK is_moving=", anim_tree.get("parameters/conditions/is_moving"), " is_sprinting=", anim_tree.get("parameters/conditions/is_sprinting"))
	Input.action_release("move_forward")

	# 3. Sprint
	Input.action_press("move_forward")
	Input.action_press("sprint")
	await create_timer(0.3).timeout
	print("SPRINT is_moving=", anim_tree.get("parameters/conditions/is_moving"), " is_sprinting=", anim_tree.get("parameters/conditions/is_sprinting"))
	Input.action_release("sprint")
	Input.action_release("move_forward")

	# 4. Attack via combat component
	var combat = player.get_node_or_null("CombatComponent")
	if combat != null:
		combat.melee_attack_started.emit(1)
		await create_timer(0.02).timeout
		print("ATTACK is_attacking=", anim_tree.get("parameters/conditions/is_attacking"))
		await create_timer(0.1).timeout
		print("ATTACK END is_attacking=", anim_tree.get("parameters/conditions/is_attacking"))
	else:
		print("NO COMBAT for attack test")

	# 5. Death (call die() to trigger proper state)
	if player.has_method("die"):
		player.die()
		await create_timer(0.1).timeout
		print("DEATH is_dead=", anim_tree.get("parameters/conditions/is_dead"))
	else:
		print("NO die() method")

	quit(0)
