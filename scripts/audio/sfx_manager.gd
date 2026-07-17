class_name SFXManager
extends Node
## Manages categorized SFX playback via SFXPool.
## Connects to combat, player, and enemy signals.

signal sfx_played(category: String, sound_name: String)

enum Category { PLAYER, MELEE, RANGED, ENEMIES, ENVIRONMENT }

@onready var pool: SFXPool = $SFXPool if has_node("SFXPool") else null

var sound_map: Dictionary = {
	Category.PLAYER: {},
	Category.MELEE: {},
	Category.RANGED: {},
	Category.ENEMIES: {},
	Category.ENVIRONMENT: {},
}

func _ready() -> void:
	if not pool:
		pool = SFXPool.new()
		add_child(pool)

func register_sound(category: Category, name: String, stream: AudioStream) -> void:
	sound_map[category][name] = stream

func play(category: Category, name: String, position: Vector3 = Vector3.ZERO, volume: float = 0.0) -> bool:
	if not sound_map.has(category) or not sound_map[category].has(name):
		return false
	var stream = sound_map[category][name]
	if not pool:
		return false
	var result = pool.play_at(stream, position, volume)
	if result:
		sfx_played.emit(Category.keys()[category], name)
	return result

func play_2d(category: Category, name: String, volume: float = 0.0) -> bool:
	if not sound_map.has(category) or not sound_map[category].has(name):
		return false
	var stream = sound_map[category][name]
	if not pool:
		return false
	return pool.play_2d(stream, volume)

func connect_to_combat(combat: CombatComponent) -> void:
	combat.hit_landed.connect(_on_hit_landed)

func _on_hit_landed(target: Node, damage: int, hit_type: String) -> void:
	play(Category.MELEE, "impact", target.global_position if target else Vector3.ZERO)
