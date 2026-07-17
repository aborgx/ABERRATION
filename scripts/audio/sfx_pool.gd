class_name SFXPool
extends Node
## Object pool for 3D audio playback.
## Manages 20 AudioStreamPlayer3D nodes for reuse.

signal player_returned

@export var pool_size: int = 20
@export var max_distance: float = 50.0

var _pool: Array[AudioStreamPlayer3D] = []

func _ready() -> void:
	for i in range(pool_size):
		var player = AudioStreamPlayer3D.new()
		player.name = "SFXPlayer_%d" % i
		player.bus = "SFX"
		player.max_distance = max_distance
		player.finished.connect(_on_player_finished.bind(player))
		add_child(player)
		_pool.append(player)

func get_free_player() -> AudioStreamPlayer3D:
	for player in _pool:
		if not player.playing:
			return player
	return null

func play_at(stream: AudioStream, position: Vector3, volume: float = 0.0) -> bool:
	var player = get_free_player()
	if not player:
		return false
	player.stream = stream
	player.global_position = position
	player.volume_db = volume
	player.play()
	return true

func play_2d(stream: AudioStream, volume: float = 0.0) -> bool:
	var player = get_free_player()
	if not player:
		return false
	player.stream = stream
	player.volume_db = volume
	player.global_position = Vector3.ZERO
	player.play()
	return true

func stop_all() -> void:
	for player in _pool:
		player.stop()

func _on_player_finished(player: AudioStreamPlayer3D) -> void:
	player_returned.emit()
