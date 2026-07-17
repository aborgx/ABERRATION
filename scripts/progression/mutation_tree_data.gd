class_name MutationTreeData
extends Resource
## Defines the mutation tree structure with 35 mutation nodes.
## Each node has position, cost, prerequisites, effects, and category.

enum Category { AGILITY, COMBAT, FRENESIA, SENSE, BLOOD }
enum EffectType { STAT_BOOST, UNLOCK_ABILITY, MODIFY_ATTACK, PASSIVE }

class MutationNode:
	var id: String
	var name: String
	var description: String
	var category: Category
	var tier: int  # 1-5
	var cost: int  # mutation points
	var prerequisites: Array[String]  # node IDs required first
	var effect_type: EffectType
	var effect_value: float
	var effect_target: String  # what stat/ability this affects
	var icon: String
	var grid_pos: Vector2  # position in tree grid

var all_nodes: Dictionary = {}  # id -> MutationNode
var category_order: Dictionary = {
	Category.AGILITY: 0,
	Category.COMBAT: 1,
	Category.FRENESIA: 2,
	Category.SENSE: 3,
	Category.BLOOD: 4,
}

func _init() -> void:
	_build_tree()

func _build_tree() -> void:
	# === AGILITY ===
	_add_node("agility_1", "Swift Step", "Move 10% faster", Category.AGILITY, 1, 1, [], EffectType.STAT_BOOST, 0.1, "move_speed")
	_add_node("agility_2", "Cat's Grace", "Reduce fall damage 50%", Category.AGILITY, 1, 1, ["agility_1"], EffectType.STAT_BOOST, 0.5, "fall_damage")
	_add_node("agility_3", "Dash Mastery", "Dash cooldown -30%", Category.AGILITY, 2, 2, ["agility_1"], EffectType.STAT_BOOST, 0.3, "dash_cooldown")
	_add_node("agility_4", "Wall Run", "Run on walls briefly", Category.AGILITY, 3, 3, ["agility_3"], EffectType.UNLOCK_ABILITY, 1.0, "wall_run")
	_add_node("agility_5", "Blink", "Short teleport dodge", Category.AGILITY, 4, 5, ["agility_4"], EffectType.UNLOCK_ABILITY, 1.0, "blink")
	_add_node("agility_6", "Afterimage", "Leave afterimage on dodge", Category.AGILITY, 4, 4, ["agility_4"], EffectType.PASSIVE, 1.0, "afterimage")
	_add_node("agility_7", "Wind Step", "Triple jump", Category.AGILITY, 5, 8, ["agility_5", "agility_6"], EffectType.UNLOCK_ABILITY, 1.0, "triple_jump")

	# === COMBAT ===
	_add_node("combat_1", "Razor Claws", "Melee damage +15%", Category.COMBAT, 1, 1, [], EffectType.STAT_BOOST, 0.15, "melee_damage")
	_add_node("combat_2", "Iron Grip", "Grab damage +30%", Category.COMBAT, 1, 1, ["combat_1"], EffectType.STAT_BOOST, 0.3, "grab_damage")
	_add_node("combat_3", "Nail Rain", "Nails fire in spread", Category.COMBAT, 2, 2, ["combat_1"], EffectType.MODIFY_ATTACK, 3.0, "nail_count")
	_add_node("combat_4", "Bloody Frenzy", "Kills heal 10 HP", Category.COMBAT, 3, 3, ["combat_3"], EffectType.PASSIVE, 10.0, "kill_heal")
	_add_node("combat_5", "Ground Pound", "Slam radius +50%", Category.COMBAT, 3, 3, ["combat_3"], EffectType.STAT_BOOST, 0.5, "slam_radius")
	_add_node("combat_6", "Dash Impact", "Dash attack stuns", Category.COMBAT, 4, 5, ["combat_4", "combat_5"], EffectType.PASSIVE, 1.0, "dash_stun")
	_add_node("combat_7", "Executioner", "Finisher on low HP enemies", Category.COMBAT, 5, 8, ["combat_6"], EffectType.UNLOCK_ABILITY, 1.0, "execution")

	# === FRENESIA ===
	_add_node("frenesia_1", "Frenesia Boost", "Frenesia gain +20%", Category.FRENESIA, 1, 1, [], EffectType.STAT_BOOST, 0.2, "frenesia_gain")
	_add_node("frenesia_2", "Slow Burn", "Frenesia decays 25% slower", Category.FRENESIA, 1, 1, ["frenesia_1"], EffectType.STAT_BOOST, 0.25, "frenesia_decay")
	_add_node("frenesia_3", "Blood Rage", "Damage at low HP heals frenesia", Category.FRENESIA, 2, 2, ["frenesia_1"], EffectType.PASSIVE, 5.0, "rage_frenesia")
	_add_node("frenesia_4", "Frenetic Speed", "Frenesia gives more speed", Category.FRENESIA, 3, 3, ["frenesia_3"], EffectType.STAT_BOOST, 0.2, "frenesia_speed_bonus")
	_add_node("frenesia_5", "Overcharge", "Overfrenesia lasts 50% longer", Category.FRENESIA, 4, 5, ["frenesia_4"], EffectType.STAT_BOOST, 0.5, "overfrenesia_duration")
	_add_node("frenesia_6", "Frenesia Nova", "Entering frenesia damages nearby", Category.FRENESIA, 4, 4, ["frenesia_4"], EffectType.PASSIVE, 30.0, "frenesia_nova_damage")
	_add_node("frenesia_7", "Unstoppable", "Damage resistance during frenesia", Category.FRENESIA, 5, 8, ["frenesia_5", "frenesia_6"], EffectType.STAT_BOOST, 0.4, "frenesia_armor")

	# === SENSE ===
	_add_node("sense_1", "Predator Sight", "Highlight enemies in 15m", Category.SENSE, 1, 1, [], EffectType.STAT_BOOST, 15.0, "highlight_range")
	_add_node("sense_2", "Heat Vision", "See through thin walls", Category.SENSE, 2, 2, ["sense_1"], EffectType.UNLOCK_ABILITY, 1.0, "heat_vision")
	_add_node("sense_3", "Danger Sense", "Warn of off-screen attacks", Category.SENSE, 2, 2, ["sense_1"], EffectType.PASSIVE, 1.0, "danger_warning")
	_add_node("sense_4", "Threat Assessment", "Show enemy HP bars", Category.SENSE, 3, 3, ["sense_2", "sense_3"], EffectType.UNLOCK_ABILITY, 1.0, "health_bars")
	_add_node("sense_5", "Adrenaline", "Slow motion on dodge", Category.SENSE, 4, 5, ["sense_4"], EffectType.PASSIVE, 1.0, "bullet_time")
	_add_node("sense_6", "Predator Focus", "Mark target takes extra damage", Category.SENSE, 5, 8, ["sense_5"], EffectType.MODIFY_ATTACK, 0.5, "marked_target_damage")

	# === BLOOD ===
	_add_node("blood_1", "Blood Thirst", "Kills drop health orbs", Category.BLOOD, 1, 1, [], EffectType.PASSIVE, 1.0, "health_orbs")
	_add_node("blood_2", "Carnage", "Blood explosion on kill", Category.BLOOD, 2, 2, ["blood_1"], EffectType.PASSIVE, 30.0, "blood_explosion_damage")
	_add_node("blood_3", "Hemomancy", "Spend HP for frenesia", Category.BLOOD, 3, 3, ["blood_2"], EffectType.UNLOCK_ABILITY, 1.0, "hemomancy")
	_add_node("blood_4", "Life Steal", "5% damage returns as HP", Category.BLOOD, 3, 3, ["blood_2"], EffectType.STAT_BOOST, 0.05, "life_steal")
	_add_node("blood_5", "Blood Shield", "HP > frenesia overflow becomes shield", Category.BLOOD, 4, 5, ["blood_3", "blood_4"], EffectType.PASSIVE, 1.0, "blood_shield")
	_add_node("blood_6", "Immortal", "Revive once per level on death", Category.BLOOD, 5, 10, ["blood_5"], EffectType.PASSIVE, 1.0, "revive")
	_add_node("blood_7", "Red Mist", "Kill streak buffs damage", Category.BLOOD, 5, 8, ["blood_5"], EffectType.PASSIVE, 1.0, "kill_streak")

