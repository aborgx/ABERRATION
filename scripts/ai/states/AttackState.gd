extends Node
## Attack: stop and attack the player.
## Placeholder — actual combat will use CombatComponent in later waves.

var enemy: EnemyBase
var attack_cooldown: float = 0.0

func setup(e: EnemyBase) -> void:
	enemy = e

func enter() -> void:
	enemy.velocity = Vector3.ZERO
	enemy.play_anim("attack")
	attack_cooldown = 0.5

func exit() -> void:
	pass

func process(delta: float) -> void:
	attack_cooldown -= delta
	
	if enemy.player_distance > enemy.attack_range * 1.5:
		enemy.fsm.transition("engage")
	elif enemy.health < enemy.retreat_threshold:
		enemy.fsm.transition("retreat")

func physics_process(delta: float) -> void:
	enemy.velocity = Vector3.ZERO

func _deal_damage() -> void:
	# Placeholder — would use CombatComponent in future
	pass
