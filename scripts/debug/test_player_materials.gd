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

	var glb = null
	for c in model.get_children():
		if c is Node3D and c != null and c.get_child_count() > 0:
			glb = c
			break
	if glb == null:
		print("NO GLB INSTANCE"); quit(1)

	var found_real_mat = false
	var found_fallback = false
	var mesh_count = 0

	var stack = [glb]
	while stack.size() > 0:
		var node = stack.pop_back()
		for child in node.get_children():
			if child is MeshInstance3D:
				var mesh = child.mesh
				if mesh != null:
					mesh_count += 1
					for i in mesh.get_surface_count():
						var mat = mesh.surface_get_material(i)
						if mat != null:
							var mat_name = mat.resource_name
							if mat_name == "" or mat.albedo_color == Color(0.6, 0.65, 0.7):
								found_fallback = true
							else:
								found_real_mat = true
							print("  surface %d: mat=%s albedo=%s" % [i, mat_name, mat.albedo_color])
			stack.push_back(child)

	print("MESH_COUNT=", mesh_count, " REAL_MAT=", found_real_mat, " FALLBACK=", found_fallback)
	if found_real_mat and not found_fallback:
		print("RESULT: PBR materials applied successfully")
	elif found_fallback and not found_real_mat:
		print("RESULT: still using grey fallback (materials not in GLB)")
	else:
		print("RESULT: mixed or none")
	quit(0)
