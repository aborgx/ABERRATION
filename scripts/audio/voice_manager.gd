class_name VoiceManager
extends Node
## Manages player vocalization pools (growl, snarl, scream, howl, etc.).
## Uses SFXPool for 3D spatial audio playback.

enum VoiceType { GROWL, SNARL, SCREAM, HOWL, GULP, CRUNCH, PAIN }

@onready var pool: SFXPool = $SFXPool if has_node("SFXPool") else null

var voice_pools: Dictionary = {}

func _ready() -> void:
	if not pool:
		pool = SFXPool.new()
		add_child(pool)

func register_voice(type: VoiceType, streams: Array[AudioStream]) -> void:
	voice_pools[type] = streams

func play_voice(type: VoiceType, position: Vector3 = Vector3.ZERO, volume: float = 0.0) -> bool:
	if not voice_pools.has(type) or voice_pools[type].is_empty():
		return false
	var streams = voice_pools[type]
	var stream = streams[randi() % streams.size()]
	if pool:
		return pool.play_at(stream, position, volume)
	return false
