class_name Level2
extends Node3D
## Level 2 — Underground Laboratory level logic.
## Layout: Decon Chamber → Lab Corridors → Experiment Halls → Service Tunnels → Server Room → Boss Arena

signal level_started
signal area_cleared(area_name: String)
signal checkpoint_reached(id: int)
signal boss_defeated

@export var player_start_position: Vector3 = Vector3(-20, 0, -10)

var current_area: String = "decon"
var areas_cleared: Dictionary = {}
var player: Node3D
var spawn_manager: SpawnManager
var director: Director
var prop_library: PropLibraryLab

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	spawn_manager = get_tree().get_first_node_in_group("spawn_manager")
	director = get_tree().get_first_node_in_group("director")
	prop_library = get_tree().get_first_node_in_group("prop_library_lab")
	
	if not prop_library:
		prop_library = PropLibraryLab.new()
		prop_library.add_to_group("prop_library_lab")
		add_child(prop_library)
	
	_connect_triggers()
	_setup_level()
	level_started.emit()

func _connect_triggers() -> void:
	var areas = {
		"DeconTrigger": "decon",
		"CorridorTrigger": "lab_corridors",
		"ExperimentsTrigger": "experiments",
		"TunnelsTrigger": "tunnels",
		"ServerTrigger": "server_room",
		"BossTrigger": "boss_arena",
	}
	var areas_node = get_node_or_null("Areas")
	if not areas_node:
		return
	for node_name in areas:
		var area = areas_node.get_node_or_null(node_name)
		if area:
			area.body_entered.connect(_on_area_body_entered.bind(areas[node_name]))

func _on_area_body_entered(body: Node, area_name: String) -> void:
	if body == player:
		on_area_entered(area_name)

func _setup_level() -> void:
	if player:
		player.global_position = player_start_position
	_build_decon()
	_build_corridors()
	_build_experiments()
	_build_tunnels()
	_build_server_room()
	_build_boss_arena()

func _build_decon() -> void:
	_place_room(-20, 0, -10, 10, 10)
	_place_spawn_point(-20, 0, -10, "decon")

func _build_corridors() -> void:
	for i in range(0, 20, 4):
		_place_room(-10 + i, 0, -10, 4, 4)
		_place_spawn_point(-8 + i, 0, -10, "lab_corridors")

func _build_experiments() -> void:
	_place_room(10, 0, -6, 16, 14)
	_place_spawn_point(10, 0, -10, "experiments")
	_place_spawn_point(10, 0, -2, "experiments")
	_place_spawn_point(16, 0, -6, "experiments")

func _build_tunnels() -> void:
	_place_room(24, 0, -6, 8, 8)
	_place_spawn_point(24, 0, -6, "tunnels")

func _build_server_room() -> void:
	_place_room(36, 0, -6, 12, 10)
	_place_spawn_point(36, 0, -6, "server_room")
	_place_spawn_point(36, 0, -2, "server_room")
	_place_spawn_point(36, 0, -10, "server_room")

func _build_boss_arena() -> void:
	_place_room(52, 0, -6, 20, 20)
	_place_spawn_point(52, 0, -10, "boss_arena")
	_place_spawn_point(52, 0, -2, "boss_arena")
	_place_spawn_point(56, 0, -6, "boss_arena")
	_place_spawn_point(48, 0, -6, "boss_arena")

func _place_room(cx: float, cz: float, cy: float, w: float, d: float) -> void:
	if not prop_library:
		return
	var floor = prop_library.instantiate_prop("lab_floor")
	if floor:
		floor.position = Vector3(cx, cy - 1.0, cz)
		floor.scale = Vector3(w / 4.0, 1, d / 4.0)
		add_child(floor)
	var walls = [
		[Vector3(cx, cy + 0.5, cz - d / 2.0 - 0.1), Vector3(w / 4.0, 1, 1)],
		[Vector3(cx, cy + 0.5, cz + d / 2.0 + 0.1), Vector3(w / 4.0, 1, 1)],
		[Vector3(cx + w / 2.0 + 0.1, cy + 0.5, cz), Vector3(1, 1, d / 4.0)],
		[Vector3(cx - w / 2.0 - 0.1, cy + 0.5, cz), Vector3(1, 1, d / 4.0)],
	]
	for pos, scale in walls:
		var wall = prop_library.instantiate_prop("lab_wall")
		if wall:
			wall.position = pos
			wall.scale = scale
			add_child(wall)

func _place_spawn_point(cx: float, cy: float, cz: float, area: String) -> void:
	var m = Marker3D.new()
	m.position = Vector3(cx, cy, cz)
	m.add_to_group("spawn_points")
	m.set_meta("area", area)
	add_child(m)

func _place_cover(cx: float, cy: float, cz: float) -> void:
	var m = Marker3D.new()
	m.position = Vector3(cx, cy, cz)
	m.add_to_group("cover_points")
	add_child(m)

func on_area_entered(area_name: String) -> void:
	if areas_cleared.has(area_name):
		return
	current_area = area_name
	match area_name:
		"decon":
			_start_wave("infantry", 2)
		"lab_corridors":
			_start_wave("infantry", 3)
		"experiments":
			_start_wave("infantry", 4)
			await get_tree().create_timer(3.0).timeout
			_spawn_enemy("sniper")
		"tunnels":
			_start_wave("infantry", 2)
		"server_room":
			_start_wave("infantry", 3)
			_spawn_enemy("engineer")
		"boss_arena":
			# Spawn Assault Robot
			var spawns = get_tree().get_nodes_in_group("spawn_points")
			for s in spawns:
				if s.has_meta("area") and s.get_meta("area") == "boss_arena":
					spawn_manager.spawn_enemy("assault_robot")
					break
			if director:
				director.notify_boss_spawned()

func _start_wave(et: String, c: int) -> void:
	if not spawn_manager:
		return
	for i in range(c):
		spawn_manager.spawn_enemy(et)
		await get_tree().create_timer(0.5).timeout

func _spawn_enemy(et: String, c: int = 1) -> void:
	if not spawn_manager:
		return
	for i in range(c):
		spawn_manager.spawn_enemy(et)
		await get_tree().create_timer(0.3).timeout

func get_checkpoint_positions() -> Array[Dictionary]:
	return [
		{"id": 1, "pos": Vector3(-20, 0, -10), "label": "Decontamination Chamber"},
		{"id": 2, "pos": Vector3(10, 0, -6), "label": "Experiment Halls"},
		{"id": 3, "pos": Vector3(36, 0, -6), "label": "Server Room"},
	]
