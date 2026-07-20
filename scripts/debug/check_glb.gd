extends SceneTree

func _initialize() -> void:
    var gltf = GLTFDocument.new()
    var state = GLTFState.new()
    var err = gltf.append_from_file("res://scenes/player/chr_player_rigged_anim.glb", state)
    if err != OK:
        print("GLB_LOAD_ERROR: ", err)
        quit()
    var scene = gltf.generate_scene(state)
    print("=== GLB SCENE TREE ===")
    _print_tree(scene, 0)
    print("=== ANIMATION PLAYER CHECK ===")
    var ap = scene.find_child("AnimationPlayer", true, false)
    if ap:
        print("AnimationPlayer FOUND: ", ap.name)
        print("  animations: ", ap.get_animation_list())
    else:
        print("AnimationPlayer NOT FOUND in GLB")
    quit()

func _print_tree(node: Node, depth: int) -> void:
    var indent = "  ".repeat(depth)
    print(indent + node.get_class() + ": " + node.name)
    for child in node.get_children():
        _print_tree(child, depth + 1)
