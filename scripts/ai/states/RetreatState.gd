extends Node
## Retreat: fall back to a safe point when health is low or player is far.

var enemy: EnemyBase
var retreat_target: Vector3

func setup(e: EnemyBase) -> void:
	enemy = e

func enter() -> void:
	retreat_target = enemy.get_retreat_point()
	enemy.play_anim("run")

func exit() -> void:
	pass

func process(delta: float) -> void:
	if enemy.global_position.distance_to(retreat_target) < 3.0:
		enemy.fsm.transition("idle")
	elif enemy.can_see_player and enemy.player_distance < enemy.engage_range:
		enemy.fsm.transition("engage")

func physics_process(delta: float) -> void:
	var nav = enemy.nav_to(retreat_target)
	if nav.length() > 0:
		enemy.velocity.x = nav.x
		enemy.velocity.z = nav.z
	else:
		enemy.move_toward(retreat_target, enemy.run_speed)
