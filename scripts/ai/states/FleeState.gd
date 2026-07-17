extends Node
## Flee: panic run away from player. Faster than retreat.
## Activated when health is critically low.

var enemy: EnemyBase
var flee_point: Vector3

func setup(e: EnemyBase) -> void:
	enemy = e

func enter() -> void:
	flee_point = enemy.get_retreat_point()
	enemy.play_anim("run")

func exit() -> void:
	pass

func process(delta: float) -> void:
	if enemy.player and enemy.global_position.distance_to(flee_point) < 3.0:
		enemy.fsm.transition("idle")

func physics_process(delta: float) -> void:
	var nav = enemy.nav_to(flee_point)
	if nav.length() > 0:
		enemy.velocity.x = nav.x
		enemy.velocity.z = nav.z
	else:
		enemy.move_toward(flee_point, enemy.run_speed * 1.5)
