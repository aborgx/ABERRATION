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

	# Direct call to trigger_attack
	anim_tree.trigger_attack()
	await create_timer(0.02).timeout
	print("is_attacking after direct trigger=", anim_tree.get("parameters/conditions/is_attacking"))
	await create_timer(0.1).timeout
	print("is_attacking after delay=", anim_tree.get("parameters/conditions/is_attacking"))

	# Check signal connection
	var combat = player.get_node_or_null("CombatComponent")
	print("combat null?", combat == null)
	if combat != null:
		print("signal melee_attack_started connections=", combat.is_connected("melee_attack_started", Callable(player, "_on_melee_attack_started")) if combat.has_signal("melee_attack_started") else "no signal")
	quit(0)
