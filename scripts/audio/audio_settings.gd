class_name AudioSettings
extends Node
## Audio bus volume persistence.
## Saves/loads per-bus volumes to user://audio_settings.cfg.

const SETTINGS_FILE: String = "user://audio_settings.cfg"
const BUS_NAMES: Array[String] = ["Master", "Music", "SFX", "Voice", "Ambient"]

var volumes: Dictionary = {}

func _ready() -> void:
	_load_settings()

func get_volume(bus_name: String) -> float:
	if volumes.has(bus_name):
		return volumes[bus_name]
	return 1.0

func set_volume(bus_name: String, linear: float) -> void:
	volumes[bus_name] = clampf(linear, 0.0, 1.0)
	_apply_volume(bus_name)

func _apply_volume(bus_name: String) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		return
	var db = linear_to_db(volumes.get(bus_name, 1.0))
	AudioServer.set_bus_volume_db(bus_idx, db)

func save_settings() -> void:
	var config = ConfigFile.new()
	for bus in BUS_NAMES:
		config.set_value("audio", bus, volumes.get(bus, 1.0))
	config.save(SETTINGS_FILE)

func _load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(SETTINGS_FILE) != OK:
		# Default: all at full
		for bus in BUS_NAMES:
			volumes[bus] = 1.0
			_apply_volume(bus)
		return
	for bus in BUS_NAMES:
		volumes[bus] = config.get_value("audio", bus, 1.0)
		_apply_volume(bus)
