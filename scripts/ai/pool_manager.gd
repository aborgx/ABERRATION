class_name PoolManager
extends Node

var pools: Dictionary = {}

func create_pool(scene: PackedScene, initial_size: int, pool_name: String) -> void:
	var pool: Array[Node] = []
	for i in range(initial_size):
		var instance = scene.instantiate()
		instance.set_process(false)
		instance.set_physics_process(false)
		instance.visible = false
		add_child(instance)
		pool.append(instance)
	pools[pool_name] = pool

func get_from_pool(pool_name: String) -> Node:
	if pools.has(pool_name):
		for node in pools[pool_name]:
			if not node.visible:
				node.visible = true
				node.set_process(true)
				node.set_physics_process(true)
				return node
	return null

func return_to_pool(node: Node) -> void:
	node.visible = false
	node.set_process(false)
	node.set_physics_process(false)
	node.get_parent().remove_child(node)
	add_child(node)