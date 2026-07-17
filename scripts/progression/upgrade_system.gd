class_name UpgradeSystem
extends Node
## Weapon upgrade system. Each weapon (Melee, Nail, Scream, Grab) has 5 levels.
## Upgrades unlock via mutation system or found in levels.

signal weapon_upgraded(weapon: String, new_level: int)

enum Weapon { MELEE, NAIL, SCREAM, GRAB }

var weapon_levels: Dictionary = {
	Weapon.MELEE: 1,
	Weapon.NAIL: 1,
	Weapon.SCREAM: 1,
	Weapon.GRAB: 1,
}

# Per-level stat multipliers
const LEVEL_STATS = {
	Weapon.MELEE: [
		{"damage": 30,  "range": 2.5, "combo_window": 0.5},
		{"damage": 36,  "range": 2.6, "combo_window": 0.55},
		{"damage": 42,  "range": 2.7, "combo_window": 0.6},
		{"damage": 50,  "range": 2.8, "combo_window": 0.65},
		{"damage": 60,  "range": 3.0, "combo_window": 0.7},
	],
	Weapon.NAIL: [
		{"damage": 20,  "count": 1,  "penetration": 3},
		{"damage": 24,  "count": 1,  "penetration": 3},
		{"damage": 28,  "count": 2,  "penetration": 4},
		{"damage": 35,  "count": 2,  "penetration": 4},
		{"damage": 45,  "count": 3,  "penetration": 5},
	],
	Weapon.SCREAM: [
		{"damage": 10,  "range": 8.0, "stun": 1.5, "cooldown": 8.0},
		{"damage": 12,  "range": 8.5, "stun": 1.5, "cooldown": 7.5},
		{"damage": 15,  "range": 9.0, "stun": 2.0, "cooldown": 7.0},
		{"damage": 18,  "range": 10.0, "stun": 2.0, "cooldown": 6.5},
		{"damage": 25,  "range": 12.0, "stun": 2.5, "cooldown": 6.0},
	],
	Weapon.GRAB: [
		{"damage": 40,  "cooldown": 1.0},
		{"damage": 50,  "cooldown": 0.9},
		{"damage": 60,  "cooldown": 0.8},
		{"damage": 75,  "cooldown": 0.7},
		{"damage": 100, "cooldown": 0.5},
	],
}

func get_level(weapon: Weapon) -> int:
	return weapon_levels.get(weapon, 1)

func upgrade_weapon(weapon: Weapon) -> bool:
	var current = weapon_levels.get(weapon, 1)
	if current >= 5:
		return false
	weapon_levels[weapon] = current + 1
	weapon_upgraded.emit(Weapon.keys()[weapon], current + 1)
	return true

func get_stats(weapon: Weapon) -> Dictionary:
	var level = clamp(weapon_levels.get(weapon, 1), 1, 5) - 1
	return LEVEL_STATS.get(weapon, [{}])[level].duplicate()

func apply_to_combat(combat: CombatComponent) -> void:
	"""Apply weapon level stats to a CombatComponent."""
	var melee = get_stats(Weapon.MELEE)
	combat.melee_damage = melee.get("damage", combat.melee_damage)
	combat.melee_range = melee.get("range", combat.melee_range)
	combat.combo_window = melee.get("combo_window", combat.combo_window)
	
	# Apply to stats directly (works if variables exist)
	if combat.has_method("set_nail_stats"):
		combat.set_nail_stats(get_stats(Weapon.NAIL))
	if combat.has_method("set_scream_stats"):
		combat.set_scream_stats(get_stats(Weapon.SCREAM))
	if combat.has_method("set_grab_stats"):
		combat.set_grab_stats(get_stats(Weapon.GRAB))

func save_state() -> Dictionary:
	return {"levels": weapon_levels.duplicate()}

func load_state(data: Dictionary) -> void:
	for weapon in Weapon.values():
		weapon_levels[weapon] = data.get("levels", {}).get(weapon, 1)
