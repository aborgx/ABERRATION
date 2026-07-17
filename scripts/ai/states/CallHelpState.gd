extends Node
## Call Help: alert nearby enemies to the player's presence.
## Triggers all enemies in radius to enter alert state.

var enemy: EnemyBase
var call_timer: float = 0.0

func setup(e: EnemyBase) -> void:
	enemy = e

func enter() -> void:
	call_timer = 2.0
	enemy.velocity = Vector3.ZERO
	enemy.play_anim("alert")

func exit() -> void:
	pass

func process(delta: float) -> void:
	call_timer -= delta
	if call_timer <= 0:
		_alert_nearby_enemies()
		if enemy.player_distance < enemy.engage_range:
			enemy.fsm.transition("engage")
		else:
			enemy.fsm.transition("patrol")

func physics_process(delta: float) -> void:
	enemy.velocity = Vector3.ZERO

func _alert_nearby_enemies() -> void:
	if not enemy.player:
		return
	var all_enemies = enemy.get_tree().get_nodes_in_group("enemies")
	var radius = 15.0
	for e in all_enemies:
		if e == enemy:
			continue
		var dist = enemy.global_position.distance_to(e.global_position)
		if dist < radius and e is EnemyBase and not e.is_dead:
			if e.fsm and e.fsm.current_state in ["idle", "patrol"]:
				e.fsm.transition("alert")
