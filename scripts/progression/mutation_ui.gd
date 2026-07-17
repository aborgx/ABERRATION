class_name MutationUI
extends Control
## Mutation tree visualization. Shows 5 categories as columns, 5 tiers as rows.
## Nodes: locked (gray), available (white), unlocked (colored), equipped (glow).

signal mutation_selected(node_id: String)
signal unlock_requested(node_id: String)
signal equip_toggled(node_id: String)

var mutation_system: MutationSystem
var selected_node_id: String = ""

const CATEGORY_COLORS = {
	MutationTreeData.Category.AGILITY: Color(0.2, 0.8, 0.4),
	MutationTreeData.Category.COMBAT: Color(0.8, 0.2, 0.2),
	MutationTreeData.Category.FRENESIA: Color(0.8, 0.2, 0.6),
	MutationTreeData.Category.SENSE: Color(0.2, 0.4, 0.8),
	MutationTreeData.Category.BLOOD: Color(0.6, 0.1, 0.1),
}

var node_buttons: Dictionary = {}  # node_id -> Button

func _ready() -> void:
	mutation_system = get_tree().get_first_node_in_group("mutation_system")
	if not mutation_system:
		mutation_system = MutationSystem.new()
		mutation_system.add_to_group("mutation_system")
		add_child(mutation_system)

func _build_tree() -> void:
	if not mutation_system or not mutation_system.tree_data:
		return
	
	# Clear existing
	for child in get_children():
		child.queue_free()
	node_buttons.clear()
	
	var data = mutation_system.tree_data
	var tree_width = 900
	var tree_height = 500
	var col_width = tree_width / 5
	var row_height = tree_height / data.get_max_tier()
	
	for nid in data.all_nodes:
		var node = data.all_nodes[nid]
		var btn = TextureButton.new()
		btn.name = "Mut_" + nid
		btn.position = Vector2(
			node.grid_pos.x * col_width + col_width * 0.2,
			node.grid_pos.y * row_height + row_height * 0.2
		)
		btn.custom_minimum_size = Vector2(col_width * 0.6, row_height * 0.6)
		btn.mouse_entered.connect(_on_node_hover.bind(nid))
		btn.pressed.connect(_on_node_pressed.bind(nid))
		add_child(btn)
		node_buttons[nid] = btn

func _on_node_hover(nid: String) -> void:
	selected_node_id = nid
	mutation_selected.emit(nid)

func _on_node_pressed(nid: String) -> void:
	if mutation_system.can_unlock(nid):
		unlock_requested.emit(nid)
	elif mutation_system.is_unlocked(nid):
		equip_toggled.emit(nid)

func refresh_display() -> void:
	if not mutation_system:
		return
	for nid in node_buttons:
		var btn = node_buttons[nid]
		var node = mutation_system.tree_data.get_node_by_id(nid)
		if not node:
			continue
		if mutation_system.is_equipped(nid):
			btn.modulate = CATEGORY_COLORS.get(node.category, Color.WHITE) * 1.2
		elif mutation_system.is_unlocked(nid):
			btn.modulate = CATEGORY_COLORS.get(node.category, Color.WHITE)
		elif mutation_system.can_unlock(nid):
			btn.modulate = Color(0.8, 0.8, 0.8)
		else:
			btn.modulate = Color(0.3, 0.3, 0.3)

func get_selected_node_info() -> Dictionary:
	if not selected_node_id or not mutation_system:
		return {}
	var node = mutation_system.tree_data.get_node_by_id(selected_node_id)
	if not node:
		return {}
	return {
		"id": node.id,
		"name": node.name,
		"desc": node.description,
		"category": node.category,
		"tier": node.tier,
		"cost": node.cost,
		"unlocked": mutation_system.is_unlocked(node.id),
		"equipped": mutation_system.is_equipped(node.id),
		"can_unlock": mutation_system.can_unlock(node.id),
	}
