extends SceneTree
func _init():
	var path = "res://scenes/player/player.tscn"
	var packed = ResourceLoader.load(path, "PackedScene")
	if packed == null:
		print("ERROR: cannot load player.tscn"); quit(1)
	var player = packed.instantiate()
	root.add_child(player)
	await create_timer(0.6).timeout

	var anim_tree = null
	for c in player.get_node("Model").get_children():
		if c is AnimationTree:
			anim_tree = c
	if anim_tree == null:
		print("NO ANIMTREE"); quit(1)
	print("ANIMTREE active=", anim_tree.active)

	var movement = player.get_node_or_null("MovementComponent")
	if movement == null:
		print("NO MOVEMENT"); quit(1)

	# Force grounded for logic validation (headless physics artifact workaround)
	player.is_on_ground = true

	# 1. Idle
	Input.action_release("sprint")
	movement.update_state(Vector2.ZERO)
	player._update_animation_state()
	await create_timer(0.05).timeout
	print("IDLE is_moving=", anim_tree.get("parameters/conditions/is_moving"), " is_sprinting=", anim_tree.get("parameters/conditions/is_sprinting"), " in_air=", anim_tree.get("parameters/conditions/in_air"))

	# 2. Walk forward
	movement.update_state(Vector2(0, -1))
	player._update_animation_state()
	await create_timer(0.05).timeout
	print("WALK is_moving=", anim_tree.get("parameters/conditions/is_moving"), " is_sprinting=", anim_tree.get("parameters/conditions/is_sprinting"))

	# 3. Sprint forward
	Input.action_press("sprint")
	movement.update_state(Vector2(0, -1))
	player._update_animation_state()
	await create_timer(0.05).timeout
	print("SPRINT is_moving=", anim_tree.get("parameters/conditions/is_moving"), " is_sprinting=", anim_tree.get("parameters/conditions/is_sprinting"))

	# 4. Stop (idle again)
	Input.action_release("sprint")
	movement.update_state(Vector2.ZERO)
	player._update_animation_state()
	await create_timer(0.05).timeout
	print("STOP is_moving=", anim_tree.get("parameters/conditions/is_moving"), " is_sprinting=", anim_tree.get("parameters/conditions/is_sprinting"))

	# 5. In air
	player.is_on_ground = false
	player._update_animation_state()
	await create_timer(0.05).timeout
	print("IN_AIR in_air=", anim_tree.get("parameters/conditions/in_air"))

	# 6. Attack (event-driven)
	var combat = player.get_node_or_null("CombatComponent")
	if combat != null:
		combat.melee_attack_started.emit(1)
		await create_timer(0.02).timeout
		print("ATTACK is_attacking=", anim_tree.get("parameters/conditions/is_attacking"))
		await create_timer(0.1).timeout
		print("ATTACK END is_attacking=", anim_tree.get("parameters/conditions/is_attacking"))

	# 7. Death
	player.is_dead = true
	player._update_animation_state()
	await create_timer(0.05).timeout
	print("DEATH is_dead=", anim_tree.get("parameters/conditions/is_dead"))

	quit(0)
