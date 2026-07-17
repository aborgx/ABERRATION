class_name MutationSystem
extends Node
## Core mutation system: track unlocked mutations, apply effects, manage mutation points.

signal mutation_unlocked(node_id: String)
signal mutation_equipped(node_id: String)
signal points_changed(total: int, available: int)
signal effects_applied(effects: Dictionary)

var tree_data: MutationTreeData
var unlocked: Dictionary = {}  # node_id -> true
var equipped: Dictionary = {}  # node_id -> true (max 12 equipped)
var mutation_points: int = 0
var total_mutations_unlocked: int = 0
var active_effects: Dictionary = {}  # effect_target -> cumulative value

func _ready() -> void:
	tree_data = MutationTreeData.new()

func add_points(amount: int) -> void:
	mutation_points += amount
	points_changed.emit(mutation_points, get_available_points())

func can_unlock(node_id: String) -> bool:
	var node = tree_data.get_node_by_id(node_id)
	if not node:
		return false
	if unlocked.has(node_id):
		return false
	if mutation_points < node.cost:
		return false
	for prereq in node.prerequisites:
		if not unlocked.has(prereq):
			return false
	return true

func unlock(node_id: String) -> bool:
	if not can_unlock(node_id):
		return false
	var node = tree_data.get_node_by_id(node_id)
	mutation_points -= node.cost
	unlocked[node_id] = true
	total_mutations_unlocked += 1
	mutation_unlocked.emit(node_id)
	points_changed.emit(mutation_points, get_available_points())
	# Auto-apply if not at max equipped
	if equipped.size() < 12:
		equip(node_id)
	return true

func equip(node_id: String) -> bool:
	if not unlocked.has(node_id):
		return false
	if equipped.size() >= 12:
		return false
	equipped[node_id] = true
	_recalculate_effects()
	mutation_equipped.emit(node_id)
	return true

func unequip(node_id: String) -> bool:
	if not equipped.has(node_id):
		return false
	equipped.erase(node_id)
	_recalculate_effects()
	return true

func is_unlocked(node_id: String) -> bool:
	return unlocked.has(node_id)

func is_equipped(node_id: String) -> bool:
	return equipped.has(node_id)

func get_available_points() -> int:
	return mutation_points

func get_total_mutations() -> int:
	return tree_data.all_nodes.size()

func _recalculate_effects() -> void:
	active_effects.clear()
	for nid in equipped:
		var node = tree_data.get_node_by_id(nid)
		if not node:
			continue
		var target = node.effect_target
		var current = active_effects.get(target, 0.0)
		match node.effect_type:
			MutationTreeData.EffectType.STAT_BOOST:
				active_effects[target] = current + node.effect_value
			MutationTreeData.EffectType.MODIFY_ATTACK:
				active_effects[target] = current + node.effect_value
			MutationTreeData.EffectType.PASSIVE:
				active_effects[target] = current + node.effect_value
			MutationTreeData.EffectType.UNLOCK_ABILITY:
				active_effects[target] = current + node.effect_value
	effects_applied.emit(active_effects.duplicate())

func get_effect(target: String) -> float:
	return active_effects.get(target, 0.0)

func has_ability(ability: String) -> bool:
	return active_effects.has(ability) and active_effects[ability] > 0.0

func reset_all() -> void:
	unlocked.clear()
	equipped.clear()
	mutation_points = 0
	total_mutations_unlocked = 0
	active_effects.clear()

func save_state() -> Dictionary:
	return {
		"unlocked": unlocked.keys(),
		"equipped": equipped.keys(),
		"points": mutation_points,
	}

func load_state(data: Dictionary) -> void:
	reset_all()
	mutation_points = data.get("points", 0)
	for nid in data.get("unlocked", []):
		unlocked[nid] = true
	for nid in data.get("equipped", []):
		equipped[nid] = true
	total_mutations_unlocked = unlocked.size()
	_recalculate_effects()
