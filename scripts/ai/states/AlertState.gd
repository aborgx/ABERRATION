extends Node
## Alert: brief reaction state before engaging.
## Serves as telegraph to the player.

var enemy: EnemyBase
var alert_timer: float = 0.0

func setup(e: EnemyBase) -> void:
	enemy = e

func enter() -> void:
	alert_timer = 1.0
	enemy.velocity = Vector3.ZERO
	enemy.play_anim("alert")

func exit() -> void:
	pass

func process(delta: float) -> void:
	alert_timer -= delta
	if alert_timer <= 0:
		if enemy.player_distance < enemy.engage_range:
			enemy.fsm.transition("engage")
		else:
			enemy.fsm.transition("patrol")

func physics_process(delta: float) -> void:
	# Face toward player during alert
	if enemy.player:
		var dir = (enemy.player.global_position - enemy.global_position).normalized()
		enemy.look_at(enemy.global_position + dir * Vector3(1, 0, 1), Vector3.UP)
