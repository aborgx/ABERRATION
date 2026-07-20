extends SceneTree
func _init():
	var path = "res://scenes/player/player.tscn"
	var packed = ResourceLoader.load(path, "PackedScene")
	if packed == null:
		print("ERROR: cannot load player.tscn"); quit(1)
	var player = packed.instantiate()
	root.add_child(player)
	await create_timer(0.8).timeout

	var model = player.get_node_or_null("Model")
	if model == null:
		print("NO MODEL"); quit(1)

	# Find GLB instance + AnimationPlayer + AnimationTree
	var glb = null
	var anim_player = null
	var anim_tree = null
	var stack = [model]
	while stack.size() > 0:
		var node = stack.pop_back()
		if node is AnimationPlayer and anim_player == null:
			anim_player = node
		if node is AnimationTree and anim_tree == null:
			anim_tree = node
		for child in node.get_children():
			stack.push_back(child)
		if node is Node3D and node != model and glb == null and node.get_child_count() > 0:
			glb = node

	print("GLB_INSTANCE=", glb != null)
	print("ANIM_PLAYER=", anim_player != null)
	if anim_player != null:
		var lib = anim_player.get_animation_library("")
		if lib != null:
			print("  ANIM_LIB animations: ", lib.get_animation_list())
		else:
			print("  ANIM_LIB null")
	print("ANIM_TREE=", anim_tree != null)
	if anim_tree != null:
		print("  tree.active=", anim_tree.active)
		var playback = anim_tree.get("parameters/playback")
		print("  playback=", playback != null)
		if playback != null:
			print("  current_node=", playback.get_current_node() if playback.has_method("get_current_node") else "n/a")

	# Check camera
	var cam = player.get_node_or_null("CameraPivot/Camera3D")
	if cam != null:
		print("CAMERA local pos=", cam.position, " global=", cam.global_position)
	else:
		print("NO CAMERA")

	quit(0)
