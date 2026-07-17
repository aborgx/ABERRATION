class_name MusicManager
extends Node
## Dynamic music with 4 layers: exploration, combat, frenesia, boss.
## Crossfades between layers based on game state (frenesia level, boss active).

signal music_state_changed(layer: String, volume: float)

@export var crossfade_speed: float = 2.0
@export var master_volume: float = 0.8

var layers: Dictionary = {}  # name -> AudioStreamPlayer
var target_volumes: Dictionary = {}
var current_volumes: Dictionary = {}
var is_boss_active: bool = false
var frenesia_level: int = 0

const LAYER_NAMES = ["exploration", "combat", "frenesia", "boss"]
const FADE_DURATION: float = 0.5

func _ready() -> void:
	_create_layers()
	# Default: exploration at full
	for layer in LAYER_NAMES:
		target_volumes[layer] = -80.0 if layer != "exploration" else 0.0
		current_volumes[layer] = -80.0 if layer != "exploration" else 0.0

func _create_layers() -> void:
	for layer_name in LAYER_NAMES:
		var player = AudioStreamPlayer.new()
		player.name = layer_name.capitalize()
		player.bus = "Music"
		player.volume_db = -80.0
		player.autoplay = true
		add_child(player)
		layers[layer_name] = player

func _process(delta: float) -> void:
	_update_volumes(delta)
	_apply_volumes()

func _update_volumes(delta: float) -> void:
	# Exploration base layer
	target_volumes["exploration"] = _db(-3.0)
	
	# Combat layer: active when frenesia > 0 or enemies nearby
	if frenesia_level > 0 or is_boss_active:
		target_volumes["combat"] = _db(-6.0)
	else:
		target_volumes["combat"] = -80.0
	
	# Frenesia layer: based on frenesia level (1-4)
	if frenesia_level >= 2:
		target_volumes["frenesia"] = _db(-8.0 - (4 - frenesia_level) * 2)
	elif frenesia_level >= 1:
		target_volumes["frenesia"] = _db(-15.0)
	else:
		target_volumes["frenesia"] = -80.0
	
	# Boss layer
	target_volumes["boss"] = _db(-3.0) if is_boss_active else -80.0

func _apply_volumes() -> void:
	for layer in LAYER_NAMES:
		var current = current_volumes[layer]
		var target = target_volumes[layer]
		current = move_toward(current, target, crossfade_speed * get_process_delta_time())
		current_volumes[layer] = current
		layers[layer].volume_db = current

func _db(value: float) -> float:
	"""Convert linear 0-1 to dB, or pass dB directly if negative."""
	return value if value < 0 else linear_to_db(value)

func set_frenesia_level(level: int) -> void:
	frenesia_level = clamp(level, 0, 4)

func set_boss_active(active: bool) -> void:
	is_boss_active = active

func play_music(layer: String, stream: AudioStream) -> void:
	if layers.has(layer):
		layers[layer].stream = stream

func stop_all() -> void:
	for layer in LAYER_NAMES:
		target_volumes[layer] = -80.0
