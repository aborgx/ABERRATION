class_name SpatialAudioManager
extends Node
## Handles 3D positioned audio with occlusion awareness.
## Uses SFXPool for playback.

@onready var pool: SFXPool = $SFXPool if has_node("SFXPool") else null

func _ready() -> void:
	if not pool:
		pool = SFXPool.new()
		add_child(pool)

func play_3d(stream: AudioStream, position: Vector3, volume: float = 0.0) -> bool:
	if pool:
		return pool.play_at(stream, position, volume)
	return false

func is_occluded(position: Vector3) -> bool:
	"""Simple raycast occlusion check."""
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return false
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		position,
		player.global_position,
		2  # Environment layer
	)
	var result = space_state.intersect_ray(query)
	return result
