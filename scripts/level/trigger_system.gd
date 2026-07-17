class_name TriggerSystem
extends Node
## Trigger system for level events.
## Supports area-based triggers with conditions (PlayerInRange, EnemiesCleared)
## and actions (SpawnWave, SaveCheckpoint, LockDoor, UnlockDoor).

signal trigger_fired(trigger_name: String, action: String)

enum TriggerType { AREA_ENTER, WAVE_START, BOSS_SPAWN, CHECKPOINT, CUTSCENE }
enum ConditionType { PLAYER_IN_RANGE, ENEMIES_CLEARED, TIME_ELAPSED, FLAG_SET }
enum ActionType { SPAWN_WAVE, SPAWN_BOSS, SAVE_CHECKPOINT, PLAY_CUTSCENE, LOCK_DOOR, UNLOCK_DOOR }

class TriggerDefinition:
	var name: String
	var type: TriggerType
	var conditions: Array[Dictionary]  # [{type: ConditionType, value: var}]
	var actions: Array[Dictionary]     # [{type: ActionType, params: Dictionary}]
	var fired: bool = false
	var area_ref: Area3D

var triggers: Array[TriggerDefinition] = []
var flags: Dictionary = {}

func register_trigger(name: String, area: Area3D, type: TriggerType) -> TriggerDefinition:
	var t = TriggerDefinition.new()
	t.name = name
	t.type = type
	t.area_ref = area
	triggers.append(t)
	
	if area:
		area.area_entered.connect(_on_area_entered.bind(t))
	
	return t

func add_condition(trigger: TriggerDefinition, type: ConditionType, value = null) -> void:
	trigger.conditions.append({"type": type, "value": value})

func add_action(trigger: TriggerDefinition, type: ActionType, params: Dictionary = {}) -> void:
	trigger.actions.append({"type": type, "params": params})

func set_flag(flag: String, value: bool = true) -> void:
	flags[flag] = value

func _on_area_entered(_area: Area3D, trigger: TriggerDefinition) -> void:
	if trigger.fired:
		return
	if _check_conditions(trigger):
		_fire_trigger(trigger)

func _check_conditions(trigger: TriggerDefinition) -> bool:
	for condition in trigger.conditions:
		match condition.type:
			ConditionType.PLAYER_IN_RANGE:
				var player = get_tree().get_first_node_in_group("player")
				if not player:
					return false
				var dist = condition.value
				if trigger.area_ref and trigger.area_ref.global_position.distance_to(player.global_position) > dist:
					return false
			ConditionType.ENEMIES_CLEARED:
				var enemies = get_tree().get_nodes_in_group("enemies")
				for e in enemies:
					if not e.has_method("is_dead") or not e.is_dead:
						return false
			ConditionType.TIME_ELAPSED:
				if Time.get_ticks_msec() / 1000.0 < condition.value:
					return false
			ConditionType.FLAG_SET:
				if not flags.has(condition.value) or not flags[condition.value]:
					return false
	return true

func _fire_trigger(trigger: TriggerDefinition) -> void:
	trigger.fired = true
	trigger_fired.emit(trigger.name, "")
	for action in trigger.actions:
		_execute_action(action, trigger)

func _execute_action(action: Dictionary, trigger: TriggerDefinition) -> void:
	match action.type:
		ActionType.SPAWN_WAVE:
			var spawn = get_tree().get_first_node_in_group("spawn_manager")
			if spawn:
				var enemy_type = action.params.get("enemy_type", "infantry")
				var count = action.params.get("count", 1)
				for i in range(count):
					spawn.spawn_enemy(enemy_type)
		ActionType.SPAWN_BOSS:
			var level = get_tree().get_first_node_in_group("level")
			if level and level.has_method("_spawn_boss"):
				level._spawn_boss()
		ActionType.SAVE_CHECKPOINT:
			var checkpoint = get_tree().get_first_node_in_group("checkpoint_manager")
			if checkpoint and checkpoint.has_method("save_checkpoint"):
				checkpoint.save_checkpoint(action.params.get("data", {}))
		ActionType.LOCK_DOOR:
			var door_path = action.params.get("door_path", "")
			var door = get_node_or_null(door_path) if door_path else null
			if door and door.has_method("lock"):
				door.lock()
		ActionType.UNLOCK_DOOR:
			var door_path = action.params.get("door_path", "")
			var door = get_node_or_null(door_path) if door_path else null
			if door and door.has_method("unlock"):
				door.unlock()
