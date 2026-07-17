extends Node
## Engage: pursue the player at run speed.

var enemy: EnemyBase

func setup(e: EnemyBase) -> void:
	enemy = e

func enter() -> void:
	enemy.play_anim("run")

func exit() -> void:
	pass

func process(delta: float) -> void:
	if not enemy.player:
		enemy.fsm.transition("patrol")
		return

	if enemy.player_distance < enemy.attack_range:
		enemy.fsm.transition("attack")
	elif enemy.player_distance > enemy.lose_range:
		enemy.fsm.transition("retreat")

func physics_process(delta: float) -> void:
	if not enemy.player:
		return
	# Move toward player — let navigation handle obstacle avoidance
	var nav = enemy.nav_to(enemy.player.global_position)
	if nav.length() > 0:
		enemy.velocity.x = nav.x
		enemy.velocity.z = nav.z
	else:
		enemy.move_toward(enemy.player.global_position, enemy.run_speed)