func _add_node(id: String, name: String, desc: String, cat: Category, tier: int, cost: int, prereqs: Array[String], etype: EffectType, evalue: float, etarget: String) -> void:
	var n = MutationNode.new()
	n.id = id
	n.name = name
	n.description = desc
	n.category = cat
	n.tier = tier
	n.cost = cost
	n.prerequisites = prereqs
	n.effect_type = etype
	n.effect_value = evalue
	n.effect_target = etarget
	n.grid_pos = Vector2(_calc_col(cat, id), tier - 1)
	all_nodes[id] = n

func _calc_col(category: Category, id: String) -> int:
	var nodes_in_cat = []
	for nid in all_nodes:
		if all_nodes[nid].category == category:
			nodes_in_cat.append(nid)
	return nodes_in_cat.size()

func get_node_by_id(id: String) -> MutationNode:
	return all_nodes.get(id, null)

func get_nodes_by_category(cat: Category) -> Array[MutationNode]:
	var result: Array[MutationNode] = []
	for nid in all_nodes:
		if all_nodes[nid].category == cat:
			result.append(all_nodes[nid])
	return result

func get_total_cost() -> int:
	var total = 0
	for nid in all_nodes:
		total += all_nodes[nid].cost
	return total

func get_max_tier() -> int:
	var max_t = 0
	for nid in all_nodes:
		if all_nodes[nid].tier > max_t:
			max_t = all_nodes[nid].tier
	return max_t
