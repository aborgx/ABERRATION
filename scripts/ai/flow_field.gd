class_name FlowField
extends Node3D

var field_size: Vector2i = Vector2i(100, 100)
var cell_size: float = 1.0
var field: Array[Array] = []

func generate_field(target_position: Vector3) -> void:
	# Initialize field
	for x in range(field_size.x):
		field[x] = []
		for y in range(field_size.y):
			field[x][y] = Vector2.ZERO
	
	# BFS from target
	var queue: Array[Vector2i] = []
	var target_cell = world_to_cell(target_position)
	queue.append(target_cell)
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var neighbors = get_neighbors(current)
		
		for neighbor in neighbors:
			if is_walkable(neighbor) and field[neighbor.x][neighbor.y] == Vector2.ZERO:
				field[neighbor.x][neighbor.y] = (current - neighbor).normalized()
				queue.append(neighbor)

func get_direction(position: Vector3) -> Vector3:
	var cell = world_to_cell(position)
	if cell.x >= 0 and cell.x < field_size.x and cell.y >= 0 and cell.y < field_size.y:
		var dir = field[cell.x][cell.y]
		return Vector3(dir.x, 0, dir.y)
	return Vector3.ZERO

func world_to_cell(position: Vector3) -> Vector2i:
	return Vector2i(int(position.x / cell_size), int(position.z / cell_size))

func get_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var neighbors = []
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var nx = cell.x + dx
			var ny = cell.y + dy
			if nx >= 0 and nx < field_size.x and ny >= 0 and ny < field_size.y:
				neighbors.append(Vector2i(nx, ny))
	return neighbors

func is_walkable(cell: Vector2i) -> bool:
	var world_pos = Vector3(cell.x * cell_size, 0, cell.y * cell_size)
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(world_pos + Vector3(0, 0.1, 0), world_pos + Vector3(0, 2, 0), 1)
	var result = space_state.intersect_ray(query)
	return not result