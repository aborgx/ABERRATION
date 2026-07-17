extends Node
## Search: move toward last known player position.
## Transitions to patrol if player not found within time limit.

var enemy: EnemyBase
var search_timer: float = 0.0
var last_known_pos: Vector3

func setup(e: EnemyBase) -> void:
	enemy = e

func enter() -> void:
	search_timer = 5.0
	last_known_pos = enemy.player.global_position if enemy.player else enemy.global_position
	enemy.play_anim("walk")

func exit() -> void:
	pass

func process(delta: float) -> void:
	search_timer -= delta
	
	if enemy.can_see_player:
		enemy.fsm.transition("engage")
	elif search_timer <= 0:
		enemy.fsm.transition("patrol")

func physics_process(delta: float) -> void:
	if enemy.global_position.distance_to(last_known_pos) < 2.0:
		# Reached last known position — look around briefly
		enemy.velocity = Vector3.ZERO
		return
	enemy.move_toward(last_known_pos, enemy.move_speed)
