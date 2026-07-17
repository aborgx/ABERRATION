class_name CheckpointSystem
extends Node
## Checkpoint save/load system for Level 1.
## Saves player position, health, frenesia; respawns on death.

signal checkpoint_saved(id: int, label: String)
signal checkpoint_loaded(id: int)
signal player_respawned

const SAVE_FILE: String = "user://checkpoint.save"

var current_checkpoint: Dictionary = {}  # {id, pos, health, frenesia, timestamp}
var checkpoints: Array[Dictionary] = []

func _ready() -> void:
	checkpoints = get_tree().get_first_node_in_group("level").get_checkpoint_positions() if get_tree().get_first_node_in_group("level") else []

func save_checkpoint(id: int) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Find matching checkpoint data from level
	var cp_data = _get_checkpoint_data(id)
	
	current_checkpoint = {
		"id": id,
		"pos": player.global_position,
		"health": player.health if player.has_method("get_health") else 100,
		"frenesia": player.frenesia if player.has_method("get_frenesia") else 0,
		"timestamp": Time.get_unix_time_from_system(),
		"label": cp_data.get("label", "Checkpoint %d" % id) if cp_data else "Checkpoint %d" % id,
	}
	_persist_save()
	checkpoint_saved.emit(id, current_checkpoint.get("label", ""))

func load_checkpoint() -> bool:
	if current_checkpoint.is_empty():
		return false
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return false
	
	player.global_position = current_checkpoint.get("pos", Vector3.ZERO)
	if player.has_method("set_health"):
		player.set_health(current_checkpoint.get("health", 100))
	if player.has_method("set_frenesia"):
		player.set_frenesia(current_checkpoint.get("frenesia", 0))
	
	checkpoint_loaded.emit(current_checkpoint.get("id", 0))
	return true

func respawn_player() -> void:
	if load_checkpoint():
		player_respawned.emit()

func _get_checkpoint_data(id: int) -> Dictionary:
	for cp in checkpoints:
		if cp.get("id") == id:
			return cp
	return {}

func _persist_save() -> void:
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_var(current_checkpoint)

func has_saved_game() -> bool:
	return not current_checkpoint.is_empty()

func get_active_checkpoint_id() -> int:
	return current_checkpoint.get("id", -1)
