extends Node
## Idle: enemy stands still, watches for player.

var enemy: EnemyBase

func setup(e: EnemyBase) -> void:
	enemy = e

func enter() -> void:
	enemy.velocity = Vector3.ZERO
	enemy.play_anim("idle")

func exit() -> void:
	pass

func process(delta: float) -> void:
	if enemy.can_see_player:
		enemy.fsm.transition("alert")

func physics_process(delta: float) -> void:
	pass
