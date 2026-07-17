class_name Level1
extends Node3D
## Level 1 — Police Station level logic.
## Manages area progression, wave triggers, checkpoint placement, and boss spawn.

signal level_started
signal area_cleared(area_name: String)
signal checkpoint_reached(id: int)
signal boss_defeated

@export var player_start_position: Vector3 = Vector3(-30, 0, -10)

var current_area: String = "entrance"
var areas_cleared: Dictionary = {}
var player: Node3D
var spawn_manager: SpawnManager
var director: Director
var prop_library: PropLibrary

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	spawn_manager = get_tree().get_first_node_in_group("spawn_manager")
	director = get_tree().get_first_node_in_group("director")
	prop_library = get_tree().get_first_node_in_group("prop_library")
	
	# Create PropLibrary if not in scene tree
	if not prop_library:
		prop_library = PropLibrary.new()
		prop_library.add_to_group("prop_library")
		add_child(prop_library)
	
	# Connect area triggers
	_connect_triggers()
	
	_setup_level()
	level_started.emit()

func _connect_triggers() -> void:
	var area_mapping = {
		"EntranceTrigger": "entrance",
		"CorridorTrigger": "corridor",
		"OfficesTrigger": "offices",
		"BarricadeTrigger": "barricade",
		"ArmoryTrigger": "armory",
		"BossArenaTrigger": "boss_arena",
	}
	var areas_node = get_node_or_null("Areas")
	if not areas_node:
		return
	for node_name in area_mapping:
		var area = areas_node.get_node_or_null(node_name)
		if area:
			area.body_entered.connect(_on_area_body_entered.bind(area_mapping[node_name]))

func _on_area_body_entered(body: Node, area_name: String) -> void:
	if body == player:
		on_area_entered(area_name)

func _setup_level() -> void:
	# Place player at start
	if player:
		player.global_position = player_start_position
	
	# Build level areas
	_build_entrance()
	_build_corridors()
	_build_offices()
	_build_barricade_section()
	_build_armory()
	_build_boss_arena()

func _build_entrance() -> void:
	"""Reception area with security checkpoint and first enemies."""
	# Area volume: 12x12x4 centered at (-30, 0, -10)
	_place_room(-30, 0, -10, 12, 12)
	_place_spawn_point(-34, 0, -6, "entrance")
	_place_spawn_point(-26, 0, -14, "entrance")
	_place_cover(-32, 0, -12)
	_place_cover(-28, 0, -8)

func _build_corridors() -> void:
	"""Connect entrance (west) to offices (east)."""
	# Main corridor: 24x4 from x=-18 to x=6 at z=-10
	for i in range(0, 24, 4):
		_place_floor(-18 + i, 0, -10, 4, 4)
		_place_spawn_point(-16 + i, 0, -10, "corridor")
	# Cover at corridor junctions
	_place_cover(-12, 0, -8)
	_place_cover(-4, 0, -12)
	_place_cover(2, 0, -8)

func _build_offices() -> void:
	"""Office wing: cubicles, interrogation rooms, cells."""
	# Large open office: 16x12 centered at (12, 0, -6)
	_place_room(12, 0, -6, 16, 12)
	# Interrogation rooms (north side)
	_place_room(8, 0, -16, 6, 4)
	_place_spawn_point(8, 0, -16, "offices")
	# Cells (south side)
	_place_room(16, 0, 4, 6, 4)
	_place_spawn_point(16, 0, 4, "offices")
	# Cover throughout
	_place_cover(6, 0, -8)
	_place_cover(12, 0, -10)
	_place_cover(18, 0, -6)
	_place_cover(10, 0, 0)
	_place_cover(14, 0, 2)

func _build_barricade_section() -> void:
	"""Barricaded area between offices and armory with shield enemies."""
	# Barricade chokepoint: 8x8 at (24, 0, -6)
	_place_room(24, 0, -6, 8, 8)
	_place_spawn_point(24, 0, -10, "barricade")
	_place_spawn_point(24, 0, -2, "barricade")
	_place_spawn_point(28, 0, -6, "barricade")
	# Extra cover
	_place_cover(22, 0, -8)
	_place_cover(26, 0, -4)
	_place_cover(28, 0, -8)

func _build_armory() -> void:
	"""Armory with heavy enemies before boss."""
	# Armory: 10x10 at (36, 0, -6)
	_place_room(36, 0, -6, 10, 10)
	_place_spawn_point(36, 0, -10, "armory")
	_place_spawn_point(36, 0, -2, "armory")
	_place_spawn_point(40, 0, -6, "armory")
	_place_cover(34, 0, -8)
	_place_cover(38, 0, -4)

func _build_boss_arena() -> void:
	"""Boss arena: large circular space at (50, 0, -6)."""
	# Arena: 20x20 at (50, 0, -6)
	_place_room(50, 0, -6, 20, 20)
	_place_spawn_point(50, 0, -10, "boss_arena")
	_place_spawn_point(50, 0, -2, "boss_arena")
	_place_spawn_point(54, 0, -6, "boss_arena")
	_place_spawn_point(46, 0, -6, "boss_arena")
	# Arena cover (pillars)
	_place_cover(46, 0, -10)
	_place_cover(54, 0, -10)
	_place_cover(46, 0, -2)
	_place_cover(54, 0, -2)

func _place_floor(cx: float, cz: float, cy: float, w: float, d: float) -> void:
	"""Place a floor tile at position."""
	if not prop_library:
		return
	var floor = prop_library.instantiate_prop("floor")
	if floor:
		floor.position = Vector3(cx, cy - 1.0, cz)
		floor.scale = Vector3(w / 4.0, 1, d / 4.0)
		add_child(floor)

func _place_room(cx: float, cz: float, cy: float, w: float, d: float) -> void:
	"""Place floor and walls for a rectangular room at center (cx, cy, cz)."""
	_place_floor(cx, cz, cy, w, d)
	if not prop_library:
		return
	# Walls (north, south, east, west)
	var half_w = w / 2.0
	var half_d = d / 2.0
	var walls = [
		[Vector3(cx, cy + 0.5, cz - half_d - 0.1), Vector3(w / 4.0, 1, 1)],  # North
		[Vector3(cx, cy + 0.5, cz + half_d + 0.1), Vector3(w / 4.0, 1, 1)],  # South
		[Vector3(cx + half_w + 0.1, cy + 0.5, cz), Vector3(1, 1, d / 4.0)],  # East
		[Vector3(cx - half_w - 0.1, cy + 0.5, cz), Vector3(1, 1, d / 4.0)],  # West
	]
	for wall_data in walls:
		var pos = wall_data[0]
		var scale = wall_data[1]
		var wall = prop_library.instantiate_prop("wall")
		if wall:
			wall.position = pos
			wall.scale = scale
			add_child(wall)

func _place_spawn_point(cx: float, cy: float, cz: float, area: String) -> void:
	var marker = Marker3D.new()
	marker.position = Vector3(cx, cy, cz)
	marker.add_to_group("spawn_points")
	marker.set_meta("area", area)
	add_child(marker)

func _place_cover(cx: float, cy: float, cz: float) -> void:
	var marker = Marker3D.new()
	marker.position = Vector3(cx, cy, cz)
	marker.add_to_group("cover_points")
	add_child(marker)

func on_area_entered(area_name: String) -> void:
	"""Called when player enters a new area."""
	if areas_cleared.has(area_name):
		return
	current_area = area_name
	match area_name:
		"entrance":
			_start_wave("infantry", 3)
		"corridor":
			_start_wave("infantry", 2)
		"offices":
			_start_wave("infantry", 4)
			await get_tree().create_timer(3.0).timeout
			_spawn_enemy("shield")
		"barricade":
			_start_wave("shield", 2)
			await get_tree().create_timer(2.0).timeout
			_spawn_enemy("infantry", 2)
		"armory":
			_start_wave("infantry", 3)
			await get_tree().create_timer(1.0).timeout
			_spawn_enemy("sniper")
		"boss_arena":
			_spawn_boss()

func _start_wave(enemy_type: String, count: int) -> void:
	if not spawn_manager:
		return
	for i in range(count):
		spawn_manager.spawn_enemy(enemy_type)
		await get_tree().create_timer(0.5).timeout

func _spawn_enemy(enemy_type: String, count: int = 1) -> void:
	if not spawn_manager:
		return
	for i in range(count):
		spawn_manager.spawn_enemy(enemy_type)
		await get_tree().create_timer(0.3).timeout

func _spawn_boss() -> void:
	"""Spawn Boss Juggernaut in boss arena."""
	if not spawn_manager or not director:
		return
	# Trigger boss music via director
	# Spawn boss using SpawnManager (at dedicated boss spawn point)
	var boss_spawns = get_tree().get_nodes_in_group("spawn_points")
	for spawn in boss_spawns:
		if spawn.has_meta("area") and spawn.get_meta("area") == "boss_arena":
			spawn_manager.spawn_enemy("juggernaut")
			break
	# Notify director
	director.notify_boss_spawned()  # Assuming method added to Director

func get_checkpoint_positions() -> Array[Dictionary]:
	"""Return candidate checkpoint positions for CheckpointSystem."""
	return [
		{"id": 1, "pos": Vector3(-30, 0, -10), "label": "Police Station Entrance"},
		{"id": 2, "pos": Vector3(6, 0, -10), "label": "Corridor Junction"},
		{"id": 3, "pos": Vector3(16, 0, 4), "label": "Office Wing"},
		{"id": 4, "pos": Vector3(36, 0, -6), "label": "Armory Entrance"},
	]
